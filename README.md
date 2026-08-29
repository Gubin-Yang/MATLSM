# MATLSM 1.0

<p align="center">
  <img src="data/logo.png" alt="MATLSM logo" width="320">
</p>

**MATLAB Land Surface Model**  
**MATLAB 陆面模式**

MATLSM 是一个本人使用 MATLAB 开发、面向全球多年到百年变化研究的离线逐日陆面模式。模型在每个陆地网格上联合计算冠层、积雪、三层土壤、概念地下水和地表水热通量，并逐网格、逐日检查水量、地表能量和土壤热储量守恒。

模式的定位不是复现暴雨分钟尺度湿润锋，而是在日强迫能够支持的信息尺度上，用少量、可解释、可率定的蓄水—产流关系稳定描述长期土壤湿度、蒸散、地下水补给和径流变化。空间运算采用 MATLAB 全矩阵化实现，并支持在线时间聚合输出，以服务全球 50–100 年模拟。联系方式：E-mail:[1220410021@stu.xaut.edu.cn](1220410021@stu.xaut.edu.cn)

---

## 1. 主要特征

- 全球 2° 规则经纬度网格，默认 `75 × 179`；
- 固定 365 日年历和逐日时间步；
- 冠层截留、穿透降雨、冠层蒸发和露水；
- 雨雪相态划分、积雪、升华和能量受限融雪；
- 0–7、7–28、28–100 cm 三层土壤水热状态；
- VIC/新安江式次网格蓄水容量曲线和饱和超量产流；
- 三层重力排水、湿润壤中流、地下水补给、毛管上升和慢速基流；
- 土壤蒸发、植被蒸腾及分层根系吸水；
- 短波、长波、感热、潜热和地表土壤热通量；
- 隐式三层土壤热传导；
- LAI 和 FVC 完整逐日输入或 365 日气候态循环；
- 多变量、多数据集、多土层、面积加权的观测评估；
- MATLAB 单元测试与逐日守恒诊断。
- 可按 1、30、365 天等固定窗口在线平均输出，避免百年模拟保存全部逐日场。

模式空间运算采用矩阵化实现，时间维顺序积分，因为土壤水分、土壤温度、冠层水和积雪均为具有记忆的状态变量。

---

## 2. 科学边界

MATLSM 1.0 重点描述网格尺度的垂直陆面水热过程。目前尚未包含：

- 亚日降水强度和连续暴雨湿润锋记忆；
- Richards 方程及基质势驱动的双向土壤水运动；
- 由地形和含水层参数求解的物理地下水位；当前地下水是垂向概念活动库；
- 土壤液态水—冰分离及冻土水热耦合；
- 多层积雪、雪密度和雪温；
- 侧向汇流、河道路由和湖泊；
- 次网格植被/裸土/积雪瓦片；
- 植被碳循环、动态生长、CO₂ 生理响应和土地利用变化；
- 大气耦合反馈。

因此，本模式适合全球长期陆面变化、离线归因和参数化开发，不用于短历时洪峰预报。数值守恒通过仅说明源汇记账一致，不代表参数已经完成全球率定。

---

## 3. 环境与依赖

### 必需软件

- MATLAB；
- Climate Data Toolbox（CDT）。

项目使用 CDT 的 `cdtarea`、`island`、`borders`、`geomask` 和地形插值相关能力建立全球网格面积、陆地掩膜、区域掩膜和高程场。运行前应确保项目根目录与 CDT 已加入 MATLAB 路径。

建议使用支持 `-v7.3` MAT 文件、`tiledlayout`、`exportgraphics` 和 `arguments` 语法的较新 MATLAB 版本。当前项目已在 MATLAB R2026a 环境完成 10 年全球运行和评估。

---

## 4. 快速开始

### 4.1 创建配置

默认配置为 10 年：

```matlab
cfg = lsm.config();      % 默认 3650 天
```

也可以显式指定模拟天数：

```matlab
cfg = lsm.config(3650);  % 10 年
cfg = lsm.config(36500); % 100 年
```

MATLSM 1.0 采用固定 365 日年历，不自动处理闰日：

```matlab
cfg.dt = 86400;          % s
cfg.nyear = cfg.ndays/365;
```

