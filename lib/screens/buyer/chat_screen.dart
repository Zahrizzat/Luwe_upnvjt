import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../models/chat_message_model.dart';
import '../../providers/app_state.dart';
import '../auth/login_screen.dart';

class ChatScreen extends StatefulWidget {
  final AppState state;

  const ChatScreen({super.key, required this.state});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    if (widget.state.isLoggedIn) {
      widget.state.refreshConversations();
    }
  }

  @override
  void dispose() {
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _msgController.text.trim();
    if (text.isNotEmpty) {
      widget.state.sendChatMessage(text);
      _msgController.clear();
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
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.state.isLoggedIn) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.chat_bubble_outline_rounded, size: 32, color: AppColors.primary),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Fitur Chat Memerlukan Akun',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Masuk ke akun Luwe kamu untuk dapat mengirim pesan dan berdiskusi langsung dengan penjual stan kuliner kampus.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.45),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => Dialog(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 480, maxHeight: 680),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: LoginScreen(state: widget.state),
                              ),
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.login_rounded, size: 18),
                      label: const Text('Masuk Sekarang', style: TextStyle(fontWeight: FontWeight.w800)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final conversations = widget.state.conversations;
    final filteredConversations = conversations.where((c) {
      return c.otherPartyName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          c.otherPartySubtitle.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    final activeConvo = widget.state.activeConversation;
    final messages = widget.state.chatMessages;

    return Container(
      color: Colors.white,
      child: Row(
        children: [
          // Left Sidebar: Conversations List
          Container(
            width: 320,
            decoration: const BoxDecoration(
              border: Border(right: BorderSide(color: AppColors.surfaceBorder)),
              color: Colors.white,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Pesan & Diskusi',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh_rounded, size: 20),
                        tooltip: 'Segarkan obrolan',
                        onPressed: () => widget.state.refreshConversations(),
                      ),
                    ],
                  ),
                ),

                // Search field
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: TextField(
                    onChanged: (v) => setState(() => _searchQuery = v),
                    decoration: InputDecoration(
                      hintText: 'Cari obrolan stan kuliner...',
                      prefixIcon: const Icon(Icons.search, size: 18, color: AppColors.textMuted),
                      filled: true,
                      fillColor: AppColors.canvas,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Conversation items
                Expanded(
                  child: filteredConversations.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.chat_bubble_outline_rounded, size: 36, color: AppColors.textLight),
                                const SizedBox(height: 12),
                                const Text(
                                  'Belum Ada Percakapan',
                                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Percakapan dengan penjual atau pembeli kamu akan tampil di sini.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.separated(
                          itemCount: filteredConversations.length,
                          separatorBuilder: (context, index) => const Divider(height: 1, indent: 68),
                          itemBuilder: (context, idx) {
                            final convo = filteredConversations[idx];
                            final isSelected = activeConvo?.id == convo.id;

                            return ListTile(
                              selected: isSelected,
                              selectedTileColor: AppColors.primaryLight.withValues(alpha: 0.3),
                              onTap: () => widget.state.selectConversation(convo),
                              leading: CircleAvatar(
                                radius: 20,
                                backgroundColor: AppColors.primaryLight,
                                backgroundImage: NetworkImage(convo.otherPartyAvatar),
                              ),
                              title: Text(
                                convo.otherPartyName,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Text(
                                convo.lastMessage,
                                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: Text(
                                '${convo.lastMessageAt.hour.toString().padLeft(2, '0')}:${convo.lastMessageAt.minute.toString().padLeft(2, '0')}',
                                style: const TextStyle(fontSize: 10, color: AppColors.textLight),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),

          // Right Area: Active Chat Room
          Expanded(
            child: activeConvo == null && conversations.isEmpty
                ? _buildEmptyState()
                : Column(
                    children: [
                      // Active Convo Header
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                        decoration: const BoxDecoration(
                          border: Border(bottom: BorderSide(color: AppColors.surfaceBorder)),
                        ),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: AppColors.primaryLight,
                              backgroundImage: NetworkImage(
                                activeConvo?.otherPartyAvatar ??
                                    'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=400&q=80',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        activeConvo?.otherPartyName ?? 'Adistya (Warung Sambal Kampus UPN)',
                                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.secondaryLight,
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: const Text(
                                          'Online',
                                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.secondaryDark),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    activeConvo?.otherPartySubtitle ?? 'Kantin Barat • Gedung Giri Reksa UPNVJT',
                                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Quick pills
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        color: AppColors.canvas,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              const Text('Pesan Cepat: ', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
                              _buildQuickPill('Kira-kira berapa menit lagi siap kak?'),
                              _buildQuickPill('Saya tunggu di depan Lobi Lab RPL ya kak'),
                              _buildQuickPill('Minta sendok plastik dan tisu ya kak'),
                              _buildQuickPill('Uang pas sudah saya siapkan kak'),
                            ],
                          ),
                        ),
                      ),

                      // Messages List
                      Expanded(
                        child: Container(
                          color: AppColors.canvas,
                          child: messages.isEmpty
                              ? const Center(
                                  child: Text(
                                    'Belum ada pesan dalam percakapan ini. Mulai ketik pesan pertama Anda!',
                                    style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                                  ),
                                )
                              : ListView.builder(
                                  controller: _scrollController,
                                  padding: const EdgeInsets.all(24),
                                  itemCount: messages.length,
                                  itemBuilder: (context, index) {
                                    final msg = messages[index];
                                    return _buildMessageBubble(msg);
                                  },
                                ),
                        ),
                      ),

                      // Input Bar
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          border: Border(top: BorderSide(color: AppColors.surfaceBorder)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _msgController,
                                onSubmitted: (_) => _sendMessage(),
                                decoration: InputDecoration(
                                  hintText: 'Tulis pesan untuk rekan civitas kampus...',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(24),
                                    borderSide: const BorderSide(color: AppColors.surfaceBorder),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(24),
                                    borderSide: const BorderSide(color: AppColors.surfaceBorder),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            IconButton.filled(
                              icon: const Icon(Icons.send_rounded, size: 18),
                              onPressed: _sendMessage,
                              style: IconButton.styleFrom(backgroundColor: AppColors.primary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.surfaceMuted,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.forum_outlined, size: 48, color: AppColors.textMuted),
            ),
            const SizedBox(height: 16),
            const Text(
              'Pilih Percakapan untuk Memulai',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 6),
            const Text(
              'Hubungi stan kuliner atau rekan mahasiswa untuk berdiskusi langsung.',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickPill(String text) {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      child: ActionChip(
        label: Text(text),
        onPressed: () {
          _msgController.text = text;
        },
        backgroundColor: Colors.white,
        labelStyle: const TextStyle(fontSize: 11, color: AppColors.textPrimary),
        side: const BorderSide(color: AppColors.surfaceBorder),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessageModel msg) {
    final isMe = msg.isMe;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        constraints: const BoxConstraints(maxWidth: 480),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isMe ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(4),
            bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(16),
          ),
          border: isMe ? null : Border.all(color: AppColors.surfaceBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              msg.senderName,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: isMe ? Colors.white70 : AppColors.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              msg.message,
              style: TextStyle(
                fontSize: 13,
                color: isMe ? Colors.white : AppColors.textPrimary,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${msg.timestamp.hour.toString().padLeft(2, '0')}:${msg.timestamp.minute.toString().padLeft(2, '0')}',
              style: TextStyle(
                fontSize: 10,
                color: isMe ? Colors.white60 : AppColors.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
