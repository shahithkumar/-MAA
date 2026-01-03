# Mental Health Support App - AI-Powered Backend

This repository contains the backend and ML inference service for the Mental Health Support Application. The system leverages AI to provide mood tracking, sentiment analysis, and empathetic chatbot interactions.

## 🚀 Features

- **AI Mood Tracker**: Analyzes user input to track emotional well-being over time.
- **Supportive Chatbot**: An empathetic AI companion powered by Groq (LLaMA 3.1).
- **Sentiment Analysis**: Multi-modal sentiment analysis (Text & Voice) using state-of-the-art models (Emo-RoBERTa, Wav2Vec2).
- **SOS Support**: Quick-response mechanism for crisis situations.
- **User Authentication**: Secure JWT-based authentication for user data protection.

## 🛠️ Tech Stack

- **Backend**: Django & Django REST Framework
- **ML Inference**: FastAPI (Uvicorn)
- **Database**: PostgreSQL
- **LLM**: Groq Cloud API (Llama-3.1-8B)
- **Frontend**: Flutter (located in `mental_health_app_frontend/`)

## 📋 Prerequisites

- Python 3.10+
- PostgreSQL
- Flutter SDK (for frontend)
- Groq API Key

## ⚙️ Setup Instructions

### Backend Setup

1. **Clone the repository**:
   ```bash
   git clone <your-repo-url>
   cd Mental_Health_App_Backend
   ```

2. **Create a virtual environment**:
   ```bash
   python -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   ```

3. **Install dependencies**:
   ```bash
   pip install -r requirements.txt
   ```

4. **Configure Environment Variables**:
   Create a `.env` file in the root directory and add:
   ```env
   DJANGO_SECRET_KEY=your_secret_key
   DEBUG=True
   DB_NAME=mental_health_db
   DB_USER=your_db_user
   DB_PASSWORD=your_db_password
   DB_HOST=localhost
   DB_PORT=5432
   GROQ_API_KEY=your_groq_api_key
   EMAIL_HOST_USER=your_email@gmail.com
   EMAIL_HOST_PASSWORD=your_app_password
   ```

5. **Run Migrations**:
   ```bash
   python manage.py migrate
   ```

6. **Start the server**:
   ```bash
   python manage.py runserver
   ```

### ML Inference Server Setup

The ML server runs independently on port 8001.

1. **Download Models**:
   Place the required `.pth` and `.keras` models in the `models/` directory.
   *(Note: Large model files are ignored by git. Contact the administrator for access.)*

2. **Start the ML server**:
   ```bash
   uvicorn ml_inference_server.main:app --host 0.0.0.0 --port 8001
   ```

## 📱 Frontend Setup

Navigate to the `mental_health_app_frontend` directory and follow the Flutter setup instructions.

```bash
cd mental_health_app_frontend
flutter pub get
flutter run
```

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.
