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
water = Fluid(fluid_name, phase=fase,temperature=temperatura, pressure=presion)

# ------------------------------
# 5. CÁLCULO DEL PROBLEMA
# ------------------------------

print(water.rho)

