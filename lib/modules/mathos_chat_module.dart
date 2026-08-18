/// ============================================================
/// mathos_chat_module.dart
/// ============================================================
/// Mathos AI — Matematik odaklı multimodal sohbet modülü.
/// Gemini 1.5 Flash API kullanır.
///
/// Bu dosya tek başına tüm iş mantığını içerir:
///   ┌─ BÖLÜM 1: Sabitler & Konfigürasyon
///   ├─ BÖLÜM 2: Modeller  (MathosMessage, MessageSender)
///   ├─ BÖLÜM 3: State     (MathosChatState, ChatStatus)
///   ├─ BÖLÜM 4: Servis    (MathosChatService — API + galeri + kamera)
///   ├─ BÖLÜM 5: Notifier  (MathosChatNotifier — iş mantığı)
///   └─ BÖLÜM 6: Provider  (mathosChatProvider — tek dış erişim noktası)
///
/// Dışarıya açılan tek provider: [mathosChatProvider]
///
/// Kullanım örneği (herhangi bir Widget içinde):
///   ```dart
///   final state  = ref.watch(mathosChatProvider);
///   final notify = ref.read(mathosChatProvider.notifier);
///
///   notify.sendMessage('integral al: x^2 + 3x');
///   notify.pickImageFromCamera();   // soru fotoğrafı çek
///   notify.pickImageFromGallery();  // galeriden seç
///   notify.removeSelectedImage();
///   notify.clearChat();
///   ```
/// ============================================================

library mathos_chat_module;

import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

// ─────────────────────────────────────────────────────────────
// BÖLÜM 1: KONFİGÜRASYON
// ─────────────────────────────────────────────────────────────

/// Tüm API ayarları bu sınıfta — değiştirilecek tek yer burası
class MathosApiConfig {
  /// ⚠️ Gerçek Gemini API anahtarın:
  /// https://aistudio.google.com/app/apikey adresinden al
  static const String apiKey = 'GEMINI_API_KEY_BURAYA';

  /// Gemini base URL
  static const String baseUrl =
      'https://generativelanguage.googleapis.com/v1beta';

  /// Kullanılacak model:
  ///   'gemini-1.5-flash'   → Hızlı, ücretsiz kota ile gelir
  ///   'gemini-1.5-pro'     → Daha güçlü, ücretli kota
  ///   'gemini-2.0-flash'   → En yeni hızlı model
  static const String model = 'gemini-1.5-flash';

  /// Sistem promptu — modeli matematik asistanı olarak ayarlar
  static const String systemPrompt = '''
Sen Mathos AI adlı güçlü bir yapay zeka asistanısın.
Görevin her türlü soruyu eksiksiz, adım adım ve anlaşılır Türkçe ile cevaplamaktır.

Yapabileceklerin:
- Matematik: Cebir, geometri, analiz, integral, türev, diferansiyel denklemler, istatistik, lineer cebir, sayılar teorisi — her seviyede, adım adım çözüm
- Fen Bilimleri: Fizik, kimya, biyoloji soruları
- Programlama: Kod yazma, hata ayıklama, algoritma açıklama (her dil)
- Genel Kültür & Tarih: Soru-cevap, açıklama
- Dil & Yazarlık: Yazı düzeltme, özet çıkarma, çeviri
- Fotoğraftan Soru Çözme: Görseldeki soru kağıdını okuyup çözme

Cevap verirken:
- Her zaman Türkçe kullan
- Karmaşık konuları basitten karmaşığa doğru açıkla
- Matematik ve formüller için düz metin formatı kullan (LaTeX yok)
- Adımları numaralandır: 1. adım, 2. adım...
- Sonucu en sonda, açıkça belirt
- Kullanıcı yanlış bir şey söylerse kibarca düzelt
''';

  /// İstek zaman aşımları
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 45);

  /// Görsel sıkıştırma ayarları
  static const int imageQuality = 75;
  static const int imageMaxDimension = 1024;

  /// Sohbet geçmişinde tutulacak maksimum mesaj sayısı
  /// (token limiti aşmamak için)
  static const int maxHistoryMessages = 10;
}

// ─────────────────────────────────────────────────────────────
// BÖLÜM 2: MODELLER
// ─────────────────────────────────────────────────────────────

/// Mesajın sahibi
enum MessageSender { user, ai }

/// Tek bir sohbet mesajını temsil eder
class MathosMessage {
  final String id;
  final String text;
  final MessageSender sender;

