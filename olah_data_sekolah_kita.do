clear all
set more off


import delimited "C:\Users\aaffa\OneDrive\Study Group Big Data\Data\sekolah_kita_v01.csv", clear

*drop observasi double -> double karena terlist dua kali di web referensi
duplicates drop

*check observasi duplikat di npsn
duplicates tag npsn, gen(dup_npsn) 

*cek kesamaan kec_name (dari tabel per kecamatan referensi) dengan kecamatankota_ln (dari detail di referensi)

split kecamatankota_ln, p(" ")
split kabkotanegara_ln, p(" ")
split propinsiluar_negeri_ln, p(" ")
replace propinsiluar_negeri_ln = kabkotanegara_ln if propinsiluar_negeri_ln1 == "INDONESIA"
replace kabkotanegara_ln = kecamatankota_ln1 if kabkotanegara_ln1 == "PROV."
replace kecamatankota_ln = desakelurahan if kecamatankota_ln1 == "KAB." | kecamatankota_ln1 == "KOTA"  // ada beberapa sekolah yang salah taruh nama kecamatan di desa dst
replace desakelurahan = ""."" if  kecamatankota_ln1 == "KAB." | kecamatankota_ln1 == "KOTA"

drop kecamatankota_ln1-propinsiluar_negeri_ln4

replace kecamatankota_ln = strlower(kecamatankota_ln)
replace kecamatankota_ln = subinstr(kecamatankota_ln,"kec. ","",1)
replace kecamatankota_ln = subinstr(kecamatankota_ln,"kec.","",1)
replace kecamatankota_ln = subinstr(kecamatankota_ln,"kecamatan ","",1)
replace kec_name = strlower(kec_name)

gen beda = kecamatankota_ln!=kec_name if dup_npsn == 1 // deteksi sekolah dengan npsn sama tapi berbada kec_name dan kecamatankota_ln
drop if beda==1

*hapus angka di depan akses_internet
replace akses_internet = subinstr(akses_internet,"1. ","",1)
replace akses_internet = subinstr(akses_internet,"1.","",1)
replace akses_internet_2 = subinstr(akses_internet_2,"2. ","",1)
replace akses_internet_2 = subinstr(akses_internet_2,"2.","",1)


*yang konsisten dengan data sekolah kita adalah akses_internet
*akses_internet "" -> kosong/tidak ada; akses_internet_sekolah_kita "" -> kosong atau PHP error

ren (status_sekolah bentuk_pendidikan kementerian_pembina akreditasi akses_internet akses_internet_2 sumber_listrik akses_internet_sekolah_kita) (status_sekolah_str bentuk_pendidikan_str kementerian_pembina_str akreditasi_str akses_internet_str akses_internet_2_str sumber_listrik_str akses_internet_sekolah_kita_str)

encode status_sekolah_str, g(status_sekolah) label(STATUS_SEKOLAH)
encode bentuk_pendidikan_str, g(bentuk_pendidikan) label(BENTUK_PENDIDIKAN)
recode bentuk_pendidikan (39 = 1) (4 = 2) (40=3) (36=4) (18=5) (13=6) (41=7) (17=8) (12=9) (14 38=10) (21=11) (5=12) (19=13) (8=14) (20=15) (1=16) (11=17) (27=18) (9=19) (28=20) (10=21) (23=22) (26=23) (6=24) (7=25) (24=26) (25=27) (29=28) (43=29) (44=30) (22=31) (30=32) (31=33) (35=34) (32=35) (34=36) (33=37) (16=38) (2=39) (15=40) (37=41) (3=42) (42=43) 
la def BENTUK_PENDIDIKAN 1 "TK" 2 "KB" 3 "TPA" 4 "SPS" 5 "RA" 6 "PAUDQ" 7 "Taman Seminari" 8 "Pratama W P" 9 "Nava Dhammasekha" 10 "PKBM" 11 "SKB" 12 "Kursus" 13 "SD" 14 "MI" 15 "SDTK" 16 "Adi W P" 17 "Mula Dhammasekha" 18 "SMP" 19 "MTs" 20 "SMPTK" 21 "Madyama W P" 22 "SMA" 23 "SMK" 24 "MA" 25 "MAK" 26 "SMAK" 27 "SMAg.k" 28 "SMTK" 29 "Utama W P" 30 "Uttama Dhammasekha" 31 "SLB" 32 "SPK KB" 33 "SPK PG" 34 "SPK TK" 35 "SPK SD" 36 "SPK SMP" 37 "SPK SMA" 38 "Pondok Pesantren" 39 "Akademik" 40 "Politeknik" 41 "Sekolah Tinggi" 42 "Institut" 43 "Universitas" 44 "" , modify
* sekolah hindu Pratama Widya Pasraman (TK), Adi Widya Pasraman (SD), Madyama Pasraman (SMP) dan Utama Widya Pasraman (SMA)
* sekolah buddha Nava Dhammasekha (TK), Mula Dhammasekha (SD), Muda Dhammasekha (SMP), Uttama Dhammasekha (SMA)

