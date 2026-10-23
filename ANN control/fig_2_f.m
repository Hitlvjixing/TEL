% =========================================================================
% Nature Communications Style Figure
% Fig.2f  a single representative trajectory
% Comparing TEL vs Traditional PTC with Measurement Noise
% 
% =========================================================================

clc; clear; close all;

%% 1. 参数与初始化
Tp = 2;               % 预设收敛时间
t_end = 2.5;          
dt = 0.001;           
t = 0:dt:t_end;
N = length(t);

b1 = 12; b2 = 6;      % 拓扑常数
Gamma = 20;          % TEL 学习率
num_neurons = 5;      
phi = @(x) [tanh(x(1)); tanh(x(2)); tanh(x(1)+x(2)); tanh(2*x(1)); tanh(2*x(2))];

% 初始状态 (选取一条具有代表性的挑战性轨迹)
x0 = [3; -2]; 

% 存储矩阵
U_TEL = zeros(1, N);
U_PTC = zeros(1, N);

%% 2. 独立闭环仿真 (含测量噪声)
x_tel = x0;
x_ptc = x0;
W = zeros(num_neurons, 1);

% 设定物理执行器的饱和极限 (Actuator Saturation Limits)
U_max = 15; 

for i = 1:N
    tau = max(Tp - t(i), 0);
    
    % --- 注入高斯测量噪声 (Measurement Noise) ---
    % 位置噪声标准差 0.01, 速度噪声标准差 0.05
    noise = [0.01 * randn(); 0.05 * randn()];
    xm_tel = x_tel + noise; 
    xm_ptc = x_ptc + noise;
    
    % =========================================================
    % Controller A: TEL Framework (Neural Spatial Feedback)
    % =========================================================
    u_tel = W' * phi(xm_tel);
    U_TEL(i) = u_tel;
    
    % if tau > 0.001
        e = tau^2 * u_tel + b2 * tau * xm_tel(2) + b1 * xm_tel(1);
        dW = -Gamma *  phi(xm_tel) * e;%tau^2 *
        W = W + dW * dt;
    % end
    if t(i) >= Tp
        % U_TEL(i) = 0; % 死停
        % x_tel = [0; 0];
    else
        x_tel(1) = x_tel(1) + x_tel(2) * dt;
        x_tel(2) = x_tel(2) + max(min(u_tel, U_max), -U_max) * dt; % 施加截断力
    end
    
    % =========================================================
    % Controller B: Traditional PTC (Analytical Time-Varying)
    % =========================================================
    tau_ptc = max(Tp - t(i), 0.005); % 限制分母最小极值防软件崩溃
    
    % 传统控制公式：微小的噪声 xm_ptc 会被 tau^2 恐怖放大
    u_ptc = -(b1 * xm_ptc(1) + b2 * tau_ptc * xm_ptc(2)) / (tau_ptc^2);
    U_PTC(i) = u_ptc;
    
    if t(i) >= Tp
        U_PTC(i) = 0;
        x_ptc = [0; 0];
    else
        % PTC在物理系统同样受到饱和截断 (导致其失去精确收敛能力)
        x_ptc(1) = x_ptc(1) + x_ptc(2) * dt;
        x_ptc(2) = x_ptc(2) + max(min(u_ptc, U_max), -U_max) * dt; 
    end
end

%% 3. NC 大刊级别高定 2D 绘图 (Aesthetic 2D Rendering)
fig = figure('Position', [150, 150, 900, 500], 'Color', 'w');

% 主绘图区
ax_main = axes('Position', [0.1, 0.15, 0.85, 0.8]);
hold(ax_main, 'on'); 
% grid(ax_main, 'on');

