# Thermophysical properties with `Fluid`

This script demonstrates how to use the `Fluid` class provided by the
`thermophysics` library within the Termofluids repository.

## Purpose
The following Python package must be installed:

- [CoolProp](https://coolprop.org/)

The script creates a thermodynamic state for a fluid and retrieves its
thermophysical properties.

It is intended as a simple example of the use of the `Fluid` class from
Python scripts running under the Termofluids environment.

## Requirements

The script must be located within a Termofluids repository.

The bootstrap section at the beginning of the script automatically locates
the repository root and adds:
```text
Termofluids/lib/python/
```
to the Python import path.

The Fluid class can therefore be imported as:

```python
from thermophysics import Fluid
```

**Creating a fluid state**

A Fluid object is created by specifying the fluid, its phase, temperature,
and pressure:

```python
water = Fluid(
    "water",
    phase="liq",
    temperature=373.15,
    pressure=101325,
)
```


## The `phase` argument

The `phase` argument allows the user to explicitly request a saturated
thermodynamic phase.

Use:

```python
phase="liq"
```

o obtain saturated liquid properties, or:

```python
phase="vap"
```

to obtain saturated vapor properties.

For a pure fluid at vapor-liquid equilibrium, temperature and pressure
are not independent. Therefore, when phase is specified, the pressure
must be consistent with the saturation pressure at the specified
temperature.

For example, saturated liquid water at approximately 100 °C can be
requested as:

```python
water = Fluid(
    "Water",
    temperature=373.16,
    pressure=101325,
    phase="liq",
)
```

Similarly, saturated vapor can be requested with:

```python
water = Fluid(
    "water",
    temperature=373.16,
    pressure=101325,
    phase="vap",
)
```

If the specified temperature and pressure are inconsistent with the
requested saturated phase, Fluid raises a ValueError. For example:

```python
water = Fluid(
    "water",
    temperature=300.16,
    pressure=101325,
    phase="vap",
)
```

raises an error because the saturation pressure of water at this
temperature is approximately 3570 Pa, whereas the specified pressure is
101325 Pa.

If phase is omitted or set to None:

```python
water = Fluid(
    "water",
    temperature=300,
    pressure=101325,
)
```

the thermodynamic state is determined from the specified temperature and
pressure. The phase argument is therefore an explicit user request. Fluid does
not choose the desired phase on behalf of the user.
The temperature is given in kelvin and the pressure in pascals.

To run the script, from the terminal type

```bash
python test_Thermostate.py
```

**Accessing thermophysical properties**

Once the thermodynamic state has been defined, the properties provided by
Fluid can be accessed as object attributes.

For example:

```python
print(water.cp)
print(water.rho)
print(water.mu)
print(water.k)
```

The available properties and their units are defined in the documentation
of the CoolProp library.
