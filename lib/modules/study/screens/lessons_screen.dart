import 'package:flutter/material.dart';
import 'timer_screen.dart';

class LessonsScreen extends StatefulWidget {
  const LessonsScreen({super.key});

  @override
  State<LessonsScreen> createState() => _LessonsScreenState();
}

class _LessonsScreenState extends State<LessonsScreen> {
  final List<LessonData> availableLessons = [
    const LessonData(
      name: 'Matematik',
      topic: 'Fonksiyonlar',
      duration: '0 dk',
      color: Color(0xFFE8DDFB),
      icon: Icons.calculate_outlined,
    ),
    const LessonData(
      name: 'Fizik',
      topic: 'Kuvvet ve Hareket',
      duration: '0 dk',
      color: Color(0xFFDCECF9),
      icon: Icons.science_outlined,
    ),
    const LessonData(
      name: 'Kimya',
      topic: 'Atom ve Periyodik Sistem',
      duration: '0 dk',
      color: Color(0xFFE1F0D8),
      icon: Icons.biotech_outlined,
    ),
    const LessonData(
      name: 'Türkçe',
      topic: 'Paragraf',
      duration: '0 dk',
      color: Color(0xFFF9E4D4),
      icon: Icons.menu_book_outlined,
    ),
    const LessonData(
      name: 'Biyoloji',
      topic: 'Hücre',
      duration: '0 dk',
      color: Color(0xFFDDF1EC),
      icon: Icons.eco_outlined,
    ),
  ];

  final List<LessonData> lessons = [
    const LessonData(
      name: 'Matematik',
      topic: 'Fonksiyonlar',
      duration: '45 dk',
      color: Color(0xFFE8DDFB),
      icon: Icons.calculate_outlined,
    ),
    const LessonData(
      name: 'Fizik',
      topic: 'Kuvvet ve Hareket',
      duration: '25 dk',
      color: Color(0xFFDCECF9),
      icon: Icons.science_outlined,
    ),
    const LessonData(
      name: 'Kimya',
      topic: 'Atom ve Periyodik Sistem',
      duration: '17 dk',
      color: Color(0xFFE1F0D8),
      icon: Icons.biotech_outlined,
    ),
    const LessonData(
      name: 'Türkçe',
      topic: 'Paragraf',
      duration: '0 dk',
      color: Color(0xFFF9E4D4),
      icon: Icons.menu_book_outlined,
    ),
    const LessonData(
      name: 'Biyoloji',
      topic: 'Hücre',
      duration: '0 dk',
      color: Color(0xFFDDF1EC),
      icon: Icons.eco_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        foregroundColor: colors.onSurface,
        title: Text(
          'Dersler',
          style: TextStyle(
            color: colors.onSurface,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.notifications_none_rounded,
              color: colors.onSurface,
            ),
          ),
        ],
      ),

      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            Text(
              'Bugün çalışmak istediğin dersi seç.',
              style: TextStyle(
                color: colors.onSurface.withValues(alpha: 0.60),
                fontSize: 15,
              ),
            ),

            const SizedBox(height: 20),

