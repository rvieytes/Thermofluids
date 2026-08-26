% =========================================================================
% BLSimulation project
% =========================================================================
% Description
%    Unified class definition containing fundamental physical constants,
%    thermodynamic reference parameters, quantum radiation constants, and
%    unit conversions for thermofluid boundary layer simulations.
%
% Syntax
%    Const = phys.constants;
%    val   = Const.G;
%
% Properties (Constant)
%    - Mechanics & Gravity  : G, PATM
%    - Statistical & Gases  : KB, RU, NA, R_AIR
%    - Radiation & Quantum  : SIGMA, H_PLANCK, C_LUM, WIEN_B
%    - Planck Radiation     : C1_RAW, C2, C1_NORM
%    - Temperature Offset   : T_ABS, T_ZERO_C
%
% Example
%    C = phys.constants();
%    g_val = C.G;
%    sigma = C.SIGMA;
%
% Notes
%    - Designed to reside inside the '+phys' package directory (+phys/constants.m).
%    - Values updated to standard CODATA thermofluid references.
%    - Fully compatible with MATLAB and GNU Octave.
%
% See also
%    load_forced_convection_config, load_free_convection_config
%
% Author      : Rvieytes
% Assisted by : Gemini 3.6; OpenAI ChatGPT
% Date        : 15/06/2026
% Version     : 0.0.1
% =========================================================================
classdef constants

    properties (Constant)
        % --- 1. Mechanics and Standard Atmosphere ---
        G         = 9.80665;       % ISO standard acceleration of gravity [m/s^2]
        PATM      = 101325.0;      % Standard atmospheric pressure at sea level [Pa]

        % --- 2. Statistical Physics and Ideal Gas Constants ---
        KB        = 1.380649e-23;  % Boltzmann constant [J/K]
        RU        = 8.314462618;   % Universal gas constant [J/(mol*K)]
        NA        = 6.02214076e23; % Avogadro number [1/mol]
        R_AIR     = 287.058;       % Specific gas constant for dry air [J/(kg*K)]

        % --- 3. Radiation and Quantum Physics ---
        SIGMA     = 5.670374419e-8;% Stefan-Boltzmann constant [W/(m^2*K^4)]
        H_PLANCK  = 6.62607015e-34;% Planck constant [J*s]
        C_LUM     = 2.99792458e8;  % Speed of light in vacuum [m/s]
        WIEN_B    = 2.8977719e-3;  % Wien's displacement constant [m*K]

        % --- 4. Planck Radiation Law Coefficients ---
        C1_RAW    = 3.74177185e-16;% First radiation constant C1 = 2*pi*h*c^2 [W*m^2]
        C2        = 1.43877687e-2; % Second radiation constant C2 = h*c/k_B [m*K]
        C1_NORM   = 3.74177185e-16 / 5.670374419e-8; % Normalized C1 (C1 / SIGMA) [m^2*K^4]

        % --- 5. Temperature Unit Conversions ---
        T_ZERO_C  = 273.15;        % Exact absolute zero temperature offset [K]
        T_ABS     = 273.15;        % Absolute temperature reference shift [K]
    end

end
