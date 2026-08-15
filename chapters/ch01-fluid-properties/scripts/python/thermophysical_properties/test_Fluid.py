# =========================================================
# THERMOFLUIDS - PYTHON TEMPLATE
# =========================================================

# ------------------------------
# 1. BOOTSTRAP (DO NOT MODIFY)
# ------------------------------

from pathlib import Path
import sys

def _setup_termofluids():
    here = Path(__file__).resolve()

    for p in [here] + list(here.parents):
        if (p / "Termofluids" / "lib").exists():
            lib = p / "Termofluids" / "lib"
            sys.path.insert(0, str(lib / "python"))
            return

    raise RuntimeError("No se encontró Termofluids/lib")

_setup_termofluids()

# =========================================================
# USER CODE AREA (LIBRE EXPANSIÓN)
# =========================================================
# ------------------------------
# 2. IMPORTS BASE
# ------------------------------

from thermophysics import Fluid

# ------------------------------
# 3. ZONA DE PARÁMETROS
# ------------------------------

# Definir condiciones del problema
fluid_name = 'water'
temperatura = 300.16
presion = 101325
fase = None# 'vap' #, 'liq'

# ------------------------------
# 4. INICIALIZACIÓN FÍSICA
# ------------------------------
f = Fluid(fluid_name, phase=fase,temperature=temperatura, pressure=presion)

# ------------------------------
# 5. CÁLCULO DEL PROBLEMA
# ------------------------------

print(f"rho        = {f.rho:.3f} kg/m³")       # density
print(f"mu         = {f.mu:.3e} Pa·s")         # dynamic viscosity
print(f"nu         = {f.nu:.3e} m²/s")         # kinematic viscosity
print(f"cp         = {f.cp:.3f} J/(kg·K)")    # specific heat capacity
print(f"k          = {f.k:.3f} W/(m·K)")      # thermal conductivity
print(f"Pr         = {f.Pr:.3f}")              # Prandtl number
print(f"h          = {f.h:.3f} J/kg")         # specific enthalpy
print(f"u          = {f.u:.3f} J/kg")          # specific internal energy
print(f"s          = {f.s:.3f} J/(kg·K)")     # specific entropy
print(f"c          = {f.sound_speed:.3f} m/s") # sound speed
print(f"beta       = {f.beta:.3e} 1/K")        # isobaric expansion coefficient
