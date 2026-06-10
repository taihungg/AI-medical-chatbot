# DrAI (ai_care_bridge)

Flutter medical chatbot app with AI symptom consultation, appointment booking, and patient history.

## Setup

1. Install [Flutter](https://docs.flutter.dev/get-started/install) (SDK `>=3.0.0`).

2. Copy environment config and add your Gemini API key:

```bash
cp .env.example .env
```

Edit `.env` and set `GEMINI_API_KEY` from [Google AI Studio](https://aistudio.google.com/apikey).  
Do not commit `.env` — it is listed in `.gitignore`.

3. Install dependencies and run:

```bash
flutter pub get
flutter run
```

## Tests

```bash
flutter analyze
flutter test
```

Requires a local `.env` file (copy from `.env.example`) because tests load dotenv at startup.
