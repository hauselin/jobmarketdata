# %% load modules

from pathlib import Path

import altair as alt
import numpy as np
import pandas as pd
import pingouin as pg
import streamlit as st
from sklearn.linear_model import LinearRegression
from sklearn.pipeline import make_pipeline
from sklearn.preprocessing import PolynomialFeatures

import utils
from utils import keys

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

# %%

st.set_page_config(
    page_title="Academic job market",
    layout="centered",
    initial_sidebar_state="expanded",
    page_icon="random",
)

# %% prepare data

df = pd.read_csv(st.secrets["data"])
df = df.drop(columns=["date", "permission"])

cols = list(keys.keys())
colnames = list(keys.values())

lucky = st.sidebar.button(f"I'm feeling lucky", key="lucky")
# lucky = False

if lucky:
    cols2 = cols[:28]
    default_x = np.random.choice(cols2)
    cols2.remove(default_x)
    default_x = cols.index(default_x)
    default_y = np.random.choice(cols2)
    default_y = cols.index(default_y)
    st.session_state["default_y"] = default_y
    st.session_state["default_x"] = default_x
else:
    try:
        default_x = st.session_state["default_x"]
        default_y = st.session_state["default_y"]
    except:
        default_x = cols.index("years_postdoc")
        default_y = cols.index("n_offers_research")

swap = st.sidebar.checkbox(f"Swap xy-axis variables", key="swap", value=False)
if swap:
    default_y, default_x = default_x, default_y

st.sidebar.markdown("#### ")

# %% sidebar

xcol = st.sidebar.selectbox("x-axis variable", colnames, index=default_x)
xcol = list(keys.keys())[list(keys.values()).index(xcol)]
remove_outliers_x = st.sidebar.checkbox(f"Exclude outliers", value=False, key="xcol")
if remove_outliers_x:
    df[xcol] = utils.na_outliers(df[xcol])
if xcol == "funding":
    df[xcol] = np.log10(df[xcol] + 1)

xmin, xmax = st.sidebar.select_slider(
    f"Range",
    options=range(int(np.floor(df[xcol].min())), int(df[xcol].max() + 1)),
    value=(int(df[xcol].min()), int(df[xcol].max())),
    key="xcol_slider",
)
df = df.loc[df[xcol] <= xmax].loc[df[xcol] >= xmin].reset_index(drop=True)

st.sidebar.markdown("#### ")

ycol = st.sidebar.selectbox("y-axis variable", colnames, index=default_y)
ycol = list(keys.keys())[list(keys.values()).index(ycol)]
remove_outliers_y = st.sidebar.checkbox(f"Exclude outliers", value=False, key="ycol")
if remove_outliers_y:
    df[ycol] = utils.na_outliers(df[ycol])
if ycol == "funding":
    df[ycol] = np.log10(df[ycol] + 1)

ymin, ymax = st.sidebar.select_slider(
    f"Range",
    options=range(int(np.floor(df[ycol].min())), int(df[ycol].max() + 1)),
    value=(int(df[ycol].min()), int(df[ycol].max())),
    key="ycol_slider",
)
df = df.loc[df[ycol] <= ymax].loc[df[ycol] >= ymin].reset_index(drop=True)

if xcol == ycol:
    st.warning("Select different x and y variables.")
    st.stop()

st.sidebar.markdown("#### ")

dfclean = df[[ycol, xcol]].dropna()
n = dfclean.shape[0]

degree = np.random.randint(1, 7, 1)[0] if lucky else 1
order = st.sidebar.slider(
    "Regression polynomial order", min_value=1, max_value=15, value=int(degree)
)

# %% regress and correlate

scores = []
degrees = [order]
poly = PolynomialFeatures(degree=order)
pipeline = make_pipeline(poly, LinearRegression())
pipeline.fit(dfclean[[xcol]], dfclean[ycol])
scores.append(pipeline.score(dfclean[[xcol]], df[ycol]))

cor = pg.corr(df[xcol], df[ycol])
if isinstance(cor["BF10"][0], str):
    cor["BF10"] = "> 1000"
if cor["p-val"][0] < 0.001:
    cor["p-val"] = "< 0.001"

# %% plot

brush = alt.selection_interval()

df = df[[ycol, xcol, "gender"]].dropna()
if ycol == "funding":
    df[ycol] = 10 ** df[ycol] - 1
if xcol == "funding":
    df[xcol] = 10 ** df[xcol] - 1

rge = [df[xcol].min(), df[xcol].max()]
tick_axis = alt.Axis(labels=False, domain=False, ticks=False)

base = (
    alt.Chart(df)
    .mark_circle(size=55)
    .encode(
        alt.X(xcol, scale=alt.Scale(domain=rge), title=keys[xcol]),
        alt.Y(ycol, title=keys[ycol]),
        tooltip=[xcol, ycol],
        color=alt.Color(
            "gender:N", title=keys["gender"], scale=alt.Scale(scheme="inferno")
        ),
    )
    .properties(title=f"R²: {scores[-1] *100:.2f}%")
)

x_density = (
    alt.Chart(df)
    .transform_fold([xcol], as_=["", "value"])
    .transform_density(
        density="value",
        bandwidth=0.3,
        groupby=["gender"],
        extent=rge,
        counts=True,
        steps=34,
    )
    .mark_area(opacity=0.8)
    .encode(
        alt.X("value:Q", title="", scale=alt.Scale(domain=rge), axis=tick_axis),
        alt.Y("density:Q", stack="zero", axis=tick_axis, title=""),
        alt.Color("gender:N"),
        tooltip=["gender", alt.X("value:Q")],
    )
    .properties(width=400, height=55)
)

polynomial_fit = [
    base.transform_regression(
        xcol, ycol, method="poly", order=order, as_=[xcol, str(order)]
    )
    .mark_line()
    .transform_fold([str(order)], as_=["degree", ycol])
    .encode()
]

reg = (
    alt.Chart(df)
    .mark_point()
    .encode(x=xcol, y=ycol)
    .transform_regression(xcol, ycol, method="poly", order=order)
    .mark_line(color="#5ec962", size=2)
)

fig1 = reg + base
fig1 = fig1.properties(height=377).interactive()
fig2 = fig1 & x_density
fig2 = (
    fig2.configure_axis(labelFontSize=11, titleFontSize=15)
    .configure_title(fontSize=15)
    .configure_legend(titleFontSize=13, labelFontSize=13)
)

# %% show plot and stuff

_, col2, _ = st.columns((0.15, 0.8, 0.1))
with col2:
    st.altair_chart(fig2, use_container_width=True)
    st.write("Hover over the data points for more info. You can also zoom/pan.")

st.table(cor)

# %%

st.markdown(
    "Data collected by [Gordon Pennycook](https://twitter.com/GordPennycook) & [Samuel Mehr](https://twitter.com/samuelmehr). App made by [Hause Lin](https://twitter.com/hauselin)."
)

# %%
