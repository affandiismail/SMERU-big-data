clear all
set more off
cap log close

log using "C:\Users\aaffa\OneDrive\Study Group Big Data\Data\results\simpletab", replace text
use "C:\Users\aaffa\OneDrive\Study Group Big Data\Data\dapodik_v01.dta", clear


fre akreditasi status bentuk_pendidikan status_kepemilikan status_bos sertifikasi_iso sumber_listrik akses_internet_dum ptk pegawai pd

log close