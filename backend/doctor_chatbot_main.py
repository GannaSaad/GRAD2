"""
Doctor Chatbot API - Standalone
Groq AI + Gemini Vision for medical consultation
Port: 8001
"""

from fastapi import FastAPI, File, UploadFile, Form
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import google.generativeai as genai
from groq import Groq
import os
from PIL import Image
import io

app = FastAPI(title="Dr. Shagy - Doctor AI Assistant")

# CORS setup
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ==================== API Keys Setup ====================
# Replace these with your actual API keys
GROQ_API_KEY = "your_groq_api_key_here"
GEMINI_API_KEY = "your_gemini_api_key_here"

# Initialize clients
groq_client = Groq(api_key=GROQ_API_KEY)
genai.configure(api_key=GEMINI_API_KEY)

# ==================== Models ====================
class TextChatRequest(BaseModel):
    message: str
    history: list = []

class ChatResponse(BaseModel):
    reply: str

# ==================== Text Chat Endpoint ====================
@app.post("/doctor/chat-text", response_model=ChatResponse)
async def chat_text(request: TextChatRequest):
    """
    Text-based medical consultation using Groq AI
    """
    try:
        # Build conversation context
        messages = []
        
        # System prompt for medical context
        system_prompt = """You are Dr. Shagy, an expert dental AI assistant. 
You help dentists with:
- Diagnosis and treatment planning
- Dental condition analysis
- Clinical decision support
- Treatment recommendations

Provide professional, accurate medical advice for dental professionals.
Keep responses concise but thorough."""
        
        messages.append({
            "role": "system",
            "content": system_prompt
        })
        
        # Add conversation history
        for msg in request.history[-5:]:  # Keep last 5 messages for context
            messages.append(msg)
        
        # Add current message
        messages.append({
            "role": "user",
            "content": request.message
        })
        
        # Call Groq API
        response = groq_client.chat.completions.create(
            model="llama-3.3-70b-versatile",
            messages=messages,
            temperature=0.7,
            max_tokens=1000,
        )
        
        reply = response.choices[0].message.content
        
        return ChatResponse(reply=reply)
    
    except Exception as e:
        print(f"❌ Error in text chat: {e}")
        return ChatResponse(reply=f"I apologize, but I encountered an error: {str(e)}")


# ==================== Image Analysis Endpoint ====================
@app.post("/doctor/chat-with-image", response_model=ChatResponse)
async def chat_with_image(
    image: UploadFile = File(...),
    question: str = Form(None)
):
    """
    Image-based dental analysis using Gemini Vision
    Analyzes X-rays, clinical photos, etc.
    """
    try:
        # Read and process image
        image_bytes = await image.read()
        pil_image = Image.open(io.BytesIO(image_bytes))
        
        # Prepare prompt
        if question and question.strip():
            prompt = f"""As Dr. Shagy, an expert dental AI assistant, analyze this dental image.

Question from doctor: {question}

Provide:
1. What you observe in the image
2. Possible diagnosis or conditions
3. Recommended treatment approach
4. Any additional clinical notes

Be professional and thorough."""
        else:
            prompt = """As Dr. Shagy, an expert dental AI assistant, analyze this dental image.

Provide:
1. Detailed description of what you see
2. Potential dental conditions or abnormalities
3. Recommended diagnostic steps
4. Suggested treatment options
5. Clinical notes and observations

Be thorough and professional."""
        
        # Use Gemini Vision for analysis
        model = genai.GenerativeModel('gemini-1.5-flash')
        response = model.generate_content([prompt, pil_image])
        
        reply = response.text
        
        return ChatResponse(reply=reply)
    
    except Exception as e:
        print(f"❌ Error in image analysis: {e}")
        return ChatResponse(reply=f"I apologize, but I couldn't analyze the image: {str(e)}")


# ==================== Health Check ====================
@app.get("/")
def root():
    return {
        "status": "running",
        "service": "Dr. Shagy - Doctor AI Assistant",
        "version": "1.0",
        "endpoints": {
            "text_chat": "/doctor/chat-text",
            "image_analysis": "/doctor/chat-with-image"
        }
    }

@app.get("/health")
def health():
    return {"status": "healthy", "service": "doctor_chatbot"}


# ==================== Run Instructions ====================
"""
To run this API:

1. Install dependencies:
   pip install fastapi uvicorn groq google-generativeai pillow python-multipart

2. Set your API keys in the code above

3. Run:
   uvicorn doctor_chatbot_main:app --host 0.0.0.0 --port 8001

4. Or with nohup:
   nohup uvicorn doctor_chatbot_main:app --host 0.0.0.0 --port 8001 > doctor_chatbot.log 2>&1 &
"""
