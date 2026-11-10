function TEL_Kuramoto_Simulation()
    % ---------------------------------------------------------
    % Topological Equivalence Learning (TEL) for Kuramoto Network
    % Topology: Normalized Complete Network (All-to-All)
    % ---------------------------------------------------------
    
    clc; clear; close all;
    
    % --- System Parameters ---
    N = 500;                % Number of oscillators
    Tp = 3.0;               % Prescribed time deadline (seconds)
    T_sim = 10.0;            % Total simulation time
    k_gain = 5.0;           % Control gain (Must be > 1/lambda_2. Here lambda_2 = 1)
    eta = 15.0;             % Neural network learning rate
    tau = 0.02;             % Tracking differentiator time constant
    
    % --- Initialization ---
    rng(42); % Set random seed for reproducibility
    omega = 2 * rand(N, 1) - 1;  
    % omega = 4 * rand(N, 1) - 2;            % Heterogeneous natural frequencies [-2, 2]
    theta0 = 2 * pi * rand(N, 1) - pi;     % Initial phases [-pi, pi]
    phi0 = theta0;                         % Initial state for TD filter
    
    L_nn = 6;                              % Number of neurons (Basis functions)
    W0 = zeros(L_nn * N, 1);               % Initial NN weights
    
    % Pack initial states for ODE solver
    % Y = [theta(1:N); phi(1:N); W(1:L_nn*N)]
    Y0 = [theta0; phi0; W0];
    
    % Pack parameters
    params.N = N;
    params.Tp = Tp;
    params.k_gain = k_gain;
    params.eta = eta;
    params.tau = tau;
    params.omega = omega;
    params.L_nn = L_nn;
    
    % Normalized Laplacian for Complete Network
    % L_mat = I - (1/N) * 1 * 1^T
    params.L_mat = eye(N) - (1/N) * ones(N, N); 
    
    % --- ODE Settings ---
    % Use tight tolerances to handle rapid convergence dynamics near Tp
    options = odeset('RelTol', 1e-4, 'AbsTol', 1e-4);
    
    disp('Starting simulation for 200 nodes... Please wait.');
    tic;
    [t, Y] = ode45(@(t, Y) kuramoto_tel_ode(t, Y, params), [0, T_sim], Y0, options);
    toc;
    disp('Simulation finished! Plotting results...');
    
    % --- Data Extraction ---
    theta = Y(:, 1:N);
    
    % Compute global synchronization error metric (Variance of phases)
    sync_error = var(theta, 0, 2);
    
    % Compute Control Inputs over time
    U_history = zeros(length(t), N);
    for i = 1:length(t)
        [~, u_i] = kuramoto_tel_ode(t(i), Y(i,:)', params);
        U_history(i, :) = u_i';
    end
    
    % --- Plotting ---
    % figure('Color', 'w', 'Position', [100, 100, 1200, 800]);
    
    % 1. Phase Trajectories
    % subplot(2, 2, 1);
    figure(1);
    plot(t, theta, 'LineWidth', 1.0); hold on;
    % xline(Tp, 'r--', 'LineWidth', 2, 'Label', 'Deadline $T_p = 5$', 'Interpreter', 'latex','FontSize', 20);
    xline(Tp, 'r--', 'LineWidth', 2);
    xlabel('Time (s)', 'Interpreter', 'latex', 'FontSize', 20);
    ylabel('Phases $\theta_i(t)$', 'Interpreter', 'latex', 'FontSize', 20);
    title('Phase consensus of 200 Kuramoto oscillators', 'FontSize', 20);
    grid on;

    % 'Label',
    
    figure(3);
    plot(t, U_history, 'LineWidth', 1.0);hold on;
    xline(Tp, 'r--', 'LineWidth', 2);
    xlabel('Time (s)', 'Interpreter', 'latex', 'FontSize', 20);
    ylabel('Control Inputs $u_i(t)$', 'Interpreter', 'latex', 'FontSize', 20);
    title('Distributed Physical Control Inputs (Singularity-Free)', 'FontSize', 20);
    grid on;

    % 2. Synchronization Error
    % subplot(2, 2, 2);
    figure(2);
    plot(t, sync_error, 'b', 'LineWidth', 2);hold on;
    xline(Tp, 'r--', 'LineWidth', 2);
    xlabel('Time (s)', 'Interpreter', 'latex', 'FontSize', 20);
    ylabel('Variance of $\theta$', 'Interpreter', 'latex', 'FontSize', 20);
    title('Global Synchronization Error', 'FontSize', 20);
    % set(gca, 'YScale', 'log');
    grid on;
    
    % 3. Control Input (Physical Isolation Verification)
    % subplot(2, 2, 3);

    % 4. Control input vs Natural Frequencies (Checking self-adaptation)
    % Extract the final control input at the end of simulation
    u_final = U_history(end, :)';
    % subplot(2, 2, 4);
    figure(4);
    scatter(omega, u_final, 50, 'Filled');
    hold on;
    plot([-1, 1], [1, -1], 'r--', 'LineWidth', 2); % Ideal cancellation line u_i = -omega_i
    xlabel('Natural Frequency $\omega_i$', 'Interpreter', 'latex', 'FontSize', 20);
    ylabel('Final Control Output $u_i(T_{sim})$', 'Interpreter', 'latex', 'FontSize', 20);
    title('Neural Network Internalization of $-\omega_i$', 'FontSize', 14);
    legend('Learned Output', 'Ideal Cancellation Line', 'Location', 'best');
    grid on;
end

% --- Differential Equation Function ---
function [dY, u_current] = kuramoto_tel_ode(t, Y, params)
    N = params.N;
    L_nn = params.L_nn;
    
    % Unpack states
    theta = Y(1:N);
    phi = Y(N+1 : 2*N);
    W_hat = reshape(Y(2*N+1 : end), L_nn, N);
    
    % Topology and Error
    e = params.L_mat * theta;
    
    % Time Envelope (ensure it doesn't go negative)
    tp_minus_t = max(params.Tp - t, 0);
    
    % Tracking Differentiator (TD)
    d_phi = (theta - phi) / params.tau;
    theta_dot_est = d_phi;
    
    % Computable Error Metric
    E_c = theta_dot_est * tp_minus_t + params.k_gain * e;
    
    % Neural Network Basis Function (Dimension: L_nn x N)
    % sigma = [1, e_i, tanh(e_i), theta_i, sin(theta_i), cos(theta_i), (Tp-t)]^T
    sigma_matrix = zeros(L_nn, N);
    sigma_matrix(1, :) = 1;
    sigma_matrix(2, :) = e';
    sigma_matrix(3, :) = tanh(e)';
    sigma_matrix(4, :) = theta';
    sigma_matrix(5, :) = sin(theta)';
    sigma_matrix(6, :) = cos(theta)';
    % sigma_matrix(7, :) = tp_minus_t;
    
    % Compute physical control execution
    u = sum(W_hat .* sigma_matrix, 1)'; % column vector N x 1
    u_current = u; % For output extraction
    
    % Kuramoto Intrinsic Dynamics (Normalized Coupling)
    % F_i = omega_i + (1/N) * sum_j sin(theta_j - theta_i)
    % Vectorized computation of coupling
    phase_diff = theta' - theta; % N x N matrix of (theta_j - theta_i)
    coupling = (1/N) * sum(sin(phase_diff), 2);
    F_intrinsic = params.omega + coupling;
    
    % System Dynamics
    d_theta = u + F_intrinsic;
    
    % Neural Network Adaptation Law
    dW = zeros(L_nn, N);
    if t <= params.Tp
        % dW_i = -eta * E_ci * sigma_i
        % Vectorized: scale each column of sigma_matrix by corresponding E_c(i)
        dW = -params.eta * (sigma_matrix .* E_c');
    end
    
    % Pack derivatives
    dY = [d_theta; d_phi; dW(:)];
end