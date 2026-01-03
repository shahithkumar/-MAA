class SafetyLayer:
    @staticmethod
    def evaluate(signals: dict) -> str:
        """
        Layer 3: Risk & Safety Evaluation.
        Inputs: Signals dict
        Output: Risk Level (LOW, MEDIUM, HIGH, CRITICAL)
        """
        intensity = signals.get("intensity", 1)
        hopelessness = signals.get("hopelessness", False)
        emotion = signals.get("emotion", "NEUTRAL")
        
        # 1. Critical Risk
        # Hopelessness + High Intensity = Critical
        if hopelessness and intensity >= 7:
            return "CRITICAL"
        
        # 2. High Risk
        # Hopelessness alone, or Severe Distress
        if hopelessness or intensity >= 9:
            return "HIGH"
            
        # 3. Medium Risk
        # Moderate to High Intensity (Distress)
        if intensity >= 6 or emotion in ["ANGRY", "SAD"] and intensity >= 5:
            return "MEDIUM"
            
        # 4. Low Risk
        return "LOW"
