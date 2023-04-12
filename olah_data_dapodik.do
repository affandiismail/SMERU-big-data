clear all
set more off

import delimited "C:\Users\aaffa\OneDrive\Documents\GitHub\SMERU-big-data\data\dapodik.csv", clear

*revisi isian
replace sertifikasi_iso = "9001" if sertifikasi_iso == "9001.0"
replace sertifikasi_iso = "" if sertifikasi_iso == "nan"

*drop variabel kosong
drop identitas_valid-menguras_tangki_septik

*rename variables
ren (desa__kelurahan kecamatan kabupaten provinsi) (nama_desa nama_kec nama_kab nama_prov)

*klarifikasi variable: ptk = jumlah guru; pegawai = jumlah tendik; pd = pd (laki-laki/perempuan)

*change string vars to categorical
ren (akreditasi kurikulum status bentuk_pendidikan status_kepemilikan kebutuhan_khusus_dilayani status_bos waku_penyelenggaraan sertifikasi_iso sumber_listrik akses_internet) (akreditasi_str kurikulum_str status_str bentuk_pendidikan_str status_kepemilikan_str kebutuhan_khusus_dilayani_str status_bos_str waku_penyelenggaraan_str sertifikasi_iso_str sumber_listrik_str akses_internet_str)

encode akreditasi_str, gen(akreditasi) label(AKREDITASI)
recode akreditasi (4=3) (6=4) (3=6)
la def AKREDITASI 3 "C" 4 "Terakreditasi" 6 "Belum Terakreditasi", modify

encode kurikulum_str, gen(kurikulum) label(KURIKULUM)
encode status_str, gen(status) label(STATUS)
encode bentuk_pendidikan_str, gen(bentuk_pendidikan) label(BENTUK_PENDIDIKAN)
recode bentuk_pendidikan (15=1) (1=2) (16=3) (14=4) (2=5) (4=6) (3=7) (8=8) (6=9) (7=10) (5=11) (9=12) (13=13) (10=14) (12=15) (11=16)
la def BENTUK_PENDIDIKAN 1 "TK" 2 "KB" 3 "TPA" 4 "SPS" 5 "PKBM" 6 "SKB" 7 "SD" 8 "SMP" 9 "SMA" 10 "SMK" 11 "SLB" 12 "SPK PG" 13 "SPK TK" 14 "SPK SD" 15 "SPK SMP" 16 "SPK SMA", modify

encode status_kepemilikan_str, gen(status_kepemilikan) label(STATUS_KEPEMILIKAN)
recode status_kepemilikan (1=4) (3=1) (4=3)
la def STATUS_KEPEMILIKAN 1 "Pemerintah Pusat" 2 "Pemerintah Daerah" 3 "Yayasan" 4 "Lainnya", modify

encode kebutuhan_khusus_dilayani_str, gen(kebutuhan_khusus_dilayani) label(KEBUTUHAN_KHUSUS_DILAYANI)
encode status_bos_str, gen(status_bos) label(STATUS_BOS)
encode waku_penyelenggaraan_str, gen(waktu_penyelenggaraan) label(WAKTU_PENYELENGGARAAN)
recode waktu_penyelenggaraan (4=1) (7=2) (8=3) (3=4) (1=5) (5=6) (6=7) (2=8)
la def WAKTU_PENYELENGGARAAN 1 "Pagi" 2 "Siang" 3 "Sore" 4 "Malam" 5 "Kombinasi" 6 "Sehari penuh (5 h/m)" 7 "Sehari penuh (6 h/m)" 8 "Lainnya" , modify

encode sertifikasi_iso_str, gen(sertifikasi_iso) label(SERTIFIKASI_ISO)
encode sumber_listrik_str, gen(sumber_listrik) label(SUMBER_LISTRIK)
recode sumber_listrik (1=3) (2=5) (3=1) (4=2) (5=4)
la def SUMBER_LISTRIK 1 "PLN" 2 "PLN & Diesel" 3 "Diesel" 4 "Tenaga Surya" 5 "Lainnya", modify

encode akses_internet_str, gen(akses_internet) label(AKSES_INTERNET)

gen akses_internet_dum = 1 if akses_internet!=.
replace akses_internet_dum = 0 if akses_internet == 27
la def AKSES_INTERNET_DUM 0 "Tidak ada internet" 1 "Ada internet"
la val akses_internet_dum AKSES_INTERNET_DUM

*date variables
gen double sinkron_terakhir = clock(last_sync,"DMY hms")
format sinkron_terakhir %tc

gen double sinkron_terakhir_day = dofc(sinkron_terakhir)
format sinkron_terakhir_day %td

gen year = 2022
gen semester = 2