  /// Kullanıcının eklediği soru görseli (sadece user mesajlarında olabilir)
  final File? imageFile;

  final DateTime createdAt;

  const MathosMessage({
    required this.id,
    required this.text,
    required this.sender,
    this.imageFile,
    required this.createdAt,
  });

  // ── Factory constructors ────────────────────────────────────

  factory MathosMessage.user({required String text, File? imageFile}) {
    return MathosMessage(
      id: '${DateTime.now().microsecondsSinceEpoch}_u',
      text: text,
      sender: MessageSender.user,
      imageFile: imageFile,
      createdAt: DateTime.now(),
    );
  }

  factory MathosMessage.ai({required String text}) {
    return MathosMessage(
      id: '${DateTime.now().microsecondsSinceEpoch}_a',
      text: text,
      sender: MessageSender.ai,
      createdAt: DateTime.now(),
    );
  }

  factory MathosMessage.error({required String errorText}) {
    return MathosMessage(
      id: '${DateTime.now().microsecondsSinceEpoch}_e',
      text: '⚠️ $errorText',
      sender: MessageSender.ai,
      createdAt: DateTime.now(),
    );
  }

  /// Sadece metin içeriği (API geçmişi için kullanılır)
  String get textOnly => text.replaceAll('⚠️ ', '');

  /// Kullanıcıdan gelen hatalı olmayan mesaj mı?
  bool get isUserMessage => sender == MessageSender.user;

  /// Hata mesajı mı?
  bool get isError => text.startsWith('⚠️');
}

// ─────────────────────────────────────────────────────────────
// BÖLÜM 3: DURUM (STATE)
// ─────────────────────────────────────────────────────────────

enum ChatStatus {
  idle,         // Bekleniyor
  loading,      // API isteği
  pickingImage, // Fotoğraf çekme
  success,      // Başarılı
  error,        // Hata
}

enum AiMode {
  solver,
  motivation,
  studyPlan
}

/// Değişmez durum nesnesi — her update yeni bir kopya üretir
class MathosChatState {
  /// Sohbet geçmişi (kronolojik sıra)
  final List<MathosMessage> messages;

  /// Mevcut çalışma durumu
  final ChatStatus status;

  /// Henüz gönderilmemiş, önizlemede bekleyen görsel
  final File? selectedImage;

  /// Son hata mesajı (Türkçe, kullanıcıya gösterilecek)
  final String? errorMessage;

  /// Mevcut AI Modu
  final AiMode currentMode;

  const MathosChatState({
    this.messages = const [],
    this.status = ChatStatus.idle,
    this.selectedImage,
    this.errorMessage,
    this.currentMode = AiMode.solver,
  });

  // ── Kolaylık getter'ları ────────────────────────────────────

  bool get isLoading =>
      status == ChatStatus.loading || status == ChatStatus.pickingImage;

  bool get hasError => status == ChatStatus.error;

  bool get hasSelectedImage => selectedImage != null;

  int get messageCount => messages.length;

  /// Sadece AI mesajlarını döndürür
  List<MathosMessage> get aiMessages =>
      messages.where((m) => m.sender == MessageSender.ai).toList();

  /// Sohbet boş mu?
  bool get isEmpty => messages.isEmpty;

  // ── copyWith ───────────────────────────────────────────────

  MathosChatState copyWith({
    List<MathosMessage>? messages,
    ChatStatus? status,
    File? selectedImage,
    String? errorMessage,
    AiMode? currentMode,
    bool clearImage = false,
    bool clearError = false,
  }) {
    return MathosChatState(
      messages: messages ?? this.messages,
      status: status ?? this.status,
      selectedImage: clearImage ? null : (selectedImage ?? this.selectedImage),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      currentMode: currentMode ?? this.currentMode,
    );
  }
}

// ─────────────────────────────────────────────────────────────
// BÖLÜM 4: SERVİS
// ─────────────────────────────────────────────────────────────

/// API iletişimi, görsel işleme ve hata yönetimi
class MathosChatService {
  late final Dio _dio;
  final _imagePicker = ImagePicker();

  MathosChatService() {
    _dio = Dio(
      BaseOptions(
        baseUrl: MathosApiConfig.baseUrl,
        connectTimeout: MathosApiConfig.connectTimeout,
        receiveTimeout: MathosApiConfig.receiveTimeout,
        headers: {'Content-Type': 'application/json'},
      ),
    );

    // Geliştirme sırasında istekleri logla (production'da kaldır)
    assert(() {
      _dio.interceptors.add(
        LogInterceptor(requestBody: false, responseBody: true, error: true),
      );
      return true;
    }());
  }