% (1) 绘制执行器饱和阴影区 (Actuator Saturation Area)
patch([0, t_end, t_end, 0], [U_max, U_max, 40, 40], [0.9 0.9 0.9], 'EdgeColor', 'none', 'FaceAlpha', 0.5, 'HandleVisibility', 'off');
patch([0, t_end, t_end, 0], [-U_max, -U_max, -40, -40], [0.9 0.9 0.9], 'EdgeColor', 'none', 'FaceAlpha', 0.5, 'HandleVisibility', 'off');

% 标注安全边界线
yline(U_max, 'k--', 'LineWidth', 1.5, 'Color', [0.4 0.4 0.4], 'DisplayName', 'Actuator saturation limit');
yline(-U_max, 'k--', 'LineWidth', 1.5, 'Color', [0.4 0.4 0.4], 'HandleVisibility', 'off');
text(0.1, U_max+2, 'Hardware Damage Zone (Saturated)', 'FontSize', 20, 'Color', [0.5 0.5 0.5]);

% (2) 绘制传统 PTC 信号 (红色爆炸)
plot(t, U_PTC, 'Color', [0.85, 0.33, 0.10, 0.8], 'LineWidth', 1.5, 'DisplayName', 'Traditional PTC (Noise Explosion)');

% (3) 绘制 TEL 信号 (深青色平滑)
plot(t, U_TEL, 'Color', [0.00, 0.60, 0.50], 'LineWidth', 2.5, 'DisplayName', 'TEL neural control (Safe)');

% 标注时间奇点
xline(Tp, 'k:', 'LineWidth', 2, 'DisplayName', 'Prescribed time $T_p$');

% 坐标轴与范围设置
xlim([0, t_end]);
ylim([-35, 35]); % 故意留大空间展示 PTC 的爆炸
xlabel('Time (s)', 'Interpreter', 'latex', 'FontSize', 20);
ylabel('Control Input $u$', 'Interpreter', 'latex', 'FontSize', 20);
% title('Actuator Safety & Singularity Evasion under Measurement Noise', 'Interpreter', 'latex', 'FontSize', 18, 'FontWeight', 'bold');

set(ax_main, 'FontSize', 12, 'FontName', 'Helvetica', 'LineWidth', 1.2, ...
    'XColor', [0.2 0.2 0.2], 'YColor', [0.2 0.2 0.2], 'GridAlpha', 0.2, 'Box', 'on');

lgd = legend('Interpreter', 'latex', 'FontSize', 20, 'Location', 'northwest');
set(lgd, 'Color', 'w', 'EdgeColor', 'k');

%% 4. 画龙点睛：局部放大镜 (The Inset Plot for Microsecond Smoothness)
% 在右侧空白处放置放大图
ax_inset = axes('Position', [0.55, 0.6, 0.35, 0.25]); 
hold(ax_inset, 'on'); box(ax_inset, 'on');

% 定义放大的时间窗口
t_zoom_idx = (t >= Tp - 0.08) & (t <= Tp + 0.08);
plot(ax_inset, t(t_zoom_idx), U_PTC(t_zoom_idx), 'Color', [0.85, 0.33, 0.10, 0.5], 'LineWidth', 1);
plot(ax_inset, t(t_zoom_idx), U_TEL(t_zoom_idx), 'Color', [0.00, 0.60, 0.50], 'LineWidth', 2.5);
xline(ax_inset, Tp, 'k:', 'LineWidth', 1.5);

xlim(ax_inset, [Tp - 0.08, Tp + 0.08]);
ylim(ax_inset, [-2, 2]); % 放大 TEL 的平滑细节
set(ax_inset, 'FontSize', 10, 'Color', [0.98 0.98 0.98]);
title(ax_inset, 'Microsecond Dead-Stop Detail', 'FontSize', 20, 'FontWeight', 'normal');

% 画连接线 (Connect main plot to inset)
annotation('line', [0.73 0.55], [0.15 0.6], 'Color', [0.5 0.5 0.5], 'LineStyle', '--');
annotation('line', [0.82 0.9], [0.15 0.6], 'Color', [0.5 0.5 0.5], 'LineStyle', '--');