from rest_framework import serializers
from .models import ChatRequest, ChatSession, ChatMessage

class ChatRequestSerializer(serializers.Serializer):
    session_id = serializers.CharField(max_length=255)
    query = serializers.CharField()
    mode = serializers.CharField(required=False, default="friend") # 'normal', 'friend', or 'guide'

class ChatResponseSerializer(serializers.Serializer):
    response = serializers.CharField()

class ChatMessageSerializer(serializers.ModelSerializer):
    class Meta:
        model = ChatMessage
        fields = ['sender', 'content', 'timestamp']

class ChatSessionSerializer(serializers.ModelSerializer):
    class Meta:
        model = ChatSession
        fields = ['session_id', 'mode', 'title', 'created_at', 'updated_at']
