import sys
import os

print(f"Python Executable: {sys.executable}")

try:
    import django
    print(f"✅ Django {django.get_version()} found.")
except ImportError:
    print("❌ Django NOT found.")

try:
    from langchain.chains import ConversationChain
    print("✅ langchain.chains.ConversationChain found.")
except ImportError as e:
    print(f"❌ langchain error: {e}")

try:
    import langchain_groq
    print("✅ langchain_groq found.")
except ImportError:
    print("❌ langchain_groq NOT found.")
