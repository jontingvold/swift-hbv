#!/usr/bin/env python3
# coding: utf-8

import pandas as pd
import numpy as np
import sklearn.metrics
import matplotlib as mpl
import matplotlib.pyplot as plt
import plotly
import plotly.graph_objects

pd.plotting.register_matplotlib_converters()

plt.style.use('seaborn-pastel')
plt.style.use('jont')
mpl.rcParams['savefig.dpi'] = 300
plt.rcParams['savefig.pad_inches'] = 0.4
plt.rcParams["axes.spines.top"] = True
plt.rcParams["axes.spines.right"] = True

import os
directory = os.path.dirname(os.path.realpath(__file__))


def process_dataset(path):
    df = pd.read_csv(path)
    df.index = pd.to_datetime(df.Datetime)
    df = df.drop(columns="Datetime")
    return df


def plot_data_with_temp_precip(x, y, y_hat, title="", init_timesteps=0):
    plt.rcParams["axes.spines.top"] = True
    plt.rcParams["axes.spines.right"] = True
    fig, axes = plt.subplots(nrows=2, ncols=1, figsize=(15, 5))
    
    year_from = y.index.year[0]
    year_to = y.index.year[-1]
    r2 = sklearn.metrics.r2_score(y.values[init_timesteps:], y_hat.values[init_timesteps:])
    
    if title:
        title = title + ", "
    if year_to == year_from+1:
        title = title + "%i/%i (R2: %.2f)" % (year_from, year_to, r2)
    else:
        title = title + "%i–%i (R2: %.2f)" % (year_from, year_to, r2)
    
    ax1 = axes[0]
    ax1.plot(y.index, y, label="Observed", linestyle="-")
    ax1.plot(y_hat.index, y_hat, label="Simulated", linestyle="-")
    ax1.set_xlabel("")
    ax1.set_ylabel("Discharge (m3/s)")
    ax1.set_title(title)
    ax1.set_xlim(y.index[0], y.index[-1])
    ax1.set_ylim(ax1.get_ylim()[0], 1.3*ax1.get_ylim()[1])

    colors = getattr(getattr(pd.plotting, '_matplotlib').style, '_get_standard_colors')(num_colors=4)
    
    # Nedbør
    precipitation = x[x.columns[0]]
    ax2 = ax1.twinx()
    ax2.spines['right'].set_position(('axes', 1.0))
    ax2.bar(precipitation.index, precipitation, label="Precipitation (mm)", color=colors[2], width=0.8)
    ax2.set_ylabel("Precipitation (mm)")
    ax2.invert_yaxis()
    ax2.set_ylim(2.0*ax2.get_ylim()[0], ax2.get_ylim()[1])
    
    # ask matplotlib for the plotted objects and their labels
    lines, labels = ax1.get_legend_handles_labels()
    lines2, labels2 = ax2.get_legend_handles_labels()
    ax2.legend(lines + lines2, labels + labels2, loc="upper left", framealpha=0.5)
    
    # Temperatur
    temp = x[x.columns[1]]
    ax3 = axes[1]
    #ax3.plot(temp.index, temp, color=colors[3])
    temp.plot(ax=ax3, color=colors[3])
    ax3.set_xlabel("")
    ax3.set_ylabel("Temperature (°C)")
    ax3.axhline(0.0, color="black", linestyle="dotted")
    
    fig.tight_layout()
    
    return fig


def plot_data(y_val, y_val_hat, title=""):
    plt.rcParams["axes.spines.top"] = False
    plt.rcParams["axes.spines.right"] = False
    ax = pd.DataFrame({
        "Observed": y_val,
        "Simulated": y_val_hat
    }).plot(style=["-", "-"], figsize=(15, 5));
    ax.set_xlabel("")
    ax.set_ylabel("Discharge (m3/s)")
    ax.set_title(title)
    ax.legend(loc="upper right")
    ax.get_figure().tight_layout()
    
    return ax
    
def plot_accumulated(y_val, y_val_hat, title=""):
    plt.rcParams["axes.spines.top"] = False
    plt.rcParams["axes.spines.right"] = False
    
    max_observed = sum(y_val)
    
    ax = pd.DataFrame({
        "Observed": y_val.cumsum() / max_observed,
        "Simulated": y_val_hat.cumsum()  / max_observed
    }).plot(style=["-", "-"], figsize=(15, 3));
    ax.set_xlabel("")
    ax.set_ylabel("Accumulated discharge\n1.0=total observed")
    ax.set_title(title)
    ax.legend(loc="lower right")
    ax.get_figure().tight_layout()
    
    return ax


