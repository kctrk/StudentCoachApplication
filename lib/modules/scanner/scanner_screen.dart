// lib/modules/scanner/scanner_screen.dart
//
// Uçtan uca soru çözümü:
//   1. Kamera / Galeri ile fotoğraf seç
//   2. ML Kit OCR ile metni çıkar (offline, cihazda)
//   3. Fotoğrafı + metni Gemini API'ye gönder
//   4. Çözümü ekranda göster
//   5. SQLite'a kaydet (geçmiş ekranında görünür)

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/database/database_service.dart';
import '../../core/services/ai_service.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  // ── State ──────────────────────────────────────────────────
  File? _image;
  String _ocrText = '';
  String _solution = '';
  String _selectedSubject = 'Matematik';
  bool _isOcr = false;
  bool _isAi = false;

  final _picker = ImagePicker();
  final _promptCtrl = TextEditingController();

  static const _subjects = [
    'Matematik',
    'Fizik',
    'Kimya',
    'Biyoloji',
    'Türkçe',
    'Tarih',
    'Coğrafya',
    'Programlama',
    'Genel',
  ];

  // ── Görsel Seçimi ──────────────────────────────────────────

  Future<void> _pickImage(ImageSource source) async {
    try {
      final xfile = await _picker.pickImage(
        source: source,
        imageQuality: 75,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      if (xfile == null) return;

      setState(() {
        _image = File(xfile.path);
        _ocrText = '';
        _solution = '';
      });

      await _runOcr(_image!);
    } catch (e) {
      _snack('Görsel seçilemedi: $e', isError: true);
    }
  }

  // ── OCR (Offline, ML Kit) ──────────────────────────────────

  Future<void> _runOcr(File file) async {
    setState(() => _isOcr = true);
    try {
      final input = InputImage.fromFile(file);
      final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
      final result = await recognizer.processImage(input);
      recognizer.close();

      setState(() => _ocrText = result.text.trim());

      if (_ocrText.isEmpty) {
        _snack('Görselde okunabilir metin bulunamadı.', isError: true);
      }
    } catch (e) {
      _snack('OCR hatası: $e', isError: true);
    } finally {
      setState(() => _isOcr = false);
    }
  }

  // ── AI Çözüm (Gemini API + DB Kayıt) ──────────────────────

  Future<void> _solveWithAi() async {
    if (_image == null) {
      _snack('Önce bir fotoğraf çek veya seç.', isError: true);
      return;
    }

    final extraPrompt = _promptCtrl.text.trim();
    final prompt = extraPrompt.isNotEmpty
        ? extraPrompt
        : 'Bu soruyu $_selectedSubject dersi kapsamında adım adım çöz:';

    setState(() {
      _solution = '';
      _isAi = true;
    });

    try {
      // 1. Görsel + metin → Gemini API
      final answer = await AiService.instance.sendImageWithText(
        imageFile: _image!,
        prompt: '${prompt}\n\nOCR ile çıkarılan metin:\n$_ocrText',
      );

      setState(() => _solution = answer);

      // 2. SQLite'a kaydet
      await DatabaseService.instance.saveSolvedQuestion(
        imagePath: _image!.path,
        ocrText: _ocrText,
        question: prompt,
        solution: answer,
        subject: _selectedSubject,
      );

      _snack('Çözüm kaydedildi ✓');
    } catch (e) {
      setState(() => _solution = '⚠️ $e');
      _snack(e.toString(), isError: true);
    } finally {
      setState(() => _isAi = false);
    }
  }

  // ── Yardımcılar ────────────────────────────────────────────

  void _snack(String msg, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: isError ? Colors.red : Colors.green,
    ));
  }

  @override
  void dispose() {
    _promptCtrl.dispose();
    super.dispose();
  }

  // ── BUILD ──────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final bool canSolve = _image != null && !_isOcr && !_isAi;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tara & Çöz'),
        actions: [
          if (_solution.isNotEmpty)
            IconButton(
              tooltip: 'Temizle',
              icon: const Icon(Icons.refresh_rounded),
              onPressed: () => setState(() {
                _image = null;
                _ocrText = '';
                _solution = '';
                _promptCtrl.clear();
              }),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Fotoğraf Butonları ────────────────────────────
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt_rounded),
                    label: const Text('Kamera'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.tonal(
                    onPressed: () => _pickImage(ImageSource.gallery),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.photo_library_rounded),
                        SizedBox(width: 8),
                        Text('Galeri'),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ── Seçilen Görsel ────────────────────────────────
            if (_image != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  _image!,
                  height: 220,
                  fit: BoxFit.cover,
                ),
              ),

            // ── OCR Yükleniyor ────────────────────────────────
            if (_isOcr) ...[
              const SizedBox(height: 16),
              const LinearProgressIndicator(),
              const SizedBox(height: 8),
              const Text(
                'Metni tanınıyor (OCR)...',
                textAlign: TextAlign.center,
              ),
            ],

            // ── OCR Sonucu ────────────────────────────────────
            if (_ocrText.isNotEmpty && !_isOcr) ...[
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Tanınan Metin (OCR)',
                icon: Icons.text_fields_rounded,
                child: Text(_ocrText, style: const TextStyle(height: 1.5)),
              ),
            ],

            // ── Ders Seçimi + Ek Prompt ───────────────────────
            if (_image != null && !_isOcr) ...[
              const SizedBox(height: 16),

              // Ders dropdown
              DropdownButtonFormField<String>(
                value: _selectedSubject,
                decoration: const InputDecoration(
                  labelText: 'Ders',
                  prefixIcon: Icon(Icons.book_rounded),
                ),
                items: _subjects
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) =>
                    setState(() => _selectedSubject = v ?? 'Matematik'),
              ),

              const SizedBox(height: 12),

              // Ek prompt
              TextField(
                controller: _promptCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Ek talimat (isteğe bağlı)',
                  hintText: 'Örn: Sadece sonucu ver, adım adım göster...',
                  prefixIcon: Icon(Icons.edit_note_rounded),
                ),
              ),

              const SizedBox(height: 16),

              // Çöz butonu
              FilledButton.icon(
                onPressed: canSolve ? _solveWithAi : null,
                icon: _isAi
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.auto_awesome_rounded),
                label: Text(_isAi ? 'Çözülüyor...' : 'AI ile Çöz'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],

            // ── AI Çözümü ─────────────────────────────────────
            if (_solution.isNotEmpty) ...[
              const SizedBox(height: 20),
              _SectionCard(
                title: 'AI Çözümü',
                icon: Icons.auto_awesome_rounded,
                iconColor: colors.primary,
                child: SelectableText(
                  _solution,
                  style: const TextStyle(height: 1.6),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Yardımcı Widget ────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color? iconColor;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    this.iconColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 18, color: iconColor ?? colors.onSurfaceVariant),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: colors.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
