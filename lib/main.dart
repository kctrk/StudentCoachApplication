import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'modules/mathos_chat_module.dart';
import 'modules/scanner/scanner_screen.dart';
import 'modules/history/history_screen.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MathosApp(),
    ),
  );
}

class MathosApp extends StatelessWidget {
  const MathosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mathos AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2196F3),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          ChatScreen(),
          ScannerScreen(),
          HistoryScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.chat), label: 'Sohbet'),
          NavigationDestination(icon: Icon(Icons.camera_alt), label: 'Tara & Çöz'),
          NavigationDestination(icon: Icon(Icons.history), label: 'Geçmiş'),
        ],
      ),
    );
  }
}

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mathosChatProvider);
    final notifier = ref.read(mathosChatProvider.notifier);

    // Yeni mesaj gelince aşağı kaydır
    ref.listen(mathosChatProvider, (previous, next) {
      if (previous?.messages.length != next.messages.length) {
        _scrollToBottom();
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF16213E),
        title: const Text('Mathos AI', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white70),
            onPressed: () => notifier.clearChat(),
            tooltip: 'Sohbeti Temizle',
          ),
          PopupMenuButton<AiMode>(
            icon: const Icon(Icons.psychology, color: Colors.white70),
            tooltip: 'AI Modunu Değiştir',
            onSelected: (mode) => notifier.setMode(mode),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: AiMode.solver,
                child: Text('Soru Çözücü'),
              ),
              const PopupMenuItem(
                value: AiMode.motivation,
                child: Text('Motivasyon Koçu'),
              ),
              const PopupMenuItem(
                value: AiMode.studyPlan,
                child: Text('Çalışma Planı Oluşturucu'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Aktif mod göstergesi
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
            color: Colors.blueAccent.withValues(alpha: 0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  state.currentMode == AiMode.solver ? Icons.calculate :
                  state.currentMode == AiMode.motivation ? Icons.favorite : Icons.calendar_month,
                  size: 16,
                  color: Colors.blueAccent,
                ),
                const SizedBox(width: 8),
                Text(
                  'Aktif Mod: ${state.currentMode.name.toUpperCase()}',
                  style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          // Mesaj Listesi
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: state.messages.length,
              itemBuilder: (context, index) {
                final msg = state.messages[index];
                final isUser = msg.sender == MessageSender.user;
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.all(12),
                    constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.8),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.blue[700] : const Color(0xFF16213E),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (msg.imageFile != null) ...[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(msg.imageFile!, height: 150, fit: BoxFit.cover),
                          ),
                          const SizedBox(height: 8),
                        ],
                        Text(
                          msg.text,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Yükleniyor Göstergesi
          if (state.isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),

          // Seçili Görsel Önizlemesi
          if (state.selectedImage != null)
            Container(
              padding: const EdgeInsets.all(8),
              color: const Color(0xFF16213E),
              child: Row(
                children: [
                  Image.file(state.selectedImage!, height: 50, width: 50, fit: BoxFit.cover),
                  const SizedBox(width: 8),
                  const Expanded(child: Text('Görsel eklendi')),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red),
                    onPressed: () => notifier.removeSelectedImage(),
                  )
                ],
              ),
            ),

          // Giriş Alanı
          Container(
            padding: const EdgeInsets.all(8),
            color: const Color(0xFF16213E),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.camera_alt),
                  onPressed: () => notifier.pickImageFromCamera(),
                ),
                IconButton(
                  icon: const Icon(Icons.photo_library),
                  onPressed: () => notifier.pickImageFromGallery(),
                ),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Bir şeyler yaz...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white12,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    onSubmitted: (val) {
                      if (val.isNotEmpty) {
                        notifier.sendMessage(val);
                        _controller.clear();
                      }
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blue),
                  onPressed: () {
                    if (_controller.text.isNotEmpty) {
                      notifier.sendMessage(_controller.text);
                      _controller.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
