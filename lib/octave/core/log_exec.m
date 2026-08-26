% =========================================================================
% BLSimulation project
% =========================================================================
% Description
%    Executes a command string within the caller workspace, captures its
%    console output, retrieves the updated Param structure, and routes each
%    output line immediately to log_script.
%
% Syntax
%    log_exec(cmd_str, level, log_fid)
%
% Input arguments
%    cmd_str : Character vector or string containing the command to evaluate.
%    level   : Logging verbosity level (optional, default = 1).
%    log_fid : File identifier for the target log output file.
%
% Output
%    None
%
% Example
%    log_exec('run_solver_step()', 1, log_fid);
%
% Notes
%    - Uses evalc and evalin('caller', ...) to capture console output without
%      printing directly to the terminal.
%    - Dynamically retrieves the updated Param variable from the caller workspace
%      to apply updated logging/verbosity settings.
%    - Splits multi-line output and passes each non-empty line to log_script.
%
% See also
%    log_script, log_function, flush_log_buffer
%
% Author      : Rvieytes
% Assisted by : Gemini 3.6; OpenAI ChatGPT
% Date        : 15/06/2026
% Version     : 0.0.1
% =========================================================================
function log_exec(cmd_str, level, log_fid)

    if nargin < 2 || isempty(level)
        level = 1;
    end

    % 1. Execute command in caller workspace and capture console output
    raw_output = evalc('evalin(''caller'', cmd_str)');

    % 2. Retrieve updated Param structure from caller workspace
    Param = evalin('caller', 'Param');

    % 3. Parse output line by line and route immediately to log_script
    lines = strsplit(strtrim(raw_output), sprintf('\n'));
    for k = 1:length(lines)
        line_clean = strtrim(lines{k});
        if ~isempty(line_clean)
            log_script(level, Param, log_fid, '%s', line_clean);
        end
    end

end
