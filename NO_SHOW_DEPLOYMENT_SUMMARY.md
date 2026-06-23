# No-Show Prediction API - Deployment Summary ✅

## What You're Deploying
Standalone No-Show prediction service on **port 8002** - separate from patient chatbot and doctor chatbot.

---

## ✅ Flutter App Status
Already configured and ready:
- API endpoint: `http://104.198.50.23:8002/predict`
- Request: POST with JSON body `{"appointments": X, "cancellations": Y}`
- Response: `{"probability": XX.XX, "status": "success"}`
- UI: Risk indicators already display in Receptionist Home Tab

---

## 📦 Files Ready for Deployment

### Local Files (in `backend/` folder):
1. ✅ **no_show_api.py** - FastAPI service code
2. ✅ **no_show_model.pkl** - Trained ML model (~2.5 MB)

### Target Location on VM:
- Directory: `~/Dentix/NoShowModel/`
- Files: `main.py` (copy of no_show_api.py) + `no_show_model.pkl`

---

## 🚀 Quick Deployment Commands

### 1. Create Directory & Upload Files
```bash
# SSH into VM
ssh YOUR_USERNAME@104.198.50.23

# Create directory
mkdir -p ~/Dentix/NoShowModel
cd ~/Dentix/NoShowModel
```

**From your Windows PowerShell:**
```powershell
# Upload both files
scp backend/no_show_api.py YOUR_USERNAME@104.198.50.23:~/Dentix/NoShowModel/
scp backend/no_show_model.pkl YOUR_USERNAME@104.198.50.23:~/Dentix/NoShowModel/
```

### 2. Setup on VM
```bash
cd ~/Dentix/NoShowModel

# Copy API file to main.py
cp no_show_api.py main.py

# Install dependencies
pip3 install fastapi uvicorn scikit-learn joblib numpy

# Start service
nohup uvicorn main:app --host 0.0.0.0 --port 8002 > no_show.log 2>&1 &

# Verify
ps aux | grep "uvicorn.*8002"
tail -30 no_show.log
```

### 3. Test
```bash
# Test prediction
curl -X POST "http://104.198.50.23:8002/predict" \
  -H "Content-Type: application/json" \
  -d '{"appointments": 10, "cancellations": 3}'
```

---

## 🎯 Expected Result

**In logs (`tail no_show.log`):**
```
✅ No-show prediction model loaded successfully
INFO:     Application startup complete.
INFO:     Uvicorn running on http://0.0.0.0:8002
```

**API response:**
```json
{
  "probability": 45.67,
  "status": "success"
}
```

**In Flutter app (Receptionist Home Tab):**
- Green indicator: Low Risk (0-30%)
- Orange indicator: Medium Risk (30-70%)
- Red indicator: High Risk (70-100%)

---

## 🔧 Service Management

**Check status:**
```bash
ps aux | grep "uvicorn.*8002"
```

**Stop service:**
```bash
pkill -f "uvicorn.*8002"
```

**Start service:**
```bash
cd ~/Dentix/NoShowModel
nohup uvicorn main:app --host 0.0.0.0 --port 8002 > no_show.log 2>&1 &
```

**View logs:**
```bash
tail -50 ~/Dentix/NoShowModel/no_show.log
```

---

## 🔥 Firewall Configuration

If you get "connection refused" from Flutter app:

```bash
gcloud compute firewall-rules create allow-no-show-api \
  --allow tcp:8002 \
  --source-ranges 0.0.0.0/0
```

Or use Google Cloud Console: VPC Network → Firewall → Create Rule for port 8002

---

## 📊 Complete Architecture

```
Flutter App
    ↓
    ├─→ Port 8000: ~/Dentix/DentixChatbot      (Patient Chatbot - RAG + Booking)
    ├─→ Port 8001: ~/Dentix/DoctorChatbot      (Doctor AI - Groq + Gemini)
    └─→ Port 8002: ~/Dentix/NoShowModel        (No-Show Prediction - ML)
```

---

## ✅ Deployment Checklist

- [ ] SSH into VM: `104.198.50.23`
- [ ] Create directory: `mkdir -p ~/Dentix/NoShowModel`
- [ ] Upload `no_show_api.py` via SCP
- [ ] Upload `no_show_model.pkl` via SCP
- [ ] Copy to main.py: `cp no_show_api.py main.py`
- [ ] Install dependencies: `pip3 install fastapi uvicorn scikit-learn joblib numpy`
- [ ] Start service: `nohup uvicorn main:app --host 0.0.0.0 --port 8002 > no_show.log 2>&1 &`
- [ ] Check logs: Model loaded successfully
- [ ] Test with curl: Get probability response
- [ ] Configure firewall: Port 8002 open
- [ ] Test from Flutter app: Risk indicators appear

---

## 🎉 Next Steps After Deployment

1. **Test in Flutter App:**
   - Login as Receptionist
   - Go to Receptionist Home Tab
   - View appointments for different days
   - Verify risk indicators show on cards

2. **Monitor Logs:**
   - Watch for any errors: `tail -f ~/Dentix/NoShowModel/no_show.log`
   - Check predictions are being calculated correctly

3. **All Services Running:**
   - Port 8000: Patient chatbot ✅
   - Port 8001: Doctor chatbot ✅  
   - Port 8002: No-Show prediction ✅

---

## 📝 Files Reference

- **Deployment Guide:** `DEPLOY_NO_SHOW_QUICK.md` (detailed steps)
- **Technical Details:** `NO_SHOW_PORT_8002_SUMMARY.md`
- **Backend Code:** `backend/no_show_api.py`
- **ML Model:** `backend/no_show_model.pkl`
- **Flutter API:** `lib/api/web_services.dart`
- **Flutter UI:** `lib/features/tabs/receptionist_tabs/receptionist_home_tab.dart`

---

## Done! 🚀
Flutter app is ready. Backend files are ready. Just deploy to VM and test!
