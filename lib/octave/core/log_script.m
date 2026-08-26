% =========================================================================
% BLSimulation project
% =========================================================================
% Description
%    Dual logging system (screen console and .log file output) supporting
%    verbosity filtering, message tagging, and sprintf-style formatting.
%
% Syntax
%    log_script(level, Param, log_fid, fmt)
%    log_script(level, Param, log_fid, fmt, ...)
%
% Input arguments
%    level    : Logging level identifier:
%               -1 : RAW mode (unformatted, no tags or timestamps)
%                0 : FATAL
%                1 : INFO
%                2 : DEBUG
%               >=3: TRACE
%    Param    : Parameter structure containing Param.run.verbose_level.
%    log_fid  : File identifier for target log file (must be > 0 to write).
%    fmt      : Character vector or string containing format specifiers.
%    varargin : Optional arguments for sprintf formatting.
%
% Output
%    None
%
% Example
%    log_script(-1, Param, log_fid, '========================================');
%    log_script( 0, Param, log_fid, 'Critical error: %s', err.message);
%    log_script( 1, Param, log_fid, 'Processing step %d of %d', i, N);
%    log_script( 2, Param, log_fid, 'Iteration value x = %.6f', x);
%
% Notes
%    - RAW mode (level = -1) omits tags and timestamps, ideal for banners.
%    - Console output is filtered based on Param.run.verbose_level.
%    - File output includes timestamping [HH:MM:SS] and forces immediate
%      disk write via fflush.
%
% See also
%    log_exec, flush_log_buffer, log_function
%
% Author      : Rvieytes
% Assisted by : Gemini 3.6; OpenAI ChatGPT
% Date        : 15/06/2026
% Version     : 0.0.1
% =========================================================================
function log_script(level, Param, log_fid, fmt, varargin)

    % 1. Determine console verbosity limit
    verbose_limit = 1; % Default value
    if isstruct(Param) && isfield(Param, 'run') && isfield(Param.run, 'verbose_level')
        verbose_limit = Param.run.verbose_level;
    end

    % 2. Format message if sprintf arguments are provided
    if nargin > 4
        msg = sprintf(fmt, varargin{:});
    else
        msg = fmt;
    end

    % 3. RAW MODE (level = -1): No tags or timestamps, ideal for banners
    if level == -1
        if verbose_limit >= 1
            fprintf('%s\n', msg);
        end
        if exist('log_fid', 'var') && log_fid > 0
            fprintf(log_fid, '%s\n', msg);
            fflush(log_fid);
        end
        return;
    end

    % 4. STRUCTURED MODE (level >= 0): Tag assignment
    switch level
        case 0, tag = 'FATAL';
        case 1, tag = 'INFO ';
        case 2, tag = 'DEBUG';
        otherwise, tag = 'TRACE';
    end

    timestamp = datestr(now, 'HH:MM:SS');

    % 5. Console output (filtered by verbose_level)
    if verbose_limit >= level
        fprintf('[%s] %s\n', tag, msg);
    end

    % 6. File output (complete execution record)
    if exist('log_fid', 'var') && log_fid > 0
        fprintf(log_fid, '[%s][%s] %s\n', timestamp, tag, msg);
        fflush(log_fid); % Force immediate write to disk
    end

end
