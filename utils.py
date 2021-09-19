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

# %%


def mad(x):
    return np.nanmedian(abs(x - np.nanmedian(x))) * 1.4826


def deviate(x):
    return (x - np.nanmedian(x)) / mad(x)


def na_outliers(x, threshold=5.0):
    mask = np.abs(deviate(x)) > threshold
    x_clean = x.copy()
    x_clean[mask] = np.nan
    return x_clean


# %%


keys = dict(
    # permission="Permission",
    h_index="h-index",
    n_papers_published="Peer-reviewed papers",
    n_first_author="First-author papers",
    citations_total="Total citations",
    citations_year="Citations this year",
    years_graduate_student="Years spent as grad student",
    years_postdoc="Years spent as postdoc",
    funding="Total grant funding (log scale)",
    n_apply_tenure="Tenure-track research jobs applied",
    n_apply_teaching="Tenure-track teaching jobs applied",
    n_apply_nontenure="Non-tenure academic jobs applied",
    n_industry_apply="Industry jobs applied",
    n_interview_research_final="Finalist research job interviews",
    n_interview_teaching_final="Finalist teaching job interviews",
    n_interviews_nontenure_final="Finalist non-tenure job interviews",
    n_interviews_industry_final="Finalist industry job interviews",
    n_offers_research="Research job offers",
    n_offers_teaching="Teaching job teaching",
    n_offers_nontenure="Non-tenure job offers",
    n_offers_industry="Industry job offers",
    n_interview_research_initial="1st round research job interviews",
    n_interview_teaching_initial="1st round teaching job interviews",
    n_interviews_nontenure_intial="1st round non-tenure job interviews",
    n_interviews_industry_initial="1st round industry job interviews",
    n_classes_taught="Classes taught (primary instructor)",
    age="Age",
    n_months_family_leave="Leave taken (months)",
    covid_job_search_impact="COVID-19 job search impact",
    career_stage="Academic career stage",
    research_area="Research area/field",
    institution_country="Country of home institution",
    highest_profile_journal="Highest profile journal",
    covid_job_search_impact_how="How did COVID-19 affect job search",
    # date="Survey complete date",
    ethnicity="Ethnicity",
    gender="Gender",
    home_institution="Home institution",
    job_market_comments="Comments about job market",
    year="Survey year/cycle",
)