气象强迫、植被状态和评估数据必须使用完全一致的日历与时间索引。如果源数据包含闰日，应在预处理阶段统一删除或显式重映射。

### 4.2 准备输入

主程序默认从下列文件读取输入：

```text
data/MyInput.mat
```

文件中应包含名为 `input_data` 的结构。使用项目读取函数重新生成输入时：

```matlab
cfg = lsm.config(3650);
input_data = lsm.read_input(cfg);
save('data/MyInput.mat','input_data','-v7.3');
```

如果启用综合评估，还需要先生成：

```text
Assessment/Obs.mat
```

运行：

```matlab
run('Assessment/A1_GetObs.m')
```

观测源文件位置在 `Assessment/A1_GetObs.m` 中配置。

### 4.3 运行模式

将 MATLAB 当前目录切换到项目根目录，然后执行：

```matlab
run
```

核心 API 为：

```matlab
cfg = lsm.config(3650);
input_data = lsm.read_input(cfg);
lsm.validate_input(input_data);

[output,final_state] = lsm.run(input_data,cfg);
report = lsm.summarize_diagnostics(output);
```

当前主程序将结果写入：

```text
output/MyRusults.mat
```

其中包含：

```matlab
output       % 完整逐日输出
final_state  % 最后一个时间步结束后的状态，可用于续跑
report       % 守恒和物理范围汇总
```

多年数组使用 `-v7.3` 保存。100 年或大型集合模拟建议按年分块输出并保存 restart，而不是一次性在内存中保存全部逐日变量。

### 4.4 自动参数率定

运行 `Calibration/A1_Calibrate.m`，或直接调用：

```matlab
cal = lsm.calibration_config("surrogateopt","soil_moisture_Root");
cal.max_evaluations = 40;
result = lsm.calibrate(input_data,Obs,cfg,cal);
```

优化方法和最重要的输出均可直接选择：

| `cal.method` | 适用情况 |
|---|---|
| `"surrogateopt"` | 默认；昂贵、非光滑目标的少次数全局搜索 |
| `"patternsearch"` | 已有较好初值时的稳健局部搜索或精修 |
| `"particleswarm"` | 更强全局探索，但通常需要更多模拟次数 |
| `"fminsearch"` | 无全局优化工具箱时的局部后备方法 |
| `"auto"` | 按本机可用工具箱自动选择 |

可以同时率定多个输出并设置重要性：

```matlab
cal.targets = ["soil_moisture_Root";"evapotranspiration";"latent_heat"];
cal.target_weights = [0.6;0.3;0.1];
```

损失函数对每个变量、数据集和土层分别计算面积加权 NRMSE 与相关系数：

```text
loss = (1-alpha)*NRMSE + alpha*(1-correlation)
```

所以 K、m³ m⁻³、mm day⁻¹ 和 W m⁻² 可以共同率定而不被单位大小支配。
默认 `alpha=0.20`；若只优化误差幅度，可设置 `cal.metric="nrmse"`。

快速阶段默认使用连续3年、首年spin-up和经纬方向每4格抽1格，约为完整全球
空间计算量的1/16。搜索期间只保存目标输出；获得最优参数后，可自动在完整
网格和完整时段复验：

```matlab
cal.run_full_validation = true;
```

默认参数集合按目标变量自动选择，也可编辑 `cal.parameters` 表中的初值、上下界
和线性/对数搜索尺度。结果写入 `Calibration/Results`。`cal.use_parallel=true`
可以并行评估，但多年输入会占用多个工作进程的内存，应按机器容量开启。

---

## 5. 网格、时间和维度

默认网格：

```matlab
cfg.lat = 89:-2:-59;   % 75 个纬度，北到南 [degree_north]
cfg.lon = -179:2:177;  % 179 个经度 [degree_east]
```

主要数组约定：

| 数据类型 | MATLAB 维度 | 含义 |
|---|---|---|
| 逐日二维场 | `nlat × nlon × ndays` | 纬度 × 经度 × 时间 |
| 分层静态场 | `nlat × nlon × nsoil` | 纬度 × 经度 × 土层 |
| 分层初始状态 | `nlat × nlon × nsoil` | 纬度 × 经度 × 土层 |
| 分层逐日输出 | `nlat × nlon × ndays × nsoil` | 纬度 × 经度 × 时间 × 土层 |
| 海洋/无效格点 | `NaN` | 不参与积分和评估 |

