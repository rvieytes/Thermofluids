% =========================================================================
% TERMOFLUIDS PROJECT
% =========================================================================
% Description
% Central registry for the Termofluids repository.
%
%   This class provides a unique mapping between logical module names
%   and their physical locations inside the repository.
%
%   The objective is to avoid hard-coded paths throughout the codebase.
%   User scripts request modules by name, while Maps resolves the
%   corresponding directory or application path.
%
% Responsibilities
%   - Resolve Octave module locations.
%   - Resolve Python application locations.
%   - Provide aliases for registered modules.
%
% Notes
%   All module and application registrations must be performed through
%   the tables defined in this class.
%
% See also
%   add_modules
%
% Author      : Rvieytes
% Assisted by : OpenAI ChatGPT
% Date        : 15/06/2026
% Version     : 1.0.0
% =========================================================================
classdef Maps
    properties (Constant)

        % ==========================================================
        % Octave modules
        % {LongName, Alias, RelativePath}
        % ==========================================================
        Moduls = { ...
            'Radiation',      'RAD',  'phys_rad'; ...
            'Thermophysical', 'TPD',  'phys_tp'; ...
            'BoundaryLayer',  'BL',   'phys_bl'; ...
            'InternalFlows',  'IF',   'phys_if'; ...
            'FreeConv',       'FC',   'phys_fc'; ...
            'ForcedConv',     'FRC',  'phys_forcedconv'; ...
        };

    end

    methods (Static)

        % ----------------------------------------------------------
        % Return module path
        % ----------------------------------------------------------
        function modpath = getModulePath(name)

            % =============================================================
            % getModulePath
            % =============================================================
            % Description
            %   Returns the absolute path of a registered Octave module.
            %
            % Syntax
            %   modpath = config.Maps.getModulePath(name)
            %
            % Input arguments
            %   name : Module name or alias.
            %
            % Output
            %   modpath : Absolute path to the module directory.
            %             Empty string if the module is not registered.
            %
            % =============================================================

            idx = strcmpi(name, config.Maps.Moduls(:,1));

            if ~any(idx)
                idx = strcmpi(name, config.Maps.Moduls(:,2));
            end

            if any(idx)

                module_dir = config.Maps.Moduls{idx,3};

                modpath = fullfile( ...
                    fileparts(fileparts(mfilename('fullpath'))), ...
                    module_dir);

            else

                modpath = '';

            end

        end


        % ----------------------------------------------------------
        % Return module alias
        % ----------------------------------------------------------
        function suffix = getSuffix(name)

            % =============================================================
            % getSuffix
            % =============================================================
            % Description
            %   Returns the alias associated with a registered module.
            %
            % Syntax
            %   suffix = config.Maps.getSuffix(name)
            %
            % Input arguments
            %   name : Registered module name.
            %
            % Output
            %   suffix : Module alias.
            %
            % =============================================================

            idx = strcmpi(name, config.Maps.Moduls(:,1));

            if any(idx)

                suffix = config.Maps.Moduls{idx,2};

            else

                suffix = name;

            end

        end

    end

end
