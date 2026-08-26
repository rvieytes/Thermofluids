% ==============================================================================
%   ____  _     ____  _                 _       _
%  | __ )| |   / ___|(_)_ __ ___  _   _| | __ _| |_ ___  _ __
%  |  _ \| |   \___ \| | '_ ` _ \| | | | |/ _` | __/ _ \| '__|
%  | |_) | |___ ___) | | | | | | | |_| | | (_| | || (_) | |
%  |____/|_____|____/|_|_| |_| |_|\__,_|_|\__,_|\__\___/|_|
%
%  BOUNDARY LAYER HEAT TRANSFER SOLVER - ISOTHERMAL FLAT PLATE
% ==============================================================================
% ==============================================================================
% Description :
%
% Author      : Roberto Vieytes
% Colaboration : Gemini 3.6 IA
% Date        : 8//26
% Version     : 0.9.0
% ==============================================================================
clear; close all; clc; fclose('all');
fprintf(1, '\033c');
spath = path();
log_fid = -1;
bootstrap_buffer = {};
sMarco='==============================================================================';
smarco='------------------------------------------------------------------------------';
try
% =============================================================================
% 1. ENVIRONMENT VALIDATION
% =============================================================================
    cwd = pwd();
    if isempty(strfind(cwd,"Thermofluids"))
        error("Not inside Thermofluids workspace");
    endif

    d = cwd;
    while true
        if exist(fullfile(d,".sandbox"),"file")
            root = d;
            break
        endif

        parent = fileparts(d);
        if strcmp(parent,d)
            error("Thermofluids sandbox not found");
        endif
        d = parent;
    end

    % -------------------------------------------------------------
    % Global repository root
    % -------------------------------------------------------------
    global TF_ROOT
    TF_ROOT = root;

    libdir = fullfile(TF_ROOT,"lib","octave");
    coredir=fullfile(libdir,"core");
    addpath(libdir);
    addpath(coredir);
    bootstrap_buffer{end+1} = {1, 'Workspace Thermofluids validado en: %s', root};
% =============================================================================
% 2. REQUIRED MODULES
% =============================================================================
  MASTER_CONFIG_FILE = 'run_case.m';
  MODULES = {
               "BL"
    };
  new_entries = log_function('add_modules(MODULES);', 1);
  bootstrap_buffer = [bootstrap_buffer, new_entries];

% =============================================================================
% 3. DIRECTORY EXISTENCE CHECK
% =============================================================================
##  dir_config  = './Config';
##  dir_outputs = './Outputs';
##  dir_figures = './Figures';
##  dir_logs = './logs'
##  bootstrap_buffer{end+1} = {1, '%s', '----Validating local folders...'};
##
##  % --- 3.1. LOCAL PROJECT STRUCTURE VALIDATION ---
##  new_entries = log_function('validate_path(''./config'', ''error_if_missing'');', 1);
##  bootstrap_buffer = [bootstrap_buffer, new_entries];
##
##  config_full_path = [pwd filesep 'config'];
##  addpath(config_full_path);
##  new_entries = log_function('validate_path(''./outputs'', ''create_if_missing'');', 1);
##  bootstrap_buffer = [bootstrap_buffer, new_entries];
##  new_entries = log_function('validate_path(''./figures'', ''create_if_missing'');', 1);
##  bootstrap_buffer = [bootstrap_buffer, new_entries];
##  new_entries = log_function('validate_path(''./logs'', ''create_if_missing'');', 1);
##  bootstrap_buffer = [bootstrap_buffer, new_entries];
##
##  bootstrap_buffer{end+1} = {1, '%s', ';--->Local structure ready.'};
dirs = {
    './config',  'error_if_missing';
    './outputs', 'create_if_missing';
    './figures', 'create_if_missing';
    './logs',    'create_if_missing'
};

bootstrap_buffer{end+1} = {1, '%s','----Validating local folders...'};

bootstrap_buffer = validate_directories(dirs, bootstrap_buffer);

config_full_path = [pwd filesep 'config'];
addpath(config_full_path);

bootstrap_buffer{end+1} = {1, '%s',    ';--->Local structure ready.'};
% =============================================================================
% 4. LOADING CONFIGURATIONS FILES
% =============================================================================
  cmd = '[Param, flg, cfg, sOutputFile] = load_config(MASTER_CONFIG_FILE);';
  bootstrap_buffer = [bootstrap_buffer, log_function(cmd, 1)];
  log_path = fullfile(pwd,'./logs',Param.run.log_file);
  log_fid  = fopen(log_path, 'w');

  log_script(-1, Param, log_fid, sMarco)
  log_script(-1, Param, log_fid, '   ____  _     ____  _                   _       _              ');
  log_script(-1, Param, log_fid, '  | __ )| |   / ___|(_)_ __ ___  _   _| | __ _| |_ ___  _ __  ');
  log_script(-1, Param, log_fid, '  |  _ \| |   \___ \| | ''_ ` _ \| | | | |/ _` | __/ _ \| ''__| ');
  log_script(-1, Param, log_fid, '  | |_) | |___ ___) | | | | | | | |_| | | (_| | || (_) | |    ');
  log_script(-1, Param, log_fid, '  |____/|_____|____/|_|_| |_| |_|\__,_|_|\__,_|\__\___/|_|    ');
  log_script(-1, Param, log_fid, '                                                              ');
  log_script(-1, Param, log_fid, '  BOUNDARY LAYER HEAT TRANSFER SOLVER - ISOTHERMAL FLAT PLATE');
  log_script(-1, Param, log_fid, sMarco)
% Vaciar el buffer de bootstrap a través de log_script
  flush_log_buffer(bootstrap_buffer, Param, log_fid)

  log_script(1, Param, log_fid, '--->Local structure ready.\n\n');


  log_script(-1, Param, log_fid, sMarco);
  log_script(-1, Param, log_fid,'##           BLHT: BOUNDARY LAYER HEAT TRANSFER SOLVER         ##');
  log_script(-1, Param, log_fid, sMarco);
% =============================================================================
% 5. VALIDATING PHYSICS (prints Re, Gr, Ri and regime warnings)
% =============================================================================

    log_script(-1,Param,log_fid,evalc('validate_selfsimilar_assumptions(Param)'));

  if flg.save.physical_csv || flg.save.similarity_data
    text=sprintf(' DATA DESTINATION:    %s\n', sOutputFile.dir_out);
    log_script(-1,Param,log_fid,text)
  end

   if flg.save.physical_fig || flg.save.similarity_fig
     text= sprintf(' FIGURES DESTINATION: %s\n', sOutputFile.dir_figs);
     log_script(-1,Param,log_fid,text)
    end
% Optional pause to let the student review the summary before iterations
% 'stop_for_view' should be defined in cfg_flags.m
  if isfield(flg, 'stop_for_view') && flg.stop_for_view
    log_script(-1,Param,log_fid,sMarco);
    log_script(-1,Param,log_fid,'>>> Press any key to launch the numerical solver...');
    pause;
  end
% =============================================================================
% 5. SOLVER EXECUTION
% =============================================================================
  if flg.auto_refine_seed
    % --- SMART SEED REFINEMENT ---
    % The look_optimal_seed function performs a coarse exploration
    % to find the "golden seed" and suggests a stable eta_max.
     log_script(-1,Param,log_fid,'>>> Starting automatic seed refinement...');
     % Invocación directa post-buffer
     log_exec('[refined_seeds, Param] = look_optimal_seed(Param);', -1, log_fid);

    % Update Param with the newly acquired wisdom
    Param.num.BC.initial_guess = refined_seeds;
    text=sprintf('>>> Seed refinement complete. New guess: [%.4f, %.4f]\n', ...
            refined_seeds(1), refined_seeds(2));
    log_script(1,Param,log_fid,text);
  end
% -------------------------------------------------------------
% 5.1 FINAL BVP SHOOTING SOLVER
% -------------------------------------------------------------
% Now we run the high-precision solver with the optimized parameters
  %[eta, profiles, ic_found, flag] = bvp_shooting_solver(Param);
  log_exec('[eta, profiles, ic_found, flag] = bvp_shooting_solver(Param);', -1, log_fid);

% -------------------------------------------------------------
% 5.2 CONVERGENCE CHECK
% -------------------------------------------------------------
if flag > 0
    log_script(-1,Param,log_fid,'>>> SOLVER CONVERGED SUCCESSFULLY.');

    % Extracting values from ic_found: [f, f', f'', g, g']
    % f''(0) is the 3rd element, g'(0) or theta'(0) is the 5th.
    f_pp_0 = ic_found(3);
    g_p_0  = ic_found(5);

    if strcmp(Param.run.problem_str, 'FORCED')
        text=sprintf(">>> Initial conditions found: f''(0) = %.6f, g'(0) = %.6f\n", f_pp_0, g_p_0);
    elseif strcmp(Param.run.problem_str, 'FREE')
        text=sprintf(">>> Initial conditions found: f''(0) = %.6f, theta'(0) = %.6f\n", f_pp_0, g_p_0);
    end
    log_script(1,Param,log_fid,text)
else
    % --- 2. ERROR HANDLING ---
    % The solver failed. We report the cause and suggest fixes.
    text=sprintf('\n' + repmat('!', 1, 60) + '\n');
    log_script(1,Param,log_fid,text)
    text=sprintf('ERROR: BVP Solver failed to converge (flag = %d).', flag);
    log_script(0,Param,log_fid,text)
    text=sfprintf('  Target Problem: %s\n', Param.run.problem_str);
    log_script(1,Param,log_fid,text)
    text='  Possible causes:';
    log_script(1,Param,log_fid,text)
    text='    - Initial guess too far from solution.';
    log_script(1,Param,log_fid,text)
    text='    - eta_max is too small to capture the boundary layer.';
    log_script(1,Param,log_fid,text)
    text='  Physical parameters (Pr, Ec) create numerical stiffness.';
    log_script(1,Param,log_fid,text)
    sprintf(repmat('!', 1, 60) + '\n');

    error('MAIN:SolverFailed', 'BVP solver failed. Check configuration and seeds.');
end
% =============================================================================
% 6. POST-PROCESSING
% =============================================================================
% Generate a unique suffix for filenames based on physics (Pr, Ec, etc.)
##
  sOutputFile.tail = create_output_tail(Param);
  text=sprintf('   > Output file tail: %s\n', sOutputFile.tail);
  log_script(1,Param,log_fid,text)
% -------------------------------------------------------------
% 6.1. SELF-SIMILAR PROFILES
% -------------------------------------------------------------
  if flg.plot.similarity
    log_script(-1,Param,log_fid,'Plotting self-similar profiles...');
    % Use 'profiles' from bvp_shooting_solver and the new function name
    new_entries = log_function('validate_path(''./config'', ''error_if_missing'');', 1);
  %  hFig_SS = plot_selfsimilar_profiles(eta, profiles, Param);
    log_exec('hFig_SS = plot_selfsimilar_profiles(eta, profiles, Param);', 1, log_fid);
% 6.1.1: Save Figure
    if flg.save.similarity_fig
     log_script(-1,Param,log_fid,'> Saving self-similar profile figure...');
        try
            base_name = sOutputFile.sim_fig_basename;
            % Ensure the filename is descriptive
            figure_filename  = sprintf('%s%s.png', base_name, sOutputFile.tail);
            full_output_path = fullfile(sOutputFile.dir_figs, figure_filename);

            % High-resolution save (300 DPI)
            print(hFig_SS, full_output_path, "-dpng", "-r300");
            text=sprintf('     > Figure saved at: %s\n', full_output_path);
            log_script(1,Param,log_fid,text)
        catch ME
            msg =sprintf('POST:SaveError', 'Could not save dimensionless figure. Error: %s', ME.message);
            log_script(0,Param,log_fid,'[WARNING] %s',msg);
        end
    end
     if flg.save.similarity_data
% 6.1.2: Save profile data
        log_script(1,Param,log_fid,'   > Saving self-similar profile data...');
        try
            base_name = sOutputFile.sim_data_basename;
            % Ensure the filename is descriptive
            cvs_filename  = sprintf('%s%s.csv', base_name, sOutputFile.tail);
            full_output_path = fullfile(sOutputFile.dir_out, cvs_filename);
            log_exec('save_similarity_fields_csv(eta, profiles, full_output_path);', 1, log_fid);

            text=sprintf('     > Self-similar csv file saved at: %s\n', full_output_path);
            log_script(1,Param,log_fid,text);
        catch ME
            msg =sprintf('POST:SaveError', 'Could not save dimensionless figure. Error: %s', ME.message);
            log_script(0,Param,log_fid,'[WARNING] %s',msg);
        end
    end
end
% =============================================================================
% 6.2 BOUNDARY LAYER THICKNESS CALCULATION (DELTAS) ---
% =============================================================================
Deltas = struct();
%  6.2.1: PHYSICAL THICKNESSES (METERS) ---
if flg.compute_bl_thickness
    log_script(-1,Param,log_fid,'> Converting dimensionless thicknesses to physical domain...');
    % Call the physical deltas calculator
    % We pass the Deltas struct calculated in Step 11
    log_exec(' Deltas = calculate_deltas(eta, profiles, ic_found, Param);', 1, log_fid);

    text=sprintf('     > Physical thickness calculation complete for %d points.\n', length(eta));
    log_script(1,Param,log_fid,text)
    if ~isnan(Deltas.eta_hid)
        text=sprintf('-> Hydrodynamic thickness (eta_h): %.6f', Deltas.eta_hid);
    else
        text=sprintf('-> Hydrodynamic thickness (eta_h): Not found.');
    end
    log_script(1,Param,log_fid,text)
    if ~isnan(Deltas.eta_ter)
        text=sprintf('-> Thermal thickness      (eta_t): %.6f', Deltas.eta_ter);
    else
        text=sprintf('->Thermal thickness      (eta_t): Not found.\n');
    end
    log_script(1,Param,log_fid,text)
end
% -------------------------------------------------------------
% 6.3. 2D PHYSICAL FIELDS POST-PROCESSING
% -------------------------------------------------------------

% Check if any 2D output is requested
  if flg.plot.physical_fields || flg.save.csv || ...
     flg.save.vtk || flg.save.physical_fig || flg.plot.quiver

      log_script(-1,Param,log_fid,'>>> Starting 2D Physical Field calculation...');

    % --- 12.1: Requirement Check (Fail Fast) ---
    % Ensure Deltas exist for grid scaling
      if ~isfield(Deltas, 'eta_hid') || isnan(Deltas.eta_hid)
          disp('   > Prerequisite: Calculating thicknesses for grid scaling...');
        % We use 'ic_found' (the unified name for initial conditions)
          log_exec(' Deltas = calculate_deltas(eta, profiles, ic_found, Param);', 1, log_fid);
         % Deltas = calculate_deltas(eta, profiles, ic_found, Param);
      end

    % --- 12.2: Dynamic Grid Height Adjustment (y_max) ---
    % We scale the physical domain to ensure the BL is perfectly visible
      log_script(-1, Param, log_fid,'Dynamically adjusting grid height (y_max) based on BL thickness...');

      nu    = Param.phys.nu;
      x_end = Param.num.grid.x_end;

      if strcmpi(Param.run.problem_str, 'FORCED')
          U_inf = Param.phys.U_inf;
        % Physical delta = eta * sqrt(nu * x / U)
          delta_hid_max = Deltas.eta_hid * sqrt((nu * x_end) / U_inf);
          delta_ter_max = Deltas.eta_ter * sqrt((nu * x_end) / U_inf);
      else
        % FREE Convection scaling: delta = eta * x / (Gr_x^(1/4))
        % Using your C-factor logic for consistency:
          L      = Param.phys.L_plate;
          Gr_L   = Param.phys.Gr;
          C_scale = L / (Gr_L^(1/4));

          delta_hid_max = Deltas.eta_hid * C_scale * (x_end/L)^(1/4);
          delta_ter_max = Deltas.eta_ter * C_scale * (x_end/L)^(1/4);
      end

    % Define physical y_max using the thickest layer and a safety factor
      max_physical_delta = max(delta_hid_max, delta_ter_max);
      Param.num.grid.y_max = max_physical_delta * Param.num.grid.y_max_safety_factor;

      text=sprintf('-> Max BL thickness at x=%.2f m: %.4f m.', x_end, max_physical_delta);
      log_script(1,Param,log_fid,text)
      text=sprintf('-> Grid y_max set to: %.4f m (Safety Factor: %.1f).\n', ...
            Param.num.grid.y_max, Param.num.grid.y_max_safety_factor);
      log_script(1,Param,log_fid,text)
    % --- 12.3: 2D Field Reconstruction ---
      log_script(-1,Param,log_fid,'Reconstructing 2D Physical Fields (U, V, T)...');
      % This function 'inflates' the 1D similarity solution into 2D matrices
      log_exec('PhysicalFields = calculate_physical_fields(eta, profiles, Param);', 1, log_fid);
      %PhysicalFields = calculate_physical_fields(eta, profiles, Param);

      % --- 12.4: Plotting and Visualization ---
      if flg.plot.physical_fields
        % Calculate physical growth lines for the plot overlay
        x_coords = PhysicalFields.X(1, :);
       log_exec('PhysicalDeltas = calculate_physical_deltas(Deltas, Param, x_coords);', 1, log_fid);

        if flg.save.delta_profiles
             % (Logic for saving deltas profile if needed)
             log_exec('save_deltas_profiles(x_coords, PhysicalDeltas, sOutputFile);', 1, log_fid);
        end

        log_script(-1,Param,log_fid,'Generating 2D Contour plots...');
        % Plotting function (PhysicalFields contains X, Y, U, V, T)
        log_exec('hFig_2D = plot_physical_fields(PhysicalFields, PhysicalDeltas, Param, flg);',1,log_fid)
% TO DO
%        if flg.plot.quiver
%          disp('   > Overlaying velocity vectors (quiver)...');
%          plot_quiver_overlay(hFig_2D, PhysicalFields, Param);
%        end
        % Save 2D Figure
        if flg.save.physical_fig
            try
                base_name = sOutputFile.phys_fig_basename;
                fig_path  = fullfile(sOutputFile.dir_figs, [base_name, sOutputFile.tail, '.png']);
                print(hFig_2D, fig_path, "-dpng", "-r300");
                log_script(-1,Param, file_fid,sprintf('2D Figure saved: %s\n', fig_path));
            catch ME
                warning('Could not save 2D figure: %s', ME.message);
            end
        end
    end

% --- 6.2.2: Data Export ---
    if flg.save.physical_csv
        log_script(-1,Param,log_fid,'> Exporting 2D data to CSV...');
        data_path = fullfile(sOutputFile.dir_out, [sOutputFile.phys_data_basename, sOutputFile.tail, '.csv']);
        log_exec('save_physical_fields_csv(PhysicalFields, data_path);',1, log_fid);
    end
  end
% -------------------------------------------------------------
% 6.3. VTK EXPORT FOR PARAVIEW (Structured Grid)
% -------------------------------------------------------------
  if flg.save.vtk
    fprintf('\n>>> Exporting VTK data for ParaView analysis...\n');

    % --- 1. Construct Header Information ---
    % Standardized metadata for the VTK file
    switch upper(Param.run.problem_str)
        case 'FORCED'
            sHeaderInfo = sprintf('Flat Plate Forced Conv - Re=%.2e, Pr=%.2f, Ec=%.2f', ...
                          Param.phys.Re, Param.phys.Pr, Param.phys.Ec);
        case 'FREE'
            % Fixed label to 'Free'
            sHeaderInfo = sprintf('Flat Plate Free Conv - Gr=%.2e, Pr=%.2f, Ec=%.2f', ...
                          Param.phys.Gr, Param.phys.Pr, Param.phys.Ec);
    end

    % --- 2. Build VTK Data Structure ---
    % Ensure indices nx/ny and matrices match the [ny, nx] structured grid format
    nx = Param.num.grid.nx;
    ny = Param.num.grid.ny;

    VTK_Data = struct();

    % a) Grid Geometry (X, Y, Z)
    VTK_Data.Grid.X = reshape(PhysicalFields.X, ny, nx);
    VTK_Data.Grid.Y = reshape(PhysicalFields.Y, ny, nx);
    VTK_Data.Grid.Z = zeros(ny, nx); % 2D Case

    % b) Scalar Fields
    VTK_Data.Scalars.Temperature = reshape(PhysicalFields.T, ny, nx);
    VTK_Data.Scalars.Theta       = reshape(PhysicalFields.Theta, ny, nx);

    % If Psi exists, it's great for contouring in ParaView
    if isfield(PhysicalFields, 'Psi')
        VTK_Data.Scalars.StreamFunction = reshape(PhysicalFields.Psi, ny, nx);
    end

    % c) Vector Fields (Velocity u, v, w)
    U_matrix = reshape(PhysicalFields.U, ny, nx);
    V_matrix = reshape(PhysicalFields.V, ny, nx);
    W_matrix = zeros(ny, nx);

    % VTK requires 3-component vectors (cat along the 3rd dimension)
    VTK_Data.Vectors.Velocity = cat(3, U_matrix, V_matrix, W_matrix);

    % --- 3. Filename Definition ---
    vtk_filename = sprintf('%s%s.vtk', sOutputFile.phys_data_basename, sOutputFile.tail);
    sVtkFilename = fullfile(sOutputFile.dir_out, vtk_filename);

    % --- 4. Call Export Function ---
    try
        % The function save_vtk_structured_grid must handle the Cat-3 velocity tensor
        save_vtk_structured_grid(sVtkFilename, sHeaderInfo, VTK_Data);
        fprintf('     > VTK file successfully saved: %s\n', sVtkFilename);
    catch ME
        warning('VTK:ExportError', 'Failed to save VTK file.\n   Details: %s', ME.message);
        fprintf('   Check if "save_vtk_structured_grid.m" is in the MATLAB/Octave path.\n');
    end

    % --- 5. Clean up temporary memory ---
    clear VTK_Data U_matrix V_matrix W_matrix vtk_filename sHeaderInfo;
  end

