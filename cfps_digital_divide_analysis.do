use "C:\Users\DELL\Desktop\2022\cfps2022person_202410.dta"

//制作控制变量
//年龄
clonevar age_copy = age
label values age_copy
summarize age_copy
tab age_copy
//性别
generate female = (gender == 1)
tab female
//受教育程度
clonevar cfps2022edu_copy = cfps2022edu
label values cfps2022edu_copy
replace cfps2022edu_copy = . if cfps2022edu_copy == -9
drop if missing(cfps2022edu_copy)
//年收入
clonevar income = qg12
label values income
tab income
replace income = . if income == -9
replace income = . if income == -8
replace income = . if income == -2
replace income = . if income == -1
drop if missing(income)
//城乡
clonevar urban22_copy = urban22
label values urban22_copy
replace urban22_copy = . if urban22_copy == -9
drop if missing(urban22_copy)
generate urban = (urban22_copy == 1)

*计数还剩多少
count

//制作信息鸿沟变量
//是否接入网络
generate internet = (qu201 == 1 | qu202 == 1) if !missing(qu201) & !missing(qu202)
tab internet
//网络使用时间
drop if missing(qu201) & missing(qu202)

clonevar qu201a_copy = qu201a
label values qu201a_copy
tab qu201a_copy
replace qu201a_copy = . if qu201a_copy == -8	//不适用
replace qu201a_copy = . if qu201a_copy == -2	//拒绝回答
replace qu201a_copy = . if qu201a_copy == -1	//不知道

clonevar qu202a_copy = qu202a
label values qu202a_copy
tab qu202a_copy
replace qu202a_copy = . if qu202a_copy == -8
replace qu202a_copy = . if qu202a_copy == -1
//计算总时长
egen total_internet_time = rowtotal(qu201a_copy qu202a_copy)
summarize total_internet_time
list qu201a_copy qu202a_copy total_internet_time in 1/10

//网络重要程度，计算总分
foreach var of varlist qu951 qu952 qu953 qu954 qu955 {
    clonevar `var'_copy = `var'
    label values `var'_copy
}

egen missing_count = rowmiss(qu951_copy qu952_copy qu953_copy qu954_copy qu955_copy)
drop if missing_count > 0

egen network_importance = rowtotal(qu951_copy qu952_copy qu953_copy qu954_copy qu955_copy)

//标准化变量
clonevar usage_time = total_internet_time
foreach var of varlist internet usage_time network_importance {
    egen z_`var' = std(`var')
}

* 主成分分析构建综合指数
pca z_internet z_usage_time z_network_importance	
predict digital_divide_index

// 计算主成分得分
pca z_internet z_usage_time z_network_importance
predict pc1 pc2 pc3, score
// 生成综合指数
gen composite_index = 0.5834 * pc1 + 0.2558 * pc2 + 0.1608 * pc3
// 标准化综合指数
egen composite_index_std = std(composite_index)


* 可靠性检验
alpha composite_index_std z_internet z_usage_time z_network_importance	//过了


*********

* 网购频率
gen online_shop = qu92 	//是为1，否为0，不适用为-8
clonevar qu921_copy = qu921
label values qu921_copy 
replace online_shop = 2 if qu921_copy == 1	//每天购物为2


* 学习频率
gen online_learn = qu94
clonevar qu941_copy = qu941
label values qu941_copy 
replace online_learn = 2 if qu941_copy == 1
replace online_learn = . if qu941_copy  == -8
replace online_learn = . if qu941_copy  == -1

gen edu_platform = qu5
clonevar qu5_copy = qu5
label values qu5_copy 
replace edu_platform = . if qu5_copy  == -8
replace edu_platform = . if qu5_copy  == -1

clonevar qu501_copy = qu501
label values qu501_copy 
replace edu_platform = . if qu5_copy  == -8
replace edu_platform = . if qu5_copy  == -2
replace edu_platform = . if qu5_copy  == -1
gen learn_time = qu501_copy/60 //转换为小时

*标准化处理
foreach var of varlist online_shop online_learn edu_platform learn_time {
    egen std_`var' = std(`var')
}

*计算综合指标
* 计算消费维度
egen consumption = rowmean(std_online_shop)

* 计算学习维度  
egen learning = rowmean(std_online_learn std_edu_platform std_learn_time)

* 计算总指标
egen func_use = rowmean(consumption learning)


*描述性统计分析
estpost summarize digital_divide_index age_copy female cfps2022edu_copy income urban
esttab, cells("mean sd min max") noobs



* 回归分析
reg func_use digital_divide_index age_copy female cfps2022edu_copy income urban
outreg2 using results.doc, replace
//检测多重共线性
estat vif

* 分位数回归
qreg func_use digital_divide_index age_copy female cfps2022edu_copy income urban, q(.25)
qreg func_use digital_divide_index age_copy female cfps2022edu_copy income urban, q(.5)
qreg func_use digital_divide_index age_copy female cfps2022edu_copy income urban, q(.75)

* 稳健性检验
reg func_use digital_divide_index age_copy female cfps2022edu_copy income urban, robust