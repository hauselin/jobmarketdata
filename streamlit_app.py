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
def mad(x):
    return np.nanmedian(abs(x - np.nanmedian(x))) * 1.4826


def deviate(x):
    return (x - np.nanmedian(x)) / mad(x)


def na_outliers(x, threshold=3.0):
    mask = np.abs(deviate(x)) > threshold
    x_clean = x.copy()
    x_clean[mask] = np.nan
    return x_clean


# %%

df = pd.read_csv(st.secrets["data"])
df = df.drop(columns=["date"])
# st.write(df)

cols = df.columns

xcol = st.sidebar.selectbox("x-axis variable", cols, index=9)
remove_outliers_x = st.sidebar.checkbox(f"Exclude outliers: {xcol}", value=True)
if remove_outliers_x:
    df[xcol] = na_outliers(df[xcol], 5)

xmin, xmax = st.sidebar.select_slider(
    f"{xcol} range",
    options=range(int(np.floor(df[xcol].min())), int(df[xcol].max() + 1)),
    value=(df[xcol].min(), df[xcol].max()),
)
df = df.loc[df[xcol] <= xmax].loc[df[xcol] >= xmin].reset_index(drop=True)


ycol = st.sidebar.selectbox("y-axis variable", cols, index=13)
remove_outliers_y = st.sidebar.checkbox(f"Exclude outliers: {ycol}", value=True)
if remove_outliers_y:
    df[ycol] = na_outliers(df[ycol], 5)

ymin, ymax = st.sidebar.select_slider(
    f"{ycol} range",
    options=range(int(np.floor(df[ycol].min())), int(df[ycol].max() + 1)),
    value=(df[ycol].min(), df[ycol].max()),
)
df = df.loc[df[ycol] <= ymax].loc[df[ycol] >= ymin].reset_index(drop=True)

dfclean = df[[ycol, xcol]].dropna()
n = dfclean.shape[0]
order = st.sidebar.slider(
    "Regression polynomial order", min_value=1, max_value=10, value=1
)

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

# %%

brush = alt.selection_interval()

base = (
    alt.Chart(df)
    .mark_circle(color="black")
    .encode(
        alt.X(xcol),
        alt.Y(ycol),
        tooltip=[xcol, ycol],
        # color=alt.condition(brush, "gender:N", alt.value("lightgray")),
        color="gender:N",
    )
    .properties(title=f"R²: {scores[-1] *100:.2f}%")
)

tick_axis = alt.Axis(labels=False, domain=False, ticks=False)

x_ticks = (
    base.mark_tick()
    .encode(
        alt.X(xcol, title="", axis=tick_axis),
        alt.Y("gender", title="", axis=tick_axis),
        color="gender:N",
    )
    .properties(title="")
)

y_ticks = (
    base.mark_tick()
    .encode(
        alt.X("gender", title="", axis=tick_axis),
        alt.Y(ycol, title="", axis=tick_axis),
        color="gender:N",
    )
    .properties(height=377, title="")
)

polynomial_fit = [
    base.transform_regression(
        xcol, ycol, method="poly", order=order, as_=[xcol, str(order)]
    )
    .mark_line()
    .transform_fold([str(order)], as_=["degree", ycol])
]

fig1 = alt.layer(base, *polynomial_fit)
# fig1 = fig1.properties(height=610).interactive().add_selection(brush)
fig1 = fig1.properties(height=377).interactive()
# fig2 = fig1 & bars

fig2 = y_ticks | (fig1 & x_ticks)
fig2 = (
    fig2.configure_axis(labelFontSize=11, titleFontSize=15)
    .configure_title(fontSize=15)
    .configure_legend(titleFontSize=13, labelFontSize=13)
)

st.altair_chart(fig2, use_container_width=True)


cor = pg.corr(df[xcol], df[ycol])
if isinstance(cor["BF10"][0], str):
    cor["BF10"] = "> 1000"
if cor["p-val"][0] < 0.001:
    cor["p-val"] = "< 0.001"

st.table(cor)


# %%


# %%
