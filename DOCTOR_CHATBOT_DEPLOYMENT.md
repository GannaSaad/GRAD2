# 🩺 Doctor Chatbot Deployment Guide - Port 8001

## Overview
Standalone Doctor AI Assistant (Dr. Shagy) for medical consultation.
- **Technology:** Groq AI + Gemini Vision
- **Port:** 8001
- **Features:** Text chat + Image analysis

---

## Step 1: Setup on VM

### Connect to VM:
```bash
ssh gannasaad0909@104.198.50.23
```

### Create directory structure:
```bash
mkdir -p ~/Dentix/DoctorChatbot
cd ~/Dentix/DoctorChatbot
```

### Create virtual environment:
```bash
python3 -m venv venv
source venv/bin/activate
```

### Install dependencies:
```bash
pip install fastapi uvicorn groq google-generativeai pillow python-multipart
```

---

## Step 2: Upload Main File

### Create the main.py file:
```bash
nano main.py
```

### Paste this content:
(Copy the content from `backend/doctor_chatbot_main.py`)

**IMPORTANT:** Replace these lines with your actual API keys:
```python
GROQ_API_KEY = "your_groq_api_key_here"
GEMINI_API_KEY = "your_gemini_api_key_here"
```

### Save and exit:
- `Ctrl+O` → `Enter` → `Ctrl+X`

---

## Step 3: Get API Keys

### Groq API Key:
1. Go to: https://console.groq.com/keys
2. Sign up / Login
3. Create new API key
4. Copy and paste in main.py

### Gemini API Key:
1. Go to: https://aistudio.google.com/app/apikey
2. Sign in with Google account
3. Create API key
4. Copy and paste in main.py

---

## Step 4: Run the Service

### Test run (foreground):
```bash
cd ~/Dentix/DoctorChatbot
source venv/bin/activate
uvicorn main:app --host 0.0.0.0 --port 8001
```

Press `Ctrl+C` to stop.

### Production run (background):
```bash
cd ~/Dentix/DoctorChatbot
source venv/bin/activate
nohup uvicorn main:app --host 0.0.0.0 --port 8001 > doctor_chatbot.log 2>&1 &
```

### Verify it's running:
```bash
tail -20 doctor_chatbot.log
```

Should see:
```
INFO:     Uvicorn running on http://0.0.0.0:8001
```

### Test the API:
```bash
curl http://104.198.50.23:8001/
```

Should return JSON with service info.

---

## Step 5: Manage the Service

### Check if running:
```bash
ps aux | grep uvicorn | grep 8001
```

### Stop the service:
```bash
pkill -f "uvicorn.*8001"
```

### Restart the service:
```bash
pkill -f "uvicorn.*8001"
cd ~/Dentix/DoctorChatbot
source venv/bin/activate
nohup uvicorn main:app --host 0.0.0.0 --port 8001 > doctor_chatbot.log 2>&1 &
```

### View logs:
```bash
tail -50 ~/Dentix/DoctorChatbot/doctor_chatbot.log
```

### View live logs:
```bash
tail -f ~/Dentix/DoctorChatbot/doctor_chatbot.log
```

---

## Step 6: Flutter Integration

### Update Flutter API URL

**File:** `lib/api/web_services.dart`

Make sure you have:
```dart
@POST("/doctor/chat-text")
Future<DoctorChatResponse> getDoctorReply(@Body() Map<String, dynamic> body);

@POST("/doctor/chat-with-image")
@MultiPart()
Future<DoctorChatResponse> doctorChatWithImage(
  @Part(name: "image") File image,
  @Part(name: "question") String? question,
);
```

**IMPORTANT:** Check baseUrl in web_services.dart:
```dart
@RestApi(baseUrl: "http://104.198.50.23:8001/")
```

If it's different, you need to update it.

### Test from Flutter:
1. Run app
2. Login as **Doctor**
3. Go to **Shagy** tab (Doctor Chatbot)
4. Send text message
5. Try uploading image

---

## Step 7: Testing

### Test Text Chat:
```bash
curl -X POST http://104.198.50.23:8001/doctor/chat-text \
  -H "Content-Type: application/json" \
  -d '{"message": "What are common causes of tooth sensitivity?", "history": []}'
```

### Test Image Upload (from local machine):
```bash
curl -X POST http://104.198.50.23:8001/doctor/chat-with-image \
  -F "image=@/path/to/dental-xray.jpg" \
  -F "question=What do you see in this X-ray?"
```

---

## File Structure on VM

```
~/Dentix/DoctorChatbot/
├── venv/                    # Virtual environment
├── main.py                  # Main API file
├── doctor_chatbot.log       # Log file
└── requirements.txt         # (optional) Dependencies list
```

---

## Ports Summary

| Service | Port | Location |
|---------|------|----------|
| Patient Chatbot | 8000 | `~/Dentix/DentixChatbot/` |
| Doctor Chatbot | 8001 | `~/Dentix/DoctorChatbot/` |
| No-Show Model | 8002 | `~/Dentix/NoShowModel/` |

---

## Troubleshooting

### Port already in use:
```bash
# Find process using port 8001
lsof -i :8001

# Kill it
pkill -f "uvicorn.*8001"
```

### Module not found errors:
```bash
cd ~/Dentix/DoctorChatbot
source venv/bin/activate
pip install fastapi uvicorn groq google-generativeai pillow python-multipart
```

### API key errors:
- Make sure you replaced the placeholder API keys in main.py
- Check keys are valid and not expired
- Groq: https://console.groq.com/keys
- Gemini: https://aistudio.google.com/app/apikey

### Can't connect from Flutter:
- Check VM firewall allows port 8001
- Verify service is running: `curl http://104.198.50.23:8001/`
- Check Flutter baseUrl matches VM IP

---

## Quick Commands Reference

```bash
# Start service
cd ~/Dentix/DoctorChatbot && source venv/bin/activate && \
nohup uvicorn main:app --host 0.0.0.0 --port 8001 > doctor_chatbot.log 2>&1 &

# Stop service
pkill -f "uvicorn.*8001"

# Check status
ps aux | grep "uvicorn.*8001"

# View logs
tail -50 ~/Dentix/DoctorChatbot/doctor_chatbot.log

# Test endpoint
curl http://104.198.50.23:8001/
```

---

## Success Criteria

- [ ] API running on port 8001
- [ ] Health check returns {"status": "healthy"}
- [ ] Text chat endpoint responds correctly
- [ ] Image upload endpoint works
- [ ] Flutter can connect and chat
- [ ] Logs show no errors

---

## 🎉 Done!

Doctor Chatbot is now running independently on port 8001, separate from voice recording and no-show prediction!

