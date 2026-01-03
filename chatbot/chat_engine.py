import os
from dotenv import load_dotenv
from langchain.prompts import (
    ChatPromptTemplate,
    MessagesPlaceholder,
    SystemMessagePromptTemplate,
    HumanMessagePromptTemplate,
)
from langchain_groq import ChatGroq
from langchain.chains import LLMChain
from langchain.memory import ConversationBufferMemory
from django.conf import settings

load_dotenv()

# Initialize Groq
try:
    llm = ChatGroq(
        api_key=settings.GROQ_API_KEY,
        model_name=os.getenv("GROQ_MODEL", "llama-3.1-8b-instant"),
        temperature=0.6  # Slightly lower for more consistent helpfulness
    )
except Exception as e:
    print(f"Error initializing Groq: {e}")
    llm = None

# System Prompt - The Brain of MAA
MAA_SYSTEM_PROMPT = """
You are MAA, a compassionate and supportive mental health companion using Groq's Llama 3 model.
Your goal is to provide a safe, non-judgmental space for users to express themselves.

CORE INSTRUCTIONS:
1.  **Empathy First**: Always validate the user's feelings first. Use phrases like "It sounds like you're going through a lot..." or "I hear how difficult this is for you."
2.  **Concise & Natural**: Keep responses short (2-3 sentences max usually) and conversational. Avoid robot-speak like "As an AI..." or "I understand."
3.  **Active Listening**: Reflect back what you hear to show understanding.
4.  **Gentle Inquiry**: Ask *one* simple, open-ended question to help the user explore their feelings. Don't interrogate.
5.  **Safety**: If the user mentions self-harm, suicide, or violence, YOU MUST immediately provide the crisis resources below and urge them to seek professional help. Do not try to treat serious crises alone.

CRISIS RESOURCES (Only share if safety risk detected):
- India: 9820466726 (AASRA)
- US: 988 (Suicide & Crisis Lifeline)
- Global: "Please contact local emergency services immediately."

Tone: Warm, calm, reassuring, and human-like.
Name: MAA.
"""

session_memory_map = {}

def get_response(session_id: str, user_query: str) -> str:
    if not llm:
        return "Error: AI engine not initialized. Check server logs."
        
    if session_id not in session_memory_map:
        # Create a new memory/chain for this session
        memory = ConversationBufferMemory(
            memory_key="chat_history",
            return_messages=True
        )
        
        prompt = ChatPromptTemplate.from_messages([
            SystemMessagePromptTemplate.from_template(MAA_SYSTEM_PROMPT),
            MessagesPlaceholder(variable_name="chat_history"),
            HumanMessagePromptTemplate.from_template("{input}")
        ])
        
        # Use LLMChain for flexibility with prompts
        session_memory_map[session_id] = LLMChain(
            llm=llm,
            prompt=prompt,
            memory=memory,
            verbose=True
        )
        
    chain = session_memory_map[session_id]
    
    # Run prediction
    try:
        response = chain.predict(input=user_query)
        return response
    except Exception as e:
        return f"I'm having trouble thinking right now. ({str(e)})"