  // ── Görsel Seçimi ──────────────────────────────────────────

  /// Galeriden görsel seç
  Future<File?> pickFromGallery() async {
    try {
      final xfile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: MathosApiConfig.imageQuality,
        maxWidth: MathosApiConfig.imageMaxDimension.toDouble(),
        maxHeight: MathosApiConfig.imageMaxDimension.toDouble(),
      );
      return xfile != null ? File(xfile.path) : null;
    } on Exception catch (e) {
      throw _friendlyError(e, 'Galeriye erişilemedi');
    }
  }

  /// Kamerayla fotoğraf çek
  Future<File?> pickFromCamera() async {
    try {
      final xfile = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: MathosApiConfig.imageQuality,
        maxWidth: MathosApiConfig.imageMaxDimension.toDouble(),
        maxHeight: MathosApiConfig.imageMaxDimension.toDouble(),
      );
      return xfile != null ? File(xfile.path) : null;
    } on Exception catch (e) {
      throw _friendlyError(e, 'Kameraya erişilemedi');
    }
  }

  // ── API İstekleri ──────────────────────────────────────────

  /// Sadece metin mesajı — geçmiş konuşmayla birlikte
  Future<String> sendText({
    required String userMessage,
    required List<MathosMessage> history,
    required AiMode mode,
  }) async {
    final payload = _buildTextPayload(userMessage, history, mode);
    return _callGemini(payload);
  }

  /// Metin + görsel (multimodal) — soru fotoğrafı çözümü için
  Future<String> sendImageWithText({
    required String userMessage,
    required File imageFile,
    required AiMode mode,
  }) async {
    final bytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(bytes);
    final mime = _mimeType(imageFile.path);
    final payload = _buildMultimodalPayload(userMessage, base64Image, mime, mode);
    return _callGemini(payload);
  }

  // ── Payload Oluşturucular ─────────────────────────────────

  String _getSystemPromptForMode(AiMode mode) {
    switch (mode) {
      case AiMode.motivation:
        return 'Sen öğrencilere destek olan sıcakkanlı bir Motivasyon Koçusun. Hedeflerine ulaşması için cesaret ver.';
      case AiMode.studyPlan:
        return 'Sen profesyonel bir Eğitim Danışmanısın. Kullanıcının hedefine göre uygulanabilir günlük/haftalık çalışma planı oluştur.';
      case AiMode.solver:
      default:
        return MathosApiConfig.systemPrompt;
    }
  }

  /// Saf metin payload (Gemini REST formatı)
  Map<String, dynamic> _buildTextPayload(
    String userMessage,
    List<MathosMessage> history,
    AiMode mode,
  ) {
    final contents = <Map<String, dynamic>>[];

    // Sistem promptunu ilk kullanıcı mesajının önüne ekle
    // Gemini REST'te system_instruction ayrı alan olarak gönderilir
    // Not: bazı modeller "system" role'ü desteklemez, bu yüzden
    //      ilk mesaj olarak "user" rolünde gönderiyoruz.

    // Geçmişi ekle (son N mesaj, token limitini aşmamak için)
    final recentHistory = history.length > MathosApiConfig.maxHistoryMessages
        ? history.sublist(history.length - MathosApiConfig.maxHistoryMessages)
        : history;

    for (final msg in recentHistory) {
      if (msg.isError) continue; // Hata mesajlarını geçmişe ekleme
      contents.add({
        'role': msg.sender == MessageSender.user ? 'user' : 'model',
        'parts': [
          {'text': msg.textOnly}
        ],
      });
    }

    // Yeni kullanıcı mesajını ekle
    contents.add({
      'role': 'user',
      'parts': [
        {'text': userMessage}
      ],
    });

    return {
      'system_instruction': {
        'parts': [
          {'text': MathosApiConfig.systemPrompt}
        ]
      },
      'contents': contents,
      'generationConfig': {
        'temperature': 0.7,      // Matematik için daha deterministik
        'maxOutputTokens': 2048,
        'topP': 0.8,
        'topK': 40,
      },
      'safetySettings': [
        {
          'category': 'HARM_CATEGORY_HARASSMENT',
          'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
        },
        {
          'category': 'HARM_CATEGORY_HATE_SPEECH',
          'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
        },
      ],
    };
  }

  /// Metin + görsel payload
  Map<String, dynamic> _buildMultimodalPayload(
    String userMessage,
    String base64Image,
    String mimeType,
    AiMode mode,
  ) {
    return {
      'system_instruction': {
        'parts': [
          {'text': _getSystemPromptForMode(mode)}
        ]
      },
      'contents': [
        {
          'role': 'user',
          'parts': [
            {'text': userMessage.isEmpty ? 'Bu soruyu çöz:' : userMessage},
            {
              'inline_data': {
                'mime_type': mimeType,
                'data': base64Image,
              }
            },
          ],
        }
      ],
      'generationConfig': {
        'temperature': 0.7,
        'maxOutputTokens': 2048,
      },
    };
  }

  // ── HTTP Çağrısı ───────────────────────────────────────────

  Future<String> _callGemini(Map<String, dynamic> payload) async {
    try {
      final path =
          '/models/${MathosApiConfig.model}:generateContent'
          '?key=${MathosApiConfig.apiKey}';

      final response = await _dio.post(path, data: payload);

      if (response.statusCode == 200) {
        return _parseResponse(response.data);
      }
      throw _httpError(response.statusCode);
    } on DioException catch (e) {
      throw _dioError(e);
    } on FormatException {
      throw 'API yanıtı işlenirken hata oluştu.';
    } catch (e) {
      if (e is String) rethrow;
      throw 'Beklenmeyen hata: $e';
    }
  }

  // ── Yanıt Ayrıştırıcı ─────────────────────────────────────

  String _parseResponse(dynamic data) {
    try {
      final candidates = data['candidates'] as List?;
      if (candidates == null || candidates.isEmpty) {
        // Güvenlik filtresi durumu
        final blockReason =
            data['promptFeedback']?['blockReason'] ?? 'bilinmiyor';
        return '🚫 Yanıt güvenlik filtresi tarafından engellendi. '
            'Sebep: $blockReason';
      }

      final content = candidates.first['content'];
      final parts = content['parts'] as List;
      final text = parts
          .map((p) => (p['text'] as String? ?? '').trim())
          .where((t) => t.isNotEmpty)
          .join('\n\n');

      return text.isEmpty ? 'Yanıt alındı fakat içerik boş.' : text;
    } catch (_) {
      return 'Yanıt formatı beklenenden farklı.';
    }
  }

  // ── Hata Yönetimi ─────────────────────────────────────────

  String _dioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
        return 'Sunucuya bağlanılamadı. İnternetini kontrol et.';
      case DioExceptionType.receiveTimeout:
        return 'Sunucu yanıt vermedi (zaman aşımı). Tekrar dene.';
      case DioExceptionType.connectionError:
        return 'İnternet bağlantısı yok.';
      case DioExceptionType.badResponse:
        return _httpError(e.response?.statusCode);
      case DioExceptionType.cancel:
        return 'İstek iptal edildi.';
      default:
        return 'Ağ hatası: ${e.message ?? 'Bilinmiyor'}';
    }
  }

  String _httpError(int? code) {
    switch (code) {
      case 400:
        return 'Geçersiz istek (400). Soruyu farklı yaz.';
      case 401:
        return 'API anahtarı geçersiz (401). Ayarları kontrol et.';
      case 403:
        return 'Erişim reddedildi (403). API kotanı kontrol et.';
      case 429:
        return 'Çok fazla istek (429). Biraz bekleyip tekrar dene.';
      case 500:
        return 'Sunucu hatası (500). Daha sonra tekrar dene.';
      case 503:
        return 'Servis geçici olarak kullanılamıyor (503).';
      default:
        return 'HTTP hatası: $code';
    }
  }

  String _friendlyError(Object e, String fallback) {
    if (e is String) return e;
    final msg = e.toString().toLowerCase();
    if (msg.contains('permission') || msg.contains('denied')) {
      return '$fallback — izin verilmedi.';
    }
    return fallback;
  }

  String _mimeType(String path) {
    final ext = path.split('.').last.toLowerCase();
    return const {
      'jpg': 'image/jpeg',
      'jpeg': 'image/jpeg',
      'png': 'image/png',
      'webp': 'image/webp',
      'gif': 'image/gif',
      'heic': 'image/heic',
      'heif': 'image/heif',
    }[ext] ??
        'image/jpeg';
  }
}

