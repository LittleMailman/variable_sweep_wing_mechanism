% ANALYZE_LINKAGE_JOINT_FORCES 四杆机构运动学与关节反力分析
%
% 运行方式（MATLAB 命令窗口）：
%   clear; clc; close all;
%   analyze_linkage_joint_forces
%
% 分析内容：
%   1. 曲柄整周转动时的连杆、摇杆运动学；
%   2. 根据质量和转动惯量构造惯性力/惯性力矩；
%   3. 求解原始模型的 9×9 平面力学平衡方程；
%   4. 绘制关节反力分量与曲柄输入力矩。
%
% 重要说明：
%   - 本文件统一采用 SI 单位：m、kg、s、N、N·m、kg·m^2。
%   - 几何长度已由原程序的 mm 转换为 m。
%   - 质量、转动惯量及工作阻力矩沿用原始示例值，尚未与
%     SolidWorks 质量属性及真实工况核对！计算结果不能直接用于选型。
%   - 保留原始机构的运动学和力平衡公式，尚未完成独立力学验证。
%   - 质心位于每根杆件中点属于简化假设。

clear; clc; close all;

%% 1. 模型参数（SI 单位）
% 杆件尺寸（m）：曲柄、连杆、摇杆、固定机架
l1 = 0.10000;       % 曲柄长度 100.00 mm
l2 = 0.38565;       % 连杆长度 385.65 mm
l3 = 0.23019;       % 摇杆长度 230.19 mm
l0 = 0.45776;       % 机架长度 457.76 mm

% 各杆质心到对应铰点的距离（m），暂按中点假设
las1 = l1 / 2;
lbs2 = l2 / 2;
lds3 = l3 / 2;

% 运动和环境参数
omega1 = 10;        % 曲柄匀速转动角速度 (rad/s)
alpha1 = 0;         % 曲柄角加速度 (rad/s^2)
g = 9.81;           % 重力加速度 (m/s^2)

% 以下为原始程序的示例参数：务必对照 CAD/实际负载复核
m1 = 4.252;         % 曲柄质量 (kg)，原始示例值
m2 = 5.111;         % 连杆质量 (kg)，原始示例值
m3 = 10.212;        % 摇杆质量 (kg)，原始示例值
Js1 = 0.111688;     % 曲柄质心转动惯量 (kg*m^2)，原始示例值
Js2 = 0.83621;      % 连杆质心转动惯量 (kg*m^2)，原始示例值
Js3 = 0.88665;      % 摇杆质心转动惯量 (kg*m^2)，原始示例值
Mr = 100;           % 作用于摇杆的工作阻力矩 (N*m)，原始示例值

if any([l0,l1,l2,l3,m1,m2,m3,Js1,Js2,Js3] <= 0)
    error('杆长、质量和转动惯量均应为正数。');
end

%% 2. 初始化输出数组
angle_deg = 1:360;
nSamples = numel(angle_deg);
angle_rad = angle_deg * pi / 180;

% 按原始代码习惯保留变量名，方便与历史结果对照
[theta2,theta3,omega2,omega3,alpha2,alpha3] = deal(zeros(1,nSamples));
[Fr10x,Fr10y,Fr12x,Fr12y,Fr23x,Fr23y,Fr30x,Fr30y,Mb] = ...
    deal(zeros(1,nSamples));

% 判断浮点计算造成的 acos/asin 微小越界
angleTol = 1e-10;
% 检查运动学奇异位置及力平衡矩阵的数值可解性
singularityTol = 1e-10;

