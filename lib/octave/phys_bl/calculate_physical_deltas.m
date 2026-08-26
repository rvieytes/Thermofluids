% =========================================================================
% BLSimulation project
% =========================================================================
% Description
%    Converts dimensionless boundary layer thicknesses (eta_hid, eta_ter)
%    into physical dimensional values in meters along specified spatial
%    coordinates (x_coords) on the plate.
%
% Syntax
%    PhysicalDeltas = calculate_physical_deltas(Deltas_adim, Param, x_coords)
%
% Input arguments
%    Deltas_adim    : Structure containing dimensionless thicknesses
%                     (.eta_hid, .eta_ter) computed by calculate_deltas.
%    Param          : Execution configuration and simulation parameter structure.
%    x_coords       : Vector of spatial positions along the plate [m].
%
% Output
%    PhysicalDeltas : Structure containing physical boundary layer profiles:
%                     .h_fis    : Hydrodynamic boundary layer thickness [m].
%                     .t_fis    : Thermal boundary layer thickness [m].
%                     .x_coords : Echoed spatial coordinate vector [m].
%
% Example
%    x_grid = linspace(0.01, 1.0, 100);
%    PhysDeltas = calculate_physical_deltas(Deltas, Param, x_grid);
%
% Notes
%    - Forced convection similarity scaling: delta(x) = eta * sqrt(nu * x / U_inf).
%    - Free convection similarity scaling: delta(x) = eta * (L / Gr_L^(1/4)) * (x / L)^(1/4).
%
% See also
%    calculate_deltas
%
% Author      : Rvieytes
% Assisted by : Gemini 3.6; OpenAI ChatGPT
% Date        : 15/06/2026
% Version     : 0.0.1
% =========================================================================
function PhysicalDeltas = calculate_physical_deltas(Deltas_adim, Param, x_coords)

    % Initialize output structure
    PhysicalDeltas.h_fis    = [];
    PhysicalDeltas.t_fis    = [];
    PhysicalDeltas.x_coords = x_coords;

    % Local references for cleaner equations
    phys = Param.phys;

    switch upper(Param.run.problem_str)
        case 'FORCED'
            % For Forced Convection: delta = eta * sqrt(nu * x / U_inf)
            U_inf = phys.U_inf;
            nu    = phys.nu;

            scale_factor = sqrt((nu * x_coords) / U_inf);

            PhysicalDeltas.h_fis = Deltas_adim.eta_hid * scale_factor;
            PhysicalDeltas.t_fis = Deltas_adim.eta_ter * scale_factor;

        case 'FREE'
            % For Free Convection: delta = eta * C * (x/L)^(1/4)
            % where C = L / (Gr_L)^(1/4)
            L    = phys.L_plate;
            Gr_L = phys.Gr;

            % Scale factor for natural convection similarity
            C = L / (Gr_L)^(1/4);
            scale_factor = C * (x_coords / L).^(1/4);

            PhysicalDeltas.h_fis = Deltas_adim.eta_hid * scale_factor;
            PhysicalDeltas.t_fis = Deltas_adim.eta_ter * scale_factor;

        otherwise
            error('PHYS_DELTAS:UnknownProblem', 'Unknown problem type: %s', Param.run.problem_str);
    end

end
