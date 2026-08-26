% =========================================================================
% BLSimulation project
% =========================================================================
% Description
%    Executes mass and energy conservation balance audits across vertical
%    slices of the physical computational domain. Aggregates mass flow
%    and enthalpy residuals into a unified Audit output structure.
%
% Syntax
%    Audit = perform_physical_audit(Fields, Param)
%
% Input arguments
%    Fields : Structure containing 2D computational grid and physical fields
%             (.X, .Y, .U, .V, .T, .q_wall).
%    Param  : Execution configuration and simulation parameter structure.
%
% Output
%    Audit  : Structure containing conservation audit results:
%             .x        - Cell-centered spatial x-coordinate vector [m].
%             .dm_error - Mass conservation residual vector [kg/s].
%             .de_error - Energy conservation residual vector [W].
%
% Example
%    Audit = perform_physical_audit(PhysFields, Param);
%
% Notes
%    - Fully compatible with MATLAB and GNU Octave (uses '%' comments and 'end').
%    - Delegates local residual calculations to mass_conservation_profile
%      and energy_conservation_profile.
%
% See also
%    mass_conservation_profile, energy_conservation_profile
%
% Author      : Rvieytes
% Assisted by : Gemini 3.6; OpenAI ChatGPT
% Date        : 15/06/2026
% Version     : 0.0.1
% =========================================================================
function Audit = perform_physical_audit(Fields, Param)

    % --- 1. Compute Mass and Energy Conservation Residuals ---
    [x_m, dm_err] = mass_conservation_profile(Fields.X, Fields.Y, Fields.U, Fields.V);
    [x_e, de_err] = energy_conservation_profile(Fields, Param);

    % --- 2. Assemble Audit Output Structure ---
    Audit.x        = x_m;
    Audit.dm_error = dm_err;
    Audit.de_error = de_err;

end

