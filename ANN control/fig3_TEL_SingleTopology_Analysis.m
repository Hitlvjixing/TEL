function TEL_SingleTopology_Analysis()
    % =====================================================================
    % Topological Equivalence Learning (TEL) - Single Topology Analysis
    % Topologies: 
    % 1 = Complete, 2 = ER Random, 3 = Square Lattice, 4 = WS Small-World
    % Generates 5 separate high-quality figures for the selected topology.
    % =====================================================================
    clc; clear; close all;
    
    % ---> CHANGE THIS VALUE (1, 2, 3, or 4) TO SWITCH TOPOLOGY <---
    topology_type = 1; 
    
    % --- 1. Global Parameters ---
    N = 256;                % Number of oscillators (16x16 for Lattice)
    Tp = 5.0;               % Prescribed deadline (seconds)
    T_sim = 7.0;            % Total simulation time
    eta = 15.0;             % Base learning rate
    tau = 0.02;             % TD filter time constant
    
    rng(42); % Fixed seed for fair comparison across topologies
    % omega = 4 * rand(N, 1) - 2;            % Natural frequencies [-2, 2]
     omega = 2 * rand(N, 1) - 1; 
    theta0 = 2 * pi * rand(N, 1) - pi;     % Initial phases [-pi, pi]
    phi0 = theta0;
    
    % --- 2. Generate Network Topology ---
    top_names = {'Complete network', 'Erdos-Renyi (ER) random graph', ...
                 'Square lattice', 'Watts-Strogatz (WS) small-world'};
    fprintf('\n>>> Selected Topology: %s <<<\n', top_names{topology_type});
    
    switch topology_type
        case 1
            A = ones(N) - eye(N); A = A / N; % Normalized Complete
        case 2
            A = generate_ER(N, 0.05);
        case 3
            A = generate_Lattice(N);
        case 4
            A = generate_WS_degree3(N, 0.3);
    end
    
    % STRICT VERIFICATION: Ensure the graph is undirected (Symmetric)
    assert(issymmetric(A), 'FATAL ERROR: Adjacency matrix is not symmetric! Not an undirected graph.');
    
    % Calculate Algebraic Connectivity
    D = diag(sum(A, 2));
    L = D - A;
    lam = sort(eig(L));
    lambda_2 = lam(2);
    fprintf('Algebraic Connectivity (lambda_2) = %.4f\n', lambda_2);
    assert(lambda_2 > 1e-5, 'FATAL ERROR: Network is NOT connected!');
    
    % Dynamic Control Gain (Theorem 4 constraint: k > 1/lambda_2)
    k_gain = (1.2 / lambda_2) + 3; 
    % k_gain = 3;
    fprintf('Dynamic Control Gain Set: k = %.4f\n', k_gain);
    
    % --- 3. ODE Simulation ---
    L_nn = 7;
    W0 = zeros(L_nn * N, 1);
    Y0 = [theta0; phi0; W0];
    
    params.N = N; params.Tp = Tp; params.k_gain = k_gain;
    params.eta = eta; params.tau = tau; params.omega = omega;
    params.L_nn = L_nn; params.L_mat = L; params.Adj = A;
    
    options = odeset('RelTol', 1e-3, 'AbsTol', 1e-3);
    
    disp('Starting numerical integration... Please wait.');
    tic;
    [t, Y] = ode45(@(t, Y) kuramoto_tel_ode(t, Y, params), [0, T_sim], Y0, options);
    toc;
    
    % --- 4. Data Extraction ---
    theta = Y(:, 1:N);
    
    % Reconstruct physical control inputs
    U_history = zeros(length(t), N);
    for i = 1:length(t)
        [~, u_curr] = kuramoto_tel_ode(t(i), Y(i,:)', params);
        U_history(i, :) = u_curr';
    end
    u_final = U_history(end, :)';
    
    disp('Generating 5 individual high-quality plots...');
    
    % =====================================================================
    % FIGURE 1: Topological Snapshot (Physical graph structure)
    % =====================================================================
    fig1 = figure('Name', 'Fig 1: Topology', 'Color', 'w', 'Position', [100, 100, 700, 600]);
    G = graph(A);
    if topology_type == 3
        % Force grid layout for Square Lattice (14x14)
        [Xg, Yg] = meshgrid(1:sqrt(N), 1:sqrt(N));
        p = plot(G, 'XData', Xg(:), 'YData', -Yg(:), 'NodeLabel', {});
    elseif topology_type == 4
        % Force circular layout for WS network
        p = plot(G, 'Layout', 'circle', 'NodeLabel', {});
    else
        % Force layout for ER and Complete
        p = plot(G, 'Layout', 'force', 'NodeLabel', {});
    end
    p.MarkerSize = 7;
    p.NodeCData = theta0; % Initial phase colors
    colormap(fig1, 'parula'); colorbar;
    title([ top_names{topology_type}], 'Interpreter', 'latex', 'FontSize', 20);
    axis off;
    % '\textbf{Topology Snapshot: } ',
    

    % =====================================================================
    % FIGURE 2: Spatiotemporal Heatmap (Plotting Disagreement State)
    % =====================================================================
    fig2 = figure('Name', 'Fig 2: Heatmap', 'Color', 'w', 'Position', [150, 150, 800, 500]);
    
    % 核心操作：计算相对于瞬时均值的相位差 (Disagreement State)
    theta_mean = mean(theta, 2);
    theta_centered = theta - theta_mean; 
    
    % 画相对相位的热力图
    imagesc(t, 1:N, theta_centered');
    
    % 顶刊级配色：使用蓝-白-红发散型色带 (或者继续用 turbo)
    % 这里我们用 MATLAB 自带的 parula 或者自定义对称色带
    colormap(fig2, 'turbo'); 
    
    % 强制颜色条对称，使得 0 永远在最中间的颜色
    caxis([-pi, pi]); 
    
    c = colorbar; 
    c.Label.String = 'Phase Disagreement $\delta_i$ (rad)'; 
    c.Label.Interpreter = 'latex'; 
    c.Label.FontSize = 20;
    
    xline(Tp, 'w--', 'LineWidth', 3);
    text(Tp - 0.6, N*0.05, 'Deadline $T_p$', 'Color', 'w', 'Interpreter', 'latex', 'FontSize', 20, 'FontWeight', 'bold');
    
    xlabel('Time (s)', 'Interpreter', 'latex', 'FontSize', 20);
    ylabel('Oscillator Index', 'Interpreter', 'latex', 'FontSize', 20);
    title('\textbf{Spatiotemporal Evolution of Phase Disagreement}', 'Interpreter', 'latex', 'FontSize', 20);
    set(gca, 'YDir', 'normal', 'FontSize', 20);
    % =====================================================================
    % FIGURE 2: Spatiotemporal Heatmap
    % =====================================================================
    % fig2 = figure('Name', 'Fig 2: Heatmap', 'Color', 'w', 'Position', [150, 150, 800, 500]);
    % imagesc(t, 1:N, theta');
    % colormap(fig2, 'turbo'); 
    % c = colorbar; c.Label.String = 'Phase \theta_i (rad)'; c.Label.FontSize = 12;
    % xline(Tp, 'w--', 'LineWidth', 3);
    % text(Tp - 0.6, N*0.05, 'Deadline $T_p$', 'Color', 'w', 'Interpreter', 'latex', 'FontSize', 14, 'FontWeight', 'bold');
    % xlabel('Time (s)', 'Interpreter', 'latex', 'FontSize', 14);
    % ylabel('Oscillator Index', 'Interpreter', 'latex', 'FontSize', 14);
    % title('\textbf{Spatiotemporal Phase Evolution Heatmap}', 'Interpreter', 'latex', 'FontSize', 16);
    % set(gca, 'YDir', 'normal', 'FontSize', 12);

% =====================================================================
    % 提取当前拓扑对应的主题色 (Nature Style Palette)
    % 1=Red(Complete), 2=LightBlue(ER), 3=Teal(Lattice), 4=DarkBlue(WS)
    % =====================================================================
    top_colors = [0.90 0.29 0.20;  
                  0.30 0.73 0.83;  
                  0.00 0.63 0.53;  
                  0.24 0.33 0.53]; 
    current_color = top_colors(topology_type, :); % 自动匹配当前网络颜色

    % =====================================================================
    % FIGURE 3: Uncertainty Funnel (Mean + Shaded Variance Envelope)
    % =====================================================================
    fig3 = figure('Name', 'Fig 3: Funnel', 'Color', 'w', 'Position', [200, 200, 700, 500]);
    th_mean = mean(theta, 2);
    th_std = std(theta, 0, 2); % Standard deviation
    
    % Draw shaded envelope (使用当前拓扑的主题色，设置30%透明度)
    fill([t; flipud(t)], [th_mean + th_std; flipud(th_mean - th_std)], ...
         current_color, 'FaceAlpha', 0.3, 'EdgeColor', 'none'); hold on;
    % Draw mean line (加深一点的主题色，或者直接用主题色)
    plot(t, th_mean, 'Color', current_color, 'LineWidth', 2.5);
    xline(Tp, 'k--', 'LineWidth', 2); % 截止线用黑色虚线更百搭
    
    xlabel('Time (s)', 'Interpreter', 'latex', 'FontSize', 20);
    ylabel('Phase $\theta$ (Mean $\pm$ Std envelope)', 'Interpreter', 'latex', 'FontSize', 20);
    title([ top_names{topology_type}], 'Interpreter', 'latex', 'FontSize', 20);
    grid on; set(gca, 'FontSize', 20);
    % '\textbf{Uncertainty Funnel: } ',
    
    % =====================================================================
    % FIGURE 4: Frequency Internalization Scatter
    % =====================================================================
    fig4 = figure('Name', 'Fig 4: Scatter', 'Color', 'w', 'Position', [250, 250, 600, 500]);
    % 散点图使用主题色，并加入黑色边缘显得更有质感
    scatter(omega, u_final, 60, current_color, 'filled', 'MarkerFaceAlpha', 0.8, 'MarkerEdgeColor', 'k'); hold on;
    plot([-1, 1], [1, -1], 'k--', 'LineWidth', 2); % Ideal y = -x line
    
    xlabel('Intrinsic natural frequency $\omega_i$', 'Interpreter', 'latex', 'FontSize', 20);
    ylabel('Terminal control input $u_i(T_{sim})$', 'Interpreter', 'latex', 'FontSize', 20);
    title([top_names{topology_type}], 'Interpreter', 'latex', 'FontSize', 20);
    legend({'Learned terminal state', 'Ideal physics cancellation'}, 'Interpreter', 'latex', 'Location', 'northeast', 'FontSize', 12);
    grid on; set(gca, 'FontSize', 20);
    % axis([-2.5 2.5 -2.5 2.5]);
    % '\textbf{Frequency Internalization: } ', 
    
    % =====================================================================
    % FIGURE 5: Control Input Evolution
    % =====================================================================
    fig5 = figure('Name', 'Fig 5: Control', 'Color', 'w', 'Position', [300, 300, 800, 500]);
    % 将当前主题色增加一个 Alpha 通道 (0.4) 变成半透明，避免200根线重叠变成死黑
    transparent_color = [current_color, 0.4]; 
    plot(t, U_history, 'LineWidth', 1.2, 'Color', transparent_color); 
    xline(Tp, 'k--', 'LineWidth', 2.5);
    
    xlabel('Time (s)', 'Interpreter', 'latex', 'FontSize', 20);
    ylabel('Physical Control Inputs $u_i(t)$', 'Interpreter', 'latex', 'FontSize', 20);
    title([top_names{topology_type}], 'Interpreter', 'latex', 'FontSize', 20);
    grid on; set(gca, 'FontSize', 20);
    % '\textbf{Singularity-Free Actuation: } ', 
end


    
    % =====================================================================
    % FIGURE 3: Uncertainty Funnel (Mean + Shaded Variance Envelope)
    % =====================================================================
    % fig3 = figure('Name', 'Fig 3: Funnel', 'Color', 'w', 'Position', [200, 200, 700, 500]);
    % th_mean = mean(theta, 2);
    % th_std = std(theta, 0, 2); % Standard deviation (sqrt of variance)
    % 
    % % Draw shaded envelope for variance/std
    % fill([t; flipud(t)], [th_mean + th_std; flipud(th_mean - th_std)], ...
    %      [0.2 0.6 0.8], 'FaceAlpha', 0.3, 'EdgeColor', 'none'); hold on;
    % % Draw mean line
    % plot(t, th_mean, 'Color', [0 0.4 0.6], 'LineWidth', 2.5);
    % xline(Tp, 'r--', 'LineWidth', 2);
    % 
    % xlabel('Time (s)', 'Interpreter', 'latex', 'FontSize', 14);
    % ylabel('Phase $\theta$ (Mean $\pm$ Std Envelope)', 'Interpreter', 'latex', 'FontSize', 14);
    % title('\textbf{Time-Gated Uncertainty Funnel}', 'Interpreter', 'latex', 'FontSize', 16);
    % grid on; set(gca, 'FontSize', 12);
    % 
    % % =====================================================================
    % % FIGURE 4: Frequency Internalization Scatter
    % % =====================================================================
    % fig4 = figure('Name', 'Fig 4: Scatter', 'Color', 'w', 'Position', [250, 250, 600, 500]);
    % scatter(omega, u_final, 60, [0.8 0.2 0.2], 'filled', 'MarkerFaceAlpha', 0.8, 'MarkerEdgeColor', 'k'); hold on;
    % plot([-1, 1], [1, -1], 'k--', 'LineWidth', 2); % Ideal y = -x line
    % 
    % xlabel('Intrinsic Natural Frequency $\omega_i$', 'Interpreter', 'latex', 'FontSize', 14);
    % ylabel('Terminal Control Input $u_i(T_{sim})$', 'Interpreter', 'latex', 'FontSize', 14);
    % title('\textbf{Autonomous Frequency Internalization}', 'Interpreter', 'latex', 'FontSize', 16);
    % legend({'Learned Terminal State', 'Ideal Physics Cancellation'}, 'Interpreter', 'latex', 'Location', 'northeast', 'FontSize', 12);
    % grid on; set(gca, 'FontSize', 12);
    % % axis([-2.5 2.5 -2.5 2.5]);
    % 
    % % =====================================================================
    % % FIGURE 5: Control Input Evolution
    % % =====================================================================
    % fig5 = figure('Name', 'Fig 5: Control', 'Color', 'w', 'Position', [300, 300, 800, 500]);
    % plot(t, U_history, 'LineWidth', 1.2, 'Color', [0.3 0.3 0.3 0.4]); % Plot all inputs with transparency
    % xline(Tp, 'r--', 'LineWidth', 2.5);
    % 
    % xlabel('Time (s)', 'Interpreter', 'latex', 'FontSize', 14);
    % ylabel('Physical Control Inputs $u_i(t)$', 'Interpreter', 'latex', 'FontSize', 14);
    % title('\textbf{Singularity-Free Physical Actuation}', 'Interpreter', 'latex', 'FontSize', 16);
    % grid on; set(gca, 'FontSize', 12);

% =========================================================================
% TOPOLOGY GENERATORS (Strictly Undirected)
% =========================================================================
function A = generate_ER(N, p)
    connected = false;
    while ~connected
        A = rand(N, N) < p; A = triu(A, 1); A = A + A';
        lam = sort(eig(diag(sum(A,2)) - A));
        if lam(2) > 1e-5, connected = true; end
    end
end

function A = generate_Lattice(N)
    side = sqrt(N);
    A = zeros(N, N);
    for i = 1:N
        row = ceil(i / side); col = mod(i - 1, side) + 1;
        if col < side, A(i, i + 1) = 1; A(i + 1, i) = 1; end
        if row < side, A(i, i + side) = 1; A(i + side, i) = 1; end
    end
end

function A = generate_WS_degree3(N, beta)
    A = zeros(N, N);
    for i = 1:N
        next_n = mod(i, N) + 1; A(i, next_n) = 1; A(next_n, i) = 1;
        opp_n = mod(i - 1 + N/2, N) + 1; A(i, opp_n) = 1; A(opp_n, i) = 1;
    end
    connected = false;
    while ~connected
        A_rew = A;
        for i = 1:N/2
            opp_n = i + N/2;
            if rand() < beta
                A_rew(i, opp_n) = 0; A_rew(opp_n, i) = 0;
                v_nodes = find(A_rew(i,:) == 0); v_nodes = v_nodes(v_nodes ~= i);
                new_n = v_nodes(randi(length(v_nodes)));
                A_rew(i, new_n) = 1; A_rew(new_n, i) = 1;
            end
        end
        lam = sort(eig(diag(sum(A_rew,2)) - A_rew));
        if lam(2) > 1e-5, connected = true; end
    end
    A = A_rew;
end

% =========================================================================
% DIFFERENTIAL EQUATION FUNCTION
% =========================================================================
function [dy, u_current] = kuramoto_tel_ode(t, Y, params)
    N = params.N; L_nn = params.L_nn;
    theta = Y(1:N); phi = Y(N+1 : 2*N);
    W_hat = reshape(Y(2*N+1 : end), L_nn, N);
    
    e = params.L_mat * theta;
    tp_minus_t = max(params.Tp - t, 0);
    
    d_phi = (theta - phi) / params.tau;
    E_c = d_phi * tp_minus_t + params.k_gain * e;
    
    sig_mat = [ones(1, N); e'; tanh(e)'; theta'; sin(theta)'; cos(theta)'; repmat(tp_minus_t, 1, N)];
    u = sum(W_hat .* sig_mat, 1)'; 
    u_current = u;
    
    coupling = sum(params.Adj .* sin(theta' - theta), 2);
    d_theta = u + params.omega + coupling;
    
    dW = zeros(L_nn, N);
    if t <= params.Tp
        dW = -params.eta * (sig_mat .* E_c');
    end
    dy = [d_theta; d_phi; dW(:)];
end