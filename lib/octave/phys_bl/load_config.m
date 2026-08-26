% =========================================================================
% BLSimulation project
% =========================================================================
% Description
%    Modular configuration orchestrator for thermofluid simulation suites.
%    Loads physical, numerical, grid, and flag parameters by executing a master
%    launcher configuration script and its dependencies sequentially.
%
% Syntax
%    [Param, flg, cfg, sOutputFile] = load_config(MASTER_NAME)
%
% Input arguments
%    MASTER_NAME : String specifying the master configuration script name
%                  (e.g., 'main_launcher.m').
%
% Output arguments
%    Param       : Global simulation parameters structure.
%    flg         : Execution, visualization, and audit flags structure.
%    cfg         : Configuration script path mappings.
%    sOutputFile : Output directories and file conventions structure.
%
% Example
%    [Param, flg, cfg, sOutputFile] = load_config('main_launcher.m');
%
% Notes
%    - Includes defensive initialization of Param.run fields to prevent
%      unbound structure errors during sequential script execution.
%    - Fully compatible with MATLAB and GNU Octave.
%
% See also
%    main_launcher, load_execution_flags, load_numerical_config
%
% Author      : Rvieytes
% Assisted by : Gemini 3.6; OpenAI ChatGPT
% Date        : 15/06/2026
% Version     : 0.0.1
% =========================================================================
function [Param, flg, cfg, sOutputFile] = load_config(MASTER_NAME)

    % Initialize output structures
    flg         = struct();
    Param       = struct();
    cfg         = struct();
    sOutputFile = struct();

    try
        fprintf('\n--- Initializing Simulation Environment ---\n');

        % --- 1. LOAD MASTER CONFIGURATION FILE ---
        if safe_exists(MASTER_NAME, 'Master Config')
            run(MASTER_NAME);
        else
            error('CONFIG:MasterNotFound', 'Critical: Master file "%s" not found.', MASTER_NAME);
        end

        % Defensive Guardrail: Ensure Param.run structure exists before loading child scripts
        if ~isfield(Param, 'run')
            Param.run = struct();
        end
        if ~isfield(Param.run, 'mode')
            Param.run.mode = 'DIMENSIONLESS';
        end
        if ~isfield(Param.run, 'problem_str')
            Param.run.problem_str = 'FREE';
        end

        % --- 2. SEQUENTIAL SUB-CONFIGURATION EXECUTION ---
        fields = {'phys', 'flags', 'tolerances', 'output', 'numerical'};

        for k = 1:length(fields)
            f_name = fields{k};

            if isfield(cfg, f_name)
                file_to_run = cfg.(f_name);

                if safe_exists(file_to_run, f_name)
                    run(file_to_run);
                else
                    error('CONFIG:FileNotFound', ...
                        'The file "%s" defined in cfg.%s does not exist on the path.', file_to_run, f_name);
                end
            else
                error('CONFIG:MissingField', ...
                    'The Master script did not define the required field: cfg.%s', f_name);
            end
        end

        fprintf('--- Configuration Loaded Successfully ---\n\n');

    catch ME
        % --- ERROR HANDLING & REPORTING ---
        fprintf(['\n', repmat('!', 1, 60), '\n']);
        fprintf('  FATAL ERROR: Configuration sequence interrupted.\n');
        fprintf('  Reason: %s\n', ME.message);

        if ~isempty(ME.stack)
            fprintf('  Location: %s (Line %d)\n', ME.stack(1).name, ME.stack(1).line);
        end

        fprintf(['\n', repmat('!', 1, 60), '\n']);

        rethrow(ME);
    end

end

% =========================================================================
% --- PRIVATE SUB-FUNCTIONS ---
% =========================================================================

function ok = safe_exists(filename, label)
    % SAFE_EXISTS Checks for file presence on search path and returns boolean.

    filepath = which(filename);

    if ~isempty(filepath)
        fprintf('   > Loading %-12s: %s\n', [label ':'], filename);
        ok = true;
    else
        line_str = repmat('*', 1, 60);
        fprintf(['\n', line_str, '\n']);
        fprintf('[FATAL ERROR] %s file not found!\n', upper(label));
        fprintf('Target  : "%s"\n', filename);
        fprintf('Context : Expected by the Master configuration.\n');
        fprintf([line_str, '\n']);
        ok = false;
    end
end
