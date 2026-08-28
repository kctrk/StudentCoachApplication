import 'package:flutter/material.dart';

import 'lessons_screen.dart';
import 'timer_screen.dart';
import 'progress_screen.dart';
import 'daily_plan_screen.dart';
import 'settings_screen.dart';
import 'ai_chat_screen.dart';

class DashboardScreen extends StatelessWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;

  const DashboardScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = Theme.of(context).colorScheme.onSurface;
    final secondaryTextColor =
        Theme.of(context).colorScheme.onSurfaceVariant;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      // ------------------------------------------------------------
      // APP BAR
      // ------------------------------------------------------------
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: textColor,
        title: const Text(
          'Dijital Koç',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SettingsScreen(
                    isDarkMode: isDarkMode,
                    onThemeChanged: onThemeChanged,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Ayarlar',
          ),
        ],
      ),

      // ------------------------------------------------------------
      // BODY
      // ------------------------------------------------------------
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // ------------------------------------------------------
              // AI TAVSİYESİ
              // ------------------------------------------------------
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(18),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AiScreen(),
                      ),
                    );
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF2A2438)
                          : const Color(0xFFF7F3FD),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: const Color(0xFF6750A4)
                            .withValues(alpha: 0.18),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF3A3150)
                                : const Color(0xFFEDE7F6),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.auto_awesome_rounded,
                            color: Color(0xFF6750A4),
                            size: 22,
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              Text(
                                'AI Tavsiyesi',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                'Bugün matematikte fonksiyonlara odaklan. '
                                    '25 dakikalık kısa bir çalışma ile '
                                    'başlayabilirsin. 🎯',
                                style: TextStyle(
                                  fontSize: 13,
                                  height: 1.4,
                                  color: secondaryTextColor,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 4),

                        Icon(
                          Icons.chevron_right_rounded,
                          color: secondaryTextColor,
                          size: 22,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ------------------------------------------------------
              // KARŞILAMA
              // ------------------------------------------------------
              Text(
                'Merhaba 👋',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                'Bugünkü çalışma hedefini tamamlamaya ne dersin?',
                style: TextStyle(
                  fontSize: 15,
                  color: secondaryTextColor,
                ),
              ),

              const SizedBox(height: 24),

              // ------------------------------------------------------
              // GÜNLÜK HEDEF KARTI
              // ------------------------------------------------------
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF6750A4),
                      Color(0xFF8B6CCB),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6750A4)
                          .withValues(alpha: 0.20),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Bugünkü Hedef',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      '2 saat 30 dakika',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 18),

                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: const LinearProgressIndicator(
                        value: 0.58,
                        minHeight: 9,
                        backgroundColor: Color(0x55FFFFFF),
                        valueColor:
                        AlwaysStoppedAnimation<Color>(
                          Colors.white,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      '1 saat 27 dakika çalışıldı',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // ------------------------------------------------------
              // ÇALIŞMAYA BAŞLA
              // ------------------------------------------------------
              SizedBox(
                width: double.infinity,
                height: 58,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const TimerScreen(),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.play_arrow_rounded,
                  ),
                  label: const Text(
                    'Çalışmaya Başla',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark
                        ? const Color(0xFFE8E0F8)
                        : const Color(0xFF202124),
                    foregroundColor: isDark
                        ? const Color(0xFF202124)
                        : Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ------------------------------------------------------
              // GÜNLÜK PLAN
              // ------------------------------------------------------
              SizedBox(
                width: double.infinity,
                height: 54,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const DailyPlanScreen(),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.calendar_month_rounded,
                  ),
                  label: const Text(
                    'Günlük Planımı Gör',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF6750A4),
                    side: BorderSide(
                      color: isDark
                          ? const Color(0xFF6750A4)
                          : const Color(0xFFD8CCF2),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // ------------------------------------------------------
              // DERSLERİM
              // ------------------------------------------------------
              Text(
                'Derslerim',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),

              const SizedBox(height: 14),

              _SubjectCard(
                title: 'Matematik',
                topic: 'Fonksiyonlar',
                duration: '45 dk',
                color: isDark
                    ? const Color(0xFF3A3150)
                    : const Color(0xFFE8DEF8),
                icon: Icons.calculate_rounded,
              ),

              const SizedBox(height: 12),

              _SubjectCard(
                title: 'Fizik',
                topic: 'Kuvvet ve Hareket',
                duration: '25 dk',
                color: isDark
                    ? const Color(0xFF293744)
                    : const Color(0xFFDDEBF7),
                icon: Icons.science_rounded,
              ),

              const SizedBox(height: 12),

              _SubjectCard(
                title: 'Kimya',
                topic: 'Atom ve Periyodik Sistem',
                duration: '17 dk',
                color: isDark
                    ? const Color(0xFF34412D)
                    : const Color(0xFFE2F0D9),
                icon: Icons.biotech_rounded,
              ),

              const SizedBox(height: 30),

              // ------------------------------------------------------
              // SON ÇALIŞMALAR
              // ------------------------------------------------------
              Text(
                'Son Çalışmalar',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),

              const SizedBox(height: 14),

              _RecentStudyItem(
                subject: 'Matematik',
                topic: 'Fonksiyonlar',
                duration: '45 dakika',
                time: 'Bugün, 14:30',
                icon: Icons.calculate_rounded,
              ),

              _RecentStudyItem(
                subject: 'Fizik',
                topic: 'Kuvvet ve Hareket',
                duration: '25 dakika',
                time: 'Bugün, 11:15',
                icon: Icons.science_rounded,
              ),

              _RecentStudyItem(
                subject: 'Kimya',
                topic: 'Atom ve Periyodik Sistem',
                duration: '17 dakika',
                time: 'Dün, 19:20',
                icon: Icons.biotech_rounded,
              ),
            ],
          ),
        ),
      ),

      // ------------------------------------------------------------
      // AI KOÇ - SAĞ ALTTA YUVARLAK BUTON
      // ------------------------------------------------------------
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(
          bottom: 8,
          right: 4,
        ),
        child: FloatingActionButton(
          heroTag: 'aiCoachButton',
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AiScreen(),
              ),
            );
          },
          backgroundColor: const Color(0xFF6750A4),
          foregroundColor: Colors.white,
          elevation: 6,
          tooltip: 'AI Koç',
          child: const Icon(
            Icons.auto_awesome_rounded,
            size: 27,
          ),
        ),
      ),

      // ------------------------------------------------------------
      // BOTTOM NAVIGATION
      // ------------------------------------------------------------
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const LessonsScreen(),
              ),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const TimerScreen(),
              ),
            );
          } else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ProgressScreen(),
              ),
            );
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Ana Sayfa',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book_rounded),
            label: 'Dersler',
          ),
          NavigationDestination(
            icon: Icon(Icons.timer_outlined),
            selectedIcon: Icon(Icons.timer_rounded),
            label: 'Kronometre',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            selectedIcon: Icon(Icons.bar_chart_rounded),
            label: 'İlerleme',
          ),
        ],
      ),
    );
  }
}