def plot_interactive_plot(y_val, y_val_hat, title=""):
    fig = plotly.subplots.make_subplots(specs=[[{"secondary_y": True}]])
    fig.add_trace(plotly.graph_objects.Scatter(x=y_val_hat.index, y=y_val_hat, name="Simulated"), secondary_y=False)
    fig.add_trace(plotly.graph_objects.Scatter(x=y_val.index, y=y_val, name="Observed"))
    fig.update_xaxes(title_text="")
    fig.update_yaxes(title_text="<b>Discharge</b> (m3/s)")
    fig.update_layout(title_text=title,)
    return fig


def nash_sutcliffe_r2(y, y_hat):
    y_mean = np.mean(y)
    
    nash_sutcliffe_r2 = 1-sum((y_hat - y)**2) / sum((y - y_mean)**2)
    return nash_sutcliffe_r2


# IMPORT DATASETS

test_dataset = process_dataset(directory + "/outputs/Testset-output.csv")
validation_dataset = process_dataset(directory + "/outputs/Validationset-output.csv")


# TRAININGSET PLOTS

x = test_dataset[["Percepation (mm)", "Temperatur (C)"]]
y = test_dataset["Observed discharge (m3/s)"]
y_hat = test_dataset["Simulated discharge (m3/s)"]

ns = nash_sutcliffe_r2(y.values, y_hat.values)

print("TRAINING SET")
print("Nash Sutcliffe/R2: %.2f of 1.0" % ns)
print("MAE: %.2f m3/s" % sklearn.metrics.mean_absolute_error(y.values, y_hat.values))
print()

# Discharge, preciptiation and temp
plot_data_with_temp_precip(x, y, y_hat, title="Training set").savefig(directory + "/plots/1.1-Trainingset.png")
plot_data_with_temp_precip(x[:365], y[:365], y_hat[:365], title="Training set").savefig(directory + "/plots/1.2-Trainingset-first-year.png")
plot_data_with_temp_precip(x[-365:], y[-365:], y_hat[-365:], title="Training set").savefig(directory + "/plots/1.3-Trainingset-last-year.png")

# Accumulated discharge
plot_accumulated(y, y_hat, title="Trainingset").get_figure().savefig(directory + "/plots/1.4-Trainingset-accumulated.png")

# Interactive
#plot_interactive_plot(y, y_hat, title=title)
#plotly.offline.plot(fig1, filename='plots/1.5-Trainingset.html', auto_open=False)


# VALIDATIONSET PLOTS

x = validation_dataset[["Percepation (mm)", "Temperatur (C)"]]
y = validation_dataset["Observed discharge (m3/s)"]
y_hat = validation_dataset["Simulated discharge (m3/s)"]

ns = nash_sutcliffe_r2(y.values, y_hat.values)

print("VALIDATION SET")
print("Nash Sutcliffe/R2: %.2f of 1.0" % ns)
print("MAE: %.2f m3/s" % sklearn.metrics.mean_absolute_error(y.values, y_hat.values))
print()

# Discharge, preciptiation and temp
plot_data_with_temp_precip(x, y, y_hat, title="Validation set").savefig(directory + "/plots/2.1-Validationset.png")
plot_data_with_temp_precip(x[:365], y[:365], y_hat[:365], title="Validation set").savefig(directory + "/plots/2.2-Validationset-first-year.png")
plot_data_with_temp_precip(x[-2*365:-365], y[-2*365:-365], y_hat[-2*365:-365], title="Validation set").savefig(directory + "/plots/2.3-Validationset-second-last-year.png")
plot_data_with_temp_precip(x[-365:], y[-365:], y_hat[-365:], title="Validation set").savefig(directory + "/plots/2.4-Validationset-last-year.png")

# Accumulated discharge
plot_accumulated(y, y_hat, title="Validationset").get_figure().savefig(directory + "/plots/2.5-Validationset-accumulated.png")

# Interactive
#plot_interactive_plot(y, y_hat, title=title)
#plotly.offline.plot(fig1, filename='plots/2.6-Validationset.html', auto_open=False)
