# %% load modules

from pathlib import Path
import numpy as np
import pandas as pd
from sklearn.neighbors import LocalOutlierFactor

# from pyod.models.mad import MAD

pd.set_option(
    "display.max_rows",
    8,
    "display.max_columns",
    None,
    "display.width",
    None,
    "display.expand_frame_repr",
    True,
    "display.max_colwidth",
    None,
)

np.set_printoptions(
    edgeitems=5,
    linewidth=233,
    precision=4,
    sign=" ",
    suppress=True,
    threshold=50,
    formatter=None,
)

import streamlit as st
import altair as alt

# %%

df = pd.read_csv(st.secrets["data"])
df = df.drop(columns=["date"])
# st.write(df)

cols = df.columns
xcol = st.sidebar.selectbox(
    "x-axis", cols, index=0, help="Variable to plot on the x-axis"
)
ycol = st.sidebar.selectbox("y-axis", cols, index=13)

remove_outliers = st.sidebar.radio(f"Remove outliers: {ycol}", ["Yes", "No"])


def mad(x):
    return np.nanmedian(abs(x - np.nanmedian(x))) * 1.4826


def deviate(x):
    return (x - np.nanmedian(x)) / mad(x)


def na_outliers(x, threshold=3.0):
    mask = np.abs(deviate(x)) > threshold
    x_clean = x.copy()
    x_clean[mask] = np.nan
    return x_clean


if remove_outliers == "Yes":
    # clf = LocalOutlierFactor()
    # df.loc[df[ycol].isna(), ycol] = -1
    # yhat = clf.fit_predict(df[[ycol]])
    # mask = yhat != 1
    # df.loc[mask, ycol] = np.nan
    # df.loc[df[ycol] == -1, ycol] = np.nan
    df[ycol] = na_outliers(df[ycol], 5)


# st.write("You selected ", xcol, " and ", ycol)

# %%

c = (
    alt.Chart(df)
    .mark_circle(size=34)
    .encode(x=xcol, y=ycol, tooltip=[xcol, ycol])
    .interactive()
    .properties(height=610)
)

st.altair_chart(c, use_container_width=True)
