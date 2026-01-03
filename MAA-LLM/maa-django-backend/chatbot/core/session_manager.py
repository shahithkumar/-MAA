from enum import Enum
import time

class State(Enum):
    CHECK_IN = "CHECK_IN"
    VALIDATION = "VALIDATION"
    EXPLORATION = "EXPLORATION"
    INTERVENTION = "INTERVENTION"
    REFLECTION = "REFLECTION"
    CLOSURE = "CLOSURE"

class SessionFSM:
    def __init__(self, session_id: str):
        self.session_id = session_id
        self.state = State.CHECK_IN
        self.history = []
        self.last_updated = time.time()
        
    def update_state(self, signals: dict, risk: str):
        """
        Layer 4: State Machine Logic.
        Decides the NEXT state based on current inputs.
        """
        # CRITICAL/HIGH Risk -> Override state logic to intervention immediately if not already handling it
        if risk in ["CRITICAL", "HIGH"] and self.state != State.INTERVENTION:
            self.state = State.INTERVENTION
            return self.state

        # Normal Flow Logic
        if self.state == State.CHECK_IN:
            # If user shared feelings (Emo/Intensity > 0), move to Validation
            if signals.get("type") == "FEELING" or signals.get("emotion") != "NEUTRAL":
                self.state = State.VALIDATION
            # If just "hi", stay in Check-in
                
        elif self.state == State.VALIDATION:
            # After validating, move to Explore (identifying the root)
            self.state = State.EXPLORATION
            
        elif self.state == State.EXPLORATION:
            # If distortion found, ready for Intervention
            if signals.get("distortion") != "none":
                self.state = State.INTERVENTION
            # Else keep exploring or offer a technique
            elif len(self.history) > 3: # Don't explore forever
                self.state = State.INTERVENTION
                
        elif self.state == State.INTERVENTION:
            # Fix: Don't exit immediately. Allow multi-turn interaction.
            # Only move to reflection if user seems done or signals relief.
            text = signals.get('text', '').lower() # We assume signal layer might pass raw text or we infer
            # For now, we'll just check if we've been here too long
            self.history.append("intervention_step")
            
            # Simple heuristic: If we've done > 5 steps OR user says "done/thanks/better", move on.
            if len([x for x in self.history if x == "intervention_step"]) > 5:
                self.state = State.REFLECTION
            
        elif self.state == State.REFLECTION:
            self.state = State.CLOSURE
            
        elif self.state == State.CLOSURE:
            self.state = State.CHECK_IN # Reset loop
            
        return self.state

# Simple in-memory storage for FSMs
# In production, use Redis or Django Session
_sessions = {}

def get_session(session_id: str) -> SessionFSM:
    if session_id not in _sessions:
        _sessions[session_id] = SessionFSM(session_id)
    return _sessions[session_id]
