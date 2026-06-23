"""
Dental Record Extraction using Groq AI
Extracts structured dental information from transcribed text
"""
import os
from groq import Groq

# Initialize Groq client
# Add your API key here or set as environment variable
GROQ_API_KEY = os.getenv("GROQ_API_KEY", "YOUR_GROQ_API_KEY_HERE")
client = Groq(api_key=GROQ_API_KEY)

def extract_dental_record(transcript: str) -> dict:
    """
    Extract structured dental record from transcript using Groq AI
    
    Args:
        transcript: Transcribed text from audio
        
    Returns:
        dict with keys:
            - diagnosis: Patient diagnosis
            - procedure_performed: Procedure done
            - treatment_plan: Future treatment plan
            - source: 'groq' or 'fallback'
    """
    try:
        if not transcript or transcript.strip() == "":
            return {
                "diagnosis": "",
                "procedure_performed": "",
                "treatment_plan": "",
                "source": "empty"
            }
        
        # Groq prompt for extraction
        prompt = f"""You are a dental record extraction assistant. Extract the following information from the doctor's notes:

Doctor's Notes: "{transcript}"

Extract and return ONLY the following in this exact format:
DIAGNOSIS: [extracted diagnosis or "Not mentioned"]
PROCEDURE: [extracted procedure or "Not mentioned"]
TREATMENT_PLAN: [extracted treatment plan or "Not mentioned"]

Rules:
- Be concise and professional
- If information is not mentioned, write "Not mentioned"
- Do not add extra information
- Use medical terminology when appropriate
"""

        print("🤖 Calling Groq AI for record extraction...")
        
        # Call Groq API
        chat_completion = client.chat.completions.create(
            messages=[
                {
                    "role": "system",
                    "content": "You are a professional dental record extraction assistant. Extract structured information from doctor's notes."
                },
                {
                    "role": "user",
                    "content": prompt
                }
            ],
            model="llama-3.3-70b-versatile",
            temperature=0.3,
            max_tokens=500
        )
        
        response = chat_completion.choices[0].message.content.strip()
        print(f"✅ Groq response received: {len(response)} characters")
        
        # Parse response
        diagnosis = ""
        procedure = ""
        treatment = ""
        
        for line in response.split("\n"):
            line = line.strip()
            if line.startswith("DIAGNOSIS:"):
                diagnosis = line.replace("DIAGNOSIS:", "").strip()
            elif line.startswith("PROCEDURE:"):
                procedure = line.replace("PROCEDURE:", "").strip()
            elif line.startswith("TREATMENT_PLAN:"):
                treatment = line.replace("TREATMENT_PLAN:", "").strip()
        
        # Clean up "Not mentioned" values
        if diagnosis.lower() in ["not mentioned", "none", ""]:
            diagnosis = ""
        if procedure.lower() in ["not mentioned", "none", ""]:
            procedure = ""
        if treatment.lower() in ["not mentioned", "none", ""]:
            treatment = ""
        
        return {
            "diagnosis": diagnosis,
            "procedure_performed": procedure,
            "treatment_plan": treatment,
            "source": "groq"
        }
        
    except Exception as e:
        print(f"❌ Groq extraction error: {e}")
        # Fallback: return transcript as diagnosis
        return {
            "diagnosis": transcript[:200],  # First 200 chars
            "procedure_performed": "",
            "treatment_plan": "",
            "source": "fallback"
        }
