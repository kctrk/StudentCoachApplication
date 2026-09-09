import 'package:flutter/material.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: const Color(0xFF202124),
        title: const Text(
          'Geçmiş',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Çalışma Geçmişi',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF202124),
                ),
              ),

              const SizedBox(height: 6),

              Text(
                'Geçmiş çalışmalarını ve çözdüğün soruları takip et.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 24),

              _HistoryCard(
                subject: 'Matematik',
                topic: 'Fonksiyonlar',
                duration: '45 dakika',
                date: 'Bugün, 14:30',
                icon: Icons.calculate_rounded,
                color: const Color(0xFFE8DEF8),
              ),

              _HistoryCard(
                subject: 'Fizik',
                topic: 'Kuvvet ve Hareket',
                duration: '25 dakika',
                date: 'Bugün, 11:15',
                icon: Icons.science_rounded,
                color: const Color(0xFFDDEBF7),
              ),

              _HistoryCard(
                subject: 'Kimya',
                topic: 'Atom ve Periyodik Sistem',
                duration: '17 dakika',
                date: 'Dün, 19:20',
                icon: Icons.biotech_rounded,
                color: const Color(0xFFE2F0D9),
              ),

              _HistoryCard(
                subject: 'Türkçe',
                topic: 'Paragraf',
                duration: '32 dakika',
                date: 'Dün, 16:45',
                icon: Icons.menu_book_rounded,
                color: const Color(0xFFF9E4D4),
              ),

              const SizedBox(height: 20),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: Colors.grey.shade200,
                  ),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.history_rounded,
                      size: 42,
                      color: Color(0xFF6750A4),
                    ),

                    const SizedBox(height: 12),

                    const Text(
                      'Çalışmaların burada birikecek',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      'Kronometre ile yaptığın çalışmalar '
                      'ileride burada otomatik olarak gösterilebilir.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
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

class _HistoryCard extends StatelessWidget {
  final String subject;
  final String topic;
  final String duration;
  final String date;
  final IconData icon;
  final Color color;

  const _HistoryCard({
    required this.subject,
    required this.topic,
    required this.duration,
    required this.date,
    required this.icon,
    required this.color,
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
            width: 50,
            height: 50,
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
                  subject,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  topic,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  date,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),

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
