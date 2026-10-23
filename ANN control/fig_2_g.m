% =========================================================================
% Nature Communications Style Figure
% Panel D: Temporal-Gated Background vs. Error-Driven Early Freezing
% =========================================================================

clc; clear; close all;

%% 1. 参数与初始化
Tp = 2;               
t_end = 2.5;          
dt = 0.002;           
t = 0:dt:t_end;
N = length(t);

b1 = 12; b2 = 6;      
Gamma = 15;         
e_threshold = 0.5; % 感觉死区阈值

num_neurons = 5; % 5个神经元 

phi = @(x) [tanh(x(1)); tanh(x(2)); tanh(x(1)+x(2)); tanh(2*x(1)); tanh(2*x(2))];

%% 2. 仿真记录 (含死区控制)
x = [3.5; -2.5]; 
W = zeros(num_neurons, 1);

W_history = zeros(num_neurons, N);
e_history = zeros(1, N);

for i = 1:N
    tau = max(Tp - t(i), 0); 
    
    u = W' * phi(x);
    e = tau^2 * u + b2 * tau * x(2) + b1 * x(1);
    e_history(i) = e;
    
    if t(i) < Tp 
        % if abs(e) > e_threshold
        %     dW = -Gamma * phi(x) * e;
        % else
        %     dW = zeros(num_neurons, 1); % Early Synaptic Freezing!
        % end
        dW = -Gamma * phi(x) * e;
        W = W + dW * dt;
        x(1) = x(1) + x(2) * dt;
        x(2) = x(2) + u * dt;
    else
        % u = 0; 
        % x = [0; 0];
    end
    W_history(:, i) = W;
end

%% 3. NC 大刊级别山脊图渲染
fig = figure('Position', [150, 150, 850, 650], 'Color', 'w');
ax = axes('Position', [0.12, 0.15, 0.8, 0.75]);
hold(ax, 'on');

% --- A. 极其平滑的时间渐变背景 (Temporal Gating Background) ---
% 代表环境时钟 TTC 的无情流逝
color_start = [0.25, 0.15, 0.60]; % 起点：深邃紫
color_end   = [0.96, 0.96, 0.98]; % 终点：Tp处的纯白/微灰

num_bg_steps = 500; % 增加步数让渐变如丝绸般平滑
t_grad = linspace(0, Tp, num_bg_steps);
for k = 1:num_bg_steps-1
    ratio = k / num_bg_steps; % 严格按时间线性变化
    curr_color = color_start * (1 - ratio) + color_end * ratio;
    patch([t_grad(k), t_grad(k+1), t_grad(k+1), t_grad(k)], ...
          [-2, -2, 12, 12], curr_color, 'EdgeColor', 'none', 'HandleVisibility', 'off');
end
% Tp 之后的区域填满纯白
patch([Tp, t_end, t_end, Tp], [-2, -2, 12, 12], color_end, 'EdgeColor', 'none', 'HandleVisibility', 'off');

% --- B. 真实误差与死区线 ---
e_mag = abs(e_history);
envelope_y = e_mag * 0.15; % 缩放系数，让其不喧宾夺主
plot(t, envelope_y, 'Color', [0.85, 0.33, 0.10], 'LineWidth', 3, ...
     'LineStyle', '--', 'DisplayName', 'Internal Evaluation Error $|e(t)|$');

yline(e_threshold * 0.15, 'k:', 'LineWidth', 1.5, 'Color', [0.4 0.4 0.4], 'DisplayName', 'Sensory Threshold (Dead-zone)');

% --- C. 神经网络权重的山脊图 ---
colors = parula(num_neurons + 2); 
offset_step = 2.0; 

for k = 1:num_neurons
    w_scaled = W_history(k, :) * 0.6; 
    y_base = (k - 1) * offset_step + 1; 
    y_line = y_base + w_scaled;     
    
    fill([t, fliplr(t)], [y_line, y_base * ones(1, N)], colors(k+1,:), ...
         'FaceAlpha', 0.85, 'EdgeColor', 'none', 'HandleVisibility', 'off');
    plot(t, y_line, 'Color', colors(k+1,:), 'LineWidth', 2, 'HandleVisibility', 'off');
    
    text(-0.05, y_base + 0.3, sprintf('$\\hat{W}_{%d}$', k), ...
         'Interpreter', 'latex', 'FontSize', 14, 'FontWeight', 'bold', 'HorizontalAlignment', 'right', 'Color', [0.2 0.2 0.2]);
end

% --- D. 标注与视觉美化 ---
xline(Tp, 'k:', 'LineWidth', 2, 'DisplayName', 'Prescribed Horizon $T_p$');
text(Tp + 0.05, num_neurons * offset_step - 0.5, 'Absolute Hard-Stop', 'FontSize', 14, 'FontWeight', 'bold', 'Color', [0.85, 0.33, 0.10]);
text(Tp + 0.05, num_neurons * offset_step - 1.2, '(Execution terminated)', 'FontSize', 11, 'Color', [0.5 0.5 0.5]);

xlim([0, t_end]);
ylim([-0.2, num_neurons * offset_step + 1]);

set(ax, 'YTick', []); set(ax, 'YColor', 'none'); 
set(ax, 'XColor', [0.2 0.2 0.2], 'LineWidth', 1.2, 'FontSize', 12, 'FontName', 'Helvetica');
xlabel('Time $t$ (s)', 'Interpreter', 'latex', 'FontSize', 16);
title('Temporal Envelope vs. Early Synaptic Freezing', 'Interpreter', 'latex', 'FontSize', 18, 'FontWeight', 'bold');

lgd = legend('Interpreter', 'latex', 'FontSize', 13, 'Location', 'northeast');
set(lgd, 'Color', 'w', 'EdgeColor', 'none', 'FaceAlpha', 0.7);
box off;