// ─────────────────────────────────────────────────────────────
// BÖLÜM 5: NOTIFIER (İŞ MANTIĞI)
// ─────────────────────────────────────────────────────────────

import '../core/database/local_storage_service.dart';

/// UI aksiyonlarını karşılayan, state'i güncelleyen sınıf
class MathosChatNotifier extends StateNotifier<MathosChatState> {
  final MathosChatService _service;
  final LocalStorageService _storage = LocalStorageService();

  MathosChatNotifier(this._service) : super(const MathosChatState()) {
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    final history = await _storage.loadMessages();
    if (history.isNotEmpty) {
      state = state.copyWith(messages: history);
    }
  }

  Future<void> setMode(AiMode mode) async {
    state = state.copyWith(currentMode: mode);
  }

  // ── Mesaj Gönderme ─────────────────────────────────────────

  /// Metin mesajı gönder.
  /// Eğer seçili görsel varsa otomatik olarak multimodal istek yapar.
  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;
    if (state.isLoading) return;

    final image = state.selectedImage;

    // 1. Kullanıcı mesajını anında ekle (optimistic update)
    final userMsg = MathosMessage.user(text: trimmed, imageFile: image);
    state = state.copyWith(
      messages: [...state.messages, userMsg],
      status: ChatStatus.loading,
      clearImage: true,  // Önizleme görselini temizle
      clearError: true,
    );

