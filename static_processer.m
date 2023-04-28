%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%本程序为北京航空航天大学陆士嘉实验室重力式水槽测力实验用程序
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear all;
format long;

%%%%%自定义参数%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
folder_address = 'C:\Users\xmr19\Documents\GitHub\LSL_ASAP\测试数据\静态测力原始数据示例';
result = 'result';
rho = 998.2;
flow_velocity = 0.15;%流速
ref_length = 1;%参考长度
ref_surface_area = 1;%参考面积
aoa_diff = 0;%零偏迎角





%%%%%以下为程序本体，严禁更改！%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%如有bug，在github上找到LSL_ASAP项目发issue或者联系贾树杰%%%%%%%%%%%%%%






dyn_sampling_rate = 2000;
dyn_pressure_infinity = 0.5 * rho * flow_velocity ^ 2 * ref_surface_area;
%鏂囦欢澶瑰湴鍧?
sta_folder_address = [folder_address,'\s'];%闈欐?鍊兼枃浠跺す鍦板潃
sta_txt_file_information = dir([sta_folder_address,'\*.txt']);%闈欐?鏂囦欢淇℃伅
dyn_folder_address = [folder_address,'\d'];%鍔ㄦ?鍊兼枃浠跺す鍦板潃
dyn_txt_file_information = dir([dyn_folder_address,'\*.txt']);%鍔ㄦ?鏂囦欢淇℃伅
result_save_address = [folder_address];%杈撳嚭鏂囦欢鍦板潃
for i = 1:length(sta_txt_file_information)%瀵规瘡涓繋瑙掕繘琛屼緷娆¤绠?
    sta_txt_file_address = ([sta_folder_address,'\',sta_txt_file_information(i).name]);%鑾峰彇闈欐?鏂囦欢瀹屾暣鍦板潃
    sta_voltage_data = importdata(sta_txt_file_address);%璇诲彇闈欐?鏂囦欢鐢靛帇鏁版嵁
    sta_voltage_mean_data = mean(sta_voltage_data);%鐢靛帇骞冲潎鍊?
    [~,sta_txt_file_name,~] = fileparts(sta_txt_file_information(i).name);% 浠庢枃浠跺悕绉嶈幏鍙栬繋瑙?
    aoa(i) = str2double(sta_txt_file_name)+aoa_diff;%灏嗚繋瑙掑瓧绗︿覆鏀逛负鏁板?
    sta_voltage_data_over_aoa(i,:) = [aoa(i), sta_voltage_mean_data(1,2:8)];%灏嗛潤鎬佺數鍘嬪啓鍏ヨ繋瑙掔數鍘嬪簭鍒楋紝鎶婂悗鑰呯涓?鐨?鑷?鍒楀啓鍏ュ墠鑰呯涓?
end
sta_voltage_data_over_aoa = sortrows(sta_voltage_data_over_aoa);%灏嗛潤鎬佽繋瑙掔數鍘嬫寜鐓ц繋瑙掓帓鍒?
for i = 1 : length(dyn_txt_file_information)%閬嶅巻鎵?湁鍔ㄦ?鏂囦欢
    dyn_txt_file_address = ([dyn_folder_address,'\',dyn_txt_file_information(i).name]);%鑾峰彇鍔ㄦ?鏂囦欢瀹屾暣鍦板潃
    dyn_voltage_data = importdata(dyn_txt_file_address);%璇诲彇鍔ㄦ?鐢靛帇鍊?
    dyn_voltage_mean_data = mean(dyn_voltage_data);%鐢靛帇骞冲潎鍊?
    dyn_voltage_data_over_aoa(i,:) = [aoa(i),dyn_voltage_mean_data(1,2:8)];%灏嗗姩鎬佺數鍘嬪啓鍏ヨ繋瑙掔數鍘嬪簭鍒?
end
dyn_voltage_data_over_aoa = sortrows(dyn_voltage_data_over_aoa);%灏嗗姩鎬佽繋瑙掔數鍘嬫寜鐓ц繋瑙掓帓鍒?
delta_voltage_data_over_aoa(:,1) = dyn_voltage_data_over_aoa(:,1);%杩庤
delta_voltage_data_over_aoa(:,2) = dyn_voltage_data_over_aoa(:,4);%渚涙ˉ鐢靛帇
delta_voltage_data_over_aoa(:,3:6) = dyn_voltage_data_over_aoa(:,5:8) - sta_voltage_data_over_aoa(:,5:8);%鍔ㄦ?鍜岄潤鎬佺數鍘嬪樊鍊?
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