// lib/core/database/database_service.dart
//
// SQLite ile kalıcı yerel veritabanı.
// Yönetilen tablolar:
//   - chat_sessions   : Sohbet oturumları
//   - chat_messages   : Sohbet mesajları
//   - solved_questions: Taranan & çözülen sorular
//   - study_sessions  : Zamanlayıcı çalışma kayıtları

import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';

// ──────────────────────────────────────────────────────────────
// VERİ MODELLERİ
// ──────────────────────────────────────────────────────────────

class ChatSession {
  final String id;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ChatSession({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ChatSession.create({required String title}) {
    final now = DateTime.now();
    return ChatSession(
      id: const Uuid().v4(),
      title: title,
      createdAt: now,
      updatedAt: now,
    );
  }

  factory ChatSession.fromMap(Map<String, dynamic> m) => ChatSession(
        id: m['id'] as String,
        title: m['title'] as String,
        createdAt: DateTime.parse(m['created_at'] as String),
        updatedAt: DateTime.parse(m['updated_at'] as String),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}

class ChatMessageRecord {
  final String id;
  final String sessionId;
  final String text;
  final bool isUser;
  final String? imagePath;
  final DateTime createdAt;

  const ChatMessageRecord({
    required this.id,
    required this.sessionId,
    required this.text,
    required this.isUser,
    this.imagePath,
    required this.createdAt,
  });

  factory ChatMessageRecord.create({
    required String sessionId,
    required String text,
    required bool isUser,
    String? imagePath,
  }) =>
      ChatMessageRecord(
        id: const Uuid().v4(),
        sessionId: sessionId,
        text: text,
        isUser: isUser,
        imagePath: imagePath,
        createdAt: DateTime.now(),
      );

  factory ChatMessageRecord.fromMap(Map<String, dynamic> m) =>
      ChatMessageRecord(
        id: m['id'] as String,
        sessionId: m['session_id'] as String,
        text: m['text'] as String,
        isUser: (m['is_user'] as int) == 1,
        imagePath: m['image_path'] as String?,
        createdAt: DateTime.parse(m['created_at'] as String),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'session_id': sessionId,
        'text': text,
        'is_user': isUser ? 1 : 0,
        'image_path': imagePath,
        'created_at': createdAt.toIso8601String(),
      };
}

class SolvedQuestion {
  final String id;
  final String? imagePath;   // Çekilen fotoğraf yolu
  final String ocrText;      // OCR ile çıkarılan ham metin
  final String question;     // Kullanıcının sorusu / soru metni
  final String solution;     // AI'ın verdiği çözüm
  final String subject;      // Ders: Matematik, Fizik, vb.
  final DateTime solvedAt;

  const SolvedQuestion({
    required this.id,
    this.imagePath,
    required this.ocrText,
    required this.question,
    required this.solution,
    required this.subject,
    required this.solvedAt,
  });

  factory SolvedQuestion.create({
    String? imagePath,
    required String ocrText,
    required String question,
    required String solution,
    String subject = 'Genel',
  }) =>
      SolvedQuestion(
        id: const Uuid().v4(),
        imagePath: imagePath,
        ocrText: ocrText,
        question: question,
        solution: solution,
        subject: subject,
        solvedAt: DateTime.now(),
      );

  factory SolvedQuestion.fromMap(Map<String, dynamic> m) => SolvedQuestion(
        id: m['id'] as String,
        imagePath: m['image_path'] as String?,
        ocrText: m['ocr_text'] as String,
        question: m['question'] as String,
        solution: m['solution'] as String,
        subject: m['subject'] as String,
        solvedAt: DateTime.parse(m['solved_at'] as String),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'image_path': imagePath,
        'ocr_text': ocrText,
        'question': question,
        'solution': solution,
        'subject': subject,
        'solved_at': solvedAt.toIso8601String(),
      };

  /// Önizleme için kısa çözüm metni
  String get shortSolution =>
      solution.length > 120 ? '${solution.substring(0, 120)}...' : solution;
}

class StudySession {
  final String id;
  final String subject;
  final int durationMinutes;
  final DateTime date;

  const StudySession({
    required this.id,
    required this.subject,
    required this.durationMinutes,
    required this.date,
  });

  factory StudySession.create({
    required String subject,
    required int durationMinutes,
  }) =>
      StudySession(
        id: const Uuid().v4(),
        subject: subject,
        durationMinutes: durationMinutes,
        date: DateTime.now(),
      );

  factory StudySession.fromMap(Map<String, dynamic> m) => StudySession(
        id: m['id'] as String,
        subject: m['subject'] as String,
        durationMinutes: m['duration_minutes'] as int,
        date: DateTime.parse(m['date'] as String),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'subject': subject,
        'duration_minutes': durationMinutes,
        'date': date.toIso8601String(),
      };
}

// ──────────────────────────────────────────────────────────────
// VERİTABANI SERVİSİ (Singleton)
// ──────────────────────────────────────────────────────────────

class DatabaseService {
  DatabaseService._();
  static final DatabaseService instance = DatabaseService._();

  Database? _db;

  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final Directory dir = await getApplicationDocumentsDirectory();
    final String path = join(dir.path, 'student_coach.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Sohbet oturumları
    await db.execute('''
      CREATE TABLE chat_sessions (
        id         TEXT PRIMARY KEY,
        title      TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // Sohbet mesajları
    await db.execute('''
      CREATE TABLE chat_messages (
        id         TEXT PRIMARY KEY,
        session_id TEXT NOT NULL,
        text       TEXT NOT NULL,
        is_user    INTEGER NOT NULL DEFAULT 0,
        image_path TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (session_id) REFERENCES chat_sessions(id)
          ON DELETE CASCADE
      )
    ''');

    // Taranan & çözülen sorular
    await db.execute('''
      CREATE TABLE solved_questions (
        id         TEXT PRIMARY KEY,
        image_path TEXT,
        ocr_text   TEXT NOT NULL,
        question   TEXT NOT NULL,
        solution   TEXT NOT NULL,
        subject    TEXT NOT NULL DEFAULT 'Genel',
        solved_at  TEXT NOT NULL
      )
    ''');

    // Zamanlayıcı çalışma kayıtları
    await db.execute('''
      CREATE TABLE study_sessions (
        id               TEXT PRIMARY KEY,
        subject          TEXT NOT NULL,
        duration_minutes INTEGER NOT NULL,
        date             TEXT NOT NULL
      )
    ''');
  }

  // ── SOHBET OTURUMU CRUD ────────────────────────────────────

  Future<ChatSession> createChatSession(String title) async {
    final db = await database;
    final session = ChatSession.create(title: title);
    await db.insert('chat_sessions', session.toMap());
    return session;
  }

  Future<List<ChatSession>> getAllChatSessions() async {
    final db = await database;
    final rows = await db.query(
      'chat_sessions',
      orderBy: 'updated_at DESC',
    );
    return rows.map(ChatSession.fromMap).toList();
  }

  Future<void> deleteChatSession(String sessionId) async {
    final db = await database;
    await db.delete(
      'chat_sessions',
      where: 'id = ?',
      whereArgs: [sessionId],
    );
  }

  // ── SOHBET MESAJI CRUD ─────────────────────────────────────

  Future<ChatMessageRecord> saveMessage({
    required String sessionId,
    required String text,
    required bool isUser,
    String? imagePath,
  }) async {
    final db = await database;
    final msg = ChatMessageRecord.create(
      sessionId: sessionId,
      text: text,
      isUser: isUser,
      imagePath: imagePath,
    );
    await db.insert('chat_messages', msg.toMap());

    // Oturumun updated_at alanını güncelle
    await db.update(
      'chat_sessions',
      {'updated_at': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [sessionId],
    );

    return msg;
  }

  Future<List<ChatMessageRecord>> getMessages(String sessionId) async {
    final db = await database;
    final rows = await db.query(
      'chat_messages',
      where: 'session_id = ?',
      whereArgs: [sessionId],
      orderBy: 'created_at ASC',
    );
    return rows.map(ChatMessageRecord.fromMap).toList();
  }

  // ── ÇÖZÜLEN SORU CRUD ──────────────────────────────────────

  Future<SolvedQuestion> saveSolvedQuestion({
    String? imagePath,
    required String ocrText,
    required String question,
    required String solution,
    String subject = 'Genel',
  }) async {
    final db = await database;
    final q = SolvedQuestion.create(
      imagePath: imagePath,
      ocrText: ocrText,
      question: question,
      solution: solution,
      subject: subject,
    );
    await db.insert('solved_questions', q.toMap());
    return q;
  }

  Future<List<SolvedQuestion>> getAllSolvedQuestions() async {
    final db = await database;
    final rows = await db.query(
      'solved_questions',
      orderBy: 'solved_at DESC',
    );
    return rows.map(SolvedQuestion.fromMap).toList();
  }

  Future<void> deleteSolvedQuestion(String id) async {
    final db = await database;
    await db.delete('solved_questions', where: 'id = ?', whereArgs: [id]);
  }

  // ── ÇALIŞMA OTURUMU CRUD ───────────────────────────────────

  Future<StudySession> saveStudySession({
    required String subject,
    required int durationMinutes,
  }) async {
    final db = await database;
    final s = StudySession.create(
      subject: subject,
      durationMinutes: durationMinutes,
    );
    await db.insert('study_sessions', s.toMap());
    return s;
  }

  Future<List<StudySession>> getAllStudySessions() async {
    final db = await database;
    final rows = await db.query('study_sessions', orderBy: 'date DESC');
    return rows.map(StudySession.fromMap).toList();
  }

  /// Son 7 günün toplam çalışma süresi (dakika)
  Future<int> getTotalStudyMinutesThisWeek() async {
    final db = await database;
    final since = DateTime.now().subtract(const Duration(days: 7));
    final rows = await db.query(
      'study_sessions',
      where: 'date >= ?',
      whereArgs: [since.toIso8601String()],
    );
    return rows.fold<int>(
      0,
      (sum, r) => sum + (r['duration_minutes'] as int),
    );
  }

  /// Toplam çözülen soru sayısı
  Future<int> getTotalSolvedCount() async {
    final db = await database;
    final result =
        await db.rawQuery('SELECT COUNT(*) as cnt FROM solved_questions');
    return (result.first['cnt'] as int?) ?? 0;
  }
}
