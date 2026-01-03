# mental_health_backend/urls.py
from django.contrib import admin
from django.urls import path, include
from django.conf import settings
from django.conf.urls.static import static  # ✅ ADD THIS IMPORT
from django.http import JsonResponse

def root_view(request):
    return JsonResponse({"status": "ok", "message": "Mental Health API is running"})

urlpatterns = [
    path('', root_view),  # Root URL now shows status instead of error
    path('admin/', admin.site.urls),
    path('api/', include('chatbot.urls')),   # Chat is at api/chat/ and api/doc-chat/
    path('api/', include('auth_api.urls')),  # Your app URLs
]

# ✅ ADD THIS BLOCK FOR MEDIA FILES (DEVELOPMENT ONLY)
if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)
    urlpatterns += static(settings.STATIC_URL, document_root=settings.STATIC_ROOT)