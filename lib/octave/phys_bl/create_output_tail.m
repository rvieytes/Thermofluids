% =========================================================================
% BLSimulation project
% =========================================================================
% Description
%    Generates a unique, filesystem-safe tail string for output filenames
%    based on key dimensionless parameters (Prandtl, Eckert, and Reynolds
%    or Grashof numbers). Replaces decimal dots and sign/exponent characters
%    to ensure complete cross-platform filesystem compatibility.
%
% Syntax
%    tail = create_output_tail(Param)
%
% Input arguments
%    Param : Parameter structure containing simulation parameters in
%            Param.run and physical parameters in Param.phys.
%
% Output
%    tail  : Character vector representing the formatted suffix string
%            (e.g., '-CL-Pr0p7-Ec0-Gr15000').
%
% Example
%    tail = create_output_tail(Param);
%    filename = ['results', tail, '.mat'];
%
% Notes
%    - Problem type prefix: 'CF' for Forced Convection, 'CL' for Free Convection.
%    - Replaces '.' with 'p', 'e-' with 'eneg', and 'e+' with 'e'.
%
% See also
%    sprintf, strrep
%
% Author      : Rvieytes
% Assisted by : Gemini 3.6; OpenAI ChatGPT
% Date        : 15/06/2026
% Version     : 0.0.1
% =========================================================================
function tail = create_output_tail(Param)

    % --- 1. Determine Problem Prefix ---
    if strcmpi(Param.run.problem_str, 'FORCED')
        prefix = 'CF'; % Forced Convection
    else
        prefix = 'CL'; % Free Convection
    end

    % --- 2. Format Parameters with Robust Logic ---

    % Prandtl: Replace '.' with 'p'
    pr_str = strrep(sprintf('Pr%.6g', Param.phys.Pr), '.', 'p');

    % Eckert: Handle near-zero values and scientific notation
    ec_val = Param.phys.Ec;
    if abs(ec_val) < 1e-9
        ec_val = 0;
    end
    ec_str_base = sprintf('Ec%.6g', ec_val);

    % Replace '.' with 'p', 'e-' with 'eneg', and 'e+' with 'e'
    ec_str = strrep(strrep(strrep(ec_str_base, '.', 'p'), 'e-', 'eneg'), 'e+', 'e');

    % Reynolds or Grashof: Depending on problem type
    if strcmpi(Param.run.problem_str, 'FORCED')
        flow_val   = Param.phys.Re;
        flow_label = 'Re';
    else
        flow_val   = Param.phys.Gr;
        flow_label = 'Gr';
    end

    flow_str_base  = sprintf('%s%.6g', flow_label, flow_val);
    flow_param_str = strrep(strrep(strrep(flow_str_base, '.', 'p'), 'e-', 'eneg'), 'e+', 'e');

    % --- 3. Final Tail Assembly ---
    tail = ['-', prefix, '-', pr_str, '-', ec_str, '-', flow_param_str];

end
