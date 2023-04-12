#import the modules
import os
import pandas as pd
#read the path
cwd = os.path.abspath('data')
#list all the files from the directory
file_list = os.listdir(cwd)
file_list

df_append = pd.DataFrame()
#append all files together
for file in file_list:
            df_temp = pd.read_csv(f'data\{file}')
            df_append = df_append.append(df_temp, ignore_index=True)
df_append

df_concat = pd.concat([pd.read_csv(f) for f in f'data\{file}'], ignore_index=True)
df_concat

df_append['npsn'] = df_append['npsn'].astype(str)
df_append['sk_pendirian_sekolah'] = df_append['sk_pendirian_sekolah'].astype(str)
df_append['sertifikasi_iso'] = df_append['sertifikasi_iso'].astype(str)
df_append['dusun'] = df_append['dusun'].astype(str)


df_append.to_parquet('data\dapodik.parquet', compression='gzip', engine='pyarrow', index=False)
df_append.to_csv('C:\Users\aaffa\OneDrive\Study Group Big Data\Data\dapodik.csv', index=False)