三层土壤定义：

| 层号 | 深度 | 厚度 |
|---:|---:|---:|
| 1 | 0–7 cm | 0.07 m |
| 2 | 7–28 cm | 0.21 m |
| 3 | 28–100 cm | 0.72 m |

`cfg.soil_depth` 表示各层厚度，不是层底深度，三层总厚度为 1.00 m。

网格属性集中存放在配置中：

| 字段 | 含义 | 单位 |
|---|---|---|
| `cfg.Lat`, `cfg.Lon` | 二维网格中心坐标 | degree |
| `cfg.latr` | 二维纬度弧度 | rad |
| `cfg.land` | CDT 地理陆地掩膜 | logical |
| `cfg.cell_area_km2` | 球面网格面积 | km² |
| `cfg.cell_area_m2` | 球面网格面积 | m² |
| `cfg.geomask_Greenland` | 格陵兰区域掩膜 | logical |
| `cfg.isDry` | 多年日均降水小于 0.5 mm 的极干旱区 | logical |

---

## 6. 输入数据

输入统一组织为：

```matlab
input_data.forcing
input_data.forcing_timevarying
input_data.static
input_data.initial
```

### 6.1 必需逐日气象强迫

所有变量维度均为 `nlat × nlon × ndays`。

| 字段 | 含义 | 单位 |
|---|---|---:|
| `tair` | 2 m 空气温度 | K |
| `surface_pressure` | 地表气压 | Pa |
| `qair` | 2 m 空气比湿 | kg kg⁻¹ |
| `wind` | 10 m 风速大小 | m s⁻¹ |
| `precip_rate` | 总降水质量速率 | kg m⁻² s⁻¹ |
| `sw_down` | 地表向下短波辐射 | W m⁻² |
| `lw_down` | 地表向下长波辐射 | W m⁻² |

降水质量速率在数值上等于液态水深速率 `mm s⁻¹`。向下短波和长波均存储为非负通量大小；地表向上长波由模式计算：

```text
lw_up = emissivity × sigma × surface_temperature^4
```

ERA5/ERA5-Land 日累计量转换示例：

```text
tp   [m day-1]      × 1000 / 86400 → precip_rate [kg m-2 s-1]
ssrd [J m-2 day-1]         / 86400 → sw_down      [W m-2]
strd [J m-2 day-1]         / 86400 → lw_down      [W m-2]
```

累计量必须先按正确累计周期差分，不能直接当作瞬时或日平均通量。

### 6.2 时变植被状态

| 字段 | 含义 | 单位/范围 |
|---|---|---:|
| `lai` | 单位植被覆盖面积上的单面叶面积指数 | m² m⁻² |
| `fvc` | 网格植被覆盖比例 | 0–1 |
| `lai_period_days` | 0：完整逐日序列；365：气候态 | day |
| `fvc_period_days` | 0：完整逐日序列；365：气候态 | day |
| `lai_source` | LAI 来源元数据 | string |
| `fvc_source` | FVC 来源元数据 | string |

配置方式：

```matlab
cfg.vegetation_forcing_mode = "auto";
```

| 取值 | 行为 |
|---|---|
| `"auto"` | 优先读取逐日数据，缺失时使用 365 日气候态 |
| `"timevarying"` | 强制使用完整逐日数据 |
| `"climatology365"` | 强制按固定 365 日周期循环 |

### 6.3 静态地表和土壤数据

| 字段 | 含义 | 单位 |
|---|---|---:|
| `land_mask` | 有效陆地掩膜 | logical |
| `elevation` | 高程 | m |
| `sand_fraction` | 分层砂粒质量分数 | 1 |
| `clay_fraction` | 分层黏粒质量分数 | 1 |
| `silt_fraction` | 分层粉粒质量分数 | 1 |
| `theta_sat` | 饱和体积含水量 | m³ m⁻³ |
| `theta_fc` | 田间持水量 | m³ m⁻³ |
| `theta_wp` | 永久萎蔫点 | m³ m⁻³ |
| `ksat` | 饱和导水率 | m s⁻¹ |
| `clapp_hornberger_b` | 保水曲线指数 | 1 |
| `psi_sat` | 饱和/进气吸力水头大小 | m water |

