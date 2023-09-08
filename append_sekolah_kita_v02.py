#import the modules
import os
import glob
import pandas as pd

jenjang = ['paud', 'dikdas', 'dikmen', 'dikti', 'dikmas']


#append all files together
for j in jenjang:
    cwd = os.path.abspath(f'data/data_sekolah_kita_v2/{j}')
    csv_files = os.listdir(cwd)
    csv_files = [f for f in csv_files if os.path.getsize(os.path.join(cwd, f)) > 2]
    var_name = f"df_concat_{j}"
    exec(f"{var_name} = pd.concat([pd.read_csv(os.path.join(cwd, f)) for f in csv_files], ignore_index=True)")
    print(var_name)

df_concat_all = pd.concat([df_concat_paud, df_concat_dikdas, df_concat_dikmen, df_concat_dikti, df_concat_dikmas], ignore_index=True)


df_concat_all.to_csv('C:/Users/aaffa/OneDrive/Study Group Big Data/Data/sekolah_kita_v02.csv', index=False)
