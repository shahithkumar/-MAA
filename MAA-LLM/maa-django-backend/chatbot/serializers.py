from rest_framework import serializers
from .models import ChatRequest

class ChatRequestSerializer(serializers.Serializer):
    session_id = serializers.CharField(max_length=255)
    query = serializers.CharField()

class ChatResponseSerializer(serializers.Serializer):
    response = serializers.CharField()
