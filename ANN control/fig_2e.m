% =========================================================================
% Nature Communications Style Figure
% Panel C: The Singular Control Landscape of Traditional PTC (Real Trajectories)
% 引入微小测量噪声，揭示 PTC 致命的工程奇异性 (Engineering Singularity)
% =========================================================================
clc; clear; close all;

%% 1. 参数初始化
Tp = 2;               
t_end = 2.0; 
dt = 0.002;           
t = 0:dt:t_end;
N = length(t);
b1 = 12;  
b2 = 6;   

%% 2. 构建闭环初始状态群
num_traj = 40; 
theta = linspace(0, 2*pi, num_traj + 1);
theta(end) = []; 
R1 = 3.5; 
R2 = 4.5; 
X0_set = [R1 * cos(theta)', R2 * sin(theta)'];

X1_all = zeros(num_traj, N);
X2_all = zeros(num_traj, N);
U_all  = zeros(num_traj, N); 



%% 3. 核心仿真循环 (Traditional PTC with Micro-Noise)
for j = 1:num_traj
    x = X0_set(j, :)';
    for i = 1:N
        X1_all(j, i) = x(1);
        X2_all(j, i) = x(2);
        
        tau = max(Tp - t(i), 1e-4); 

            noise = [0.01 * randn(); 0.05 * randn()];
    % xm_tel = x_tel + noise; 
    x_meas = x + noise;
        
        % 引入传感器的高频微小噪声
        % x_meas = x + noise_amp * [sin(50 * t(i)); cos(50 * t(i))];
        
        % 传统 PTC 控制律：分母的黑洞开始吞噬微小的测量误差
        u_ptc = -(b1 * x_meas(1) + b2 * tau * x_meas(2)) / (tau^2);
        
        % 真实工程限幅
        u_ptc = max(min(u_ptc, 60), -60);
        
        U_all(j, i) = u_ptc; 
        
        x(1) = x(1) + x(2) * dt;
        x(2) = x(2) + u_ptc * dt;
    end
end

X1_all(end+1, :) = X1_all(1, :);
X2_all(end+1, :) = X2_all(1, :);
U_all(end+1, :)  = U_all(1, :);

%% 4. 3D 渲染 (Aesthetic 3D Rendering - 终极红金火山质感)
fig = figure('Position', [100, 100, 950, 750], 'Color', 'w');
axes1 = axes('Parent', fig);
hold(axes1, 'on');
view(axes1, [-38, 25]);
grid(axes1, 'on');

% --- 核心修改：极致亮眼的红金火山色与材质强化 ---
% 提升 AmbientStrength (环境光) 和 DiffuseStrength (漫反射)，彻底消除灰色重叠阴影
surf(X1_all, X2_all, U_all, ...
    'FaceColor', [1.00, 0.25, 0.05], 'FaceAlpha', 0.85, ...
    'EdgeColor', 'none', 'DisplayName', 'PTC Trajectories under Micro-noise', ...
    'AmbientStrength', 0.65, 'DiffuseStrength', 0.8, 'SpecularStrength', 0.4);

% 绘制原点垂直辅助线 (理想的死停目标)
plot3([0 0], [0 0], [-60 60], 'k--', 'LineWidth', 2, 'HandleVisibility', 'off');

%% 5. 坐标轴与光影美化 (Aesthetics Formatting)
zlim([-60, 60]); 
xlim([-4, 4]); ylim([-5, 5]);

xlabel('Position $x_1$', 'Interpreter', 'latex', 'FontSize', 16);
ylabel('Velocity $x_2$', 'Interpreter', 'latex', 'FontSize', 16);
zlabel('Control Input $u$', 'Interpreter', 'latex', 'FontSize', 16);
title('Singular Execution Cone of Traditional PTC (with noise)', 'Interpreter', 'latex', 'FontSize', 18, 'FontWeight', 'bold');

set(axes1, 'FontSize', 12, 'FontName', 'Helvetica', 'LineWidth', 1.2, ...
    'XColor', [0.2 0.2 0.2], 'YColor', [0.2 0.2 0.2], 'ZColor', [0.2 0.2 0.2], ...
    'GridAlpha', 0.15, 'Box', 'on');

lgd = legend('Interpreter', 'latex', 'FontSize', 14, 'Location', 'northeast');
set(lgd, 'Color', 'w', 'EdgeColor', [0.8 0.8 0.8]);

% --- 光影重构：引爆火山 ---
% 使用双侧补光，抛弃 dull 材质，拥抱闪耀的岩浆质感 (shiny)！
camlight('headlight'); 
camlight('right'); 
lighting gouraud; 
material shiny;