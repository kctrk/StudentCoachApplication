import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

// ============================================================================
// 1. MODEL KATMANI
// ============================================================================

/// Mesajı gönderen tarafı temsil eder.
enum MessageSender { user, ai }

/// Tek bir sohbet mesajının veri modeli.
class ChatMessageModel {
  final String id;
  final String text;
  final MessageSender sender;
  final DateTime timestamp;
  final File? imageFile;
  final String? base64Image;

  ChatMessageModel({
    required this.id,
    required this.text,
    required this.sender,
    required this.timestamp,
    this.imageFile,
    this.base64Image,
  });

  bool get isUser => sender == MessageSender.user;

  Map<String, dynamic> toJson() => {
        'id': id,
        'text': text,
        'sender': sender.name,
        'timestamp': timestamp.toIso8601String(),
        'hasImage': imageFile != null,
      };
}

// ============================================================================
// 2. HATA VE AĞ SERVİS KATMANI (DIO & API)
// ============================================================================

/// Dio ve Ağ isteklerinden dönen hataları yakalayan özel sınıf.
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  factory ApiException.fromDioError(DioException dioException) {
    switch (dioException.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException("Bağlantı zaman aşımına uğradı. İnternet bağlantınızı kontrol edin.");
      case DioExceptionType.badResponse:
        final code = dioException.response?.statusCode;
        if (code == 401) {
          return ApiException("API Anahtarı geçersiz veya yetkisiz erişim (401).", statusCode: code);
        } else if (code == 403) {
          return ApiException("Erişim engellendi (403).", statusCode: code);
        } else if (code == 404) {
          return ApiException("İstenen API servisi bulunamadı (404).", statusCode: code);
        } else if (code == 429) {
          return ApiException("Çok fazla istek gönderildi. Lütfen bir süre bekleyin (429).", statusCode: code);
        } else if (code != null && code >= 500) {
          return ApiException("Yapay zeka sunucu hatası ($code).", statusCode: code);
        }
        return ApiException("Sunucudan hatalı yanıt döndü ($code).", statusCode: code);
      case DioExceptionType.cancel:
        return ApiException("İstek iptal edildi.");
      case DioExceptionType.connectionError:
        return ApiException("İnternet bağlantısı kurulamadı.");
      default:
        return ApiException("Beklenmeyen ağ hatası: ${dioException.message}");
    }
  }

  @override
  String toString() => message;
}

/// Dio altyapısı ile Yapay Zeka Multimodal API İsteklerini Yöneten Servis.
class AiChatService {
  final Dio _dio;

  AiChatService({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 30),
                receiveTimeout: const Duration(seconds: 60),
                headers: {'Content-Type': 'application/json'},
              ),
            );

  /// Metin ve isteğe bağlı Görsel (Base64) kabul eden multimodal API çağrısı.
  Future<String> generateMultimodalResponse({
    required String endpointUrl,
    required String apiKey,
    required String prompt,
    String? base64Image,
    String mimeType = 'image/jpeg',
  }) async {
    try {
      final List<Map<String, dynamic>> parts = [
        {'text': prompt}
      ];

      if (base64Image != null && base64Image.isNotEmpty) {
        parts.add({
          'inline_data': {
            'mime_type': mimeType,
            'data': base64Image,
          }
        });
      }

      final requestData = {
        'contents': [
          {'parts': parts}
        ]
      };

      final response = await _dio.post(
        '$endpointUrl?key=$apiKey',
        data: jsonEncode(requestData),
      );

      if (response.statusCode == 200 && response.data != null) {
        final candidates = response.data['candidates'] as List?;
        if (candidates != null && candidates.isNotEmpty) {
          final text = candidates[0]['content']['parts'][0]['text'];
          return text ?? "Yanıt boş döndü.";
        }
        return "Yapay zekadan yanıt alınamadı.";
      } else {
        throw ApiException("Hatalı yanıt kodu: ${response.statusCode}", statusCode: response.statusCode);
      }
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException("Beklenmeyen hata: $e");
    }
  }

  static String bytesToBase64(Uint8List bytes) => base64Encode(bytes);
}

// ============================================================================
// 3. STATE MANAGEMENT KATMANI (RIVERPOD NOTIFIER & STATE)
// ============================================================================

/// Sohbet ekranının durum çeşitleri.
enum ChatStatus { initial, loading, sendingImage, success, error }