% -------------------------------------------------------------
% 6.4. QUIVER DATA EXPORT (Vector Analysis)
% -------------------------------------------------------------

  if flg.save.quiver_data
    fprintf('> Exporting downsampled quiver data (CSV format)...\n');

    % Construct filenames using the standardized tail
    base_name = sOutputFile.quiver_data_basename;
    data_filename = sprintf('%s%s.csv', base_name, sOutputFile.tail);
    full_quiver_path = fullfile(sOutputFile.dir_out, data_filename);

    % The save_quiver_data function should handle the stride logic
    % (e.g., taking every 5th or 10th point)
    try
        save_quiver_data(PhysicalFields, full_quiver_path, Param);
        fprintf('     > Quiver data saved: %s\n', full_quiver_path);
    catch ME
        warning('QUIVER:SaveError', 'Could not save quiver data: %s', ME.message);
    end
  end
% =============================================================================
% 7. PHYSICAL AUDIT (Mass & Energy Balance)
% =============================================================================

  if flg.audit.phys
    fprintf('\n>>> Performing Physical Audit (Conservation Laws)...\n');
  %Param.num.audit_mode
    % Ejecución de la auditoría
    Audit = perform_physical_audit(PhysicalFields, Param);

##    % Visualización rápida de resultados
    err_masa = mean(abs(Audit.dm_error));
    err_ener = mean(abs(Audit.de_error));
