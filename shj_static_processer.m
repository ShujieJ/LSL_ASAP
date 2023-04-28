clear all;
format long;
folder_address = 'H:\s\group1\';
result = 'result';
rho = 998.2;
flow_velocity = 0.118;%�����޸ģ�����
ref_length = 0.108;%�����޸ģ��ο�����0.0736
ref_surface_area = 0.009787258;%�����޸ģ��ο����0.00541696��AR1����0.01083392��AR2��,0.01625088(AR3)��0.02166784��AR4����0.0270848(AR5),0.0052656��a30-0.015797
dyn_sampling_rate = 2000;
dyn_pressure_infinity = 0.5 * rho * flow_velocity ^ 2 * ref_surface_area;
%�ļ��е�ַ
sta_folder_address = [folder_address,'H:\s\group1\'];%��ֵ̬�ļ��е�ַ
sta_txt_file_information = dir('H:\s\group1\*.txt');%��̬�ļ���Ϣ
result_save_address = [folder_address];%����ļ���ַ
for i = 1:length(sta_txt_file_information)%��ÿ��ӭ�ǽ������μ���
    sta_txt_file_address = ([sta_folder_address,'H:\s\group1\result\',sta_txt_file_information(i).name]);%��ȡ��̬�ļ�������ַ
    sta_voltage_data = importdata(sta_txt_file_address);%��ȡ��̬�ļ���ѹ����
    sta_voltage_mean_data = mean(sta_voltage_data);%��ѹƽ��ֵ
    [~,sta_txt_file_name,~] = fileparts(sta_txt_file_information(i).name);% ���ļ����ֻ�ȡӭ��
    aoa(i) = str2double(sta_txt_file_name)+2.1;%��ӭ���ַ�����Ϊ��ֵ
    sta_voltage_data_aoa(i,:) = [aoa(i), sta_voltage_mean_data(1,2:8)];%����̬��ѹд��ӭ�ǵ�ѹ���У��Ѻ��ߵ�һ�е�2��8��д��ǰ�ߵ�һ��
end
sta_voltage_data_over_aoa = sortrows(sta_voltage_data);%����̬ӭ�ǵ�ѹ����ӭ������
for i = 1 : length(dyn_txt_file_information)%�������ж�̬�ļ�
    dyn_txt_file_address = ([dyn_folder_address,'G:\Static-4.7\LG2\group1\',dyn_txt_file_information(i).name]);%��ȡ��̬�ļ�������ַ
    dyn_voltage_data = importdata(dyn_txt_file_address);%��ȡ��̬��ѹֵ
    dyn_voltage_mean_data = mean(dyn_voltage_data);%��ѹƽ��ֵ
    dyn_voltage_data_over_aoa(i,:) = [aoa(i),dyn_voltage_mean_data(1,2:8)];%����̬��ѹд��ӭ�ǵ�ѹ����
end
dyn_voltage_data_over_aoa = sortrows(dyn_voltage_data_over_aoa);%����̬ӭ�ǵ�ѹ����ӭ������
delta_voltage_data_over_aoa(:,1) = dyn_voltage_data_over_aoa(:,1);%ӭ��
delta_voltage_data_over_aoa(:,2) = dyn_voltage_data_over_aoa(:,4);%���ŵ�ѹ
delta_voltage_data_over_aoa(:,3:6) = dyn_voltage_data_over_aoa(:,5:8) - sta_voltage_data_over_aoa(:,5:8);%��̬�;�̬��ѹ��ֵ
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
CL(i,1) = L(i,1) / dyn_pressure_infinity;%����ϵ������������ϵ��
CD(i,1) = D(i,1) / dyn_pressure_infinity;%����ϵ������������ϵ��
end
force_coefficient_final_result_over_aoa = [aoa CL CD];
[row_number, ~] = size(force_coefficient_final_result_over_aoa);
head = {'aoa', 'CL', 'CD'};
xlswrite([result_save_address, '\', result,'.xls'], head,'sheet1', 'A1');
xlswrite([result_save_address, '\', result,'.xls'], force_coefficient_final_result_over_aoa, 'sheet1', 'A2');