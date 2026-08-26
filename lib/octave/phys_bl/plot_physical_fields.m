% =========================================================================
% BLSimulation project
% =========================================================================
% Description
%    Generates 2D contour plots of physical boundary layer fields (tangential
%    velocity U, normal velocity V, temperature T, and streamlines Psi) with
%    dynamic visual layout orientation adapted to the convection regime
%    (horizontal plate for forced convection, vertical plate for free convection).
%
% Syntax
%    hFig_XY = plot_physical_fields(PhysicalFields, PhysicalDeltas, Param, flg)
%
% Input arguments
%    PhysicalFields : Structure containing 2D computational field matrices
%                     (.X, .Y, .U, .V, .T, .Psi).
%    PhysicalDeltas : Structure containing physical boundary layer thickness
%                     profiles (.x_coords, .h_fis, .t_fis).
%    Param          : Execution configuration and simulation parameter structure.
%    flg            : Visualization control flags structure (.plot.bl_thickness).
%
% Output
%    hFig_XY        : Handle to the created MATLAB/Octave figure window.
%
% Example
%    hFig = plot_physical_fields(PhysFields, PhysDeltas, Param, flg);
%
% Notes
%    - Dynamically toggles plot arrangement: 3x1 vertical layout for forced
%      convection (plate along bottom) and 1x3 horizontal layout for free
%      convection (plate along left).
%    - Overlays hydrodynamic (h_fis) and thermal (t_fis) boundary layer
%      growth curves on the temperature field when enabled by flg.plot.bl_thickness.
%    - Fully compatible with MATLAB and GNU Octave.
%
% See also
%    calculate_physical_fields, calculate_physical_deltas, contourf
%
% Author      : Rvieytes
% Assisted by : Gemini 3.6; OpenAI ChatGPT
% Date        : 15/06/2026
% Version     : 0.0.1
% =========================================================================
function hFig_XY = plot_physical_fields(PhysicalFields, PhysicalDeltas, Param, flg)

    % --- 1. Data Extraction ---
    X   = PhysicalFields.X;
    Y   = PhysicalFields.Y;
    U   = PhysicalFields.U;
    V   = PhysicalFields.V;
    T   = PhysicalFields.T;
    Psi = PhysicalFields.Psi;

    x_end = Param.num.grid.x_end;
    y_max = Param.num.grid.y_max;

    % Determine orientation based on convection regime
    is_free = strcmpi(Param.run.problem_str, 'FREE');

    % --- 2. Figure Setup ---
    hFig_XY = figure('Name', ['2D Fields - ' Param.run.problem_str], ...
                     'NumberTitle', 'off', ...
                     'Visible', 'off');

    if is_free
        set(hFig_XY, 'Position', [100, 100, 1200, 600]); % Horizontal layout for vertical plates
        layout = [1, 3];
    else
        set(hFig_XY, 'Position', [100, 100, 800, 900]);  % Vertical layout for horizontal plates
        layout = [3, 1];
    end
    cmap = colormap('jet');

    % --- 3. Subplot 1: Tangential Velocity U & Streamlines ---
    subplot(layout(1), layout(2), 1);
    draw_contour_logic(X, Y, U, Psi, is_free, PhysicalDeltas, false);
    format_subplot_logic('Velocity U [m/s] & \Psi', 'U [m/s]', x_end, y_max, is_free);

    % --- 4. Subplot 2: Normal Velocity V ---
    subplot(layout(1), layout(2), 2);
    V_plot = V;
    V_plot(:, 1) = V_plot(:, 2); % Singularity correction at origin wall node
    draw_contour_logic(X, Y, V_plot, [], is_free, PhysicalDeltas, false);

    v_max_ref = max(max(abs(V_plot(:, floor(end/2):end))));
    if v_max_ref > 0
        caxis([-v_max_ref, v_max_ref] * 1.1);
    end
    format_subplot_logic('Normal Velocity V [m/s]', 'V [m/s]', x_end, y_max, is_free);

    % --- 5. Subplot 3: Temperature Field T ---
    subplot(layout(1), layout(2), 3);
    draw_contour_logic(X, Y, T, [], is_free, PhysicalDeltas, flg.plot.bl_thickness);
    format_subplot_logic('Temperature Field T [K]', 'T [K]', x_end, y_max, is_free);

    colormap(cmap);
    set(hFig_XY, 'Visible', 'on');

% =========================================================================
% PRIVATE NESTED HELPER FUNCTIONS
% =========================================================================

    function draw_contour_logic(X_grid, Y_grid, Data, Stream_Psi, is_natural, deltas, flag_BL)
        if is_natural
            % Free convection orientation (Vertical plate: Y-axis horizontal, X-axis vertical)
            contourf(Y_grid, X_grid, Data, 50, 'LineStyle', 'none');
            hold on;

            if ~isempty(Stream_Psi)
                levels = linspace(sqrt(abs(min(Stream_Psi(:)))), sqrt(abs(max(Stream_Psi(:)))), 20).^2 * sign(max(Stream_Psi(:)));
                contour(Y_grid, X_grid, Stream_Psi, levels, 'k-', 'LineWidth', 0.5);
            end

            if flag_BL && isfield(deltas, 'h_fis')
                plot(deltas.h_fis(:), deltas.x_coords(:), 'w--', 'LineWidth', 1.5);
                plot(deltas.t_fis(:), deltas.x_coords(:), 'r:', 'LineWidth', 1.5);
            end
        else
            % Forced convection orientation (Horizontal plate: X-axis horizontal, Y-axis vertical)
            contourf(X_grid, Y_grid, Data, 50, 'LineStyle', 'none');
            hold on;

            if ~isempty(Stream_Psi)
                levels = linspace(sqrt(abs(min(Stream_Psi(:)))), sqrt(abs(max(Stream_Psi(:)))), 20).^2 * sign(max(Stream_Psi(:)));
                contour(X_grid, Y_grid, Stream_Psi, levels, 'k-', 'LineWidth', 0.5);
            end

            if flag_BL && isfield(deltas, 'h_fis')
                plot(deltas.x_coords(:), deltas.h_fis(:), 'w--', 'LineWidth', 1.5);
                plot(deltas.x_coords(:), deltas.t_fis(:), 'r:', 'LineWidth', 1.5);
            end
        end
        hold off;
    end

    function format_subplot_logic(title_str, cb_label, x_lim, y_lim, is_natural)
        title(title_str);
        grid on;
        h_cb = colorbar;
        ylabel(h_cb, cb_label);

        if is_natural
            ylabel('Vertical position x [m]');
            xlabel('Distance y [m]');
            axis([0, y_lim, 0, x_lim]);
            set(gca, 'PlotBoxAspectRatio', [1, 3, 1]);
        else
            xlabel('Horizontal position x [m]');
            ylabel('Distance y [m]');
            axis([0, x_lim, 0, y_lim]);
            set(gca, 'PlotBoxAspectRatio', [3, 1, 1]);
        end
    end

end
