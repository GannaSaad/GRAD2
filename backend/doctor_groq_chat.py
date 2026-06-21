"""
Doctor Chatbot with Groq (text) + Gemini (images)
Supports both text-only and image+text queries
"""

import os
from groq import Groq
from fastapi import UploadFile
import google.generativeai as genai

# Initialize Groq client for text
GROQ_API_KEY = os.getenv("GROQ_API_KEY", "your-groq-api-key-here")
groq_client = Groq(api_key=GROQ_API_KEY)

# Groq text model
TEXT_MODEL = "llama-3.3-70b-versatile"

# Gemini for images
GEMINI_API_KEY = os.getenv("GEMINI_API_KEY", "your-gemini-api-key-here")
genai.configure(api_key=GEMINI_API_KEY)
gemini_model = genai.GenerativeModel('gemini-2.0-flash-exp')


async def doctor_chat_text_only(question: str) -> dict:
    """
    Handle text-only doctor questions using Groq
    
    Args:
        question: The doctor's question
        
    Returns:
        dict with 'response' key containing the answer
    """
    try:
        system_prompt = """You are an expert dental assistant AI helping dentists with clinical decisions.
        
Your role:
- Provide evidence-based dental treatment recommendations
- Help with diagnosis and treatment planning
- Explain dental procedures and best practices
- Suggest appropriate clinical protocols
- Reference dental literature when relevant

Keep responses:
- Professional and clinically accurate
- Concise but comprehensive
- Focused on actionable advice
- Evidence-based when possible"""

        response = groq_client.chat.completions.create(
            model=TEXT_MODEL,
            messages=[
                {"role": "system", "content": system_prompt},
                {"role": "user", "content": question}
            ],
            temperature=0.3,
            max_tokens=2000,
        )
        
        answer = response.choices[0].message.content
        
        return {
            "response": answer,
            "model": TEXT_MODEL,
            "type": "text_only"
        }
        
    except Exception as e:
        print(f"❌ Error in doctor_chat_text_only: {e}")
        import traceback
        traceback.print_exc()
        return {
            "response": f"I apologize, but I encountered an error: {str(e)}",
            "model": TEXT_MODEL,
            "type": "text_only",
            "error": str(e)
        }


async def doctor_chat_with_image(image_file: UploadFile, question: str = None) -> dict:
    """
    Handle doctor questions with image analysis using Gemini Vision
    (Groq doesn't support vision models anymore)
    
    Args:
        image_file: Uploaded image file
        question: Optional specific question about the image
        
    Returns:
        dict with 'response' key containing the analysis
    """
    try:
        print("🖼️ Processing image with Gemini Vision...")
        
        # Read image
        image_bytes = await image_file.read()
        content_type = image_file.content_type or "image/jpeg"
        
        print(f"📁 Image size: {len(image_bytes)} bytes")
        print(f"📝 Content type: {content_type}")
        
        # Build prompt
        if question and question.strip():
            prompt = f"""Clinical Question: {question}

Please analyze this dental image and answer the question with:
1. Visible structures and findings
2. Clinical diagnosis
3. Treatment recommendations
4. Urgency level"""
        else:
            prompt = """Provide a comprehensive clinical analysis of this dental image:

1. **Visible Structures**: Identify teeth, restorations, pathology
2. **Clinical Findings**: Caries, bone loss, impactions, lesions
3. **Diagnosis**: Potential conditions based on imaging
4. **Treatment Recommendations**: Evidence-based suggestions
5. **Urgency**: Priority level (routine, urgent, emergency)

Be thorough, accurate, and clinically relevant."""
        
        # Call Gemini Vision API
        response = gemini_model.generate_content([
            prompt,
            {"mime_type": content_type, "data": image_bytes}
        ])
        
        analysis = response.text
        
        print(f"✅ Gemini response received: {len(analysis)} characters")
        
        return {
            "response": analysis,
            "model": "gemini-2.0-flash-exp",
            "type": "image_analysis"
        }
        
    except Exception as e:
        print(f"❌ Error in doctor_chat_with_image: {e}")
        import traceback
        traceback.print_exc()
        
        return {
            "response": f"I apologize, but I encountered an error analyzing the image: {str(e)}",
            "model": "gemini-2.0-flash-exp",
            "type": "image_analysis",
            "error": str(e)
        }
