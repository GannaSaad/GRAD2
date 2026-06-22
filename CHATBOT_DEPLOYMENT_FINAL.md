# 🎯 Patient Chatbot - Final Deployment Guide

## Problem
Appointments booked via chatbot not appearing in Activity Tab because `patientId` is empty.

## Solution
Send `patient_id` from Flutter → Backend saves it in Firebase → Activity Tab shows it.

---

## Step 1: Update Backend on VM

### Connect to VM:
```bash
ssh gannasaad0909@104.198.50.23
cd ~/Dentix/DentixChatbot
```

### Backup current file:
```bash
cp main.py main.py.backup
```

### Edit main.py:
```bash
nano main.py
```

### Replace ENTIRE content with:
```python
from fastapi import FastAPI
from pydantic import BaseModel
from dentix_combined_bot import combined_chatbot

app = FastAPI(title="Dentix Patient Chatbot API")

class ChatRequest(BaseModel):
    message: str
    patient_id: str = ""
    patient_name: str = "Mobile Patient"

@app.get("/")
def root():
    return {"status": "running", "service": "Dentix Patient Chatbot"}

@app.post("/chat")
def chat(request: ChatRequest):
    reply = combined_chatbot(
        request.message,
        patient_name=request.patient_name or "Mobile Patient",
        patient_id=request.patient_id or ""
    )
    return {"reply": reply}
```

### Save: `Ctrl+O` → `Enter` → `Ctrl+X`

---

## Step 2: Restart Chatbot

```bash
# Stop current chatbot
pkill -f "uvicorn.*8000"

# Start with new code
cd ~/Dentix/DentixChatbot
source ~/Dentix/VoiceAI/venv/bin/activate
nohup uvicorn main:app --host 0.0.0.0 --port 8000 > chatbot.log 2>&1 &

# Verify it's running
tail -20 chatbot.log
```

You should see:
```
INFO:     Uvicorn running on http://0.0.0.0:8000
```

---

## Step 3: Flutter Already Fixed ✅

The Flutter code in `lib/features/tabs/chatbot_tab/chatbot_tab.dart` now:
1. Gets `FirebaseAuth.instance.currentUser.uid`
2. Sends it as `patient_id` in request body
3. Backend receives it and passes to `combined_chatbot()`

---

## Step 4: Test

### From Flutter App:
1. Login as patient
2. Go to Chatbot Tab
3. Book appointment:
   - "I want to book"
   - Choose doctor
   - Choose date
   - Choose time
4. Complete booking

### Verify in Firebase:
1. Open Firebase Console
2. Go to `appointments` collection
3. Find latest appointment
4. **Check: `patientId` should NOT be empty** ✅

### Verify in App:
1. Go to Activity Tab
2. **Appointment should appear** ✅

---

## Step 5: Troubleshooting

### If patientId still empty:

#### Check backend logs:
```bash
tail -50 ~/Dentix/DentixChatbot/chatbot.log
```

#### Check if backend received patient_id:
Add this to `main.py` after line 18:
```python
@app.post("/chat")
def chat(request: ChatRequest):
    print(f"🔍 Received: patient_id={request.patient_id}, name={request.patient_name}")
    reply = combined_chatbot(...)
    return {"reply": reply}
```

Then restart and check logs.

#### Test backend directly:
```bash
curl -X POST http://104.198.50.23:8000/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "hi", "patient_id": "TEST123", "patient_name": "Test"}'
```

Should return chat response.

---

## Expected Flow

```
Flutter App (patient_id: "abc123")
    ↓
    POST /chat {"message": "book", "patient_id": "abc123"}
    ↓
Backend main.py receives request
    ↓
Calls combined_chatbot(message, patient_id="abc123")
    ↓
combined_chatbot books appointment
    ↓
Saves to Firebase with patientId="abc123"
    ↓
Activity Tab filters: .where('patientId', isEqualTo: "abc123")
    ↓
✅ Appointment appears!
```

---

## Files Changed

### Flutter:
- ✅ `lib/features/tabs/chatbot_tab/chatbot_tab.dart` - sends patient_id

### Backend (VM):
- ✅ `~/Dentix/DentixChatbot/main.py` - accepts patient_id parameter
- ✅ `~/Dentix/DentixChatbot/dentix_combined_bot.py` - already supports patient_id (no change needed!)

### Firebase:
- No changes needed - just storing data correctly now

---

## Success Criteria

- [ ] Backend `main.py` updated
- [ ] Chatbot restarted on port 8000
- [ ] Flutter app rebuilt (Hot Restart)
- [ ] Test booking from app
- [ ] Firebase `patientId` field filled
- [ ] Appointment appears in Activity Tab

---

## That's It! 🎉

Simple 2-file fix:
1. Flutter sends `patient_id`
2. Backend accepts and uses it

Everything else already works!
