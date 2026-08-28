import 'dart:async';

import 'package:flutter/material.dart';

class TimerScreen extends StatefulWidget {
  final String subject;
  final String topic;
  final int durationMinutes;

  const TimerScreen({
    super.key,
    this.subject = 'Matematik',
    this.topic = 'Fonksiyonlar',
    this.durationMinutes = 25,
  });

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  Timer? _timer;

  late int _selectedMinutes;
  late int _remainingSeconds;

  bool _isRunning = false;

  @override
  void initState() {
    super.initState();

    _selectedMinutes = widget.durationMinutes;
    _remainingSeconds = widget.durationMinutes * 60;
  }

  void _startTimer() {
    if (_isRunning || _remainingSeconds <= 0) return;

    setState(() {
      _isRunning = true;
    });

    _timer = Timer.periodic(
      const Duration(seconds: 1),
          (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }

        if (_remainingSeconds > 0) {
          setState(() {
            _remainingSeconds--;
          });
        } else {
          _stopTimer();

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Çalışma süren tamamlandı! 🎉'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
    );
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;

    if (!mounted) return;

    setState(() {
      _isRunning = false;
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    _timer = null;

    setState(() {
      _remainingSeconds = _selectedMinutes * 60;
      _isRunning = false;
    });
  }

  void _selectDuration(int minutes) {
    if (_isRunning) return;

    setState(() {
      _selectedMinutes = minutes;
      _remainingSeconds = minutes * 60;
    });
  }

  Future<void> _showManualDurationDialog() async {
    if (_isRunning) return;

    final controller = TextEditingController(
      text: _selectedMinutes.toString(),
    );

    final result = await showDialog<int>(
      context: context,
      builder: (dialogContext) {
        final theme = Theme.of(dialogContext);
        final colors = theme.colorScheme;

        return AlertDialog(
          title: const Text('Manuel Süre Belirle'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Dakika',
              hintText: 'Örneğin 35',
              suffixText: 'dk',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('İptal'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: colors.onPrimary,
              ),
              onPressed: () {
                final minutes = int.tryParse(controller.text);

                if (minutes != null && minutes > 0 && minutes <= 180) {
                  Navigator.pop(dialogContext, minutes);
                }
              },
              child: const Text('Uygula'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (result != null && mounted) {
      _selectDuration(result);
    }
  }

  String _formatTime() {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;

    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  double get _progress {
    final totalSeconds = _selectedMinutes * 60;

    if (totalSeconds <= 0) return 0;

    return 1 - (_remainingSeconds / totalSeconds);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final isDark = theme.brightness == Brightness.dark;

    final cardColor = theme.cardColor;
    final primaryColor = colors.primary;
    final mainTextColor = colors.onSurface;
    final secondaryTextColor = colors.onSurface.withValues(alpha: 0.65);

    final chipBackground = isDark
        ? colors.surfaceContainerHighest
        : Colors.white;

    final borderColor = isDark
        ? colors.outline.withValues(alpha: 0.35)
        : const Color(0xFFE0E0E4);

    final softPurple = isDark
        ? const Color(0xFF30264A)
        : const Color(0xFFE8DEF8);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: mainTextColor,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Kronometre',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
          child: Column(
            children: [
              Text(
                'Odaklanma Zamanı',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: mainTextColor,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                _isRunning
                    ? 'Çalışmaya devam et, harika gidiyorsun! 💪'
                    : 'Çalışma süreni belirle ve başla.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: secondaryTextColor,
                ),
              ),

              const SizedBox(height: 28),

              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Çalışma Süresi',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: mainTextColor,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _DurationChip(
                    label: '15 dk',
                    selected: _selectedMinutes == 15,
                    enabled: !_isRunning,
                    onTap: () => _selectDuration(15),
                  ),
                  _DurationChip(
                    label: '25 dk',
                    selected: _selectedMinutes == 25,
                    enabled: !_isRunning,
                    onTap: () => _selectDuration(25),
                  ),
                  _DurationChip(
                    label: '45 dk',
                    selected: _selectedMinutes == 45,
                    enabled: !_isRunning,
                    onTap: () => _selectDuration(45),
                  ),
                  _DurationChip(
                    label: '60 dk',
                    selected: _selectedMinutes == 60,
                    enabled: !_isRunning,
                    onTap: () => _selectDuration(60),
                  ),
                  _DurationChip(
                    label: 'Manuel',
                    selected: ![15, 25, 45, 60].contains(_selectedMinutes),
                    enabled: !_isRunning,
                    onTap: _showManualDurationDialog,
                  ),
                ],
              ),

              const SizedBox(height: 36),

              Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: cardColor,
                  boxShadow: [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: isDark ? 0.20 : 0.12),
                      blurRadius: 30,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 250,
                      height: 250,
                      child: CircularProgressIndicator(
                        value: _progress,
                        strokeWidth: 12,
                        backgroundColor: isDark
                            ? colors.surfaceContainerHighest
                            : const Color(0xFFE8E1F5),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          primaryColor,
                        ),
                      ),
                    ),

                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _formatTime(),
                          style: TextStyle(
                            fontSize: 52,
                            fontWeight: FontWeight.bold,
                            color: mainTextColor,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          _isRunning ? 'Çalışılıyor' : 'Hazır',
                          style: TextStyle(
                            fontSize: 14,
                            color: secondaryTextColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 36),

              // Ders bilgisi
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: borderColor,
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: softPurple,
                      child: Icon(
                        Icons.calculate_rounded,
                        color: primaryColor,
                      ),
                    ),

                    const SizedBox(width: 14),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.subject,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: mainTextColor,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            widget.topic,
                            style: TextStyle(
                              fontSize: 13,
                              color: secondaryTextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _isRunning ? _stopTimer : _startTimer,
                  icon: Icon(
                    _isRunning
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                  ),
                  label: Text(
                    _isRunning ? 'Durdur' : 'Başlat',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark
                        ? colors.primary
                        : const Color(0xFF202124),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  onPressed: _resetTimer,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Sıfırla'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primaryColor,
                    side: BorderSide(
                      color: isDark
                          ? colors.outline.withValues(alpha: 0.5)
                          : const Color(0xFFD8CCF2),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    textStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Text(
                '💡 İpucu: Telefonunu sessize al ve sadece çalışmana odaklan.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: secondaryTextColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DurationChip extends StatelessWidget {
  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  const _DurationChip({
    required this.label,
    required this.selected,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 11,
        ),
        decoration: BoxDecoration(
          color: selected
              ? colors.primary
              : isDark
              ? colors.surfaceContainerHighest
              : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? colors.primary
                : colors.outline.withValues(alpha: 0.35),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected
                ? colors.onPrimary
                : colors.onSurface.withValues(alpha: 0.75),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

