% COMPUTE_DUAL_ROCKER_ANGLES 双侧摇杆位移关系
% 输入 theta_1（第一曲柄角）、theta_Beta（曲柄夹角），杆长比 x1..x4 和侧向间距 L。
% 用法: angles = compute_dual_rocker_angles(theta_1,theta_Beta,x1,x2,x3,x4,L)
% 说明: 保留原来的代数根选择、常数 pi/3 及几何表达式；根号与 acos 的定义域需后续验证。
% 来源: 用户提供的旧版 MATLAB 程序；重命名及注释整理版本。

function theta = compute_dual_rocker_angles(theta_1,theta_Beta,x1,x2,x3,x4,L)
% 1. 第一侧摇杆：构造由几何关系得到的二次方程系数。
A=L/2+x1*cos(theta_1);
B=sqrt(x4^2-(L/2)^2)+x1*sin(theta_1);

M=4*x3^2*(A.*A+B.*B);
N=-(4*x3*A.*(x2^2-A.*A-x3^2-B.*B));
Q=-4*x3^2*B.*B+(x2^2-A.*A-x3^2-B.*B).*(x2^2-A.*A-x3^2-B.*B);

% 待验证：原式包含 sqrt(sqrt(discriminant))，与常见二次方程求根不同。
% 此处为忠实保留，不擅自修改传动几何模型。
theta_312=acos((-N+sqrt(N.*N-4*M.*Q))/(2*M));
theta_3=theta_312-pi/3;

% 2. 第二侧摇杆：另一曲柄与第一侧相差 theta_Beta。
theta_12=theta_1+theta_Beta;

C=-L/2+x1*cos(theta_12);
D=sqrt(x4^2-(L/2)^2)+x1*sin(theta_12);

R=4*x3^2*(C.*C+D.*D);
S=-(4*x3*C.*(x2^2-C.*C-x3^2-D.*D));
T=-4*x3^2*D.*D+(x2^2-C.*C-x3^2-D.*D).*(x2^2-C.*C-x3^2-D.*D);

theta_322=acos((-S-sqrt(S.*S-4*R.*T))/(2*R));
theta_32=pi-theta_322;

theta=[theta_3;theta_32]; % 输出两侧摇杆角 (rad)，顺序与原文件一致
