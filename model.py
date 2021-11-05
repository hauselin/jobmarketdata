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

import os
from sklearn.feature_extraction.text import TfidfVectorizer, CountVectorizer
from pathlib import Path

# %%

df = pd.read_csv("data/clean/data_cleaned.csv")

df["highest_profile_journal"] = df["highest_profile_journal"].str.replace("&", "and")

journals = ",".join(
    df.query("highest_profile_journal.notna()")["highest_profile_journal"].to_list()
)
journals = list(np.unique(journals.split(",")))

journals = [j.lower() for j in journals]
# journals = ["behavioral and brain sciences"]

# %%

doc = df.query("highest_profile_journal.notna()")["highest_profile_journal"]

vectorizer = CountVectorizer(vocabulary=journals, ngram_range=(1, 50), binary=True)
X = vectorizer.fit_transform(doc)
X.todense()
df3 = pd.DataFrame(X.toarray(), columns=vectorizer.get_feature_names())
df3

doc.iloc[1]
df3.to_csv("check.csv")

# %%

# https://stackoverflow.com/questions/42634581/countvectorizer-returns-only-zeros/42634841

features = ["a", "b", "c", "ac"]
features = ["psych sci", "science", "nature"]
doc = ["a", "c"]
doc = ["a", "b", "c", "a", "ac"]
doc = ["psych sci", "science", "nature,science,psych sci"]
vectoriser = CountVectorizer(
    vocabulary=features, token_pattern=r"\b\w+\b", ngram_range=(1, 10)
)

x = vectoriser.fit_transform(doc)
x.todense()
df3 = pd.DataFrame(x.toarray(), columns=vectoriser.get_feature_names())
df3

# %%
