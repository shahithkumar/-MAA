import re

class InputLayer:
    @staticmethod
    def process(text: str) -> str:
        """
        Layer 1: Input Normalization.
        - Trims whitespace.
        - Normalizes casing (optional, but keeping original case is often better for emotion detection, 
          so we just strict sanitize).
        - Removes excessive whitespace/newlines.
        """
        if not text or not isinstance(text, str):
            return ""
            
        # 1. Trim whitespace
        clean_text = text.strip()
        
        # 2. Collaps multiple spaces/newlines
        clean_text = re.sub(r'\s+', ' ', clean_text)
        
        # 3. (Optional) Remove obviously broken chars if needed
        # For now, we trust the input is utf-8 text.
        
        return clean_text
