        import requests
        from bs4 import BeautifulSoup
        from pprint import pprint
        import pandas as pd
        import warnings
        warnings.filterwarnings("ignore", message="Unverified HTTPS request is being made.*")
        import re

        def make_request(kec_code, jenjang):
            while True:
                try:
                    response = requests.get(f'https://referensi.data.kemdikbud.go.id/pendidikan/{jenjang}/{kec_code}/3', verify=False)
                    response.raise_for_status()
                    return response
                except requests.exceptions.HTTPError as errh:
                    print(f"HTTP Error: {errh}")
                except requests.exceptions.ConnectionError as errc:
                    print(f"Error Connecting: {errc}")
                except requests.exceptions.Timeout as errt:
                    print(f"Timeout Error: {errt}")
                except requests.exceptions.RequestException as err:
                    print(f"Something went wrong: {err}")

        def make_request_sek(url):
            while True:
                try:
                    response = requests.get(url, verify=False)
                    response.raise_for_status()
                    return response
                except requests.exceptions.HTTPError as errh:
                    print(f"HTTP Error: {errh}")
                    return response
                except requests.exceptions.ConnectionError as errc:
                    print(f"Error Connecting: {errc}")
                except requests.exceptions.Timeout as errt:
                    print(f"Timeout Error: {errt}")
                except requests.exceptions.RequestException as err:
                    print(f"Something went wrong: {err}")

        def get_column_based_data(table, key_prefix, data_dict): # Ekstraksi data tabel yang mempunyai orientasi kolom
            key_data = table[0].find_all('td')[:-1]
            value_data = table[1].find_all('td')[:-1]

            for i in range(len(key_data)):
                key = key_prefix+key_data[i].get_text(strip=True).lower()
                key = re.sub(r'(\s-*\s*|\s*-\s*)', '_', key)
                value = value_data[i].get_text(strip=True)
                data_dict[key] = value

        def get_row_based_data(table, key_prefix, data_dict): # Ekstraksi data tabel yang mempunyai orientasi baris
            table = table[2:]
            for row in table:
                key_value = row.find_all('td')
                key = key_prefix+key_value[0].get_text(strip=True).lower()
                # key = key.replace('-', '_').replace(' - ', '_').replace(' ', '_')
                key = re.sub(r'(\s-*\s*|\s*-\s*)', '_', key) # Untuk mengganti teks pada sebuah string dengan pola regular ekspression, hasilnya akan sama dengan baris program yang ada diatasnya
                value = key_value[1].get_text(strip=True)
                data_dict[key] = value
        # Kedua fungsi tersebut dibuat karena operasi digunakan beberapa kali, sehingga mempermudah untuk pemanggilan dan perbaikan fungsi

        def get_data_sekolah_kita(link_sekolah_kita):
            data_sekolah = {}
            r = make_request_sek(link_sekolah_kita)
            soup = BeautifulSoup(r.content, 'html.parser')

            akreditasi = soup.find('div', {'class': 'box-body box-profile'}).find_all('li')[1].get_text(strip=True)

            data_sekolah['akreditasi'] = akreditasi.split(':')[1].strip()

            data_utama = soup.find_all('div', {'class': 'col-xs-12 col-md-3 text-left'})
            for du in data_utama:
                value_data = du.get_text("~", strip=True)
                value_data = value_data.split("~")

                for i in range(len(value_data)):
                    if value_data[i] == '*':
                        continue
                    if ':' in value_data[i]:
                        if re.search(r":$", value_data[i]):
                            key = value_data[i]
                            key = key.strip(' :').lower().replace(' ', '_').replace('-', '_')
                            if i == len(value_data)-1:
                                data_sekolah[key] = None
                                continue
                                
                            value = value_data[i+1]
                            if ':' in value:
                                value = None
                            data_sekolah[key] = value
                        else:
                            key_value = value_data[i].split(':')
                            key = key_value[0]
                            key = key.strip().lower().replace(' ', '_').replace('-', '_')
                            value = key_value[1]
                            value = value.strip()
                            data_sekolah[key] = value
                            if "akses_internet" in data_sekolah:
                                # Retrieve the value associated with the "akses_internet" key
                                value = data_sekolah.pop("akses_internet")
                                # Add the value to the dictionary with the new key name
                                data_sekolah["akses_internet_sekolah_kita"] = value
                
            status_guru = soup.find('div', {'id': 'gurustatus'}).find_all('tr')
            get_row_based_data(status_guru, 'guru_', data_sekolah)
            golongan_guru = soup.find('div', {'id': 'gurugolongan'}).find_all('tr')
            get_column_based_data(golongan_guru, 'guru_gol_', data_sekolah)
            sertifikasi_guru = soup.find('div', {'id': 'gurusertifikasi'}).find_all('tr')
            get_row_based_data(sertifikasi_guru, 'guru_', data_sekolah)
            ijazah_guru = soup.find('div', {'id': 'guruijazah'}).find_all('tr')
            get_row_based_data(ijazah_guru, 'guru_', data_sekolah)
            umur_guru = soup.find('div', {'id': 'guruumur'}).find_all('tr')
            get_row_based_data(umur_guru, 'guru_', data_sekolah)
            jeniskelamin_guru = soup.find('div', {'id': 'gurujeniskelamin'}).find_all('tr')
            get_row_based_data(jeniskelamin_guru, 'guru_', data_sekolah)
            rombel_data = soup.find('div', {'id': 'rombel'}).find_all('tr')
            get_row_based_data(rombel_data, 'rombel_tingkat_', data_sekolah)
            ruang_kelas = soup.find('div', {'id': 'ruangkelas'}).find_all('tr')
            get_row_based_data(ruang_kelas, 'ruang_kelas_', data_sekolah)
            perpustakaan = soup.find('div', {'id': 'perpustakaan'}).find_all('tr')
            get_row_based_data(perpustakaan, 'perpustakaan_', data_sekolah)

            return data_sekolah


        def get_sekolah(kec_code, jenjang):
            response = make_request(kec_code, jenjang)
            html_content = response.content
            data_all = [] # tempat menyimpan semua data sekolah pada kecamatan terpilih

            # Parse the HTML content using BeautifulSoup
            soup = BeautifulSoup(html_content, 'html.parser')
            print(f'Mengambil data di kecamatan ke {i} dari {len(df_wilayah)} \n {wilayah.prov_name}, {wilayah.kab_name}, {wilayah.kec_name}')

            # Find all the table cells with class "link1"
            cells = soup.find_all('td', {'class': 'link1'})
            web = [cell.find('a')['href'] for cell in cells]
            for w in web:
                response = make_request_sek(w)
                html_content = response.content
                soup = BeautifulSoup(html_content, 'html.parser')
                cells = soup.find_all('div', {'class': 'tabby-content'})

                data_referensi = [cells[0], cells[1], cells[2], cells[3],]
                tab_peta = cells[4]

                data = {'prov_name': wilayah.prov_name, 'kab_name': wilayah.kab_name, 'kec_name': wilayah.kec_name}

                data['link_sekolah_kita'] = cells[0].find('a')['href']
                data['link_referensi'] = w.strip()

                for df in data_referensi:
                    for element in df.find_all('tr'):
                        text = element.get_text()
                        if text == '':
                            continue
                        if text.split(':')[1].strip() == '' or text.split(':')[1].strip() == '-':
                            value = None
                        else:
                            value = text.split(':')[1].strip()
                        if text.split(':')[0].lower().strip().replace(' ', '_') == "":
                            data['akses_internet_2'] = value
                        else:
                            data[text.split(':')[0].lower().strip().replace(' ', '_')] = value

                for element in tab_peta.find_all('div', {'class': 'col-lg-4 col-md-4'}):
                    text = element.get_text()
                    if text.split('\n')[1].strip().split(':')[1] == '' or text.split('\n')[1].strip().split(':')[1] == '-' or text.split('\n')[1].strip().split(':')[1] == 0:
                        value = None
                    else:
                        if text.split('\n')[1].strip().split(': ')[1] == '' or text.split('\n')[1].strip().split(': ')[1] == '-' or text.split('\n')[1].strip().split(': ')[1] == 0:
                            value = None
                        else:
                            value = text.split('\n')[1].strip().split(': ')[1]
                        data[text.split('\n')[1].strip().split(': ')[0].lower().replace(' ', '_')] = value
                    if text.split('\n')[2].strip().split(':')[1] == '' or text.split('\n')[2].strip().split(':')[1] == '-' or text.split('\n')[2].strip().split(':')[1] == 0:
                        value = None
                    else:
                        if text.split('\n')[2].strip().split(': ')[1] == '' or text.split('\n')[2].strip().split(': ')[1] == '-' or text.split('\n')[2].strip().split(': ')[1] == 0:
                            value = None
                        else:
                            value = text.split('\n')[2].strip().split(': ')[1]
                        data[text.split('\n')[2].strip().split(': ')[0].lower().replace(' ', '_')] = value

                try:
                    data_sekolah = get_data_sekolah_kita(data['link_sekolah_kita'])
                except  AttributeError:
                    data_sekolah = []
                except requests.exceptions.HTTPError:
                    data_sekolah = []

                if data_sekolah == []:
                    data = data
                else:
                    data = {**data, **data_sekolah}

                data_all.append(data)

            df_sekolah = pd.DataFrame(data_all)
            df_sekolah.to_csv(f'data/data_sekolah_kita_v2/{jenjang}/{i}_detail_sekolah_kita_{kec_code.strip()}.csv', index=False)

        df_wilayah = pd.read_csv('data/data_sekolah_kita_v2/df_wilayah/wilayah_sekolah_kita.csv', dtype='str')

        for i, wilayah in df_wilayah.iloc[0:len(df_wilayah)].iterrows():
            akreditasi = get_sekolah(wilayah.kec_code, 'dikmen')
