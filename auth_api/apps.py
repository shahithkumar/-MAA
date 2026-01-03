from django.apps import AppConfig
import logging

class AuthApiConfig(AppConfig):
    default_auto_field = 'django.db.models.BigAutoField'
    name = 'auth_api'
    
    # Store models on the config instance
    # LEGACY: Models are now handled by the separate ML Inference Server.
    
    def ready(self):
        # We no longer load heavy ML models here.
        # Check ml_inference_server/ for the actual model logic.
        print("\n[INFO] Auth API Ready (ML delegated to Inference Server)\n")
