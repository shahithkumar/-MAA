import os
import django
from django.conf import settings

# Setup Django environment
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'maa.settings')
django.setup()

from chatbot.chat_engine import get_response

print("Testing Groq Chat Engine...")
try:
    response = get_response("test_session_1", "Hello! Are you running on Groq?")
    print(f"\nResponse from AI:\n{response}")
    print("\n✅ Verification SUCCESS: Groq is responding.")
except Exception as e:
    print(f"\n❌ Verification FAILED: {e}")
