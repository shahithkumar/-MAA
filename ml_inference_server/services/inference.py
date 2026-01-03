
import torch
import numpy as np
import io
from typing import List, Dict
from PIL import Image
import librosa
import soundfile as sf
from core.config import settings
from services.model_loader import model_loader

class InferenceService:
    
    def __init__(self):
        # Ensure models are loaded
        if not model_loader.face_model:
            model_loader.load_models()

    def _normalize_prediction(self, probs: List[float], labels: List[str], mapping: Dict[str, str]) -> Dict[str, float]:
        """
        Converts raw model probabilities into the Final Emotion Set.
        
        Args:
            probs: List of probabilities from softmax.
            labels: List of label names corresponding to probs indices.
            mapping: Dictionary mapping specific labels to Final Emotions.
            
        Returns:
            Dict[str, float]: Normalized dictionary { 'happy': 0.8, 'sad': 0.1, ... }
        """
        # Initialize final scores
        final_scores = {e: 0.0 for e in settings.FINAL_EMOTIONS}
        
        print(f"DEBUG: Raw Probs: {probs}")
        print(f"DEBUG: Labels: {labels}")

        for prob, label in zip(probs, labels):
            target_emotion = mapping.get(label)
            if target_emotion:
                # Add probability to the target bucket
                # (e.g. Joy(0.4) + Surprise(0.2) -> Happy(0.6))
                final_scores[target_emotion] += prob
        
        print(f"DEBUG: Normalized Scores: {final_scores}")
        return final_scores

    def predict_face(self, image_bytes: bytes):
        if not model_loader.face_model:
            return {"error": "Face model not loaded"}

        try:
            # Preprocess: Grayscale, Resize 48x48, Normalize
            image = Image.open(io.BytesIO(image_bytes)).convert('L')
            image = image.resize((48, 48))
            img_array = np.array(image, dtype=np.float32)
            img_array = img_array / 255.0
            
            # To Tensor: (1, 1, 48, 48)
            tensor_input = torch.tensor(img_array).unsqueeze(0).unsqueeze(0)
            
            with torch.no_grad():
                output = model_loader.face_model(tensor_input)
                probs = torch.softmax(output, dim=1).squeeze().tolist()
            
            # Normalize
            normalized = self._normalize_prediction(
                probs, 
                settings.FACE_LABELS, 
                settings.FACE_MAPPING
            )
            
            # Find dominant
            dominant = max(normalized, key=normalized.get)
            
            return {
                "modality": "face",
                "raw_probs": dict(zip(settings.FACE_LABELS, probs)),
                "normalized_probs": normalized,
                "dominant_emotion": dominant,
                "confidence": normalized[dominant]
            }
            
        except Exception as e:
            return {"error": str(e)}

    def predict_text(self, text: str):
        if not model_loader.text_model or not model_loader.tokenizer:
            return {"error": "Text model not loaded"}
            
        try:
            # Preprocess
            inputs = model_loader.tokenizer(
                text, 
                return_tensors="pt", 
                truncation=True, 
                padding="max_length", 
                max_length=128
            )
            
            ids = inputs["input_ids"]
            mask = inputs["attention_mask"]
            
            with torch.no_grad():
                # Trace model expects (ids, mask)
                output = model_loader.text_model(ids, mask)
                probs = torch.softmax(output, dim=1).squeeze().tolist()

            # Normalize
            normalized = self._normalize_prediction(
                probs, 
                settings.TEXT_LABELS, 
                settings.TEXT_MAPPING
            )
            
            dominant = max(normalized, key=normalized.get)
            
            return {
                "modality": "text",
                "raw_probs": dict(zip(settings.TEXT_LABELS, probs)),
                "normalized_probs": normalized,
                "dominant_emotion": dominant,
                "confidence": normalized[dominant]
            }

        except Exception as e:
            return {"error": str(e)}

    def predict_audio(self, audio_bytes: bytes):
        if not model_loader.voice_model or not model_loader.processor:
            return {"error": "Voice model not loaded"}
            
        try:
            # Preprocess: Load audio from bytes
            audio_data, samplerate = sf.read(io.BytesIO(audio_bytes))
            print(f"DEBUG: Audio Loaded. Shape: {audio_data.shape}, SR: {samplerate}")
            
            if len(audio_data) == 0:
                print("DEBUG: ⚠️ Audio data is empty!")
                return {"error": "Empty audio data"}

            # Ensure it's 1D (Mono)
            if len(audio_data.shape) > 1:
                audio_data = audio_data.mean(axis=1) # Average channels to mono
                print(f"DEBUG: Converted to Mono. New Shape: {audio_data.shape}")

            # OPTIMIZATION: Trim BEFORE resampling
            # Limit to 5 seconds of audio at the CURRENT sample rate (Optimized from 10s)
            max_input_frames = samplerate * 5
            if len(audio_data) > max_input_frames:
                print(f"DEBUG: Input too long ({len(audio_data)} frames). Trimming to 10s ({max_input_frames} frames) BEFORE resampling.")
                audio_data = audio_data[:max_input_frames]

            # Resample if needed (Wav2Vec2 needs 16000)
            if samplerate != 16000:
                print(f"DEBUG: Resampling from {samplerate} to 16000...")
                audio_data = librosa.resample(audio_data, orig_sr=samplerate, target_sr=16000)
                print(f"DEBUG: Resampled. New Shape: {audio_data.shape}")

            # Ensure non-empty after resampling
            if len(audio_data) == 0:
                 return {"error": "Audio empty after resampling"}

            # Double check length (redundant but safe)
            max_len = 16000 * 5
            if len(audio_data) > max_len:
                audio_data = audio_data[:max_len]
                
            inputs = model_loader.processor(
                audio_data, 
                sampling_rate=16000, 
                return_tensors="pt", 
                padding=True
            )
            
            input_values = inputs.input_values
            
            with torch.no_grad():
                # Trace model expects (input_values) based on user's snippet
                output = model_loader.voice_model(input_values)
                probs = torch.softmax(output, dim=1).squeeze().tolist()
                
            # Normalize
            normalized = self._normalize_prediction(
                probs, 
                settings.VOICE_LABELS, 
                settings.VOICE_MAPPING
            )
            
            dominant = max(normalized, key=normalized.get)
            
            return {
                "modality": "voice",
                "raw_probs": dict(zip(settings.VOICE_LABELS, probs)),
                "normalized_probs": normalized,
                "dominant_emotion": dominant,
                "confidence": normalized[dominant]
            }

        except Exception as e:
            return {"error": str(e)}

inference_service = InferenceService()
