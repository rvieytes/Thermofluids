% =========================================================================
% BLSimulation project
% =========================================================================
% Description
%    High-fidelity shooting solver for boundary layer differential equations.
%    Uses fsolve to determine missing initial conditions at the wall (f''(0)
%    and g'(0)) and performs numerical integration via ode15s to compute
%    complete similarity profiles.
%
% Syntax
%    [eta, profiles, ic_found, flag] = bvp_shooting_solver(Param)
%
% Input arguments
%    Param    : Execution configuration and simulation parameter structure
%               containing numerical tolerances, boundary conditions, and
%               ODE handle definitions.
%
% Output
%    eta      : 1D similarity variable coordinate vector.
%    profiles : Matrix containing solved boundary layer profiles
%               [f, f', f'', g, g'].
%    ic_found : Complete assembled vector of initial conditions at the wall
%               [f(0), f'(0), f''(0), g(0), g'(0)].
%    flag     : Convergence exit flag returned by fsolve.
%
% Example
%    [eta, profiles, ic_found, flag] = bvp_shooting_solver(Param);
%
% Notes
%    - Fully synchronized with Param.num.opts_fsolve and Param.num.opts_ode.
%    - Uses nested helper functions to compute boundary condition residuals
%      at infinity and assemble full initial condition vectors.
%
% See also
%    fsolve, ode15s, update_numerical_options
%
% Author      : Rvieytes
% Assisted by : Gemini 3.6; OpenAI ChatGPT
% Date        : 15/06/2026
% Version     : 0.0.1
% =========================================================================
function [eta, profiles, ic_found, flag] = bvp_shooting_solver(Param)

    % --- 1. PARAMETER EXTRACTION ---
    eta_max       = Param.num.eta_max;
    initial_guess = Param.num.BC.initial_guess; % Optimized by look_optimal_seed

    % Pre-configured options from central Param structure
    fsolve_opts = Param.num.opts_fsolve;
    ode_opts    = Param.num.opts_ode;

    fprintf('\n');
    fprintf(repmat('=', 1, 79));
    fprintf('\n BVP_SHOOTING_SOLVER: Starting final high-fidelity run.\n');
    fprintf(repmat('=', 1, 79));
    fprintf('\n');
    fprintf('    Targeting eta_max = %.1f with strict tolerances.\n', eta_max);

    % --- 2. ROOT-FINDING PHASE (fsolve) ---
    fsolve_h = @(ics) compute_residuals(ics, ode_opts);

    [found_ics, ~, flag] = fsolve(fsolve_h, initial_guess, fsolve_opts);

    if flag <= 0
        warning('BVP_SOLVER:ConvergenceWarning', 'fsolve did not converge perfectly (flag = %d).', flag);
    end

    % Assemble final initial conditions: [f, f', f'', g, g']
    ic_found = assemble_iv(Param.num.BC.known_initial_values, found_ics);

    % --- 3. FINAL INTEGRATION ATTEMPT ---
    try
        [eta, profiles] = ode15s( ...
            @(e, S) Param.num.ode_handle(e, S, Param), ...
            [0, eta_max], ...
            ic_found, ...
            ode_opts);

        fprintf('    Final integration successful. Points calculated: %d\n', length(eta));
    catch ME
        fprintf('    [ERROR] Final integration failed: %s\n', ME.message);
        eta = []; profiles = [];
    end

% =========================================================================
% PRIVATE NESTED HELPER FUNCTIONS
% =========================================================================

    function residuals = compute_residuals(unknown_ics, current_ode_opts)
        % Assemble full vector for ODE integrator
        iv_guess = assemble_iv(Param.num.BC.known_initial_values, unknown_ics);

        try
            % Integrate from 0 to eta_max
            [~, sol_matrix] = ode15s( ...
                @(e, S) Param.num.ode_handle(e, S, Param), ...
                [0, eta_max], ...
                iv_guess, ...
                current_ode_opts);

            if isempty(sol_matrix)
                residuals = [1e4; 1e4];
                return;
            end

            % Boundary Conditions at Infinity:
            % Forced: f'(inf) = 1, g(inf) = 0
            % Free:   f'(inf) = 0, g(inf) = 0
            final_state     = sol_matrix(end, :);
            calculated_vals = [final_state(2); final_state(4)];

            % Target values defined in Param.num.BC.final_targets
            residuals = calculated_vals - Param.num.BC.final_targets;

        catch
            residuals = [1e4; 1e4];
        end
    end

    function full_iv = assemble_iv(known, found)
        % Layout: [f(0), f'(0), f''(0), g(0), g'(0)]
        % known: [f(0), f'(0), g(0)] | found: [f''(0), g'(0)]
        full_iv = [known(1); known(2); found(1); known(3); found(2)];
    end

end