encode kementerian_pembina_str, g(kementerian_pembina) label (KEMENTERIAN_PEMBINA)
recode kementerian_pembina (3=1) (1=2) (2=3)
la def KEMENTERIAN_PEMBINA 1 "Kementerian Pendidikan, Kebudayaan, Riset, dan Teknologi" 2 "Kementerian Agama" 3 "Kementerian Kelautan dan Perikanan", modify

encode akreditasi_str, g(akreditasi) label(AKREDITASI)
recode akreditasi (4=3) (6=4) (3=6)
la def AKREDITASI 3 "C" 4 "Terakreditasi" 6 "Belum Terakreditasi", modify

encode akses_internet_str, g(akses_internet) label(AKSES_INTERNET)

gen akses_internet_dum = 1 if akses_internet!=.
replace akses_internet_dum = 0 if akses_internet == 1
replace akses_internet_dum = . if akses_internet == 2
la def AKSES_INTERNET_DUM 0 "Tidak ada internet" 1 "Ada internet"
la val akses_internet_dum AKSES_INTERNET_DUM


la var prov_name "Nama provinsi (tabel referensi)"
la var kab_name "Nama kecamatan (tabel referensi)"
la var kec_name "Nama kecamatan (tabel referensi)"
la var link_sekolah_kita "Link sekolah kita"
la var link_referensi "Link detail referensi"
la var nama "Nama sekolah"
la var npsn "NPSN"
la var alamat "Alamat sekolah"
la var desakelurahan "Nama desa (detail referensi)"
la var kecamatankota_ln "Nama kecamatan (detail referensi)"
la var kabkotanegara_ln "Nama kabupaten (detail referensi)"
la var propinsiluar_negeri_ln "Nama provinsi (detail referensi)"
la var tanggal_sk_operasional "Tanggal SK operasional"
la var luas_tanah "Luas tanah"
la var lintang "Lintang"
la var bujur "Bujur"
la var guru "Jumlah guru"
la var siswa_laki_laki "Jumlah murid laki-laki"
la var siswa_perempuan "Jumlah murid perempuan"
la var rombongan_belajar "Jumlah rombongan belajar"
la var semester_data "Data pada semester"
replace daya_listrik = subinstr(daya_listrik,",","",1)
destring daya_listrik, replace
la var daya_listrik "Daya listrik"
la var ruang_kelas "Jumlah ruang kelas"
la var laboratorium "Jumlah laboratorium"
la var perpustakaan "Jumlah perpustakaan"
la var sanitasi_siswa "Jumlah toilet"
la var guru_pns "Jumlah guru PNS"
la var guru_gtt "Jumlah guru tidak tetap"
la var guru_gty "Jumlah guru tetap yayasan"
la var guru_honor "Jumlah guru honor"
la var guru_gol_i "Jumlah guru golongan I"
la var guru_gol_ii "Jumlah guru golongan II"
la var guru_gol_iii "Jumlah guru golongan III"
la var guru_gol_iv "Jumlah guru golongan IV"
la var guru_sertifikasi "Jumlah guru dengan sertifikasi"
la var guru_belum_sertifikasi "Jumlah guru belum sertifikasi"
la var guru_kurang_dari_s1 "Jumlah guru dengan ijazah kurang dari S1"
la var guru_s1_atau_lebih "Jumlah guru dengan ijazah S1 ke atas"
la var guru_data_kosong "Jumlah guru dengan data kosong"
la var guru_kurang_dari_30_tahun "Jumlah guru di bawah 30 tahun"
la var guru_31_35_tahun "Jumlah guru 31-35 tahun"
la var guru_36_40 "Jumlah guru 36-40 tahun"
la var guru_41_45_tahun "Jumlah guru 41-45 tahun"
la var guru_46_50_tahun "Jumlah guru 46-50 tahun"
la var guru_51_55_tahun "Jumlah guru 51-55 tahun"
la var guru_lebih_dari_55_tahun "Jumlah guru di atas 55 tahun"
la var guru_laki_laki "Jumlah guru laki-laki"
la var guru_perempuan "Jumlah guru perempuan"
la var status_sekolah "Status sekolah"
la var bentuk_pendidikan "Bentuk pendidikan"
la var kementerian_pembina "Kementerian pembina"
la var akreditasi "Akreditasi"
la var akses_internet "Akses internet"
la var akses_internet_sekolah_kita "Akses internet (sekolah kita)"
la var akses_internet_dum "Dummy akses internet"

notes : Data ini diambil tanggal 04 April - 30 April 2023
notes : Ada beberapa seoklah di data sekolah kita yang tidak ada di dapodik (padahal waktu dicek ternyata ada link daponya, tetapi hasil random check hampir semua bersifat tidak pernah sync atau sync setelah tanggal pengambilan data dapodik)

save "C:\Users\aaffa\OneDrive\Study Group Big Data\Data\sekolah_kita_v01.dta", replace