% =========================================================================
% BLSimulation project
% =========================================================================
% Description
%    Rescales 1D similarity boundary layer solutions back into 2D physical
%    fields (U, V, T, Psi) on a computational mesh along the plate.
%    Computes wall heat flux and physical temperature gradients accurately.
%
% Syntax
%    PhysicalFields = calculate_physical_fields(eta_1d, sol_profiles_1d, Param)
%
% Input arguments
%    eta_1d          : 1D similarity variable vector from ODE solver.
%    sol_profiles_1d : Matrix of similarity profiles [f, f', f'', theta, theta'].
%    Param           : Execution configuration and simulation parameter structure.
%
% Output
%    PhysicalFields  : Structure containing 2D computational grid and physical fields:
%                      .X, .Y      - 2D spatial grid coordinates [m].
%                      .U, .V      - 2D velocity field components [m/s].
%                      .T          - 2D physical temperature field [K].
%                      .Psi        - Stream function field [m^2/s].
%                      .Theta      - 2D dimensionless temperature field.
%                      .f_pp_0     - Wall velocity gradient f''(0).
%                      .g_p_0      - Wall temperature gradient theta'(0).
%                      .dTdy_wall  - Physical wall temperature gradient [K/m].
%                      .q_wall     - Physical wall heat flux [W/m^2].
%
% Example
%    PhysFields = calculate_physical_fields(eta, profiles, Param);
%
% Notes
%    - Supports forced convection (Blasius/Pohlhausen) and free convection
%      (Ostrach similarity) inverse transformations.
%    - Validates audit mode and forces 'EXACT' uniform grid configuration
%      if unvalidated modes are supplied.
%    - Includes an embedded, Octave-compatible computational grid generator.
%
% See also
%    calculate_deltas, calculate_physical_deltas, interp1, meshgrid
%
% Author      : Rvieytes
% Assisted by : Gemini 3.6; OpenAI ChatGPT
% Date        : 15/06/2026
% Version     : 0.0.1
% =========================================================================
function PhysicalFields = calculate_physical_fields(eta_1d, sol_profiles_1d, Param)

    if ~strcmpi(Param.num.audit_mode, 'EXACT')
        fprintf('\n[WARNING] Audit mode "%s" is not fully validated for V1.0.\n', Param.num.audit_mode);
        fprintf('[WARNING] Reverting to "EXACT" and forcing UNIFORM grid for consistency.\n');

        % Force safe configuration
        Param.num.audit_mode = 'EXACT';
        if isfield(Param.num, 'grid_type')
            Param.num.grid_type = 'uniform';
        end
    end

    % --- 1. Data Extraction ---
    f_1d   = sol_profiles_1d(:, 1);
    f_p_1d = sol_profiles_1d(:, 2);
    g_1d   = sol_profiles_1d(:, 4);

    % Exact dimensionless gradients from the ODE solver
    f_pp_0 = sol_profiles_1d(1, 3);
    g_p_0  = sol_profiles_1d(1, 5);

    phys   = Param.phys;
    T_w    = phys.T_w;
    T_inf  = phys.T_inf;
    deltaT = T_w - T_inf;
    nu     = phys.nu;
    k_cond = phys.k;

    % --- 2. Grid Generation ---
    [X, Y] = generate_computational_grid(Param.num);

    % Pre-allocate physical fields
    U = zeros(size(X)); V = zeros(size(X)); T = zeros(size(X)); Psi = zeros(size(X));

    % --- 3. Inverse Transformation Logic ---
    switch upper(Param.run.problem_str)
        case 'FORCED'
            U_inf = phys.U_inf;
            C_eta = sqrt(U_inf / nu);
            C_psi = sqrt(nu * U_inf);
            C_v   = 0.5 * sqrt(nu * U_inf);

            Eta_2D = Y .* C_eta ./ sqrt(X);

            f_2D   = interp1(eta_1d, f_1d,   Eta_2D, 'linear', 'extrap');
            f_p_2D = interp1(eta_1d, f_p_1d, Eta_2D, 'linear', 'extrap');
            g_2D   = interp1(eta_1d, g_1d,   Eta_2D, 'linear', 'extrap');

            U   = U_inf .* f_p_2D;
            V   = C_v ./ sqrt(X) .* (Eta_2D .* f_p_2D - f_2D);
            T   = T_inf + deltaT .* g_2D;
            Psi = C_psi .* sqrt(X) .* f_2D;

            dTdy_wall = g_p_0 * deltaT * C_eta ./ sqrt(X(1, :));

        case 'FREE'
            g_grav = phys.g;
            beta   = phys.beta;

            % Ostrach scaling constant (consistent with 3/4 f f'' ODE)
            C = (g_grav * beta * abs(deltaT) / (4 * nu^2))^(1/4);

            % Scales for FREE convection reconstruction
            C_psi = nu * C;
            C_u   = nu * C^2;
            C_v   = nu * C;

            Eta_2D = Y .* C .* X.^(-1/4);

            f_2D   = interp1(eta_1d, f_1d,   Eta_2D, 'linear', 'extrap');
            f_p_2D = interp1(eta_1d, f_p_1d, Eta_2D, 'linear', 'extrap');
            g_2D   = interp1(eta_1d, g_1d,   Eta_2D, 'linear', 'extrap');

            % Physical Velocity and Temperature
            U   = C_u .* sqrt(X) .* f_p_2D;
            V   = C_v .* X.^(-1/4) .* (Eta_2D .* f_p_2D - 3 .* f_2D);
            T   = T_inf + deltaT .* g_2D;
            Psi = C_psi .* X.^(3/4) .* f_2D;

            % Adjust signs for cold plate (buoyancy acts downwards)
            if (T_w < T_inf)
                U = -U; V = -V; Psi = -Psi;
            end

            % Exact wall temperature gradient: dT/dy = g'(0) * deltaT * (dEta/dy)
            dTdy_wall = g_p_0 * deltaT * C .* X(1, :).^(-1/4);
    end

    % --- 4. Final Assembly ---
    PhysicalFields.X = X; PhysicalFields.Y = Y;
    PhysicalFields.U = U; PhysicalFields.V = V;
    PhysicalFields.T = T; PhysicalFields.Psi = Psi;
    PhysicalFields.Theta     = g_2D;
    PhysicalFields.g_p_0     = g_p_0;
    PhysicalFields.f_pp_0    = f_pp_0;
    PhysicalFields.dTdy_wall = dTdy_wall;
    PhysicalFields.q_wall     = -k_cond * dTdy_wall;

