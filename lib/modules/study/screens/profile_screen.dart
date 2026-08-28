import 'package:flutter/material.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String userName = 'Student Coach Kullanıcısı';
  String userNickname = 'studentcoach';

  bool notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: colors.onSurface,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Profil',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
          child: Column(
            children: [
              // PROFİL BAŞLIĞI
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
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
                    Radius.circular(24),
                  ),
                ),
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 42,
                      backgroundColor: Colors.white,
                      child: Icon(
                        Icons.person_rounded,
                        size: 48,
                        color: Color(0xFF6750A4),
                      ),
                    ),

                    const SizedBox(height: 14),

                    Text(
                      userName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 5),

                    Text(
                      '@$userNickname',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),

                    const SizedBox(height: 5),

                    const Text(
                      'Düzenli çalış, hedeflerine ulaş 🚀',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // İSTATİSTİKLER
              Row(
                children: [
                  const Expanded(
                    child: _ProfileStat(
                      value: '24s',
                      label: 'Toplam',
                      icon: Icons.timer_rounded,
                    ),
                  ),

                  const SizedBox(width: 12),

                  const Expanded(
                    child: _ProfileStat(
                      value: '5',
                      label: 'Ders',
                      icon: Icons.menu_book_rounded,
                    ),
                  ),

                  const SizedBox(width: 12),

                  const Expanded(
                    child: _ProfileStat(
                      value: '12',
                      label: 'Gün',
                      icon: Icons.local_fire_department_rounded,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Hesap',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colors.onSurface,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // PROFİL BİLGİLERİ
              _ProfileMenuItem(
                icon: Icons.person_outline_rounded,
                title: 'Profil Bilgileri',
                subtitle: 'Ad ve kullanıcı bilgilerini düzenle',
                onTap: _showProfileEditSheet,
              ),

              // BİLDİRİMLER
              _ProfileMenuItem(
                icon: Icons.notifications_none_rounded,
                title: 'Bildirimler',
                subtitle: notificationsEnabled
                    ? 'Bildirimler açık'
                    : 'Bildirimler kapalı',
                onTap: _showNotificationSettings,
              ),

              // AYARLAR
              _ProfileMenuItem(
                icon: Icons.settings_outlined,
                title: 'Ayarlar',
                subtitle: 'Uygulama tercihlerini yönet',
                onTap: _openSettings,
              ),

              const SizedBox(height: 20),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Diğer',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colors.onSurface,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              _ProfileMenuItem(
                icon: Icons.info_outline_rounded,
                title: 'Hakkında',
                subtitle: 'Student Coach hakkında',
                onTap: _showAbout,
              ),

              _ProfileMenuItem(
                icon: Icons.logout_rounded,
                title: 'Çıkış Yap',
                subtitle: 'Hesabından çıkış yap',
                danger: true,
                onTap: () {
                  _showLogoutDialog(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // PROFİL BİLGİLERİ
  // ------------------------------------------------------------

  void _showProfileEditSheet() {
    final nameController = TextEditingController(
      text: userName,
    );

    final nicknameController = TextEditingController(
      text: userNickname,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        final colors = theme.colorScheme;

        return Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            8,
            20,
            MediaQuery.of(sheetContext).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Profil Bilgileri',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: colors.onSurface,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  'Profil bilgilerini düzenleyebilirsin.',
                  style: TextStyle(
                    color: colors.onSurface.withValues(alpha: 0.60),
                  ),
                ),

                const SizedBox(height: 24),

                Center(
                  child: Stack(
                    children: [
                      const CircleAvatar(
                        radius: 42,
                        backgroundColor: Color(0xFFEDE7F6),
                        child: Icon(
                          Icons.person_rounded,
                          size: 46,
                          color: Color(0xFF6750A4),
                        ),
                      ),

                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: colors.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            color: Colors.white,
                            size: 17,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                TextField(
                  controller: nameController,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'Ad Soyad',
                    prefixIcon: const Icon(
                      Icons.person_outline_rounded,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                TextField(
                  controller: nicknameController,
                  decoration: InputDecoration(
                    labelText: 'Kullanıcı adı',
                    prefixIcon: const Icon(
                      Icons.alternate_email_rounded,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      final newName = nameController.text.trim();
                      final newNickname =
                      nicknameController.text.trim();

                      if (newName.isEmpty ||
                          newNickname.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Lütfen tüm alanları doldur.',
                            ),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        return;
                      }

                      setState(() {
                        userName = newName;
                        userNickname = newNickname;
                      });

                      Navigator.pop(sheetContext);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Profil bilgileri güncellendi.',
                          ),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: const Icon(Icons.check_rounded),
                    label: const Text('Kaydet'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: colors.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
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

  // ------------------------------------------------------------
  // BİLDİRİM AYARLARI
  // ------------------------------------------------------------

  void _showNotificationSettings() {
    bool soundEnabled = true;
    bool studyReminderEnabled = true;

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final theme = Theme.of(context);
            final colors = theme.colorScheme;

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  8,
                  20,
                  30,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Bildirimler',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: colors.onSurface,
                        ),
                      ),
                    ),

                    const SizedBox(height: 6),

                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Çalışma bildirimlerini ve hatırlatıcılarını yönet.',
                        style: TextStyle(
                          fontSize: 14,
                          color: colors.onSurface
                              .withValues(alpha: 0.60),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'Bildirimleri Aç',
                      ),
                      subtitle: const Text(
                        'Çalışma ve uygulama bildirimleri',
                      ),
                      value: notificationsEnabled,
                      onChanged: (value) {
                        setSheetState(() {
                          notificationsEnabled = value;
                        });

                        setState(() {});
                      },
                    ),

                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'Çalışma Hatırlatıcıları',
                      ),
                      subtitle: const Text(
                        'Çalışma zamanı geldiğinde hatırlat',
                      ),
                      value: studyReminderEnabled,
                      onChanged: notificationsEnabled
                          ? (value) {
                        setSheetState(() {
                          studyReminderEnabled = value;
                        });
                      }
                          : null,
                    ),

                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'Tamamlanma Sesi',
                      ),
                      subtitle: const Text(
                        'Çalışma tamamlandığında ses çal',
                      ),
                      value: soundEnabled,
                      onChanged: notificationsEnabled
                          ? (value) {
                        setSheetState(() {
                          soundEnabled = value;
                        });
                      }
                          : null,
                    ),

                    const SizedBox(height: 8),

                    if (!notificationsEnabled)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: colors.primary
                              .withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              color: colors.primary,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Bildirimler kapalı olduğu için '
                                    'hatırlatıcılar çalışmaz.',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: colors.onSurface
                                      .withValues(alpha: 0.70),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ------------------------------------------------------------
  // AYARLAR
  // ------------------------------------------------------------

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SettingsScreen(
          isDarkMode:
          Theme.of(context).brightness == Brightness.dark,
          onThemeChanged: (value) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  value
                      ? 'Koyu tema seçildi.'
                      : 'Açık tema seçildi.',
                ),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        ),
      ),
    );
  }

  // ------------------------------------------------------------
  // HAKKINDA
  // ------------------------------------------------------------

  void _showAbout() {
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
          'Öğrencilerin çalışma süreçlerini takip etmelerine '
              'yardımcı olan çalışma koçu uygulaması.',
        ),
      ],
    );
  }

  // ------------------------------------------------------------
  // ÇIKIŞ
  // ------------------------------------------------------------

  void _showLogoutDialog(BuildContext context) {
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
                      'Çıkış işlemi daha sonra bağlanacak.',
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
}

// ============================================================
// PROFİL İSTATİSTİK KARTI
// ============================================================

class _ProfileStat extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const _ProfileStat({
    required this.value,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 16,
        horizontal: 8,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme.dividerColor,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: const Color(0xFF6750A4),
            size: 24,
          ),

          const SizedBox(height: 8),

          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colors.onSurface,
            ),
          ),

          const SizedBox(height: 3),

          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// PROFİL MENÜ ELEMANI
// ============================================================

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool danger;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final iconColor = danger
        ? Colors.red.shade600
        : const Color(0xFF6750A4);

    final titleColor = danger
        ? Colors.red.shade600
        : colors.onSurface;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme.dividerColor,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 5,
        ),
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: danger
                ? (isDark
                ? const Color(0xFF4A2020)
                : Colors.red.shade50)
                : (isDark
                ? const Color(0xFF3A3150)
                : const Color(0xFFEDE7F6)),
            borderRadius: BorderRadius.circular(13),
          ),
          child: Icon(
            icon,
            color: iconColor,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: titleColor,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: colors.onSurfaceVariant,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: colors.onSurfaceVariant,
        ),
        onTap: onTap,
      ),
    );
  }
}
