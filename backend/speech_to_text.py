"""
Speech-to-Text Module using OpenAI Whisper
Converts audio files to text transcription
"""
import whisper
import os

# Load Whisper model (base model for speed/accuracy balance)
# Options: tiny, base, small, medium, large
model = None

def load_model():
    """Load Whisper model on first use"""
    global model
    if model is None:
        print("📥 Loading Whisper model (base)...")
        model = whisper.load_model("base")
        print("✅ Whisper model loaded successfully")
    return model

def transcribe_audio(audio_path: str) -> dict:
    """
    Transcribe audio file to text using Whisper
    
    Args:
        audio_path: Path to audio file
        
    Returns:
        dict with keys:
            - transcript: Transcribed text
            - language: Detected language code
    """
    try:
        if not os.path.exists(audio_path):
            raise FileNotFoundError(f"Audio file not found: {audio_path}")
        
        # Load model if not already loaded
        whisper_model = load_model()
        
        # Transcribe
        print(f"🎯 Transcribing: {audio_path}")
        result = whisper_model.transcribe(audio_path)
        
        transcript = result["text"].strip()
        language = result.get("language", "unknown")
        
        print(f"✅ Transcription complete: {len(transcript)} characters")
        print(f"🌍 Detected language: {language}")
        
        return {
            "transcript": transcript,
            "language": language
        }
    except Exception as e:
        print(f"❌ Transcription error: {e}")
        raise e
