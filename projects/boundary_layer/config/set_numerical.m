% ===================================================================
% ==       MASTER NUMERICAL, GRID & VISUALIZATION CONFIGURATION    ==
% ===================================================================
fprintf('   > Loading unified numerical and graphics setup... ');

% --- 1. PROBLEM-SPECIFIC SOLVER SETUP (DYNAMIC COUPLING) ---
% Vinculamos los punteros de las funciones y las semillas según el problema elegido
if strcmpi(Param.run.problem_str, 'FREE')
    Param.num.ode_handle = @free_convection_ode;
    Param.num.BC.initial_guess = [0.6; -0.5] * sqrt(2); % [f''(0), g'(0)]
    Param.num.BC.final_targets = [0; 0];                 % [f'(inf), g(inf)]

elseif strcmpi(Param.run.problem_str, 'FORCED')
    Param.num.ode_handle = @forced_convection_ode;
    Param.num.BC.initial_guess = [0.3; -0.3] * sqrt(2); % [f''(0), g'(0)]
    Param.num.BC.final_targets = [1; 0];                 % [f'(inf), g(inf)]
else
    error('CORE_ERROR: Problem type not recognized in set_numerical.m');
end

% Condiciones de contorno conocidas en la pared (Comunes para ambos)
% f(0)=0 (no penetración), f'(0)=0 (no deslizamiento), g(0)=1 (pared isotérmica)
Param.num.BC.known_initial_values = [0; 0; 1];

% Límite de integración matemática hacia el infinito (eta -> inf)
Param.num.eta_max = 10.0;

% --- 2. COMPUTATIONAL GRID CONFIGURATION ---
Param.num.grid.x_start = 1e-4;   % Evita la singularidad en el borde de ataque (x=0)
Param.num.grid.x_end   = Param.phys.L_plate;
Param.num.grid.nx      = 50;     % Nodos en X
Param.num.grid.ny      = 50;     % Nodos en Y

% Factor de estiramiento de malla (s > 1 concentra nodos cerca de la pared y=0)
Param.num.grid_s = 1.08;

% Factor de seguridad para inflar la grilla física en el Main
Param.num.grid.y_max_safety_factor = 2.0;

% NOTA: El cálculo estático de Param.num.grid.y_max fue ELIMINADO de aquí.
% Ahora se calcula de forma 100% dinámica dentro de 'main_BL_simulation.m'

% --- 3. CONSERVATION AUDIT MODE ---
% 'EXACT'          - Usa gradientes analíticos del solver.
% 'STRETCHED_FINE' - Diferencias finitas de alto orden sobre malla estirada.
Param.num.audit_mode = 'STRETCHED_FINE';

% --- 4. VISUALIZATION & PLOTTING SETTINGS ---
Param.plot.font_size  = 14;
Param.plot.line_width = 2;

% Configuración del campo de vectores (Quiver)
Param.num.quiver.step      = 2;   % Muestra un vector cada 2 nodos (evita saturación)
Param.num.quiver.scale     = 0.1;
Param.num.quiver.head_size = 0.3;

fprintf('Done.\n');
