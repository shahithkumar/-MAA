from enum import Enum

class Policy(Enum):
    SUPPORTIVE = "SUPPORTIVE"
    CBT = "CBT"
    GROUNDING = "GROUNDING"
    PSYCHOEDUCATION = "PSYCHOEDUCATION"
    CRISIS = "CRISIS"
    VALIDATION_FIRST_AID = "VALIDATION_FIRST_AID"
    CHOICE_OFFER = "CHOICE_OFFER"
    REFLECTION_CHECK = "REFLECTION_CHECK"
    GENERAL = "GENERAL"

class DecisionLayer:
    @staticmethod
    def select_policy(signals: dict, risk: str, state, mode: str = 'friend', session=None) -> str:
        """
        Layer 5: Therapeutic Policy Selection.
        """
        intensity = signals.get("intensity", 1)
        distortion = signals.get("distortion", "none")
        s_type = signals.get("type", "FEELING")
        state_str = str(state).split(".")[-1] # Handle Enum output safely

        # 1. Critical Safety Override (Always applies)
        if risk == "CRITICAL":
            return Policy.CRISIS.value
            
        # STICKY POLICY LOGIC
        # If we have a stored policy in session, prefer it unless major shift
        current_policy = getattr(session, 'current_policy', None)
        
        # Lock CBT/INTERVENTION if already in it, unless panic spikes
        if current_policy == Policy.CBT.value:
             if intensity > 8: 
                 return Policy.GROUNDING.value # Panic override
             if distortion == "none" and intensity < 4:
                 pass # Might exit, but usually stay until closure
             else:
                 return Policy.CBT.value # STICKY

        # --- Normal Mode (Standard Chatbot) ---
        if mode == 'normal':
            return Policy.GENERAL.value

        # --- First Aid Flow Enforcers (GUIDE MODE ONLY) ---
        if mode == 'guide':
            if state_str == "VALIDATION":
                return Policy.VALIDATION_FIRST_AID.value
                
            if state_str == "CHOICE":
                return Policy.CHOICE_OFFER.value
                
            if state_str == "REFLECTION":
                return Policy.REFLECTION_CHECK.value

        # 1.5 Continuity Check
        if state_str == "INTERVENTION":
             if distortion != "none":
                 return Policy.CBT.value
             return Policy.GROUNDING.value
            
        # 2. High Distress -> Grounding
        # Guide Mode must follow flow (no grounding in Validation/Choice).
        # Friend Mode can receive immediate grounding.
        can_ground = True
        if state_str == "CHECK_IN":
            can_ground = False
        if mode == 'guide' and state_str in ["VALIDATION", "CHOICE"]:
            can_ground = False
            
        if intensity >= 8 and can_ground:
            return Policy.GROUNDING.value
            
        # 3. Cognitive Distortion -> CBT
        if distortion != "none":
            return Policy.CBT.value
            
        # 4. Questions -> Psychoeducation
        if s_type == "QUESTION":
            return Policy.PSYCHOEDUCATION.value
            
        # 5. Default -> Reflexive Support (New Default)
        return Policy.SUPPORTIVE.value
