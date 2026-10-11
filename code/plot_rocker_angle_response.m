% PLOT_ROCKER_ANGLE_RESPONSE 双侧摇杆转角曲线
% 调用双侧曲柄-摇杆角度模型，比较两侧摇杆随输入曲柄转角的变化。
% 用法: plot_rocker_angle_response
% 说明: 使用设计示例参数；输出包含的复数/NaN 风险取决于 compute_dual_rocker_angles。
% 来源: 用户提供的旧版 MATLAB 程序；重命名及注释整理版本。

x1=1;
x2=3.86;
x3=2.30;
x4=4.58;
L=3;

hd=pi/180;%换算为弧度制
du=180/pi;%换算为角度制
theta_Beta=106*hd; % 两侧曲柄夹角：106°，设计输入（待与 CAD 核对）

% 自 270° - theta_Beta/2 开始扫描 360°，共 361 个采样点。
for n=1:361
    theta_1=(270*hd-(theta_Beta/2))+(n-1)*hd;
    [theta]=compute_dual_rocker_angles(theta_1,theta_Beta,x1,x2,x3,x4,L);
    theta_3(n)=theta(1);
    theta_32(n)=theta(2);

end
x=(270-theta_Beta*du/2)+(0:360); % 用真实输入曲柄转角作横轴

plot(x, theta_3*du,'k',x, theta_32*du,'k--')
xlabel('曲柄转角\theta_1/\circ')
ylabel('摇杆转角/\circ')
grid on;
