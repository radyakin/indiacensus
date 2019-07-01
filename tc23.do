	// -----------------------------------------------------------------
	// 2019-07, Sergiy Radyakin, Senior Economist, The World Bank
	// T23 from Census Data : cenmicro_HR.dta 47,952,589
	// 1261223:31(19014):2862368569:3998512538
	// -----------------------------------------------------------------
	
	local report `"C:\temp\c23-delhi-d.xlsx"'
	local datafile `"c:\Temp\ind\cenmicro_HR.dta"'
	
	clear all

	use `"`datafile'"', clear
	generate byte age1=1
	generate byte age2=inrange(Q04_AGE,00,14)
	generate byte age3=inrange(Q04_AGE,15,59)
	generate byte age4=inrange(Q04_AGE,60,998)
	generate byte age5=Q04_AGE==999
	contract age1-age5 DISTRICT RU Q15_WORKER Q09A_DIS_STATUS Q09B_DIS_TYPE Q03_SEX
	tempfile tmp
	save `"`tmp'"'
	capture erase `"`report'"'
	display ""

	t23, file(`"`report'"') sheet(`"T23 HARYANA"')

	levelsof DISTRICT, local(levs)
	foreach distr in `levs' {
		// use `"`tmp'"', clear
		display as text `"`:label b `distr''"'
		// quietly keep if (DISTRICT==`distr')
		t23, file(`"`report'"') sheet(`"T23 `:label b `distr''"') condition("DISTRICT==`distr'")
	}

	shell "`report'"

// === === === END OF FILE === === ===
