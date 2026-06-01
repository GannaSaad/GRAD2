from fastapi import FastAPI, Query, UploadFile, File, Form
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import google.generativeai as genai
import joblib
import numpy as np
import json
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
# 1) PATIENT KNOWLEDGE BASE (STABLE)
# ---------------------------------------------------------
chunks = []
diseases = []
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
data_path = os.path.join(BASE_DIR, "data", "chunks_with_embeddings.json")

if os.path.exists(data_path):
    try:
        with open(data_path, "r", encoding="utf-8") as f:
            chunks = json.load(f)
        diseases = list(set([c["disease"].lower() for c in chunks]))
        print(f"Loaded {len(chunks)} patient data chunks.")
    except Exception as e:
        print(f"Error loading Patient JSON: {e}")

class ChatRequest(BaseModel):
    message: str

# Context to remember the current topic for patient
chat_context = {"last_topic": None}

@app.post("/chat")
async def patient_chat(request: ChatRequest):
    """
    Patient Chatbot: Uses local knowledge base (STABLE).
    """
    msg = request.message.lower().strip()
    
    # 1. Detect which disease the user is talking about
    detected_disease = None
    for d in diseases:
        if d in msg:
            detected_disease = d
            chat_context["last_topic"] = d
            break
    
    target = detected_disease or chat_context["last_topic"]

    # 2. Handle Disease-specific questions
    if target:
        category = "definition"
        if any(k in msg for k in ["prevent", "avoid", "stop"]):
            category = "prevention"
        elif any(k in msg for k in ["happen", "cause", "why"]):
            category = "causes"
        elif any(k in msg for k in ["reduce", "discomfort", "pain", "relief"]):
            category = "patient_advice"

        results = [c for c in chunks if c["disease"].lower() == target and c["category"] == category]
        if results:
            return {"reply": results[0]["text"]}
        
        # Fallback to definition
        defs = [c for c in chunks if c["disease"].lower() == target and c["category"] == "definition"]
        if defs:
            return {"reply": defs[0]["text"]}

    # 3. Ultimate Fallback
    return {"reply": "I am Shagy, your dental assistant! You can ask me about conditions like Caries or Gingivitis, or book an appointment."}


# ---------------------------------------------------------
# 2) GEMINI CONFIGURATION (FOR DOCTOR)
# ---------------------------------------------------------
GEMINI_KEY = "AIzaSyDXp5afutBWhF_mT80yUiUEmE3oi1HbAo0"
genai.configure(api_key=GEMINI_KEY)
# Use 1.5-flash for maximum stability and speed
gemini_model = genai.GenerativeModel('gemini-2.0-flash')

@app.post("/doctor/chat-with-image")
async def doctor_clinical_analysis(
    image: UploadFile = File(...),
    question: str = Form("")
):
    """
    Doctor Assistant: Uses Gemini Vision for Image Analysis.
    """
    try:
        img_bytes = await image.read()
        
        prompt = f"""
        Act as Shagy, a Senior Dental Consultant AI. 
        Analyze the provided dental image.
        Doctor's additional query: {question}
        
        Please provide a professional, structured report in English:
        1. Likely Diagnosis (with confidence level)
        2. Visual Markers observed in the photo
        3. Recommended Clinical Treatment Plan
        4. Urgent red flags or referral needs
        """
        
        response = gemini_model.generate_content([
            prompt,
            {"mime_type": "image/jpeg", "data": img_bytes}
        ])
        
        return {
            "answer": response.text,
            "status": "success"
        }
    except Exception as e:
        print(traceback.format_exc())
        return {"error": str(e), "status": "error"}


# ---------------------------------------------------------
# 3) NO-SHOW PREDICTION (Logistic Regression)
# ---------------------------------------------------------
try:
    no_show_model = joblib.load(os.path.join(BASE_DIR, "no_show_model.pkl"))
except:
    no_show_model = None

@app.get("/predict")
def predict_no_show(appointments: int = Query(...), cancellations: int = Query(...)):
    if not no_show_model: return {"error": "Model missing"}
    ratio = cancellations / appointments if appointments > 0 else 0
    features = np.array([[ratio, appointments]])
    prob = no_show_model.predict_proba(features)[0][1]
    return {"probability": round(float(prob * 100), 2), "status": "success"}

@app.get("/health")
def health():
    return {"status": "Clinical AI Suite Online"}

@app.get("/")
def root():
    return {"status": "Clinical AI Live"}
