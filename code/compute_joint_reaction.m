
function FR = compute_joint_reaction(a1, r, x1, x2, x3, x4, Fz)
% COMPUTE_JOINT_REACTION 四杆机构关节反力计算
%
% 输入参数：
%   a1  - 曲柄转角 (rad)
%   r   - 摩擦圆半径
%   x1  - 曲柄长度
%   x2  - 连杆长度
%   x3  - 摇杆长度
%   x4  - 机架长度
%   Fz  - 外部载荷 (N)
%
% 输出参数：
%   FR(1) - 反力计算值 FRX (N)
%   FR(2) - 合反力计算值 FR0 (N)
%
% 注意：
%   1. 所有长度参数必须使用相同单位。
%   2. 假设 OC 方向竖直。
%   3. 保留原始力学计算公式，尚未独立验证物理模型。
%   4. 对 acos 输入进行浮点误差保护。

%% 1. 输入参数检查
if any([x1, x2, x3, x4] <= 0)
    error('所有杆件长度必须大于零。');
end

if r < 0
    error('摩擦圆半径不能为负数。');
end

%% 2. 计算机构几何参数

% AC 两铰接点间距离的平方
l = x1^2 + x4^2 - 2*x1*x4*cos(a1);

if l <= 0
    error('机构几何异常：AC 长度为零。');
end

AC = sqrt(l);

% 连杆与摇杆之间的夹角
cos_a3 = (x2^2 + x3^2 - l) / (2*x2*x3);
a3 = safe_acos(cos_a3);

%% 3. 计算摩擦圆相关角度

% 连杆与摩擦圆的几何夹角
cos_fai = r / (x2/2);
fai = safe_acos(cos_fai);

% 反力方向与摇杆之间的夹角
theta = a3 - fai + pi/2;

%% 4. 计算机构其余几何夹角

% 夹角 a41
cos_a41 = (l + x4^2 - x1^2) / (2*AC*x4);
a41 = safe_acos(cos_a41);

% 夹角 a42
cos_a42 = (l + x3^2 - x2^2) / (2*AC*x3);
a42 = safe_acos(cos_a42);

% 合成几何角度
a4 = a41 + a42;

% 计算反力合成所需夹角
reaction_angle = pi - a4 - theta;

%% 5. 计算机构运动反力

% 防止分母接近零
if abs(sin(theta)) < 1e-10
    error('机构处于反力计算奇异位置：sin(theta) 接近零。');
end

% 反力分量
FRX = (sin(a4) * (Fz/2)) / sin(theta);

% 合反力
FR0 = sqrt(FRX^2 + Fz^2 ...
    - 2*FRX*Fz*cos(reaction_angle));

%% 6. 输出计算结果
FR = [FRX, FR0];

end


%% 辅助函数：安全反余弦计算
function angle = safe_acos(value)
% SAFE_ACOS 防止浮点舍入误差导致 acos 返回复数
%
% 允许 1e-10 以内的数值越界。
% 如果明显超出 [-1,1]，则报告几何参数错误。

    tolerance = 1e-10;

    if any(~isfinite(value(:)))
        error('acos 输入包含 NaN 或 Inf，请检查几何参数。');
    end

    if any(abs(value(:)) > 1 + tolerance)
        error('机构几何异常：acos 输入超出 [-1,1] 范围。');
    end

    % 修正浮点舍入造成的微小越界
    value = max(-1, min(1, value));

    % 计算实数反余弦
    angle = acos(value);

end
