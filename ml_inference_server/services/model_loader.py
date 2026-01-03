
import torch
import os
from transformers import AutoTokenizer, Wav2Vec2Processor
from core.config import settings

class ModelLoader:
    _instance = None
    
    def __new__(cls):
        if cls._instance is None:
            cls._instance = super(ModelLoader, cls).__new__(cls)
            cls._instance.face_model = None
            cls._instance.voice_model = None
            cls._instance.text_model = None
            cls._instance.tokenizer = None
            cls._instance.processor = None
            cls._instance.device = torch.device("cpu") # Default to CPU for safety, can upgrade to cuda
        return cls._instance

    def load_models(self):
        print("⏳ Loading models... This might take a moment.")
        
        # 1. Load Face Model (TorchScript)
        if os.path.exists(settings.FACE_MODEL_PATH):
            try:
                self.face_model = torch.jit.load(settings.FACE_MODEL_PATH, map_location=self.device)
                self.face_model.eval()
                print(f"✅ Face model loaded from {settings.FACE_MODEL_PATH}")
            except Exception as e:
                print(f"❌ Failed to load Face model: {e}")
        else:
            print(f"⚠️ Face model not found at {settings.FACE_MODEL_PATH}")

        # 2. Load Text Model (TorchScript) + Tokenizer
        # We need the tokenizer to convert text to IDs for the model
        try:
            self.tokenizer = AutoTokenizer.from_pretrained("roberta-base") # Matching user's notebook
            if os.path.exists(settings.TEXT_MODEL_PATH):
                self.text_model = torch.jit.load(settings.TEXT_MODEL_PATH, map_location=self.device)
                self.text_model.eval()
                print(f"✅ Text model loaded from {settings.TEXT_MODEL_PATH}")
            else:
                 print(f"⚠️ Text model not found at {settings.TEXT_MODEL_PATH}")
        except Exception as e:
            print(f"❌ Failed to load Text components: {e}")

        # 3. Load Voice Model (TorchScript) + Processor
        try:
            self.processor = Wav2Vec2Processor.from_pretrained("facebook/wav2vec2-base") # Matching user's notebook
            if os.path.exists(settings.VOICE_MODEL_PATH):
                self.voice_model = torch.jit.load(settings.VOICE_MODEL_PATH, map_location=self.device)
                self.voice_model.eval()
                print(f"✅ Voice model loaded from {settings.VOICE_MODEL_PATH}")
            else:
                print(f"⚠️ Voice model not found at {settings.VOICE_MODEL_PATH}")
        except Exception as e:
            print(f"❌ Failed to load Voice components: {e}")
            
        print("🚀 Model loading complete.")

model_loader = ModelLoader()
