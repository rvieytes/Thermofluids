# thermo_state_wrapper.py
"""
Command-line interface for the Fluid thermophysical engine.

Receives state variables from external applications,
evaluates thermophysical properties using CoolProp,
and returns the results as JSON.
"""
import sys
import json

from pathlib import Path

# =========================================================
# PYTHON LIBRARY PATH
# =========================================================

here = Path(__file__).resolve()
python_lib = here.parent.parent

if str(python_lib) not in sys.path:
    sys.path.insert(0, str(python_lib))

from thermophysics import Fluid



if __name__ == "__main__":
    if len(sys.argv) not in (4, 5):
        print(json.dumps({"error": "Uso: python thermo_state.py <fluid> <T> <P> [fase]"}))
        sys.exit(1)
#captura de parámetros desde línea de comandos
    fluid_name = sys.argv[1]
    temperature = float(sys.argv[2])
    pressure = float(sys.argv[3])

    phase_arg = sys.argv[4] if len(sys.argv) == 5 else None
    phase = None if phase_arg == "None" else phase_arg

    try:
       # Instanciamos la clase que ya tienes en Fluido.py
        fluid = Fluid(
        fluid_name,
        temperature=temperature,
        pressure=pressure,
        phase=phase
        )
        result = {
        "rho": fluid.rho,
        "mu": fluid.mu,
        "nu": fluid.nu,
        "cp": fluid.cp,
        "k": fluid.k,
        "Pr": fluid.Pr,
        "h": fluid.h,
        "u": fluid.u,
        "s": fluid.s,
        "sound_speed": fluid.sound_speed,
        "beta": fluid.beta,
        "surface_tension": fluid.surface_tension,
        }
        print(json.dumps(result))
    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)
