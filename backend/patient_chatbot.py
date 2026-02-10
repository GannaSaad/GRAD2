# chatbot/patient_chatbot.py
import json

# The JSON data will now be loaded lazily to ensure fast server startup.
chunks = None

def get_patient_answer(disease, category):
    global chunks

    # Lazy-load the data on the first request.
    if chunks is None:
        try:
            with open("data/chunks_with_embeddings.json", "r", encoding="utf-8") as f:
                chunks = json.load(f)
        except FileNotFoundError:
            return "Error: The chatbot data file is missing. Please contact support."
        except json.JSONDecodeError:
            return "Error: The chatbot data file is corrupt. Please contact support."

    if not category:
        return "No information available for this question category."

    # Filter chunks based on the provided disease and category.
    filtered = [c for c in chunks if c.get("disease") == disease and c.get("category") == category]

    if not filtered:
        return f"No information available for {disease} regarding {category}."

    # Return the text of the first matching chunk.
    return filtered[0].get("text", "Content not available.")
