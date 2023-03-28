import re
import requests
import pandas as pd
from bs4 import BeautifulSoup

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
    data_sekolah = {'link_sekolah_kita': link_sekolah_kita}
    r = requests.get(link_sekolah_kita)
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
    
    return data_sekolah

# contoh penggunaan dengan menggunakan data hasil dari program scrap_detail_dapodik.py Karena data sekolah disimpan setiap kecamatan, maka penggunaanya juga setiap kecamatan
# data = []
# df_sekolah = pd.read_csv('data/detail_dapodik_056020.csv')
# for i, sekolah in df_sekolah.iterrows():
#     data.append(get_data_sekolah_kita(sekolah.link_sekolah_kita))
# df_sekolah_kita = pd.DataFrame(data)
# df_sekolah_kita.to_csv('data/detail_sekolah_kita_056020.csv', index=False) # Menyimpan data sekolah kita untuk satu kecamatan dengan nama yang bersesuaian dengan data sekolah dapodik
