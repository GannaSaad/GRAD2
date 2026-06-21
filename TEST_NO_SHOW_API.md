# Test No-Show API - Debugging 422 Error

## Problem
Getting **422 Unprocessable Entity** errors when calling `/predict` endpoint.

## From the logs:
```
INFO: 105.196.69.188:57986 - "POST /predict HTTP/1.1" 422 Unprocessable Entity
```

This means:
1. ✅ API is running on port 8002
2. ❌ Request format is wrong or validation failed

---

## Possible Issues

### Issue 1: Wrong Request Format
The API expects JSON body like this:
```json
{
  "appointments": 6,
  "cancellations": 4
}
```

But FastAPI might be receiving empty body or wrong format.

### Issue 2: Pydantic Validation Failed
The `PredictionRequest` model expects `int` values, but might be receiving strings or null.

---

## Solution: Add Better Error Logging

Update `backend/no_show_api.py` to see what's being received:

```python
@app.post("/predict")
def predict_no_show(request: PredictionRequest):
    """
    Predict the probability that a patient will be a no-show
    Based on their appointment history
    """
    print("=" * 50)
    print("📊 NO-SHOW PREDICTION REQUEST")
    print(f"Raw request: {request}")
    print(f"Total appointments: {request.appointments}")
    print(f"Cancellations: {request.cancellations}")
    print(f"Request type - appointments: {type(request.appointments)}")
    print(f"Request type - cancellations: {type(request.cancellations)}")
    
    if not no_show_model:
        print("❌ Model not loaded")
        return {"error": "No-show prediction model not available", "status": "error"}
    
    try:
        # Validate inputs
        if request.appointments <= 0:
            print("❌ Invalid appointments count")
            return {"error": "Appointments must be greater than 0", "status": "error"}
        
        if request.cancellations < 0:
            print("❌ Invalid cancellations count")
            return {"error": "Cancellations cannot be negative", "status": "error"}
        
        # Calculate no-show ratio
        ratio = request.cancellations / request.appointments if request.appointments > 0 else 0
        
        # Prepare features [no_show_ratio, total_appointments]
        features = np.array([[ratio, request.appointments]])
        
        print(f"Features: {features}")
        
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
```

---

## Quick Test from Terminal

### Test 1: From your local machine
```bash
curl -X POST "http://104.198.50.23:8002/predict" \
  -H "Content-Type: application/json" \
  -d '{"appointments": 6, "cancellations": 4}'
```

Expected response:
```json
{"probability": 66.67, "status": "success"}
```

### Test 2: Check what Flutter is sending

Add this debug print in `lib/data/repos/prediction_repo_impl.dart`:

```dart
@override
Future<NoShowPrediction> getPrediction(
    String patientId,
    int appointments,
    int cancellations
    ) async {
  try {
    // Prepare JSON body for POST request to port 8002
    final body = {
      'appointments': appointments,
      'cancellations': cancellations,
    };
    
    // DEBUG: Print what we're sending
    print("🔍 Sending prediction request:");
    print("  Patient ID: $patientId");
    print("  Body: $body");
    
    final response = await _webServices.getNoShowPrediction(body);
    
    // DEBUG: Print response
    print("✅ Prediction response: ${response.probability}");
    
    return NoShowPrediction(
      probability: response.probability ?? 0.0,
      patientId: patientId.isEmpty ? "unknown_patient" : patientId,
      appointments: appointments,
      cancellations: cancellations,
      pending: (appointments - cancellations) < 0 ? 0 : (appointments - cancellations),
    );
  } catch (e) {
    debugPrint("❌ PREDICTION ERROR for Patient $patientId: ${e.toString()}");
    
    // Print full error details
    print("Error type: ${e.runtimeType}");
    print("Error message: $e");

    // Fallback object so the UI doesn't crash if the internet fails
    return NoShowPrediction(
      probability: 0.0,
      patientId: patientId,
      appointments: appointments,
      cancellations: cancellations,
      pending: 0,
    );
  }
}
```

---

## Check Server Logs

SSH into your server and check the logs:

```bash
ssh YOUR_USERNAME@104.198.50.23

# Check if service is running
ps aux | grep no_show_api

# View recent logs
tail -100 /Dentix/VoiceAI/no_show_api.log

# View logs in real-time while testing
tail -f /Dentix/VoiceAI/no_show_api.log
```

Look for lines showing what the API received.

---

## Common Causes of 422 Error

1. **Missing Content-Type header**: Should be `application/json`
2. **Wrong data types**: Sending strings instead of integers
3. **Missing fields**: Not sending both `appointments` and `cancellations`
4. **Extra fields**: Sending fields that aren't in the model
5. **Null values**: Sending null instead of numbers

---

## Next Steps

1. Add debug logging to `prediction_repo_impl.dart`
2. Restart Flutter app and check console output
3. Check server logs: `tail -f /Dentix/VoiceAI/no_show_api.log`
4. Test with curl to verify API works standalone
5. Compare curl request with Flutter request to find the difference
