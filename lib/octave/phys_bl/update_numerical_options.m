% =========================================================================
% BLSimulation project
% =========================================================================
% Description
%    Re-generates numerical control objects (root-finder and ODE solver
%    options) within the Param structure. Updates solver settings if
%    eta_max or numerical tolerances were modified during execution.
%
% Syntax
%    Param = update_numerical_options(Param)
%
% Input arguments
%    Param : Parameter structure containing numerical settings in Param.num.
%
% Output
%    Param : Updated parameter structure with refreshed opts_fsolve and
%            opts_ode option structures.
%
% Example
%    Param.num.eta_max = 12.0;
%    Param = update_numerical_options(Param);
%
% Notes
%    - Updates fsolve options using Param.num.TolFun (default: 1e-8).
%    - Updates ODE integrator options using Param.num.RelTol (default: 1e-6)
%      and Param.num.AbsTol (default: 1e-8).
%
% See also
%    optimset, odeset
%
% Author      : Rvieytes
% Assisted by : Gemini 3.6; OpenAI ChatGPT
% Date        : 15/06/2026
% Version     : 0.0.1
% =========================================================================
function Param = update_numerical_options(Param)

    % 1. Update Root-Finder Options (fsolve)
    tol_fun = 1e-8;
    if isfield(Param.num, 'TolFun')
        tol_fun = Param.num.TolFun;
    end

    Param.num.opts_fsolve = optimset('Display', 'iter', ...
        'TolFun', tol_fun, ...
        'MaxIter', 100);

    % 2. Update ODE Integrator Options (ode15s/ode45)
    rel_tol = 1e-6;
    abs_tol = 1e-8;

    if isfield(Param.num, 'RelTol')
        rel_tol = Param.num.RelTol;
    end
    if isfield(Param.num, 'AbsTol')
        abs_tol = Param.num.AbsTol;
    end

    Param.num.opts_ode = odeset( ...
        'RelTol', rel_tol, ...
        'AbsTol', abs_tol);

    % 3. Log the update
    fprintf('    > Numerical options updated (eta_max = %.1f).\n', Param.num.eta_max);

end
