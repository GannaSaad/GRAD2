import os
import joblib
import numpy as np
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

app = FastAPI(title="Dentix No-Show Prediction API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Load the no-show prediction model
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
try:
    no_show_model = joblib.load(os.path.join(BASE_DIR, "no_show_model.pkl"))
    print("✅ No-show prediction model loaded successfully")
except Exception as e:
    no_show_model = None
    print(f"⚠️ Failed to load no-show model: {e}")

class PredictionRequest(BaseModel):
    appointments: int
    cancellations: int

@app.get("/")
def home():
    return {"message": "Dentix No-Show Prediction API is running on port 8002"}

@app.post("/predict")
def predict_no_show(request: PredictionRequest):
    """
    Predict the probability that a patient will be a no-show
    Based on their appointment history
    """
    print("=" * 50)
    print("📊 NO-SHOW PREDICTION REQUEST")
    print(f"Raw request object: {request}")
    print(f"Total appointments: {request.appointments} (type: {type(request.appointments).__name__})")
    print(f"Cancellations: {request.cancellations} (type: {type(request.cancellations).__name__})")
    
    if not no_show_model:
        print("❌ Model not loaded")
        return {"error": "No-show prediction model not available", "status": "error"}
    
    try:
        # Validate inputs
        if request.appointments <= 0:
            print("❌ Invalid appointments count (must be > 0)")
            return {"error": "Appointments must be greater than 0", "status": "error", "probability": 0.0}
        
        if request.cancellations < 0:
            print("❌ Invalid cancellations count (cannot be negative)")
            return {"error": "Cancellations cannot be negative", "status": "error", "probability": 0.0}
        
        # Calculate no-show ratio
        ratio = request.cancellations / request.appointments if request.appointments > 0 else 0
        print(f"No-show ratio: {ratio:.4f} ({request.cancellations}/{request.appointments})")
        
        # Prepare features [no_show_ratio, total_appointments]
        features = np.array([[ratio, request.appointments]])
        print(f"Features array: {features}")
        
        # Get prediction probability
        prob = no_show_model.predict_proba(features)[0][1]
        probability = round(float(prob * 100), 2)
        
        print(f"✅ Prediction: {probability}% probability of no-show")
        print("=" * 50)
        
        return {
            "probability": probability,
            "status": "success"
        }
    except Exception as e:
        print(f"❌ Prediction error: {e}")
        import traceback
        traceback.print_exc()
        return {
            "error": str(e),
            "status": "error",
            "probability": 0.0
        }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8002)
