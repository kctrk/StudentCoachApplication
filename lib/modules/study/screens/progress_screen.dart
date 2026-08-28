import 'package:flutter/material.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF202124),
        title: const Text(
          'İlerleme',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Çalışma İstatistiklerin',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF202124),
                ),
              ),

              const SizedBox(height: 6),

              Text(
                'Çalışma performansını buradan takip edebilirsin.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'Bugün',
                      value: '1s 27dk',
                      icon: Icons.today_rounded,
                      color: const Color(0xFFE8DEF8),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      title: 'Bu Hafta',
                      value: '6s 42dk',
                      icon: Icons.date_range_rounded,
                      color: const Color(0xFFDDEBF7),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _StatCard(
                      title: 'Toplam',
                      value: '24s 18dk',
                      icon: Icons.timer_rounded,
                      color: const Color(0xFFE2F0D9),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatCard(
                      title: 'Ders',
                      value: '5',
                      icon: Icons.menu_book_rounded,
                      color: const Color(0xFFF9E4D4),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              const Text(
                'Haftalık Çalışma',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF202124),
                ),
              ),

              const SizedBox(height: 14),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.grey.shade200,
                  ),
                ),
                child: Column(
                  children: [
                    _DayBar(
                      day: 'Pzt',
                      value: 0.65,
                      time: '1s 18dk',
                    ),
                    _DayBar(
                      day: 'Sal',
                      value: 0.80,
                      time: '1s 36dk',
                    ),
                    _DayBar(
                      day: 'Çar',
                      value: 0.45,
                      time: '54dk',
                    ),
                    _DayBar(
                      day: 'Per',
                      value: 0.90,
                      time: '1s 48dk',
                    ),
                    _DayBar(
                      day: 'Cum',
                      value: 0.72,
                      time: '1s 26dk',
                    ),
                    _DayBar(
                      day: 'Cmt',
                      value: 0.30,
                      time: '36dk',
                    ),
                    _DayBar(
                      day: 'Paz',
                      value: 0.20,
                      time: '24dk',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                'Derslere Göre',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF202124),
                ),
              ),

              const SizedBox(height: 14),

              _LessonProgress(
                lesson: 'Matematik',
                duration: '3s 25dk',
                progress: 0.85,
                color: const Color(0xFFE8DEF8),
                icon: Icons.calculate_rounded,
              ),

              _LessonProgress(
                lesson: 'Fizik',
                duration: '2s 10dk',
                progress: 0.60,
                color: const Color(0xFFDDEBF7),
                icon: Icons.science_rounded,
              ),

              _LessonProgress(
                lesson: 'Kimya',
                duration: '1s 35dk',
                progress: 0.45,
                color: const Color(0xFFE2F0D9),
                icon: Icons.biotech_rounded,
              ),

              _LessonProgress(
                lesson: 'Türkçe',
                duration: '52dk',
                progress: 0.30,
                color: const Color(0xFFF9E4D4),
                icon: Icons.menu_book_rounded,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF6750A4),
            ),
          ),

          const SizedBox(height: 12),

          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            value,
            style: const TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
              color: Color(0xFF202124),
            ),
          ),
        ],
      ),
    );
  }
}

class _DayBar extends StatelessWidget {
  final String day;
  final double value;
  final String time;

  const _DayBar({
    required this.day,
    required this.value,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          SizedBox(
            width: 38,
            child: Text(
              day,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: value,
                minHeight: 10,
                backgroundColor: const Color(0xFFEDEDF2),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFF6750A4),
                ),
              ),
            ),
          ),

          const SizedBox(width: 10),

          SizedBox(
            width: 55,
            child: Text(
              time,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LessonProgress extends StatelessWidget {
  final String lesson;
  final String duration;
  final double progress;
  final Color color;
  final IconData icon;

  const _LessonProgress({
    required this.lesson,
    required this.duration,
    required this.progress,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: const Color(0xFF4A4458),
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lesson,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 7),

                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 7,
                    backgroundColor: const Color(0xFFEDEDF2),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF6750A4),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          Text(
            duration,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Color(0xFF6750A4),
            ),
          ),
        ],
      ),
    );
  }
}
