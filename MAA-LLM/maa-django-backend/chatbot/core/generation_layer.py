import os
from langchain_groq import ChatGroq
from langchain.prompts import ChatPromptTemplate
from django.conf import settings

class GenerationLayer:
    def __init__(self):
        # Using a slightly higher temp for conversational warmth, 
        # but constrained by the strict prompt.
        self.llm = ChatGroq(
            api_key=settings.GROQ_API_KEY,
            model_name=os.getenv("GROQ_MODEL", "llama-3.1-8b-instant"),
            temperature=0.6
        )

    def generate(self, text: str, state: str, policy: str, signals: dict, rag_context: str) -> str:
        """
        Layer 7: Controlled Response Generation.
        """
        
        # 1. Select the correct System Instruction based on Policy
        policy_instructions = self._get_policy_instruction(policy)
        
        # 2. Construct the PROMPT
        system_msg = f"""
        You are MAA, a controlled mental health dialogue system.
        
        CURRENT STATE: {state}
        SELECTED POLICY: {policy}
        USER SIGNALS: Emotion={signals.get('emotion')}, Intensity={signals.get('intensity')}/10
        
        HARD CONSTRAINTS:
        1. Maintain the Persona: Warm, empathetic, professional (Woebot-style).
        2. Strict Policy Adherence: Follow the 'POLICY INSTRUCTIONS' below exactly.
        3. No Hallucination: If RAG CONTEXT is provided, use it. Do not invent medical facts.
        4. Length: Short (2-4 sentences). One snippet of advice/question max.
        5. DO NOT mention the 'CURRENT STATE', 'POLICY', or 'SIGNALS' in your response. Output ONLY the dialogue.
        
        POLICY INSTRUCTIONS ({policy}):
        {policy_instructions}
        
        RAG CONTEXT (If any):
        {rag_context if rag_context else "None available."}
        """
        
        prompt = ChatPromptTemplate.from_messages([
            ("system", system_msg),
            ("human", "{text}")
        ])
        
        # 3. Render
        chain = prompt | self.llm
        try:
            response = chain.invoke({"text": text})
            return response.content
        except Exception as e:
            return "I'm listening, please go on. (Error in generation)"

    def _get_policy_instruction(self, policy: str) -> str:
        if policy == "CRISIS":
            return """
            - ACKNOWLEDGE the pain immediately.
            - DO NOT try to treat.
            - PROVIDE these resources: 'India: 9820466726 (AASRA), US: 988'.
            - URGE professional help.
            - Tone: Urgent but calm.
            """
        elif policy == "SUPPORTIVE":
            return """
            - VALIDATE the user's emotion (e.g., 'It makes sense you feel that way').
            - NORMALIZE their experience.
            - Ask ONE gentle open-ended question to explore further.
            - NO advice yet.
            """
        elif policy == "CBT":
            return """
            - Identify the cognitive distortion (if any).
            - DO NOT explain the whole solution at once.
            - Ask ONE gentle question to help the user challenge the thought themselves (e.g., 'What evidence do you have for that?').
            - Wait for their reply.
            """
        elif policy == "GROUNDING":
            return """
            - Guide the user through a grounding exercise STEP-BY-STEP.
            - Give only the FIRST step (e.g., 'Let's take a deep breath. Tell me when you're ready.').
            - Do NOT list all 5 steps at once. Wait for the user to do it.
            - Use the RAG CONTEXT for the specific technique.
            """
        elif policy == "PSYCHOEDUCATION":
            return """
            - Explain ONE concept clearly using RAG CONTEXT.
            - Keep it short/bite-sized.
            - Ask a question to check if they relate to it.
            """
        else:
            return "Be kind and supportive."
