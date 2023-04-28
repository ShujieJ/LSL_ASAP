%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%������Ϊ�������պ����ѧ½ʿ��ʵ��������ʽˮ�۲���ʵ���ó���
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all;
format long;

%%%%%�Զ������%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
folder_address = 'G:\lab\GD\4_Experiment_Data\jsj\a60_metal\0.15'; %�ļ��е�ַ
rho = 998.2; %�ܶ� kg/m3
flow_velocity = 0.15; %�ٶ� m/s
ref_length = 1; %�ο����� m
ref_surface_area = 1; %�ο���� m2
delta_time = 0; %ӭ�ǲɼ�����ƽ�ɼ������ʱ��

%�����Զ�����������ޱ�Ҫ�����޸ģ�
delta_alpha = 0.02; %���ӭ�����е�����
delta_dimensionless_time = 0.0001; %���������ʱ�����е�����
dyn_sampling_rate = 2000; %���ݲ�����





%%%%%����Ϊ�����壬�Ͻ����ģ�%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%����bug����github���ҵ�LSL_ASAP��Ŀ��issue������ϵ������%%%%%%%%%%%%%%





%��Ҫ������ʼ��
sta_voltage_data_over_aoa = zeros(13, 8); %��̬ӭ�ǵ�ѹ����
sta_voltage_data_over_dimensionless_time = zeros(25, 8); %��̬������ʱ���ѹ����
sta_voltage_data_over_aoa_interpolated = zeros(60 / delta_alpha + 1, 8); %��̬ӭ�ǲ�ֵ��ѹ����
sta_voltage_data_over_dimensionless_time_interpolated = zeros(1 / delta_dimensionless_time + 1, 8); %��̬������ʱ���ֵ��ѹ����
dyn_voltage_data_over_aoa_interpolated = zeros(60 / delta_alpha + 1, 6); %��̬ӭ�ǲ�ֵ��ѹ����
dyn_voltage_data_over_dimensionless_time_interpolated = zeros(1 / delta_dimensionless_time + 1, 6); %��̬������ʱ���ֵ��ѹ����
sta_force_over_dimensionless_time = zeros(1 / delta_dimensionless_time, 5); %��̬������ʱ��������
dyn_force_over_dimensionless_time = zeros(1 / delta_dimensionless_time, 5); %��̬������ʱ��������
dyn_force_result_over_dimensionless_time = zeros(1 / delta_dimensionless_time, 5); %������ʱ�����������ռ�����

%�ļ��е�ַ
sta_folder_address = [folder_address, '\s']; %��ֵ̬�ļ��е�ַ
dyn_folder_address = [folder_address, '\d']; %��ֵ̬�ļ��е�ַ
result_save_address = [folder_address, '\result']; %����ļ���ַ

%Զǰ��������ѹ*�ο����
dyn_pressure_infinity = 0.5 * rho * flow_velocity ^ 2 * ref_surface_area;

