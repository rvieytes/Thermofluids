
"""
Fluid: thermophysical properties from CoolProp for a given state.
"""

import CoolProp.CoolProp as CP


class Fluid:
    """
    Working fluid at a given thermodynamic state (T, P), with
    properties obtained from CoolProp.

    If phase is left unset, the state is determined directly from
    (T, P). If phase is set to 'liq' or 'vap', a saturated state is
    forced at that temperature — in that case P must match the
    saturation pressure at T (they are not independent inside the
    two-phase dome); an inconsistent P raises an error rather than
    being silently ignored.
    """

    def __init__(self, name, temperature, pressure, phase=None):

        self.name = name
        self.temperature = temperature
        self.pressure = pressure
        self.phase = phase

        self.real_phase = self._get_real_phase()
        self._validate_phase()

        self.Q = self._get_Q()
        self._evaluate_properties()

    def _props(self, key):
        """
        Evaluate a CoolProp property at the current state.
        """

        if self.Q is None:
            return CP.PropsSI(
                key, 'T', self.temperature, 'P', self.pressure, self.name
            )

        return CP.PropsSI(
            key, 'T', self.temperature, 'Q', self.Q, self.name
        )

    def _evaluate_properties(self):
        """
        Evaluate all thermophysical properties of interest.
        """

        self.rho = self._props('D')
        self.mu = self._props('V')
        self.nu = self.mu / self.rho
        self.cp = self._props('C')
        self.k = self._props('L')
        self.Pr = self._props('Prandtl')
        self.h = self._props('H')
        self.u = self._props('U')
        self.s = self._props('S')
        self.sound_speed = self._props('A')
        self.beta = self._props('ISOBARIC_EXPANSION_COEFFICIENT')

        if self.phase == 'liq' or self.real_phase == 'liquid':
            self.surface_tension = CP.PropsSI(
                'SURFACE_TENSION', 'T', self.temperature, 'Q', 0, self.name
            )
        else:
            self.surface_tension = None

    def _get_Q(self):
        """
        Return the vapor quality implied by the forced phase, or None
        if the state is not being forced to saturation.
        """

        if self.phase == 'liq':
            return 0.0

        if self.phase == 'vap':
            return 1.0

        return None

    def _validate_phase(self):
        """
        Validate the requested phase.

        If phase is not specified, the state is determined from (T, P).

        If phase is 'liq' or 'vap', the user explicitly requests the
        corresponding saturated phase. In that case the pressure must be
        consistent with the saturation pressure at the specified
        temperature.
        """

        if self.phase is None:

            if self.real_phase in ('twophase', 'unknown'):
                raise ValueError(
                    f"Ambiguous state at T={self.temperature:.2f} K, "
                    f"P={self.pressure:.0f} Pa: the fluid state is "
                    f"'{self.real_phase}'. Specify phase='liq' or "
                    "phase='vap' to resolve the ambiguity."
                    )

            return

        if self.phase not in ('liq', 'vap'):
            raise ValueError(
                f"Invalid phase: {self.phase!r}. "
                "Must be 'liq' or 'vap'."
                )

    # A saturated phase can only exist below the critical temperature.
        T_crit = CP.PropsSI('Tcrit', self.name)

        if self.temperature >= T_crit:
            raise ValueError(
                f"Cannot force phase={self.phase!r} at "
                f"T={self.temperature:.2f} K: "
                f"the temperature is at or above the critical "
                f"temperature ({T_crit:.2f} K)."
                )

    # Requested saturated phase
        Q = 0.0 if self.phase == 'liq' else 1.0

        p_sat = CP.PropsSI(
            'P',
            'T', self.temperature,
            'Q', Q,
            self.name
            )

        relative_error = abs(self.pressure - p_sat) / p_sat

        if relative_error > 0.01:
            requested_phase = (
                'saturated liquid'
                if self.phase == 'liq'
                else 'saturated vapor'
                )

            raise ValueError(
                f"Inconsistent saturated state: {requested_phase} "
                f"at T={self.temperature:.2f} K requires "
                f"P_sat={p_sat:.0f} Pa, but "
                f"P={self.pressure:.0f} Pa was given "
                f"({relative_error:.1%} off)."
                )

    def _get_real_phase(self):
        """
        Query CoolProp for the actual phase at the current (T, P).

        Note: if (T, P) lies at or extremely close to the liquid-vapor
        saturation curve, T and P stop being independent (a pure
        substance in phase equilibrium has only one degree of
        freedom), and CoolProp itself documents that it may raise an
        error in that situation rather than returning a phase, because
        both liquid and vapor solutions are mathematically valid
        there. We treat that case the same as 'twophase': the state is
        ambiguous from (T, P) alone.
        """

        try:
            phase = CP.PhaseSI(
                'T', self.temperature, 'P', self.pressure, self.name
            )

        except Exception:
            return 'twophase'

        if phase.startswith('unknown'):
            return 'unknown'

        return phase

if __name__ == "__main__":
    Tsat = CP.PropsSI(
        'T',
        'P',
        101325,
        'Q',
        0,
        'Water'
        )
    f = Fluid("Water", Tsat, 101325, "liq")

    print("rho =", f.rho)
    print("phase =", f.phase)
    print("real phase =", f.real_phase)
    print("Q =", f.Q)
