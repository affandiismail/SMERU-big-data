/*------------------------------------------------------------------------------
THE SMERU RESEARCH INSTITUTE
--------------------------------------------------------------------------------
Author          : Affandi Ismail et al.
Project         : Pemetaan kondisi populasi sekolah di seluruh Indonesia melalui web scraping
Email           : aismail@smeru.or.id
-------------------------------------------------------------------------------- */
*****************************************************************************
* Pembuatan tabulasi untuk dimasukkan ke excel
*****************************************************************************
clear all
set more off
cap log close

**********************************************************************************
//Mengatur direktori komputer/laptop tiap peneliti 

*user 1 - Fandi
if c(username) == "aaffa" { // change username
	qui cd "C:\Users\aaffa\OneDrive\Study Group Big Data" // change your directory
	}

global tables 4_Research note\Dapodik & Sekolah kita\graphs_tables
global data data


**********************************************************************************
//Load data dapodik dan buat frame dapodik
use "$data\dapodik_v01.dta", replace
frame rename default dapo
drop if nama_prov=="Luar Negeri" // drop sekolah LN
replace nama_prov = subinstr(nama_prov,"Prov. ","",1) // hilangkan awalan Prov. 

recode bentuk_pendidikan (1/4 12 13 = 1 "TK/sederajat") (7 14 = 2 "SD") (8 15 = 3 "SMP") (9 16 = 4 "SMA") (10 = 5 "SMK") (5 6 = 6 "PKBM/SKB") (11 = 7 "SLB"), gen(jenjang)
la var jenjang "Jenjang pendidikan"


**********************************************************************************
//Load data sekolah kita dan buat frame sekolah kita (sekolah kita V02 is available!)
frame create sekolahkita
frame sekolahkita {
	use "$data\sekolah_kita_v02.dta", replace
	recode bentuk_pendidikan (1/9 32/34 = 1 "PAUD/sederajat") (13/17 35 = 2 "SD/sederajat") (18/21 36 = 3 "SMP/sederajat") (19/22 24 26/30 37 = 4 "SMA/sederajat") (23 25 = 5 "SMK") (10 11 12 = 6 "PKBM/SKB/Kursus") (31 = 7 "SLB") (38 = 8 "Pondok Pesantren") (39/43 = 9 "Universitas/sederajat"), gen(jenjang)
	la var jenjang "Jenjang pendidikan"
	la var prov_name "Nama provinsi"
	drop if prov_name == "Luar Negeri"
	}
	


**********************************************************************************
//Rasio siswa-rombel dan rasio siswa-guru 
* anggap missing siswa, guru, dan rombel yang angkanya 0
foreach var in pd ptk rombel{
	replace `var' = . if `var' == 0
}

gen siswa_per_rombel = pd/rombel
la var siswa_per_rombel "Siswa per rombel"
gen siswa_per_guru = pd/ptk
la var siswa_per_guru "Siswa per guru"

gen ideal_rombel =.
replace ideal_rombel = 28 if jenjang == 2
replace ideal_rombel = 32 if jenjang == 3
replace ideal_rombel = 36 if jenjang == 4
replace ideal_rombel = 36 if jenjang == 5

gen non_ideal_rombel = siswa_per_rombel>ideal_rombel if siswa_per_rombel!=.

gen ideal_guru =.
replace ideal_guru = 20 if jenjang == 2
replace ideal_guru = 20 if jenjang == 3
replace ideal_guru = 20 if jenjang == 4
replace ideal_guru = 15 if jenjang == 5
	
gen non_ideal_guru = siswa_per_guru>ideal_guru if siswa_per_rombel!=.

*siswa-rombel/guru by jenjang
frame put siswa_per_rombel siswa_per_guru non_ideal_rombel non_ideal_guru ideal_rombel ideal_guru jenjang, into(siswarombeljenjang)

frame siswarombeljenjang {
	keep if inrange(jenjang,2,5) // keep SD-SMK

	collapse siswa_per_rombel siswa_per_guru non_ideal_rombel non_ideal_guru ideal_rombel ideal_guru, by(jenjang)
	la var siswa_per_rombel "Rasio siswa per rombel"
	la var siswa_per_guru "Rasio siswa per guru"
	la var non_ideal_rombel "Proporsi sekolah yang melebihi rasio siswa per rombel maksimum"
	la var non_ideal_guru "Proporsi sekolah yang melebihi rasio siswa per guru maksimum"
	la var ideal_rombel "Rasio siswa per rombel maksimum"
	la var ideal_guru "Rasio siswa per guru maksimum"
	
	*export excel using "$tables/tables.xlsx", sheet("siswa_per_rombelguru", modify) firstrow(varlabels) keepcellfmt 
}

