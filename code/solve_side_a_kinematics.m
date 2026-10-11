% SOLVE_SIDE_A_KINEMATICS 计算A侧（杆2、杆3）的角位移、角速度、角加速度
% 输入驱动角 theta0 (rad)、角速度 omega1 (rad/s)、角加速度 alpha1 (rad/s²) 和四杆长度 l1..l4。
% 用法: [theta,omega,alpha] = solve_side_a_kinematics(theta0,omega1,alpha1,l1,l2,l3,l4)
% 说明: 三个输出各为 2×1 向量；沿用原公式与分支，不保证所有几何输入都可装配/非奇异。
% 来源: 用户提供的旧版 MATLAB 程序；重命名及注释整理版本。

function [theta,omega,alpha]=solve_side_a_kinematics(theta01,omega1,alpha1,l1,l2,l3,l4)
% 1. 利用四杆闭环几何关系，计算从动杆角位移 (rad)。
L=sqrt(l4*l4+l1*l1-2*l1*l4*cos(theta01));
phi=asin((l1./L)*sin(theta01));
beta=acos((-l2*l2+l3*l3+L*L)/(2*l3*L));
% acos 理论返回 [0, pi]；以下分支来自原代码，通常不会触发。
if beta<0 
    beta=beta+pi;
end
theta3=pi-phi-beta;                               % theta3 表示杆3转过角度
theta2=asin((l3*sin(theta3)-l1*sin(theta01))/l2);         % theta2 表示杆2转过角度
theta=[theta2;theta3] ;
% 2. 求解速度线性方程 A * omega = omega1 * B。
A=[-l2*sin(theta2), l3*sin(theta3);                  % 机构从动件的位置参数矩阵
    l2*cos(theta2), -l3*cos(theta3)];             
B=[l1*sin(theta01); -l1*cos(theta01)];                 % 机构原动件的位置参数列阵
omega=A\(omega1*B);                           % 机构从动件的速度列阵
omega2=omega(1); omega3=omega(2);
 
% 3. 将速度方程对时间求导，求角加速度。  
A=[-l2*sin(theta2),  l3*sin(theta3); 
    l2*cos(theta2), -l3*cos(theta3)];   
At=[-omega2*l2*cos(theta2), omega3*l3*cos(theta3); 
    -omega2*l2*sin(theta2), omega3*l3*sin(theta3)]; 
B=[l1*sin(theta01); -l1*cos(theta01)];                  % 机构原动件的位置参数列阵
Bt=[omega1*l1*cos(theta01); omega1*l1*sin(theta01)];   % Bt=dB/dt
alpha=A\(-At*omega+alpha1*B+omega1*Bt);         % 机构从动件的加速度列阵
