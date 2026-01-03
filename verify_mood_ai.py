
import os
import django
from rest_framework.test import APIRequestFactory
from django.contrib.auth.models import User
from django.utils import timezone
from datetime import timedelta
import sys
import sys
from django.conf import settings

# INLINE SETTINGS CONFIGURATION
if not settings.configured:
    settings.configure(
        SECRET_KEY='secret-key',
        DEBUG=True,
        ALLOWED_HOSTS=['*'],
        INSTALLED_APPS=[
            'django.contrib.admin',
            'django.contrib.auth',
            'django.contrib.contenttypes',
            'django.contrib.sessions',
            'django.contrib.messages',
            'django.contrib.staticfiles',
            'rest_framework',
            'auth_api',
            'chatbot',
        ],
        DATABASES={
            'default': {
                'ENGINE': 'django.db.backends.sqlite3',
                'NAME': ':memory:',
            }
        },
        MIDDLEWARE=[
            'django.contrib.sessions.middleware.SessionMiddleware',
            'django.contrib.auth.middleware.AuthenticationMiddleware',
            'django.contrib.messages.middleware.MessageMiddleware',
        ],
        ROOT_URLCONF='mental_health_backend.urls',
        TIME_ZONE='UTC',
        USE_TZ=True,
        GROQ_API_KEY=os.getenv('GROQ_API_KEY'),
    )

try:
    django.setup()
    from django.core.management import call_command
    call_command('migrate', verbosity=0) # Ensure tables exist
except Exception as e:
    import traceback
    traceback.print_exc()
    print(f"Django Setup/Migrate Error: {e}")
    sys.exit(1)

from auth_api.models import MoodLog
from auth_api.views import MoodSummaryView

def verify_ai_summary():
    print("🚀 Starting Mood AI Verification...")
    
    # 1. Create/Get User
    user, created = User.objects.get_or_create(username="test_ai_user")
    if created:
        user.set_password("password123")
        user.save()
        print("✅ Created test user")

    # 2. Clear old logs
    MoodLog.objects.filter(user=user).delete()

    # 3. Create Sample Logs (Mixed week)
    logs_data = [
        ('happy', 'Happy', 'Had a great lunch!', 6),
        ('anxious', 'Anxious', 'Work deadline stressing me out', 5),
        ('sad', 'Sad', 'Feeling lonely tonight', 4),
        ('happy', 'Happy', 'Solved a bug!', 2),
        ('calm', 'Calm', 'Meditation helped', 1),
    ]

    for emoji, label, note, days_ago in logs_data:
        MoodLog.objects.create(
            user=user, 
            mood_emoji=emoji, 
            mood_label=label, 
            note=note,
            created_at=timezone.now() - timedelta(days=days_ago)
        )
    print(f"✅ Created {len(logs_data)} sample mood logs")

    # 4. Simulate Request
    factory = APIRequestFactory()
    request = factory.get('/api/moods/summary/')
    request.user = user
    
    view = MoodSummaryView.as_view()
    
    try:
        response = view(request)
        print("\n🔎 Response Status:", response.status_code)
        if response.status_code == 200:
            print("\n🤖 AI Summary:", response.data['summary'])
            print("\n💡 Suggestions:", response.data['suggestions'])
            print("\n📊 Counts:", response.data['mood_counts'])
            
            if "Start logging" not in response.data['summary']:
                print("\n✅ SUCCESS: AI Generated a unique summary!")
            else:
                print("\n⚠️ WARNING: AI might have failed or not run (check API Key). Using fallback.")
        else:
            print("❌ FAILED:", response.data)
            
    except Exception as e:
        print(f"❌ Exception: {e}")

if __name__ == "__main__":
    verify_ai_summary()