%% 3. 对每个输入曲柄转角求运动学和关节反力
for k = 1:nSamples
    t1 = angle_rad(k);

    % ---- 3.1 四杆机构位置解（保留原始装配分支） ----
    L = sqrt(l0^2 + l1^2 - 2*l1*l0*cos(t1));
    if L <= singularityTol
        error('输入角 %.1f 度：几何长度 L 接近零。',angle_deg(k));
    end

    sin_phi = l1*sin(t1)/L;
    cos_beta = (-l2^2 + l3^2 + L^2)/(2*l3*L);
    if abs(sin_phi) > 1+angleTol || abs(cos_beta) > 1+angleTol
        error('输入角 %.1f 度：几何参数超出 asin/acos 实数定义域。',angle_deg(k));
    end
    phi = asin(max(-1,min(1,sin_phi)));
    beta = acos(max(-1,min(1,cos_beta)));
    theta3(k) = pi - phi - beta;

    sin_theta2 = (l3*sin(theta3(k))-l1*sin(t1))/l2;
    if abs(sin_theta2) > 1+angleTol
        error('输入角 %.1f 度：连杆角 theta2 无实数解。',angle_deg(k));
    end
    theta2(k) = asin(max(-1,min(1,sin_theta2)));

    % 几何闭合检查：r1 + r2 = r0 + r3
    closureX = l1*cos(t1)+l2*cos(theta2(k))-l0-l3*cos(theta3(k));
    closureY = l1*sin(t1)+l2*sin(theta2(k))-l3*sin(theta3(k));
    if hypot(closureX,closureY) > 1e-8
        error('输入角 %.1f 度：四杆闭合误差过大，请检查装配分支。',angle_deg(k));
    end

    % ---- 3.2 角速度、角加速度 ----
    s32 = sin(theta3(k)-theta2(k));
    if abs(s32) < singularityTol
        error('输入角 %.1f 度：四杆处于或接近运动学奇异位置。',angle_deg(k));
    end

    omega3(k) = omega1*l1*sin(t1-theta2(k))/(l3*s32);
    omega2(k) = -omega1*l1*sin(t1-theta3(k)) / ...
        (l2*sin(theta2(k)-theta3(k)));

    alpha3(k) = (omega1^2*l1*cos(t1-theta2(k)) + ...
        omega2(k)^2*l2-omega3(k)^2*l3*cos(theta3(k)-theta2(k))) / ...
        (l3*s32);
    alpha2(k) = (-omega1^2*l1*cos(t1-theta3(k)) + ...
        omega3(k)^2*l3-omega2(k)^2*l2*cos(theta2(k)-theta3(k))) / ...
        (l2*sin(theta2(k)-theta3(k)));

    % ---- 3.3 杆件质心加速度 (m/s^2) ----
    as1x = -las1*omega1^2*cos(t1) - las1*alpha1*sin(t1);
    as1y = -las1*omega1^2*sin(t1) + las1*alpha1*cos(t1);

    as2x = -l1*(omega1^2*cos(t1)+alpha1*sin(t1)) ...
           -lbs2*(alpha2(k)*sin(theta2(k))+omega2(k)^2*cos(theta2(k)));
    as2y =  l1*(alpha1*cos(t1)-omega1^2*sin(t1)) ...
           +lbs2*(alpha2(k)*cos(theta2(k))-omega2(k)^2*sin(theta2(k)));

    as3x = -lds3*(cos(theta3(k))*omega3(k)^2+sin(theta3(k))*alpha3(k));
    as3y = -lds3*(sin(theta3(k))*omega3(k)^2-cos(theta3(k))*alpha3(k));

    % ---- 3.4 达朗贝尔惯性力、惯性力偶 ----
    F1x = -m1*as1x; F1y = -m1*as1y;
    F2x = -m2*as2x; F2y = -m2*as2y;
    F3x = -m3*as3x; F3y = -m3*as3y;
    M1 = -Js1*alpha1;                  % 匀速输入时为零
    M2 = -Js2*alpha2(k);
    M3 = -Js3*alpha3(k)-Mr;

    % ---- 3.5 铰点和各杆质心的平面坐标 (m) ----
    xa = 0; ya = 0;
    xb = l1*cos(t1);              yb = l1*sin(t1);
    xc = l0+l3*cos(theta3(k));    yc = l3*sin(theta3(k));
    xd = l0; yd = 0;
    xs1 = (xa+xb)/2; ys1 = (ya+yb)/2;
    xs2 = (xb+xc)/2; ys2 = (yb+yc)/2;
    xs3 = (xc+xd)/2; ys3 = (yc+yd)/2;

    % ---- 3.6 9×9 平面力平衡方程（沿用原始系数及符号） ----
    % 未知量 C = [Mb, Fr10x, Fr10y, Fr12x, Fr12y, ...
    %             Fr23x, Fr23y, Fr30x, Fr30y]'
    A = zeros(9,9);
    A(1,1)=1;
    A(1,2)=-(ys1-ya);           A(1,3)=-(xa-xs1);
    A(1,4)=-(ys1-yb);           A(1,5)=-(xb-xs1);
    A(2,2)=-1;                  A(2,4)=-1;
    A(3,3)=-1;                  A(3,5)=-1;
    A(4,4)=ys2-yb;              A(4,5)=xb-xs2;
    A(4,6)=-(ys2-yc);           A(4,7)=-(xc-xs2);
    A(5,4)=1;                   A(5,6)=-1;
    A(6,5)=1;                   A(6,7)=-1;
    A(7,6)=ys3-yc;              A(7,7)=xc-xs3;
    A(7,8)=-(ys3-yd);           A(7,9)=-(xd-xs3);
    A(8,6)=1;                   A(8,8)=-1;
    A(9,7)=1;                   A(9,9)=-1;

    B = zeros(9,1);
    B(1)=-M1;
    B(2)=-F1x;
    B(3)=-F1y+m1*g;
    B(4)=-M2;
    B(5)=-F2x;
    B(6)=-F2y+m2*g;
    B(7)=-M3;
    B(8)=-F3x;
    B(9)=-F3y+m3*g;

    if rcond(A) < singularityTol
        error('输入角 %.1f 度：力平衡矩阵接近奇异，结果不可靠。',angle_deg(k));
    end

    C = A\B;
    if any(~isfinite(C))
        error('输入角 %.1f 度：关节反力出现 NaN/Inf。',angle_deg(k));
    end

    Mb(k)=C(1);
    Fr10x(k)=C(2); Fr10y(k)=C(3);
    Fr12x(k)=C(4); Fr12y(k)=C(5);
    Fr23x(k)=C(6); Fr23y(k)=C(7);
    Fr30x(k)=C(8); Fr30y(k)=C(9);
