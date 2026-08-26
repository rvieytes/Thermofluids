% =========================================================================
% BLSimulation project
% =========================================================================
% Description
%    Generates visualization plots for 1D dimensionless similarity profiles
%    (velocity f', temperature theta, shear stress f'', and heat flux theta')
%    as functions of the similarity variable eta. Automatically customizes
%    the header annotation based on convection regime (FORCED vs. FREE).
%
% Syntax
%    hFig = plot_selfsimilar_profiles(eta, sol_profiles, Param)
%
% Input arguments
%    eta          : Vector of dimensionless similarity variable eta.
%    sol_profiles : Matrix of similarity profile states [f, f', f'', g, g'].
%    Param        : Execution configuration and simulation parameter structure.
%
% Output
%    hFig         : Handle to the created MATLAB/Octave figure window.
%
% Example
%    hFig = plot_selfsimilar_profiles(eta, profiles, Param);
%
% Notes
%    - Displays main state profiles (velocity, temperature) and gradient
%      profiles (shear stress, heat flux) side-by-side.
%    - Dynamically formats annotation header with governing dimensionless
%      numbers (Pr, Re, Gr, Ec).
%    - Fully compatible with MATLAB and GNU Octave.
%
% See also
%    bvp_shooting_solver, save_similarity_fields_csv, plot_physical_fields
%
% Author      : Rvieytes
% Assisted by : Gemini 3.6; OpenAI ChatGPT
% Date        : 15/06/2026
% Version     : 0.0.1
% =========================================================================
function hFig = plot_selfsimilar_profiles(eta, sol_profiles, Param)

    % --- 1. Data Extraction ---
    % sol_profiles layout: [f, f', f'', g, g']
    df_sol  = sol_profiles(:, 2);  % f' (Velocity profile)
    d2f_sol = sol_profiles(:, 3);  % f'' (Shear stress profile)
    g_sol   = sol_profiles(:, 4);  % g / theta (Temperature profile)
    dg_sol  = sol_profiles(:, 5);  % g' / theta' (Heat flux profile)

    % --- 2. Figure Setup ---
    hFig = figure('Name', 'Similarity Solutions', ...
                  'Units', 'normalized', ...
                  'OuterPosition', [0, 0, 1, 1], ...
                  'MenuBar', 'none', ...
                  'ToolBar', 'none', ...
                  'Visible', 'off');

    % Normalized subplot positions [left, bottom, width, height]
    pos1 = [0.08, 0.22, 0.38, 0.60];
    pos2 = [0.56, 0.22, 0.38, 0.60];

    % --- 3. Subplot 1: Main Profiles (Velocity & Temperature) ---
    subplot('Position', pos1);
    plot(eta, df_sol, 'b-', 'LineWidth', 2.5);
    hold on;
    plot(eta, g_sol, 'r--', 'LineWidth', 2.5);
    grid on;
    xlabel('\eta (Similarity Variable)', 'FontSize', 12);
    ylabel('f''(\eta), \theta(\eta)', 'FontSize', 12);
    title('Velocity and Temperature Profiles', 'FontSize', 14);

    legend('f'' (Velocity)', '\theta (Temperature)', ...
           'Location', 'southoutside', ...
           'Orientation', 'horizontal', ...
           'Box', 'off', ...
           'FontSize', 12);

    % --- 4. Subplot 2: Gradients (Shear Stress & Heat Flux) ---
    subplot('Position', pos2);
    plot(eta, d2f_sol, 'b-', 'LineWidth', 2.5);
    hold on;
    plot(eta, dg_sol, 'r--', 'LineWidth', 2.5);
    grid on;
    xlabel('\eta (Similarity Variable)', 'FontSize', 12);
    ylabel('f''''(\eta), \theta''(\eta)', 'FontSize', 12);
    title('Derivative Profiles (Gradients)', 'FontSize', 14);

    legend('f'''' (Shear Stress)', '\theta'' (Heat Flux)', ...
           'Location', 'southoutside', ...
           'Orientation', 'horizontal', ...
           'Box', 'off', ...
           'FontSize', 12);

    % --- 5. Global Header Annotation ---
    if strcmpi(Param.run.problem_str, 'FORCED')
        main_title = sprintf('Self-Similar Solution - Forced Convection (Pr=%.2g, Re=%.2g, Ec=%.2g)', ...
            Param.phys.Pr, Param.phys.Re, Param.phys.Ec);
    else
        main_title = sprintf('Self-Similar Solution - Free Convection (Pr=%.2g, Gr=%.2g, Ec=%.2g)', ...
            Param.phys.Pr, Param.phys.Gr, Param.phys.Ec);
    end

    annotation('textbox', [0.1, 0.92, 0.8, 0.08], ...
               'String', main_title, ...
               'EdgeColor', 'none', ...
               'HorizontalAlignment', 'center', ...
               'FontSize', 16, ...
               'FontWeight', 'bold');

    % --- 6. Final Window Formatting ---
    set(hFig, 'Position', [0.01, 0.05, 0.98, 0.85]);
    set(hFig, 'Visible', 'on');

end
