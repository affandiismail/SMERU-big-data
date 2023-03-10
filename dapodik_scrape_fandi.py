#scrape https://dapo.kemdikbud.go.id/
# Date: Feb 23, 2023

from urllib.request import urlopen
import requests
from bs4 import BeautifulSoup
import timeit
import csv
import json
import os


start = timeit.default_timer()

url = "https://dapo.kemdikbud.go.id/sp"
page = requests.get(url)




# check in the developer tools of the website for the json link
# note that the semester id is genap 2022
first = "https://dapo.kemdikbud.go.id/rekap/dataSekolah\
?id_level_wilayah=0&kode_wilayah=000000&semester_id=20222"
first_page = urlopen(first)

# see what is contained in the json data
prov = json.loads(first_page.read())

# count how many rows in the json data
count_prov = len(prov)

# get all province name and its code
for x in range(count_prov):
    nama_prov = prov[x]['nama']
    kode_prov = prov[x]['kode_wilayah']
    #prepare the csv, can be updated later after find out all needed columns
    file = "D:/SMERU/Belajar python/belajar web scraping/data_dapodik_"+prov[x]['nama']+".csv"

    f = open(file, "w")
    headers = "nama_prov,kode_prov,nama_kab,kode_kab,\
        nama_kec,kode_kec,nama_school,npsn,bentuk_pendidikan,status_sekolah,school_id \n"
    f.write(headers)
    print(f"\nNama: {prov[x]['nama']}; \
Kode: {prov[x]['kode_wilayah']} \n")

    # go into each districts
    start_second = "https://dapo.kemdikbud.go.id/rekap/dataSekolah\
?id_level_wilayah=1\
&kode_wilayah="+prov[x]["kode_wilayah"]+"&semester_id=20222"
    second = start_second.replace(" ","")
    second_page = urlopen(second)
    district = json.loads(second_page.read())
    count_dist = len(district)
    for i in range(count_dist):
        nama_kab = district[i]["nama"]
        kode_kab = district[i]["kode_wilayah"]
        print(f"\nNama: {district[i]['nama']}; \
Kode: {district[i]['kode_wilayah']}\n")
        print(f"District {i} of {count_dist}")

        # go into each kecamatan
        start_third = "https://dapo.kemdikbud.go.id/rekap/dataSekolah\
?id_level_wilayah=2\
&kode_wilayah="+district[i]["kode_wilayah"]+"&semester_id=20222"
        third = start_third.replace(" ","")
        third_page = urlopen(third)
        kec = json.loads(third_page.read())
        count_kec = len(kec)
        for j in range(count_kec):
            nama_kec = kec[j]["nama"]
            kode_kec = kec[j]["kode_wilayah"]
            print(f"Nama: {kec[j]['nama']}; \
Kode: {kec[j]['kode_wilayah']}")

            # go into each school
            start_fourth = "https://dapo.kemdikbud.go.id/rekap/progresSP\
?id_level_wilayah=3&kode_wilayah="+kec[j]["kode_wilayah"]+\
"&semester_id=20222&bentuk_pendidikan_id="
            fourth = start_fourth.replace(" ","")
            fourth_page = urlopen(fourth)
            fourth_read = fourth_page.read()
            school = json.loads(fourth_read)
            count_school = len(school)
            for k in range(count_school):
                nama_school = school[k]["nama"]
                npsn = school[k]["npsn"]
                school_id = school[k]["sekolah_id_enkrip"]

                # go into each school detail
                start_fourth = "https://dapo.kemdikbud.go.id/rekap/progresSP\
?id_level_wilayah=3&kode_wilayah="+kec[j]["kode_wilayah"]+\
"&semester_id=20222&bentuk_pendidikan_id="
                fourth = start_fourth.replace(" ","")
                fourth_page = urlopen(fourth)
                fourth_read = fourth_page.read()
                school = json.loads(fourth_read)
                count_school = len(school)
                for k in range(count_school):
                    nama_school = school[k]["nama"]
                    npsn = school[k]["npsn"]
                    bentuk_pendidikan = school[k]["bentuk_pendidikan"]
                    status_sekolah = school[k]["status_sekolah"]
                    school_id = school[k]["sekolah_id_enkrip"]


                f.write('"{}"'.format(nama_prov) +
                ',"{}"'.format(kode_prov) +
                ',"{}"'.format(nama_kab) +
                ',"{}"'.format(kode_kab) +
                ',"{}"'.format(nama_kec) +
                ',"{}"'.format(kode_kec) + 
                ',"{}"'.format(nama_school) +
                ',"{}"'.format(npsn) +
                ',"{}"'.format(bentuk_pendidikan) +
                ',"{}"'.format(status_sekolah) +
                ',"{}"'.format(school_id) + "\n")
        
f.close()

end = timeit.default_timer()
print(end - start)

import pandas as pd
import numpy as np

df = pd.read_csv("belajar web scraping\data_dapodik_Prov. Jawa Timur.csv")
df.head(100)