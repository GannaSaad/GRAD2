# Add these imports at the top of main.py
from doctor_groq_chat import doctor_chat_text_only, doctor_chat_with_image

# Add these new endpoints (keep all existing endpoints!)

# NEW: Doctor text-only chat with Groq
@app.post("/doctor/chat-text")
async def doctor_text_chat(request: dict):
    """
    Doctor Assistant: Text-only questions using Groq
    
    Body: {"question": "your question here"}
    """
    question = request.get("question", "").strip()
    
    if not question:
        return {"response": "Please provide a question.", "error": "empty_question"}
    
    result = await doctor_chat_text_only(question)
    return result


# UPDATED: Doctor image analysis with Groq Vision (replaces Gemini)
@app.post("/doctor/chat-with-image-groq")
async def doctor_clinical_analysis_groq(
    image: UploadFile = File(...),
    question: str = Form(None)
):
    """
    Doctor Assistant: Image analysis with optional question using Groq Vision
    
    Replaces the Gemini-based /doctor/chat-with-image endpoint
    """
    result = await doctor_chat_with_image(image, question)
    return result


# Keep the old Gemini endpoint for backwards compatibility (optional)
# You can remove this if you want to fully switch to Groq
@app.post("/doctor/chat-with-image")
async def doctor_clinical_analysis_legacy(
    image: UploadFile = File(...),
    question: str = Form(None)
):
    """
    LEGACY: Redirects to Groq-based endpoint
    Kept for backwards compatibility
    """
    return await doctor_clinical_analysis_groq(image, question)
