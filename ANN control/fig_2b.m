% =========================================================================
% Nature Communications Style Figure
% 3D Spatiotemporal Convergence Cone (Topological Manifold Contraction)
% Plant: Second-Order Pure Integrator (Pure TEL Framework, NO SMC)
% =========================================================================

clc; clear; close all;

%% 1. 参数初始化 (Parameter Initialization)
Tp = 2;               % 预设收敛时间
t_end = 2.5;          % 总仿真时间
dt = 0.002;           % 仿真步长 (稍微调大一点点方便曲面渲染)
t = 0:dt:t_end;
N = length(t);

% 拓扑常数 (Derived from inverse-dynamics topological balance)
b1 = 12;  
b2 = 6;   

% 神经网络与学习参数
Gamma = 20;          % 学习率 
num_neurons = 5;      
% 零偏激活函数 (Zero-biased basis functions)
phi = @(x) [tanh(x(1)); tanh(x(2)); tanh(x(1)+x(2)); tanh(2*x(1)); tanh(2*x(2))];

%% 2. 构建闭环初始状态群 (Closed-loop Initial Conditions)
num_traj = 40; % 采样40条轨迹构成曲面
theta = linspace(0, 2*pi, num_traj + 1);
theta(end) = []; % 去掉最后一个点以免重复，我们在画图时手动闭合

% 在相平面上定义一个椭圆作为初始边界
R1 = 3.5; % x1 的半径
R2 = 4.5; % x2 的半径
X0_set = [R1 * cos(theta)', R2 * sin(theta)'];

% 数据存储矩阵
X1_all = zeros(num_traj, N);
X2_all = zeros(num_traj, N);

%% 3. 核心仿真循环 (Pure TEL Simulation Loop)
for j = 1:num_traj
    x = X0_set(j, :)';
    W = zeros(num_neurons, 1); % 初始权重为0
    
    for i = 1:N
        % 记录数据
        X1_all(j, i) = x(1);
        X2_all(j, i) = x(2);
        
        tau = max(Tp - t(i), 0); % 剩余时间 TTC
        
        % 执行层 - 纯空间状态反馈，绝对无奇异
        u = W' * phi(x);
        
        % 学习层 - 时间门控的内部误差评价
        % if tau > 0.001 % 在接近 Tp 时平滑冻结
            e = tau^2 * u + b2 * tau * x(2) + b1 * x(1);
            dW = -Gamma  * phi(x) * e; %* tau^2
            W = W + dW * dt;
        % end
        
        
        % 物理系统更新: 纯积分器 x1_dot = x2, x2_dot = u
        if i < N
            x(1) = x(1) + x(2) * dt;
            x(2) = x(2) + u * dt;
        end
    end
end

%% 4. 生成闭合曲面数据 (Closing the 3D Tube for Surface Rendering)
% 把第一条轨迹拼接到最后一条，形成一个完美闭合的管状曲面
X1_surf = [X1_all; X1_all(1, :)];
X2_surf = [X2_all; X2_all(1, :)];
T_surf  = repmat(t, num_traj + 1, 1);

%% 5. NC 大刊级别 3D 渲染 (Aesthetic 3D Rendering)
fig = figure('Position', [100, 100, 900, 800], 'Color', 'w');
axes1 = axes('Parent', fig);
hold(axes1, 'on');
view(axes1, [-38, 22]); % 调整至极佳的3D观察视角
grid(axes1, 'on');

% (1) 绘制半透明的收敛锥面 (Spatiotemporal Convergence Cone)
% 降低时间维度上的网格密度，使得曲面看起来更清爽
downsample_rate = 5; 
idx = 1:downsample_rate:N;

surf(X1_surf(:, idx), X2_surf(:, idx), T_surf(:, idx), ...
     'EdgeColor', 'none', ...          % 去掉生硬的网格线
     'FaceAlpha', 0.85, ...            % 设置半透明度
     'FaceLighting', 'gouraud', ...    % 高级平滑光照
     'AmbientStrength', 0.4);          % 环境光强度

% 设置具有时间渐变感的高级 Colormap (深海蓝 -> 亮金黄)
colormap(parula); 

% (2) 挑选几条代表性的骨架轨迹加粗显示 (Guiding Trajectories)
num_guides = 6;
guide_idx = round(linspace(1, num_traj, num_guides+1));
for j = 1:num_guides
    plot3(X1_all(guide_idx(j), :), X2_all(guide_idx(j), :), t, ...
          'LineWidth', 1.5, 'Color', 'c', 'HandleVisibility', 'off');
end

% (3) 绘制半透明的时空剖面平面 (Temporal Horizon Plane at Z = Tp)
plane_x = [-5, 5, 5, -5];
plane_y = [-6, -6, 6, 6];
plane_z = [Tp, Tp, Tp, Tp];
patch('XData', plane_x, 'YData', plane_y, 'ZData', plane_z, ...
      'FaceColor', [0.7, 0.7, 0.7], 'FaceAlpha', 0.3, ...
      'EdgeColor', 'none', 'HandleVisibility', 'off');

% (4) 标注初始状态边界环 (Initial State Boundary)
plot3(X1_surf(:,1), X2_surf(:,1), zeros(num_traj+1, 1), ...
      'LineWidth', 3, 'Color', 'c', 'DisplayName', 'Initial Boundary');

% (5) 标注汇聚奇点与死停线 (The Dead-stop)
scatter3(0, 0, Tp, 150, 'p', 'MarkerEdgeColor', 'b', 'MarkerFaceColor', [1 0.8 0], ...
         'LineWidth', 1.5, 'DisplayName', 'Temporal Convergence Point');
plot3([0, 0], [0, 0], [Tp, t_end], 'LineWidth', 3, 'Color', [0.85, 0.33, 0.10], ...
      'DisplayName', 'Post-convergence State');

% (6) 坐标轴与外观设置 (Aesthetics formatting)
xlabel('Position $x_1$', 'Interpreter', 'latex', 'FontSize', 16);
ylabel('Velocity $x_2$', 'Interpreter', 'latex', 'FontSize', 16);
zlabel('Time (s)', 'Interpreter', 'latex', 'FontSize', 16);
title('Topological Contraction of the Convergence Cone', ...
      'Interpreter', 'latex', 'FontSize', 18, 'FontWeight', 'bold');

xlim([-5, 5]); ylim([-6, 6]); zlim([0, t_end]);

% 设置坐标轴属性
set(axes1, 'FontSize', 16, 'FontName', 'Helvetica', 'LineWidth', 1.2, ...
    'XColor', [0.2 0.2 0.2], 'YColor', [0.2 0.2 0.2], 'ZColor', [0.2 0.2 0.2], ...
    'GridAlpha', 0.2, 'Box', 'on');

% 图例
lgd = legend('Interpreter', 'latex', 'FontSize', 13, 'Location', 'northeast');
set(lgd, 'Color', 'none', 'EdgeColor', 'none');

% (7) 打光渲染增强 (Lighting & Rendering)
camlight('headlight'); 
camlight('left');
material shiny; % 增加曲面反光的高级质感