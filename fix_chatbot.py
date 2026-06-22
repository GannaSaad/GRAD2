#!/usr/bin/env python3
"""
Script to fix the get_doctors() function in dentix_combined_bot.py
"""

def fix_chatbot_file():
    file_path = "~/Dentix/DentixChatbot/dentix_combined_bot.py"
    
    # Read the file
    with open(file_path.replace("~", "/home/gannasaad0909"), 'r') as f:
        content = f.read()
    
    # Find and replace the get_doctors function
    old_function = '''def get_doctors():
    doctors = []
    for doc in db.collection("doctors").stream():
        data = doc.to_dict()
        if data.get("active") is True:
            name = str(data.get("name", "")).strip()
            if not name:
                continue
            if not name.lower().startswith("dr "):
                name = "Dr " + name.title()
            doctors.append(name)
    return sorted(list(set(doctors)))'''
    
    new_function = '''def get_doctors():
    doctors = []
    for doc in db.collection("users").where("role", "==", "doctor").stream():
        data = doc.to_dict()
        name = str(data.get("name", "")).strip()
        if not name:
            continue
        if not name.lower().startswith("dr "):
            name = "Dr " + name.title()
        doctors.append(name)
    return sorted(list(set(doctors)))'''
    
    # Replace
    content = content.replace(old_function, new_function)
    
    # Write back
    with open(file_path.replace("~", "/home/gannasaad0909"), 'w') as f:
        f.write(content)
    
    print("✅ Fixed get_doctors() function")
    print("\nNow restart the server:")
    print("pkill -f 'uvicorn.*8000'")
    print("cd ~/Dentix/DentixChatbot")
    print("source venv/bin/activate")
    print("nohup uvicorn main:app --host 0.0.0.0 --port 8000 > chatbot.log 2>&1 &")

if __name__ == "__main__":
    fix_chatbot_file()
