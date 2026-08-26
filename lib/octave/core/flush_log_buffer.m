% =========================================================================
% BLSimulation project
% =========================================================================
% Description
%    Processes queued log entries through log_script and clears the buffer
%    to release memory.
%
% Syntax
%    buffer = flush_log_buffer(buffer, Param, log_fid)
%
% Input arguments
%    buffer  : Cell array containing queued log items, where each item
%              holds {level, format_string, args...}.
%    Param   : Execution configuration and simulation parameter structure.
%    log_fid : File identifier for the target log output file.
%
% Output
%    buffer  : Empty cell array ({}) returned upon successful flushing.
%
% Example
%    log_buffer = flush_log_buffer(log_buffer, Param, log_fid);
%
% Notes
%    - Processes all items sequentially via log_script.
%    - Returns early without action if the input buffer is empty.
%
% See also
%    log_script, log_exec
%
% Author      : Rvieytes
% Assisted by : Gemini 3.6; OpenAI ChatGPT
% Date        : 15/06/2026
% Version     : 0.0.1
% =========================================================================
function buffer = flush_log_buffer(buffer, Param, log_fid)

    if isempty(buffer)
        return;
    end

    for k = 1:length(buffer)
        item  = buffer{k};
        level = item{1};
        fmt   = item{2};
        args  = item(3:end);

        log_script(level, Param, log_fid, fmt, args{:});
    end

    % Clear buffer returning an empty cell array
    buffer = {};

end
