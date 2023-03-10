import requests
from bs4 import BeautifulSoup

url = 'https://referensi.data.kemdikbud.go.id/pendidikan/paud/'

# Send a GET request to the URL and retrieve the HTML content
response = requests.get(url)
html_content = response.content

# Parse the HTML content using BeautifulSoup
soup = BeautifulSoup(html_content, 'html.parser')

# Find all the table cells with class "link1"
cells = soup.find_all('td', {'class': 'link1'})

# Extract the code and province name pairs from the cells
code_province_pairs = []
for cell in cells:
    link = cell.find('a')
    if link is not None:
        href = link.get('href')
        prov_code = href.split('/')[-2]
        prov_name = link.text.strip()

        url_prov = 'https://referensi.data.kemdikbud.go.id/pendidikan/paud/'+prov_code+'/1'
        response_prov = requests.get(url_prov)
        html_content_prov = response_prov.content
        soup_prov = BeautifulSoup(html_content_prov, 'html.parser')
        cells_prov = soup_prov.find_all('td', {'class': 'link1'})
        for cellp in cells_prov:
            link_prov = cellp.find('a')
            if link_prov is not None:
                    href_prov = link_prov.get('href')
                    kab_code = href_prov.split('/')[-2]
                    kab_name = link_prov.text.strip()
                    print(f"\nProv: {prov_name}; Kab: {kab_name} \n")

                    url_kab = 'https://referensi.data.kemdikbud.go.id/pendidikan/paud/'+kab_code+'/2'
                    response_kab = requests.get(url_kab)
                    html_content_kab = response_kab.content
                    soup_kab = BeautifulSoup(html_content_kab, 'html.parser')
                    cells_kab = soup_kab.find_all('td', {'class': 'link1'})
                    for cellkb in cells_kab:
                        link_kab = cellkb.find('a')
                        if link_kab is not None:
                            href_kab = link_kab.get('href')
                            kec_code = href_kab.split('/')[-2]
                            kec_name = link_kab.text.strip()
                            code_province_pairs.append((prov_code, prov_name, kab_code, kab_name, kec_code, kec_name))

# Print the resulting pairs
for pair in code_province_pairs:
    print(pair)

import pandas as pd

df = pd.DataFrame(code_province_pairs, columns=['prov_code','prov_name','kab_code','kab_name','kec_code','kec_name'])
print(df.head(10))