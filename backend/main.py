from fastapi import FastAPI, Query
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import joblib
import numpy as np
import json
import os

app = FastAPI(title="Dentix Patient Assistant API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# =========================
# LOAD PATIENT KNOWLEDGE BASE
# =========================
chunks = []
diseases = []
data_path = "data/chunks_with_embeddings.json"
if os.path.exists(data_path):
    try:
        with open(data_path, "r", encoding="utf-8") as f:
            chunks = json.load(f)
        diseases = list(set([c["disease"].lower() for c in chunks]))
        print(f"Loaded {len(chunks)} data chunks.")
    except Exception as e:
        print(f"Error loading JSON: {e}")

class ChatRequest(BaseModel):
    message: str

# Topic memory
chat_context = {"last_topic": None}

@app.post("/chat")
async def patient_chat(request: ChatRequest):
    msg = request.message.lower().strip()
    
    # Detect Disease
    detected = None
    for d in diseases:
        if d in msg:
            detected = d
            chat_context["last_topic"] = d
            break
    
    target = detected or chat_context["last_topic"]

    if target:
        # Simple intent matching
        category = "definition"
        if any(k in msg for k in ["prevent", "avoid", "stop"]): category = "prevention"
        elif any(k in msg for k in ["happen", "cause", "why"]): category = "causes"
        elif any(k in msg for k in ["reduce", "discomfort", "pain", "relief"]): category = "patient_advice"

        results = [c for c in chunks if c["disease"].lower() == target and c["category"] == category]
        if results:
            return {"reply": results[0]["text"]}
        
        # Fallback to definition if specific category not found
        defs = [c for c in chunks if c["disease"].lower() == target and c["category"] == "definition"]
        if defs:
            return {"reply": defs[0]["text"]}

    # Fallback for general greetings or unknown topics
    return {"reply": "I am Shagy, your dental assistant! How can I help you with your dental health today?"}


# =========================
# NO-SHOW PREDICTION MODEL
# =========================
try:
    no_show_model = joblib.load("no_show_model.pkl")
except:
    no_show_model = None

@app.get("/predict")
def predict_no_show(appointments: int = Query(...), cancellations: int = Query(...)):
    if not no_show_model: return {"error": "Model missing"}
    ratio = cancellations / appointments if appointments > 0 else 0
    prob = no_show_model.predict_proba(np.array([[ratio, appointments]]))[0][1]
    return {"probability": round(float(prob * 100), 2)}

@app.get("/")
def root():
    return {"status": "Patient AI Suite Live"}