/*
frame put siswa_per_rombel siswa_per_guru nama_prov nama_kab, into(siswarombelkab)
frame siswarombelkab {
	sum siswa_per_rombel
	local rombel_total = r(mean)
	sum siswa_per_guru
	local guru_total = r(mean)
	
	collapse siswa_per_rombel siswa_per_guru, by(nama_prov nama_kab)
	
	local n = _N+1
	set obs `n' // add one observation for total
	local last = _N
	replace nama_prov = "Indonesia" in `last'
	replace siswa_per_rombel = `rombel_total' in `last'
	replace siswa_per_guru = `guru_total' in `last'
}
*/

**********************************************************************************
*Rasio guru honor/guru lain (pns + gtt + gty)
frame sekolahkita {
	replace guru = . if guru == 0
	gen sekolah_honor = guru_honor>0 if guru!=.
	la var sekolah_honor "Rasio sekolah dengan guru honor"
	tab2xl jenjang using "$tables/tables.xlsx" if inrange(jenjang,2,5) & status_sekolah==1, summarize(sekolah_honor) sheet("guru_honor_SK", replace) row(1) col(1)
	tab2xl prov_name using "$tables/tables.xlsx" if inrange(jenjang,2,5) & status_sekolah==1, summarize(sekolah_honor) sheet("guru_honor_SK") row(1) col(6)
	
**********************************************************************************
	*Rasio/total guru dengan ijazah s1 
	frame put guru_kurang_dari_s1 guru_s1_atau_lebih jenjang prov_name, into(gurus1)
	frame gurus1{
		keep if inrange(jenjang,1,5) // keep TK-SMK
		collapse (sum) guru_kurang_dari_s1 guru_s1_atau_lebih, by(jenjang)

		local n = _N+1
		set obs `n' // add one observation for total
		local last = _N
		replace jenjang = 99 in `last' // masukkan angka karena jenjang adalah integer
		la def jenjang 99 "Total" , modify
		sum guru_kurang_dari_s1,d
		local a = r(sum)
		sum guru_s1_atau_lebih,d
		local b = r(sum)
		replace guru_kurang_dari_s1 = `a' in `last'
		replace guru_s1_atau_lebih = `b' in `last'
		gen rasio_s1_jenjang = guru_kurang_dari_s1/(guru_kurang_dari_s1+guru_s1_atau_lebih)
		la var rasio_s1_jenjang "Rasio guru dengan ijazah kurang dari S1"
		drop guru_kurang_dari_s1 guru_s1_atau_lebih
		
		*export excel using "$tables/tables.xlsx", sheet("ijazah_SK", replace) cell(A1) firstrow(varlabels) keepcellfmt 
	}
	frame drop gurus1
	frame put guru_kurang_dari_s1 guru_s1_atau_lebih jenjang prov_name, into(gurus1)
	frame gurus1{
		keep if inrange(jenjang,1,5) // keep TK-SMK
		collapse (sum) guru_kurang_dari_s1 guru_s1_atau_lebih, by(prov_name)

		local n = _N+1
		set obs `n' // add one observation for total
		local last = _N
		replace prov_name = "Indonesia" in `last' // masukkan string karena prov_name adalah string
		sum guru_kurang_dari_s1,d
		local a = r(sum)
		sum guru_s1_atau_lebih,d
		local b = r(sum)
		replace guru_kurang_dari_s1 = `a' in `last'
		replace guru_s1_atau_lebih = `b' in `last'
		gen rasio_s1_jenjang = guru_kurang_dari_s1/(guru_kurang_dari_s1+guru_s1_atau_lebih)
		la var rasio_s1_jenjang "Rasio guru dengan ijazah kurang dari S1"
		drop guru_kurang_dari_s1 guru_s1_atau_lebih
		
		*export excel using "$tables/tables.xlsx", sheet("ijazah_SK", modify) cell(D1) firstrow(varlabels) keepcellfmt 
	}
}

