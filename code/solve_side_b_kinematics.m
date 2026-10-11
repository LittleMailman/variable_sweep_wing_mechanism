% SOLVE_SIDE_B_KINEMATICS 计算B侧（杆4、杆5）的角位移、角速度、角加速度
% 输入驱动角 theta0 (rad)、角速度 omega1 (rad/s)、角加速度 alpha1 (rad/s²) 和四杆长度 l1..l4。
% 用法: [theta,omega,alpha] = solve_side_b_kinematics(theta0,omega1,alpha1,l1,l2,l3,l4)
% 说明: 三个输出各为 2×1 向量；沿用原公式与分支，不保证所有几何输入都可装配/非奇异。
% 来源: 用户提供的旧版 MATLAB 程序；重命名及注释整理版本。

function [theta,omega,alpha]=solve_side_b_kinematics(theta02,omega1,alpha2,l1,l2,l3,l4)
% 1. 利用四杆闭环几何关系，计算从动杆角位移 (rad)。
L=sqrt(l4*l4+l1*l1-2*l1*l4*cos(theta02));
phi=asin((l1./L)*sin(theta02));
beta=acos((-l2*l2+l3*l3+L*L)/(2*l3*L));
% acos 理论返回 [0, pi]；以下分支来自原代码，通常不会触发。
if beta<0 
    beta=beta+pi;
end
theta5=pi-phi-beta;                               % theta5 表示杆5转过角度
theta4=asin((l3*sin(theta5)-l1*sin(theta02))/l2);         % theta4 表示杆4转过角度
theta=[theta4;theta5] ;
% 2. 求解速度线性方程 A * omega = omega1 * B。
A=[-l2*sin(theta4), l3*sin(theta5);                  % 机构从动件的位置参数矩阵
    l2*cos(theta4), -l3*cos(theta5)];             
B=[l1*sin(theta02); -l1*cos(theta02)];                 % 机构原动件的位置参数列阵
omega=A\(omega1*B);                           % 机构从动件的速度列阵
omega4=omega(1); omega5=omega(2);
 
% 3. 将速度方程对时间求导，求角加速度。  
A=[-l2*sin(theta4),  l3*sin(theta5); 
    l2*cos(theta4), -l3*cos(theta5)];   
At=[-omega4*l2*cos(theta4), omega5*l3*cos(theta5); 
    -omega4*l2*sin(theta4), omega5*l3*sin(theta5)]; 
B=[l1*sin(theta02); -l1*cos(theta02)];                  % 机构原动件的位置参数列阵
Bt=[omega1*l1*cos(theta02); omega1*l1*sin(theta02)];   % Bt=dB/dt
alpha=A\(-At*omega+alpha2.*B+omega1*Bt);         % 机构从动件的加速度列阵
