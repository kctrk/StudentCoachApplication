import 'package:flutter/material.dart';
import 'profile_screen.dart';


class SettingsScreen extends StatefulWidget {
  final bool isDarkMode;
  final ValueChanged<bool> onThemeChanged;

  const SettingsScreen({
    super.key,
    required this.isDarkMode,
    required this.onThemeChanged,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notificationsEnabled = true;
  bool soundEnabled = true;
  int defaultStudyMinutes = 25;

  bool get darkModeEnabled => widget.isDarkMode;

  void _changeTheme(bool value) {
    widget.onThemeChanged(value);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          value ? 'Koyu tema açıldı.' : 'Açık tema açıldı.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showNotificationSettings() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Bildirimler',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Bildirimleri Aç'),
                    subtitle: const Text(
                      'Çalışma ve hatırlatma bildirimleri',
                    ),
                    value: notificationsEnabled,
                    onChanged: (value) {
                      setSheetState(() {
                        notificationsEnabled = value;
                      });

                      setState(() {});

                      if (!value) {
                        ScaffoldMessenger.of(this.context).showSnackBar(
                          const SnackBar(
                            content: Text('Bildirimler kapatıldı.'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                  ),

                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Çalışma Tamamlandı Sesi'),
                    subtitle: const Text(
                      'Sayaç tamamlandığında ses çal',
                    ),
                    value: soundEnabled,
                    onChanged: notificationsEnabled
                        ? (value) {
                            setSheetState(() {
                              soundEnabled = value;
                            });

                            setState(() {});
                          }
                        : null,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showAppearanceSettings() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Görünüm',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Koyu Tema'),
                    subtitle: const Text(
                      'Uygulamanın koyu görünümünü kullan',
                    ),
                    value: widget.isDarkMode,
                    onChanged: (value) {
                      _changeTheme(value);

                      setSheetState(() {});
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showStudyDurationSettings() {
    final durations = [15, 25, 45, 60, 90];

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Varsayılan Çalışma Süresi',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Kronometre açıldığında kullanılacak süreyi seç.',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  ...durations.map(
                    (minutes) => RadioListTile<int>(
                      contentPadding: EdgeInsets.zero,
                      title: Text('$minutes dakika'),
                      value: minutes,
                      groupValue: defaultStudyMinutes,
                      onChanged: (value) {
                        if (value == null) return;

                        setSheetState(() {
                          defaultStudyMinutes = value;
                        });

                        setState(() {});

                        Navigator.pop(sheetContext);
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Çıkış Yap'),
          content: const Text(
            'Hesabından çıkış yapmak istediğine emin misin?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Çıkış işlemi hazır. '
                      'Giriş sistemi bağlandığında buradan çıkış yapılacak.',
                    ),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text('Çıkış Yap'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF121212)
          : const Color(0xFFF6F7FB),

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDark
            ? Colors.white
            : const Color(0xFF202124),
        title: const Text(
          'Ayarlar',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
          children: [
            _SectionTitle(title: 'Hesap'),

            const SizedBox(height: 12),

            _SettingsCard(
              icon: Icons.person_outline_rounded,
              title: 'Profil',
              subtitle: 'Profil bilgilerini görüntüle ve düzenle',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ProfileScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 12),

            _SettingsCard(
              icon: Icons.notifications_none_rounded,
              title: 'Bildirimler',
              subtitle: notificationsEnabled
                  ? 'Bildirimler açık'
                  : 'Bildirimler kapalı',
              onTap: _showNotificationSettings,
            ),

            const SizedBox(height: 28),

            _SectionTitle(title: 'Çalışma'),

            const SizedBox(height: 12),

            _SettingsCard(
              icon: Icons.timer_outlined,
              title: 'Varsayılan Çalışma Süresi',
              subtitle: '$defaultStudyMinutes dakika',
              onTap: _showStudyDurationSettings,
            ),

            const SizedBox(height: 28),

            _SectionTitle(title: 'Uygulama'),

            const SizedBox(height: 12),

            _SettingsCard(
              icon: Icons.palette_outlined,
              title: 'Görünüm',
              subtitle: darkModeEnabled
                  ? 'Koyu tema'
                  : 'Açık tema',
              onTap: _showAppearanceSettings,
            ),

            const SizedBox(height: 12),

            _SettingsCard(
              icon: Icons.info_outline_rounded,
              title: 'Hakkında',
              subtitle: 'Student Coach hakkında',
              onTap: () {
                showAboutDialog(
                  context: context,
                  applicationName: 'Student Coach',
                  applicationVersion: '1.0.0',
                  applicationIcon: const Icon(
                    Icons.school_rounded,
                    color: Color(0xFF6750A4),
                    size: 40,
                  ),
                  children: const [
                    Text(
                      'Derslerini, çalışma süreni ve ilerlemeni '
                      'takip etmene yardımcı olan öğrenci koç uygulaması.',
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 30),

            SizedBox(
              height: 52,
              child: OutlinedButton.icon(
                onPressed: _showLogoutDialog,
                icon: const Icon(Icons.logout_rounded),
                label: const Text(
                  'Çıkış Yap',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: BorderSide(
                    color: Colors.red.shade200,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : const Color(0xFF202124),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isDark
                  ? Colors.white12
                  : Colors.grey.shade200,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFEDE7F6),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF6750A4),
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? Colors.white
                            : const Color(0xFF202124),
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? Colors.white60
                            : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              Icon(
                Icons.chevron_right_rounded,
                color: isDark
                    ? Colors.white54
                    : const Color(0xFF888888),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
