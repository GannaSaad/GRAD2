# Google Cloud VM Setup for Dentix AI Model

## Step 1: Get Your VM External IP
1. Go to Google Cloud Console → Compute Engine → VM Instances
2. Find your VM instance
3. Copy the **External IP** address (e.g., `34.xxx.xxx.xxx`)

## Step 2: Update the App
Open `lib/api/web_services.dart` and replace:
```dart
@RestApi(baseUrl: "http://YOUR_VM_EXTERNAL_IP:8000/")
```

With your actual IP:
```dart
@RestApi(baseUrl: "http://34.xxx.xxx.xxx:8000/")
```

## Step 3: Configure VM Firewall
1. Go to VPC Network → Firewall Rules
2. Create a new firewall rule:
   - **Name**: `allow-dentix-api`
   - **Direction**: Ingress
   - **Targets**: All instances in the network (or specific target tags)
   - **Source IP ranges**: `0.0.0.0/0` (or restrict to specific IPs for security)
   - **Protocols and ports**: `tcp:8000`
3. Click **Create**

## Step 4: Start Your Model on the VM
SSH into your VM and run:
```bash
cd /path/to/your/model
python main.py --host 0.0.0.0 --port 8000
```

Or use a process manager like `screen` or `systemd` to keep it running:
```bash
screen -S dentix-api
python main.py --host 0.0.0.0 --port 8000
# Press Ctrl+A then D to detach
```

## Step 5: Test the Connection
```bash
curl http://YOUR_VM_EXTERNAL_IP:8000/chat -X POST -H "Content-Type: application/json" -d '{"message": "Hello"}'
```

You should get a response like:
```json
{"reply": "Hello! How can I help you?"}
```

## Step 6: Regenerate Dart Code
After updating the baseUrl in web_services.dart, run:
```bash
dart run build_runner build --delete-conflicting-outputs
```

## Security Notes (Important!)
⚠️ **For Production:**
1. **Use HTTPS** instead of HTTP
2. Set up **SSL/TLS** certificates
3. Restrict firewall to **specific IP ranges**
4. Add **API authentication** (API keys or OAuth)
5. Consider using **Google Cloud Load Balancer** with health checks

## Alternative: Use Cloud Run (Recommended)
Instead of VM, deploy to Cloud Run for better scalability:
1. Containerize your model with Docker
2. Deploy to Cloud Run
3. Use the HTTPS URL provided (like the current one)
4. Benefit from automatic scaling and HTTPS

## Troubleshooting
- **Connection refused**: Check if the model is running on VM
- **Timeout**: Check firewall rules
- **404 errors**: Verify the API endpoints match (`/chat`, `/doctor/chat-with-image`, `/predict`)
