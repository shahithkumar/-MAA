import os
import django
import sys

# Add project root to path
sys.path.append(os.getcwd())

# Setup Django environment
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'mental_health_backend.settings')
django.setup()

print("✅ Django Environment Setup Complete")

try:
    from chatbot.chat_engine import get_response
    print("✅ Chat Engine Imported Successfully")
except ImportError as e:
    print(f"❌ Failed to import Chat Engine: {e}")
    sys.exit(1)

try:
    from chatbot.doc_engine import query_documents
    print("✅ Doc Engine Imported Successfully")
except ImportError as e:
    print(f"❌ Failed to import Doc Engine: {e}") 
    # Don't exit, RAG might be optional or lazy loaded, but good to know
    
print("\n--- Testing Groq Chat (Simple) ---")
try:
    response = get_response("test_session_startup_check", "Hello, are you online?")
    print(f"🤖 AI Response: {response}")
    if "Error" in response:
        print("⚠️ Warning: Chat engine returned an error message.")
    else:
        print("✅ Chat Engine Test Passed")
except Exception as e:
    print(f"❌ Chat Engine Runtime Error: {e}")

print("\n--- Testing RAG (Vector Store) ---")
try:
    # This triggers the loading of 'data' folder
    from chatbot.doc_engine import query_engine
    if query_engine:
        print("✅ RAG Engine Loaded & Index Created (data folder found)")
    else:
        print("⚠️ RAG Engine did not initialize (check 'data' folder presence/content)")
except Exception as e:
    print(f"❌ RAG Engine Runtime Error: {e}")
