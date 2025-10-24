# CFPS-Digital-Divide-Analysis
基于2022年中国家庭追踪调查(CFPS)数据的实证研究 | **独立完成Stata数据分析全流程**

## 研究概述

本研究使用Stata对CFPS 2022数据进行分析，探讨数字鸿沟如何影响个人的功能性互联网使用行为。通过构建数字鸿沟综合指数和功能性使用指标，采用线性回归和分位数回归模型进行实证检验。

## 🎯 项目亮点

**独立完成完整的Stata数据分析流程：**
- ✅ 数据清洗与预处理
- ✅ 变量构建与指标设计  
- ✅ 主成分分析(PCA)构建综合指数
- ✅ 多元线性回归与分位数回归
- ✅ 稳健性检验与多重共线性诊断
- ✅ 结果输出与报告生成

## 📄 代码文件
cfps_digital_divide_analysis.do: 包含从原始数据导入、变量处理、指标构建到模型估计的全部Stata代码。

## 📊 独立技术实现

### 数据预处理 (`2022.do`)
```stata
// 独立完成数据清洗流程
use "C:\Users\DELL\Desktop\2022\cfps2022person_202410.dta"

// 控制变量构建
generate female = (gender == 1)
clonevar age_copy = age
clonevar income = qg12

// 异常值处理
replace income = . if income == -9 | income == -8
drop if missing(income)
```

### 数字鸿沟指标构建
```stata
// 独立设计三级指标体系
* 接入沟：是否接入网络
generate internet = (qu201 == 1 | qu202 == 1)

* 使用沟：网络使用时间  
egen total_internet_time = rowtotal(qu201a_copy qu202a_copy)

* 认知沟：网络重要性评价
egen network_importance = rowtotal(qu951_copy qu952_copy qu953_copy qu954_copy qu955_copy)

* 主成分分析构建综合指数
pca z_internet z_usage_time z_network_importance
predict digital_divide_index
```

### 统计建模与分析
```stata
// 独立完成回归分析
reg func_use digital_divide_index age_copy female cfps2022edu_copy income urban

// 分位数回归
qreg func_use digital_divide_index age_copy female cfps2022edu_copy income urban, q(.25)

// 稳健性检验
reg func_use digital_divide_index age_copy female cfps2022edu_copy income urban, robust

// 多重共线性诊断
estat vif
```

## 🛠️ 技术能力展示

**Stata技能栈：**
- 数据导入与清洗
- 变量生成与转换
- 缺失值处理
- 描述性统计分析
- 主成分分析(PCA)
- 多元线性回归
- 分位数回归
- 稳健标准误
- 多重共线性检验
- 结果导出与报告

**独立解决的问题：**
- 复杂指标体系的构建与验证
- 不同回归模型的比较与选择
- 统计结果的解释与可视化
- 完整研究流程的规划与执行


## 🎓 研究成果

基于独立完成的Stata分析，研究发现：
- 数字鸿沟指数对功能性互联网使用具有显著正向影响
- 教育水平是提升功能性使用能力的关键因素  
- 性别差异在互联网使用行为中表现显著
- 不同分位数下影响因素存在异质性

## 💡 技术价值

本项目完整展示了从原始数据到研究结论的**端到端数据分析能力**，证明了独立处理复杂社会科学数据、构建统计模型、解释分析结果的专业技能。

---

*该项目所有Stata代码均由个人独立编写完成，体现了完整的数据分析能力和统计建模水平。*
```
