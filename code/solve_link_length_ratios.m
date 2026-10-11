% SOLVE_LINK_LENGTH_RATIOS 计算四杆机构相对杆长
% 输入 theta_1、theta_3 为三组配对角度 (3×1, rad)；alpha_0、phi_0 为常量偏置 (rad)。
% 输出 l、m、n 分别对应连杆、摇杆和机架相对曲柄长度的比例。
% 用法: [l,m,n] = solve_link_length_ratios(theta_1,theta_3,alpha_0,phi_0)
% 说明: 计算公式沿用原程序；若系数矩阵奇异、比例出现负值/复数，应检查输入设计条件。
% 来源: 用户提供的旧版 MATLAB 程序；重命名及注释整理版本。

function [l,m,n]=solve_link_length_ratios(theta_1,theta_3,alpha_0,phi_0)  % 连杆机构设计
% 基于三组输入角度构造设计方程的系数矩阵 A。 
A=[ cos(theta_3(1)+phi_0),  cos(theta_3(1)+phi_0-theta_1(1)-alpha_0),  1;
    cos(theta_3(2)+phi_0),  cos(theta_3(2)+phi_0-theta_1(2)-alpha_0),  1;
    cos(theta_3(3)+phi_0),  cos(theta_3(3)+phi_0-theta_1(3)-alpha_0),  1 ];
% 构造线性方程组右端项 B。
B=[cos(theta_1(1)+alpha_0); cos(theta_1(2)+alpha_0); cos(theta_1(3)+alpha_0)];
% 求解 P = A\B，得到中间无量纲设计参数。
P=A\B;
% 根据原始推导求相对杆长，公式未进行独立验证。
P0=P(1);P1=P(2);P2=P(3);
m=P0;
n=-m/P1;
l=sqrt(m*m+n*n+1-P2*2*n);
