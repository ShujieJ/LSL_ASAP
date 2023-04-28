clear all;
format long;
folder_address = 'H:\s\group1\';
result = 'result';
rho = 998.2;
flow_velocity = 0.118;%（需修改）流速
ref_length = 0.108;%（需修改）参考长度0.0736
ref_surface_area = 0.009787258;%（需修改）参考面积0.00541696（AR1），0.01083392（AR2）,0.01625088(AR3)，0.02166784（AR4），0.0270848(AR5),0.0052656，a30-0.015797
dyn_sampling_rate = 2000;
dyn_pressure_infinity = 0.5 * rho * flow_velocity ^ 2 * ref_surface_area;
%文件夹地址
sta_folder_address = [folder_address,'H:\s\group1\'];%静态值文件夹地址
sta_txt_file_information = dir('H:\s\group1\*.txt');%静态文件信息
result_save_address = [folder_address];%输出文件地址
for i = 1:length(sta_txt_file_information)%对每个迎角进行依次计算
    sta_txt_file_address = ([sta_folder_address,'H:\s\group1\result\',sta_txt_file_information(i).name]);%获取静态文件完整地址
    sta_voltage_data = importdata(sta_txt_file_address);%读取静态文件电压数据
    sta_voltage_mean_data = mean(sta_voltage_data);%电压平均值
    [~,sta_txt_file_name,~] = fileparts(sta_txt_file_information(i).name);% 从文件名种获取迎角
    aoa(i) = str2double(sta_txt_file_name)+2.1;%将迎角字符串改为数值
    sta_voltage_data_aoa(i,:) = [aoa(i), sta_voltage_mean_data(1,2:8)];%将静态电压写入迎角电压序列，把后者第一行的2至8列写入前者第一行
end
sta_voltage_data_over_aoa = sortrows(sta_voltage_data);%将静态迎角电压按照迎角排列
for i = 1 : length(dyn_txt_file_information)%遍历所有动态文件
    dyn_txt_file_address = ([dyn_folder_address,'G:\Static-4.7\LG2\group1\',dyn_txt_file_information(i).name]);%获取动态文件完整地址
    dyn_voltage_data = importdata(dyn_txt_file_address);%读取动态电压值
    dyn_voltage_mean_data = mean(dyn_voltage_data);%电压平均值
    dyn_voltage_data_over_aoa(i,:) = [aoa(i),dyn_voltage_mean_data(1,2:8)];%将动态电压写入迎角电压序列
end
dyn_voltage_data_over_aoa = sortrows(dyn_voltage_data_over_aoa);%将动态迎角电压按照迎角排列
delta_voltage_data_over_aoa(:,1) = dyn_voltage_data_over_aoa(:,1);%迎角
delta_voltage_data_over_aoa(:,2) = dyn_voltage_data_over_aoa(:,4);%供桥电压
delta_voltage_data_over_aoa(:,3:6) = dyn_voltage_data_over_aoa(:,5:8) - sta_voltage_data_over_aoa(:,5:8);%动态和静态电压差值
for i = 1 : length(delta_voltage_data_over_aoa)
    dyn_bridge_voltage = delta_voltage_data_over_aoa(i,2);
    dyn_balance_voltage = [delta_voltage_data_over_aoa(i,3:6),0,0];
    [dyn_Y, dyn_Mz, dyn_X, dyn_Mx, ~, ~] = Balance_Cal(dyn_balance_voltage, dyn_bridge_voltage);
    force_result_over_aoa(i,:) = [delta_voltage_data_over_aoa(i,1),dyn_Y, dyn_Mz, dyn_X, dyn_Mx];
end
Y_force = force_result_over_aoa(:,2);
Mz_moment = force_result_over_aoa(:,3);
X_force = force_result_over_aoa(:,4);
Mx_moment = force_result_over_aoa(:,5);
aoa = aoa';
aoa = sortrows(aoa);
for i = 1 : length(aoa)
L(i,1) = - Y_force(i,1) * cos(aoa(i) * pi / 180) - X_force(i,1) * sin(aoa(i) * pi / 180);
D(i,1) = - Y_force(i,1) * sin(aoa(i) * pi / 180) + X_force(i,1) * cos(aoa(i) * pi / 180);
CL(i,1) = L(i,1) / dyn_pressure_infinity;%升力系数（气流坐标系）
CD(i,1) = D(i,1) / dyn_pressure_infinity;%阻力系数（气流坐标系）
end
force_coefficient_final_result_over_aoa = [aoa CL CD];
[row_number, ~] = size(force_coefficient_final_result_over_aoa);
head = {'aoa', 'CL', 'CD'};
xlswrite([result_save_address, '\', result,'.xls'], head,'sheet1', 'A1');
xlswrite([result_save_address, '\', result,'.xls'], force_coefficient_final_result_over_aoa, 'sheet1', 'A2');