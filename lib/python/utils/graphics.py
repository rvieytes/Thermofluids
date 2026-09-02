import matplotlib.pyplot as plt

def close_figures():
    """
    Close all open Matplotlib figures.
    Safe to call even if no figures are open.
    """
    plt.close("all")
