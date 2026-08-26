% =========================================================================
% BLSimulation project
% =========================================================================
% Description
%    Validates physical assumptions and mathematical model constraints for
%    boundary layer similarity solutions. Checks laminar/turbulent regime
%    limits (Re_crit, Ra_crit), evaluates buoyancy effects via the Richardson
%    number (Ri), and verifies Eckert number (Ec) similarity constraints for
%    free convection.
%
% Syntax
%    validate_selfsimilar_assumptions(Param)
%
% Input arguments
%    Param : Execution configuration and simulation parameter structure
%            containing physical properties (Re, Gr, Pr, Ec, Ra, Ri, Re_crit,
%            Ra_crit, L_plate).
%
% Output
%    Displays validation diagnostics and warnings directly to the console.
%    Throws an error if physical limits strictly invalidate similarity hypotheses.
%
% Example
%    validate_selfsimilar_assumptions(Param);
%
% Notes
%    - In vertical free convection, viscous dissipation (Ec > 0) introduces
%      explicit x-dependence that breaks exact self-similarity. A pseudo-similarity
%      approximation is permitted up to Ec <= 5e-5.
%    - Richardson number Ri = Gr / Re^2 measures forced vs. natural convection.
%
% See also
%    load_config, bvp_shooting_solver
%
% Author      : Rvieytes
% Assisted by : Gemini 3.6; OpenAI ChatGPT
% Date        : 15/06/2026
% Version     : 0.0.1
% =========================================================================
function validate_selfsimilar_assumptions(Param)

    fprintf('Validating laminar flow assumptions...\n');
    fprintf('----------------------------------------------------\n');
    fprintf('  Dimensionless Parameters & Regime Validation:\n');

    % Extract variables for readability
    Re = Param.phys.Re;
    Gr = Param.phys.Gr;
    Pr = Param.phys.Pr;
    Ec = Param.phys.Ec;
    Ra = Param.phys.Ra;
    Ri = Param.phys.Ri;

    fprintf('    - Reynolds (Re):        %.3e\n', Re);
    fprintf('    - Grashof (Gr):         %.3e\n', Gr);
    fprintf('    - Prandtl (Pr):         %.3f\n', Pr);
    fprintf('    - Eckert (Ec):          %.3e\n', Ec);
    fprintf('    - Rayleigh (Ra):        %.3e\n', Ra);

    % --- 1. SELF-SIMILARITY CHECK (FREE CONVECTION CASE) ---
    if strcmpi(Param.run.problem_str, 'FREE')
        % Similarity evaluation thresholds for viscous dissipation
        Ec_limit_strict = 1e-7;
        Ec_limit_accept = 5e-5;

        if Ec < Ec_limit_strict
            fprintf('    > Ec = %.2e: Dissipation negligible. Similarity hypothesis is robust.\n', Ec);
        elseif Ec <= Ec_limit_accept
            fprintf('    > WARNING: Ec = %.2e: Pseudo-similarity mode active.\n', Ec);
            fprintf('      Viscous dissipation is present but small enough to approximate\n');
            fprintf('      the solution as self-similar.\n');
        else
            error('PHYSICS:NonSelfSimilar', ...
                'Ec = %.2e is too high! The x-dependency cannot be ignored for free convection.', Ec);
        end
    end

    % --- 2. REGIME VALIDATION (RICHARDSON NUMBER) ---
    if strcmpi(Param.run.problem_str, 'FORCED')
        if Ri < 0.1
            regime_str = 'Forced Dominated';
        elseif Ri > 10
            regime_str = 'Natural Dominated';
        else
            regime_str = 'Mixed Convection';
        end
        fprintf('    - Richardson (Ri):      %.3e (Regime: %s)\n', Ri, regime_str);

        % Buoyancy effects warning for Forced Solver
        if Ri > 0.1
            warning('PHYSICS:InvalidRegime', ...
                ['Richardson number (Ri = %.2f) suggests buoyancy is significant.\n' ...
                 'Forced solver results (ignoring gravity) might be inaccurate.'], Ri);
        end
    end

    % --- 3. LAMINAR VS TURBULENT LIMITS ---
    if strcmpi(Param.run.problem_str, 'FORCED')
        limit_val   = Param.phys.Re_crit;
        current_val = Re;
        val_name    = 'Re';
    else
        limit_val   = Param.phys.Ra_crit;
        current_val = Ra;
        val_name    = 'Ra';
    end

    if current_val > limit_val
        % Calculate transition coordinate where laminar model fails (x_critical)
        if strcmpi(Param.run.problem_str, 'FORCED')
            x_crit = Param.phys.L_plate * (limit_val / current_val);
        else
            x_crit = Param.phys.L_plate * (limit_val / current_val)^(1/3);
        end

        fprintf('\n    WARNING: Laminar model limits exceeded.\n');
        fprintf('    -> Current %s (%.2e) > Critical %s (%.2e).\n', val_name, current_val, val_name, limit_val);
        fprintf('    -> Solution is only valid up to x = %.3f m.\n', x_crit);
    else
        fprintf('    - Flow Regime: Laminar assumption is valid over the entire plate.\n');
    end

    fprintf('----------------------------------------------------\n\n');

end
