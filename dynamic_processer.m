%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%本程序为北京航空航天大学陆士嘉实验室重力式水槽测力实验用程序
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all;
format long;

%%%%%自定义参数%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
folder_address = 'G:\lab\GD\4_Experiment_Data\jsj\a60_metal\0.15'; %文件夹地址
rho = 998.2; %密度 kg/m3
flow_velocity = 0.15; %速度 m/s
ref_length = 1; %参考长度 m
ref_surface_area = 1; %参考面积 m2
delta_time = 0; %迎角采集与天平采集的误差时间

%其他自定义参数（如无必要无需修改）
delta_alpha = 0.02; %输出迎角序列递增量
delta_dimensionless_time = 0.0001; %输出无量纲时间序列递增量
dyn_sampling_rate = 2000; %数据采样率





%%%%%以下为程序本体，严禁更改！%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%如有bug，在github上找到LSL_ASAP项目发issue或者联系贾树杰%%%%%%%%%%%%%%





%重要变量初始化
sta_voltage_data_over_aoa = zeros(13, 8); %静态迎角电压序列
sta_voltage_data_over_dimensionless_time = zeros(25, 8); %静态无量纲时间电压序列
sta_voltage_data_over_aoa_interpolated = zeros(60 / delta_alpha + 1, 8); %静态迎角插值电压序列
sta_voltage_data_over_dimensionless_time_interpolated = zeros(1 / delta_dimensionless_time + 1, 8); %静态无量纲时间插值电压序列
dyn_voltage_data_over_aoa_interpolated = zeros(60 / delta_alpha + 1, 6); %动态迎角插值电压序列
dyn_voltage_data_over_dimensionless_time_interpolated = zeros(1 / delta_dimensionless_time + 1, 6); %动态无量纲时间插值电压序列
sta_force_over_dimensionless_time = zeros(1 / delta_dimensionless_time, 5); %静态无量纲时间力矩阵
dyn_force_over_dimensionless_time = zeros(1 / delta_dimensionless_time, 5); %动态无量纲时间力矩阵
dyn_force_result_over_dimensionless_time = zeros(1 / delta_dimensionless_time, 5); %无量纲时间力矩阵最终计算结果

%文件夹地址
sta_folder_address = [folder_address, '\s']; %静态值文件夹地址
dyn_folder_address = [folder_address, '\d']; %动态值文件夹地址
result_save_address = [folder_address, '\result']; %输出文件地址

%远前方来流动压*参考面积
dyn_pressure_infinity = 0.5 * rho * flow_velocity ^ 2 * ref_surface_area;

