from enum import Enum

class Policy(Enum):
    SUPPORTIVE = "SUPPORTIVE"
    CBT = "CBT"
    GROUNDING = "GROUNDING"
    PSYCHOEDUCATION = "PSYCHOEDUCATION"
    CRISIS = "CRISIS"

class DecisionLayer:
    @staticmethod
    def select_policy(signals: dict, risk: str, state) -> str:
        """
        Layer 5: Therapeutic Policy Selection.
        """
        intensity = signals.get("intensity", 1)
        distortion = signals.get("distortion", "none")
        s_type = signals.get("type", "FEELING")
        
        # 1. Critical Safety Override
        if risk == "CRITICAL":
            return Policy.CRISIS.value

        # 1.5 Continuity Check (Fix for "ok" dropping context)
        # If we are already in INTERVENTION, keep doing what we were doing (Grounding/CBT)
        # unless risk is critical.
        if str(state) == "State.INTERVENTION":
             # Default to Grounding for now as it's the most common intervention here
             # Ideally we'd store the "active policy" in the session, but this fixes the immediate drop.
             if distortion != "none":
                 return Policy.CBT.value
             return Policy.GROUNDING.value
            
        # 2. High Distress -> Grounding
        if intensity >= 8:
            return Policy.GROUNDING.value
            
        # 3. Cognitive Distortion -> CBT
        if distortion != "none":
            return Policy.CBT.value
            
        # 4. Questions -> Psychoeducation
        if s_type == "QUESTION":
            return Policy.PSYCHOEDUCATION.value
            
        # 5. Default -> Supportive
        return Policy.SUPPORTIVE.value