            Container(
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: colors.outline.withValues(alpha: 0.25),
                ),
              ),
              child: TextField(
                style: TextStyle(
                  color: colors.onSurface,
                ),
                decoration: InputDecoration(
                  hintText: 'Ders veya konu ara...',
                  hintStyle: TextStyle(
                    color: colors.onSurface.withValues(alpha: 0.45),
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: colors.onSurface.withValues(alpha: 0.55),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 15,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 28),

            Text(
              'Derslerim',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: colors.onSurface,
              ),
            ),

            const SizedBox(height: 12),

            ...lessons.map(
                  (lesson) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _LessonCard(
                  lesson: lesson,
                  onTap: () {
                    _openLesson(context, lesson);
                  },
                ),
              ),
            ),

            const SizedBox(height: 8),

            OutlinedButton.icon(
              onPressed: _showAddLessonSheet,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Yeni Ders Ekle'),
              style: OutlinedButton.styleFrom(
                foregroundColor: colors.primary,
                side: BorderSide(
                  color: colors.primary.withValues(alpha: 0.30),
                ),
                backgroundColor: theme.brightness == Brightness.dark
                    ? colors.primary.withValues(alpha: 0.08)
                    : const Color(0xFFFAF8FF),
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddLessonSheet() {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final notAddedLessons = availableLessons.where((available) {
      return !lessons.any(
            (lesson) => lesson.name == available.name,
      );
    }).toList();

    if (notAddedLessons.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Eklenebilecek başka ders kalmadı.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: theme.scaffoldBackgroundColor,
      showDragHandle: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ders Seç',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: colors.onSurface,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  'Eklemek istediğin dersi seç.',
                  style: TextStyle(
                    fontSize: 14,
                    color: colors.onSurface.withValues(alpha: 0.60),
                  ),
                ),

                const SizedBox(height: 18),

                ...notAddedLessons.map(
                      (lesson) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Material(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          setState(() {
                            lessons.add(lesson);
                          });

                          Navigator.pop(sheetContext);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${lesson.name} derslere eklendi.',
                              ),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: colors.outline.withValues(
                                alpha: 0.25,
                              ),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: lesson.color,
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Icon(
                                  lesson.icon,
                                  color: const Color(0xFF51465F),
                                ),
                              ),

                              const SizedBox(width: 14),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      lesson.name,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: colors.onSurface,
                                      ),
                                    ),

                                    const SizedBox(height: 4),

                                    Text(
                                      lesson.topic,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: colors.onSurface.withValues(
                                          alpha: 0.60,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              Icon(
                                Icons.add_circle_outline_rounded,
                                color: colors.primary,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openLesson(
      BuildContext context,
      LessonData lesson,
      ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LessonDetailScreen(
          lesson: lesson,
        ),
      ),
    );
  }
}

class LessonData {
  final String name;
  final String topic;
  final String duration;
  final Color color;
  final IconData icon;

  const LessonData({
    required this.name,
    required this.topic,
    required this.duration,
    required this.color,
    required this.icon,
  });
}

class _LessonCard extends StatelessWidget {
  final LessonData lesson;
  final VoidCallback onTap;

  const _LessonCard({
    required this.lesson,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: colors.outline.withValues(alpha: 0.25),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: isDark
                      ? Color.lerp(
                    lesson.color,
                    Colors.black,
                    0.55,
                  )
                      : lesson.color,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  lesson.icon,
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.85)
                      : const Color(0xFF51465F),
                  size: 27,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lesson.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: colors.onSurface,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      lesson.topic,
                      style: TextStyle(
                        fontSize: 13,
                        color: colors.onSurface.withValues(alpha: 0.60),
                      ),
                    ),
                  ],
                ),
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    lesson.duration,
                    style: TextStyle(
                      color: colors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Icon(
                    Icons.chevron_right_rounded,
                    color: colors.onSurface.withValues(alpha: 0.45),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LessonDetailScreen extends StatelessWidget {
  final LessonData lesson;

  const LessonDetailScreen({
    super.key,
    required this.lesson,
  });

  int _durationToMinutes(String duration) {
    return int.tryParse(
      duration.replaceAll(' dk', ''),
    ) ??
        25;
  }

  void _startStudy(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TimerScreen(
          subject: lesson.name,
          topic: lesson.topic,
          durationMinutes: _durationToMinutes(lesson.duration),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        foregroundColor: colors.onSurface,
        title: Text(
          lesson.name,
          style: TextStyle(
            color: colors.onSurface,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF694DB7),
                  Color(0xFF8B6BCB),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.all(
                Radius.circular(22),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.menu_book_rounded,
                  color: Colors.white70,
                  size: 28,
                ),

                const SizedBox(height: 14),

                Text(
                  lesson.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  lesson.topic,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                  ),
                ),

                const SizedBox(height: 22),

                const Text(
                  'Bugünkü çalışma',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  lesson.duration,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          Text(
            'Konular',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: colors.onSurface,
            ),
          ),

          const SizedBox(height: 12),

          _TopicTile(
            title: lesson.topic,
            completed: true,
          ),

          const _TopicTile(
            title: 'Konu tekrarı',
            completed: false,
          ),

          const _TopicTile(
            title: 'Soru çözümü',
            completed: false,
          ),

          const SizedBox(height: 24),

          SizedBox(
            height: 54,
            child: ElevatedButton.icon(
              onPressed: () {
                _startStudy(context);
              },
              icon: const Icon(
                Icons.play_arrow_rounded,
              ),
              label: const Text(
                'Çalışmaya Başla',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.brightness == Brightness.dark
                    ? colors.primary
                    : const Color(0xFF202124),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                textStyle: const TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopicTile extends StatelessWidget {
  final String title;
  final bool completed;

  const _TopicTile({
    required this.title,
    required this.completed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.outline.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          Icon(
            completed
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked_rounded,
            color: completed
                ? colors.primary
                : colors.onSurface.withValues(alpha: 0.40),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: completed
                    ? colors.onSurface
                    : colors.onSurface.withValues(alpha: 0.65),
              ),
            ),
          ),

          Icon(
            Icons.chevron_right_rounded,
            color: colors.onSurface.withValues(alpha: 0.45),
          ),
        ],
      ),
    );
  }
}
