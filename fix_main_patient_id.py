#!/usr/bin/env python3
"""
Fix main.py to accept and pass patient_id parameter
"""

fix_code = '''
# This will fix ~/Dentix/DentixChatbot/main.py

# Step 1: Update ChatRequest model
OLD_MODEL = """class ChatRequest(BaseModel):
    message: str"""

NEW_MODEL = """class ChatRequest(BaseModel):
    message: str
    patient_id: str = ""
    patient_name: str = "Mobile Patient" """

# Step 2: Update chat endpoint
OLD_ENDPOINT = """    response = combined_chatbot(request.message)"""

NEW_ENDPOINT = """    response = combined_chatbot(
        request.message,
        patient_id=request.patient_id or "",
        patient_name=request.patient_name or "Mobile Patient"
    )"""

print("🔧 Copy and run these commands on your VM:")
print()
print("# Backup first")
print("cp ~/Dentix/DentixChatbot/main.py ~/Dentix/DentixChatbot/main.py.backup")
print()
print("# Edit main.py - add these lines:")
print("# In ChatRequest class (around line 10-12):")
print(NEW_MODEL)
print()
print("# In @app.post('/chat') endpoint (around line 20):")
print(NEW_ENDPOINT)
print()
print("# Then restart:")
print("pkill -f 'uvicorn.*8000'")
print("cd ~/Dentix/DentixChatbot")
print("source ~/Dentix/VoiceAI/venv/bin/activate")
print("nohup uvicorn main:app --host 0.0.0.0 --port 8000 > chatbot.log 2>&1 &")
'''

print(fix_code)
print("\n" + "="*60)
print("✅ او اعملي كده بالتفصيل:")
print("="*60)

# Show manual steps
manual_steps = """
1️⃣ افتحي SSH للـ VM:
   ssh gannasaad0909@104.198.50.23

2️⃣ اعملي backup:
   cp ~/Dentix/DentixChatbot/main.py ~/Dentix/DentixChatbot/main.py.backup

3️⃣ افتحي الملف:
   nano ~/Dentix/DentixChatbot/main.py

4️⃣ دوري على السطرده (حوالين سطر 10):
   class ChatRequest(BaseModel):
       message: str

5️⃣ غيريه لـ:
   class ChatRequest(BaseModel):
       message: str
       patient_id: str = ""
       patient_name: str = "Mobile Patient"

6️⃣ دوري على السطر ده (حوالين سطر 20):
   response = combined_chatbot(request.message)

7️⃣ غيريه لـ:
   response = combined_chatbot(
       request.message,
       patient_id=request.patient_id or "",
       patient_name=request.patient_name or "Mobile Patient"
   )

8️⃣ احفظي: Ctrl+O ثم Enter ثم Ctrl+X

9️⃣ أوقفي الـ chatbot:
   pkill -f "uvicorn.*8000"

🔟 شغليه تاني:
   cd ~/Dentix/DentixChatbot
   source ~/Dentix/VoiceAI/venv/bin/activate
   nohup uvicorn main:app --host 0.0.0.0 --port 8000 > chatbot.log 2>&1 &

1️⃣1️⃣ اتأكدي شغال:
   tail -20 ~/Dentix/DentixChatbot/chatbot.log
"""

print(manual_steps)
print("="*60)
print("🎯 بعد كده جربي تحجزي من التطبيق - patientId مش هيكون فاضي!")
print("="*60)
