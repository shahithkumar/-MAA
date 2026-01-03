
from typing import List, Dict, Optional
from core.config import settings

class FusionService:
    
    # Dynamic Fusion Logic: "The Humble Expert"
    # We trust models based on their own confidence, but cap it at 0.85 to allow disagreement.
    CONFIDENCE_CAP = 0.85

    def fuse_emotions(self, 
                     face_probs: Optional[Dict[str, float]], 
                     voice_probs: Optional[Dict[str, float]], 
                     text_probs: Optional[Dict[str, float]]) -> Dict:
        
        # Initialize
        fused_scores = {e: 0.0 for e in settings.FINAL_EMOTIONS}
        total_weight = 0.0
        
        inputs = [
            ("face", face_probs),
            ("voice", voice_probs),
            ("text", text_probs)
        ]
        
        valid_inputs = 0
        debug_info = []

        for name, probs in inputs:
            if not probs:
                continue

            valid_inputs += 1
            
            # 1. Get Modality Confidence (Max Prob)
            # probs is like {'happy': 0.2, 'sad': 0.8} -> conf = 0.8
            raw_conf = max(probs.values())
            
            # 2. Apply "Humble Cap" (Clip at 0.85)
            weight = min(raw_conf, self.CONFIDENCE_CAP)
            
            debug_info.append(f"{name}: Conf={raw_conf:.2f}, Weight={weight:.2f}")
            
            # 3. Weighted Sum
            total_weight += weight
            for emotion, prob in probs.items():
                if emotion in fused_scores:
                    fused_scores[emotion] += prob * weight

        # 4. Normalize
        final_probs = {}
        if valid_inputs == 0:
            return {"error": "No valid inputs provided"}
            
        if total_weight == 0:
             # Should practically never happen if valid_inputs > 0, but safe fallback
             return {"error": "Total weight is zero"}

        for emotion in settings.FINAL_EMOTIONS:
            final_probs[emotion] = fused_scores[emotion] / total_weight
        
        print(f"DEBUG: Fusion Weights - {', '.join(debug_info)}")
        print(f"DEBUG: Fusion Result - {final_probs}")
        
        # 5. Determine Winner
        dominant_emotion = max(final_probs, key=final_probs.get)
        
        return {
            "fused_probs": final_probs,
            "dominant_emotion": dominant_emotion,
            "confidence": final_probs[dominant_emotion],
            "modalities_used": valid_inputs,
            "debug_weights": debug_info
        }

fusion_service = FusionService()
