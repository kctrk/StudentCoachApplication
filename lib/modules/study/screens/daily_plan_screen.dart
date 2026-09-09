import 'package:flutter/material.dart';
import 'timer_screen.dart';

class DailyPlanScreen extends StatefulWidget {
  const DailyPlanScreen({super.key});

  @override
  State<DailyPlanScreen> createState() => _DailyPlanScreenState();
}

class _DailyPlanScreenState extends State<DailyPlanScreen> {
  final List<PlanItem> plans = [
    const PlanItem(
      time: '09:00',
      subject: 'Matematik',
      topic: 'Fonksiyonlar',
      duration: '45 dk',
      icon: Icons.calculate_rounded,
      color: Color(0xFFE8DEF8),
    ),
    const PlanItem(
      time: '11:30',
      subject: 'Fizik',
      topic: 'Kuvvet ve Hareket',
      duration: '30 dk',
      icon: Icons.science_rounded,
      color: Color(0xFFDDEBF7),
    ),
    const PlanItem(
      time: '14:00',
      subject: 'Kimya',
      topic: 'Atom ve Periyodik Sistem',
      duration: '40 dk',
      icon: Icons.biotech_rounded,
      color: Color(0xFFE2F0D9),
    ),
  ];

  final List<SubjectOption> subjects = const [
    SubjectOption(
      name: 'Matematik',
      icon: Icons.calculate_rounded,
      color: Color(0xFFE8DEF8),
    ),
    SubjectOption(
      name: 'Fizik',
      icon: Icons.science_rounded,
      color: Color(0xFFDDEBF7),
    ),
    SubjectOption(
      name: 'Kimya',
      icon: Icons.biotech_rounded,
      color: Color(0xFFE2F0D9),
    ),
    SubjectOption(
      name: 'Türkçe',
      icon: Icons.menu_book_rounded,
      color: Color(0xFFF9E4D4),
    ),
    SubjectOption(
      name: 'Biyoloji',
      icon: Icons.eco_rounded,
      color: Color(0xFFDDF1EC),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: colors.onSurface,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Günlük Plan',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
          children: [
            _buildHeader(context),

            const SizedBox(height: 24),

            Text(
              'Bugünkü Çalışmalar',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colors.onSurface,
              ),
            ),

            const SizedBox(height: 14),

            ...plans.asMap().entries.map(
                  (entry) => _PlanCard(
                plan: entry.value,
                index: entry.key,
                onStart: () {
                  _startStudy(entry.value);
                },
                onDelete: () {
                  _deletePlan(entry.key);
                },
              ),
            ),

            const SizedBox(height: 10),

            OutlinedButton.icon(
              onPressed: _addPlan,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Görev Ekle'),
              style: OutlinedButton.styleFrom(
                foregroundColor: colors.primary,
                minimumSize: const Size(double.infinity, 54),
                side: BorderSide(
                  color: colors.primary.withValues(alpha: 0.35),
                ),
                backgroundColor: colors.primary.withValues(alpha: 0.05),
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

  Widget _buildHeader(BuildContext context) {
    final totalMinutes = plans.fold<int>(
      0,
          (sum, plan) => sum + _durationToMinutes(plan.duration),
    );

    return Container(
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
          Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bugün',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 6),

          const Text(
            'Çalışma planın hazır 🚀',
            style: TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            '${plans.length} çalışma • Toplam ${_formatTotalDuration(totalMinutes)}',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  void _addPlan() {
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
      builder: (_) {
        return _AddPlanSheet(
          subjects: subjects,
          onAdd: (plan) {
            setState(() {
              plans.add(plan);
              plans.sort(
                    (a, b) => a.time.compareTo(b.time),
              );
            });
          },
        );
      },
    );
  }

  void _startStudy(PlanItem plan) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TimerScreen(
          subject: plan.subject,
          topic: plan.topic,
          durationMinutes: _durationToMinutes(plan.duration),
        ),
      ),
    );
  }

  void _deletePlan(int index) {
    final deletedPlan = plans[index];

    setState(() {
      plans.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${deletedPlan.subject} görevi silindi.'),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'GERİ AL',
          onPressed: () {
            setState(() {
              plans.insert(index, deletedPlan);
              plans.sort(
                    (a, b) => a.time.compareTo(b.time),
              );
            });
          },
        ),
      ),
    );
  }

  int _durationToMinutes(String duration) {
    final hourMatch = RegExp(r'(\d+)s').firstMatch(duration);
    final minuteMatch = RegExp(r'(\d+)dk').firstMatch(duration);

    final hours = hourMatch != null
        ? int.tryParse(hourMatch.group(1)!) ?? 0
        : 0;

    final minutes = minuteMatch != null
        ? int.tryParse(minuteMatch.group(1)!) ?? 0
        : int.tryParse(
      duration.replaceAll(' dk', '').trim(),
    ) ??
        25;

    return (hours * 60) + minutes;
  }

  String _formatTotalDuration(int totalMinutes) {
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;

    if (hours == 0) {
      return '$minutes dakika';
    }

    if (minutes == 0) {
      return '$hours saat';
    }

    return '$hours saat $minutes dakika';
  }
}

class _AddPlanSheet extends StatefulWidget {
  final List<SubjectOption> subjects;
  final ValueChanged<PlanItem> onAdd;

  const _AddPlanSheet({
    required this.subjects,
    required this.onAdd,
  });

  @override
  State<_AddPlanSheet> createState() => _AddPlanSheetState();
}

class _AddPlanSheetState extends State<_AddPlanSheet> {
  SubjectOption? selectedSubject;

  final TextEditingController topicController =
  TextEditingController();

  TimeOfDay selectedTime = const TimeOfDay(
    hour: 16,
    minute: 0,
  );

  int selectedDuration = 30;

  final List<int> durationOptions = [
    15,
    25,
    30,
    45,
    60,
    90,
  ];

  @override
  void dispose() {
    topicController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          4,
          20,
          20 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Görev Ekle',
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.w700,
                  color: colors.onSurface,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                'Bugünkü çalışma planına yeni bir görev ekle.',
                style: TextStyle(
                  fontSize: 14,
                  color: colors.onSurface.withValues(alpha: 0.60),
                ),
              ),

              const SizedBox(height: 22),

              Text(
                'Ders',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: colors.onSurface,
                ),
              ),

              const SizedBox(height: 10),

              SizedBox(
                height: 94,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.subjects.length,
                  separatorBuilder: (_, __) =>
                  const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final subject = widget.subjects[index];
                    final selected =
                        selectedSubject?.name == subject.name;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedSubject = subject;
                        });
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: 92,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: selected
                              ? colors.primary.withValues(alpha: 0.12)
                              : theme.cardColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: selected
                                ? colors.primary
                                : colors.outline.withValues(
                              alpha: 0.25,
                            ),
                            width: selected ? 1.5 : 1,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: subject.color,
                                borderRadius: BorderRadius.circular(11),
                              ),
                              child: Icon(
                                subject.icon,
                                size: 20,
                                color: const Color(0xFF51465F),
                              ),
                            ),

                            const SizedBox(height: 7),

                            Text(
                              subject.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: colors.onSurface,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 20),

              Text(
                'Konu',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: colors.onSurface,
                ),
              ),

              const SizedBox(height: 10),

              TextField(
                controller: topicController,
                style: TextStyle(
                  color: colors.onSurface,
                ),
                decoration: InputDecoration(
                  hintText: 'Örn. Türev, Paragraf, Hücre...',
                  hintStyle: TextStyle(
                    color: colors.onSurface.withValues(alpha: 0.45),
                  ),
                  prefixIcon: const Icon(
                    Icons.menu_book_rounded,
                  ),
                  filled: true,
                  fillColor: theme.cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: colors.outline.withValues(alpha: 0.25),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: colors.outline.withValues(alpha: 0.25),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: colors.primary,
                      width: 1.5,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Text(
                'Saat',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: colors.onSurface,
                ),
              ),

              const SizedBox(height: 10),

              InkWell(
                onTap: _selectTime,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 15,
                  ),
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
                        Icons.access_time_rounded,
                        color: colors.primary,
                      ),

                      const SizedBox(width: 12),

                      Text(
                        selectedTime.format(context),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: colors.onSurface,
                        ),
                      ),

                      const Spacer(),

                      Icon(
                        Icons.chevron_right_rounded,
                        color: colors.onSurface.withValues(alpha: 0.45),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Text(
                'Çalışma süresi',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: colors.onSurface,
                ),
              ),

              const SizedBox(height: 10),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: durationOptions.map(
                      (duration) {
                    final selected =
                        selectedDuration == duration;

                    return ChoiceChip(
                      label: Text('$duration dk'),
                      selected: selected,
                      onSelected: (_) {
                        setState(() {
                          selectedDuration = duration;
                        });
                      },
                      selectedColor:
                      colors.primary.withValues(alpha: 0.15),
                      labelStyle: TextStyle(
                        color: selected
                            ? colors.primary
                            : colors.onSurface.withValues(
                          alpha: 0.70,
                        ),
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                      side: BorderSide(
                        color: selected
                            ? colors.primary
                            : colors.outline.withValues(
                          alpha: 0.25,
                        ),
                      ),
                    );
                  },
                ).toList(),
              ),

              const SizedBox(height: 26),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: _savePlan,
                  icon: const Icon(Icons.add_task_rounded),
                  label: const Text('Görevi Ekle'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
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
        ),
      ),
    );
  }

  Future<void> _selectTime() async {
    final result = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );

    if (result != null) {
      setState(() {
        selectedTime = result;
      });
    }
  }

  void _savePlan() {
    if (selectedSubject == null) {
      _showError('Lütfen bir ders seç.');
      return;
    }

    final topic = topicController.text.trim();

    if (topic.isEmpty) {
      _showError('Lütfen çalışacağın konuyu yaz.');
      return;
    }

    final plan = PlanItem(
      time: _formatTime(selectedTime),
      subject: selectedSubject!.name,
      topic: topic,
      duration: '$selectedDuration dk',
      icon: selectedSubject!.icon,
      color: selectedSubject!.color,
    );

    widget.onAdd(plan);

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${plan.subject} • ${plan.topic} günlük plana eklendi.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

class SubjectOption {
  final String name;
  final IconData icon;
  final Color color;

  const SubjectOption({
    required this.name,
    required this.icon,
    required this.color,
  });
}

class PlanItem {
  final String time;
  final String subject;
  final String topic;
  final String duration;
  final IconData icon;
  final Color color;

  const PlanItem({
    required this.time,
    required this.subject,
    required this.topic,
    required this.duration,
    required this.icon,
    required this.color,
  });
}

class _PlanCard extends StatelessWidget {
  final PlanItem plan;
  final int index;
  final VoidCallback onStart;
  final VoidCallback onDelete;

  const _PlanCard({
    required this.plan,
    required this.index,
    required this.onStart,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    final iconBackground = isDark
        ? Color.lerp(
      plan.color,
      Colors.black,
      0.45,
    )!
        : plan.color;

    final iconColor = isDark
        ? Colors.white.withValues(alpha: 0.90)
        : const Color(0xFF4A4458);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colors.outline.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 52,
            child: Text(
              plan.time,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: colors.primary,
              ),
            ),
          ),

          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              plan.icon,
              color: iconColor,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plan.subject,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: colors.onSurface,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  plan.topic,
                  style: TextStyle(
                    fontSize: 13,
                    color: colors.onSurface.withValues(alpha: 0.60),
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  plan.duration,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: colors.onSurface.withValues(alpha: 0.50),
                  ),
                ),
              ],
            ),
          ),

          PopupMenuButton<String>(
            tooltip: 'Görev seçenekleri',
            onSelected: (value) {
              if (value == 'delete') {
                onDelete();
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(
                      Icons.delete_outline_rounded,
                      color: Colors.red,
                    ),
                    SizedBox(width: 10),
                    Text('Görevi sil'),
                  ],
                ),
              ),
            ],
            icon: Icon(
              Icons.more_vert_rounded,
              color: colors.onSurface.withValues(alpha: 0.45),
            ),
          ),

          IconButton(
            onPressed: onStart,
            tooltip: 'Çalışmaya başla',
            style: IconButton.styleFrom(
              backgroundColor: colors.primary.withValues(
                alpha: isDark ? 0.18 : 0.08,
              ),
              foregroundColor: colors.primary,
            ),
            icon: const Icon(
              Icons.play_arrow_rounded,
            ),
          ),
        ],
      ),
    );
  }
}


