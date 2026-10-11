% PLOT_RELATIVE_LINKAGE_KINEMATICS 双侧四杆机构相对运动曲线
% 对两侧连杆进行 0..360° 扫描，计算并展示角位移、角速度和角加速度。
% 用法: plot_relative_linkage_kinematics
% 说明: 修复原 alpha2 输入/输出变量冲突，补记角度序列；曲柄相位分段公式仍沿用原文件、待验证。
% 来源: 用户提供的旧版 MATLAB 程序；重命名及注释整理版本。

clear; clc;
l1=100; l2=385.65; l3=230.19; l4=457.79;
omega1=100;
alpha1=0;%初始时的角加速度
alpha_input_side_b=0; % 第二侧驱动角加速度（常数，原文件 alpha2 与输出数组同名）
hd=pi/180;%转换为弧度制
du=180/pi;%转换为角度制

% 调用子函数计算机构位移，角速度，角加速度
for x=1:361
   theta01=(x-1)*hd;
   theta01_history(x)=theta01; % 记录整段曲柄角度，供相对位移绘图
   [theta,omega,alpha]=solve_side_a_kinematics(theta01,omega1,alpha1,l1,l2,l3,l4);
   theta2(x)=theta(1);theta3(x)=theta(2);
   omega2(x)=omega(1);omega3(x)=omega(2);
   alpha2(x)=alpha(1);alpha3(x)=alpha(2);%分别求2，3杆的运动特征参数

   % 原输入角关系；原脚本将弧度 theta01 与数字 106 比较。
   % 这一角度阈值可能应为 106*hd，但会改变曲线与运动分支，故暂按原式保留。
   theta02=106*hd-theta01;
if theta01<106 
   theta02=theta01-106*hd;
end
   theta02_history(x)=theta02; % 记录第二侧曲柄角度
   [theta,omega,alpha]=solve_side_b_kinematics(theta02,omega1,alpha_input_side_b,l1,l2,l3,l4);
   theta4(x)=theta(1);theta5(x)=theta(2);
   omega4(x)=omega(1);omega5(x)=omega(2);
   alpha4(x)=alpha(1);alpha5(x)=alpha(2);%分别求4，5杆的运动特征参数

end


x=0:360; % 对应 theta01 = 0°..360° 的真实角度横轴
% 图 1：相对运动指标
subplot(3,2,1);    % 相对位移图
plot(x,theta01_history*du-theta3*du,'k',x,theta2*du-theta3*du,'k--');
title('相对角位移图');
xlabel('曲柄转角 \theta_1 / \circ')
ylabel('角位移 / \circ')
legend('theta13','theta23')
grid on; hold on;

    
% 图 2：相对运动指标
subplot(3,2,2);    % 相对角速度图
plot(x,omega1-omega3,'k',x,omega2-omega3,'k--')
title('相对角速度图');
xlabel('曲柄转角 \theta_1 / \circ')
ylabel('角速度 / rad\cdots^{-1}')
legend('omega13','omega23')
grid on;hold on;

    
% 图 3：相对运动指标
subplot(3,2,3);   % 2，3杆角加速度图
plot(x,alpha2-alpha3,'k')
title('杆2，3相对角加速度图');
xlabel('曲柄转角 \theta_1 / \circ')
ylabel('角加速度 / rad\cdots^{-2}')
grid on;hold on;


% 图 4：相对运动指标
subplot(3,2,4);   % 相对位移图
plot(x,theta02_history*du-theta4*du,'k',x,theta4*du-theta5*du,'k--');
title('B侧相对角位移图');
xlabel('曲柄转角 \theta_1 / \circ')
ylabel('角位移 / \circ')
legend('theta24','theta45')
grid on; hold on;


% 图 5：相对运动指标
subplot(3,2,5);    % 相对角速度图
plot(x,omega1-omega4,'k',x,omega4-omega5,'k--')
title('角速度图');
xlabel('曲柄转角 \theta_1 / \circ')
ylabel('角速度 / rad\cdots^{-1}')
legend('omega24','omega45')
grid on;hold on;

    
% 图 6：相对运动指标
subplot(3,2,6);    % 4，5杆角加速度图
plot(x,alpha4-alpha5,'k')
title('杆4，5角加速度图');
xlabel('曲柄转角 \theta_1 / \circ')
ylabel('角加速度 / rad\cdots^{-2}')
grid on;hold on;
