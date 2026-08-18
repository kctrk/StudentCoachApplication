/// ============================================================
/// AI Chat Module — Modüler, UI-bağımsız Flutter modülü
/// ============================================================
/// Bu dosya TEK başına tüm iş mantığını içerir:
///   - ChatMessage modeli
///   - ChatState (durum sınıfı)
///   - AiChatService (Dio ile API istekleri)
///   - AiChatNotifier (Riverpod StateNotifier)
///   - aiChatProvider (dışarıya açılan tek provider)
///
/// Kullanım: Herhangi bir Widget'ta sadece şunu yaz:
///   final state = ref.watch(aiChatProvider);
///   ref.read(aiChatProvider.notifier).sendMessage('...');
///   ref.read(aiChatProvider.notifier).pickImageFromGallery();
/// ============================================================

library ai_chat_module;

import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

// ─────────────────────────────────────────────────────────────
// BÖLÜM 1: MODELLER
// ─────────────────────────────────────────────────────────────

/// Mesajın kime ait olduğunu belirtir
enum MessageSender { user, ai }

/// Tek bir sohbet mesajını temsil eder
class ChatMessage {
  final String id;
  final String text;
  final MessageSender sender;
  final File? imageFile; // Kullanıcının eklediği görsel (varsa)
  final DateTime createdAt;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.sender,
    this.imageFile,
    required this.createdAt,
  });

  /// Yeni mesaj oluştururken kolaylık
  factory ChatMessage.user({required String text, File? imageFile}) {
    return ChatMessage(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      text: text,
      sender: MessageSender.user,
      imageFile: imageFile,
      createdAt: DateTime.now(),
    );
  }

  factory ChatMessage.ai({required String text}) {
    return ChatMessage(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      text: text,
      sender: MessageSender.ai,
      createdAt: DateTime.now(),
    );
  }

  /// Hata mesajı (AI tarafından)
  factory ChatMessage.error({required String errorText}) {
    return ChatMessage(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      text: '⚠️ $errorText',
      sender: MessageSender.ai,
      createdAt: DateTime.now(),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// BÖLÜM 2: DURUM (STATE)
// ─────────────────────────────────────────────────────────────

/// Modülün mevcut çalışma durumu
enum ChatStatus {
  idle,         // Bekleniyor
  loading,      // API isteği yapılıyor
  pickingImage, // Görsel seçiliyor
  success,      // Son işlem başarılı
  error,        // Son işlem hatalı
}

/// Değişmez (immutable) durum nesnesi
class AiChatState {
  final List<ChatMessage> messages;
  final ChatStatus status;
  final File? selectedImage;   // Henüz gönderilmemiş seçili görsel
  final String? errorMessage;  // Son hata mesajı (Türkçe)

  const AiChatState({
    this.messages = const [],
    this.status = ChatStatus.idle,
    this.selectedImage,
    this.errorMessage,
  });

  /// Kolaylık getter'ları
  bool get isLoading => status == ChatStatus.loading;
  bool get hasError => status == ChatStatus.error;
  bool get hasImage => selectedImage != null;

  /// copyWith: sadece değişen alanları günceller
  AiChatState copyWith({
    List<ChatMessage>? messages,
    ChatStatus? status,
    File? selectedImage,
    String? errorMessage,
    bool clearImage = false,
    bool clearError = false,
  }) {
    return AiChatState(
      messages: messages ?? this.messages,
      status: status ?? this.status,
      selectedImage: clearImage ? null : (selectedImage ?? this.selectedImage),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// BÖLÜM 3: API SERVİSİ
// ─────────────────────────────────────────────────────────────

/// API yapılandırması — buradan endpoint ve key'i değiştirirsin
class ApiConfig {
  // ⚠️ API anahtarını environment variable veya flutter_dotenv'den oku
  // Şimdilik placeholder — gerçek key'i buraya yaz
  static const String apiKey = 'BURAYA_API_KEY_YAZ';

  // Google Gemini API (varsayılan)
  static const String baseUrl =
      'https://generativelanguage.googleapis.com/v1beta';
  static const String model = 'gemini-1.5-flash'; // veya 'gemini-pro'

  // Alternatif: OpenAI
  // static const String baseUrl = 'https://api.openai.com/v1';
  // static const String model = 'gpt-4o';

  // Timeout ayarları
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 30);
}

/// Tüm API ve görsel işlemlerini yöneten servis katmanı
class AiChatService {
  late final Dio _dio;
  final _imagePicker = ImagePicker();

  AiChatService() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: ApiConfig.connectTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
      headers: {'Content-Type': 'application/json'},
    ));

    // İstekleri/yanıtları debug modda logla
    _dio.interceptors.add(LogInterceptor(
      requestBody: false, // API key'i gizlemek için body'yi loglamıyoruz
      responseBody: true,
      error: true,
    ));
  }

  /// ── GÖRSEL SEÇİMİ ──────────────────────────────────────────

  /// Galeriden görsel seç
  Future<File?> pickFromGallery() async {
    try {
      final xfile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70, // Boyutu küçültmek için sıkıştır
        maxWidth: 1024,
        maxHeight: 1024,
      );
      return xfile != null ? File(xfile.path) : null;
    } catch (e) {
      throw _mapError(e, 'Galeriye erişilemedi');
    }
  }

  /// Kameradan fotoğraf çek
  Future<File?> pickFromCamera() async {
    try {
      final xfile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      return xfile != null ? File(xfile.path) : null;
    } catch (e) {
      throw _mapError(e, 'Kameraya erişilemedi');
    }
  }

  /// ── API İSTEKLERİ ─────────────────────────────────────────

  /// Sadece metin mesajı gönder (Gemini formatında)
  Future<String> sendTextMessage(
    String userText, {
    List<ChatMessage> history = const [],
  }) async {
    final payload = _buildTextPayload(userText, history);
    return await _callApi(payload);
  }

  /// Metin + görsel gönder (multimodal)
  Future<String> sendImageMessage(
    String userText,
    File imageFile,
  ) async {
    // Görseli Base64'e çevir
    final imageBytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(imageBytes);
    final mimeType = _getMimeType(imageFile.path);

    final payload = _buildMultimodalPayload(userText, base64Image, mimeType);
    return await _callApi(payload);
  }

  /// ── PAYLOAD OLUŞTURUCULAR (Gemini formatı) ─────────────────

  Map<String, dynamic> _buildTextPayload(
    String text,
    List<ChatMessage> history,
  ) {
    // Geçmiş mesajları Gemini formatına çevir
    final contents = <Map<String, dynamic>>[];

    for (final msg in history) {
      contents.add({
        'role': msg.sender == MessageSender.user ? 'user' : 'model',
        'parts': [
          {'text': msg.text}
        ],
      });
    }

    // Yeni kullanıcı mesajını ekle
    contents.add({
      'role': 'user',
      'parts': [
        {'text': text}
      ],
    });

    return {
      'contents': contents,
      'generationConfig': {
        'temperature': 0.9,
        'maxOutputTokens': 2048,
      },
    };
  }

  Map<String, dynamic> _buildMultimodalPayload(
    String text,
    String base64Image,
    String mimeType,
  ) {
    return {
      'contents': [
        {
          'parts': [
            {'text': text},
            {
              'inline_data': {
                'mime_type': mimeType,
                'data': base64Image,
              }
            }
          ]
        }
      ],
      'generationConfig': {
        'temperature': 0.9,
        'maxOutputTokens': 2048,
      },
    };
  }

  /// ── API ÇAĞRISI ────────────────────────────────────────────

  Future<String> _callApi(Map<String, dynamic> payload) async {
    try {
      final endpoint =
          '/models/${ApiConfig.model}:generateContent?key=${ApiConfig.apiKey}';

      final response = await _dio.post(endpoint, data: payload);

      if (response.statusCode == 200) {
        return _parseGeminiResponse(response.data);
      } else {
        throw _mapHttpError(response.statusCode);
      }
    } on DioException catch (e) {
      throw _mapDioError(e);
    } catch (e) {
      throw _mapError(e, 'Beklenmeyen bir hata oluştu');
    }
  }

  /// ── YANIT AYRIŞTIRICI ─────────────────────────────────────

  String _parseGeminiResponse(dynamic data) {
    try {
      final candidates = data['candidates'] as List;
      if (candidates.isEmpty) {
        return 'Yapay zekadan yanıt alınamadı.';
      }
      final content = candidates[0]['content'];
      final parts = content['parts'] as List;
      return parts.map((p) => p['text'] as String).join('\n').trim();
    } catch (_) {
      return 'Yanıt işlenirken hata oluştu.';
    }
  }

  /// ── HATA YÖNETİMİ ─────────────────────────────────────────

  String _mapDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Sunucu zaman aşımına uğradı. Lütfen tekrar deneyin.';
      case DioExceptionType.connectionError:
        return 'İnternet bağlantısı yok. Bağlantını kontrol et.';
      case DioExceptionType.badResponse:
        return _mapHttpError(e.response?.statusCode);
      case DioExceptionType.cancel:
        return 'İstek iptal edildi.';
      default:
        return 'Ağ hatası: ${e.message ?? 'Bilinmeyen hata'}';
    }
  }

  String _mapHttpError(int? statusCode) {
    switch (statusCode) {
      case 400:
        return 'Geçersiz istek gönderildi (400).';
      case 401:
        return 'API anahtarı geçersiz veya eksik (401).';
      case 403:
        return 'Bu işlem için yetkiniz yok (403).';
      case 429:
        return 'Çok fazla istek gönderildi. Biraz bekleyin (429).';
      case 500:
      case 502:
      case 503:
        return 'Sunucu hatası. Lütfen daha sonra tekrar deneyin.';
      default:
        return 'HTTP hatası: $statusCode';
    }
  }

  String _mapError(Object e, String fallback) {
    if (e is String) return e;
    return fallback;
  }

  /// Dosya uzantısına göre MIME türü döndür
  String _getMimeType(String path) {
    final ext = path.split('.').last.toLowerCase();
    const mimeMap = {
      'jpg': 'image/jpeg',
      'jpeg': 'image/jpeg',
      'png': 'image/png',
      'webp': 'image/webp',
      'gif': 'image/gif',
      'heic': 'image/heic',
    };
    return mimeMap[ext] ?? 'image/jpeg';
  }
}

