clc;clear all;
save_floder=['F:\2021.11 force\inertia force_2\W50-TE\0.2Hz\result\'];%待处理文件路径
save_floder1=['F:\2021.11 force\inertia force_2\W50-TE\0.2Hz\result\'];%处理后文件存放路径
save_path=[save_floder,'force_3.txt'];%待处理文件名
save_path1=[save_floder1,'force_3_0.25.txt'];%处理后文件名
time=0.25;
f=0.2;T=1/f;T1=T/2;
%delimiterIn   = ' '; % 字符分隔符
%headerlinesIn = 1;   % 文件头的行数
%A = importdata(save_path, delimiterIn, headerlinesIn);
data_up = importdata(save_path);
data = data_up.data;
aoa=data(:,1);Y=data(:,5);X=data(:,6);
L=Y.*cos(aoa*pi/180)-X.*sin(aoa*pi/180);D=Y.*sin(aoa*pi/180)+X.*cos(aoa*pi/180);
data1=[aoa L D Y X];
[q,p]=max(aoa);
[q0,p0]=min(aoa);
p1=max(p,p0);
p2=min(p,p0);
data2=data1(p2:p1-1,:);
%data2=data2(1:10:end,:); 
s1=data1(p1:end,:);s2=data1(1:p2-1,:);data3=[s1;s2];
%data3=data3(1:10:end,:); 
%判断up和down
if data2(1,1)<=data2(100,1)
    data_up=data2;
    data_down=data3;
else data_up=data3;
    data_down=data2;
end
data_up(:,1)=data_up(:,1)-data_up(1,1);
data_down(:,1)=data_down(:,1)-data_down(end,1);
[h s]=hist(data_up(:,1),unique(data_up(:,1)));
data_up(ismember(data_up(:,1),s(h~=1)),:)=[];
[h s]=hist(data_down(:,1),unique(data_down(:,1)));
data_down(ismember(data_down(:,1),s(h~=1)),:)=[];
t_up=acos(1-data_up(:,1)/30)/(2*pi*f);
t_down=T-acos(1-data_down(:,1)/30)/(2*pi*f);
t_up1=t_up+time;t_down1=t_down+time;
t=[t_up1;t_down1];data_t=[data_up;data_down];data_t=[t real(data_t)];
[N M]=size(data_t);
for i=1:N
    if data_t(i,1)>T
        data_t(i,1)=data_t(i,1)-T;
    end
end
data_t=sortrows(data_t,1);
for i=1:N
    data_t(i,2)=30-30*cos(2*pi*f*data_t(i,1));
end
for i=1:N
    data_t(i,3)=data_t(i,5)*cos(data_t(i,2)*pi/180)-data_t(i,6)*sin(data_t(i,2)*pi/180);
    data_t(i,4)=data_t(i,5)*sin(data_t(i,2)*pi/180)+data_t(i,6)*cos(data_t(i,2)*pi/180);
end
%plot(data_t(:,1),-data_t(:,3));
for i=1:N
    if data_t(i,1)<=T1
        up(i,:)=data_t(i,:);
    else
        down(i,:)=data_t(i,:);
    end
end
% cqm_w = unique(down(:,1));
[h s]=hist(real(down(:,1)),unique(real(down(:,1))));
down(ismember(down(:,1),s(h~=1)),:)=[];
%up=data_t(1:4838,:);down=data_t(4839:end,:);
down=flip(down,1);
up=up(1:10:end,:);down=down(1:10:end,:);
Alpha = 0:0.25:60;Alpha = Alpha';
Cl_up = interp1(up(:,2),up(:,3),Alpha,'linear');
Cl_down = interp1(real(down(:,2)),real(down(:,3)),Alpha,'linear'); %  real(),去掉复数函数的虚部
%plot(data_up(:,1),data_up(:,2),'r');
%hold on
%plot(data_down(:,1),data_down(:,2),'r');
%hold on
%plot(t_up,-data_up(:,2),'r');
%hold on
Cl0=(Cl_up(2,1)+Cl_down(2,1))/2;Cl60=(Cl_up(end-1,1)+Cl_down(end-1,1))/2;
Cl_up(1,1)=Cl0;Cl_down(1,1)=Cl0;Cl_up(end,1)=Cl60;Cl_down(end,1)=Cl60;
time_up=acos(1-Alpha/30)/(2*pi*f);time_down=T-acos(1-Alpha/30)/(2*pi*f);
result_up=[time_up Alpha Cl_up];result_down=[time_down Alpha Cl_down];result_down=flip(result_down,1);
result=[result_up;result_down];
result(:,3)=result(:,3);
%plot(result(:,1),-result(:,2),'g');
%写入文件
fid=fopen(save_path1,'wt');
fprintf(fid,'%s\n','t        aoa       Cl');
[m,n]=size(result);
 for i=1:1:m
    for j=1:1:n
       if j==n
         fprintf(fid,'%g\n',result(i,j));
      else
        fprintf(fid,'%g\t',result(i,j));
       end
    end
end
fclose(fid);
subplot(1,2,1);
plot(t_up,data_up(:,2),'r');
hold on
plot(t_down,data_down(:,2),'r');
hold on
plot(data_t(:,1),data_t(:,3),'b');
hold on
plot(result(:,1),result(:,3),'g');
subplot(1,2,2);
plot(data_up(:,1),data_up(:,2),'r');
hold on
plot(data_down(:,1),data_down(:,2),'r');
hold on
plot(data_t(:,2),data_t(:,3),'b');
hold on
plot(result(:,2),result(:,3),'g');

%plot(t_up(:,1),data_up(:,2),'r');
%hold on
%plot(t_down(:,1),data_down(:,2),'b');