`data/Soil.mat` 的原始层为 0–5、5–15、15–30、30–60 和 60–100 cm。模式按源层与目标层的重叠厚度，将砂、黏、粉粒比例守恒重映射到三个目标层，再使用 Cosby 土壤传递函数和 Clapp–Hornberger 关系估算水力参数。

有效陆地土层必须满足：

```text
theta_wp < theta_fc < theta_sat
sand_fraction + clay_fraction + silt_fraction ≈ 1
```

### 6.4 初始状态

| 字段 | 含义 | 单位 |
|---|---|---:|
| `soil_moisture` | 三层土壤体积含水量 | m³ m⁻³ |
| `soil_temperature` | 三层土壤温度 | K |
| `canopy_water` | 冠层截留水 | kg m⁻² = mm |
| `swe` | 雪水当量 | kg m⁻² = mm |
| `groundwater_storage` | 概念地下水活动库储量 | kg m⁻² = mm |
| `surface_temperature` | 地表温度 | K |

初始状态代表第一个时间步开始前的状态。自动生成的初值是确定性启动场，不是相应日期的分析场。多年模拟应通过重复强迫或前置历史强迫进行水热 spin-up，并在储水量、深层土壤湿度和土壤温度年际漂移足够小时再开始正式分析。

---

## 7. 核心物理过程

### 7.1 降水、冠层和积雪

- 气温控制线性雨雪相态过渡；
- LAI 控制冠层容量和光学截留率；
- FVC 将植被尺度过程转换为网格平均通量；
- 穿透降雨进入入渗过程；
- 单一 SWE 水库描述积雪累积、升华和能量受限融雪；
- 露水依次进入冠层、积雪或表层土壤。

### 7.2 入渗、土壤水和径流

- 前两层 0–28 cm 的网格平均有效蓄水量控制产流；
- VIC/新安江式蓄水容量分布表示一个大网格内部的土壤深度、地形和湿润程度差异；
- 当蓄水增加时，饱和面积比例扩大，更多日液态水形成饱和超量地表径流；
- `runoff_shape_parameter=0` 时严格退化为“填满后产流”的简单水桶；
- 入渗水由上至下加入前两层，随后按 Clapp–Hornberger 非饱和导水率逐层排水；
- 湿润时第二层部分排水形成壤中流，第三层渗漏进入概念地下水活动库；
- 地下水以线性水库慢速退水形成基流，并能向低于田间持水量的第三层提供受限毛管补给。

主要日尺度参数集中在配置中：

```matlab
cfg.runoff_shape_parameter = 0.30;       % 次网格蓄水容量曲线
cfg.max_interflow_fraction = 0.15;       % 第二层排水的最大壤中流比例
cfg.groundwater_recession_days = 120;   % 地下水慢库e折减时间
cfg.capillary_rise_timescale_days = 60; % 地下水毛管补给时间尺度
```

这些是大尺度有效参数，应使用径流、土壤湿度、蒸散和地下水储量联合率定；它们不依赖虚构的小时降雨历时。

### 7.3 蒸散

- 湿冠层蒸发受冠层储水限制；
- 积雪升华受 SWE 限制；
- 蒸腾受 LAI、FVC、辐射、温度、空气湿度和根区水分共同限制；
- 根系吸水按分层可利用水量和根系比例分配；
- 土壤蒸发来自第一层并受水分胁迫控制。

### 7.4 地表能量和土壤热传导

地表能量平衡包括吸收短波、向下和向上长波、感热、潜热、地表土壤热通量和融雪潜热。地表温度通过向量化二分求根获得。

土壤热过程采用含水量相关热容量、简化 Johansen 热导率以及三层隐式守恒热传导，1 m 底部为绝热边界。

### 7.5 方案来源与适用尺度

当前水文结构是面向日尺度全球长期模拟的组合方案，并非任何现有模型的逐行复刻：

