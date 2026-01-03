from typing import List

CRISIS_KEYWORDS: List[str] = [
    "suicidal", "suicide", "kill myself", "want to die", "hopeless", "worthless",
    "can't go on", "give up", "ending it all", "no reason to live"
]

SAFETY_MESSAGE = """
It sounds like you're going through a really tough time. You're not alone—reaching out is a brave first step. Please consider talking to a professional right away.

Helplines:
- India: AASRA (91-9820466726)
- US: National Suicide Prevention Lifeline (988)
- UK: Samaritans (116 123)

If it's an emergency, call local services immediately.
"""

def contains_crisis_keywords(text: str) -> bool:
    return any(keyword.lower() in text.lower() for keyword in CRISIS_KEYWORDS)
