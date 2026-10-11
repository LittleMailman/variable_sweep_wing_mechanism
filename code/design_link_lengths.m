% DESIGN_LINK_LENGTHS 连杆尺寸综合主脚本
% 依据三组目标输入/输出角度，调用 solve_link_length_ratios 求取杆长比例并换算为毫米。
% 用法: design_link_lengths
% 说明: 设计案例参数来自原程序；计算结果尚未与 CAD 模型逐项核对。
% 来源: 用户提供的旧版 MATLAB 程序；重命名及注释整理版本。

clear; clc;
% 1. 已知设计角（角度转弧度）与曲柄基准长度 (mm)
alpha_0=0*pi/180;phi_0=72*pi/180;
theta_1=[60;100;180]*pi/180;
theta_3=[30;45;75]*pi/180;
x1=100;

% 2. 相对杆长计算：x1 为曲柄基准长度，其他杆长按比例缩放
[l,m,n]=solve_link_length_ratios(theta_1,theta_3,alpha_0,phi_0);
x2=x1*l;
x3=x1*m;
x4=x1*n;

% 3. 打印无量纲比例和尺寸 (mm)
disp('        计算结果1:  各杆相对长度     ');
disp('--------------------------------------------');
fprintf ('       连杆相对长度     l = %3.2f  \n',l);
fprintf ('       摇杆相对长度     m = %3.2f  \n',m);
fprintf ('       机架相对长度     n = %3.2f  \n',n);
disp('--------------------------------------------');
disp('        计算结果2:  各杆长度 （单位 mm）    ');
disp('--------------------------------------------');
fprintf ('       曲柄长度       x1 = %3.2f  \n',x1);
fprintf ('       连杆长度       x2 = %3.2f  \n',x2);
fprintf ('       摇杆长度       x3 = %3.2f  \n',x3);
fprintf ('       机架长度       x4 = %3.2f  \n',x4);
