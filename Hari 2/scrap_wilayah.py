import requests
import pandas as pd
from bs4 import BeautifulSoup

data_wilayah = []
base_url = 'https://dapo.kemdikbud.go.id/rekap/dataSekolah?id_level_wilayah={level}&kode_wilayah={kode_wilayah}&semester_id=20222'

data_prov_request = requests.get(base_url.format(level=0, kode_wilayah='000000')) # fungsi format untuk formating string, bisa juga untuk menambahkan variabel ke dalam string
data_prov = data_prov_request.json()

for prov in data_prov:
    print('----------------------------------------------------------------------------------------')
    print(f'Mengambil data provinsi {prov["nama"]}')
    data_kab_request = requests.get(base_url.format(level=prov["id_level_wilayah"], kode_wilayah=prov["kode_wilayah"]))
    data_kab = data_kab_request.json()
    for kab in data_kab:
        print(f'Mengambil data kabupaten {kab["nama"]}')
        data_kec_request = requests.get(base_url.format(level=kab["id_level_wilayah"], kode_wilayah=kab["kode_wilayah"]))
        data_kec = data_kec_request.json()
        for kec in data_kec:
            data_wilayah.append({
                'prov': prov['nama'],
                'kode_prov': prov['kode_wilayah'],
                'kab': kab['nama'],
                'kode_kab': kab['kode_wilayah'],
                'kec': kec['nama'],
                'kode_kec': kec['kode_wilayah']
            })

df_wilayah = pd.DataFrame(data_wilayah, dtype='str') # Membuat dataframe dari list of dictionary
df_wilayah.to_csv('data\wilayah_dapodik.csv', index=False) # Simpan data dengan format csv, argumen index pada fungsi to_csv untuk memastikan index pada datafram tidak ikut tersimpan