/// Immutable (Değiştirilemez) State Sınıfı.
class ChatState {
  final List<ChatMessageModel> messages;
  final ChatStatus status;
  final String? errorMessage;
  final File? selectedImage;
  final String? selectedBase64Image;

  ChatState({
    required this.messages,
    this.status = ChatStatus.initial,
    this.errorMessage,
    this.selectedImage,
    this.selectedBase64Image,
  });

  bool get isLoading => status == ChatStatus.loading || status == ChatStatus.sendingImage;
  bool get hasSelectedImage => selectedImage != null;

  ChatState copyWith({
    List<ChatMessageModel>? messages,
    ChatStatus? status,
    String? errorMessage,
    File? selectedImage,
    String? selectedBase64Image,
    bool clearImage = false,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      status: status ?? this.status,
      errorMessage: errorMessage,
      selectedImage: clearImage ? null : (selectedImage ?? this.selectedImage),
      selectedBase64Image: clearImage ? null : (selectedBase64Image ?? this.selectedBase64Image),
    );
  }
}

// Global Providers
final aiServiceProvider = Provider<AiChatService>((ref) => AiChatService());
final chatProvider = NotifierProvider<ChatNotifier, ChatState>(ChatNotifier.new);

/// İş mantığı ve Görsel / API entegrasyonunu yöneten Riverpod Notifier.
class ChatNotifier extends Notifier<ChatState> {
  final ImagePicker _picker = ImagePicker();

  // Varsayılan API Konfigürasyonu
  String _endpointUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';
  String _apiKey = 'YOUR_GEMINI_API_KEY_HERE';

  @override
  ChatState build() {
    return ChatState(messages: []);
  }

  /// Endpoint ve API Key'i dinamik olarak güncelleme metodu
  void configureApi({required String endpointUrl, required String apiKey}) {
    _endpointUrl = endpointUrl;
    _apiKey = apiKey;
  }

  /// Galeriden veya Kameradan Görsel Seçme
  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        final File imageFile = File(pickedFile.path);
        final bytes = await imageFile.readAsBytes();
        final String base64String = base64Encode(bytes);

        state = state.copyWith(
          selectedImage: imageFile,
          selectedBase64Image: base64String,
          status: ChatStatus.initial,
        );
      }
    } catch (e) {
      state = state.copyWith(
        status: ChatStatus.error,
        errorMessage: "Görsel seçimi sırasında izin hatası veya işlem iptali gerçekleşti.",
      );
    }
  }

  /// Seçili Görseli İptal Etme
  void removeSelectedImage() {
    state = state.copyWith(clearImage: true);
  }

  /// Sohbet Geçmişini Temizleme
  void clearChat() {
    state = ChatState(messages: []);
  }

  /// Mesaj ve Görseli Yapay Zekaya Gönderme (Backend İşlemi)
  Future<void> sendMessage(String textPrompt) async {
    final promptText = textPrompt.trim();
    if (promptText.isEmpty && state.selectedImage == null) return;

    final userImage = state.selectedImage;
    final userBase64 = state.selectedBase64Image;

    // 1. Kullanıcı mesajını ekle
    final userMessage = ChatMessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: promptText,
      sender: MessageSender.user,
      timestamp: DateTime.now(),
      imageFile: userImage,
      base64Image: userBase64,
    );

    state = state.copyWith(
      messages: [...state.messages, userMessage],
      status: userImage != null ? ChatStatus.sendingImage : ChatStatus.loading,
      clearImage: true,
    );

    // 2. API Servis Çağrısı
    try {
      final aiService = ref.read(aiServiceProvider);
      final aiResponseText = await aiService.generateMultimodalResponse(
        endpointUrl: _endpointUrl,
        apiKey: _apiKey,
        prompt: promptText.isEmpty ? "Bu görseli analiz et ve detaylıca açıkla." : promptText,
        base64Image: userBase64,
      );

      // 3. AI Yanıtını ekle
      final aiMessage = ChatMessageModel(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        text: aiResponseText,
        sender: MessageSender.ai,
        timestamp: DateTime.now(),
      );

      state = state.copyWith(
        messages: [...state.messages, aiMessage],
        status: ChatStatus.success,
      );
    } on ApiException catch (e) {
      state = state.copyWith(
        status: ChatStatus.error,
        errorMessage: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        status: ChatStatus.error,
        errorMessage: "Beklenmeyen hata: $e",
      );
    }
  }
}
