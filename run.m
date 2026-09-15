% ==========================================================================
%% MATLSM 是一个使用 MATLAB 开发的全球离线逐日陆面模式。
% 模型在每个陆地网格上联合计算冠层、积雪、土壤水分、土壤温度以及地表水热通量，
% 并逐网格、逐日检查水量、地表能量和土壤热储量守恒。
% 版本 1.0 的定位是：结构清晰、数值稳定、便于诊断和继续开发的科研型陆面模式。
% 它适合开展多年全球离线试验、土壤湿度和蒸散研究、参数敏感性分析以及新参数化方案的原型验证；
% 它不是完整的地球系统模式，也不包含大气反馈或河道路由。
% 作者: Guibin-Yang 1220410021@stu.xaut.edu.cn  2026-8-28
% ==========================================================================

clear;clc;close all

cfg = lsm.config();
% if ~isfolder("data")
%     mkdir("data");
% end

% %% 1.读取真实强迫场/静态场和初始状态。名称叫 MyInput，数据为input_data
% fprintf("1/5 正在读取并保存 %d x %d x %d ：强迫场/静态场和初始状态...\n", ...
%     numel(cfg.lat),numel(cfg.lon),cfg.ndays);
% input_data = lsm.read_input(cfg);
% InputName='MyInput';
% save(['data/' InputName '.mat'],"input_data",'-v7.3')
% clear input_data


%% 2.读取并检查输入
total_timer = tic;
InputName='MyInput';
fprintf("2/6 从 MAT 读取并检查输入...\n");
load(['data/' InputName '.mat'])
lsm.validate_input(input_data);

%% 3.运行
fprintf("3/6 运行陆面模式...\n");
model_timer = tic;
[output, final_state] = lsm.run(input_data, cfg);
model_runtime_seconds = toc(model_timer);
report = lsm.summarize_diagnostics(output);
disp(report)

%% 4.保存结果
disp("4/6 写入结果....\n");
outfilePath='output/MyRusults.mat';%保存路径
if ~isfolder("output")
    mkdir("output");
end
save(outfilePath, "output", "final_state", "report", "-v7.3");

%% 5. 模拟完成
fprintf("完成。最大逐日水量残差 = %.3g kg m-2，最大地表能量残差 = %.3g W m-2。\n", ...
    report.max_abs_water_error, report.max_abs_energy_error);

% %% 6. 综合评估：精度、时空结构、分层表现、守恒与计算性能
% if cfg.assessment.enabled
%     fprintf("6/6 正在进行多变量、多数据集和多土层综合评估...\n");
%     assessment = lsm.run_assessment( ...
%         output,cfg,model_runtime_seconds,toc(total_timer));
% end
% % 结果保存在  【Assessment/Results】文件夹下
% fprintf('总耗时 %.2f s，其中模式积分 %.2f s。\n', ...
%     toc(total_timer),model_runtime_seconds);
