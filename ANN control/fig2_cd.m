% =========================================================================
% Nature Communications Style Figure
% Panel B: The Singularity-Free Control Landscape based on REAL Trajectories
% Plant: Second-Order Pure Integrator (Pure TEL Framework, NO SMC)
% =========================================================================

clc; clear; close all;
%有噪声 
%% 1. 参数初始化 (Parameter Initialization)
Tp = 2;               
t_end = 2.5;          
dt = 0.002;           
t = 0:dt:t_end;
N = length(t);

% 拓扑常数
b1 = 12;  
b2 = 6;   

% 神经网络与学习参数
Gamma = 20;          
num_neurons = 5;      
phi = @(x) [tanh(x(1)); tanh(x(2)); tanh(x(1)+x(2)); tanh(2*x(1)); tanh(2*x(2))];

%% 2. 构建闭环初始状态群 (Closed-loop Initial Conditions)
num_traj = 40; 
theta = linspace(0, 2*pi, num_traj + 1);
theta(end) = []; 

R1 = 3.5; % x1 初始边界
R2 = 4.5; % x2 初始边界
X0_set = [R1 * cos(theta)', R2 * sin(theta)'];

% 数据存储矩阵
X1_all = zeros(num_traj, N);
X2_all = zeros(num_traj, N);
U_all  = zeros(num_traj, N); % 记录真实的控制输入 u
W_final_all = zeros(num_traj, num_neurons); % 记录收敛时的真实权重


%% 3. 核心仿真循环 (Pure TEL Simulation Loop)
for j = 1:num_traj
    x = X0_set(j, :)';
    W = zeros(num_neurons, 1); 
    % Gamma =1+ 5 * t(i);    
    for i = 1:N
        X1_all(j, i) = x(1);
        X2_all(j, i) = x(2);
        
        tau = max(Tp - t(i), 0); 
        % x_meas = x + noise_amp * [sin(50 * t(i)); cos(50 * t(i))];
        noise = [0.01 * randn(); 0.05 * randn()];
        x_meas = x + 0*noise;
        % 执行层 - 真实的纯空间状态反馈
        u = W' * phi(x_meas);
        U_all(j, i) = u; % 记录真实控制量
        
        % 学习层
        % if tau > 0.0001 
            e = tau^2 * u + b2 * tau * x_meas(2) + b1 * x_meas(1);
            dW = -Gamma  * phi(x_meas) * e;%* tau^2
            W = W + dW * dt;
        % end

        
        if i < N
            x(1) = x(1) + x(2) * dt;
            x(2) = x(2) + u * dt;
        end
    end
    % 记录该条轨迹冻结时的真实网络权重
    W_final_all(j, :) = W';
end

%% 4. 提取真实训练结果并生成控制曲面 (Generate Surfaces from Real Data)
% 取 40 条轨迹学到的权重的平均值，作为该系统的宏观拓扑流形特征
W_trained_mean = mean(W_final_all, 1)'; 

% 生成相平面网格
x_range = linspace(-4, 4, 100);
y_range = linspace(-5, 5, 100);
[X1_grid, X2_grid] = meshgrid(x_range, y_range);

% (1) 真实学到的 TEL 神经网络曲面 (蓝色底层流形)
U_NN = zeros(size(X1_grid));
for i = 1:numel(X1_grid)
    U_NN(i) = W_trained_mean' * phi([X1_grid(i); X2_grid(i)]);
end

% (2) 传统 PTC 控制曲面 (红色尖刺奇点)
R_grid = sqrt(X1_grid.^2 + X2_grid.^2);
tau_grid = max(0.4 * R_grid, 0.05); % 限制下限以防止渲染崩溃
U_Trad = -(b1 * X1_grid + b2 * tau_grid .* X2_grid) ./ (tau_grid.^2);

% (3) 生成真实执行漏斗曲面数据 (Closing the Cone for Actual Trajectories)
% 截取 t=0 到 t=Tp 的部分，避开死停后的0点，并拼接第一条闭合曲面
valid_idx = 1:sum(t <= Tp);
X1_surf = [X1_all(:, valid_idx); X1_all(1, valid_idx)];
X2_surf = [X2_all(:, valid_idx); X2_all(1, valid_idx)];
U_surf  = [U_all(:, valid_idx);  U_all(1, valid_idx)];

%% 5. 3D 渲染 (Aesthetic 3D Rendering)
fig = figure('Position', [100, 100, 950, 750], 'Color', 'w');
axes1 = axes('Parent', fig);
hold(axes1, 'on');
view(axes1, [-38, 25]);
grid(axes1, 'on');

