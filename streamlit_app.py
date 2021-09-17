# %% load modules

from pathlib import Path
import numpy as np
import pandas as pd

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
    "x-axis", cols, index=10, help="Variable to plot on the x-axis"
)
ycol = st.sidebar.selectbox("y-axis", cols, index=11)

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