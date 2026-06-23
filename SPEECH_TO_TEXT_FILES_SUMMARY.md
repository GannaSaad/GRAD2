# Speech-to-Text Service - All Files 📁

## Files Ready for Deployment

### Main API File
**`backend/speech_to_text_main.py`** → Upload as `main.py`
- FastAPI application
- Port 8003
- Endpoint: `/api/voice-to-record`
- Handles file upload and orchestration

### Helper Modules
**`backend/speech_to_text.py`**
- Whisper integration
- Transcribes audio to text
- Supports multiple languages
- Auto-detects language

**`backend/extract_record.py`**
- Groq AI integration
- Extracts structured dental records
- Fields: diagnosis, procedure, treatment plan
- **IMPORTANT:** Add your Groq API key before deployment!

---

## What Each File Does

### 1. speech_to_text_main.py (Main API)
```python
# Receives audio file from Flutter app
# Calls speech_to_text.py for transcription
# Calls extract_record.py for extraction
# Returns structured JSON response
```

**Response format:**
```json
{
  "language": "en",
  "diagnosis": "Dental caries",
  "procedure_performed": "Filling",
  "treatment_plan": "Follow-up in 2 weeks"
}
```

### 2. speech_to_text.py (Whisper)
```python
# Uses OpenAI Whisper model
# Converts audio → text
# Detects language automatically
# Works offline (no API key needed)
```

### 3. extract_record.py (Groq AI)
```python
# Uses Groq LLaMA-3.3-70B
# Converts transcript → structured fields
# Extracts: diagnosis, procedure, treatment
# REQUIRES: Groq API key
```

---

## Deployment Steps

### Step 1: Upload Files to VM
```powershell
# Create directory on VM
ssh YOUR_USERNAME@104.198.50.23
mkdir -p ~/Dentix/SpeechToText

# Upload from Windows
scp backend/speech_to_text_main.py YOUR_USERNAME@104.198.50.23:~/Dentix/SpeechToText/main.py
scp backend/speech_to_text.py YOUR_USERNAME@104.198.50.23:~/Dentix/SpeechToText/
scp backend/extract_record.py YOUR_USERNAME@104.198.50.23:~/Dentix/SpeechToText/
```

### Step 2: Add Groq API Key
```bash
# Edit extract_record.py
nano ~/Dentix/SpeechToText/extract_record.py

# Change this line:
GROQ_API_KEY = os.getenv("GROQ_API_KEY", "YOUR_GROQ_API_KEY_HERE")

# To:
GROQ_API_KEY = os.getenv("GROQ_API_KEY", "gsk_xxxxxxxxxxxxx")
# Replace with your actual Groq API key
```

### Step 3: Install Dependencies
```bash
cd ~/Dentix/SpeechToText
pip3 install fastapi uvicorn openai-whisper groq python-multipart
```

### Step 4: Start Service
```bash
cd ~/Dentix/SpeechToText
nohup uvicorn main:app --host 0.0.0.0 --port 8003 > speech.log 2>&1 &

# Check logs
tail -30 speech.log
```

### Step 5: Configure Firewall
```bash
gcloud compute firewall-rules create allow-speech-api \
  --allow tcp:8003 \
  --source-ranges 0.0.0.0/0
```

### Step 6: Test
```bash
curl http://104.198.50.23:8003/
# Expected: {"message": "Dentix Speech-to-Text API is running on port 8003"}
```

---

## Dependencies

### Python Packages
```bash
pip3 install fastapi
pip3 install uvicorn
pip3 install openai-whisper
pip3 install groq
pip3 install python-multipart
```

### System Requirements
- Python 3.8+
- FFmpeg (for audio processing)
- ~2GB disk space (for Whisper model)

### Install FFmpeg (if needed)
```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install ffmpeg

# Or check if already installed
ffmpeg -version
```

---

## File Structure on VM

```
~/Dentix/SpeechToText/
├── main.py                 (speech_to_text_main.py)
├── speech_to_text.py       (Whisper module)
├── extract_record.py       (Groq extraction module)
└── speech.log              (Service logs)
```

---

## API Keys Required

### Groq API Key
**Where to get:** https://console.groq.com/keys

**How to add:**
1. Get API key from Groq Console
2. Edit `~/Dentix/SpeechToText/extract_record.py`
3. Replace `YOUR_GROQ_API_KEY_HERE` with actual key
4. Restart service

**Example:**
```python
GROQ_API_KEY = "gsk_abc123xyz456..."
```

### Whisper
No API key needed - runs locally!