// ─────────────────────────────────────────────────────────────
// BÖLÜM 4: STATE NOTIFIER (İŞ MANTIĞI)
// ─────────────────────────────────────────────────────────────

/// Tüm UI aksiyonlarını karşılayan notifier
class AiChatNotifier extends StateNotifier<AiChatState> {
  final AiChatService _service;

  AiChatNotifier(this._service) : super(const AiChatState());

  // ── PUBLIC API — UI bu metodları çağırır ───────────────────

  /// Metin mesajı gönder (görsel varsa multimodal olarak gönderir)
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    if (state.isLoading) return;

    final image = state.selectedImage;

    // 1. Kullanıcı mesajını hemen ekle (optimistic update)
    final userMsg = ChatMessage.user(text: text, imageFile: image);
    state = state.copyWith(
      messages: [...state.messages, userMsg],
      status: ChatStatus.loading,
      clearImage: true, // Görseli temizle
      clearError: true,
    );

    try {
      // 2. API çağrısı
      final String aiResponse;
      if (image != null) {
        aiResponse = await _service.sendImageMessage(text, image);
      } else {
        aiResponse = await _service.sendTextMessage(
          text,
          history: state.messages.length > 1
              ? state.messages.sublist(0, state.messages.length - 1)
              : [],
        );
      }

      // 3. AI yanıtını ekle
      final aiMsg = ChatMessage.ai(text: aiResponse);
      state = state.copyWith(
        messages: [...state.messages, aiMsg],
        status: ChatStatus.success,
      );
    } catch (errorMessage) {
      // 4. Hata mesajını sohbete ekle
      final errMsg = ChatMessage.error(errorText: errorMessage.toString());
      state = state.copyWith(
        messages: [...state.messages, errMsg],
        status: ChatStatus.error,
        errorMessage: errorMessage.toString(),
      );
    }
  }

  /// Galeriden görsel seç
  Future<void> pickImageFromGallery() async {
    state = state.copyWith(status: ChatStatus.pickingImage);
    try {
      final file = await _service.pickFromGallery();
      state = state.copyWith(
        selectedImage: file,
        status: ChatStatus.idle,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        status: ChatStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// Kameradan fotoğraf çek
  Future<void> pickImageFromCamera() async {
    state = state.copyWith(status: ChatStatus.pickingImage);
    try {
      final file = await _service.pickFromCamera();
      state = state.copyWith(
        selectedImage: file,
        status: ChatStatus.idle,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        status: ChatStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// Seçili görseli kaldır
  void removeSelectedImage() {
    state = state.copyWith(clearImage: true, clearError: true);
  }

  /// Tüm sohbeti temizle
  void clearChat() {
    state = const AiChatState();
  }
}

// ─────────────────────────────────────────────────────────────
// BÖLÜM 5: PROVIDERS — Dışarıya açılan tek nokta
// ─────────────────────────────────────────────────────────────

/// Servis provider'ı (Singleton — bir kez oluşturulur)
final aiChatServiceProvider = Provider<AiChatService>((ref) {
  return AiChatService();
});

/// Ana provider — UI bu provider'ı izler ve notifier'ı kullanır
///
/// Kullanım:
///   final state = ref.watch(aiChatProvider);
///   ref.read(aiChatProvider.notifier).sendMessage('...');
final aiChatProvider =
    StateNotifierProvider<AiChatNotifier, AiChatState>((ref) {
  final service = ref.read(aiChatServiceProvider);
  return AiChatNotifier(service);
});
