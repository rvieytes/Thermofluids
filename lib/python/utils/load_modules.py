"""
Module dependency management.

This module provides load_modules(), which checks the dependencies
required by a script. Missing dependencies are installed automatically
only when running in Google Colab.
"""

import importlib.util
import subprocess
import sys


def _python_package_installed(package):
    """Return True if a Python package can be imported."""
    return importlib.util.find_spec(package) is not None


def pip_install(package):
    """Install a Python package using pip."""
    subprocess.check_call(
        [sys.executable, "-m", "pip", "install", package]
    )


def load_modules(runtime, python=None, system=None):
    """
    Check and, in Google Colab, install required dependencies.

    Parameters
    ----------
    runtime : TFEnvironment
        Runtime environment detected by the bootstrap.

    python : list[str], optional
        Python packages required by the script.

    system : list[str], optional
        System packages required by the script.
    """

    python = python or []
    system = system or []

    missing_python = []

    # ------------------------------------------------------------
    # Check Python packages
    # ------------------------------------------------------------
    for package in python:
        if _python_package_installed(package):
            print(f"  {package}: installed")
        else:
            print(f"  {package}: missing")
            missing_python.append(package)

    # ------------------------------------------------------------
    # Local / Jupyter
    # ------------------------------------------------------------
    if not runtime.IN_COLAB:

        if missing_python:
            print("\nMissing Python packages:")
            for package in missing_python:
                print(f"  - {package}")

            print("\nPlease install them manually.")

        return

    # ------------------------------------------------------------
    # Google Colab
    # ------------------------------------------------------------
    for package in missing_python:
        print(f"Installing Python package: {package}")
        pip_install(package)

    # ------------------------------------------------------------
    # Verify installation
    # ------------------------------------------------------------
    still_missing = [
        package
        for package in python
        if not _python_package_installed(package)
    ]

    if still_missing:
        raise ImportError(
            "The following Python packages could not be installed:\n"
            + "\n".join(f"  - {package}" for package in still_missing)
        )
