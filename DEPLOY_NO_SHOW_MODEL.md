# Deploy No-Show Prediction Model to Cloud (Port 8002)

## Current Status
✅ Backend code ready with no-show model
✅ Flutter UI updated to display predictions in receptionist interface
✅ API integration updated to use port 8002 with POST method

## Architecture
- **Port 8001**: Main API (voice-to-text, doctor chatbot)
- **Port 8002**: No-show prediction API (separate service)

## What You Need to Do

### Step 1: Create API File for Port 8002

SSH into your server and create a new file:

```bash
# SSH into your server
ssh YOUR_USERNAME@104.198.50.23

# Navigate to VoiceAI directory
cd /Dentix/VoiceAI

# Create the no-show API file
nano no_show_api.py
```

Copy this code into `no_show_api.py`:

```python
import os
import joblib
import numpy as np
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

app = FastAPI(title="Dentix No-Show Prediction API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Load the no-show prediction model
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
try:
    no_show_model = joblib.load(os.path.join(BASE_DIR, "no_show_model.pkl"))
    print("✅ No-show prediction model loaded successfully")
except Exception as e:
    no_show_model = None
    print(f"⚠️ Failed to load no-show model: {e}")

class PredictionRequest(BaseModel):
    appointments: int
    cancellations: int

@app.get("/")
def home():
    return {"message": "Dentix No-Show Prediction API is running on port 8002"}

@app.post("/predict")
def predict_no_show(request: PredictionRequest):
    """
    Predict the probability that a patient will be a no-show
    Based on their appointment history
    """
    print("=" * 50)
    print("📊 NO-SHOW PREDICTION REQUEST")
    print(f"Total appointments: {request.appointments}")
    print(f"Cancellations: {request.cancellations}")
    
    if not no_show_model:
        print("❌ Model not loaded")
        return {"error": "No-show prediction model not available", "status": "error"}
    
    try:
        # Calculate no-show ratio
        ratio = request.cancellations / request.appointments if request.appointments > 0 else 0
        
        # Prepare features [no_show_ratio, total_appointments]
        features = np.array([[ratio, request.appointments]])
        
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

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8002)
```

Save and exit (Ctrl+X, then Y, then Enter)

### Step 2: Upload Model File to Server

You need to upload `backend/no_show_model.pkl` to your Google Cloud VM.

**Option A: Using SCP (Secure Copy)**
```powershell
# From your local project directory (where backend folder is)
scp backend/no_show_model.pkl YOUR_USERNAME@104.198.50.23:/Dentix/VoiceAI/no_show_model.pkl
```

**Option B: Using Google Cloud Console**
1. Go to Google Cloud Console
2. Navigate to your VM instance
3. Click "SSH" to open terminal
4. On your local machine, go to `backend/` folder
5. Use the "Upload file" option in the SSH terminal menu
6. Upload `no_show_model.pkl`
7. Move it to the correct location:
```bash
mv no_show_model.pkl /Dentix/VoiceAI/no_show_model.pkl
```

**Option C: Using gcloud CLI**
```powershell
# Upload file using gcloud
gcloud compute scp backend/no_show_model.pkl YOUR_VM_NAME:/Dentix/VoiceAI/no_show_model.pkl --zone YOUR_ZONE
```

### Step 3: Verify Model File is Present

```bash
# Check if model file exists
ls -lh /Dentix/VoiceAI/no_show_model.pkl

# You should see something like:
# -rw-r--r-- 1 user user 2.5M Jan 15 10:30 no_show_model.pkl
```

### Step 4: Start the No-Show API Service (Port 8002)

```bash
# Navigate to VoiceAI directory
cd /Dentix/VoiceAI

# Start the no-show API service on port 8002
nohup uvicorn no_show_api:app --host 0.0.0.0 --port 8002 > no_show_api.log 2>&1 &

# Verify it's running
ps aux | grep no_show_api

# Check the logs
tail -f no_show_api.log
```

You should see in the logs:
```
✅ No-show prediction model loaded successfully
INFO:     Application startup complete.
INFO:     Uvicorn running on http://0.0.0.0:8002
```

### Step 5: Test the Endpoint

From your local machine or server:

```bash
# Test the prediction endpoint with POST request
curl -X POST "http://104.198.50.23:8002/predict" \
  -H "Content-Type: application/json" \
  -d '{"appointments": 10, "cancellations": 3}'

# Expected response:
# {"probability": 45.67, "status": "success"}
```

Or test the home endpoint:
```bash
curl "http://104.198.50.23:8002/"
# Expected: {"message": "Dentix No-Show Prediction API is running on port 8002"}
```

### Step 6: Test in Flutter App