end

%% 4. 绘图：清空旧图窗内容，避免不同测试叠加
figure(4); clf;
set(gcf,'Name','四杆机构动力学与关节反力','NumberTitle','off');

subplot(2,2,1);
plot(angle_deg,Fr10x,'k-',angle_deg,Fr10y,'k--','LineWidth',1);
title('运动副反力 F_{R10}');
xlabel('曲柄转角 \theta_1 / °'); ylabel('反力 / N');
legend('F_{R10x}','F_{R10y}','Location','best'); grid on;

subplot(2,2,2);
plot(angle_deg,Fr23x,'k-',angle_deg,Fr23y,'k--','LineWidth',1);
title('运动副反力 F_{R23}');
xlabel('曲柄转角 \theta_1 / °'); ylabel('反力 / N');
legend('F_{R23x}','F_{R23y}','Location','best'); grid on;

subplot(2,2,3);
plot(angle_deg,Fr30x,'k-',angle_deg,Fr30y,'k--','LineWidth',1);
title('运动副反力 F_{R30}');
xlabel('曲柄转角 \theta_1 / °'); ylabel('反力 / N');
legend('F_{R30x}','F_{R30y}','Location','best'); grid on;

subplot(2,2,4);
plot(angle_deg,Mb,'k-','LineWidth',1);
title('曲柄输入力矩 M_b');
xlabel('曲柄转角 \theta_1 / °'); ylabel('输入力矩 / N·m');
grid on;

%% 5. 输出简要数值摘要
fprintf('\n=== 四杆机构关节反力分析（示例参数，SI 单位）===\n');
fprintf('曲柄输入角速度：%.2f rad/s\n',omega1);
fprintf('曲柄输入力矩：最小 %.3f N·m，最大 %.3f N·m\n',min(Mb),max(Mb));
fprintf('各关节反力分量的最大绝对值：%.3f N\n', ...
    max(abs([Fr10x,Fr10y,Fr12x,Fr12y,Fr23x,Fr23y,Fr30x,Fr30y])));
fprintf('注意：质量、转动惯量和工作阻力矩尚未经 CAD/实验校验。\n');
