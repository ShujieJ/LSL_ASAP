# LSL_ASAP
ASAP课题组用数据处理代码

# 使用说明
## 静态测力处理程序 shj_static_processer.m
用于水槽测量静态气动力后的数据处理
### 静态测力结果命名规范
**根目录**为 %folder_address%  
**无流速数据**存放位置：%folder_address%/s  
**有流速数据**存放位置：%folder_address%/d  
所有数据txt命名均为：_AoA_.txt（如：30.txt代表迎角为30度所测数据）
### 程序使用检查单
需要注意修改的项有：  
**folder_address：保存测力原始数据的文件夹**  
result：自定义输出结果子文件夹名  
rho：密度  
**flow_velocity：流速**  
**ref_length：参考长度**  
**ref_surface_area：参考面积**  