**********************************************************************************
*Ruang kelas baik/rusak
frame sekolahkita {
	replace ruang_kelas=. if ruang_kelas==0
	frame put ruang_kelas_baik ruang_kelas_rusak_ringan ruang_kelas_rusak_sedang ruang_kelas_rusak_berat jenjang prov_name, into(ruangkelas)
		frame ruangkelas{
		keep if inrange(jenjang,1,5) // keep TK-SMK
		collapse (sum) ruang_kelas_baik ruang_kelas_rusak_ringan ruang_kelas_rusak_sedang ruang_kelas_rusak_berat, by(jenjang)

		local n = _N+1
		set obs `n' // add one observation for total
		local last = _N
		replace jenjang = 99 in `last' // masukkan angka karena jenjang adalah integer
		la def jenjang 99 "Total" , modify
		sum ruang_kelas_baik,d
		local a = r(sum)
		sum ruang_kelas_rusak_ringan,d
		local b = r(sum)
		sum ruang_kelas_rusak_sedang,d
		local c = r(sum)
		sum ruang_kelas_rusak_berat,d
		local d = r(sum)
		replace ruang_kelas_baik = `a' in `last'
		replace ruang_kelas_rusak_ringan = `b' in `last'
		replace ruang_kelas_rusak_sedang = `c' in `last'
		replace ruang_kelas_rusak_berat = `d' in `last'
		gen rasio_kelas_baik = ruang_kelas_baik/(ruang_kelas_baik+ruang_kelas_rusak_ringan+ruang_kelas_rusak_sedang+ruang_kelas_rusak_berat)
		foreach var in ringan sedang berat{
			gen rasio_kelas_`var' = ruang_kelas_rusak_`var'/(ruang_kelas_baik+ruang_kelas_rusak_ringan+ruang_kelas_rusak_sedang+ruang_kelas_rusak_berat)
		}
		la var rasio_kelas_baik "Rasio ruang kelas dalam keadaan baik"
		la var rasio_kelas_ringan "Rasio ruang kelas dalam keadaan rusak ringan"
		la var rasio_kelas_sedang "Rasio ruang kelas dalam keadaan rusak sedang"
		la var rasio_kelas_berat "Rasio ruang kelas dalam keadaan rusak berat"
		drop ruang_kelas_baik ruang_kelas_rusak_ringan ruang_kelas_rusak_sedang ruang_kelas_rusak_berat
		
		*export excel using "$tables/tables.xlsx", sheet("ruang_kelas_SK", replace) cell(A1) firstrow(varlabels) keepcellfmt 
	}
	frame drop ruangkelas
	frame put ruang_kelas_baik ruang_kelas_rusak_ringan ruang_kelas_rusak_sedang ruang_kelas_rusak_berat jenjang prov_name, into(ruangkelas)
		frame ruangkelas{
		keep if inrange(jenjang,1,5) // keep TK-SMK
		collapse (sum) ruang_kelas_baik ruang_kelas_rusak_ringan ruang_kelas_rusak_sedang ruang_kelas_rusak_berat, by(prov_name)

		local n = _N+1
		set obs `n' // add one observation for total
		local last = _N
		replace prov_name = "Indonesia" in `last'
		sum ruang_kelas_baik,d
		local a = r(sum)
		sum ruang_kelas_rusak_ringan,d
		local b = r(sum)
		sum ruang_kelas_rusak_sedang,d
		local c = r(sum)
		sum ruang_kelas_rusak_berat,d
		local d = r(sum)
		replace ruang_kelas_baik = `a' in `last'
		replace ruang_kelas_rusak_ringan = `b' in `last'
		replace ruang_kelas_rusak_sedang = `c' in `last'
		replace ruang_kelas_rusak_berat = `d' in `last'
		gen rasio_kelas_baik = ruang_kelas_baik/(ruang_kelas_baik+ruang_kelas_rusak_ringan+ruang_kelas_rusak_sedang+ruang_kelas_rusak_berat)
		foreach var in ringan sedang berat{
			gen rasio_kelas_`var' = ruang_kelas_rusak_`var'/(ruang_kelas_baik+ruang_kelas_rusak_ringan+ruang_kelas_rusak_sedang+ruang_kelas_rusak_berat)
		}
		la var rasio_kelas_baik "Rasio ruang kelas dalam keadaan baik"
		la var rasio_kelas_ringan "Rasio ruang kelas dalam keadaan rusak ringan"
		la var rasio_kelas_sedang "Rasio ruang kelas dalam keadaan rusak sedang"
		la var rasio_kelas_berat "Rasio ruang kelas dalam keadaan rusak berat"
		drop ruang_kelas_baik ruang_kelas_rusak_ringan ruang_kelas_rusak_sedang ruang_kelas_rusak_berat
		
		*export excel using "$tables/tables.xlsx", sheet("ruang_kelas_SK", modify) cell(I1) firstrow(varlabels) keepcellfmt 
	}
}

