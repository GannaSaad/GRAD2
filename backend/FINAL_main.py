from fastapi import FastAPI
from pydantic import BaseModel
from dentix_combined_bot import combined_chatbot

app = FastAPI(title="Dentix Patient Chatbot API")

class ChatRequest(BaseModel):
    message: str
    patient_id: str = ""
    patient_name: str = "Mobile Patient"

@app.get("/")
def root():
    return {"status": "running", "service": "Dentix Patient Chatbot"}

@app.post("/chat")
def chat(request: ChatRequest):
    reply = combined_chatbot(
        request.message,
        patient_name=request.patient_name or "Mobile Patient",
        patient_id=request.patient_id or ""
    )
    return {"reply": reply}
