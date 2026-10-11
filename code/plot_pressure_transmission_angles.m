% PLOT_PRESSURE_TRANSMISSION_ANGLES 绘制压力角/传动角
% 遍历曲柄角度，绘制机构压力角（实线）与传动角（虚线）的变化曲线。
% 用法: plot_pressure_transmission_angles
% 说明: 采用原设计案例杆长比；图像展示不等于机构运动范围已经验证。
% 来源: 用户提供的旧版 MATLAB 程序；重命名及注释整理版本。

% 四杆机构杆长比例（无量纲）
x1=1;
x2=3.86;
x3=2.30;
x4=4.58;

hd=pi/180;%换算为弧度制
du=180/pi;%换算为角度制

% 完整转动范围：0–360°，共 361 个采样点。
for n=1:361
    a1=(n-1)*hd;
    [ay]=compute_pressure_transmission_angles(x1,x2,x3,x4,a1);
    a(n)=ay(1);
    y(n)=ay(2);
end

x=0:360; % 横轴为实际曲柄角度 (deg)，原程序采用 1:361
plot(x, a*du,'k',x, y*du,'k--')
xlabel('曲柄转角\theta_1/\circ')
ylabel('压力角与传动角/\circ')
grid on;
text(48,60,'虚线为传动角')
text(260,30,'实线为压力角')%绘制传动角和压力角图像
