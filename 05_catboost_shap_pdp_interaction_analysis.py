# =====================================================
# CatBoost interaction screening analysis
# Dataset: CGSS dataset (n=8148).csv
# Fully reproducible, GitHub root-compatible version
# =====================================================

# =====================================================
# 0. Import required libraries
# =====================================================
import os
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

from sklearn.model_selection import train_test_split, KFold
from sklearn.metrics import root_mean_squared_error
from sklearn import metrics
from sklearn.inspection import partial_dependence

from catboost import CatBoostRegressor
import shap

# Set font and plotting configuration
plt.rcParams['font.sans-serif'] = 'Times New Roman'
plt.rcParams['axes.unicode_minus'] = False


# =====================================================
# 1. Automatically detect project root directory
# =====================================================
# This ensures compatibility with GitHub and any local system
script_dir = os.path.dirname(os.path.abspath(__file__))

# If script is inside /code folder, go up one level
root_dir = os.path.dirname(script_dir)

print("Script directory:", script_dir)
print("Project root directory:", root_dir)


# =====================================================
# 2. Load dataset
# =====================================================
data_path = os.path.join(root_dir, "CGSS dataset (n=8148).csv")

print("Loading dataset from:", data_path)

data = pd.read_csv(
    data_path,
    encoding="utf-8"
)

df = pd.DataFrame(data)

print("\nDataset loaded successfully.")
print("Dataset shape:", df.shape)


# =====================================================
# 3. Define dependent and independent variables
# =====================================================
# Dependent variable
y = df['Y']

# Independent variables
X = df.drop(['Y'], axis=1)

print("\nNumber of features:", X.shape[1])


# =====================================================
# 4. Split into training and testing sets
# =====================================================
X_train, X_test, y_train, y_test = train_test_split(
    X,
    y,
    test_size=0.2,
    random_state=42
)

print("\nTraining set size:", X_train.shape)
print("Test set size:", X_test.shape)


# =====================================================
# 5. Train CatBoost model with K-fold cross-validation
# =====================================================
params_cat = {
    'learning_rate': 0.02,
    'iterations': 1000,
    'depth': 6,
    'eval_metric': 'RMSE',
    'random_seed': 42,
    'verbose': 500
}

kf = KFold(n_splits=5, shuffle=True, random_state=42)

scores = []
best_score = np.inf
best_model = None

print("\nStarting K-fold cross-validation...")

for fold, (train_index, val_index) in enumerate(kf.split(X_train, y_train), 1):

    print(f"\nTraining fold {fold}...")

    X_train_fold = X_train.iloc[train_index]
    X_val_fold = X_train.iloc[val_index]

    y_train_fold = y_train.iloc[train_index]
    y_val_fold = y_train.iloc[val_index]

    model = CatBoostRegressor(**params_cat)

    model.fit(
        X_train_fold,
        y_train_fold,
        eval_set=(X_val_fold, y_val_fold),
        early_stopping_rounds=100
    )

    y_val_pred = model.predict(X_val_fold)

    score = root_mean_squared_error(y_val_fold, y_val_pred)

    scores.append(score)

    print(f"Fold {fold} RMSE:", score)

    if score < best_score:
        best_score = score
        best_model = model


print("\nBest CV RMSE:", best_score)


# =====================================================
# 6. Evaluate model on test set
# =====================================================
print("\nEvaluating model on test set...")

y_pred = best_model.predict(X_test)

mse = metrics.mean_squared_error(y_test, y_pred)
rmse = np.sqrt(mse)
mae = metrics.mean_absolute_error(y_test, y_pred)
r2 = metrics.r2_score(y_test, y_pred)

cc = np.corrcoef(y_test, y_pred)[0, 1]
rsd = np.std(y_pred) / (np.mean(y_pred) + 1e-12)

print("\nModel performance:")
print("Relative standard deviation (RSD):", rsd)
print("Correlation coefficient (cc):", cc)
print("Root mean squared error (RMSE):", rmse)
print("Mean squared error (MSE):", mse)
print("Mean absolute error (MAE):", mae)
print("R-squared:", r2)


# =====================================================
# 7. Create results directory
# =====================================================
results_dir = os.path.join(root_dir, "results")

os.makedirs(results_dir, exist_ok=True)

print("\nResults directory:", results_dir)


# =====================================================
# 8. Define interaction feature
# =====================================================
# Example interaction feature
interaction_feat = "SEP"

# Feature list
all_features = list(X.columns)


# =====================================================
# 9. Function to compute PDP interaction strength
# =====================================================
def pdp_cross_interaction_strength(model, X, feat_x, feat_y, grid_resolution=50):

    pd_res = partial_dependence(
        model,
        X=X,
        features=[(feat_x, feat_y)],
        kind='average',
        grid_resolution=grid_resolution
    )

    Z = pd_res['average'][0]

    dZ_dx = np.gradient(Z, axis=1)

    d2Z_dxdy = np.gradient(dZ_dx, axis=0)

    score = np.nanmean(np.abs(d2Z_dxdy))

    return float(score)


# =====================================================
# 10. Compute SHAP interaction strength
# =====================================================
print("\nComputing SHAP interaction values...")

shap_int_scores = {}

try:

    explainer = shap.TreeExplainer(best_model)

    shap_interactions = explainer.shap_interaction_values(X_test)

    feature_names = list(X_test.columns)

    j = feature_names.index(interaction_feat)

    for i, f in enumerate(feature_names):

        shap_int_scores[f] = float(
            np.mean(np.abs(shap_interactions[:, i, j]))
        )

except Exception as e:

    print("SHAP interaction not available:", e)

    shap_int_scores = {f: np.nan for f in X_test.columns}


# =====================================================
# 11. Compute PDP interaction strength
# =====================================================
print("\nComputing PDP interaction strength...")

records = []

for rank, feat in enumerate(all_features, 1):

    print("Processing feature:", feat)

    pdp_score = pdp_cross_interaction_strength(
        best_model,
        X_test,
        feat,
        interaction_feat
    )

    records.append({

        "rank_order": rank,

        "feature": feat,

        "interaction_with": interaction_feat,

        "pdp_cross_mixed_deriv": pdp_score,

        "shap_pair_interaction_mean_abs": shap_int_scores.get(feat, np.nan)

    })


rank_df = pd.DataFrame(records)


# =====================================================
# 12. Normalize scores
# =====================================================
for col in [

    "pdp_cross_mixed_deriv",

    "shap_pair_interaction_mean_abs"

]:

    if rank_df[col].notna().any():

        mn = rank_df[col].min()

        mx = rank_df[col].max()

        rank_df[col + "_norm01"] = (rank_df[col] - mn) / (mx - mn + 1e-12)

    else:

        rank_df[col + "_norm01"] = np.nan


rank_df["interaction_score_combined"] = rank_df[

    [

        "pdp_cross_mixed_deriv_norm01",

        "shap_pair_interaction_mean_abs_norm01"

    ]

].mean(axis=1)


# =====================================================
# 13. Sort and save results
# =====================================================
rank_df_sorted = rank_df.sort_values(

    by="interaction_score_combined",

    ascending=False

)


output_path = os.path.join(

    results_dir,

    "CGSS_interaction_strength_results.csv"

)

rank_df_sorted.to_csv(

    output_path,

    index=False,

    encoding="utf-8-sig"

)

print("\nResults saved to:", output_path)


# =====================================================
# 14. Display top 10 interactions
# =====================================================
print("\nTop 10 interaction features:")

print(

    rank_df_sorted[

        [

            "feature",

            "interaction_score_combined"

        ]

    ].head(10)

)


print("\nAnalysis completed successfully.")
