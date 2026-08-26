% =========================================================================
% BLSimulation project
% =========================================================================
% Description
%    Subsamples 2D spatial physical velocity fields (X, Y, U, V) and exports
%    the resulting vector grid to a comma-separated value (.csv) file for
%    quiver plotting in external visualization toolchains (ParaView, Python, etc.).
%
% Syntax
%    save_quiver_data(PhysicalFields, full_output_path, Param)
%
% Input arguments
%    PhysicalFields   : Structure containing full 2D mesh and velocity fields:
%                       - .X : 2D grid matrix of X coordinates [m]
%                       - .Y : 2D grid matrix of Y coordinates [m]
%                       - .U : 2D grid matrix of horizontal velocity components [m/s]
%                       - .V : 2D grid matrix of vertical velocity components [m/s]
%    full_output_path : Full target file path for CSV export (including extension).
%    Param            : Parameter structure containing .num.quiver.step
%                       subsampling stride factor.
%
% Output
%    None (generates .csv file on disk).
%
% Example
%    save_quiver_data(PhysicalFields, 'outputs/quiver_data.csv', Param);
%
% Notes
%    - Uses step sampling stride (Param.num.quiver.step) to prevent visual
%      clutter in vector field exports.
%    - Fully compatible with MATLAB and GNU Octave.
%
% See also
%    save_deltas_profiles, load_numerical_config, main_BL_simulation
%
% Author      : Rvieytes
% Assisted by : Gemini 3.6; OpenAI ChatGPT
% Date        : 15/06/2026
% Version     : 0.0.1
% =========================================================================
function save_quiver_data(PhysicalFields, full_output_path, Param)

    try
        fprintf('   > Subsampling vector field data for quiver export (.csv)... ');

        % --- 1. DIRECTORY VALIDATION & CREATION ---
        out_dir = fileparts(full_output_path);
        if ~isempty(out_dir) && ~exist(out_dir, 'dir')
            mkdir(out_dir);
        end

        % --- 2. EXTRACT FULL FIELDS FROM MEMORY ---
        X = PhysicalFields.X;
        Y = PhysicalFields.Y;
        U = PhysicalFields.U;
        V = PhysicalFields.V;

        % --- 3. FIELD SUBSAMPLING (STRIDE SAMPLING) ---
        if isfield(Param, 'num') && isfield(Param.num, 'quiver') && isfield(Param.num.quiver, 'step')
            step = Param.num.quiver.step;
        elseif isfield(Param, 'Numerical') && isfield(Param.Numerical, 'Quiver') && isfield(Param.Numerical.Quiver, 'step')
            step = Param.Numerical.Quiver.step;
        else
            step = 2; % Fallback sampling stride
        end

        X_q = X(1:step:end, 1:step:end);
        Y_q = Y(1:step:end, 1:step:end);
        U_q = U(1:step:end, 1:step:end);
        V_q = V(1:step:end, 1:step:end);

        % --- 4. DATA MATRIX ASSEMBLY & CSV FILE EXPORT ---
        output_matrix = [X_q(:), Y_q(:), U_q(:), V_q(:)];

        fid = fopen(full_output_path, 'w');
        if fid == -1
            error('EXPORT:FileOpenError', 'Cannot create output file at path: %s', full_output_path);
        end

        fprintf(fid, 'x,y,u,v\n'); % Header
        fprintf(fid, '%.6e,%.6e,%.6e,%.6e\n', output_matrix'); % Tabular CSV export
        fclose(fid);

        [~, fname, ext] = fileparts(full_output_path);
        fprintf('Done.\n');
        fprintf('     - Quiver vector data saved : %s\n', [fname, ext]);

    catch ME
        warning('EXPORT:QuiverWriteFailure', 'Failed to generate quiver CSV file. Reason: %s', ME.message);
    end

end
