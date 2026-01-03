from typing import List

CRISIS_KEYWORDS: List[str] = [
    "suicidal", "suicide", "kill myself", "want to die", "hopeless", "worthless",
    "can't go on", "give up", "ending it all", "no reason to live"
]

SAFETY_MESSAGE = """
It sounds like you're going through a really tough time. You're not alone—reaching out is a brave first step. Please consider talking to a professional right away.

Helplines (India 24/7):
- KIRAN: 1800-599-0019
- Tele-MANAS: 14416 or 1-800-891-4416
- Vandrevala Foundation: +91 9999666555
- Contact our Team:Shahith:6301103526

If it's an emergency, please call 112 immediately.
"""

def contains_crisis_keywords(text: str) -> bool:
    return any(keyword.lower() in text.lower() for keyword in CRISIS_KEYWORDS)