1. Open the app
2. Login as receptionist
3. Go to receptionist home tab
4. You should now see risk indicators (High Risk / Medium Risk / Low Risk) with percentages on each appointment card

---

## How It Works

**API Architecture:**
- **Port 8001**: Main API (voice-to-text, doctor chatbot)
- **Port 8002**: No-show prediction API (separate service)

**The no-show prediction:**
- **Input**: JSON body with `appointments` and `cancellations` counts
- **Method**: POST request
- **Model**: Logistic regression trained on patient history
- **Output**: Probability (0-100%) that patient will be a no-show

**Risk Levels:**
- 🟢 **Low Risk** (0-30%): Green indicator
- 🟠 **Medium Risk** (30-70%): Orange indicator  
- 🔴 **High Risk** (70-100%): Red indicator

The Flutter app automatically loads predictions when viewing appointments in the receptionist interface.

---

## Managing Both Services

**Check running services:**
```bash
# Port 8001 (main API)
ps aux | grep voice_record_api

# Port 8002 (no-show API)
ps aux | grep no_show_api
```

**Stop services:**
```bash
# Stop port 8001
pkill -f voice_record_api

# Stop port 8002
pkill -f no_show_api
```

**Start services:**
```bash
cd /Dentix/VoiceAI

# Start main API (port 8001)
nohup uvicorn voice_record_api:app --host 0.0.0.0 --port 8001 > voice_api.log 2>&1 &

# Start no-show API (port 8002)
nohup uvicorn no_show_api:app --host 0.0.0.0 --port 8002 > no_show_api.log 2>&1 &
```

**View logs:**
```bash
# Main API logs
tail -f /Dentix/VoiceAI/voice_api.log

# No-show API logs
tail -f /Dentix/VoiceAI/no_show_api.log
```

---

## Troubleshooting

**If model doesn't load:**
```bash
# Check file permissions
ls -la /Dentix/VoiceAI/no_show_model.pkl

# Make sure the file is readable
chmod 644 /Dentix/VoiceAI/no_show_model.pkl
```

**If predictions don't show in app:**
1. Check backend logs: `tail -f /Dentix/VoiceAI/no_show_api.log`
2. Test endpoint manually with curl (see Step 5)
3. Check Flutter app logs for API errors
4. Verify base URL in `lib/api/web_services.dart` has port 8002 for predictions

**If you see "Model not loaded" error:**
- The model file path is wrong or file doesn't exist
- Check that `no_show_model.pkl` is in `/Dentix/VoiceAI/` directory
- Restart the service after placing the file

**Port already in use:**
```bash
# Find what's using port 8002
lsof -i :8002

# Kill the process (replace XXXX with PID)
kill XXXX

# Or force kill
kill -9 XXXX
```

**Connection refused from Flutter app:**
- Check if service is running: `ps aux | grep no_show_api`
- Check firewall: Port 8002 must be open in Google Cloud firewall rules
- Test locally on server first: `curl http://localhost:8002/`

---

## Firewall Configuration (Important!)

Make sure port 8002 is open in Google Cloud:

```bash
# Create firewall rule for port 8002
gcloud compute firewall-rules create allow-no-show-api \
  --allow tcp:8002 \
  --source-ranges 0.0.0.0/0 \
  --description "Allow no-show prediction API traffic"
```

Or via Google Cloud Console:
1. Go to VPC Network > Firewall
2. Create Firewall Rule
3. Name: `allow-no-show-api`
4. Direction: Ingress
5. Targets: All instances
6. Source IP ranges: `0.0.0.0/0`
7. Protocols and ports: `tcp:8002`
8. Create

---

## Quick Deploy Commands (All in One)

```bash
# 1. Upload model file
scp backend/no_show_model.pkl YOUR_USERNAME@104.198.50.23:/Dentix/VoiceAI/

# 2. SSH and deploy
ssh YOUR_USERNAME@104.198.50.23

# 3. Create API file (paste the Python code from Step 1)
cd /Dentix/VoiceAI
nano no_show_api.py
# [paste code, save and exit]

# 4. Start service
nohup uvicorn no_show_api:app --host 0.0.0.0 --port 8002 > no_show_api.log 2>&1 &

# 5. Test
curl -X POST "http://104.198.50.23:8002/predict" \
  -H "Content-Type: application/json" \
  -d '{"appointments": 10, "cancellations": 3}'
```

---

## Summary

✅ **Flutter App Changes**: Updated to use POST to `http://104.198.50.23:8002/predict`
✅ **Backend Setup**: New `no_show_api.py` file on port 8002
✅ **Model File**: Upload `no_show_model.pkl` to `/Dentix/VoiceAI/`
✅ **Firewall**: Open port 8002 in Google Cloud
✅ **Testing**: Use curl or Flutter app to verify

