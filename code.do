clear
*****打开数据*****
cd D:\数字经济\CGSS
use cgss2017.dta, clear
*****数据预处理*****
keep id s41 a8b a53aa a285 a3012 a29 a18 a31 a2 a4 a69 a10 a7a a15 a45
sum
rename s41 pro
drop if a8b == 9999999
drop if a8b == 9999998
drop if a8b == 9999997
drop if a8b == 9999996
drop if a8b == 0
rename a8b income
drop if a53aa == .
drop if a53aa == 0
rename a53aa hours
drop if a285 == 99
drop if a285 == 98
rename a285 internet
drop if a29 == .
drop if a29 == 9
drop if a29 == 8
drop if a29 == 7
recode a29 (5 = 1 "互联网")(1 = 0 "其他")(2= 0 "其他")(3 = 0 "其他")(4 = 0 "其他")(6 = 0 "其他"), gen (inform)
drop if a3012 == 99
drop if a3012 == 98
recode a3012 (1 = 5 "每天")(2 = 4 "一周数次")(3 = 3 "一月数次")(4 = 2 "一月数次或更少")(5 = 1 "从不"), gen (freq)
drop if a18 == 6
drop if a18 == 7
rename a18 register
gen age = 2018 - a31
recode a2 (1 = 1 "男")(2 = 0 "女"), gen (sex)
recode a4 (2 = 0 "其他")(3 = 0 "其他")(4 = 0 "其他")(5 = 0 "其他")(6 = 0 "其他")(7 = 0 "其他")(8 = 0 "其他"), gen (nation)
recode a69 (1 = 0 "未婚")(2 = 0 "未婚")(3 = 1 "已婚")(4 = 1 "已婚")(5 = 1 "已婚")(6 = 0 "未婚")(7 = 0 "未婚"), gen (married)
drop if a10 == 98
drop if a10 == 99
recode a10 (1 = 0 "其他")(2 = 0 "其他")(3 = 0 "其他")(4 = 1 "党员"), gen (party)
gen edu = 0
drop if a7a == 14
replace edu = 3 if a7a == 02
replace edu = 6 if a7a == 03
replace edu = 9 if a7a == 04
replace edu = 12 if a7a == 05
replace edu = 12 if a7a == 06
replace edu = 12 if a7a == 07
replace edu = 12 if a7a == 08
replace edu = 15 if a7a == 09
replace edu = 15 if a7a == 10
replace edu = 16 if a7a == 11
replace edu = 16 if a7a == 12
replace edu = 19 if a7a == 13
rename a15 health
drop if a45 == 99
drop if a45 == 98
recode a45 (1 = 1 "是")(2 = 0 "不是")(3 = 0 "不是"), gen (union)
drop a29 a31 a3012 a2 a4 a69 a10 a7a a45
gen hincome = income/(52*hours)
gen lnincome = log(hincome)
gen agegroup = 0
replace agegroup = 1 if age <= 40
replace agegroup = 2 if age >40 & age <=60
replace agegroup = 3 if age > 60
gen above = 0
replace above = 1 if edu >=12
cd D:\数字经济
save data.dta, replace
*****描述性统计*****
outreg2 using statistic1.doc, replace sum(log) keep(hincome lnincome hours internet freq age sex married edu) eqkeep(N mean sd) append
bysort sex: outreg2 using statistic1.doc, sum(log) keep(hincome lnincome hours internet freq age sex married edu) eqkeep(N mean sd) append
bysort agegroup: outreg2 using statistic2.doc, replace sum(log) keep(hincome lnincome hours internet freq age sex married edu) eqkeep(N mean sd)
bysort above: outreg2 using statistic3.doc, replace sum(log) keep(hincome lnincome hours internet freq age sex married edu) eqkeep(N mean sd)
*****总体性别工资差异*****
reg lnincome internet age married edu sex hour
outreg2 using result1.doc, replace append bdec(3) ctitle(1) 
reg lnincome internet age married edu hour if sex == 1
outreg2 using result1.doc, append bdec(3) ctitle(2) 
reg lnincome internet age married edu hour if sex == 0
outreg2 using result1.doc, append bdec(3) ctitle(3) 
*****Oaxaca-Blinder分解法*****
oaxaca lnincome internet age married edu hour, by(sex) weight(1)
outreg2 using result2.xls, replace append bdec(4)
*****进一步讨论（按年龄段分组）*****
reg lnincome internet age married edu hour if sex == 1 & agegroup == 1
outreg2 using result3.doc, replace append bdec(3) ctitle(1) 
reg lnincome internet age married edu hour if sex == 0 & agegroup == 1
outreg2 using result3.doc, append bdec(3) ctitle(2) 
reg lnincome internet age married edu hour if sex == 1 & agegroup == 2
outreg2 using result3.doc, append bdec(3) ctitle(3) 
reg lnincome internet age married edu hour if sex == 0 & agegroup == 2
outreg2 using result3.doc, append bdec(3) ctitle(4) 
reg lnincome internet age married edu hour if sex == 1 & agegroup == 3
outreg2 using result3.doc, append bdec(3) ctitle(5) 
reg lnincome internet age married edu hour if sex == 0 & agegroup == 3
outreg2 using result3.doc, append bdec(3) ctitle(6) 
*****进一步讨论（按学历分组）*****
reg lnincome internet age married edu hour if sex == 1 & above == 1
outreg2 using result4.doc, replace append bdec(3) ctitle(1) 
reg lnincome internet age married edu hour if sex == 0 & above == 1
outreg2 using result4.doc, append bdec(3) ctitle(2) 
reg lnincome internet age married edu hour if sex == 1 & above == 0
outreg2 using result4.doc, append bdec(3) ctitle(3) 
reg lnincome internet age married edu hour if sex == 0 & above == 0
outreg2 using result4.doc, append bdec(3) ctitle(4) 
*****稳健性检验*****
reg lnincome freq age married edu sex hour
outreg2 using stationary1.doc, replace append bdec(3) ctitle(1) 
reg lnincome freq age married edu hour if sex == 0
outreg2 using stationary1.doc, append bdec(3) ctitle(2) 
reg lnincome freq age married edu hour if sex == 1
outreg2 using stationary1.doc, append bdec(3) ctitle(3)
reg lnincome internet age married edu hour if pro != 1&4&7&28
outreg2 using stationary2.doc, replace append bdec(3) ctitle(1)
winsor2 lnincome, replace cut (1, 99) trim
reg lnincome internet age married edu hour
outreg2 using stationary3.doc, replace append bdec(3) ctitle(1)
