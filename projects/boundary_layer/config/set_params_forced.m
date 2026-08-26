% ===================================================================
% ==                FORCED CONVECTION PHYSICAL PARAMETERS          ==
% ===================================================================
fprintf('   > Loading forced convection physical constants... ');

% --- 1. GEOMETRY & BOUNDARY CONDITIONS ---
Param.phys.Re_crit = 5e5;
Param.phys.Ra_crit = 1e9;

Param.phys.U_inf   = 0.5;    % Velocidad de la corriente libre [m/s]
Param.phys.L_plate = 0.8;    % Largo de la placa [m]
Param.phys.T_w     = 300.5;  % Temperatura de la pared [K]
Param.phys.T_inf   = 300.0;  % Temperatura del fluido libre [K]
Param.phys.T_film  = 0.5 * (Param.phys.T_w + Param.phys.T_inf);

% Propiedades del Aire a T_film
Param.phys.rho = 1.086;
Param.phys.k   = 0.02816;

% --- 2. CORE LIBRARY CONSTANTS ---
C = phys.constants();
if isempty(C), error('Library Error: Cannot initialize phys.constants'); end
Param.phys.g      = C.G;
Param.phys.deltaT = abs(Param.phys.T_w - Param.phys.T_inf);
Param.phys.beta   = 1 / Param.phys.T_inf;

% --- 3. INPUT MODE BRANCHING ---
if strcmpi(Param.run.mode, 'PHYSICAL')
    Param.phys.mu = 1.963e-5;
    Param.phys.cp = 1008.0;
elseif strcmpi(Param.run.mode, 'DIMENSIONLESS')
    Param.phys.Re = 5e5;
    Param.phys.Pr = 0.7;
    Param.phys.Ec = 0.0;
else
    error('INPUT_ERROR: Mode "%s" not recognized.', Param.run.mode);
end

% --- 4. ALGEBRAIC CONSISTENCY BRIDGE ---
if strcmpi(Param.run.mode, 'PHYSICAL')
    Param.phys.nu = Param.phys.mu / Param.phys.rho;
    Param.phys.Pr = (Param.phys.mu * Param.phys.cp) / Param.phys.k;
    Param.phys.Ec = Param.phys.U_inf^2 / (Param.phys.cp * Param.phys.deltaT);
    Param.phys.Re = (Param.phys.U_inf * Param.phys.L_plate) / Param.phys.nu;
elseif strcmpi(Param.run.mode, 'DIMENSIONLESS')
    Param.phys.nu = (Param.phys.U_inf * Param.phys.L_plate) / Param.phys.Re;
    Param.phys.mu = Param.phys.nu * Param.phys.rho;
    if Param.phys.Ec > 1e-9
        Param.phys.cp = Param.phys.U_inf^2 / (Param.phys.Ec * Param.phys.deltaT);
    else
        Param.phys.cp = (Param.phys.Pr * Param.phys.k) / Param.phys.mu;
    end
end

% Grupos adimensionales secundarios finales
Param.phys.Gr = (Param.phys.g * Param.phys.beta * Param.phys.deltaT * Param.phys.L_plate^3) / (Param.phys.nu^2);
Param.phys.Ra = Param.phys.Gr * Param.phys.Pr;
Param.phys.Ri = Param.phys.Gr / Param.phys.Re^2;

fprintf('Done.\n');
