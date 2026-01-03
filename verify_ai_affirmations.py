import sys
import os
import django
from unittest.mock import MagicMock

# MOCK MISSING DEPENDENCIES
sys.modules['speech_recognition'] = MagicMock()
sys.modules['pydub'] = MagicMock()

# Setup Django environment
sys.path.append('c:/Users/shahi/OneDrive/Documents/Mental_Health_App_Backend')
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'mental_health_backend.settings')
django.setup()

from requests import Request, RequestException
from rest_framework.test import APIRequestFactory
from auth_api.views import GenerateAIAffirmationsView, CustomAffirmationView
from auth_api.models import CustomAffirmation
from django.contrib.auth import get_user_model

User = get_user_model()

def verify_ai_generation():
    print("\n--- Verifying AI Generation Endpoint ---")
    factory = APIRequestFactory()
    
    # Mock user
    try:
        user = User.objects.first()
        if not user:
            print("❌ No users found to test with.")
            return
    except Exception as e:
        print(f"❌ Error getting user: {e}")
        return

    # 1. Test Generate Endpoint
    view = GenerateAIAffirmationsView.as_view()
    data = {
        'user_context': 'Focus: Confidence. Challenge: Public Speaking. Direction: I am calm and clear.',
        'count': 3
    }
    request = factory.post('/api/affirmations/generate-ai/', data, format='json')
    request.user = user
    
    print(f"Sending request for user: {user.email}")
    
    try:
        response = view(request)
        print(f"Status Code: {response.status_code}")
        
        if response.status_code == 200:
            print("✅ Generate Success! Data:")
            print(response.data)
        else:
            print(f"❌ Generate Failed: {response.data}")
            
    except Exception as e:
        print(f"❌ Exception in Generate: {e}")

def verify_save_custom_affirmation():
    print("\n--- Verifying Save Custom Affirmation Endpoint ---")
    factory = APIRequestFactory()
    user = User.objects.first()
    
    view = CustomAffirmationView.as_view()
    
    # Test saving an AI generated affirmation (with explicit text)
    data = {
        'focus_area': 'confidence',
        'challenge': 'public speaking',
        'positive_direction': 'calm and clear',
        'affirmation_text': 'I speak with confidence and clarity, knowing my voice matters.' # Explicit override
    }
    
    request = factory.post('/api/affirmations/custom/', data, format='json')
    request.user = user
    
    try:
        response = view(request)
        print(f"Status Code: {response.status_code}")
        
        if response.status_code == 201:
            print("✅ Save Success!")
            print(f"Saved Text: {response.data.get('affirmation_text')}")
            
            # Verify DB integrity
            saved_id = response.data.get('id')
            saved_obj = CustomAffirmation.objects.get(id=saved_id)
            if saved_obj.affirmation_text == data['affirmation_text']:
                 print("✅ DB Verification Passed: Text matches.")
            else:
                 print(f"❌ DB Verification Failed: expected {data['affirmation_text']}, got {saved_obj.affirmation_text}")
                 
        else:
            print(f"❌ Save Failed: {response.data}")
            
    except Exception as e:
         print(f"❌ Exception in Save: {e}")


if __name__ == "__main__":
    verify_ai_generation()
    verify_save_custom_affirmation()
