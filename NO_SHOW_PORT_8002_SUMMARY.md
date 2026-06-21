# No-Show Prediction on Port 8002 - Summary

## ✅ Changes Made

### Flutter App Changes (Local - Already Done)
1. **`lib/api/web_services.dart`**
   - Changed prediction endpoint from GET to POST
   - Updated to use full URL: `http://104.198.50.23:8002/predict`
   - Changed parameters from query params to JSON body

2. **`lib/api/web_services.g.dart`**
   - Updated generated code to match POST method
   - Uses JSON body instead of query parameters

3. **`lib/data/repos/prediction_repo_impl.dart`**
   - Updated to send JSON body: `{'appointments': X, 'cancellations': Y}`

4. **`lib/features/tabs/receptionist_tabs/receptionist_home_tab.dart`**
   - Already displays risk indicators (no changes needed)

### Backend Files (Need to Deploy to Server)
1. **`backend/no_show_api.py`** (NEW FILE)
   - FastAPI app running on port 8002
   - POST endpoint `/predict` accepting JSON body
   - Loads `no_show_model.pkl` from same directory
   - Returns probability as percentage

2. **`backend/no_show_model.pkl`** (EXISTING FILE)
   - Trained model file
   - Needs to be uploaded to server at `/Dentix/VoiceAI/`

---

## 🚀 Deployment Steps

### On Your Server (via SSH):

```bash
# 1. Upload the model file
scp backend/no_show_model.pkl YOUR_USERNAME@104.198.50.23:/Dentix/VoiceAI/

# 2. SSH into server
ssh YOUR_USERNAME@104.198.50.23

# 3. Create the API file
cd /Dentix/VoiceAI
nano no_show_api.py
# Copy content from backend/no_show_api.py, save and exit

# 4. Start the service
nohup uvicorn no_show_api:app --host 0.0.0.0 --port 8002 > no_show_api.log 2>&1 &

# 5. Verify it's running
ps aux | grep no_show_api
tail -f no_show_api.log

# 6. Test the endpoint
curl -X POST "http://104.198.50.23:8002/predict" \
  -H "Content-Type: application/json" \
  -d '{"appointments": 10, "cancellations": 3}'
```

### Firewall (Google Cloud Console):
- Make sure port 8002 is open in firewall rules
- Or run: `gcloud compute firewall-rules create allow-no-show-api --allow tcp:8002 --source-ranges 0.0.0.0/0`

---

## 📊 API Specification

**Endpoint**: `POST http://104.198.50.23:8002/predict`

**Request Body**:
```json
{
  "appointments": 10,
  "cancellations": 3
}
```

**Response**:
```json
{
  "probability": 45.67,
  "status": "success"
}
```

**Error Response**:
```json
{
  "error": "Error message",
  "status": "error"
}
```

---

## 🧪 Testing

### Test from Command Line:
```bash
curl -X POST "http://104.198.50.23:8002/predict" \
  -H "Content-Type: application/json" \
  -d '{"appointments": 15, "cancellations": 8}'
```

### Test from Flutter App:
1. Login as receptionist
2. Go to receptionist home tab
3. View appointments for any day
4. You should see risk indicators on appointment cards:
   - 🟢 Low Risk (0-30%)
   - 🟠 Medium Risk (30-70%)
   - 🔴 High Risk (70-100%)

---

## 🔧 Troubleshooting

**Service not starting:**
- Check logs: `tail -f /Dentix/VoiceAI/no_show_api.log`
- Verify model exists: `ls -la /Dentix/VoiceAI/no_show_model.pkl`

**Port already in use:**
- Find process: `lsof -i :8002`
- Kill it: `kill -9 <PID>`

**Connection refused from Flutter:**
- Check firewall rules (port 8002 must be open)
- Test locally on server: `curl http://localhost:8002/`

**Predictions not showing:**
- Check Flutter logs for API errors
- Test endpoint manually with curl
- Verify internet connection

---

## 📝 Architecture

```
Flutter App
    ↓
    ├─→ Port 8001: voice_record_api.py (voice-to-text, doctor chatbot)
    └─→ Port 8002: no_show_api.py (no-show predictions)
```

Both services run independently and can be started/stopped separately.