%获取静态电压随迎角变化的数据 保存在static_measurement_voltage_data_over_aoa中
sta_txt_file_information = dir([sta_folder_address, '\*.txt']); %静态文件信息
for i = 1 : length(sta_txt_file_information) %遍历所有静态文件
    sta_txt_file_address = ([sta_folder_address, '\', sta_txt_file_information(i).name]); %获取静态文件完整地址
    sta_voltage_data = importdata(sta_txt_file_address); %读取静态文件数据
    sta_voltage_mean_data = mean(sta_voltage_data); %将平均值记录
    [~, sta_txt_file_name, ~] = fileparts(sta_txt_file_information(i).name); %获取文件名作为迎角
    sta_aoa = str2double(sta_txt_file_name); %将迎角从文件名字符串转为数值
    sta_voltage_data_over_aoa(i, :) = [sta_aoa, sta_voltage_mean_data(1, 2 : 8)]; %将信息写入静态迎角电压序列
    sta_dimensionless_time = acos(1 - sta_aoa / 30) / (2 * pi); %计算迎角对应的无量纲时间
    sta_voltage_data_over_dimensionless_time(i, :) = [sta_dimensionless_time, sta_voltage_mean_data(1, 2 : 8)]; %将信息写入静态无量纲时间电压序列
    sta_voltage_data_over_dimensionless_time(26 - i, :) = [1 - sta_dimensionless_time, sta_voltage_mean_data(1, 2 : 8)]; %将信息写入静态无量纲时间电压序列
end
sta_voltage_data_over_aoa = sortrows(sta_voltage_data_over_aoa, 1); %将静态迎角电压序列按照迎角排序
sta_voltage_data_over_dimensionless_time = sortrows(sta_voltage_data_over_dimensionless_time, 1); %将静态无量纲时间电压序列按照迎角排序

%生成迎角序列和无量纲时间序列并对静态电压进行插值
angle_of_attack_sequence = 0:delta_alpha:60; 
angle_of_attack_sequence = angle_of_attack_sequence'; %生成迎角序列
dimensionless_time_sequence = 0:delta_dimensionless_time:1;
dimensionless_time_sequence = dimensionless_time_sequence'; %生成无量纲时间序列
for i = 2 : 8 %对电压序列中第二列到第八列进行插值
    sta_voltage_data_over_dimensionless_time_interpolated(:, i) = interp1(sta_voltage_data_over_dimensionless_time(:, 1), sta_voltage_data_over_dimensionless_time(:, i), dimensionless_time_sequence, 'pchip'); %时间序列插值
    %！！！注意！！！此处插值方法不得使用spline球面插值方法，可能造成过拟合！
end
sta_voltage_data_over_dimensionless_time_interpolated = [dimensionless_time_sequence sta_voltage_data_over_dimensionless_time_interpolated(:, 4 : 8)];


% subplot(2, 3, 1);
% plot(sta_voltage_data_over_dimensionless_time(:, 1), sta_voltage_data_over_dimensionless_time(:, 4), 'o', dimensionless_time_sequence, sta_voltage_data_over_dimensionless_time_interpolated(:, 2),'r');
% subplot(2, 3, 2);
% plot(sta_voltage_data_over_dimensionless_time(:, 1), sta_voltage_data_over_dimensionless_time(:, 5), 'o', dimensionless_time_sequence, sta_voltage_data_over_dimensionless_time_interpolated(:, 3),'r');
% subplot(2, 3, 3);
% plot(sta_voltage_data_over_dimensionless_time(:, 1), sta_voltage_data_over_dimensionless_time(:, 6), 'o', dimensionless_time_sequence, sta_voltage_data_over_dimensionless_time_interpolated(:, 4),'r');
% subplot(2, 3, 4);
% plot(sta_voltage_data_over_dimensionless_time(:, 1), sta_voltage_data_over_dimensionless_time(:, 7), 'o', dimensionless_time_sequence, sta_voltage_data_over_dimensionless_time_interpolated(:, 5),'r');
% subplot(2, 3, 5);
% plot(sta_voltage_data_over_dimensionless_time(:, 1), sta_voltage_data_over_dimensionless_time(:, 8), 'o', dimensionless_time_sequence, sta_voltage_data_over_dimensionless_time_interpolated(:, 6),'r');

%处理动态数据
dyn_txt_file_information = dir([dyn_folder_address, '\*.txt']); %静态文件信息
for i = 1 : length(dyn_txt_file_information) %遍历所有动态文件
    %清除循环中的变量
    clear dyn_txt_file_address;
    clear dyn_voltage_data;
    clear time;
    clear dyn_aoa_voltage;
    clear dyn_bridge_voltage;
    clear dyn_Y_balance_voltage;
    clear dyn_Mz_balance_voltage;
    clear dyn_X_balance_voltage;
    clear dyn_Mx_balance_voltage;
    clear dyn_txt_file_name;
    clear dyn_pitching_rate;
    clear dyn_sample_cycle_number;
    clear dyn_sample_point_per_cycle;
    clear dyn_fil_avr_aoa_voltage;
    clear dyn_fil_avr_bridge_voltage;
    clear dyn_fil_avr_Y_balance;
    clear dyn_fil_avr_Mz_balance;
    clear dyn_fil_avr_X_balance;
    clear dyn_fil_avr_Mx_balance;
    clear dyn_fil_avr_aoa;
    clear dyn_aoa_max;
    clear dyn_aoa_min;
    clear dyn_fil_avr_aoa_compressed;
    clear dyn_dimensionless_time;
    clear dyn_voltage_data_over_dimensionless_time;
    clear number;
    clear center;
    clear dyn_dimesionless_time_min_location;
    clear dyn_dimesionless_time_max_location;
    clear dyn_aoa;
    clear dyn_voltage_data_over_dimensionless_time_interpolated;
    clear sta_bridge_voltage;
    clear sta_balance_voltage;
    clear sta_Y;
    clear sta_Mz;
    clear sta_X;
    clear sta_Mx;
    clear sta_force_over_dimensionless_time;
    clear dyn_bridge_voltage;
    clear dyn_balance_voltage;
    clear dyn_Y;
    clear dyn_Mz;
    clear dyn_X;
    clear dyn_Mx;
    clear dyn_force_over_dimensionless_time;
    clear dyn_force_result_over_dimensionless_time;
    clear Y_balance_force;
    clear Mz_balance_moment;
    clear X_balance_force;
    clear Mx_balance_moment;
    clear aoa_calculated_by_dimensionless_time;
    clear L;
    clear D;
    clear CL;
    clear CD;
    clear CMz;
    clear CMx;
    clear CY;
    clear CX;
    clear force_coefficient_final_result_over_dimensionless_time;
    clear row_number;
    clear result_file_name;
    clear result_txt_save_address;
    clear ans;
    clear fid;
    clear shift_sample_point_number;
    
    %读取文件
    dyn_txt_file_address = ([dyn_folder_address, '\', dyn_txt_file_information(i).name]); %获取动态文件完整地址
    dyn_voltage_data = importdata(dyn_txt_file_address); %读取动态文件数据
    
    %动态文件数据分类
    time = dyn_voltage_data(:, 1);%时间
    dyn_aoa_voltage = dyn_voltage_data(:, 3); %迎角电压
    dyn_bridge_voltage = dyn_voltage_data(:, 4); %供桥电压
    dyn_Y_balance_voltage = dyn_voltage_data(:, 5); %法向力电压（天平坐标系）
    dyn_Mz_balance_voltage = dyn_voltage_data(:, 6); %俯仰力矩电压（天平坐标系）
    dyn_X_balance_voltage = dyn_voltage_data(:, 7); %轴向力电压（天平坐标系）
    dyn_Mx_balance_voltage = dyn_voltage_data(:, 8); %滚转力矩电压（天平坐标系）
    
    %获取频率，计算采样周期数、单周期的采样点数
    [~, dyn_txt_file_name, ~] = fileparts(dyn_txt_file_information(i).name); %获取文件名作为频率
    dyn_pitching_rate = str2double(dyn_txt_file_name) / 10000; %将迎角从文件名字符串转为数值
    dyn_sample_cycle_number = floor(time(end) * dyn_pitching_rate);%对（采样总时间*频率）向下取整得到采样周期数
    dyn_sample_point_per_cycle = floor(dyn_sampling_rate / dyn_pitching_rate); %单周期采样数为（采样频率/俯仰频率）向下取整
    
    %平移
    shift_sample_number = floor(delta_time * dyn_sampling_rate);
    dyn_Y_balance_voltage = circshift(dyn_Y_balance_voltage, shift_sample_number);
    dyn_Mz_balance_voltage = circshift(dyn_Mz_balance_voltage, shift_sample_number);
    dyn_X_balance_voltage = circshift(dyn_X_balance_voltage, shift_sample_number);
    dyn_Mx_balance_voltage = circshift(dyn_Mx_balance_voltage, shift_sample_number);
    
    %滤波并按周期平均数据
    [dyn_fil_avr_aoa_voltage] = fil_avr(dyn_aoa_voltage, dyn_sample_point_per_cycle, dyn_sample_cycle_number);
    [dyn_fil_avr_bridge_voltage] = fil_avr(dyn_bridge_voltage, dyn_sample_point_per_cycle, dyn_sample_cycle_number);
    [dyn_fil_avr_Y_balance] = fil_avr(dyn_Y_balance_voltage, dyn_sample_point_per_cycle, dyn_sample_cycle_number);
    [dyn_fil_avr_Mz_balance] = fil_avr(dyn_Mz_balance_voltage, dyn_sample_point_per_cycle, dyn_sample_cycle_number);
    [dyn_fil_avr_X_balance] = fil_avr(dyn_X_balance_voltage, dyn_sample_point_per_cycle, dyn_sample_cycle_number);
    [dyn_fil_avr_Mx_balance] = fil_avr(dyn_Mx_balance_voltage, dyn_sample_point_per_cycle, dyn_sample_cycle_number);
    %plot(time(1: length(dyn_fil_avr_X_balance)), dyn_X_balance_voltage(1: length(dyn_fil_avr_X_balance)), 'r', time(1: length(dyn_fil_avr_X_balance)), dyn_fil_avr_X_balance,'g');
    
    %计算动态迎角
    aoa_voltage_constant_a = 72.3643;
    aoa_voltage_constant_b = -218.7194;
    dyn_fil_avr_aoa = aoa_voltage_constant_a * dyn_fil_avr_aoa_voltage + aoa_voltage_constant_b;
    %将迎角压缩映射至0-60度
    dyn_aoa_max = max(dyn_fil_avr_aoa);
    dyn_aoa_min = min(dyn_fil_avr_aoa);
    dyn_fil_avr_aoa_compressed = (dyn_fil_avr_aoa - dyn_aoa_min) / (dyn_aoa_max - dyn_aoa_min) * 60;
    %根据迎角计算对应的无量纲时间
    dyn_dimensionless_time = acos(1 - dyn_fil_avr_aoa_compressed / 30) / (2 * pi);
   
    %将无量纲时间和天平电压数据组合成为动态电压矩阵
    %矩阵内容：迎角 桥压 Y Mz X Mx，注意此时矩阵中无量纲时间仅是0-0.5的余弦简单对应，并非0-1，需要处理
    dyn_voltage_data_over_dimensionless_time = [dyn_dimensionless_time dyn_fil_avr_bridge_voltage dyn_fil_avr_Y_balance dyn_fil_avr_Mz_balance dyn_fil_avr_X_balance dyn_fil_avr_Mx_balance];
    %将所有数据平移至从无量纲时间0开始
    [~, dyn_dimesionless_time_min_location] = min(dyn_voltage_data_over_dimensionless_time(:, 1));
    dyn_voltage_data_over_dimensionless_time = circshift(dyn_voltage_data_over_dimensionless_time, length(dyn_voltage_data_over_dimensionless_time) + 1 - dyn_dimesionless_time_min_location); %对时间进行平移
    %将下俯周期的无量纲时间转换至0.5到1
    [~, dyn_dimesionless_time_max_location] = max(dyn_voltage_data_over_dimensionless_time(:, 1));
    for j = dyn_dimesionless_time_max_location : length(dyn_voltage_data_over_dimensionless_time)
        dyn_voltage_data_over_dimensionless_time(j, 1) = 1 - dyn_voltage_data_over_dimensionless_time(j, 1);
    end
    %去除所有因测量导致的无量纲时间重复的行
    [number, center] = hist(dyn_voltage_data_over_dimensionless_time(:, 1), unique(dyn_voltage_data_over_dimensionless_time(:, 1)));
    dyn_voltage_data_over_dimensionless_time(ismember(dyn_voltage_data_over_dimensionless_time(:, 1), center(number ~= 1)), :)=[];
            
    %对无量纲时间电压序列中第二列到第六列进行插值
    for j = 2 : 6
        dyn_voltage_data_over_dimensionless_time_interpolated(:, j) = interp1(dyn_voltage_data_over_dimensionless_time(:, 1), dyn_voltage_data_over_dimensionless_time(:, j), dimensionless_time_sequence, 'pchip'); %时间序列插值
        %！！！注意！！！此处插值方法不得使用spline球面插值方法，可能造成过拟合！
    end
    
    %形成基于无量纲时间的完整矩阵
    %矩阵内容为：无量纲时间 桥压 Y Mz X Mx
    dyn_voltage_data_over_dimensionless_time_interpolated = [dimensionless_time_sequence dyn_voltage_data_over_dimensionless_time_interpolated(:, 2 : 6)];
    
    %至此，动态和静态的文件均处理成为了关于无量纲时间的电压序列
    %静态值储存在sta_voltage_data_over_dimensionless_time_interpolated
    %动态值储存在dyn_voltage_data_over_dimensionless_time_interpolated
    %矩阵内容为：无量纲时间 桥压 Y Mz X Mx
    %接下来进行天平矩阵处理
    %将动态电压结果减去静态电压结果
    dyn_voltage_data_over_dimensionless_time_interpolated(:, 3 : 6) = dyn_voltage_data_over_dimensionless_time_interpolated(:, 3 : 6) - sta_voltage_data_over_dimensionless_time_interpolated(:, 3 : 6);
    %然后对动态电压值进行处理
    for j = 1 : length(dyn_voltage_data_over_dimensionless_time_interpolated)
        dyn_bridge_voltage = dyn_voltage_data_over_dimensionless_time_interpolated(j, 2);
        dyn_balance_voltage = [dyn_voltage_data_over_dimensionless_time_interpolated(j, 3 : 6), 0, 0];
        [dyn_Y, dyn_Mz, dyn_X, dyn_Mx, ~, ~] = Balance_Cal(dyn_balance_voltage, dyn_bridge_voltage);
        dyn_force_result_over_dimensionless_time(j, :) = [dyn_voltage_data_over_dimensionless_time_interpolated(j, 1), dyn_Y, dyn_Mz, dyn_X, dyn_Mx];
    end
    
    %计算气动力系数
    Y_balance_force = dyn_force_result_over_dimensionless_time(:, 2);
    Mz_balance_moment = dyn_force_result_over_dimensionless_time(:, 3);
    X_balance_force = dyn_force_result_over_dimensionless_time(:, 4);
    Mx_balance_moment = dyn_force_result_over_dimensionless_time(:, 5);
    aoa_calculated_by_dimensionless_time = 30 - 30 * cos(2 * pi * dyn_force_result_over_dimensionless_time(:, 1));
    L = Y_balance_force .* cos(aoa_calculated_by_dimensionless_time * pi / 180) + X_balance_force .* sin(aoa_calculated_by_dimensionless_time * pi / 180);%升力（气流坐标系）
    D = Y_balance_force .* sin(aoa_calculated_by_dimensionless_time * pi / 180) - X_balance_force .* cos(aoa_calculated_by_dimensionless_time * pi / 180);%阻力（气流坐标系）
    CL = L / dyn_pressure_infinity;%升力系数（气流坐标系）
    CD = D / dyn_pressure_infinity;%阻力系数（气流坐标系）
    CMz = Mz_balance_moment / dyn_pressure_infinity / ref_length;%俯仰力矩系数（取矩点为天平测力取矩点）
    CMx = Mx_balance_moment / dyn_pressure_infinity / ref_length;%滚转力矩系数（取矩点为天平测力取矩点）
    CY = - Y_balance_force / dyn_pressure_infinity;%法向力系数（模型对称面坐标系）
    CX = X_balance_force / dyn_pressure_infinity;%轴向力系数（模型对称面坐标系）
    force_coefficient_final_result_over_dimensionless_time = [dimensionless_time_sequence CL CD CY CX];
    
    %保存结果
    [row_number, ~] = size(force_coefficient_final_result_over_dimensionless_time);%取得最终结果的行数并储存
    result_file_name = dyn_txt_file_name;
    mkdir(result_save_address);
%     result_txt_save_address = [result_save_address, '\force_', result_file_name, '.txt'];
%     fid = fopen(result_txt_save_address, 'wt');
%     fprintf(fid, '%s\n', 'time* aoa CL CD CY CX');
%     for k = 1 : row_number
%        fprintf(fid, '%g ', force_coefficient_final_result_over_dimensionless_time(k, :));
%        fprintf(fid, '\n');
%     end
%     fclose(fid);
    
    head = {'time', 'CL', 'CD', 'CY', 'CX'};
    xlswrite([result_save_address, '\', 'result.xls'], head, result_file_name, 'A1');
    xlswrite([result_save_address, '\', 'result.xls'], force_coefficient_final_result_over_dimensionless_time, result_file_name, 'A2');
end

%plot(dyn_voltage_data_over_dimensionless_time(:, 1), dyn_voltage_data_over_dimensionless_time(:, 4), 'o', dimensionless_time_sequence, dyn_voltage_data_over_dimensionless_time_interpolated(:, 4),'r');