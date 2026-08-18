import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../mathos_chat_module.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(mathosChatProvider);
    
    // Yalnızca AI'ın verdiği cevapları filtreleyelim (Çözümler)
    final aiMessages = state.messages.where((m) => m.sender == MessageSender.ai).toList();
    // Ters çevirelim, en yeniler en üstte
    final reversedMessages = aiMessages.reversed.toList();

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: const Text('Geçmiş Çözümler', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF16213E),
      ),
      body: reversedMessages.isEmpty
          ? const Center(
              child: Text('Henüz geçmiş çözüm bulunmuyor.', 
                style: TextStyle(color: Colors.white70)),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: reversedMessages.length,
              itemBuilder: (context, index) {
                final msg = reversedMessages[index];
                return Card(
                  color: const Color(0xFF16213E),
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.auto_awesome, color: Colors.blueAccent, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              '${msg.createdAt.day}/${msg.createdAt.month}/${msg.createdAt.year} ${msg.createdAt.hour}:${msg.createdAt.minute}',
                              style: const TextStyle(color: Colors.white54, fontSize: 12),
                            ),
                          ],
                        ),
                        const Divider(color: Colors.white24),
                        const SizedBox(height: 8),
                        Text(
                          msg.text,
                          style: const TextStyle(color: Colors.white, fontSize: 14),
                          maxLines: 5,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