---

## Testing

### Test Health Endpoint
```bash
curl http://104.198.50.23:8003/
```

### Test with Audio File
```bash
# Upload a test audio file
curl -X POST "http://104.198.50.23:8003/api/voice-to-record" \
  -F "file=@test.wav"
```

### Expected Response
```json
{
  "language": "en",
  "diagnosis": "Patient has dental caries in upper right molar",
  "procedure_performed": "Cavity filled with composite resin",
  "treatment_plan": "Follow-up appointment in 2 weeks"
}
```

---

## Troubleshooting

### Whisper Model Download
First request will download Whisper model (~140MB):
```bash
# Check logs during first request
tail -f ~/Dentix/SpeechToText/speech.log

# You'll see:
# 📥 Loading Whisper model (base)...
# ✅ Whisper model loaded successfully
```

### Groq API Errors
```bash
# Check if API key is set correctly
cat ~/Dentix/SpeechToText/extract_record.py | grep GROQ_API_KEY

# Test Groq connection
python3 -c "from groq import Groq; print('OK')"
```

### FFmpeg Not Found
```bash
# Install FFmpeg
sudo apt-get update
sudo apt-get install ffmpeg -y

# Verify
ffmpeg -version
```

### Port Already in Use
```bash
# Find process using port 8003
lsof -i :8003

# Kill it
kill -9 <PID>
```

---

## Performance Notes

**First Request:**
- ~2-3 seconds (Whisper model loading)
- Downloads model if not cached

**Subsequent Requests:**
- ~500ms - 1s per audio file
- Depends on audio length

**Audio Limits:**
- Max file size: 25MB
- Supported formats: WAV, MP3, M4A, etc.
- Whisper handles format conversion

---

## Flutter Integration

✅ **Already configured:**
- Endpoint: `http://104.198.50.23:8003/api/voice-to-record`
- File: `lib/api/web_services.dart`
- Method: POST multipart/form-data

**Used in:**
- Doctor's case details screen
- Voice note recording feature
- Clinical record creation

---

## Complete Architecture

```
Flutter App (Doctor Interface)
    ↓
    Records Audio
    ↓
Port 8003: Speech-to-Text API
    ↓
    ├─→ Whisper (audio → text)
    └─→ Groq AI (text → structured record)
    ↓
Returns to Flutter:
    - Diagnosis
    - Procedure
    - Treatment Plan
```

---

## All Services Overview

| Service | Port | Directory | Files |
|---------|------|-----------|-------|
| Patient Chatbot | 8000 | ~/Dentix/DentixChatbot | main.py, dentix_combined_bot.py |
| Doctor Chatbot | 8001 | ~/Dentix/DoctorChatbot | main.py |
| No-Show Model | 8002 | ~/Dentix/NoShowModel | main.py, no_show_model.pkl |
| Speech-to-Text | 8003 | ~/Dentix/SpeechToText | main.py, speech_to_text.py, extract_record.py |

---

## Quick Deploy Commands

```bash
# 1. Create directory
ssh YOUR_USERNAME@104.198.50.23
mkdir -p ~/Dentix/SpeechToText

# 2. Upload files (from Windows)
scp backend/speech_to_text_main.py YOUR_USERNAME@104.198.50.23:~/Dentix/SpeechToText/main.py
scp backend/speech_to_text.py YOUR_USERNAME@104.198.50.23:~/Dentix/SpeechToText/
scp backend/extract_record.py YOUR_USERNAME@104.198.50.23:~/Dentix/SpeechToText/

# 3. Add Groq API key
nano ~/Dentix/SpeechToText/extract_record.py
# Replace YOUR_GROQ_API_KEY_HERE with actual key

# 4. Install dependencies
cd ~/Dentix/SpeechToText
pip3 install fastapi uvicorn openai-whisper groq python-multipart

# 5. Start service
nohup uvicorn main:app --host 0.0.0.0 --port 8003 > speech.log 2>&1 &

# 6. Test
curl http://104.198.50.23:8003/
```

---

## ✅ Checklist

- [ ] Upload `speech_to_text_main.py` as `main.py`
- [ ] Upload `speech_to_text.py`
- [ ] Upload `extract_record.py`
- [ ] Add Groq API key to `extract_record.py`
- [ ] Install FFmpeg (if not installed)
- [ ] Install Python dependencies
- [ ] Start service on port 8003
- [ ] Check logs for successful startup
- [ ] Test health endpoint
- [ ] Configure firewall for port 8003
- [ ] Test from Flutter app
