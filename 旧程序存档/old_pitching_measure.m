function pitching_measure
flow_rate=72.84;
pv2s=0.5*998.2*(flow_rate*0.00162)^2*0.009787258;
%选择U0和U文件
[U0,data,save_path]=file_import;
t=data(:,1);
deg_u=data(:,2);%角度总压
aoa_u=data(:,3);%迎角电压
u=data(:,4);%供桥电压
Y=data(:,5);
Mz=data(:,6);
X=data(:,7);
Mx=data(:,8);
%输入频率，计算采样率、采样周期数、单周期的采样点数
rate=inputdlg('频率：','动态频率');rate=str2double(rate{:});
sampling_rate=1/(t(2)-t(1));
sample_number=floor(t(end)*rate);
sample_point=sampling_rate/rate;
%滤波、相位平均数据
[fil_avr_deg_u]=fil_avr(deg_u,sample_point,sample_number);
[fil_avr_aoa_u]=fil_avr(aoa_u,sample_point,sample_number);
[fil_avr_u]=fil_avr(u,sample_point,sample_number);
[fil_avr_Y]=fil_avr(Y,sample_point,sample_number);
[fil_avr_Mz]=fil_avr(Mz,sample_point,sample_number);
[fil_avr_X]=fil_avr(X,sample_point,sample_number);
[fil_avr_Mx]=fil_avr(Mx,sample_point,sample_number);
%计算角度
a=72.3643;b=-218.7194;
% AOA=a*(fil_avr_aoa_u./fil_avr_deg_u)+b;
AOA=a*fil_avr_aoa_u+b;

force=zeros(sample_point+1,4);%aoa，cl，cd，y，mz,x,mx,z,my
for j=1:sample_point+1
    U_exp=fil_avr_u(j);
    U=[fil_avr_Y(j),fil_avr_Mz(j),fil_avr_X(j),fil_avr_Mx(j),0,0];
    [tempY,tempMz,tempX,~,~,~]=Balance_Cal(U0,U,U_exp);
    aoa=AOA(j); 
    force(j,:)=[aoa,tempY,tempMz,tempX];
end

%计算气动力系数
aoa=force(:,1);Y=force(:,2);Mz=force(:,3);X=force(:,4);
X=-1*X;
L=Y.*cos(aoa*pi/180)-X.*sin(aoa*pi/180);D=Y.*sin(aoa*pi/180)+X.*cos(aoa*pi/180);
Cl=L/pv2s;Cd=D/pv2s;Cm=Mz/pv2s/0.108;
Cy=Y/pv2s;Cx=X/pv2s;
out_data=[aoa Cl Cd Cm Cy Cx];
% plot(90/19.139*(aoa-328.898),Cy,90/19.139*(aoa-328.898),Cx);
plot(aoa,(-1)*Cl);
%保存结果
[m,~]=size(out_data);
fid=fopen(save_path,'wt');
fprintf(fid,'%s\n','aoa Cl Cd Cm Cy Cx');
for k=1:m
   fprintf(fid,'%g ',out_data(k,:));
   fprintf(fid,'\n');
end
fclose(fid);
end

