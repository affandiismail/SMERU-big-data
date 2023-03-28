import requests
import pandas as pd
from bs4 import BeautifulSoup
import json
import timeit

def get_data_dapodik(kode_kec): # Dibuat menjadi fungsi agar lebih mudah dibaca
    data = [] # tempat menyimpan semua data sekolah pada kecamatan terpilih
    url = f'https://dapo.kemdikbud.go.id/rekap/progresSP?id_level_wilayah=3&kode_wilayah={kode_kec}&semester_id=20222&bentuk_pendidikan_id='
    r = requests.get(url)
    daftar_sekolah = r.json()
    print(f'Mengambil data di kecamatan ke {i} dari {len(df_wilayah)} \n {wilayah.prov}, {wilayah.kab}, {wilayah.kec}')

    for sekolah in daftar_sekolah:
        data_sekolah = {'kode_kec': kode_kec.strip()} # membuat dictionary data sekolah
        url_html = f'https://dapo.kemdikbud.go.id/sekolah/{sekolah["sekolah_id_enkrip"]}'
        url_json = f'https://dapo.kemdikbud.go.id/rekap/sekolahDetail?semester_id=20222&sekolah_id={sekolah["sekolah_id_enkrip"]}' # pada website dapodik digunakan 2 tipe transfer data, jadi dibutuhkan 2 alamat url
        r_json = requests.get(url_json)
        json_data = r_json.json()
        json_data = json.loads(json.dumps(json_data[0]))

        r_html = requests.get(url_html)
        html_soup = BeautifulSoup(r_html.content, 'html.parser')

        data_sekolah['nama'] = html_soup.find('h2', {'class': 'name'}).get_text(strip=True)
        data_sekolah['link_dapo'] = url_html.strip()
        data_sekolah['link_sekolah_kita'] = html_soup.find('div', {'class': 'profile-userbuttons'}).find('a')['href']
        data_sekolah['last_sync'] = sekolah["sinkron_terakhir"]

        profile = html_soup.find('div', {'class': 'profile-usermenu'}).find_all('a')
        akreditasi = profile[2].get_text(strip=True)
        data_sekolah['akreditasi'] = akreditasi.split(':')[1]
        kurikulum = profile[3].get_text(strip=True)
        data_sekolah['kurikulum'] = kurikulum.split(':')[1]

        data_utama = html_soup.find_all('div', {'class': 'panel panel-info'})
        data_utama = [data_utama[0], data_utama[1], data_utama[2], data_utama[7]] # data utama pada table dalam tab dipilih dan dimasukkan ke dalam list untuk dilakukan ekstraksi data dengan iterasi kemudian

        for du in data_utama: # Pemrosesan data utama dilakukan dengan iterasi karena proses yang dilakukan sama untuk semua tabel
            for data_value in du.find_all('p'):
                text = data_value.get_text()
                if text.split(':')[1].strip()=='' or text.split(':')[1].strip()=='-': # Jika data berisi '-' atau string kosong maka dianggap missing value
                    value = None
                else: # Selain missing maka data akan dibersihkan untuk disimpan pada dictionary
                    value = text.split(':')[1].strip()
                data_sekolah[text.split(':')[0].lower().strip().replace(' ', '_')] = value # Key untuk dictionary juga diambil dari tabel dengan melakukan cleaning terlebih dahulu

        data_sekolah = {**data_sekolah, **json_data} # Ini adalah fungsi unpack pada python, untuk menggabungka 2 atau lebih dictionary
        data.append(data_sekolah)

    df_sekolah = pd.DataFrame(data)
    df_sekolah.to_csv(f'data/{i}_detail_dapodik_{kode_kec.strip()}.csv', index=False)

# Contoh penggunaan, menggunakan file wilayah kecamatan yang didapat dari program scrap_wilayah.py
df_wilayah = pd.read_csv('D:\SMERU\Belajar python\QSS\Hari 2\data\wilayah_dapodik.csv', dtype='str')
start = timeit.default_timer()
#ganti jadi 
for i, wilayah in df_wilayah.iloc[592:len(df_wilayah)].iterrows():
    get_data_dapodik(wilayah.kode_kec)
end = timeit.default_timer()
print(end - start)

df_wilayah

url = f'https://dapo.kemdikbud.go.id/rekap/progresSP?id_level_wilayah=3&kode_wilayah=056020&semester_id=20222&bentuk_pendidikan_id='
r = requests.get(url)
daftar_sekolah = r.json()

url_html = 'https://dapo.kemdikbud.go.id/sekolah/4E0CC2693ADA09B17A62'
r_html = requests.get(url_html)
html_soup = BeautifulSoup(r_html.content, 'html.parser')

data = []
data['link_sekolah_kita'] = html_soup.find('div', {'class': 'profile-userbuttons'}).find('a')['href']

aww = {}
aww ['asa'] = html_soup.find('div', {'class': 'profile-userbuttons'}).find('a')['href']

