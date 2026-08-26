% =========================================================================
% BLSimulation project
% =========================================================================
% Description
%    Exports 1D dimensionless similarity profiles (eta vs. state functions)
%    to a CSV file. The generated dataset is independent of physical scales
%    and represents the fundamental solution to the boundary layer ODEs.
%
% Syntax
%    save_similarity_fields_csv(eta, sol_profiles, full_output_path)
%
% Input arguments
%    eta              : Column or row vector of similarity variable eta.
%    sol_profiles     : Matrix of similarity profile states [f, f', f'', g, g'].
%    full_output_path : Target file path for the CSV output file.
%
% Output
%    Generates a comma-separated text file at full_output_path.
%
% Example
%    save_similarity_fields_csv(eta, profiles, 'output/similarity_data.csv');
%
% Notes
%    - Automatically builds headers [eta, f, f_p, f_pp, g, g_p] for 6-column
%      data or generic indexed column headers [eta, y1, y2, ...] otherwise.
%    - Writes floating-point values in high-precision scientific format (%.10e).
%    - Fully compatible with MATLAB and GNU Octave.
%
% See also
%    bvp_shooting_solver, calculate_physical_fields, fopen, fprintf
%
% Author      : Rvieytes
% Assisted by : Gemini 3.6; OpenAI ChatGPT
% Date        : 15/06/2026
% Version     : 0.0.1
% =========================================================================
function save_similarity_fields_csv(eta, sol_profiles, full_output_path)

    try
        % --- 1. Prepare Output Matrix ---
        % Ensure eta is a column vector and concatenate with similarity profiles
        if size(eta, 2) > size(eta, 1)
            eta = eta';
        end
        output_matrix = [eta, sol_profiles];

        % --- 2. Build CSV Header Based on Column Count ---
        % Standard system layout: [eta, f, f_p, f_pp, g, g_p]
        num_cols = size(output_matrix, 2);

        if num_cols == 6
            header_line = 'eta,f,f_p,f_pp,g,g_p';
        else
            % Generic fallback header if solver dimension changes
            header_line = 'eta';
            for i = 1:(num_cols - 1)
                header_line = [header_line, sprintf(',y%d', i)];
            end
        end

        % --- 3. Fast Vectorized File Write ---
        fid = fopen(full_output_path, 'w');
        if fid == -1
            error('DIM_DATA:FileOpenError', 'Could not open file for writing: %s', full_output_path);
        end

        % Write header line
        fprintf(fid, '%s\n', header_line);

        % Write numerical data with high precision (transposed for column-major access)
        format_str = [repmat('%.10e,', 1, num_cols - 1), '%.10e\n'];
        fprintf(fid, format_str, output_matrix');

        fclose(fid);

        [~, fname, fext] = fileparts(full_output_path);
        fprintf('    > Dimensionless profiles exported: %s\n', [fname, fext]);

    catch ME
        if exist('fid', 'var') && fid ~= -1
            fclose(fid);
        end
        warning('DIM_DATA:WriteError', 'Failed to save dimensionless data: %s', ME.message);
    end

end
