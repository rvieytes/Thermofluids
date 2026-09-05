import importlib

from config.maps import MAPS


def load_modules(runtime, modules):

    for module in modules:

        if module not in MAPS:
            raise ModuleNotFoundError(
                f"Module {module!r} is not defined in MAPS."
            )

        dependencies = MAPS[module]["dependencies"]

        # External dependencies
        for dependency in dependencies.get("external", []):
            try:
                importlib.import_module(dependency)
                print(f"{dependency} Found!")
            except ImportError as exc:
                raise ImportError(
                    f"External dependency {dependency!r} "
                    f"required by {module!r} is not available."
                ) from exc
