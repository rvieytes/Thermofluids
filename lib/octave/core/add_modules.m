% =========================================================================
% BLSimulation project
% =========================================================================
% Description
%    Loads one or more registered Termofluids modules into the Octave
%    search path.
%
%    Module names are resolved through the central registry defined in
%    config.Maps. Only modules explicitly requested by the user are added
%    to the path.
%
%    This mechanism minimizes namespace pollution and allows user scripts
%    to load only the functionality required for a particular calculation.
%
% Syntax
%    add_modules(MODULE_LIST)
%
% Input arguments
%    MODULE_LIST : Cell array containing module names or aliases.
%                  Registered modules can be referenced either by their
%                  full name or by their alias as defined in config.Maps.
%
% Output
%    None
%
% Example
%    MODULES = { ...
%        'Radiation'; ...
%        'TPD' ...
%    };
%    add_modules(MODULES);
%
% Notes
%    - Modules must be registered in config.Maps.
%    - Duplicate paths are not added.
%    - An error is generated if a module is unknown or if its directory
%      cannot be located.
%
% See also
%    config.Maps
%
% Author      : Rvieytes
% Assisted by : Gemini 3.6; OpenAI ChatGPT
% Date        : 15/06/2026
% Version     : 0.0.1
% =========================================================================
function add_modules(MODULE_LIST)

    if nargin == 0 || isempty(MODULE_LIST)
        return
    end

    if ~iscell(MODULE_LIST)
        error('add_modules: MODULE_LIST must be a cell array of module names.');
    end

    for i = 1:length(MODULE_LIST)

        module_name = MODULE_LIST{i};

        % Ask the master table for the module path
        module_path = config.Maps.getModulePath(module_name);

        if isempty(module_path)
            error('Module [%s] is not registered in Config.Maps.', module_name);
        end

        if exist(module_path, 'dir') ~= 7
            error('Module [%s] directory not found: %s', module_name, module_path);
        end

        % Avoid adding duplicates
        if isempty(strfind(path, module_path))
            addpath(module_path);
            fprintf('Loaded module: %-15s -> %s\n', module_name, module_path);
        end

    end

end
