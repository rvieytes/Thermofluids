% =========================================================================
% BLSimulation project
% =========================================================================
% Description
%    Robust seed search and numerical continuation function for determining
%    optimal initial boundary derivatives [f''(0), g'(0)] for shooting solvers.
%    Executes adaptive parameter sweeps across Prandtl (Pr) and Eckert (Ec)
%    numbers with dynamic domain boundary layer expansion.
%
% Syntax
%    [optimal_seeds, Param] = look_optimal_seed(Param)
%
% Input arguments
%    Param         : Execution configuration and simulation parameter structure.
%
% Output
%    optimal_seeds : Optimized initial derivative seed vector [f''(0), g'(0)].
%    Param         : Updated simulation parameter structure synchronized with
%                    adapted numerical domain options.
%
% Example
%    [seeds, Param] = look_optimal_seed(Param);
%
% Notes
%    - Features multi-stage continuation: Prandtl sweep followed by adaptive
%      Eckert continuation.
%    - Automatically expands physical domain eta_max if asymptotic decay at
%      infinity is not satisfied.
%    - Fully synchronized with update_numerical_options.
%
% See also
%    bvp_shooting_solver, update_numerical_options, fsolve, ode15s
%
% Author      : Rvieytes
% Assisted by : Gemini 3.6; OpenAI ChatGPT
% Date        : 15/06/2026
% Version     : 0.0.1
% =========================================================================
function [optimal_seeds, Param] = look_optimal_seed(Param)

    % --- VERBOSITY & LOGGING CONFIGURATION ---
    verbose = 1;
    if isfield(Param.run, 'verbose_level')
        verbose = Param.run.verbose_level;
    end

    disp(repmat('=', 1, 79));
    text = '    Robust Optimal Seed Search (v5 - Domain Adaptive)';
    s_centered = [repmat(' ', 1, floor((79 - length(text)) / 2)), text];
    disp(s_centered);
    disp(repmat('=', 1, 79));

    % --- 1. SETTINGS & INITIAL GUESSES ---
    tols.loose  = [1e-4, 1e-4, 1e-4];
    tols.medium = [1e-5, 1e-6, 1e-6];
    tols.strict = [1e-7, 1e-8, 1e-8];

    switch upper(Param.run.problem_str)
        case 'FORCED'
            Pr_start = 0.7;
            seeds_start = [0.3, -0.3];
            num_steps_ec_init = 25;

        case 'FREE'
            Pr_start = 0.7;
            seeds_start = [0.908, -0.714];
            num_steps_ec_init = 40;

        otherwise
            error('LOOK_SEED:UnknownProblem', 'Unknown problem type: %s', Param.run.problem_str);
    end

    Pr_target     = Param.phys.Pr;
    Ec_target     = Param.phys.Ec;
    current_seeds = seeds_start;

    % --- 2. STAGE 1: PRANDTL SWEEP (at Ec = 0) ---
    if abs(Pr_target - Pr_start) > 1e-4
        disp('--- STAGE 1: Prandtl Sweep ---');
        pr_steps = logspace(log10(Pr_start), log10(Pr_target), 15);

        for i = 2:length(pr_steps)
            Param.phys.Pr = pr_steps(i);
            Param.phys.Ec = 0;
            current_seeds = solve_with_domain_check(current_seeds, tols.loose);
        end
    end

    % --- 3. STAGE 2: ECKERT SWEEP (Adaptive Stepping) ---
    if abs(Ec_target - 0) > 1e-4
        disp('--- STAGE 2: Eckert Sweep (Adaptive) ---');
        Param.phys.Pr = Pr_target;
        ec_curr = 0;
        dEc     = (Ec_target - 0) / num_steps_ec_init;

        while (Ec_target - ec_curr) > 1e-9
            ec_next       = min(ec_curr + dEc, Ec_target);
            Param.phys.Ec = ec_next;

            % Update numerical options and synchronization handles
            Param = update_numerical_options(Param);

            err_handle = @(s) shooting_error_function(s, Param.num.opts_ode.RelTol, Param.num.opts_ode.AbsTol);
            [found_seeds, ~, exitflag] = fsolve(err_handle, current_seeds, Param.num.opts_fsolve);

            if exitflag > 0
                [is_ok, fpp_inf, ~] = check_asymptotic_behavior(found_seeds, Param.num.opts_ode.RelTol, Param.num.opts_ode.AbsTol);

                if is_ok && abs(fpp_inf) < 1e3
                    current_seeds = found_seeds;
                    ec_curr       = ec_next;
                    dEc           = dEc * 1.1; % Adaptive step growth
                else
                    disp('    ! Convergence issue. Adjusting domain/step...');
                    Param.num.eta_max = Param.num.eta_max + 5;
                    dEc               = dEc / 2;
                end
            else
                dEc = dEc / 2;
            end
        end
    end

    % --- 4. STAGE 3: FINAL REFINEMENT ---
    disp('--- STAGE 3: Final Refinement ---');
    Param = update_numerical_options(Param); % Final options synchronization
    final_err_h = @(s) shooting_error_function(s, Param.num.opts_ode.RelTol, Param.num.opts_ode.AbsTol);
    [optimal_seeds, ~, ~] = fsolve(final_err_h, current_seeds, Param.num.opts_fsolve);

    % Final state synchronization for caller module
    Param = update_numerical_options(Param);

% =========================================================================
% PRIVATE NESTED HELPER FUNCTIONS
% =========================================================================

    function err = shooting_error_function(s, rt, at)
        [~, sol] = bl_calc_profiles(s, rt, at);
        if isempty(sol)
            err = [1e6; 1e6];
            return;
        end

        target_f_prime = 1.0;
        if strcmpi(Param.run.problem_str, 'FREE')
            target_f_prime = 0.0;
        end
        err = [sol(end, 2) - target_f_prime; sol(end, 4) - 0.0];
    end

    function [e, sol] = bl_calc_profiles(s, rt, at)
        try
            y0   = [0; 0; s(1); 1; s(2)];
            opts = odeset('RelTol', rt, 'AbsTol', at);
            [e, sol] = ode15s(@(e, y) Param.num.ode_handle(e, y, Param), [0, Param.num.eta_max], y0, opts);
        catch
            e   = [];
            sol = [];
        end
    end

    function [is_asym, fpp, gp] = check_asymptotic_behavior(s, rt, at)
        [~, sol] = bl_calc_profiles(s, rt, at);
        if isempty(sol)
            is_asym = false;
            fpp     = inf;
            gp      = inf;
            return;
        end

        fpp    = sol(end, 3);
        gp     = sol(end, 5);
        thresh = 1e-4; % Heuristic threshold for asymptotic derivative convergence
        is_asym = (abs(fpp) < thresh) && (abs(gp) < thresh);
    end

    function final_s = solve_with_domain_check(init_s, ~)
        is_ok    = false;
        attempt_s = init_s;

        while ~is_ok
            Param = update_numerical_options(Param);
            [found_s, ~, ~] = fsolve(@(s) shooting_error_function(s, Param.num.opts_ode.RelTol, Param.num.opts_ode.AbsTol), attempt_s, Param.num.opts_fsolve);

            if check_asymptotic_behavior(found_s, Param.num.opts_ode.RelTol, Param.num.opts_ode.AbsTol)
                is_ok   = true;
                final_s = found_s;
            else
                Param.num.eta_max = Param.num.eta_max + 10;
            end
        end
    end

end