% --- A. 绘制传统 PTC 曲面 (红色尖刺) ---
surf(X1_grid, X2_grid, U_Trad, ...
    'FaceColor', [0.85, 0.33, 0.10], 'FaceAlpha', 0.5, ...
    'EdgeColor', 'none', 'DisplayName', 'Traditional PTC (Singular Abyss)');

% --- B. 绘制基于真实权重的 TEL 神经网络曲面 (蓝色平滑面) ---
surf(X1_grid, X2_grid, U_NN, ...
    'FaceColor', [0.00, 0.45, 0.70], 'FaceAlpha', 0.8, ...
    'EdgeColor', 'none', 'DisplayName', 'TEL Neural Spatial Manifold');

zlim([-60, 60]); 
xlim([-4, 4]); ylim([-5, 5]);

xlabel('Position $x_1$', 'Interpreter', 'latex', 'FontSize', 16);
ylabel('Velocity $x_2$', 'Interpreter', 'latex', 'FontSize', 16);
zlabel('Control Input $u$', 'Interpreter', 'latex', 'FontSize', 16);
title('Singularity-Free Execution Cone over Neural Landscape', 'Interpreter', 'latex', 'FontSize', 18, 'FontWeight', 'bold');

set(axes1, 'FontSize', 12, 'FontName', 'Helvetica', 'LineWidth', 1.2, ...
    'XColor', [0.2 0.2 0.2], 'YColor', [0.2 0.2 0.2], 'ZColor', [0.2 0.2 0.2], ...
    'GridAlpha', 0.15, 'Box', 'on');

lgd = legend('Interpreter', 'latex', 'FontSize', 13, 'Location', 'northeast');
set(lgd, 'Color', 'none', 'EdgeColor', [0.8 0.8 0.8]);

% 打光与高级材质渲染
camlight('headlight'); camlight('left');
lighting gouraud; material dull;

% --- C. 绘制真实的物理执行漏斗曲面 (The Real Executed Spatiotemporal Cone) ---
% 降低时间维度上的网格密度，使得曲面看起来更清爽
fig1 = figure('Position', [100, 100, 950, 750], 'Color', 'w');
axes1 = axes('Parent', fig1);
hold(axes1, 'on');
view(axes1, [-38, 25]);
grid(axes1, 'on');
downsample_rate = 5; 
idx = 1:downsample_rate:length(valid_idx);

surf(X1_surf(:, idx), X2_surf(:, idx), U_surf(:, idx), ...
     'FaceColor', [0.00, 0.45, 0.70], ... % 高级琥珀金
     'FaceAlpha', 0.95, ...               % 几乎不透明，凸显实体感
     'EdgeColor', 'none', ...
     'FaceLighting', 'gouraud', ...
     'DisplayName', 'Actual Physical Execution Cone');
scatter3(0, 0, 0, 150, 'p', 'MarkerEdgeColor', 'r', 'MarkerFaceColor', [1 0.8 0], ...
         'LineWidth', 1.5, 'DisplayName', 'Temporal Convergence Point');
% 绘制原点辅助线
plot3([0 0], [0 0], [-80 80], 'k--', 'LineWidth', 3, 'HandleVisibility', 'off');

%% 6. 坐标轴与视觉美化 (Aesthetics Formatting)
zlim([-60, 60]); 
xlim([-4, 4]); ylim([-5, 5]);

xlabel('Position $x_1$', 'Interpreter', 'latex', 'FontSize', 16);
ylabel('Velocity $x_2$', 'Interpreter', 'latex', 'FontSize', 16);
zlabel('Control Input $u$', 'Interpreter', 'latex', 'FontSize', 16);
title('Singularity-Free Execution Cone over Neural Landscape', 'Interpreter', 'latex', 'FontSize', 18, 'FontWeight', 'bold');

set(axes1, 'FontSize', 12, 'FontName', 'Helvetica', 'LineWidth', 1.2, ...
    'XColor', [0.2 0.2 0.2], 'YColor', [0.2 0.2 0.2], 'ZColor', [0.2 0.2 0.2], ...
    'GridAlpha', 0.15, 'Box', 'on');

lgd = legend('Interpreter', 'latex', 'FontSize', 13, 'Location', 'northeast');
set(lgd, 'Color', 'none', 'EdgeColor', [0.8 0.8 0.8]);

% 打光与高级材质渲染
camlight('headlight'); camlight('left');
lighting gouraud; material dull;


