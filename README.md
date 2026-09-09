# Student Coach

Öğrenciler için geliştirilmiş Flutter tabanlı AI destekli çalışma asistanı.

## Özellikler

- **AI Sohbet**: Gemini API ile matematik, fizik, programlama ve daha fazlası
- **Tara & Çöz**: Kamera ile soru fotoğrafı çek → OCR → AI adım adım çözüm
- **Zamanlayıcı (Pomodoro)**: Çalışma süresi takibi ve otomatik DB kaydı
- **Geçmiş**: Tüm çözümlere ve sohbetlere kolayca eriş
- **Auth**: Kayıt / Giriş sistemi (Firebase'e geçiş için hazır)

## Kurulum

### 1. Bağımlılıkları Yükle
```bash
flutter pub get
```

### 2. API Anahtarı Ekle
`lib/core/services/ai_service.dart` dosyasında:
```dart
static const String apiKey = 'GEMINI_API_KEY_BURAYA';
```
Ücretsiz anahtar: https://aistudio.google.com/app/apikey

### 3. Çalıştır
```bash
flutter run
```

## Proje Yapısı

```
lib/
├── core/
│   ├── constants/     → Sistem promptları
│   ├── database/      → SQLite (DatabaseService)
│   └── services/      → AI, Auth, Notification
├── modules/
│   ├── auth/          → Login, Register, Splash
│   ├── history/       → Geçmiş çözümler
│   ├── scanner/       → OCR + AI çözüm
│   └── study/         → Dashboard, Timer, AI Chat
└── main.dart
```

## Teknolojiler

| Paket | Kullanım |
|---|---|
| `dio` | Gemini API HTTP istekleri |
| `sqflite` | Yerel SQLite veritabanı |
| `shared_preferences` | Auth oturumu |
| `google_mlkit_text_recognition` | OCR (offline) |
| `image_picker` | Kamera & galeri |
| `flutter_local_notifications` | Bildirimler |
| `flutter_riverpod` | State management |
