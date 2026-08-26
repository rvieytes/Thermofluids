% =========================================================================
% BLSimulation project
% =========================================================================
% Description
%    Exports 2D physical field matrices (mesh coordinates, velocity components,
%    temperature distribution, and stream function) into a long-format CSV
%    file suitable for external post-processing, archiving, or visualization.
%
% Syntax
%    save_physical_fields_csv(PhysicalFields, full_output_path)
%
% Input arguments
%    PhysicalFields   : Structure containing 2D computational field matrices
%                       (.X, .Y, .U, .V, .T, .Theta, and optional .Psi).
%    full_output_path : Target file path for the CSV output file.
%
% Output
%    Generates a comma-separated text file in long format at full_output_path.
%
% Example
%    save_physical_fields_csv(PhysFields, 'output/physical_fields.csv');
%
% Notes
%    - Matrix elements are flattened column-wise into long-format 1D vectors.
%    - Dynamically detects optional stream function field (.Psi) and updates
%      CSV headers accordingly.
%    - High-speed vectorized file writing formatted in scientific notation (%.8e).
%    - Fully compatible with MATLAB and GNU Octave.
%
% See also
%    calculate_physical_fields, save_similarity_fields_csv, fopen, fprintf
%
% Author      : Rvieytes
% Assisted by : Gemini 3.6; OpenAI ChatGPT
% Date        : 15/06/2026
% Version     : 0.0.1
% =========================================================================
function save_physical_fields_csv(PhysicalFields, full_output_path)

    try
        % --- 1. Flatten 2D Grid Matrices into Column Vectors ---
        X_vec     = PhysicalFields.X(:);
        Y_vec     = PhysicalFields.Y(:);
        U_vec     = PhysicalFields.U(:);
        V_vec     = PhysicalFields.V(:);
        T_vec     = PhysicalFields.T(:);
        Theta_vec = PhysicalFields.Theta(:);

        % Conditionally include Stream Function (Psi) if present
        if isfield(PhysicalFields, 'Psi')
            Psi_vec       = PhysicalFields.Psi(:);
            output_matrix = [X_vec, Y_vec, U_vec, V_vec, T_vec, Theta_vec, Psi_vec];
            header_line   = 'x,y,u,v,T,theta,psi';
        else
            output_matrix = [X_vec, Y_vec, U_vec, V_vec, T_vec, Theta_vec];
            header_line   = 'x,y,u,v,T,theta';
        end

        % --- 2. Fast Vectorized File Write ---
        fid = fopen(full_output_path, 'w');
        if fid == -1
            error('PHYS_DATA:FileOpenError', 'Could not open file for writing: %s', full_output_path);
        end

        % Write header line
        fprintf(fid, '%s\n', header_line);

        % Write numerical data with scientific precision (transposed for column-major access)
        num_cols   = size(output_matrix, 2);
        format_str = [repmat('%.8e,', 1, num_cols - 1), '%.8e\n'];
        fprintf(fid, format_str, output_matrix');

        fclose(fid);

        [~, fname, fext] = fileparts(full_output_path);
        fprintf('    > Physical data CSV exported: %s\n', [fname, fext]);

    catch ME
        if exist('fid', 'var') && fid ~= -1
            fclose(fid);
        end
        warning('PHYS_DATA:WriteError', 'Failed to save physical fields CSV: %s', ME.message);
    end

end
