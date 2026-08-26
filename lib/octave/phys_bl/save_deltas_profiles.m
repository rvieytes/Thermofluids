% =========================================================================
% BLSimulation project
% =========================================================================
% Description
%    Exports physical hydrodynamic and thermal boundary layer thickness
%    profiles (delta_h(x) and delta_t(x)) to tab-delimited ASCII .dat files
%    including descriptive header columns.
%
% Syntax
%    save_deltas_profiles(x_coords, PhysicalDeltas, sOutputFile)
%
% Input arguments
%    x_coords       : Vector of streamwise spatial coordinates along plate [m].
%    PhysicalDeltas : Structure containing physical thickness arrays:
%                     - .h_fis : Hydrodynamic boundary layer thickness [m]
%                     - .t_fis : Thermal boundary layer thickness [m]
%    sOutputFile    : Structure containing file naming conventions and paths:
%                     - .BL_Data_HydroProfile : Base name for hydrodynamic profile
%                     - .BL_Data_ThermProfile : Base name for thermal profile
%                     - .tail                 : Case identifier string
%                     - .dir_outputs          : Target export directory path
%
% Output
%    None (generates .dat files on disk).
%
% Example
%    save_deltas_profiles(x_mesh, PhysicalDeltas, sOutputFile);
%
% Notes
%    - Data columns are formatted using double precision exponential notation (%.6e).
%    - Automatically creates the output directory if it does not exist on disk.
%    - Fully compatible with MATLAB and GNU Octave.
%
% See also
%    load_output_config, main_BL_simulation
%
% Author      : Rvieytes
% Assisted by : Gemini 3.6; OpenAI ChatGPT
% Date        : 15/06/2026
% Version     : 0.0.1
% =========================================================================
function save_deltas_profiles(x_coords, PhysicalDeltas, sOutputFile)

    try
        fprintf('   > Saving physical boundary layer thickness profiles (.dat)... ');

        % --- 1. DIRECTORY VALIDATION & CREATION ---
        if ~exist(sOutputFile.dir_outputs, 'dir')
            mkdir(sOutputFile.dir_outputs);
        end

        % --- 2. FILE PATH CONSTRUCTION ---
        base_name_h = sOutputFile.BL_Data_HydroProfile;
        base_name_t = sOutputFile.BL_Data_ThermProfile;

        fname_h = sprintf('%s%s.dat', base_name_h, sOutputFile.tail);
        fname_t = sprintf('%s%s.dat', base_name_t, sOutputFile.tail);

        path_h = fullfile(sOutputFile.dir_outputs, fname_h);
        path_t = fullfile(sOutputFile.dir_outputs, fname_t);

        % --- 3. EXPORT HYDRODYNAMIC BOUNDARY LAYER PROFILE ---
        fid_h = fopen(path_h, 'w');
        if fid_h == -1
            error('EXPORT:FileOpenError', 'Cannot create hydrodynamic file at path: %s', path_h);
        end
        fprintf(fid_h, 'x_m\tdelta_h_m\n'); % Column header
        data_h = [x_coords(:), PhysicalDeltas.h_fis(:)];
        fprintf(fid_h, '%.6e\t%.6e\n', data_h'); % Matrix export
        fclose(fid_h);

        % --- 4. EXPORT THERMAL BOUNDARY LAYER PROFILE ---
        fid_t = fopen(path_t, 'w');
        if fid_t == -1
            error('EXPORT:FileOpenError', 'Cannot create thermal file at path: %s', path_t);
        end
        fprintf(fid_t, 'x_m\tdelta_t_m\n'); % Column header
        data_t = [x_coords(:), PhysicalDeltas.t_fis(:)];
        fprintf(fid_t, '%.6e\t%.6e\n', data_t'); % Matrix export
        fclose(fid_t);

        fprintf('Done.\n');
        fprintf('     - Hydrodynamic profile saved : %s\n', fname_h);
        fprintf('     - Thermal profile saved      : %s\n', fname_t);

    catch ME
        warning('EXPORT:WriteFailure', 'Failed to save thickness profiles. Reason: %s', ME.message);
    end

end


