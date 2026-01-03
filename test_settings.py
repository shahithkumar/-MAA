
from mental_health_backend.settings import *
import os

SECRET_KEY = 'insecure-test-key-for-verification-only'
DEBUG = True
ALLOWED_HOSTS = ['*']

# Override Database to use SQLite for testing/verification
DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': BASE_DIR / 'db.sqlite3',
    }
}
