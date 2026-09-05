# maps.py
#
# Map of the Thermofluids Python infrastructure.
#
# This module is declarative: it does not execute anything.
# maps.py
#
# Map of Thermofluids Python modules and their dependencies.

MAPS = {

    "thermophysics": {
        "path": "lib/python/thermophysics",
        "dependencies": {
            "external": ["CoolProp"],
            "standard": ["datetime"],
        },
    },

}
