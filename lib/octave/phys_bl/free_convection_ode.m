% =========================================================================
% BLSimulation project
% =========================================================================
% Description
%    Defines the system of coupled first-order ordinary differential equations
%    (ODEs) for free (natural) convection boundary layer flow along a vertical
%    flat plate using Ostrach similarity scaling.
%
% Syntax
%    dS_deta = free_convection_ode(eta, S, Param)
%
% Input arguments
%    eta     : Similarity variable (independent variable required by ODE solvers).
%    S       : State vector [f; f'; f''; theta; theta'].
%              - S(1) = f       : Dimensionless stream function
%              - S(2) = f'      : Dimensionless vertical velocity component
%              - S(3) = f''     : Dimensionless shear stress derivative
%              - S(4) = theta   : Dimensionless temperature profile
%              - S(5) = theta'  : Dimensionless temperature gradient
%    Param   : Execution configuration and simulation parameter structure
%              containing physical properties (Param.phys.Pr).
%
% Output
%    dS_deta : Column vector of state variable derivatives [f'; f''; f'''; theta'; theta''].
%
% Example
%    dS = free_convection_ode(0.5, [0; 0; 0.6; 1; -0.5], Param);
%
% Notes
%    - Momentum equation: f''' + 0.75 * f * f'' - 0.5 * (f')^2 + theta = 0
%    - Energy equation:   theta'' + 0.75 * Pr * f * theta' = 0
%    - Formulated according to Ostrach similarity transformation scaling coefficients.
%
% See also
%    forced_convection_edo, bvp_shooting_solver
%
% Author      : Rvieytes
% Assisted by : Gemini 3.6; OpenAI ChatGPT
% Date        : 15/06/2026
% Version     : 0.0.1
% =========================================================================
function dS_deta = free_convection_ode(eta, S, Param)

    % --- Numerical Stability Check ---
    if any(isnan(S))
        error('free_convection_ode:NaN', 'NaN detected at eta = %f', eta);
    end

    % --- Physical Parameters Extraction ---
    Pr = Param.phys.Pr;

    % --- State Variables ---
    f       = S(1);
    f_p     = S(2); % f'
    f_pp    = S(3); % f''
    theta   = S(4); % theta
    theta_p = S(5); % theta'

    % --- First-Order Differential Equations System ---
    dS_deta = zeros(5, 1);

    % Equation 1: d(f)/d(eta) = f'
    dS_deta(1) = f_p;

    % Equation 2: d(f')/d(eta) = f''
    dS_deta(2) = f_pp;

    % Equation 3 (Buoyancy-Coupled Momentum):
    % f''' = 0.5*(f')^2 - 0.75*f*f'' - theta
    dS_deta(3) = 0.5 * (f_p^2) - 0.75 * f * f_pp - theta;

    % Equation 4: d(theta)/d(eta) = theta'
    dS_deta(4) = theta_p;

    % Equation 5 (Energy):
    % theta'' = -0.75 * Pr * f * theta'
    dS_deta(5) = -0.75 * Pr * f * theta_p;

end
