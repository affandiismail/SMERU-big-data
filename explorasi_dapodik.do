clear all
set more off
cap log close

log using "C:\Users\aaffa\OneDrive\Study Group Big Data\Data\results\simpletab", replace text
use "C:\Users\aaffa\OneDrive\Study Group Big Data\Data\dapodik_v01.dta", clear


fre akreditasi status bentuk_pendidikan status_kepemilikan status_bos sertifikasi_iso sumber_listrik akses_internet_dum nama_prov

egen aftersum = rowtotal(after*), missing
egen beforesum = rowtotal(before*), missing
egen psum = rowtotal(ptk pegawai pd), missing

fre after* if aftersum!=0
fre after* if aftersum==0

fre before* if beforesum!=0
fre before* if beforesum==0

fre ptk pegawai pd if psum!=0
fre ptk pegawai pd if psum==0

log close