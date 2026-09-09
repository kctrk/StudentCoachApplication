import 'package:flutter/material.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: colors.onSurface,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'İstatistikler',
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
              Text(
                'Çalışma performansın',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: colors.onSurface,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                'Çalışma alışkanlıklarını ve ilerlemeni takip et.',
                style: TextStyle(
                  fontSize: 15,
                  color: colors.onSurface.withValues(alpha: 0.60),
                ),
              ),

              const SizedBox(height: 24),

              Row(
                children: [
                  Expanded(
                    child: _SummaryCard(
                      title: 'Bugün',
                      value: '1s 27dk',
                      icon: Icons.today_rounded,
                      color: const Color(0xFFEDE7F6),
                      iconColor: const Color(0xFF6750A4),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SummaryCard(
                      title: 'Bu hafta',
                      value: '8s 45dk',
                      icon: Icons.calendar_month_rounded,
                      color: const Color(0xFFE3F2FD),
                      iconColor: const Color(0xFF1976D2),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _SummaryCard(
                      title: 'Konular',
                      value: '12',
                      icon: Icons.check_circle_outline_rounded,
                      color: const Color(0xFFE8F5E9),
                      iconColor: const Color(0xFF388E3C),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SummaryCard(
                      title: 'Seri',
                      value: '5 gün',
                      icon: Icons.local_fire_department_rounded,
                      color: const Color(0xFFFFF3E0),
                      iconColor: const Color(0xFFE67E22),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              Text(
                'Haftalık çalışma',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colors.onSurface,
                ),
              ),

              const SizedBox(height: 14),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: colors.outline.withValues(alpha: 0.25),
                  ),
                ),
                child: Column(
                  children: const [
                    SizedBox(
                      height: 180,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _ChartBar(
                            day: 'Pzt',
                            height: 0.55,
                            value: '1s 20dk',
                          ),
                          _ChartBar(
                            day: 'Sal',
                            height: 0.75,
                            value: '2s 10dk',
                          ),
                          _ChartBar(
                            day: 'Çar',
                            height: 0.45,
                            value: '1s 05dk',
                          ),
                          _ChartBar(
                            day: 'Per',
                            height: 0.90,
                            value: '2s 35dk',
                          ),
                          _ChartBar(
                            day: 'Cum',
                            height: 0.65,
                            value: '1s 35dk',
                          ),
                          _ChartBar(
                            day: 'Cmt',
                            height: 0.35,
                            value: '50dk',
                          ),
                          _ChartBar(
                            day: 'Paz',
                            height: 0.58,
                            value: '1s 27dk',
                            isToday: true,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 12),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              Text(
                'Derslere göre çalışma',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colors.onSurface,
                ),
              ),

              const SizedBox(height: 14),

              const _SubjectProgress(
                subject: 'Matematik',
                duration: '3s 20dk',
                progress: 0.75,
                color: Color(0xFF6750A4),
                icon: Icons.calculate_rounded,
              ),

              const SizedBox(height: 12),

              const _SubjectProgress(
                subject: 'Fizik',
                duration: '2s 10dk',
                progress: 0.52,
                color: Color(0xFF1976D2),
                icon: Icons.science_rounded,
              ),

              const SizedBox(height: 12),

              const _SubjectProgress(
                subject: 'Kimya',
                duration: '1s 40dk',
                progress: 0.40,
                color: Color(0xFF388E3C),
                icon: Icons.biotech_rounded,
              ),

              const SizedBox(height: 12),

              const _SubjectProgress(
                subject: 'Türkçe',
                duration: '1s 15dk',
                progress: 0.30,
                color: Color(0xFFE67E22),
                icon: Icons.menu_book_rounded,
              ),

              const SizedBox(height: 30),

              Text(
                'Günlük hedef',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colors.onSurface,
                ),
              ),

              const SizedBox(height: 14),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF6750A4),
                      Color(0xFF8B6CCB),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.all(
                    Radius.circular(22),
                  ),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.flag_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Bugünkü hedef',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 16),

                    Text(
                      '1 saat 27 dakika / 2 saat 30 dakika',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),

                    SizedBox(height: 12),

                    ClipRRect(
                      borderRadius: BorderRadius.all(
                        Radius.circular(20),
                      ),
                      child: LinearProgressIndicator(
                        value: 0.58,
                        minHeight: 10,
                        backgroundColor: Color(0x55FFFFFF),
                        valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),

                    SizedBox(height: 12),

                    Text(
                      '%58 tamamlandı',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final Color iconColor;

  const _SummaryCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final iconBackground = isDark
        ? Color.lerp(color, Colors.black, 0.45)!
        : color;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colors.outline.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              icon,
              color: isDark
                  ? Colors.white.withValues(alpha: 0.90)
                  : iconColor,
              size: 22,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            title,
            style: TextStyle(
              color: colors.onSurface.withValues(alpha: 0.60),
              fontSize: 13,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            value,
            style: TextStyle(
              color: colors.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartBar extends StatelessWidget {
  final String day;
  final double height;
  final String value;
  final bool isToday;

  const _ChartBar({
    required this.day,
    required this.height,
    required this.value,
    this.isToday = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 9,
              color: colors.onSurface.withValues(alpha: 0.55),
            ),
          ),

          const SizedBox(height: 6),

          Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: FractionallySizedBox(
                heightFactor: height,
                child: Container(
                  width: 22,
                  decoration: BoxDecoration(
                    color: isToday
                        ? colors.primary
                        : isDark
                        ? colors.primary.withValues(alpha: 0.32)
                        : const Color(0xFFD9D0ED),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          Text(
            day,
            style: TextStyle(
              fontSize: 11,
              fontWeight:
              isToday ? FontWeight.bold : FontWeight.normal,
              color: isToday
                  ? colors.primary
                  : colors.onSurface.withValues(alpha: 0.55),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubjectProgress extends StatelessWidget {
  final String subject;
  final String duration;
  final double progress;
  final Color color;
  final IconData icon;

  const _SubjectProgress({
    required this.subject,
    required this.duration,
    required this.progress,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colors.outline.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isDark
                      ? color.withValues(alpha: 0.20)
                      : color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  icon,
                  color: isDark
                      ? Color.lerp(color, Colors.white, 0.25)
                      : color,
                  size: 22,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Text(
                  subject,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: colors.onSurface,
                  ),
                ),
              ),

              Text(
                duration,
                style: TextStyle(
                  color: isDark
                      ? Color.lerp(color, Colors.white, 0.25)
                      : color,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 7,
              backgroundColor: color.withValues(
                alpha: isDark ? 0.18 : 0.10,
              ),
              valueColor: AlwaysStoppedAnimation<Color>(
                isDark
                    ? Color.lerp(color, Colors.white, 0.15)!
                    : color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
