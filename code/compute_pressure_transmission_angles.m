% COMPUTE_PRESSURE_TRANSMISSION_ANGLES 压力角与传动角
% 四杆机构几何角度计算。x1=曲柄，x2=连杆，x3=摇杆，x4=机架；a1=曲柄转角 (rad)。
% 用法: angles = compute_pressure_transmission_angles(x1,x2,x3,x4,a1)
% 说明: 结果为 [pressure_angle, transmission_angle] (rad)；输入几何必须可装配，原公式未添加定义域裁剪。
% 来源: 用户提供的旧版 MATLAB 程序；重命名及注释整理版本。


function ay = compute_pressure_transmission_angles(x1,x2,x3,x4,a1)
% 对角线长度的平方，避免把 l 当作实际长度。
l=x1^2+x4^2-2*x1*x4*cos(a1);%DF的长度的平方
a3=acos((x2^2+x3^2-l)/(2*x2*x3));

% 传动角按锐角约定取值；压力角为其余角。
if a3>=pi/2
y=pi-a3;
elseif a3<pi/2
        y=a3;
end

a=pi/2-y;
ay=[a,y]; % 输出依次为 [压力角, 传动角]，单位 rad
