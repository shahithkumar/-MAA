from django.urls import path
from . import views

urlpatterns = [
    path('', views.root, name='root'),
    path('chat/', views.chat_view, name='chat'),
    path('doc-chat/', views.doc_chat_view, name='doc_chat'),
]
