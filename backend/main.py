from fastapi import FastAPI, UploadFile, File, Form, Query
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import google.generativeai as genai
import joblib
import numpy as np
import os
import traceback

app = FastAPI(title="Dentix AI Suite")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# ---------------------------------------------------------
# GEMINI CONFIGURATION (UPDATED FOR SDK 0.8.3+)
# ---------------------------------------------------------
GEMINI_KEY = "AIzaSyBNHz7TG2qnw-DOkD-P7VDcTbnFBvH5qSM"
genai.configure(api_key=GEMINI_KEY)

# Use the full model path to avoid 404
model = genai.GenerativeModel('models/gemini-2.0-flash')

class ChatRequest(BaseModel):
    message: str

# 1. PATIENT CHAT
@app.post("/chat")
async def patient_chat(request: ChatRequest):
    try:
        response = model.generate_content(f"You are Shagy, a friendly dental assistant. Answer this briefly in simple English for a patient: {request.message}")
        return {"reply": response.text}
    except Exception as e:
        return {"reply": "I'm having a bit of a connection issue. Please try again later."}

# 2. DOCTOR ANALYSIS (Vision)
@app.post("/doctor/chat-with-image")
async def doctor_analysis(image: UploadFile = File(...), question: str = Form("")):
    try:
        img_bytes = await image.read()

        # Correct prompt format for Vision analysis
        prompt = f"""
        Act as Shagy, a Senior Dental Clinical Assistant.
        Analyze the provided dental image.
        Doctor's query: {question}

        Provide a professional report in English:
        - Diagnosis Suggestion
        - Visual Markers observed
        - Recommended Treatment Plan
        - Any urgent red flags
        """

        # The new SDK requires this specific list format for images
        response = model.generate_content([
            prompt,
            {"mime_type": "image/jpeg", "data": img_bytes}
        ])

        return {"answer": response.text, "status": "success"}
    except Exception as e:
        print(traceback.format_exc())
        return {"error": str(e), "status": "error"}

# 3. NO-SHOW PREDICTION
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

@app.get("/health")
def health():
    return {"status": "ok"}