- 次网格蓄水容量分布及饱和超量产流参考 [VIC](https://doi.org/10.1029/94JD00483) 和[新安江模型](https://doi.org/10.1016/0022-1694(92)90096-E)；
- 简洁、连续的日尺度漏桶思想参考 [H08](https://doi.org/10.5194/hess-12-1007-2008)；
- 土壤层—地下水活动库—基流结构及毛管补给思路参考 [PCR-GLOBWB 2](https://doi.org/10.5194/gmd-11-2429-2018)；
- 地表能量平衡、三层土壤、分层根系吸水和独立河道路由的总体边界与 [VIC官方说明](https://vic.readthedocs.io/en/master/Overview/ModelOverview/)一致。

这些模型共同说明：较粗时间分辨率可以通过守恒的有效参数化描述长期统计响应，但“等效”并不意味着能唯一恢复亚日洪峰。日强迫下应重点检验多年均值、季节循环、趋势、干湿异常持续性和储量变化，而不应将日径流解释为暴雨小时峰值。

---

## 8. 输出变量

### 8.1 状态变量

| 字段 | 含义 | 单位 |
|---|---|---:|
| `surface_temperature` | 地表温度 | K |
| `soil_moisture` | 三层土壤体积含水量 | m³ m⁻³ |
| `soil_temperature` | 三层土壤温度 | K |
| `soil_moisture_Root` | 0–100 cm 厚度加权土壤湿度 | m³ m⁻³ |
| `soil_temperature_Root` | 0–100 cm 厚度加权土壤温度 | K |
| `canopy_water` | 冠层截留水 | kg m⁻² |
| `swe` | 雪水当量 | kg m⁻² |
| `total_soil_water` | 0–100 cm 土壤总水柱 | kg m⁻² |
| `groundwater_storage` | 概念地下水活动库储量 | kg m⁻² |
| `total_water_storage` | 冠层 + 积雪 + 土壤 + 地下水总储量 | kg m⁻² |

根区变量按土层厚度加权：

```text
Xroot = 0.07×X1 + 0.21×X2 + 0.72×X3
```

分层逐日变量的维度顺序为：

```matlab
output.soil_moisture(nlat,nlon,ndays,nsoil)
output.soil_temperature(nlat,nlon,ndays,nsoil)
```

例如：

```matlab
theta_day10_layer2 = output.soil_moisture(:,:,10,2);
```

### 8.2 逐日水量通量

单位均为 `kg m⁻² day⁻¹`，数值上等于 `mm day⁻¹`。

| 字段 | 含义 |
|---|---|
| `evapotranspiration` | 冠层蒸发 + 蒸腾 + 土壤蒸发 + 雪升华 |
| `canopy_evaporation` | 冠层蒸发 |
| `transpiration` | 植物蒸腾 |
| `soil_evaporation` | 土壤蒸发 |
| `snow_sublimation` | 积雪升华 |
| `dew` | 进入陆面的露水 |
| `snowfall` | 固态降水 |
| `snowmelt` | 融雪内部转移量 |
| `infiltration` | 进入前两层土壤的液态水 |
| `surface_runoff` | 饱和超量产流和露水溢流 |
| `interflow` | 湿润土层的侧向壤中流 |
| `groundwater_recharge` | 第三层进入地下水库的补给 |
| `capillary_rise` | 地下水返回第三层土壤的毛管补给 |
| `baseflow` | 地下水慢库退水 |
| `total_runoff` | 地表径流 + 壤中流 + 基流 |

总径流诊断应使用：

```matlab
total_runoff = output.surface_runoff + output.interflow + output.baseflow;
```

`saturated_area_fraction` 为产流计算开始时的次网格饱和面积比例，单位为 1。

### 8.3 能量和地表属性

| 字段 | 含义 | 单位 |
|---|---|---:|
| `net_radiation` | 净辐射 | W m⁻² |
| `sensible_heat` | 向上感热 | W m⁻² |
| `latent_heat` | 净向上潜热 | W m⁻² |
| `ground_heat` | 向下进入土壤的热通量 | W m⁻² |
| `lw_up` | 向上长波通量大小 | W m⁻² |
| `albedo` | 地表短波反照率 | 1 |


### 8.4 长期模拟输出聚合

```matlab
cfg.output_period_days = 1;   % 逐日输出，兼容当前逐日评估
cfg.output_period_days = 30;  % 连续30日平均
cfg.output_period_days = 365; % 固定365日平均，适合百年趋势
```

模式始终逐日积分；只有输出采用在线平均，不会把月/年平均强迫直接送入物理过程。状态和通量均保存该窗口的日平均值，水通量单位仍为 `kg m-2 day-1`。`output.time_end_day` 和 `output.period_day_count` 分别给出窗口结束日序和实际包含天数。

当前 `Assessment/Obs.mat` 是逐日观测，因此使用 30/365 日聚合输出时应设置
`cfg.assessment.enabled=false`，或另行制备完全相同聚合窗口的观测数据。



---

## 9. 守恒定义

逐日水量闭合：

```text
降水 + 露水
= 蒸散 + 地表径流 + 壤中流 + 基流 + 总储水变化 + water_balance_error
```

总储水包括冠层水、雪水当量、三层土壤水和概念地下水活动库。地下水补给与毛管上升是内部交换，不重复计入外部源汇。

地表能量闭合：

```text
净辐射
= 感热 + 潜热 + 地表土壤热通量 + 融雪能量 + energy_balance_error
```

土壤热储量通过 `soil_heat_balance_error` 独立检查。

版本 1.0 的 10 年全球基准结果为：

| 诊断 | 最大绝对残差 |
|---|---:|
| 水量闭合 | `2.39×10⁻¹² kg m⁻² day⁻¹` |
| 地表能量闭合 | `3.15×10⁻⁷ W m⁻²` |
| 土壤热储量闭合 | `5.41×10⁻¹² W m⁻²` |

---

## 10. 综合评估

评估数据结构为：

```matlab
Obs.(模型输出变量名).(数据集名)
```

评估函数会自动遍历 `Obs` 的所有顶层字段。只要 `output` 中存在同名数值字段，且空间、时间和分层尺寸完全一致，就会自动纳入评估，无需再修改评估函数。例如，新增径流观测只需：

```matlab
Obs.total_runoff.ERA5 = runoff_observation;
```

用户还可以继续增加任意变量。没有同名模式输出、尺寸不一致或没有共同有效样本的条目不会阻断其它变量，而会记录在 `assessment.discovery.skipped` 和 `Assessment/Results/assessment_skipped.csv` 中。新增变量的单位和可选分层标签可放在配置或 `ObsInfo` 中：

```matlab
ObsInfo.variable_units.my_variable = "kg m-2 day-1";
ObsInfo.layer_labels.my_variable = ["surface","root zone"];
```

也可使用 `cfg.assessment.variable_units` 和 `cfg.assessment.layer_labels`；配置中的设置优先于 `ObsInfo`。

当前示例包括 ERA5 土壤水热变量、GLEAM/PLSHv2/SiTHv2 蒸散以及 ERA5 湍流通量。ERA5 是再分析参考而非独立原位真值。

评估采用共同有效样本和真实网格面积加权，偏差定义为：

```text
bias = model - reference
```

输出包括覆盖率、偏差、相对偏差、MAE、RMSE、ubRMSE、标准化 RMSE、相关系数、R²、NSE、KGE 和标准差比。结果写入：

```text
Assessment/Results/assessment_summary.csv
Assessment/Results/assessment_skipped.csv
Assessment/Results/assessment.mat
Assessment/Results/00_summary_skill.png
Assessment/Results/*.png
```

当 `cfg.assessment.remove=true` 时，评分域剔除格陵兰和多年日均降水小于 0.5 mm 的极干旱区。全球变化研究建议同时报告完整陆地、干旱区、高纬区和核心评分域。

### 10.1 重构前版本 1.0 的 10 年参考技能

| 变量 | 偏差 | RMSE | 相关系数 | KGE |
|---|---:|---:|---:|---:|
| 0–7 cm 土壤湿度 | −0.0596 m³ m⁻³ | 0.1219 | 0.638 | 0.346 |
| 7–28 cm 土壤湿度 | −0.0308 m³ m⁻³ | 0.1109 | 0.467 | 0.246 |
| 28–100 cm 土壤湿度 | −0.0131 m³ m⁻³ | 0.1059 | 0.416 | 0.212 |
| 0–100 cm 土壤湿度 | −0.0206 m³ m⁻³ | 0.1043 | 0.457 | 0.237 |
| 0–100 cm 土壤温度 | +0.0115 K | 6.747 | 0.947 | 0.587 |
| 蒸散 / GLEAM | −0.499 mm day⁻¹ | 1.355 | 0.604 | 0.489 |
| 蒸散 / PLSHv2 | −0.318 mm day⁻¹ | 1.262 | 0.586 | 0.530 |
| 蒸散 / SiTHv2 | −0.414 mm day⁻¹ | 1.188 | 0.724 | 0.571 |
| 潜热 / ERA5 | −16.73 W m⁻² | 33.91 | 0.732 | 0.565 |
| 感热 / ERA5 | −0.55 W m⁻² | 30.70 | 0.711 | 0.590 |

这些结果表明 1.0 版能够稳定再现主要季节节律，但仍存在表层土壤偏干、深层异常相关偏低、蒸散和潜热不足、土壤温度季节振幅偏强等系统误差。该表是后续版本回归比较的基线，而不是最终精度声明。

---

## 11. 测试

运行全部单元测试：

```matlab
results = runtests('tests');
assertSuccess(results);
```

测试覆盖配置与维度、土壤质地守恒重映射、水力参数、可变蓄水容量产流、地下水状态、聚合输出、雨雪过程、365 日植被循环、分层输出、MAT 输入往返、综合评估以及水热守恒。

修改物理过程后，应同时运行单元测试和 10 年参考评估，确认目标变量得到改善且没有破坏守恒或其它通量。

---

## 12. 项目结构

```text
MATLSM/
├─ +lsm/                         模式核心与 MATLAB 包
│  ├─ config.m                   配置入口
│  ├─ read_input.m               输入组装
│  ├─ run.m                      时间积分
│  ├─ step.m                     单日水热过程
│  ├─ partition_surface_water.m  日尺度可变蓄水容量产流
│  ├─ redistribute_water.m       土层—壤中流—地下水交换
│  ├─ soil_hydraulic_from_texture.m
│  ├─ evaluate_output.m          面积加权综合评估
│  ├─ plot_evaluation.m          评估图件
│  ├─ summarize_diagnostics.m    守恒诊断
│  ├─ calibrate.m                自动参数率定
│  ├─ calibration_score.m        面积加权多目标损失
│  └─ subset_calibration_problem.m 快速空间/时间抽样
├─ Calibration/
│  ├─ A1_Calibrate.m             自动率定入口
│  └─ Results/                   参数、指标与率定结果
├─ Assessment/
│  ├─ A1_GetObs.m                评估数据预处理
│  └─ Results/                   评估表、MAT 与图件
├─ data/                         土壤、输入和辅助数据
├─ forcing/                      气象及植被强迫
├─ output/                       模式结果
├─ tests/                        MATLAB 单元测试
├─ run.m                         端到端运行入口
└─ README.md
```

---

## 13. 推荐开发路线

近期优先事项：

1. 使用径流、土壤湿度、蒸散和 GRACE 陆地水储量联合率定日尺度参数；
2. 增加按年读取强迫和直接写入 MAT/HDF5 的低内存工作流；
3. 完善 restart、spin-up 收敛判断和趋势不确定性分析；
4. 加入独立站点、遥感土壤湿度及地下水观测验证；
5. 增加独立河道路由模块，但保持与垂向陆面过程解耦。

版本 2.0 候选方向：

1. 基于总水势梯度的双向层间水通量；
2. 由含水层属性和地形约束的地下水位；
3. 更深土壤和深层温度边界；
4. 冻土水热耦合与多层积雪；
5. 次网格植被、雪和地形瓦片。

---

## 14. 引用、作者与许可

如果 MATLSM 用于论文或数据产品，请注明软件名称、版本、代码版本、强迫数据、参数数据、模拟时段、spin-up 方法和评估数据。

建议引用格式：

```text
MATLSM v1.0: MATLAB Land Surface Model, version 1.0.
```

正式公开前建议补充作者、机构、联系方式、仓库地址、发布日期、DOI、`CITATION.cff` 和明确的开源许可证。

当前仓库尚未声明软件许可证。在许可证加入前，默认不应假定代码可被自由再分发或用于商业用途。
