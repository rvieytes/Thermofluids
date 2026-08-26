% ===================================================================
% ==                  EXECUTION CONTROL FLAGS                      ==
% ===================================================================
fprintf('   > Loading execution flags: flg... ');

% --- 1. COMPUTATIONAL FLAGS ---
flg.compute_bl_thickness = true;  % Calculate and display delta, delta*, theta

% --- 2. PLOT CONTROL FLAGS ---
flg.plot.similarity      = true;  % Plot dimensionless profiles (f', g, etc.)
flg.plot.physical_fields = true;  % Plot 2D physical fields (u, v, T)
flg.plot.bl_thickness    = true;  % Plot boundary layer growth along the plate
flg.plot.quiver          = false;  % Plot velocity vector field

% --- 3. SAVE CONTROL FLAGS ---
% Figures
flg.save.similarity_fig  = false; % Save similarity profile plots
flg.save.physical_fig    = false; % Save physical field contour plots


% Data Files
flg.save.similarity_data = true;  % Save dimensionless results to file
flg.save.quiver_data     = true;  % Save filtered data for vector plots
flg.save.parametric_log  = false; % Enable logging for parametric sweeps. TO DO: Not yet impĺemented
flg.save.run_log         = false; % Generate a general simulation log file
flg.save.delta_profiles  = false;  % Save physical delta profiles.

% Export Formats
flg.save.physical_csv    = true;  % Save physical fields in CSV format
flg.save.vtk             = false; % Generate VTK files for ParaView/Mayavi

% Refinate seed for bvp
flg.auto_refine_seed     = true;

%Physical audit
flg.audit.phys           = true;
fprintf('Done.\n');

% ===================================================================
% ==                   END OF FLAGS CONFIGURATION                  ==
% ===================================================================
