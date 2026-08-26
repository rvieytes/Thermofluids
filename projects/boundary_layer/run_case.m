% ===================================================================
% ==              MAIN SIMULATION LAUNCHER                         ==
% ===================================================================
% This script initializes the environment and selects the problem type.


% --- 1. PROBLEM SELECTION & INPUT MODE ---
% Options: 'FORCED' (Blasius/Pohlhausen) or 'FREE' (Vertical Plate)
% Modes: 'PHYSICAL' (SI Units) or 'DIMENSIONLESS' (Direct Re, Pr, Ec, Gr)
target_problem = 'FORCED';
input_mode     = 'DIMENSIONLESS';

fprintf('Initializing Simulation Environment...\n');

% --- 2. MODULAR CONFIGURATION FILES ASSIGNMENT ---
% These files contain the fine-tuning of flags, tolerances, and names.

cfg.flags      = 'set_flags.m';
cfg.tolerances = 'set_tolerances.m';
cfg.output     = 'set_output_files.m';
#cfg.control    = 'set_control.m';
cfg.numerical  = 'set_numerical.m';

% --- 3. PARAMETER FILE SELECTION LOGIC ---
% Selects the physical and numerical parameter file based on Section 1.
if strcmpi(target_problem, 'FORCED')
    cfg.phys = 'set_params_forced.m';
elseif strcmpi(target_problem, 'FREE')
    cfg.phys = 'set_params_free.m';
else
    % Fail-Fast check: Immediate error for invalid strings.
    error('Problem type "%s" not recognized. Use ''FORCED'' or ''FREE''.', target_problem);
end

% --- 4. INITIALIZE PARAM STRUCTURE ---
% We pre-fill the run metadata so later scripts know the context.
Param = struct();
Param.run.problem_str   = upper(target_problem);
Param.run.mode          = upper(input_mode);
Param.run.verbose_level = 1; % 0: Minimal, 1: Normal, 2: Detailed
Param.run.log_file      = 'last_run-t.log';

% Constant physical values
%Param.phys.g = 9.81;

fprintf('   > Problem: %s\n', Param.run.problem_str);
fprintf('   > Mode:    %s\n', Param.run.mode);

fprintf('Launcher initialization complete.\n');



