import os
# Suppress TensorFlow logs
os.environ['TF_ENABLE_ONEDNN_OPTS'] = '0'

import asyncio # Added for parallelism
from fastapi import FastAPI, UploadFile, File, Form, HTTPException
from contextlib import asynccontextmanager
from typing import Optional
import json

import time
from core.config import settings
from services.model_loader import model_loader
from services.inference import inference_service
from services.fusion import fusion_service

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Load models on startup
    model_loader.load_models()
    yield
    # Clean up if needed

app = FastAPI(title=settings.PROJECT_NAME, version=settings.VERSION, lifespan=lifespan)

@app.get("/")
def health_check():
    return {"status": "ok", "models_loaded": {
        "face": model_loader.face_model is not None,
        "voice": model_loader.voice_model is not None,
        "text": model_loader.text_model is not None
    }}

@app.post("/predict/face")
async def predict_face(file: UploadFile = File(...)):
    contents = await file.read()
    # Run synchronous inference in a thread to avoid blocking event loop
    result = await asyncio.to_thread(inference_service.predict_face, contents)
    if "error" in result:
        raise HTTPException(status_code=500, detail=result["error"])
    return result

@app.post("/predict/audio")
async def predict_audio(file: UploadFile = File(...)):
    contents = await file.read()
    result = await asyncio.to_thread(inference_service.predict_audio, contents)
    if "error" in result:
        raise HTTPException(status_code=500, detail=result["error"])
    return result

@app.post("/predict/text")
async def predict_text(text: str = Form(...)): 
    result = await asyncio.to_thread(inference_service.predict_text, text)
    if "error" in result:
        raise HTTPException(status_code=500, detail=result["error"])
    return result

@app.post("/predict/multimodal")
async def predict_multimodal(
    face_file: Optional[UploadFile] = File(None),
    audio_file: Optional[UploadFile] = File(None),
    text_input: Optional[str] = Form(None)
):
    print("--- 🚀 STARTING PARALLEL MULTIMODAL PREDICTION ---")
    start_total = time.time()

    # 1. READ INPUTS (I/O Bound - Fast)
    face_bytes = await face_file.read() if face_file else None
    audio_bytes = await audio_file.read() if audio_file else None
    
    # 2. DEFINE TASKS
    # We use a helper to return None if input is missing, cleanly handling the parallel list
    async def run_safe(func, arg):
        if arg is None: return None
        return await asyncio.to_thread(func, arg)

    # 3. EXECUTE IN PARALLEL (CPU Bound - Offloaded to Threads)
    # This is where the magic happens. All 3 run at once.
    t0 = time.time()
    
    face_task = run_safe(inference_service.predict_face, face_bytes)
    audio_task = run_safe(inference_service.predict_audio, audio_bytes)
    text_task = run_safe(inference_service.predict_text, text_input)
    
    results = await asyncio.gather(face_task, audio_task, text_task)
    face_res, voice_res, text_res = results
    
    print(f"--- ⚡ Parallel Inference Took: {time.time() - t0:.2f}s ---")

    # 4. LOG ERRORS (But don't crash)
    if face_res and "error" in face_res:
         print(f"Errors in face: {face_res}")
         face_res = None
    if voice_res and "error" in voice_res:
         print(f"Errors in voice: {voice_res}")
         voice_res = None
    if text_res and "error" in text_res:
         print(f"Errors in text: {text_res}")
         text_res = None

    print(f"--- 🕒 TOTAL REQUEST TIME: {time.time() - start_total:.2f}s ---")

    # 5. Extract normalized probs
    face_probs = face_res["normalized_probs"] if face_res else None
    voice_probs = voice_res["normalized_probs"] if voice_res else None
    text_probs = text_res["normalized_probs"] if text_res else None
    
    # 6. Fuse
    fusion_result = fusion_service.fuse_emotions(face_probs, voice_probs, text_probs)
    
    return {
        "fusion": fusion_result,
        "components": {
            "face": face_res,
            "voice": voice_res,
            "text": text_res
        }
    }
