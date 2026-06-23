# Deploy Speech-to-Text API - Port 8003 🎤

## Quick Summary
Deploy standalone Speech-to-Text service on port 8003, separate from all other services.

---

## Step 1: Upload Files to VM

**Files needed:**
- `backend/speech_to_text_main.py` → Will be `main.py` on server
- `backend/speech_to_text.py` → Whisper transcription module
- `backend/extract_record.py` → Groq record extraction module

**From Windows PowerShell:**
```powershell
# Upload main file
scp backend/speech_to_text_main.py YOUR_USERNAME@104.198.50.23:~/Dentix/SpeechToText/main.py

# Upload dependencies
scp backend/speech_to_text.py YOUR_USERNAME@104.198.50.23:~/Dentix/SpeechToText/
scp backend/extract_record.py YOUR_USERNAME@104.198.50.23:~/Dentix/SpeechToText/
```

---

## Step 2: Install Dependencies on VM

```bash
# SSH into VM
ssh YOUR_USERNAME@104.198.50.23

# Navigate to directory
cd ~/Dentix/SpeechToText

# Install required packages
pip3 install fastapi uvicorn openai-whisper groq python-multipart
```

---

## Step 3: Add API Keys

Edit `main.py` or helper files to add your API keys:
- **Groq API Key** (for extract_record.py)
- **Whisper** should work locally without API key

```bash
# If needed, add keys to environment or directly in files
nano ~/Dentix/SpeechToText/extract_record.py
# Add: GROQ_API_KEY = "your_groq_api_key_here"
```

---

## Step 4: Start the Service

```bash
cd ~/Dentix/SpeechToText

# Start on port 8003
nohup uvicorn main:app --host 0.0.0.0 --port 8003 > speech.log 2>&1 &

# Verify it's running
ps aux | grep "uvicorn.*8003"

# Check logs
tail -30 speech.log
```

**Expected in logs:**
```
INFO:     Application startup complete.
INFO:     Uvicorn running on http://0.0.0.0:8003
```

---

## Step 5: Test the API

```bash
# Test health endpoint
curl http://104.198.50.23:8003/

# Test with audio file (replace with actual audio file)
curl -X POST "http://104.198.50.23:8003/api/voice-to-record" \
  -F "file=@test_audio.wav"
```

**Expected Response:**
```json
{
  "language": "en",
  "diagnosis": "Dental caries in upper molar",
  "procedure_performed": "Cavity filling",
  "treatment_plan": "Follow-up in 2 weeks"
}
```

---

## Step 6: Configure Firewall

Make sure port 8003 is open:

```bash
gcloud compute firewall-rules create allow-speech-api \
  --allow tcp:8003 \
  --source-ranges 0.0.0.0/0 \
  --description "Speech-to-Text API"
```

Or via **Google Cloud Console**:
- VPC Network → Firewall → Create Rule
- Name: `allow-speech-api`
- Targets: All instances
- Source IP: `0.0.0.0/0`
- Protocols: `tcp:8003`

---

## Managing the Service

**Check if running:**
```bash
ps aux | grep "uvicorn.*8003"
```

**Stop service:**
```bash
pkill -f "uvicorn.*8003"
```

**Start service:**
```bash
cd ~/Dentix/SpeechToText
nohup uvicorn main:app --host 0.0.0.0 --port 8003 > speech.log 2>&1 &
```

**View logs:**
```bash
tail -50 ~/Dentix/SpeechToText/speech.log
```

---

## Architecture Overview

```
Flutter App
    ↓
    ├─→ Port 8000: Patient Chatbot (RAG + Booking)
    ├─→ Port 8001: Doctor Chatbot (Groq + Gemini Vision)
    ├─→ Port 8002: No-Show Prediction (ML Model)
    └─→ Port 8003: Speech-to-Text (Whisper + Groq)
```

---

## Flutter App Integration

✅ Already updated to use port 8003:
- File: `lib/api/web_services.dart`
- Endpoint: `http://104.198.50.23:8003/api/voice-to-record`
- Method: POST with multipart file upload

**Used in:**
- Doctor's record creation screen
- Voice note transcription

---

## Troubleshooting

**Service not starting:**
```bash
# Check logs for errors
tail -50 ~/Dentix/SpeechToText/speech.log

# Test Python imports
python3 -c "import whisper; import groq; print('OK')"
```

**Whisper model download:**
- First request will download Whisper model (~140MB)
- This may take 1-2 minutes on first run
- Subsequent requests will be faster

**Groq API errors:**
```bash
# Verify API key in extract_record.py
cat ~/Dentix/SpeechToText/extract_record.py | grep GROQ_API_KEY
```

**Port already in use:**
```bash
# Find what's using port 8003
lsof -i :8003

# Kill it
kill -9 <PID>
```

---

## All Services Summary

| Service | Port | Directory | Command |
|---------|------|-----------|---------|
| Patient Chatbot | 8000 | ~/Dentix/DentixChatbot | `uvicorn main:app --host 0.0.0.0 --port 8000` |
| Doctor Chatbot | 8001 | ~/Dentix/DoctorChatbot | `uvicorn main:app --host 0.0.0.0 --port 8001` |
| No-Show Model | 8002 | ~/Dentix/NoShowModel | `uvicorn main:app --host 0.0.0.0 --port 8002` |
| Speech-to-Text | 8003 | ~/Dentix/SpeechToText | `uvicorn main:app --host 0.0.0.0 --port 8003` |

---

## ✅ Deployment Checklist

- [ ] Create `~/Dentix/SpeechToText/` directory
- [ ] Upload `speech_to_text_main.py` as `main.py`
- [ ] Upload `speech_to_text.py` helper
- [ ] Upload `extract_record.py` helper
- [ ] Add Groq API key to `extract_record.py`
- [ ] Install dependencies (fastapi, uvicorn, whisper, groq)
- [ ] Start service on port 8003
- [ ] Test with curl
- [ ] Configure firewall (port 8003)
- [ ] Test from Flutter app

---

## Notes

**Whisper Model:**
- Uses OpenAI Whisper for transcription
- Runs locally on server (no API key needed)
- Supports multiple languages (Arabic, English, etc.)

**Record Extraction:**
- Uses Groq LLaMA for intelligent extraction
- Extracts: diagnosis, procedure, treatment plan
- Requires Groq API key

**Performance:**
- First request: ~2-3 seconds (model loading)
- Subsequent requests: ~500ms - 1s
- Audio file size limit: 25MB
