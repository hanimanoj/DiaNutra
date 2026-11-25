
from flask import Flask, request, jsonify
from flask_cors import CORS
import pandas as pd
import joblib
import json
from pathlib import Path

# Initialize Flask
app = Flask(__name__)
CORS(app)

# Base directory
BASE_DIR = Path(__file__).resolve().parent
MODEL_DIR = BASE_DIR / "models"
DATA_DIR = BASE_DIR / "data"

# Load trained models
food_knn_model = joblib.load(MODEL_DIR / "food_knn_model.pkl")
scaler_food = joblib.load(MODEL_DIR / "scaler_food.pkl")

meal_knn_models = joblib.load(MODEL_DIR / "meal_knn_models.pkl")
scaler_meal = joblib.load(MODEL_DIR / "scaler_meal.pkl")

# Load Food Dataset
food_df = pd.read_excel(
    DATA_DIR / "Dianutra_Food_Database.xlsx",
    sheet_name="Modified"
)

# Apply original food filtering
food_features = food_df[
    (food_df["Suitable for Diabetes"] == 1) &
    (food_df["Malaysian Availability"] == "Yes") &
    (food_df["Glycemic Index"].between(1, 55))
].copy()

food_knn = food_features.copy()

print("\n===== FOOD FILTER CHECK =====")
print("Total original foods:", len(food_df))
print("Total filtered foods:", len(food_knn))

print("\nMalaysian Availability:")
print(food_knn["Malaysian Availability"].value_counts())

print("\nSuitable for Diabetes:")
print(food_knn["Suitable for Diabetes"].value_counts())

print("\nGlycemic Index range:")
print(food_knn["Glycemic Index"].min(),
      "-",
      food_knn["Glycemic Index"].max())

print("\nFiltered food names:")
print(food_knn["Food Name"].tolist())

# Load Meal Dataset
meal_df = pd.read_excel(
    DATA_DIR / "DiaNutra_Complete_Meals.xlsx",
    sheet_name="DiaNutra_Complete_Meals"
)

# Select original meal features
meal_features = meal_df[
    [
        "Dish",
        "Meal",
        "Veg/Non-Veg",
        "Calories",
        "Protein",
        "Carbs",
        "Fat",
        "Fiber",
        "Glycemic Index"
    ]
].copy()

# Group meal records and calculate averages
meal_unique = meal_features.groupby(
    ["Meal", "Dish"],
    as_index=False
).agg({
    "Calories": "mean",
    "Carbs": "mean",
    "Protein": "mean",
    "Fat": "mean",
    "Fiber": "mean",
    "Glycemic Index": "mean"
})


# Health check endpoint
@app.route("/health", methods=["GET"])
def health():
    return jsonify({
        "status": "success",
        "message": "DiaNutra ML API is running!"
    })


# Food recommendation endpoint
@app.route("/recommend/foods", methods=["POST"])
def recommend_foods():

    try:
        data = request.get_json()

        target_data = pd.DataFrame([{
            "Calories": float(data["calories"]),
            "Carbohydrates": float(data["carbs"]),
            "Protein": float(data["protein"]),
            "Fat": float(data["fat"])
        }])

        # Apply trained scaler
        target_scaled = scaler_food.transform(target_data)

        # Find 5 nearest foods
        distances, indices = food_knn_model.kneighbors(
            target_scaled
        )

        recommendations = food_knn.iloc[indices[0]].copy()
        recommendations["Distance"] = distances[0]

        result = json.loads(
            recommendations.to_json(orient="records")
        )

        return jsonify({
            "status": "success",
            "recommendations": result
        })

    except Exception as e:
        return jsonify({
            "status": "error",
            "message": str(e)
        }), 400


# Meal recommendation endpoint
@app.route("/recommend/meal", methods=["POST"])
def recommend_meal():

    try:
        data = request.get_json()

        meal_type = data["meal_type"]

        if meal_type not in meal_knn_models:
            return jsonify({
                "status": "error",
                "message": "Invalid meal category"
            }), 400

        target = pd.DataFrame([{
            "Calories": float(data["calories"]),
            "Carbs": float(data["carbs"]),
            "Protein": float(data["protein"]),
            "Fat": float(data["fat"])
        }])

        # Apply trained scaler
        target_scaled = scaler_meal.transform(target)

        # Select corresponding meal model
        model = meal_knn_models[meal_type]

        # Get dishes for selected category
        meal_data = meal_unique[
            meal_unique["Meal"] == meal_type
        ].reset_index(drop=True)

        # Find nearest dish
        distances, indices = model.kneighbors(target_scaled)

        recommendations = meal_data.iloc[
            indices[0]
        ].copy()

        recommendations["Distance"] = distances[0]

        recommendations = recommendations.sort_values(
            "Distance"
        ).head(1)

        result = json.loads(
            recommendations.to_json(orient="records")
        )
        print("MEAL NAME CHECK:", result)

        return jsonify({
            "status": "success",
            "recommendations": result
        })

    except Exception as e:
        return jsonify({
            "status": "error",
            "message": str(e)
        }), 400


# Run Flask server
if __name__ == "__main__":
    print("DiaNutra ML API is starting...")
    print("Filtered food records:", len(food_knn))
    print("Unique meal records:", len(meal_unique))

    app.run(
        host="0.0.0.0",
        port=5000,
        debug=True
    )
