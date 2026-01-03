import json
import os
from langchain_groq import ChatGroq
from langchain.prompts import ChatPromptTemplate
from django.conf import settings

class SignalLayer:
    def __init__(self):
        # Using a low temperature for deterministic extraction
        self.llm = ChatGroq(
            api_key=settings.GROQ_API_KEY,
            model_name=os.getenv("GROQ_MODEL", "llama-3.1-8b-instant"),
            temperature=0.0 
        )
        
        # System prompt for signal extraction
        self.prompt = ChatPromptTemplate.from_messages([
            ("system", """
            You are an expert psychological classifier. 
            Analyze the user's text and extract the following signals in valid JSON format.
            
            OUTPUT SCHEMA:
            {{
                "emotion": "SAD" | "ANXIOUS" | "ANGRY" | "STRESSED" | "NEUTRAL" | "HAPPY",
                "intensity": <int 1-10>,
                "type": "FEELING" | "THOUGHT" | "BEHAVIOR" | "QUESTION",
                "distortion": "overgeneralization" | "catastrophizing" | "all_or_nothing" | "self_blame" | "none",
                "hopelessness": <bool>
            }}
            
            RULES:
            - Intensity 1-3 (Mild), 4-6 (Moderate), 7-10 (Severe).
            - Detect 'hopelessness' if user mentions giving up, worthlessness, or suicide.
            - Default to "none" for distortion if not clear.
            """),
            ("human", "{text}")
        ])
        
    def process(self, text: str) -> dict:
        """
        Layer 2: Psychological Signal Extraction.
        Returns a dict of signals.
        """
        try:
            chain = self.prompt | self.llm
            response = chain.invoke({"text": text})
            content = response.content
            
            # Simple JSON parsing (Llama 3 is usually good at raw JSON but could need cleaning)
            # In production, use a JsonOutputParser for robustness.
            start = content.find('{')
            end = content.rfind('}') + 1
            if start == -1 or end == 0:
                # Fallback
                return self._default_signals()
                
            json_str = content[start:end]
            signals = json.loads(json_str)
            return signals
            
        except Exception as e:
            print(f"Signal Extraction Error: {e}")
            return self._default_signals()
            
    def _default_signals(self):
        return {
            "emotion": "NEUTRAL",
            "intensity": 1,
            "type": "FEELING",
            "distortion": "none",
            "hopelessness": False
        }
