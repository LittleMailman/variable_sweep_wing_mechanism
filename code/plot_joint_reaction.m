% PLOT_JOINT_REACTION 绘制关节反力与曲柄力矩
% 扫描曲柄转角，调用 compute_joint_reaction 绘制反力曲线和驱动力矩估计。
% 用法: plot_joint_reaction
% 说明: 原长宽比可能无量纲，力矩数值需先核对长度单位；未与 CAD 模型受力仿真验证。
% 来源: 用户提供的旧版 MATLAB 程序；重命名及注释整理版本。

x1=1;
x2=3.86;
x3=2.30;
x4=4.58;

hd=pi/180;%换算为弧度制
du=180/pi;%换算为角度制

r=0.2; % 原假设摩擦圆半径，与杆长采用一致长度单位%假设摩擦圆半径为0.2
Fz=100; % 外载荷 (N)，原案例参数%假设阻力为100N

for n=1:361
    a1=(n-1)*hd;
    [FR]=compute_joint_reaction(a1,r,x1,x2,x3,x4,Fz);
    FRX(n)=FR(1);
    FR0(n)=FR(2);
end
figure(2);
x=0:360; % 实际曲柄转角 (deg)
subplot(1,2,1); 
plot(x, FRX,'k',x, FR0,'k--')
xlabel('曲柄转角\theta_1/\circ')
ylabel('运动反力F/N')
legend('F_R_x','F_R_0')
grid on;

subplot(1,2,2); 
plot(x, FRX*x1,'k') % 注意：仅当 x1 以米为单位时，力矩单位才是 N·m
xlabel('曲柄转角\theta_1/\circ')
ylabel('曲柄上的驱动力矩M/Nm')
grid on;