%��ȡ��̬��ѹ��ӭ�Ǳ仯������ ������static_measurement_voltage_data_over_aoa��
sta_txt_file_information = dir([sta_folder_address, '\*.txt']); %��̬�ļ���Ϣ
for i = 1 : length(sta_txt_file_information) %�������о�̬�ļ�
    sta_txt_file_address = ([sta_folder_address, '\', sta_txt_file_information(i).name]); %��ȡ��̬�ļ�������ַ
    sta_voltage_data = importdata(sta_txt_file_address); %��ȡ��̬�ļ�����
    sta_voltage_mean_data = mean(sta_voltage_data); %��ƽ��ֵ��¼
    [~, sta_txt_file_name, ~] = fileparts(sta_txt_file_information(i).name); %��ȡ�ļ�����Ϊӭ��
    sta_aoa = str2double(sta_txt_file_name); %��ӭ�Ǵ��ļ����ַ���תΪ��ֵ
    sta_voltage_data_over_aoa(i, :) = [sta_aoa, sta_voltage_mean_data(1, 2 : 8)]; %����Ϣд�뾲̬ӭ�ǵ�ѹ����
    sta_dimensionless_time = acos(1 - sta_aoa / 30) / (2 * pi); %����ӭ�Ƕ�Ӧ��������ʱ��
    sta_voltage_data_over_dimensionless_time(i, :) = [sta_dimensionless_time, sta_voltage_mean_data(1, 2 : 8)]; %����Ϣд�뾲̬������ʱ���ѹ����
    sta_voltage_data_over_dimensionless_time(26 - i, :) = [1 - sta_dimensionless_time, sta_voltage_mean_data(1, 2 : 8)]; %����Ϣд�뾲̬������ʱ���ѹ����
end
sta_voltage_data_over_aoa = sortrows(sta_voltage_data_over_aoa, 1); %����̬ӭ�ǵ�ѹ���а���ӭ������
sta_voltage_data_over_dimensionless_time = sortrows(sta_voltage_data_over_dimensionless_time, 1); %����̬������ʱ���ѹ���а���ӭ������

%����ӭ�����к�������ʱ�����в��Ծ�̬��ѹ���в�ֵ
angle_of_attack_sequence = 0:delta_alpha:60; 
angle_of_attack_sequence = angle_of_attack_sequence'; %����ӭ������
dimensionless_time_sequence = 0:delta_dimensionless_time:1;
dimensionless_time_sequence = dimensionless_time_sequence'; %����������ʱ������
for i = 2 : 8 %�Ե�ѹ�����еڶ��е��ڰ��н��в�ֵ
    sta_voltage_data_over_dimensionless_time_interpolated(:, i) = interp1(sta_voltage_data_over_dimensionless_time(:, 1), sta_voltage_data_over_dimensionless_time(:, i), dimensionless_time_sequence, 'pchip'); %ʱ�����в�ֵ
    %������ע�⣡�����˴���ֵ��������ʹ��spline�����ֵ������������ɹ���ϣ�
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

%����̬����
dyn_txt_file_information = dir([dyn_folder_address, '\*.txt']); %��̬�ļ���Ϣ
for i = 1 : length(dyn_txt_file_information) %�������ж�̬�ļ�
    %���ѭ���еı���
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
    
    %��ȡ�ļ�
    dyn_txt_file_address = ([dyn_folder_address, '\', dyn_txt_file_information(i).name]); %��ȡ��̬�ļ�������ַ
    dyn_voltage_data = importdata(dyn_txt_file_address); %��ȡ��̬�ļ�����
    
    %��̬�ļ����ݷ���
    time = dyn_voltage_data(:, 1);%ʱ��
    dyn_aoa_voltage = dyn_voltage_data(:, 3); %ӭ�ǵ�ѹ
    dyn_bridge_voltage = dyn_voltage_data(:, 4); %���ŵ�ѹ
    dyn_Y_balance_voltage = dyn_voltage_data(:, 5); %��������ѹ����ƽ����ϵ��
    dyn_Mz_balance_voltage = dyn_voltage_data(:, 6); %�������ص�ѹ����ƽ����ϵ��
    dyn_X_balance_voltage = dyn_voltage_data(:, 7); %��������ѹ����ƽ����ϵ��
    dyn_Mx_balance_voltage = dyn_voltage_data(:, 8); %��ת���ص�ѹ����ƽ����ϵ��
    
    %��ȡƵ�ʣ���������������������ڵĲ�������
    [~, dyn_txt_file_name, ~] = fileparts(dyn_txt_file_information(i).name); %��ȡ�ļ�����ΪƵ��
    dyn_pitching_rate = str2double(dyn_txt_file_name) / 10000; %��ӭ�Ǵ��ļ����ַ���תΪ��ֵ
    dyn_sample_cycle_number = floor(time(end) * dyn_pitching_rate);%�ԣ�������ʱ��*Ƶ�ʣ�����ȡ���õ�����������
    dyn_sample_point_per_cycle = floor(dyn_sampling_rate / dyn_pitching_rate); %�����ڲ�����Ϊ������Ƶ��/����Ƶ�ʣ�����ȡ��
    
    %ƽ��
    shift_sample_number = floor(delta_time * dyn_sampling_rate);
    dyn_Y_balance_voltage = circshift(dyn_Y_balance_voltage, shift_sample_number);
    dyn_Mz_balance_voltage = circshift(dyn_Mz_balance_voltage, shift_sample_number);
    dyn_X_balance_voltage = circshift(dyn_X_balance_voltage, shift_sample_number);
    dyn_Mx_balance_voltage = circshift(dyn_Mx_balance_voltage, shift_sample_number);
    
    %�˲���������ƽ������
    [dyn_fil_avr_aoa_voltage] = fil_avr(dyn_aoa_voltage, dyn_sample_point_per_cycle, dyn_sample_cycle_number);
    [dyn_fil_avr_bridge_voltage] = fil_avr(dyn_bridge_voltage, dyn_sample_point_per_cycle, dyn_sample_cycle_number);
    [dyn_fil_avr_Y_balance] = fil_avr(dyn_Y_balance_voltage, dyn_sample_point_per_cycle, dyn_sample_cycle_number);
    [dyn_fil_avr_Mz_balance] = fil_avr(dyn_Mz_balance_voltage, dyn_sample_point_per_cycle, dyn_sample_cycle_number);
    [dyn_fil_avr_X_balance] = fil_avr(dyn_X_balance_voltage, dyn_sample_point_per_cycle, dyn_sample_cycle_number);
    [dyn_fil_avr_Mx_balance] = fil_avr(dyn_Mx_balance_voltage, dyn_sample_point_per_cycle, dyn_sample_cycle_number);
    %plot(time(1: length(dyn_fil_avr_X_balance)), dyn_X_balance_voltage(1: length(dyn_fil_avr_X_balance)), 'r', time(1: length(dyn_fil_avr_X_balance)), dyn_fil_avr_X_balance,'g');
    
    %���㶯̬ӭ��
    aoa_voltage_constant_a = 72.3643;
    aoa_voltage_constant_b = -218.7194;
    dyn_fil_avr_aoa = aoa_voltage_constant_a * dyn_fil_avr_aoa_voltage + aoa_voltage_constant_b;
    %��ӭ��ѹ��ӳ����0-60��
    dyn_aoa_max = max(dyn_fil_avr_aoa);
    dyn_aoa_min = min(dyn_fil_avr_aoa);
    dyn_fil_avr_aoa_compressed = (dyn_fil_avr_aoa - dyn_aoa_min) / (dyn_aoa_max - dyn_aoa_min) * 60;
    %����ӭ�Ǽ����Ӧ��������ʱ��
    dyn_dimensionless_time = acos(1 - dyn_fil_avr_aoa_compressed / 30) / (2 * pi);
   
    %��������ʱ�����ƽ��ѹ������ϳ�Ϊ��̬��ѹ����
    %�������ݣ�ӭ�� ��ѹ Y Mz X Mx��ע���ʱ������������ʱ�����0-0.5�����Ҽ򵥶�Ӧ������0-1����Ҫ����
    dyn_voltage_data_over_dimensionless_time = [dyn_dimensionless_time dyn_fil_avr_bridge_voltage dyn_fil_avr_Y_balance dyn_fil_avr_Mz_balance dyn_fil_avr_X_balance dyn_fil_avr_Mx_balance];
    %����������ƽ������������ʱ��0��ʼ
    [~, dyn_dimesionless_time_min_location] = min(dyn_voltage_data_over_dimensionless_time(:, 1));
    dyn_voltage_data_over_dimensionless_time = circshift(dyn_voltage_data_over_dimensionless_time, length(dyn_voltage_data_over_dimensionless_time) + 1 - dyn_dimesionless_time_min_location); %��ʱ�����ƽ��
    %���¸����ڵ�������ʱ��ת����0.5��1
    [~, dyn_dimesionless_time_max_location] = max(dyn_voltage_data_over_dimensionless_time(:, 1));
    for j = dyn_dimesionless_time_max_location : length(dyn_voltage_data_over_dimensionless_time)
        dyn_voltage_data_over_dimensionless_time(j, 1) = 1 - dyn_voltage_data_over_dimensionless_time(j, 1);
    end
    %ȥ��������������µ�������ʱ���ظ�����
    [number, center] = hist(dyn_voltage_data_over_dimensionless_time(:, 1), unique(dyn_voltage_data_over_dimensionless_time(:, 1)));
    dyn_voltage_data_over_dimensionless_time(ismember(dyn_voltage_data_over_dimensionless_time(:, 1), center(number ~= 1)), :)=[];
            
    %��������ʱ���ѹ�����еڶ��е������н��в�ֵ
    for j = 2 : 6
        dyn_voltage_data_over_dimensionless_time_interpolated(:, j) = interp1(dyn_voltage_data_over_dimensionless_time(:, 1), dyn_voltage_data_over_dimensionless_time(:, j), dimensionless_time_sequence, 'pchip'); %ʱ�����в�ֵ
        %������ע�⣡�����˴���ֵ��������ʹ��spline�����ֵ������������ɹ���ϣ�
    end
    
    %�γɻ���������ʱ�����������
    %��������Ϊ��������ʱ�� ��ѹ Y Mz X Mx
    dyn_voltage_data_over_dimensionless_time_interpolated = [dimensionless_time_sequence dyn_voltage_data_over_dimensionless_time_interpolated(:, 2 : 6)];
    
    %���ˣ���̬�;�̬���ļ��������Ϊ�˹���������ʱ��ĵ�ѹ����
    %��ֵ̬������sta_voltage_data_over_dimensionless_time_interpolated
    %��ֵ̬������dyn_voltage_data_over_dimensionless_time_interpolated
    %��������Ϊ��������ʱ�� ��ѹ Y Mz X Mx
    %������������ƽ������
    %����̬��ѹ�����ȥ��̬��ѹ���
    dyn_voltage_data_over_dimensionless_time_interpolated(:, 3 : 6) = dyn_voltage_data_over_dimensionless_time_interpolated(:, 3 : 6) - sta_voltage_data_over_dimensionless_time_interpolated(:, 3 : 6);
    %Ȼ��Զ�̬��ѹֵ���д���
    for j = 1 : length(dyn_voltage_data_over_dimensionless_time_interpolated)
        dyn_bridge_voltage = dyn_voltage_data_over_dimensionless_time_interpolated(j, 2);
        dyn_balance_voltage = [dyn_voltage_data_over_dimensionless_time_interpolated(j, 3 : 6), 0, 0];
        [dyn_Y, dyn_Mz, dyn_X, dyn_Mx, ~, ~] = Balance_Cal(dyn_balance_voltage, dyn_bridge_voltage);
        dyn_force_result_over_dimensionless_time(j, :) = [dyn_voltage_data_over_dimensionless_time_interpolated(j, 1), dyn_Y, dyn_Mz, dyn_X, dyn_Mx];
    end
    
    %����������ϵ��
    Y_balance_force = dyn_force_result_over_dimensionless_time(:, 2);
    Mz_balance_moment = dyn_force_result_over_dimensionless_time(:, 3);
    X_balance_force = dyn_force_result_over_dimensionless_time(:, 4);
    Mx_balance_moment = dyn_force_result_over_dimensionless_time(:, 5);
    aoa_calculated_by_dimensionless_time = 30 - 30 * cos(2 * pi * dyn_force_result_over_dimensionless_time(:, 1));
    L = Y_balance_force .* cos(aoa_calculated_by_dimensionless_time * pi / 180) + X_balance_force .* sin(aoa_calculated_by_dimensionless_time * pi / 180);%��������������ϵ��
    D = Y_balance_force .* sin(aoa_calculated_by_dimensionless_time * pi / 180) - X_balance_force .* cos(aoa_calculated_by_dimensionless_time * pi / 180);%��������������ϵ��
    CL = L / dyn_pressure_infinity;%����ϵ������������ϵ��
    CD = D / dyn_pressure_infinity;%����ϵ������������ϵ��
    CMz = Mz_balance_moment / dyn_pressure_infinity / ref_length;%��������ϵ����ȡ�ص�Ϊ��ƽ����ȡ�ص㣩
    CMx = Mx_balance_moment / dyn_pressure_infinity / ref_length;%��ת����ϵ����ȡ�ص�Ϊ��ƽ����ȡ�ص㣩
    CY = - Y_balance_force / dyn_pressure_infinity;%������ϵ����ģ�ͶԳ�������ϵ��
    CX = X_balance_force / dyn_pressure_infinity;%������ϵ����ģ�ͶԳ�������ϵ��
    force_coefficient_final_result_over_dimensionless_time = [dimensionless_time_sequence CL CD CY CX];
    
    %������
    [row_number, ~] = size(force_coefficient_final_result_over_dimensionless_time);%ȡ�����ս��������������
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