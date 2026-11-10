function TEL_Kuramoto_Simulation_With_Noise()
    % ---------------------------------------------------------
    % Topological Equivalence Learning (TEL) for Kuramoto Network
    % Topology: Normalized Complete Network (All-to-All)
    % Condition: Stochastic Communication Noises Injected
    % ---------------------------------------------------------
    
    clc; clear; close all;
    
    % --- System Parameters ---
    N = 1000;                % Number of oscillators
    Tp = 7.0;               % Prescribed time deadline (seconds)
    T_sim = 10.0;           % Total simulation time
    k_gain = 5.0;           % Control gain (Must be > 1/lambda_2. Here lambda_2 = 1)
    eta = 5.0;             % Neural network learning rate
    tau = 0.02;             % Tracking differentiator time constant
    
    % --- Communication Noise Setting ---
    noise_amp = 0.02;       % Amplitude of stochastic communication channel noise
    
    % --- Initialization ---
    rng(42); % Set random seed for reproducibility
    omega = 2 * rand(N, 1) - 1;  
    theta0 = 2 * pi * rand(N, 1) - pi;     % Initial phases [-pi, pi]
    phi0 = theta0;                         % Initial state for TD filter
    
    L_nn = 7;                              % Number of neurons (Basis functions)
    W0 = zeros(L_nn * N, 1);               % Initial NN weights
    
    % Pack initial states for ODE solver
    Y0 = [theta0; phi0; W0];
    
    % Pack parameters
    params.N = N;
    params.Tp = Tp;
    params.k_gain = k_gain;
    params.eta = eta;
    params.tau = tau;
    params.omega = omega;
    params.L_nn = L_nn;
    params.noise_amp = noise_amp; % Pass noise amplitude to ODE
    
    % Normalized Laplacian for Complete Network
    params.L_mat = eye(N) - (1/N) * ones(N, N); 
    
    % --- ODE Settings ---
    % Note: When injecting randn into ode45, the adaptive step solver might slow down 
    % slightly due to stochasticity, but it effectively simulates persistent excitation.
    options = odeset('RelTol', 1e-3, 'AbsTol', 1e-3);
    
    disp(['Starting noise-corrupted simulation for ', num2str(N), ' nodes... Please wait.']);
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
    % 1. Phase Trajectories
    figure(1);
    plot(t, theta, 'LineWidth', 1.0); hold on;
    xline(Tp, 'r--', 'LineWidth', 2);
    xlabel('Time (s)', 'Interpreter', 'latex', 'FontSize', 20);
    ylabel('Phases $\theta_i(t)$', 'Interpreter', 'latex', 'FontSize', 20);
    % title(['Phase consensus of ', num2str(N), ' Kuramoto oscillators (with noise)'], 'FontSize', 20);
    grid on;

    % 2. Synchronization Error (Log Scale to observe the residual boundary)
    figure(2);
    plot(t, sync_error, 'b', 'LineWidth', 2);hold on;
    xline(Tp, 'r--', 'LineWidth', 2);
    xlabel('Time (s)', 'Interpreter', 'latex', 'FontSize', 20);
    ylabel('Variance of $\theta$', 'Interpreter', 'latex', 'FontSize', 20);
    title('Global synchronization error', 'FontSize', 20);
    % set(gca, 'YScale', 'log'); % CRITICAL: Log scale to see the bounded residual!
    grid on;

    
    
    % 3. Control Input (Physical Isolation Verification)
    figure(3);
    plot(t, U_history, 'LineWidth', 1.0);hold on;
    xline(Tp, 'r--', 'LineWidth', 2);
    xlabel('Time (s)', 'Interpreter', 'latex', 'FontSize', 20);
    ylabel('Control inputs $u_i(t)$', 'Interpreter', 'latex', 'FontSize', 20);
    % title('Distributed physical control inputs', 'FontSize', 20);
    grid on;

    % 4. Control input vs Natural Frequencies
    u_final = U_history(end, :)';
    figure(4);
    scatter(omega, u_final, 50, 'Filled');
    hold on;
    plot([-1, 1], [1, -1], 'r--', 'LineWidth', 2); 
    xlabel('Natural frequency $\omega_i$', 'Interpreter', 'latex', 'FontSize', 20);
    ylabel('Final control output $u_i(T_{sim})$', 'Interpreter', 'latex', 'FontSize', 20);
    % title('Neural Network Internalization of $-\omega_i$', 'FontSize', 14);
    legend('Learned output', 'Ideal cancellation line', 'Location', 'best','FontSize', 20);
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
    
    % =========================================================
    % COMMUNICATION NOISE INJECTION
    % Agent i receives state from j, but the channel adds noise.
    % =========================================================
    comm_noise = params.noise_amp * randn(N, 1);
    theta_rcv = theta + comm_noise; % This is what neighbors broadcast
    
    % Topology and Error 
    % e_i is calculated using the noisy received states
    e = params.L_mat * theta_rcv;
    
    % Time Envelope 
    tp_minus_t = max(params.Tp - t, 0);
    
    % Tracking Differentiator (Uses local clean state, NO comm noise here)
    d_phi = (theta - phi) / params.tau;
    theta_dot_est = d_phi;
    
    % Computable Error Metric
    E_c = theta_dot_est * tp_minus_t + params.k_gain * e;
    
    % Neural Network Basis Function
    sigma_matrix = zeros(L_nn, N);
    sigma_matrix(1, :) = 1;
    sigma_matrix(2, :) = e';           % Based on noisy consensus error
    sigma_matrix(3, :) = tanh(e)';     % Based on noisy consensus error
    sigma_matrix(4, :) = theta';       % Local state is clean
    sigma_matrix(5, :) = sin(theta)';  % Local state is clean
    sigma_matrix(6, :) = cos(theta)';  % Local state is clean
    sigma_matrix(7, :) = tp_minus_t;
    
    % Compute physical control execution
    u = sum(W_hat .* sigma_matrix, 1)'; 
    u_current = u; 
    
    % Kuramoto Intrinsic Dynamics
    % Coupling is based on what agent i receives from agent j
    phase_diff = theta_rcv' - theta; % N x N matrix of (theta_rcv_j - theta_i)
    coupling = (1/N) * sum(sin(phase_diff), 2);
    F_intrinsic = params.omega + coupling;
    
    % System Dynamics
    d_theta = u + F_intrinsic;
    
    % Neural Network Adaptation Law
    dW = zeros(L_nn, N);
    if t <= params.Tp
        dW = -params.eta * (sigma_matrix .* E_c');
    end
    
    % Pack derivatives
    dY = [d_theta; d_phi; dW(:)];
end