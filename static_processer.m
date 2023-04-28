%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%������Ϊ�������պ����ѧ½ʿ��ʵ��������ʽˮ�۲���ʵ���ó���
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all;
format long;

%%%%%�Զ������%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
folder_address = 'C:\Users\xmr19\Documents\GitHub\LSL_ASAP\��������\��̬����ԭʼ����ʾ��';
result = 'result';
rho = 998.2;
flow_velocity = 0.15;%����
ref_length = 1;%�ο�����
ref_surface_area = 1;%�ο����
aoa_diff = 0;%��ƫӭ��





%%%%%����Ϊ�����壬�Ͻ����ģ�%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%����bug����github���ҵ�LSL_ASAP��Ŀ��issue������ϵ������%%%%%%%%%%%%%%






dyn_sampling_rate = 2000;
dyn_pressure_infinity = 0.5 * rho * flow_velocity ^ 2 * ref_surface_area;
%文件夹地�?
sta_folder_address = [folder_address,'\s'];%静�?值文件夹地址
sta_txt_file_information = dir([sta_folder_address,'\*.txt']);%静�?文件信息
dyn_folder_address = [folder_address,'\d'];%动�?值文件夹地址
dyn_txt_file_information = dir([dyn_folder_address,'\*.txt']);%动�?文件信息
result_save_address = [folder_address];%输出文件地址
for i = 1:length(sta_txt_file_information)%对每个迎角进行依次计�?
    sta_txt_file_address = ([sta_folder_address,'\',sta_txt_file_information(i).name]);%获取静�?文件完整地址
    sta_voltage_data = importdata(sta_txt_file_address);%读取静�?文件电压数据
    sta_voltage_mean_data = mean(sta_voltage_data);%电压平均�?
    [~,sta_txt_file_name,~] = fileparts(sta_txt_file_information(i).name);% 从文件名种获取迎�?
    aoa(i) = str2double(sta_txt_file_name)+aoa_diff;%将迎角字符串改为数�?
    sta_voltage_data_over_aoa(i,:) = [aoa(i), sta_voltage_mean_data(1,2:8)];%将静态电压写入迎角电压序列，把后者第�?���?�?列写入前者第�?��
end
sta_voltage_data_over_aoa = sortrows(sta_voltage_data_over_aoa);%将静态迎角电压按照迎角排�?
for i = 1 : length(dyn_txt_file_information)%遍历�?��动�?文件
    dyn_txt_file_address = ([dyn_folder_address,'\',dyn_txt_file_information(i).name]);%获取动�?文件完整地址
    dyn_voltage_data = importdata(dyn_txt_file_address);%读取动�?电压�?
    dyn_voltage_mean_data = mean(dyn_voltage_data);%电压平均�?
    dyn_voltage_data_over_aoa(i,:) = [aoa(i),dyn_voltage_mean_data(1,2:8)];%将动态电压写入迎角电压序�?
end
dyn_voltage_data_over_aoa = sortrows(dyn_voltage_data_over_aoa);%将动态迎角电压按照迎角排�?
delta_voltage_data_over_aoa(:,1) = dyn_voltage_data_over_aoa(:,1);%迎角
delta_voltage_data_over_aoa(:,2) = dyn_voltage_data_over_aoa(:,4);%供桥电压
delta_voltage_data_over_aoa(:,3:6) = dyn_voltage_data_over_aoa(:,5:8) - sta_voltage_data_over_aoa(:,5:8);%动�?和静态电压差�?
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
    L(i,1) = Y_force(i,1) * cos(aoa(i) * pi / 180) + X_force(i,1) * sin(aoa(i) * pi / 180);
    D(i,1) = Y_force(i,1) * sin(aoa(i) * pi / 180) - X_force(i,1) * cos(aoa(i) * pi / 180);
    %L(i,1) = Y_force(i,1);
    %D(i,1) = X_force(i,1);
    CL(i,1) = L(i,1) / dyn_pressure_infinity;
    CD(i,1) = D(i,1) / dyn_pressure_infinity;
end
force_coefficient_final_result_over_aoa = [aoa CL CD];
[row_number, ~] = size(force_coefficient_final_result_over_aoa);
head = {'aoa', 'CL', 'CD'};
xlswrite([result_save_address, '\', result,'.xls'], head,'sheet1', 'A1');
xlswrite([result_save_address, '\', result,'.xls'], force_coefficient_final_result_over_aoa, 'sheet1', 'A2');