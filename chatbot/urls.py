from django.urls import path
from . import views

urlpatterns = [
    path('', views.root, name='root'),
    path('chat/', views.chat_view, name='chat'),
    path('chat/history/', views.chat_history_view, name='chat_history'),
    path('chat/history/<str:session_id>/', views.session_messages_view, name='session_messages'),
    path('doc-chat/', views.doc_chat_view, name='doc_chat'),
]