*labeling the variables
la var nama "Nama satuan pendidikan"
la var sinkron_terakhir "Waktu sinkronisasi terakhir"
la var sinkron_terakhir_day "Waktu sinkronisasi terakhir (hari)"
la var akreditasi "Akreditasi satuan pendidikan"
la var kurikulum "Kurikulum yang digunakan"
la var link_dapo "Tautan dapodik"
la var link_sekolah_kita "Tautan sekolah kita"
la var npsn "Nomor pokok sekolah nasional"
la var status "Status satuan pendidikan"
la var bentuk_pendidikan "Bentuk pendidikan"
la var status_kepemilikan "Status kepemilikan satuan pendidikan"
la var sk_pendirian_sekolah "Nomor SK pendirian satuan pendidikan"
la var tanggal_sk_pendirian "Tanggal SK pendirian satuan pendidikan"
la var sk_izin_operasional "Nomor SK izin operasional satuan pendidikan"
la var tanggal_sk_izin_operasional "Tanggal SK izin operasional satuan pendidikan"
la var kebutuhan_khusus_dilayani "Jenis kebutuhan khusus yang dilayani"
la var nama_bank "Nama bank"
la var cabang_kcpunit "Nama cabang KCP/unit"
la var rekening_atas_nama "Nama pemilik rekening"
la var status_bos "Status kesediaan menerima BOS"
la var waktu_penyelenggaraan "Waktu penyelenggaraan"
la var sertifikasi_iso "Sertifikasi ISO"
la var sumber_listrik "Sumber listrik"
la var daya_listrik "Daya listrik"
la var akses_internet "Jenis akses internet"
la var akses_internet_dum "Mengakses internet"
la var alamat "Alamat"
la var rt__rw "RT/RW"
la var dusun "Nama dusun"
la var nama_desa "Nama desa/kelurahan dapodik"
la var nama_kec "Nama kecamatan dapodik"
la var nama_kab "Nama kabupaten/kota dapodik"
la var nama_prov "Nama provinsi dapodik"
la var kode_pos "Kode pos"
la var lintang "Garis lintang"
la var bujur "Garis bujur"
la var ptk "Jumlah guru"
la var pegawai "Jumlah tenaga pendidik"
la var pd "Jumlah peserta didik"
la var rombel "Jumlah rombongan belajar"
la var ptk_laki "Jumlah guru laki-laki"
la var ptk_perempuan "Jumlah guru perempuan"
la var pegawai_laki "Jumlah tenaga pendidik laki-laki"
la var pegawai_perempuan "Jumlah tenaga pendidik perempuan"
la var pd_laki "Jumlah peserta didik laki-laki"
la var pd_perempuan "Jumlah peserta didik perempuan"
la var before_ruang_kelas "Jumlah ruang kelas semester 1"
la var after_ruang_kelas "Jumlah ruang kelas semester 2"
la var before_ruang_perpus "Jumlah ruang perpus semester 1"
la var after_ruang_perpus "Jumlah ruang perpus semester 2"
la var before_ruang_lab "Jumlah ruang lab semester 1"
la var after_ruang_lab "Jumlah ruang lab semester 2"
la var before_ruang_praktik "Jumlah ruang praktik semester 1"
la var after_ruang_praktik "Jumlah ruang praktik semester 2"
la var before_ruang_pimpinan "Jumlah ruang pimpinan semester 1"
la var after_ruang_pimpinan "Jumlah ruang pimpinan semester 2"
la var before_ruang_guru "Jumlah ruang guru semester 1"
la var after_ruang_guru "Jumlah ruang guru semester 2"
la var before_ruang_ibadah "Jumlah ruang ibadah semester 1"
la var after_ruang_ibadah "Jumlah ruang ibadah semester 2"
la var before_ruang_uks "Jumlah ruang uks semester 1"
la var after_ruang_uks "Jumlah ruang uks semester 2"
la var before_toilet "Jumlah toilet semester 1"
la var after_toilet "Jumlah toilet semester 2"
la var before_gudang "Jumlah gudang semester 1"
la var after_gudang "Jumlah gudang semester 2"
la var before_ruang_sirkulasi "Jumlah ruang sirkulasi semester 1"
la var after_ruang_sirkulasi "Jumlah ruang sirkulasi semester 2"
la var before_tempat_bermain_olahraga "Jumlah tempat bermain olahraga semester 1"
la var after_tempat_bermain_olahraga "Jumlah tempat bermain olahraga semester 2"
la var before_ruang_tu "Jumlah ruang tu semester 1"
la var after_ruang_tu "Jumlah ruang tu semester 2"
la var before_ruang_konseling "Jumlah ruang konseling semester 1"
la var after_ruang_konseling "Jumlah ruang konseling semester 2"
la var before_ruang_osis "Jumlah ruang osis semester 1"
la var after_ruang_osis "Jumlah ruang osis semester 2"
la var before_bangunan "Jumlah bangunan semester 1"
la var after_bangunan "Jumlah bangunan semester 2"
la var year "Tahun"
la var semester "Semester"

notes : Data ini diambil tanggal 27 Maret - 03 April 2023
notes : JANGAN PAKAI VARIABEL TANPA LABEL KARENA TIDAK MUNCUL DI TAMPILAN WEB DAPODIK

save "C:\Users\aaffa\OneDrive\Study Group Big Data\Data\dapodik_v01.dta", replace






