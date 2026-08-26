% ===================================================================
% ==                OUTPUT FILENAMES & DIRECTORIES                 ==
% ===================================================================
% Note: To ensure LaTeX compatibility, filenames use "-" instead of "_"
fprintf('   > Loading output directories and filenames... ');

% --- 1. DIRECTORY DEFINITIONS ---
sOutputFile.dir_out  = './outputs'; % Directory for numerical data
sOutputFile.dir_figs = './figures'; % Directory for plots and pictures
sOutputFile.dir_logs = './logs';    % Directory for logs
% --- 2. BASE FILENAMES ---

% Log files
sOutputFile.run_log_basename = 'simulation-log';

% Similarity Solution Data (f, f', f'', g, g')
sOutputFile.sim_data_basename = 'similarity-solution-data';
sOutputFile.sim_fig_basename  = 'similarity-solution-plot';

% 2D Physical Fields (u, v, T)
sOutputFile.phys_data_basename = 'physical-fields-data';
sOutputFile.phys_fig_basename  = 'physical-fields-plot';

% Vector Plot (Quiver) Data
sOutputFile.quiver_data_basename = 'vector-field-quiver';

% Boundary Layer Thickness Data (delta, delta_star, theta)
sOutputFile.bl_hydro_basename = 'thickness-hydrodynamic';
sOutputFile.bl_thermal_basename = 'thickness-thermal';

% Parametric Sweeps / Scanning Data not implemented yet
sOutputFile.scan_data_filename = 'parametric-sweep-results.csv';

fprintf('Done.\n');

% ===================================================================
% ==                  END OF OUTPUT CONFIGURATION                  ==
% ===================================================================