% Statistical calculations
    mass_med = median(abs(Audit.dm_error));
    mass_max = max(abs(Audit.dm_error));
    ener_med = median(abs(Audit.de_error));
    ener_max = max(abs(Audit.de_error));
    log_script(-1,Param,log_fid,sMarco)

    log_script(-1,Param,log_fid,'      PHYSICAL AUDIT REPORT (GLOBAL BALANCE)');
    log_script(-1,Param,log_fid,sMarco)
    log_script(-1,Param,log_fid,'METRIC       |  TYPICAL (MEDIAN)  |  PEAK (LEADING EDGE)');
    log_script(-1,Param,log_fid,smarco)

    text=sprintf('Mass [kg/s]  |     %.2e       |     %.2e', mass_med, mass_max);
    log_script(-1,Param,log_fid,text)
    text=sprintf('Energy [W]   |     %.2e       |     %.2e', ener_med, ener_max);
    log_script(-1,Param,log_fid,text)

    log_script(-1,Param,log_fid,sMarco)
    % Opcional: Graficar el error de cierre
    if flg.plot.physical_fields
      figure('Name', 'Physical Audit Diagnostics', 'NumberTitle', 'off');

    % --- 1. Computational Grid Visualization ---
      subplot(2,2,1);
    % We plot horizontal and vertical lines to show the "skeleton"
      hold on;
    % Vertical lines (x = constant)
      for i = 1:size(PhysicalFields.X, 2)
        plot(PhysicalFields.X(:, i), PhysicalFields.Y(:, i), 'Color', [0.7 0.7 0.7], 'LineWidth', 0.5);
      end
    % Horizontal lines (y = constant)
      for j = 1:size(PhysicalFields.X, 1)
        plot(PhysicalFields.X(j, :), PhysicalFields.Y(j, :), 'Color', [0.7 0.7 0.7], 'LineWidth', 0.5);
      end
      title('Computational Grid (Stretching View)');
      ylabel('y [m]'); xlabel('x [m]');
    % Focus on the boundary layer area to see the stretching better
      y_limit = max(PhysicalFields.Y(:)) * 0.25; % Zoom into the first 25% of the domain
      ylim([0, y_limit]);
      grid on; hold off;

    % --- 2. Mass Balance ---
      subplot(2,2,2);
      semilogy(Audit.x, abs(Audit.dm_error), 'b-o', 'MarkerSize', 4);
      title('Mass Balance Residuals'); ylabel('|\Delta \dot{m}| [kg/s]');
      grid on;

    % --- 3. Energy Balance ---
      subplot(2,2,4);
      semilogy(Audit.x, abs(Audit.de_error), 'r-s', 'MarkerSize', 4);
      title('Energy Balance Residuals'); ylabel('|\Delta \dot{E}| [W]');
      xlabel('x [m]'); grid on;

    % --- 4. Wall Heat Flux (Context for Energy Error) ---
      subplot(2,2,3);
      plot(PhysicalFields.X(1,:), PhysicalFields.q_wall, 'k', 'LineWidth', 1.5);
      title('Wall Heat Flux (Reference)'); ylabel('q_w [W/m^2]');
      xlabel('x [m]'); grid on;
    end
  end
