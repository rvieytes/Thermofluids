def clear_console():
    """Clear the interactive console if running under IPython."""
    try:
        from IPython import get_ipython

        shell = get_ipython()
        if shell is not None:
            shell.run_line_magic("clear", "")

    except ImportError:
        pass