    try {
      // 2. API çağrısını yap
      final String aiText;
      if (image != null) {
        // Görsel + metin → multimodal istek
        aiText = await _service.sendImageWithText(
          userMessage: trimmed,
          imageFile: image,
          mode: state.currentMode,
        );
      } else {
        // Sadece metin → geçmiş ile birlikte gönder
        final history = state.messages.length > 1
            ? state.messages.sublist(0, state.messages.length - 1)
            : const <MathosMessage>[];

        aiText = await _service.sendText(
          userMessage: trimmed,
          history: history,
          mode: state.currentMode,
        );
      }

      // 3. AI yanıtını ekle
      final newMessages = [...state.messages, MathosMessage.ai(text: aiText)];
      state = state.copyWith(
        messages: newMessages,
        status: ChatStatus.success,
      );
      
      // 4. Geçmişi kaydet
      await _storage.saveMessages(newMessages);
    } catch (errorMsg) {
      // 4. Hata mesajını sohbet akışına ekle + state'i güncelle
      state = state.copyWith(
        messages: [
          ...state.messages,
          MathosMessage.error(errorText: errorMsg.toString()),
        ],
        status: ChatStatus.error,
        errorMessage: errorMsg.toString(),
      );
    }
  }

  // ── Görsel İşlemleri ────────────────────────────────────────

  /// Galeriden soru görseli seç
  Future<void> pickImageFromGallery() async {
    if (state.isLoading) return;
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

  /// Kamerayla soru fotoğrafı çek
  Future<void> pickImageFromCamera() async {
    if (state.isLoading) return;
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

  /// Seçili önizleme görselini kaldır
  void removeSelectedImage() {
    state = state.copyWith(clearImage: true, clearError: true);
  }

  // ── Sohbet Yönetimi ─────────────────────────────────────────

  /// Tüm sohbeti sıfırla
  Future<void> clearChat() async {
    state = state.copyWith(messages: const []);
    await _storage.clearHistory();
  }

  /// Son mesajı sil (geri al)
  void removeLastMessage() {
    if (state.messages.isEmpty) return;
    state = state.copyWith(
      messages: state.messages.sublist(0, state.messages.length - 1),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// BÖLÜM 6: PROVIDERS — Dışarıya açılan tek nokta
// ─────────────────────────────────────────────────────────────

/// Servis provider (Singleton)
final _mathosChatServiceProvider = Provider<MathosChatService>((ref) {
  return MathosChatService();
});

/// ★ Ana provider — UI bu provider'ı izler
///
/// State okuma:
///   ```dart
///   final state = ref.watch(mathosChatProvider);
///   ```
///
/// Aksiyon tetikleme:
///   ```dart
///   ref.read(mathosChatProvider.notifier).sendMessage('x^2 - 4 = 0 çöz');
///   ref.read(mathosChatProvider.notifier).pickImageFromCamera();
///   ref.read(mathosChatProvider.notifier).clearChat();
///   ```
final mathosChatProvider =
    StateNotifierProvider<MathosChatNotifier, MathosChatState>((ref) {
  final service = ref.read(_mathosChatServiceProvider);
  return MathosChatNotifier(service);
});
