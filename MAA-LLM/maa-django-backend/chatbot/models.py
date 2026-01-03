from django.db import models
from pydantic import BaseModel

class ChatRequest(BaseModel):
    session_id: str
    query: str

# Optional: Add DB models for sessions if scaling
class Session(models.Model):
    session_id = models.CharField(max_length=255, unique=True)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.session_id
