	// -----------------------------------------------------------------
	// 2019-12, Sergiy Radyakin, Senior Economist, The World Bank
	// India T23 from Census Data 
	// Requires special data preparation as per the main program
	// -----------------------------------------------------------------
	
	program define tabover, rclass
		syntax , vars(string) condition(string) [w(real 20)]
		matrix M=J(5,3,.)
		local i=1
		foreach v in `vars' {
			quietly summarize _freq if (`condition') & (`v'==1), meanonly
			matrix M[`i',1]=r(sum)*`w'
			quietly summarize _freq if (`condition') & (`v'==1 & q03_sex==1) , meanonly
			matrix M[`i',2]=r(sum)*`w'
			quietly summarize _freq if (`condition') & (`v'==1 & q03_sex==2), meanonly
			matrix M[`i',3]=r(sum)*`w'
			local i=`i'+1
		}
		return matrix COUNTS=M
	end

	program define tabpanel, rclass
		syntax , rowvars(string) over(string) subpop(string)
		tabover, vars(`rowvars') condition(`subpop')
		matrix PANEL = r(COUNTS)
		quietly levelsof `over', local (dislevs)
		foreach lev in `dislevs' {
			tabover, vars(`rowvars') condition((`subpop') & (`over'==`lev'))
			matrix PANEL=PANEL \ r(COUNTS)
		}
		return matrix PANEL=PANEL
	end

	program define tabcolumn
		syntax , subpop(string) result(string)
		local rv "age1 age2 age3 age4 age5"
		local over "q09b_dis_type"
		local subpop "((`subpop') & (q09a_dis_status==1))"
		local cmd `"tabpanel, rowvars(`rv') over(`over')"'

		tempname COL
		`cmd' subpop(`subpop')
		matrix `COL'=r(PANEL)
		`cmd' subpop((`subpop') & (ru==1))
		matrix `COL'=`COL' \ r(PANEL)
		`cmd' subpop((`subpop') & (ru==2))
		matrix `COL'=`COL' \ r(PANEL)
		capture confirm matrix `result'
		if _rc matrix `result'=`COL'
		else matrix `result'=`result',`COL'
	end
	
	program define xlsmakeline, rclass
		syntax , [row(integer 1) column(integer 1)] line(string)
		local n=`"`:word count `line''"'
		local result ""
		forval j=1/`n' {
			excelcol `=`j'-1+`column''
			local result=`"`result' `r(column)'`row' = "`: word `j' of `line''""'
		}
		return local line = `"`result'"'
	end

	program define xlsmakecol, rclass
		syntax , [row(integer 1) column(integer 1)] line(string)
		local n=`"`:word count `line''"'
		excelcol `column'
		local j="`r(column)'"
		local result ""
		forval i=1/`n' {
			local result=`"`result' `j'`=`i'+`row'-1' = "`: word `i' of `line''""'
		}
		return local line = `"`result'"'
	end


	program define t23
		syntax, file(string) sheet(string) [condition(string)]
		tempname M
		
		if (`"`condition'"'=="") local condition "1"

		tabcolumn, result(`M') subpop((`condition'))
		tabcolumn, result(`M') subpop((q15_worker==1)&(`condition'))
		tabcolumn, result(`M') subpop((q15_worker==3)&(`condition'))
		tabcolumn, result(`M') subpop((q15_worker==2)&(`condition'))
		tabcolumn, result(`M') subpop((q15_worker==4)&(`condition'))
		
		quietly {
			putexcel set `"`file'"', sheet(`"`sheet'"') modify
			putexcel A1:R1 = "C-23 DISABLED POPULATION AMONG MAIN WORKERS, MARGINAL WORKERS, NON-WORKERS BY TYPE OF DISABILITY, AGE AND SEX", merge hcenter bold
			putexcel A2 = "Total/Rural/Urban"
			putexcel B2 = "Disability"
			putexcel C2 = "Age group"
			putexcel D2:F2 = "Total disabled population", merge hcenter
			putexcel G2:I2 = "Main worker", merge hcenter
			putexcel J2:L2 = "Marginal worker Less than 3 months", merge hcenter
			putexcel M2:O2 = "Marginal worker 3-6 months", merge hcenter
			putexcel P2:R2 = "Non-worker", merge hcenter
			forval j=4(3)16 {
			  xlsmakeline, line("Persons" "Males" "Females") row(3) column(`j')
			  putexcel `r(line)', hcenter
			}
			xlsmakeline , line(1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16) row(4) column(3)
			putexcel `r(line)', hcenter

			xlsmakecol, line(`"`="Total "*5*9' `="Rural "*5*9' `="Urban "*5*9'"') row(5) column(1)
			putexcel `r(line)'

			xlsmakecol, line(`"`=`"`="Total "*5' `="In-Seeing "*5' `="In-Hearing "*5'  `="In-Speech "*5' `="In-Movement "*5' `="Mental-Retardation "*5' `="Mental-Illness "*5' `="Any-Other "*5' `="Multiple-Disability "*5'  "'*3'"') row(5) column(2)
			putexcel `r(line)'

			xlsmakecol, line(`"`=`""Total" "0-14" "15-59" "60+" "Age not stated" "'*27'"') row(5) column(3)
			putexcel `r(line)'

			putexcel D5=matrix(`M')
		}
		matrix drop `M'
	end
