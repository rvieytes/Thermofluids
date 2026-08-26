% =========================================================================
% BLSimulation project
% =========================================================================
% Description
%    Computes local mass conservation balance residuals across vertical slices
%    of a 2D boundary layer domain. Integrates horizontal mass flux (U) along
%    the Y-coordinate and calculates entrainment/outflow across the top
%    boundary (V) to evaluate slice-by-slice mass conservation accuracy.
%
% Syntax
%    [x_coords, dm_error] = mass_conservation_profile(X, Y, U, V)
%
% Input arguments
%    X        : 2D matrix of horizontal spatial grid coordinates [m].
%    Y        : 2D matrix of vertical spatial grid coordinates [m].
%    U        : 2D matrix of horizontal velocity components [m/s].
%    V        : 2D matrix of vertical velocity components [m/s].
%
% Output
%    x_coords : Vector of cell-centered midpoint x-coordinates [m].
%    dm_error : Local mass balance residual vector across slices [m^2/s].
%
% Example
%    [x_mid, err_mass] = mass_conservation_profile(X, Y, U, V);
%
% Notes
%    - Uses trapezoidal integration along Y at each column to account
%      for non-uniform grid stretching.
%    - Conservation law: m_in - m_out - m_top_out = Residual.
%    - Fully compatible with MATLAB and GNU Octave.
%
% See also
%    energy_conservation_profile, perform_physical_audit, trapz
%
% Author      : Rvieytes
% Assisted by : Gemini 3.6; OpenAI ChatGPT
% Date        : 15/06/2026
% Version     : 0.0.1
% =========================================================================
function [x_coords, dm_error] = mass_conservation_profile(X, Y, U, V)

    % --- 1. Domain Dimensions and Grid Step ---
    [~, nx] = size(U);
    dx      = X(1, 2) - X(1, 1);

    % --- 2. Horizontal Mass Flux Integration ---
    % Traverses each x-station to handle non-uniform Y-grid stretching
    m_dot_x = zeros(1, nx);
    for i = 1:nx
        m_dot_x(i) = trapz(Y(:, i), U(:, i));
    end

    % --- 3. Top Boundary Outflow / Entrainment Flux ---
    m_dot_top = V(end, :) * dx;

    % Midpoint averaging for flux consistency over spatial step dx
    m_top_avg = 0.5 * (m_dot_top(1:end-1) + m_dot_top(2:end));

    % --- 4. Mass Balance Calculation ---
    % Balance equation: m_in - m_out - m_top_out = Residual
    dm_error = m_dot_x(1:end-1) - m_dot_x(2:end) - m_top_avg;

    % Cell-centered X coordinates for plotting and diagnostic analysis
    x_coords = 0.5 * (X(1, 1:end-1) + X(1, 2:end));

end
