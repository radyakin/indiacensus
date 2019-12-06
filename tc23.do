	// MODIFIED
	// -----------------------------------------------------------------
	// 2019-12, Sergiy Radyakin, Senior Economist, The World Bank
	// T23 from Census Data : cenmicro_HR.dta 42,906,072
	// 1261223:30(85132):1955914902:992689886
	// -----------------------------------------------------------------
	// CREATED
	// -----------------------------------------------------------------
	// 2019-07, Sergiy Radyakin, Senior Economist, The World Bank
	// T23 from Census Data : cenmicro_HR.dta 47,952,589
	// 1261223:31(19014):2862368569:3998512538
	// -----------------------------------------------------------------
	
	local report `"C:\temp\india\c23_HR.xlsx"'
	local datafile `"c:\Temp\india\cenmicro_HR.dta"'
	
	clear all

	use `"`datafile'"', clear
	generate byte age1=1
	generate byte age2=inrange(q04_age,00,14)
	generate byte age3=inrange(q04_age,15,59)
	generate byte age4=inrange(q04_age,60,998)
	generate byte age5=q04_age==999
	contract age1-age5 district ru q15_worker q09a_dis_status q09b_dis_type q03_sex
	tempfile tmp
	save `"`tmp'"'
	capture erase `"`report'"'
	display ""

	t23, file(`"`report'"') sheet(`"T23 HARYANA"')

	levelsof district, local(levs)
	foreach distr in `levs' {
		display as text `"`distr' - `:label `: value label district' `distr''"'
		t23, file(`"`report'"') sheet(`"T23 `:label `: value label district' `distr''"') condition("district==`distr'")
	}

	shell "`report'"

// === === === END OF FILE === === ===
