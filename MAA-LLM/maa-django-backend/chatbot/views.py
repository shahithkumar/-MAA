from rest_framework.decorators import api_view
from rest_framework.response import Response
from rest_framework import status
from .serializers import ChatRequestSerializer, ChatResponseSerializer
from .orchestrator import process_message
from .logger import log_chat
from .doc_engine import query_documents

@api_view(['GET'])
def root(request):
    return Response({"message": "Welcome to MAA 2.0 (Cognitive Architecture)"})

@api_view(['POST'])
def chat_view(request):
    serializer = ChatRequestSerializer(data=request.data)
    if not serializer.is_valid():
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    session_id = serializer.validated_data['session_id']
    query = serializer.validated_data['query']
    
    # OLD LOGIC REMOVED: Crisis check is now inside Layer 3 (SafetyLayer)
    # is_crisis = contains_crisis_keywords(query)
    
    # 7-LAYER SYSTEM CALL
    response = process_message(session_id, query)
    
    # Infer crisis for logging if needed (optional optimization)
    # For now simply log.
    log_chat(session_id, query, response, False)
    return Response({"response": response})

@api_view(['POST'])
def doc_chat_view(request):
    serializer = ChatRequestSerializer(data=request.data)
    if not serializer.is_valid():
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    session_id = serializer.validated_data['session_id']
    query = serializer.validated_data['query']
    response = query_documents(query)
    log_chat(session_id, query, response, False)
    return Response({"response": response})
