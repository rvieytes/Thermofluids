% =========================================================================
% BLSimulation project
% =========================================================================
% Description
%    Defines the system of first-order ordinary differential equations (ODEs)
%    for forced convection boundary layer flow over a flat plate (Blasius
%    momentum and Pohlhausen energy equations with optional viscous dissipation).
%
% Syntax
%    dS_deta = forced_convection_edo(eta, S, Param)
%
% Input arguments
%    eta     : Similarity variable (independent variable required by ODE solvers).
%    S       : State vector [f; f'; f''; g; g'].
%              - S(1) = f   : Dimensionless stream function
%              - S(2) = f'  : Dimensionless velocity profile (u / U_inf)
%              - S(3) = f'' : Dimensionless shear stress derivative
%              - S(4) = g   : Dimensionless temperature profile (theta)
%              - S(5) = g'  : Dimensionless temperature gradient
%    Param   : Execution configuration and simulation parameter structure
%              containing physical properties (Param.phys.Pr, Param.phys.Ec).
%
% Output
%    dS_deta : Column vector of state variable derivatives [f'; f''; f'''; g'; g''].
%
% Example
%    dS = forced_convection_edo(0.5, [0; 0.1; 0.33; 1; -0.3], Param);
%
% Notes
%    - Momentum equation: f''' + 0.5 * f * f'' = 0 (Blasius)
%    - Energy equation:   g'' + 0.5 * Pr * f * g' + Pr * Ec * (f'')^2 = 0
%    - Includes numerical stability check to halt integration on NaN detection.
%
% See also
%    free_convection_edo, bvp_shooting_solver
%
% Author      : Rvieytes
% Assisted by : Gemini 3.6; OpenAI ChatGPT
% Date        : 15/06/2026
% Version     : 0.0.1
% =========================================================================
function dS_deta = forced_convection_edo(eta, S, Param)

    % --- Numerical Stability Check ---
    if any(isnan(S))
        error('forced_convection_edo:NaN', 'NaN detected at eta = %f', eta);
    end

    % --- Physical Parameters Extraction ---
    prandtl = Param.phys.Pr;
    eckert  = Param.phys.Ec;

    % --- State Variables ---
    f    = S(1);
    f_p  = S(2); % f'
    f_pp = S(3); % f''
    g    = S(4); % g (theta)
    g_p  = S(5); % g'

    % --- First-Order Differential Equations System ---
    dS_deta = zeros(5, 1);

    % Equation 1: d(f)/d(eta) = f'
    dS_deta(1) = f_p;

    % Equation 2: d(f')/d(eta) = f''
    dS_deta(2) = f_pp;

    % Equation 3 (Blasius Momentum): f''' = -0.5 * f * f''
    dS_deta(3) = -0.5 * f * f_pp;

    % Equation 4: d(g)/d(eta) = g'
    dS_deta(4) = g_p;

    % Equation 5 (Pohlhausen Energy with Viscous Dissipation):
    % g'' = -Pr * (0.5 * f * g' + Ec * (f'')^2)
    dS_deta(5) = -prandtl * (0.5 * f * g_p + eckert * f_pp^2);

end

