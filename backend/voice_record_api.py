import os
import tempfile
import joblib
import numpy as np
import json
from fastapi import FastAPI, UploadFile, File, Query
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from speech_to_text import transcribe_audio
from extract_record import extract_dental_record
from doctor_groq_chat import doctor_chat_text_only, doctor_chat_with_image

app = FastAPI(title="Dentix Voice Record API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ========================================
# PATIENT CHATBOT KNOWLEDGE BASE
# ========================================
chunks = []
diseases = []
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
data_path = os.path.join(BASE_DIR, "data", "chunks_with_embeddings.json")

if os.path.exists(data_path):
    try:
        with open(data_path, "r", encoding="utf-8") as f:
            chunks = json.load(f)
        diseases = list(set([c["disease"].lower() for c in chunks]))
        print(f"✅ Loaded {len(chunks)} patient chatbot data chunks.")
    except Exception as e:
        print(f"⚠️ Error loading Patient JSON: {e}")

class ChatRequest(BaseModel):
    message: str

# Context to remember the current topic for patient
chat_context = {"last_topic": None}

@app.get("/")
def home():
    return {"message": "Dentix Voice Record API is running"}

@app.post("/api/voice-to-record")
async def voice_to_record(file: UploadFile = File(...)):
    print("=" * 50)
    print("🎤 RECEIVED AUDIO FILE:", file.filename)
    print("📦 Content Type:", file.content_type)
    
    suffix = os.path.splitext(file.filename)[1] or ".wav"
    print(f"📝 File extension: {suffix}")
    
    with tempfile.NamedTemporaryFile(delete=False, suffix=suffix) as temp_audio:
        content = await file.read()
        print(f"📏 File size: {len(content)} bytes")
        temp_audio.write(content)
        audio_path = temp_audio.name
    
    print(f"💾 Saved to: {audio_path}")
    
    try:
        print("🎯 Starting Whisper transcription...")
        stt_result = transcribe_audio(audio_path)
        transcript = stt_result["transcript"]
        
        print("=" * 50)
        print("🗣️ TRANSCRIPT:", transcript)
        print("🌍 LANGUAGE:", stt_result["language"])
        print("=" * 50)
        
        if not transcript or transcript.strip() == "":
            print("⚠️ WARNING: Transcript is empty!")
            return {
                "language": stt_result["language"],
                "diagnosis": "",
                "procedure_performed": "",
                "treatment_plan": ""
            }
        
        print("🤖 Extracting dental record with AI...")
        record = extract_dental_record(transcript)
        
        print("=" * 50)
        print("📋 EXTRACTED RECORD:")
        print(f"  - Diagnosis: {record.get('diagnosis', '')}")
        print(f"  - Procedure: {record.get('procedure_performed', '')}")
        print(f"  - Plan: {record.get('treatment_plan', '')}")
        print(f"  - Source: {record.get('source', 'unknown')}")
        print("=" * 50)
        
        return {
            "language": stt_result["language"],
            "diagnosis": record.get("diagnosis", ""),
            "procedure_performed": record.get("procedure_performed", ""),
            "treatment_plan": record.get("treatment_plan", "")
        }
    except Exception as e:
        print("=" * 50)
        print("❌ ERROR:", str(e))
        print("=" * 50)
        import traceback
        traceback.print_exc()
        return {
            "language": "unknown",
            "diagnosis": "",
            "procedure_performed": "",
            "treatment_plan": "",
            "error": str(e)
        }
    finally:
        if os.path.exists(audio_path):
            os.remove(audio_path)
            print(f"🗑️ Cleaned up: {audio_path}")


# ==================== DOCTOR CHATBOT ENDPOINTS ====================

class DoctorTextQuery(BaseModel):
    question: str

@app.post("/doctor/chat-text")
async def doctor_chat_text_endpoint(query: DoctorTextQuery):
    """
    Doctor chatbot endpoint for text-only questions
    Uses Groq LLaMA-3.3-70B model
    """
    print("=" * 50)
    print("🩺 DOCTOR CHAT - TEXT ONLY")
    print(f"📝 Question: {query.question}")
    print("=" * 50)
    
    try:
        result = await doctor_chat_text_only(query.question)
        print(f"✅ Response generated: {len(result['response'])} characters")
        return result
    except Exception as e:
        print(f"❌ Error: {e}")
        import traceback
        traceback.print_exc()
        return {
            "response": f"Error processing your question: {str(e)}",
            "error": str(e)
        }

@app.post("/doctor/chat-with-image")
async def doctor_chat_image_endpoint(
    image: UploadFile = File(...),
    question: str = ""
):
    """
    Doctor chatbot endpoint for image analysis
    Uses Gemini Vision model (Groq vision models decommissioned)
    """
    print("=" * 50)
    print("🩺 DOCTOR CHAT - IMAGE ANALYSIS")
    print(f"🖼️ Image: {image.filename}")
    print(f"📝 Question: {question if question else 'General analysis'}")
    print("=" * 50)
    
    try:
        result = await doctor_chat_with_image(image, question if question else None)
        print(f"✅ Analysis generated: {len(result['response'])} characters")
        return result
    except Exception as e:
        print(f"❌ Error: {e}")
        import traceback
        traceback.print_exc()
        return {
            "response": f"Error analyzing image: {str(e)}",
            "error": str(e)
        }


# ==================== NO-SHOW PREDICTION ====================

# Load the no-show prediction model
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
try:
    no_show_model = joblib.load(os.path.join(BASE_DIR, "no_show_model.pkl"))
    print("✅ No-show prediction model loaded successfully")
except Exception as e:
    no_show_model = None
    print(f"⚠️ Failed to load no-show model: {e}")

@app.get("/predict")
def predict_no_show(appointments: int = Query(...), cancellations: int = Query(...)):
    """
    Predict the probability that a patient will be a no-show
    Based on their appointment history
    """
    print("=" * 50)
    print("📊 NO-SHOW PREDICTION REQUEST")
    print(f"Total appointments: {appointments}")
    print(f"Cancellations: {cancellations}")
    
    if not no_show_model:
        print("❌ Model not loaded")
        return {"error": "No-show prediction model not available", "status": "error"}
    
    try:
        # Calculate no-show ratio
        ratio = cancellations / appointments if appointments > 0 else 0
        
        # Prepare features [no_show_ratio, total_appointments]
        features = np.array([[ratio, appointments]])
        
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
            "status": "error"
        }


# ========================================
# PATIENT CHATBOT ENDPOINT
# ========================================
@app.post("/chat")
async def patient_chat(request: ChatRequest):
    """
    Patient Chatbot: Uses local knowledge base for dental questions.
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