**********************************************************************************
*sekolah tanpa listrik
gen akses_listrik_dum = (sumber_listrik == 6) if sumber_listrik!=.
la var akses_listrik_dum "Rasio sekolah tanpa akses listrik"

/*
tab2xl jenjang using "$tables/tables.xlsx" if inrange(jenjang,1,5), summarize(akses_listrik_dum) sheet("akses_listrik_dapo", replace) row(1) col(1)
tab2xl nama_prov using "$tables/tables.xlsx" if inrange(jenjang,1,5), summarize(akses_listrik_dum) sheet("akses_listrik_dapo") row(1) col(6)
*/

**********************************************************************************
*sekolah tanpa toilet dan kurang dari regulasi (minimal 3 toilet)
egen sum_sarpras = rowtotal(after*)
gen missing_sarpras = sum_sarpras == 0

gen sekolah_toilet = after_toilet==0 if missing_sarpras==0
gen sekolah_toilet_regulate = after_toilet<3 if missing_sarpras==0
la var sekolah_toilet "Rasio sekolah tanpa toilet"
la var sekolah_toilet_regulate "Rasio sekolah dengan toilet tidak sesuai peraturan"

/*
tab2xl jenjang using "$tables/tables.xlsx" if inrange(jenjang,1,5), summarize(sekolah_toilet) sheet("toilet_dapo", replace) row(1) col(1)
tab2xl nama_prov using "$tables/tables.xlsx" if inrange(jenjang,1,5), summarize(sekolah_toilet) sheet("toilet_dapo") row(1) col(6)
tab2xl jenjang using "$tables/tables.xlsx" if inrange(jenjang,1,5), summarize(sekolah_toilet_regulate) sheet("toilet_dapo") row(1) col(11)
tab2xl nama_prov using "$tables/tables.xlsx" if inrange(jenjang,1,5), summarize(sekolah_toilet_regulate) sheet("toilet_dapo") row(1) col(16)
*/

**********************************************************************************
*sekolah tanpa perpus
gen sekolah_perpus = after_ruang_perpus==0 if missing_sarpras==0
la var sekolah_perpus "Rasio sekolah tanpa perpustakaan"

/*
tab2xl jenjang using "$tables/tables.xlsx" if inrange(jenjang,2,5), summarize(sekolah_perpus) sheet("perpus_dapo", replace) row(1) col(1)
tab2xl nama_prov using "$tables/tables.xlsx" if inrange(jenjang,2,5), summarize(sekolah_perpus) sheet("perpus_dapo") row(1) col(6)
*/

**********************************************************************************
*sekolah tanpa internet
recode akses_internet_dum (0 = 1) (1 = 0), gen(sekolah_internet)
la var sekolah_internet "Rasio sekolah tanpa internet"

/*
tab2xl jenjang using "$tables/tables.xlsx" if inrange(jenjang,1,5), summarize(sekolah_internet) sheet("internet_dapo", replace) row(1) col(1)
tab2xl nama_prov using "$tables/tables.xlsx" if inrange(jenjang,1,5), summarize(sekolah_internet) sheet("internet_dapo") row(1) col(6)
*/

**********************************************************************************
*keberadaan universitas by kabkota
frame sekolahkita {
	frame put jenjang prov_name kab_name,into(univ)
	frame univ {
		gen univ = (jenjang == 9) // tag observasi universitas
		collapse (sum) univ, by(prov_name kab_name)
	}
}

frame create kabkotcode
frame kabkotcode{
	import excel "$data/sekolah_kita_kabkota.xlsx", sheet("in") firstrow
}

frame univ {
	frlink m:1 kab_name, frame(kabkotcode)
	frget IDKAB, from(kabkotcode)
	sort IDKAB
}

frame create map 
frame map {
	use "$data/peta_kab_2016/INDO_KAB_2016.dta", replace
	destring IDKAB, replace
	frlink 1:1 IDKAB, frame(univ) gen(u)
	frget univ, from(u)
	replace univ = .  if univ == 0
	/*
	spmap univ using "data/peta_kab_2016/INDO_KAB_2016_shp.dta", id(_ID) fc(yellow*0.3 sandb orange orange_red maroon) ///
	ndo(gray) nds(vthin) ndl(0) clm(custom) ///
	clb(1 2 5 10 20 231) ocolor(none ..) legend(pos(8)) lego(hilo) legs(2) ///
	plotregion(color(white))
	*/
}