% =========================================================================
% PRIVATE NESTED SUB-FUNCTION: Grid Generation (Octave-Safe Version)
% =========================================================================
    function [Xm, Ym] = generate_computational_grid(num_cfg)
        g_cfg = num_cfg.grid;
        x_vec = linspace(g_cfg.x_start, g_cfg.x_end, g_cfg.nx);

        % Check for stretching using strfind (Octave compatible)
        is_stretched_type = isfield(num_cfg, 'grid_type') && strcmpi(num_cfg.grid_type, 'stretched');

        is_stretched_mode = false;
        if isfield(num_cfg, 'audit_mode')
            if ~isempty(strfind(upper(num_cfg.audit_mode), 'STRETCHED'))
                is_stretched_mode = true;
            end
        end

        if is_stretched_type || is_stretched_mode
            % Stretching in Y to cluster nodes near the wall (y=0)
            s = num_cfg.grid_s; % Stretching factor
            n = g_cfg.ny;
            % Geometric distribution from 0 to y_max
            y_vec = g_cfg.y_max * ((1 + s).^(0:n-1) - 1) / ((1 + s)^(n-1) - 1);
        else
            % Uniform grid
            y_vec = linspace(0, g_cfg.y_max, g_cfg.ny);
        end
        [Xm, Ym] = meshgrid(x_vec, y_vec);
    end

end