// ==================================================================
// DERS KARTI
// ==================================================================

class _SubjectCard extends StatelessWidget {
  final String title;
  final String topic;
  final String duration;
  final Color color;
  final IconData icon;

  const _SubjectCard({
    required this.title,
    required this.topic,
    required this.duration,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark =
        Theme.of(context).brightness == Brightness.dark;

    final textColor =
        Theme.of(context).colorScheme.onSurface;

    final secondaryTextColor =
        Theme.of(context).colorScheme.onSurfaceVariant;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(
              icon,
              color: isDark
                  ? Colors.white70
                  : const Color(0xFF4A4458),
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  topic,
                  style: TextStyle(
                    fontSize: 13,
                    color: secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),

          Text(
            duration,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF6750A4),
            ),
          ),
        ],
      ),
    );
  }
}

// ==================================================================
// SON ÇALIŞMA
// ==================================================================

class _RecentStudyItem extends StatelessWidget {
  final String subject;
  final String topic;
  final String duration;
  final String time;
  final IconData icon;

  const _RecentStudyItem({
    required this.subject,
    required this.topic,
    required this.duration,
    required this.time,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final textColor =
        Theme.of(context).colorScheme.onSurface;

    final secondaryTextColor =
        Theme.of(context).colorScheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Theme.of(context).brightness ==
                  Brightness.dark
                  ? const Color(0xFF3A3150)
                  : const Color(0xFFEDE7F6),
              borderRadius: BorderRadius.circular(13),
            ),
            child: const Icon(
              Icons.history_rounded,
              color: Color(0xFF6750A4),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  '$subject • $topic',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    color: textColor,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  time,
                  style: TextStyle(
                    fontSize: 12,
                    color: secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),

          Text(
            duration,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}

