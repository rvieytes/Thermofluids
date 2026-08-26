% ===================================================================
% ==                NUMERICAL SOLVER TOLERANCES                    ==
% ===================================================================
% This file defines precision for both the ODE integrator and
% the root-finding algorithm (fsolve).
fprintf('   > Loading numerical tolerances... ');

% --- 1. SEED FINDER TOLERANCES (look_optimal_seed) ---
% Uses adaptive precision: 'loose' for intermediate steps, 'tight' for final.

% Loose settings (faster exploration)
Param.num.tolerances.seed_finder.loose.fsolve_tol = 1e-3;
Param.num.tolerances.seed_finder.loose.ode_reltol = 1e-3;
Param.num.tolerances.seed_finder.loose.ode_abstol = 1e-3;

% Tight settings (precise refinement)
Param.num.tolerances.seed_finder.tight.fsolve_tol = 1e-7;
Param.num.tolerances.seed_finder.tight.ode_reltol = 1e-7;
Param.num.tolerances.seed_finder.tight.ode_abstol = 1e-8;

% --- 2. MAIN SOLVER TOLERANCES (bvp_shooting_solver) ---
% Strict tolerances for the high-fidelity final solution.
Param.num.tolerances.main_solver.fsolve_tol = 1e-7;
Param.num.tolerances.main_solver.ode_reltol = 1e-7;
Param.num.tolerances.main_solver.ode_abstol = 1e-8;

fprintf('Done.\n');