function [U0,data,save_path]=file_import
%选择U0文件，计算U0
[U0_name,U0_path]=uigetfile('.txt','选择U0文件');
struct=importdata([U0_path,U0_name]);
mean_struct=mean(struct);
U0=mean_struct(1,5:8);
U0=[U0 0 0];
%选择U文件，导入数据
[U_name,U_path]=uigetfile('.txt','选择U文件');
data=importdata([U_path,U_name]);
%创建保存文件的路径
save_floder=[U_path,'result\'];mkdir(save_floder);
save_path=[save_floder,'force_',U_name];
end

function [fil_avr_a]=fil_avr(a,sample_point,sample_number)
%中值过滤,由于中值过滤前几个点偏差太大，因此抛弃第一个周期的数据不用
M_n=200;
fil_a=medfilt1(a,M_n);%中值过滤
a0=zeros(sample_point+1,sample_number-1);
for i=1:(sample_number-1)
    a0(:,i)=fil_a((i*sample_point+1):((i+1)*sample_point+1));
end
fil_avr_a=mean(a0,2);
end

function [Y,Mz,X,Mx,Z,My]=Balance_Cal(U0,U,U_exp)
%%%%%%%%%%%%%%%%%%%%%%%%%%%
%说明
%2N小量程天平电压转换
%输入按照 Y Mz X Mx Z My 排列
%%%%%%%%%%%%%%%%%%%%%%%%%%
%天平矩阵
%列对应：Y Mx Z Mz X My
%行对应：deltaU Y Mx Z Mz X My Y(Y+2Gy) (Y+Gy)Mx (Y+Gy)Z (Y+Gy)Mz (Y+Gy)X
%(Y+Gy)My MxMx MxZ MzMx Mx(X+Gx) MxMy ZZ ZMz Z(X+Gx) ZMy MzMz Mz(X+Gx) MzMy
%X(X+2Gx) (X+Gx)My MyMy
Matrix=[0.5536636	0.0531595	0	0.0637731	0.5562558	0
    0	-6.26E-06	0	-1.61E-05	-0.006445	0.00E+00
    -0.009198	0	0	0.0005985	-0.040805	0
    0	0	0	0	0	0
    0.0821301	-0.000578	0	0	-0.033633	0
    0.0122153	1.37E-05	0	5.80E-05	0	0.00E+00
    0	0	0	0	0	0
    0	4.58E-06	0	6.12E-06	9.92E-06	0.00E+00
    0	0	0	0	0	0
    0	0.00E+00	0	0.00E+00	0	0.00E+00
    0	0	0	0	0	0
    0	0.00E+00	0	0.00E+00	0	0.00E+00
    0	0	0	0	0	0
    0.0068252	0.00E+00	0	-5.76E-04	0.0311408	0.00E+00
    0	0	0	0	0	0
    0	0.00E+00	0	0.00E+00	0	0.00E+00
    0	0	0	0	0	0
    0	0.00E+00	0	0.00E+00	0	0.00E+00
    0	0	0	0	0	0
    0	0.00E+00	0	0.00E+00	0	0.00E+00
    0	0	0	0	0	0
    0	0.00E+00	0	0.00E+00	0	0.00E+00
    0.0042168	0.0006971	0	0	-0.003529	0
    0	0.00E+00	0	0.00E+00	0	0.00E+00
    0	0	0	0	0	0
    0.0001276	1.12E-05	0	-8.49E-08	0	0.00E+00
    0	0	0	0	0	0
    0	0.00E+00	0	0.00E+00	0	0.00E+00];
%重力修正
Gy=0;Gx=0;%天平沿着Z轴安装
%电压修正
K_check=1.0149;U_check=10.0073;
K=U_check/U_exp*K_check;

%数据重新排列
%测量分量排序为Y Mz X Mx Z My;天平矩阵排序为Y Mx Z Mz X My
U([1,2,3,4,5,6])=U([1,4,5,2,3,6]);
U0([1,2,3,4,5,6])=U0([1,4,5,2,3,6]);
%计算
DU=(U-U0)*K;
F=DU.*Matrix(1,:);
C=zeros(1,27);
main_Y=F(1);
main_Mx=F(2);
main_Z=F(3);
main_Mz=F(4);
main_X=F(5);
main_My=F(6);

for i=1:10
    if i==1
        Y=main_Y;
        Mx=main_Mx;
        Z=main_Z;
        Mz=main_Mz;
        X=main_X;
        My=main_My;
    else
        Y=main_Y+C*Matrix(2:end,1);
        Mx=main_Mx+C*Matrix(2:end,2);
        Z=main_Z+C*Matrix(2:end,3);
        Mz=main_Mz+C*Matrix(2:end,4);
        X=main_X+C*Matrix(2:end,5);
        My=main_My+C*Matrix(2:end,6);
    end
    C(1)=Y;
    C(2)=Mx;
    C(3)=Z;
    C(4)=Mz;
    C(5)=X;
    C(6)=My;
    C(7)=Y*(Y+2*Gy);
    C(8)=(Y+Gy)*Mx;
    C(9)=(Y+Gy)*Z;
    C(10)=(Y+Gy)*Mz;
    C(11)=(Y+Gy)*X;
    C(12)=(Y+Gy)*My;
    C(13)=Mx*Mx;
    C(14)=Mx*Z;
    C(15)=Mz*Mx;
    C(16)=Mx*(X+Gx);
    C(17)=Mx*My;
    C(18)=Z*Z;
    C(19)=Z*Mz;
    C(20)=Z*(X+Gx);
    C(21)=Z*My;
    C(22)=Mz*Mz;
    C(23)=Mz*(X+Gx);
    C(24)=Mz*My;
    C(25)=X*(X+2*Gx);
    C(26)=(X+Gx)*My;
    C(27)=My*My;
end

end