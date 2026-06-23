import os
import tempfile
from fastapi import FastAPI, UploadFile, File
from fastapi.middleware.cors import CORSMiddleware
from speech_to_text import transcribe_audio
from extract_record import extract_dental_record

app = FastAPI(title="Dentix Speech-to-Text API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
def home():
    return {"message": "Dentix Speech-to-Text API is running on port 8003"}

@app.post("/api/voice-to-record")
async def voice_to_record(file: UploadFile = File(...)):
    """
    Convert audio to text and extract dental record information
    Uses Whisper for speech-to-text and Groq for record extraction
    """
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

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8003)
