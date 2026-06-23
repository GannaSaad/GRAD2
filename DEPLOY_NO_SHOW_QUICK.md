# Deploy No-Show API - Port 8002 🚀

## Quick Summary
Deploy standalone No-Show prediction service on port 8002, separate from patient chatbot (8000) and doctor chatbot (8001).

---

## Step 1: Create Service Directory

```bash
# SSH into VM
ssh YOUR_USERNAME@104.198.50.23

# Create new directory for No-Show service
mkdir -p ~/Dentix/NoShowModel
cd ~/Dentix/NoShowModel
```

---

## Step 2: Upload Files

Upload these 2 files from your local `backend/` folder to `~/Dentix/NoShowModel/`:

1. **no_show_api.py** (main API file)
2. **no_show_model.pkl** (trained model)

**Option A: Using SCP from Windows PowerShell**
```powershell
scp backend/no_show_api.py YOUR_USERNAME@104.198.50.23:~/Dentix/NoShowModel/
scp backend/no_show_model.pkl YOUR_USERNAME@104.198.50.23:~/Dentix/NoShowModel/
```

**Option B: Using Google Cloud Console**
- Open Cloud Console → Your VM → SSH
- Use "Upload file" button
- Upload both files to `~/Dentix/NoShowModel/`

---

## Step 3: Install Dependencies

```bash
cd ~/Dentix/NoShowModel

# Install required packages
pip3 install fastapi uvicorn scikit-learn joblib numpy
```

---

## Step 4: Create main.py

```bash
cd ~/Dentix/NoShowModel

# Copy no_show_api.py to main.py
cp no_show_api.py main.py
```

---

## Step 5: Start the Service

```bash
cd ~/Dentix/NoShowModel

# Start on port 8002
nohup uvicorn main:app --host 0.0.0.0 --port 8002 > no_show.log 2>&1 &

# Verify it's running
ps aux | grep "uvicorn.*8002"

# Check logs
tail -30 no_show.log
```

**Expected in logs:**
```
✅ No-show prediction model loaded successfully
INFO:     Application startup complete.
INFO:     Uvicorn running on http://0.0.0.0:8002
```

---

## Step 6: Test the API

```bash
# Test health endpoint
curl http://104.198.50.23:8002/

# Test prediction endpoint
curl -X POST "http://104.198.50.23:8002/predict" \
  -H "Content-Type: application/json" \
  -d '{"appointments": 10, "cancellations": 3}'
```

**Expected Response:**
```json
{
  "probability": 45.67,
  "status": "success"
}
```

---

## Step 7: Configure Firewall

Make sure port 8002 is open in Google Cloud:

```bash
gcloud compute firewall-rules create allow-no-show-api \
  --allow tcp:8002 \
  --source-ranges 0.0.0.0/0 \
  --description "No-Show Prediction API"
```

Or via **Google Cloud Console**:
- VPC Network → Firewall → Create Rule
- Name: `allow-no-show-api`
- Targets: All instances
- Source IP: `0.0.0.0/0`
- Protocols: `tcp:8002`

---

## Managing the Service

**Check if running:**
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

## Architecture Overview

```
Flutter App
    ↓
    ├─→ Port 8000: Patient Chatbot (RAG + Booking)
    ├─→ Port 8001: Doctor Chatbot (Groq + Gemini Vision)  
    └─→ Port 8002: No-Show Prediction (ML Model)
```

---

## Testing from Flutter App

1. Login as **Receptionist**
2. Go to **Receptionist Home Tab**
3. View appointments
4. You'll see risk indicators:
   - 🟢 **Low Risk** (0-30%)
   - 🟠 **Medium Risk** (30-70%)
   - 🔴 **High Risk** (70-100%)

---

## Troubleshooting

**Model not loading:**
```bash
# Check model file exists
ls -la ~/Dentix/NoShowModel/no_show_model.pkl

# Fix permissions
chmod 644 ~/Dentix/NoShowModel/no_show_model.pkl
```

**Port already in use:**
```bash
# Find what's using port 8002
lsof -i :8002

# Kill it
kill -9 <PID>
```

**Service not responding:**
```bash
# Check logs
tail -50 ~/Dentix/NoShowModel/no_show.log

# Test locally on VM
curl http://localhost:8002/

# Verify process is running
ps aux | grep "uvicorn.*8002"
```

---

## All Services Summary

| Service | Port | Directory | Command |
|---------|------|-----------|---------|
| Patient Chatbot | 8000 | ~/Dentix/DentixChatbot | `uvicorn main:app --host 0.0.0.0 --port 8000` |
| Doctor Chatbot | 8001 | ~/Dentix/DoctorChatbot | `uvicorn main:app --host 0.0.0.0 --port 8001` |
| No-Show Model | 8002 | ~/Dentix/NoShowModel | `uvicorn main:app --host 0.0.0.0 --port 8002` |

---

## ✅ Deployment Checklist

- [ ] Create `~/Dentix/NoShowModel/` directory
- [ ] Upload `no_show_api.py` and `no_show_model.pkl`
- [ ] Install dependencies (fastapi, uvicorn, scikit-learn, joblib, numpy)
- [ ] Copy `no_show_api.py` to `main.py`
- [ ] Start service on port 8002
- [ ] Verify in logs: "No-show prediction model loaded successfully"
- [ ] Test with curl
- [ ] Configure firewall (port 8002)
- [ ] Test from Flutter app (receptionist interface)
