% ===================================================================
% ==                  FREE CONVECTION PHYSICAL PARAMETERS          ==
% ===================================================================
fprintf('   > Loading free convection physical constants... ');

% --- 1. GEOMETRY & BOUNDARY CONDITIONS ---
% Valores de transición límite para control del operador
Param.phys.Re_crit = 5e5;   % Reynolds crítico (No usado directamente en Free)
Param.phys.Ra_crit = 1e9;   % Rayleigh crítico para transición a régimen turbulento

% Parámetros geométricos y térmicos de la simulación
Param.phys.L_plate = 0.5;    % Largo de la placa vertical [m]
Param.phys.T_w     = 300.5;  % Temperatura de la pared caliente [K]
Param.phys.T_inf   = 300.0;  % Temperatura del ambiente imperturbable [K]
Param.phys.T_film  = 0.5 * (Param.phys.T_w + Param.phys.T_inf);

% Propiedades de referencia del fluido (Evaluadas a Temperatura de Film T_f)
% Ejemplo por defecto: Aire estándar
Param.phys.rho = 1.086;      % Densidad [kg/m^3]
Param.phys.k   = 0.02816;    % Conductividad térmica [W/m*K]

% --- 2. CORE LIBRARY CONSTANTS & THERMODYNAMICS ---
C = phys.constants();
if isempty(C), error('Library Error: Cannot initialize phys.constants'); end

Param.phys.g      = C.G;                                      % Gravedad de la librería
Param.phys.deltaT = abs(Param.phys.T_w - Param.phys.T_inf);   % Gradiente térmico motor
Param.phys.beta   = 1 / Param.phys.T_inf;                     % Coef. de expansión volumétrica (Gas Ideal) [1/K]

% --- 3. INPUT MODE BRANCHING ---
if strcmpi(Param.run.mode, 'PHYSICAL')
    % --- MODO: PHYSICAL (Propiedades Dimensionales) ---
    Param.phys.mu = 1.963e-5;  % Viscosidad dinámica [Pa*s]
    Param.phys.cp = 1008.0;    % Calor específico [J/kg*K]

elseif strcmpi(Param.run.mode, 'DIMENSIONLESS')
    % --- MODO: DIMENSIONLESS (Grupos Adimensionales Motores) ---
    Param.phys.Gr = 1e8;       % Número de Grashof (Define el empuje flotante)
    Param.phys.Pr = 0.7;       % Número de Prandtl
    Param.phys.Ec = 0.0;       % Número de Eckert (Típicamente 0 en convección libre natural)
else
    error('INPUT_ERROR: Mode "%s" not recognized in set_param_Free.m', Param.run.mode);
end

% --- 4. ALGEBRAIC CONSISTENCY BRIDGE ---
if strcmpi(Param.run.mode, 'PHYSICAL')
    % Construcción hacia adelante: Calcular Números Adimensionales desde la Física
    Param.phys.nu = Param.phys.mu / Param.phys.rho;
    Param.phys.Pr = (Param.phys.mu * Param.phys.cp) / Param.phys.k;
    Param.phys.Gr = (Param.phys.g * Param.phys.beta * Param.phys.deltaT * Param.phys.L_plate^3) / (Param.phys.nu^2);
    Param.phys.Ec = (Param.phys.g * Param.phys.beta * Param.phys.L_plate) / Param.phys.cp;

elseif strcmpi(Param.run.mode, 'DIMENSIONLESS')
    % Ingeniería inversa: Calcular Propiedades Físicas desde los Adimensionales
    if Param.phys.Gr <= 0, error('PHYSICS_ERROR: Grashof (Gr) must be strictly positive.'); end

    % Despeje de la viscosidad cinemática a partir de la definición de Gr
    Param.phys.nu = sqrt((Param.phys.g * Param.phys.beta * Param.phys.deltaT * Param.phys.L_plate^3) / Param.phys.Gr);
    Param.phys.mu = Param.phys.nu * Param.phys.rho;

    % Evitamos la división por cero si el usuario desprecia la disipación viscosa (Ec = 0)
    if Param.phys.Ec > 1e-9
        Param.phys.cp = (Param.phys.g * Param.phys.beta * Param.phys.L_plate) / Param.phys.Ec;
    else
        % Si Ec = 0, se deduce cp directamente a través de Pr y k conocidos
        Param.phys.cp = (Param.phys.Pr * Param.phys.k) / Param.phys.mu;
    end

    % Auditoría interna de consistencia para el número de Prandtl
    Pr_calc = (Param.phys.mu * Param.phys.cp) / Param.phys.k;
    if abs(Pr_calc - Param.phys.Pr) / Param.phys.Pr > 1e-3
        warning('CONSISTENCY: Input Pr (%.3f) differs from calculated Pr (%.3f). Using Input Pr.', ...
                 Param.phys.Pr, Pr_calc);
    end
end

% --- 5. FINAL FLUID DYNAMICS MAPPING (EQUIVALENCES) ---
% Para que el procesador matemático del Main unifique los lazos de cálculo,
% definimos el Reynolds equivalente para el régimen de Convección Natural.
Param.phys.Re_equiv = sqrt(Param.phys.Gr);
Param.phys.Re       = Param.phys.Re_equiv; % El Main requiere un .Re global para mallas
Param.phys.Ra       = Param.phys.Gr * Param.phys.Pr;
Param.phys.Ri       = Param.phys.Gr / Param.phys.Re^2; % Por definición de equivalencia, esto dará 1.0

fprintf('Done.\n');
