function parameterized_fourbar_demo()
% PARAMETERIZED_FOURBAR_DEMO  M1：参数化四杆机构闭合与运动可视化
%
% 使用方法：在 MATLAB 中将工作目录切换至 code，然后运行
%   parameterized_fourbar_demo
%
% 修改下方 cfg 的四杆长度、曲柄起始相位、装配分支，即可观察运动变化。
% 这是独立的平面单侧四杆几何验证工具，不更改已有的计算程序与结果。
% 输出是摇杆相对于机架的几何角度，不等同于真实机翼后掠角。
% 与左右机翼的实际连接关系、CAD 铰点和零位需要进一步标定。
%
% 无第三方工具箱依赖。脚本包含局部求解函数，推荐 MATLAB R2016b 或更新版本。

%% 1. 可修改参数
cfg.crank_mm   = 100.00;   % AB：曲柄长度 (mm)
cfg.coupler_mm = 385.65;   % BC：连杆长度 (mm)
cfg.rocker_mm  = 230.19;   % DC：摇杆长度 (mm)
cfg.ground_mm  = 457.76;   % AD：机架长度 (mm)

cfg.phase_deg  = 0;        % 曲柄初始相位 (deg)
cfg.branch     = 1;        % 装配分支：+1 或 -1
cfg.samples    = 181;      % 0~360 deg 的样本数（>= 2）
cfg.animate    = true;     % 是否播放运动
cfg.pause_s    = 0.01;     % 每帧停留时间 (s)

%% 2. 输入检查和闭合可行性
lengths = [cfg.crank_mm, cfg.coupler_mm, cfg.rocker_mm, cfg.ground_mm];
if any(~isfinite(lengths)) || any(lengths <= 0)
    error('四杆长度必须是有限的正数（单位：mm）。');
end
if ~ismember(cfg.branch, [-1, 1])
    error('cfg.branch 必须为 +1 或 -1。');
end
if ~isfinite(cfg.phase_deg) || ~isscalar(cfg.samples) || ...
        cfg.samples < 2 || cfg.samples ~= round(cfg.samples)
    error('检查曲柄相位及采样数设置。');
end
if ~isscalar(cfg.pause_s) || ~isfinite(cfg.pause_s) || cfg.pause_s < 0
    error('cfg.pause_s 必须是非负有限数。');
end

a = cfg.crank_mm; b = cfg.coupler_mm;
c = cfg.rocker_mm; d = cfg.ground_mm;
tol = 1e-9 * max(lengths);
dist_min = abs(d - a);
dist_max = d + a;
if dist_max > (b + c + tol) || dist_min < (abs(b - c) - tol)
    error('当前杆长无法支持完整 360 度曲柄运动，请调整长度参数。');
end

%% 3. 几何闭合求解（两圆交点）
input_deg = linspace(0, 360, cfg.samples);
theta = (input_deg + cfg.phase_deg) * pi / 180;
A = [0; 0];
D = [d; 0];
B = zeros(2, cfg.samples);
C = zeros(2, cfg.samples);
rocker_rad = zeros(1, cfg.samples);
max_residual_mm = 0;

for k = 1:cfg.samples
    B(:, k) = A + a * [cos(theta(k)); sin(theta(k))];
    [C(:, k), residual] = solve_rocker_point(B(:, k), D, b, c, cfg.branch, tol);
    rocker_rad(k) = atan2(C(2, k) - D(2), C(1, k) - D(1));
    max_residual_mm = max(max_residual_mm, residual);
end

rocker_deg = unwrap(rocker_rad) * 180 / pi;
fprintf('M1 parameterized four-bar demo\n');
fprintf('Input rotation: %.1f to %.1f deg\n', input_deg(1), input_deg(end));
fprintf('Rocker angle range: %.3f to %.3f deg (geometry reference)\n', ...
    min(rocker_deg), max(rocker_deg));
fprintf('Maximum closure residual: %.3e mm\n', max_residual_mm);

%% 4. 绘图（左侧机构、右侧摇杆响应）
fig = figure('Name', 'Parameterized four-bar mechanism (M1)', ...
    'NumberTitle', 'off', 'Color', 'w');

ax1 = subplot(1, 2, 1, 'Parent', fig);
hold(ax1, 'on');
plot(ax1, [A(1), D(1)], [A(2), D(2)], 'k-', 'LineWidth', 2);
hCrank   = plot(ax1, [A(1), B(1, 1)], [A(2), B(2, 1)], ...
    'b-o', 'LineWidth', 2);
hCoupler = plot(ax1, [B(1, 1), C(1, 1)], [B(2, 1), C(2, 1)], ...
    'g-o', 'LineWidth', 2);
hRocker  = plot(ax1, [D(1), C(1, 1)], [D(2), C(2, 1)], ...
    'r-o', 'LineWidth', 2);
plot(ax1, [A(1), D(1)], [A(2), D(2)], 'ko', 'MarkerFaceColor', 'k');
axis(ax1, 'equal');
margin = a + b + c;
axis(ax1, [-margin, d + margin, -margin, margin]);
grid(ax1, 'on');
xlabel(ax1, 'x (mm)'); ylabel(ax1, 'y (mm)');
title(ax1, 'Single-side planar linkage');
legend(ax1, {'Ground AD', 'Crank AB', 'Coupler BC', 'Rocker DC'}, ...
    'Location', 'best');

ax2 = subplot(1, 2, 2, 'Parent', fig);
plot(ax2, input_deg, rocker_deg, 'b-', 'LineWidth', 1.5);
hold(ax2, 'on');
hMarker = plot(ax2, input_deg(1), rocker_deg(1), 'ro', ...
    'MarkerFaceColor', 'r');
grid(ax2, 'on');
xlabel(ax2, 'Crank increment (deg)');
ylabel(ax2, 'Rocker angle (deg)');
title(ax2, 'Angular response (not wing sweep)');
xlim(ax2, [0, 360]);

%% 5. 播放机构运动
if cfg.animate
    frame_indices = 1:cfg.samples;
else
    frame_indices = 1;
end
for k = frame_indices
    if ~ishandle(fig)
        break;
    end
    set(hCrank,   'XData', [A(1), B(1, k)], ...
        'YData', [A(2), B(2, k)]);
    set(hCoupler, 'XData', [B(1, k), C(1, k)], ...
        'YData', [B(2, k), C(2, k)]);
    set(hRocker,  'XData', [D(1), C(1, k)], ...
        'YData', [D(2), C(2, k)]);
    set(hMarker, 'XData', input_deg(k), 'YData', rocker_deg(k));
    drawnow;
    if cfg.animate && cfg.pause_s > 0
        pause(cfg.pause_s);
    end
end
end

function [C, residual] = solve_rocker_point(B, D, b, c, branch, tol)
% 两圆交点：以 B 为圆心半径 b，以 D 为圆心半径 c。
v = D - B;
L = norm(v);
if L <= tol || L > b + c + tol || L < abs(b - c) - tol
    error('机构无法闭合或处于退化几何位置。');
end

u = v / L;
offset = (b^2 - c^2 + L^2) / (2 * L);
height_sq = b^2 - offset^2;
if height_sq < -tol * max(b, c)
    error('两圆无实数交点，请检查机构尺寸。');
end
height = sqrt(max(height_sq, 0));
n = [-u(2); u(1)];
C = B + offset * u + branch * height * n;

residual = max(abs(norm(C - B) - b), abs(norm(C - D) - c));
if ~isfinite(residual) || residual > max(1e-7, 1e-8 * max(b, c))
    error('四杆几何闭合残差超出容差。');
end
end
