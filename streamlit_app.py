# %% load modules

from pathlib import Path
import numpy as np
import pandas as pd
import pingouin as pg
from sklearn.preprocessing import PolynomialFeatures
from sklearn.pipeline import make_pipeline
from sklearn.linear_model import LinearRegression

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
    "x-axis", cols, index=9, help="Variable to plot on the x-axis"
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


xmin, xmax = st.sidebar.select_slider(
    f"{xcol} range",
    options=range(int(np.floor(df[ycol].min())), int(df[xcol].max() + 1)),
    value=(df[xcol].min(), df[xcol].max()),
)
xmin = np.float_(xmin)
xmax = np.float_(xmax)
df = df.loc[df[xcol] <= xmax].loc[df[xcol] >= xmin].reset_index(drop=True)

ymin, ymax = st.sidebar.select_slider(
    f"{ycol} range",
    options=range(int(np.floor(df[ycol].min())), int(df[ycol].max() + 1)),
    value=(df[ycol].min(), df[ycol].max()),
)
ymin = np.float_(ymin)
ymax = np.float_(ymax)
df = df.loc[df[ycol] <= ymax].loc[df[ycol] >= ymin].reset_index(drop=True)

dfclean = df[[ycol, xcol]].dropna()
n = dfclean.shape[0]
order = st.sidebar.slider("Polynomial order", min_value=1, max_value=10, value=1)

# %%

cor = pg.corr(df[xcol], df[ycol])
if isinstance(cor["BF10"][0], str):
    cor["BF10"] = "> 1000"
if cor["p-val"][0] < 0.001:
    cor["p-val"] = "< 0.001"

st.table(cor)

# %%

base = (
    alt.Chart(df)
    .mark_circle(color="black")
    .encode(alt.X(xcol), alt.Y(ycol), tooltip=[xcol, ycol])
)

polynomial_fit = [
    base.transform_regression(
        xcol, ycol, method="poly", order=order, as_=[xcol, str(order)]
    )
    .mark_line()
    .transform_fold([str(order)], as_=["degree", ycol])
]

fig1 = alt.layer(base, *polynomial_fit)
fig1 = fig1.properties(height=610).interactive()
st.altair_chart(fig1, use_container_width=True)


# %%


# %%

scores = []
degrees = []
for o in range(1, order + 1):
    degrees.append(o)
    poly = PolynomialFeatures(degree=o)
    pipeline = make_pipeline(poly, LinearRegression())
    pipeline.fit(dfclean[[xcol]], dfclean[ycol])
    scores.append(pipeline.score(dfclean[[xcol]], df[ycol]))


r2 = pd.DataFrame({"degree": degrees, "R2": scores})
r2 = r2.set_index("degree")
st.table(r2)
