% =========================================================================
% BLSimulation project
% =========================================================================
% Description
%    Calculates dimensionless hydrodynamic and thermal boundary layer
%    thicknesses (eta_hid, eta_ter) using precise ODE Event Location.
%    Also stores wall shear stress and thermal gradient values (f''(0), theta'(0))
%    required for skin friction coefficient and Nusselt number calculations.
%
% Syntax
%    Deltas = calculate_deltas(eta, sol_profiles, iv_found, Param)
%
% Input arguments
%    eta          : Similarity variable vector from solver integration.
%    sol_profiles : Matrix of profiles [f, f', f'', theta, theta'].
%    iv_found     : Validated initial conditions vector for shooting method.
%    Param        : Execution configuration and simulation parameter structure.
%
% Output
%    Deltas       : Structure containing calculated boundary layer properties:
%                   .eta_hid : Hydrodynamic thickness (eta where f' criterion is met).
%                   .eta_ter : Thermal thickness (eta where theta criterion is met).
%                   .fpp_0   : Wall velocity gradient f''(0).
%                   .tp_0    : Wall temperature gradient theta'(0).
%
% Example
%    Deltas = calculate_deltas(eta, sol_profiles, iv_found, Param);
%
% Notes
%    - Forced convection uses f' = 0.99 for hydrodynamic thickness.
%    - Free convection locates the peak velocity first and evaluates f' = 0.01
%      along the descending velocity branch.
%    - Generic thermal thickness criterion uses theta = 0.01.
%
% See also
%    ode15s, odeset
%
% Author      : Rvieytes
% Assisted by : Gemini 3.6; OpenAI ChatGPT
% Date        : 15/06/2026
% Version     : 0.0.1
% =========================================================================
function Deltas = calculate_deltas(eta, sol_profiles, iv_found, Param)

    % --- 1. Parameter Extraction ---
    eta_max    = Param.num.eta_max;
    ode_handle = Param.num.ode_handle;

    % Initialization
    Deltas.eta_hid = NaN;
    Deltas.eta_ter = NaN;

    % --- 2. Problem Selection ---
    switch upper(Param.run.problem_str)
        case 'FORCED'
            fprintf('    > Calculating thicknesses for Forced Convection (Event-based)...\n');

            % --- Hydrodynamic Thickness (f' = 0.99) ---
            opts_h = odeset('Events', @event_hydro_forced, 'RelTol', 1e-6);
            [~, ~, TE_h] = ode15s(@(e, S) ode_handle(e, S, Param), [0, eta_max], iv_found, opts_h);

            if ~isempty(TE_h)
                Deltas.eta_hid = TE_h(1);
            else
                warning('DELTAS:NotFound', 'Hydrodynamic thickness exceeds domain (eta > %.1f)', eta_max);
            end

            % --- Thermal Thickness (theta = 0.01) ---
            opts_t = odeset('Events', @event_thermal_generic, 'RelTol', 1e-6);
            [~, ~, TE_t] = ode15s(@(e, S) ode_handle(e, S, Param), [0, eta_max], iv_found, opts_t);

            if ~isempty(TE_t)
                Deltas.eta_ter = TE_t(1);
            end

        case 'FREE'
            fprintf('    > Calculating thicknesses for Free Convection (Event-based)...\n');

            % --- Hydrodynamic Thickness (f' = 0.01 after peak) ---
            % Find peak velocity location to initiate search along descending branch
            f_p_sol  = sol_profiles(:, 2);
            [~, idx_max] = max(f_p_sol);
            eta_peak = eta(idx_max);

            opts_h = odeset('Events', @event_hydro_free_practical, 'RelTol', 1e-7);
            [~, ~, TE_h] = ode15s(@(e, S) ode_handle(e, S, Param), [eta_peak, eta_max], iv_found, opts_h);

            if ~isempty(TE_h)
                Deltas.eta_hid = TE_h(1);
            else
                warning('DELTAS:NotFound', 'Free Hydrodynamic thickness not found after peak.');
            end

            % --- Thermal Thickness (theta = 0.01) ---
            opts_t = odeset('Events', @event_thermal_generic, 'RelTol', 1e-7);
            [~, ~, TE_t] = ode15s(@(e, S) ode_handle(e, S, Param), [0, eta_max], iv_found, opts_t);

            if ~isempty(TE_t)
                Deltas.eta_ter = TE_t(1);
            end

        otherwise
            error('DELTAS:UnknownProblem', 'Problem type "%s" not recognized.', Param.run.problem_str);
    end

    % Store wall gradients for Nu/Cf calculation
    Deltas.fpp_0 = iv_found(3);
    Deltas.tp_0  = iv_found(5);

end

% =========================================================================
% PRIVATE EVENT SUB-FUNCTIONS
% =========================================================================

function [value, isterminal, direction] = event_hydro_forced(~, S)
    % Triggers when f'(eta) reaches 99% of ambient velocity (1.0)
    value      = S(2) - 0.99;
    isterminal = 1; % Stop integration
    direction  = 1; % Detect only when velocity is increasing
end

function [value, isterminal, direction] = event_hydro_free_practical(~, S)
    % Triggers when f'(eta) decays to 0.01 along descending velocity profile
    value      = S(2) - 0.01;
    isterminal = 1;
    direction  = -1; % Detect only when velocity is decreasing
end

function [value, isterminal, direction] = event_thermal_generic(~, S)
    % Triggers when theta(eta) decays to 1% of wall value (1.0)
    value      = S(4) - 0.01;
    isterminal = 1;
    direction  = -1; % Temperature profile is strictly decreasing
end
