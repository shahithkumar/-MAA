from chatbot.core.input_layer import InputLayer
from chatbot.core.signal_layer import SignalLayer
from chatbot.core.safety_layer import SafetyLayer
from chatbot.core.session_manager import get_session
from chatbot.core.decision_layer import DecisionLayer
from chatbot.core.rag_layer import RAGLayer
from chatbot.core.generation_layer import GenerationLayer

class Orchestrator:
    def __init__(self):
        self.signal_layer = SignalLayer()
        self.generation_layer = GenerationLayer()
        
    def process_message(self, session_id: str, text: str) -> str:
        """
        Executes the 7-Layer Cognitive Architecture.
        """
        # --- Layer 1: Input ---
        clean_text = InputLayer.process(text)
        if not clean_text:
            return "I'm listening."
            
        # --- Layer 2: Signals ---
        # Extracts: Emotion, Intensity, Distortion, etc.
        signals = self.signal_layer.process(clean_text)
        # Debug log for visibility
        # print(f"[ORCHESTRATOR] Signals: {signals}")
        
        # --- Layer 3: Risk ---
        # Output: LOW, MEDIUM, HIGH, CRITICAL
        risk_level = SafetyLayer.evaluate(signals)
        # print(f"[ORCHESTRATOR] Risk: {risk_level}")
        
        # --- Layer 4: FSM State ---
        # Decides: CHECK_IN vs VALIDATION vs INTERVENTION
        session = get_session(session_id)
        current_state = session.update_state(signals, risk_level)
        # print(f"[ORCHESTRATOR] State: {current_state.value}")
        
        # --- Layer 5: Policy ---
        # Decides: CBT vs SUPPORTIVE vs GROUNDING
        policy = DecisionLayer.select_policy(signals, risk_level, current_state)
        # print(f"[ORCHESTRATOR] Policy: {policy}")
        
        # --- Layer 6: RAG ---
        # Fetches content if policy needs it
        rag_context = RAGLayer.retrieve(policy, clean_text)
        
        # --- Layer 7: Generation ---
        # Renders the final response
        response = self.generation_layer.generate(
            text=clean_text,
            state=current_state.value,
            policy=policy,
            signals=signals,
            rag_context=rag_context
        )
        
        return response

# Global instance
_orchestrator = Orchestrator()

def process_message(session_id: str, text: str) -> str:
    return _orchestrator.process_message(session_id, text)