You need to upload `backend/no_show_model.pkl` to your Google Cloud VM.

**Option A: Using SCP (Secure Copy)**
```powershell
# From your local project directory (where backend folder is)
scp backend/no_show_model.pkl YOUR_USERNAME@104.198.50.23:/Dentix/VoiceAI/no_show_model.pkl
```

**Option B: Using Google Cloud Console**
1. Go to Google Cloud Console
2. Navigate to your VM instance
3. Click "SSH" to open terminal
4. On your local machine, go to `backend/` folder
5. Use the "Upload file" option in the SSH terminal menu
6. Upload `no_show_model.pkl`
7. Move it to the correct location:
```bash
mv no_show_model.pkl /Dentix/VoiceAI/no_show_model.pkl
```

**Option C: Using gcloud CLI**
```powershell
# Upload file using gcloud
gcloud compute scp backend/no_show_model.pkl YOUR_VM_NAME:/Dentix/VoiceAI/no_show_model.pkl --zone YOUR_ZONE
```

### Step 2: Update voice_record_api.py on Server

Connect to your VM via SSH and update the file:

```bash
# SSH into your server
ssh YOUR_USERNAME@104.198.50.23

# Navigate to the VoiceAI directory
cd /Dentix/VoiceAI

# Backup current file (optional)
cp voice_record_api.py voice_record_api.py.backup

# Edit the file (use nano or vim)
nano voice_record_api.py
```

Then copy the entire content from `backend/voice_record_api.py` (the local file I can see has all the code).

### Step 3: Verify Model File is Present

```bash
# Check if model file exists
ls -lh /Dentix/VoiceAI/no_show_model.pkl

# You should see something like:
# -rw-r--r-- 1 user user 2.5M Jan 15 10:30 no_show_model.pkl
```

### Step 4: Restart the Service

```bash
# Find the running process
ps aux | grep voice_record_api

# Kill the old process (replace XXXX with the process ID)
kill XXXX

# Or use pkill
pkill -f voice_record_api

# Start the service again
cd /Dentix/VoiceAI
nohup uvicorn voice_record_api:app --host 0.0.0.0 --port 8001 > voice_api.log 2>&1 &

# Verify it's running
ps aux | grep voice_record_api

# Check the logs
tail -f voice_api.log
```

You should see in the logs:
```
✅ No-show prediction model loaded successfully
```

### Step 5: Test the Endpoint

From your local machine or server:

```bash
# Test the prediction endpoint
curl "http://104.198.50.23:8001/predict?appointments=10&cancellations=3"

# Expected response:
# {"probability": 45.67, "status": "success"}
```

### Step 6: Test in Flutter App

1. Open the app
2. Login as receptionist
3. Go to receptionist home tab
4. You should now see risk indicators (High Risk / Medium Risk / Low Risk) with percentages on each appointment card

---

## How It Works

The no-show prediction uses:
- **Input**: Number of total appointments and cancellations for a patient
- **Model**: Machine learning model trained on patient history
- **Output**: Probability (0-100%) that patient will be a no-show

**Risk Levels:**
- 🟢 **Low Risk** (0-30%): Green indicator
- 🟠 **Medium Risk** (30-70%): Orange indicator  
- 🔴 **High Risk** (70-100%): Red indicator

The Flutter app automatically loads predictions when viewing appointments in the receptionist interface.

---

## Troubleshooting

**If model doesn't load:**
```bash
# Check file permissions
ls -la /Dentix/VoiceAI/no_show_model.pkl

# Make sure the file is readable
chmod 644 /Dentix/VoiceAI/no_show_model.pkl
```

**If predictions don't show in app:**
1. Check backend logs: `tail -f /Dentix/VoiceAI/voice_api.log`
2. Test endpoint manually with curl (see Step 5)
3. Check Flutter app logs for API errors
4. Verify base URL in `lib/api/web_services.dart` is `http://104.198.50.23:8001/`

**If you see "Model not loaded" error:**
- The model file path is wrong or file doesn't exist
- Check that `no_show_model.pkl` is in `/Dentix/VoiceAI/` directory
- Restart the service after placing the file

---

## Quick Deploy Command (All in One)

If you have SSH access and the model file ready:

```bash
# Upload model
scp backend/no_show_model.pkl YOUR_USERNAME@104.198.50.23:/Dentix/VoiceAI/

# SSH and restart
ssh YOUR_USERNAME@104.198.50.23 "cd /Dentix/VoiceAI && pkill -f voice_record_api && nohup uvicorn voice_record_api:app --host 0.0.0.0 --port 8001 > voice_api.log 2>&1 &"

# Test
curl "http://104.198.50.23:8001/predict?appointments=10&cancellations=3"
```
