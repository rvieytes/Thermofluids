% =========================================================================
% BLSimulation project
% =========================================================================
% Description
%    Executes a command string in the caller workspace, captures its standard
%    console output, and converts it into structured log buffer entries.
%
% Syntax
%    entries = log_function(cmd_str, level)
%
% Input arguments
%    cmd_str : String or character vector containing the command to evaluate.
%    level   : Logging priority level (optional, default = 1).
%
% Output
%    entries : Cell array of formatted log entries compatible with buffer
%              flushing routines, where each element is {level, '%s', line_text}.
%
% Example
%    log_entries = log_function('add_modules({"Radiation"})', 1);
%
% Notes
%    - Uses evalc and evalin('caller', ...) to capture console output
%      without displaying it directly in the terminal.
%    - Splits multi-line string outputs and strips blank lines.
%
% See also
%    flush_log_buffer, log_script, log_exec
%
% Author      : Rvieytes
% Assisted by : Gemini 3.6; OpenAI ChatGPT
% Date        : 15/06/2026
% Version     : 0.0.1
% =========================================================================
function entries = log_function(cmd_str, level)

    entries = {};

    % Default logging level: 1 (INFO)
    if nargin < 2
        level = 1;
    end

    % Capture console output from the caller workspace
    raw_output = evalc('evalin(''caller'',cmd_str)');

    % Parse output line by line, stripping extra whitespace
    lines = strsplit(strtrim(raw_output), sprintf('\n'));
    for k = 1:length(lines)
        line_clean = strtrim(lines{k});
        if ~isempty(line_clean)
            entries{end+1} = {level, '%s', line_clean};
        end
    end

end
