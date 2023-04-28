# LSL_ASAP
ASAP 课题组用数据处理代码

# 使用说明
static_processer.m 为静态测力处理程序  
dynamic_processer.m 为动态测力处理程序  
子函数也必须一并下载并放在同一目录下  

如果遇到程序 bug 或者需要修改程序，可以：  
1. （推荐）使用 github 的 fork 和 Pull requests 功能。
2. 在issue里说明问题，我来修改代码
3. 直接联系我

# 静态测力处理程序 static_processer.m
用于水槽测量静态气动力后的数据处理
## 静态测力结果命名规范
- **根目录**为：%folder_address%  
- **无流速数据**存放位置：%folder_address%/s  
- **有流速数据**存放位置：%folder_address%/d  
- 所有数据txt命名均为：_AoA_.txt（如：30.txt代表迎角为30度所测数据）
## 程序使用检查单
每次运行前需要确定修改的项有：  
1. **folder_address：保存测力原始数据的文件夹**  
2. result：自定义输出结果子文件夹名  
3. rho：密度  
4. **flow_velocity：流速**  
5. **ref_length：参考长度**  
6. **ref_surface_area：参考面积**  
# 动态测力处理程序 dynamic_processer.m
用于水槽测量动态气动力后的数据处理
## 动态测力结果命名规范
- **根目录**为 %folder_address%  
- **无流速数据**存放位置：%folder_address%/s  
- **无流速数据**命名为：_AoA_.txt（如：30.txt代表迎角为30度所测数据）  
- **有流速数据**存放位置：%folder_address%/d  
- **有流速数据**命名为：_10000*pitch_rate_.txt（如：0.1Hz所测数据命名为1000.txt）  
## 程序使用检查单
每次运行前需要确定修改的项有：  
1. **folder_address：保存测力原始数据的文件夹**  
2. rho：密度  
3. **flow_velocity：流速**  
4. **ref_length：参考长度**  
5. **ref_surface_area：参考面积**  
6. **delta_time：迎角采集和天平采集的误差时间**  

按需修改的参数：  
1. delta_alpha：输出迎角序列递增量
2. delta_dimensionless_time：输出无量纲时间序列递增量
3. dyn_sampling_rate：数据采样率