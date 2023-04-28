%%%中值过滤函数，严禁更改！%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%如有bug，在github上找到LSL_ASAP项目发issue或者联系贾树杰%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [fil_avr_data] = fil_avr(data, dyn_sample_point_per_cycle, dyn_sample_cycle_number)%子程序：滤波平均
    %中值过滤,由于中值过滤前几个点偏差太大，因此抛弃第一个周期的数据不用
%     median_filter_order = 400;%中值过滤拟合宽度 默认值为400 即0.2秒
%     fil_a = medfilt1(data, median_filter_order);%将输入值进行中值过滤
    order = 3;
    framelen = 3001;
    fil_a = sgolayfilt(data, order, framelen);
    a0 = zeros(dyn_sample_point_per_cycle + 1, dyn_sample_cycle_number - 2);
    
    for i = 1 : (dyn_sample_cycle_number - 2)%将中值过滤后的数据按周期分列放置
        a0(:, i) = fil_a((i * dyn_sample_point_per_cycle + 1) : ((i + 1) * dyn_sample_point_per_cycle + 1));
    end
    
    fil_avr_data = mean(a0, 2);%按行计算平均并输出
end