% =============================================================================
% 7. SUCCESSFUL COMPLETION & TEARDOWN
% =============================================================================
    log_script(-1, Param, log_fid, sMarco);
    log_script(-1, Param, log_fid, 'Simulation finished successfully.');
    log_script( 1, Param, log_fid, 'Outputs generated in: %s\n', sOutputFile.dir_out);
    log_script(-1, Param, log_fid, sMarco);

    % Graceful resource cleanup on success
    if log_fid > 0
        fclose(log_fid);
    end
    clear global TF_ROOT;
%   path(spath);

% =============================================================================
% ERROR HANDLING & TEARDOWN
% =============================================================================
catch err
    if exist('log_fid', 'var') && log_fid > 0
        log_script(-1, Param, log_fid, repmat('=', 1, 79));
        log_script( 0, Param, log_fid, 'ABORTED: FATAL ERROR : %s', err.message);

        if ~isempty(err.stack)
            log_script(0, Param, log_fid, 'Location: %s -> at line %d', ...
                err.stack(1).name, err.stack(1).line);
        end
        log_script(-1, Param, log_fid, repmat('=', 1, 79));

        fclose(log_fid);
    else
        fprintf('[FATAL ERROR] %s\n', err.message);
    end

    % Graceful resource cleanup on error
    clear global TF_ROOT;
    path(spath);

    % Rethrow error to halt execution in Octave/MATLAB console
    rethrow(err);
end
