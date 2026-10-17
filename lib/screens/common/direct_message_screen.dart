import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../models/chat_message_model.dart';
import '../../models/order_model.dart';
import '../../models/user_model.dart';
import '../../providers/app_state.dart';
import '../auth/login_screen.dart';

/// Halaman Direct Message (DM) / Pesan Resmi LuWe!
/// Menghubungkan komunikasi langsung antara Mahasiswa/Pembeli dan Toko Danusan/Penjual.
class DirectMessageScreen extends StatefulWidget {
  final AppState state;

  const DirectMessageScreen({super.key, required this.state});

  @override
  State<DirectMessageScreen> createState() => _DirectMessageScreenState();
}

class _DirectMessageScreenState extends State<DirectMessageScreen> {
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _searchQuery = '';
  bool _isSending = false;

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

  Future<void> _sendMessage() async {
    final text = _msgController.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() => _isSending = true);
    final ok = await widget.state.sendChatMessage(text);
    if (mounted) {
      setState(() => _isSending = false);
    }

    if (ok) {
      _msgController.clear();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
          );
        }
      });
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal mengirim pesan. Silakan periksa koneksi dan coba lagi.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showOrderDetailDialog(BuildContext context, OrderModel order) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: 480,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.receipt_long_rounded, color: AppColors.primary, size: 22),
                      const SizedBox(width: 8),
                      Text(
                        'Pesanan ${order.id}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.canvas,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.surfaceBorder),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Toko / Danusan:', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        Text(order.merchantName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Status Pesanan:', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        Text(
                          order.statusText,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primary),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Pembayaran:', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                        Text(
                          'Rp ${order.totalAmount}',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.primaryRed),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              const Text('Menu yang dipesan:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              ...order.items.map((it) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('• ${it.quantity}x ${it.item.name}', style: const TextStyle(fontSize: 12)),
                        Text('Rp ${it.subtotal}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  )),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Tutup'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final isBuyer = state.activeRole == UserRole.buyer;

    if (!state.isLoggedIn) {
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
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 68,
                    height: 68,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryLight,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.chat_bubble_outline_rounded, size: 34, color: AppColors.primaryRed),
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Direct Message Memerlukan Akun',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Masuk ke akun LuWe! kamu untuk mengirim pesan, berdiskusi mengenai menu, dan memantau status pesanan langsung dengan penjual stan atau pembeli.',
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
                                child: LoginScreen(state: state),
                              ),
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.login_rounded, size: 18),
                      label: const Text('Masuk Sekarang', style: TextStyle(fontWeight: FontWeight.w800)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final conversations = state.conversations;
    final filteredConversations = conversations.where((c) {
      final q = _searchQuery.toLowerCase();
      return c.otherPartyName.toLowerCase().contains(q) ||
          c.otherPartySubtitle.toLowerCase().contains(q) ||
          (c.orderId != null && c.orderId!.toLowerCase().contains(q));
    }).toList();

    final activeConvo = state.activeConversation;
    final messages = state.chatMessages;

    // Check if related order exists
    OrderModel? relatedOrder;
    if (activeConvo?.orderId != null && activeConvo!.orderId!.isNotEmpty) {
      final allOrders = isBuyer ? state.orders : state.sellerOrders;
      relatedOrder = allOrders.where((o) => o.id == activeConvo.orderId).firstOrNull;
    }

    return Container(
      color: Colors.white,
      child: Row(
        children: [
          // Left Sidebar: Conversations List
          Container(
            width: 340,
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
                      Row(
                        children: [
                          const Icon(Icons.mark_chat_unread_rounded, size: 22, color: AppColors.primaryRed),
                          const SizedBox(width: 8),
                          Text(
                            isBuyer ? 'Direct Message Toko' : 'Direct Message Pembeli',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh_rounded, size: 20),
                        tooltip: 'Segarkan pesan',
                        onPressed: () => state.refreshConversations(),
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
                      hintText: isBuyer ? 'Cari toko atau kode pesanan...' : 'Cari pembeli atau pesanan...',
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

                // Conversation List
                Expanded(
                  child: filteredConversations.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.forum_outlined, size: 40, color: AppColors.textLight),
                                const SizedBox(height: 12),
                                Text(
                                  isBuyer ? 'Belum Ada Pesan Masuk' : 'Belum Ada Chat Pembeli',
                                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  isBuyer
                                      ? 'Mulai chat dengan toko danusan setelah memesan atau tanyakan menu favoritmu.'
                                      : 'Pesan dari pembeli yang memesan menu tokomu akan ditampilkan di sini.',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted, height: 1.4),
                                ),
                              ],
                            ),
                          ),
                        )
                      : ListView.separated(
                          itemCount: filteredConversations.length,
                          separatorBuilder: (context, index) => const Divider(height: 1, indent: 72),
                          itemBuilder: (context, idx) {
                            final convo = filteredConversations[idx];
                            final isSelected = activeConvo?.id == convo.id;

                            return ListTile(
                              selected: isSelected,
                              selectedTileColor: AppColors.primaryLight.withValues(alpha: 0.35),
                              onTap: () => state.selectConversation(convo),
                              leading: Stack(
                                children: [
                                  CircleAvatar(
                                    radius: 22,
                                    backgroundColor: AppColors.primaryLight,
                                    backgroundImage: NetworkImage(convo.otherPartyAvatar),
                                  ),
                                  if (convo.unreadCount > 0)
                                    Positioned(
                                      right: 0,
                                      top: 0,
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: AppColors.primaryRed,
                                          shape: BoxShape.circle,
                                        ),
                                        constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                                        child: Text(
                                          '${convo.unreadCount}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 9,
                                            fontWeight: FontWeight.w900,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              title: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      convo.otherPartyName,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: isSelected || convo.unreadCount > 0
                                            ? FontWeight.w800
                                            : FontWeight.w600,
                                        color: AppColors.textPrimary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${convo.lastMessageAt.hour.toString().padLeft(2, '0')}:${convo.lastMessageAt.minute.toString().padLeft(2, '0')}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: convo.unreadCount > 0 ? AppColors.primaryRed : AppColors.textLight,
                                      fontWeight: convo.unreadCount > 0 ? FontWeight.w700 : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (convo.orderId != null && convo.orderId!.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                      decoration: BoxDecoration(
                                        color: AppColors.cream,
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(color: AppColors.goldenYellow.withValues(alpha: 0.6)),
                                      ),
                                      child: Text(
                                        'Pesanan #${convo.orderId}',
                                        style: const TextStyle(
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.terracotta,
                                        ),
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 2),
                                  Text(
                                    convo.lastMessage,
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      color: convo.unreadCount > 0 ? AppColors.textPrimary : AppColors.textMuted,
                                      fontWeight: convo.unreadCount > 0 ? FontWeight.w700 : FontWeight.normal,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),

          // Right Area: Active Direct Message Conversation
          Expanded(
            child: activeConvo == null
                ? _buildEmptyActiveState(isBuyer)
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
                              backgroundImage: NetworkImage(activeConvo.otherPartyAvatar),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        activeConvo.otherPartyName,
                                        style: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.textPrimary,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: AppColors.pastelYellow,
                                          borderRadius: BorderRadius.circular(4),
                                          border: Border.all(color: AppColors.goldenYellow),
                                        ),
                                        child: Text(
                                          isBuyer ? 'Toko Danusan' : 'Pembeli Mahasiswa',
                                          style: const TextStyle(
                                            fontSize: 9.5,
                                            fontWeight: FontWeight.w800,
                                            color: AppColors.terracotta,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    activeConvo.otherPartySubtitle,
                                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Related Order Card (If Conversation is Linked to an Order)
                      if (activeConvo.orderId != null && activeConvo.orderId!.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppColors.canvas,
                            border: const Border(bottom: BorderSide(color: AppColors.surfaceBorder)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: AppColors.cream,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.receipt_long_rounded, size: 18, color: AppColors.primaryRed),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Percakapan terkait pesanan #${activeConvo.orderId}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      relatedOrder != null
                                          ? '${relatedOrder.statusText} • Rp ${relatedOrder.totalAmount}'
                                          : 'Transaksi pesanan mahasiswa terhubung',
                                      style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                    ),
                                  ],
                                ),
                              ),
                              if (relatedOrder != null)
                                TextButton.icon(
                                  onPressed: () => _showOrderDetailDialog(context, relatedOrder!),
                                  icon: const Icon(Icons.visibility_rounded, size: 14),
                                  label: const Text('Detail Pesanan', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                                  style: TextButton.styleFrom(foregroundColor: AppColors.primaryRed),
                                ),
                            ],
                          ),
                        ),

                      // Quick Pills for Convenient Messaging
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        color: AppColors.canvas,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              const Text('Pesan Cepat: ',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMuted)),
                              if (isBuyer) ...[
                                _buildQuickPill('Halo kak, apakah menu masih ready?'),
                                _buildQuickPill('Pesanan saya sudah siap diambil kak?'),
                                _buildQuickPill('Saya sedang menuju ke lokasi stan kak.'),
                                _buildQuickPill('Terima kasih banyak kak!'),
                              ] else ...[
                                _buildQuickPill('Halo kak! Pesanan sedang kami siapkan yaa.'),
                                _buildQuickPill('Pesanan sudah siap diambil di stan kami kak.'),
                                _buildQuickPill('Mohon konfirmasi jika sudah di lokasi stan.'),
                                _buildQuickPill('Terima kasih sudah memesan di danus kami!'),
                              ],
                            ],
                          ),
                        ),
                      ),

                      // Messages List
                      Expanded(
                        child: Container(
                          color: AppColors.canvas,
                          child: state.isLoadingChat
                              ? const Center(child: CircularProgressIndicator())
                              : messages.isEmpty
                                  ? const Center(
                                      child: Text(
                                        'Belum ada pesan dalam percakapan ini. Kirim pesan pertama Anda!',
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
                                  hintText: isBuyer
                                      ? 'Tulis pesan untuk toko danusan mahasiswa...'
                                      : 'Tulis balasan pesan untuk pembeli...',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(24),
                                    borderSide: const BorderSide(color: AppColors.surfaceBorder),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(24),
                                    borderSide: const BorderSide(color: AppColors.surfaceBorder),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            IconButton.filled(
                              icon: _isSending
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                    )
                                  : const Icon(Icons.send_rounded, size: 18),
                              onPressed: _isSending ? null : _sendMessage,
                              style: IconButton.styleFrom(backgroundColor: AppColors.primaryRed),
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

  Widget _buildEmptyActiveState(bool isBuyer) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: const BoxDecoration(
                color: AppColors.surfaceMuted,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.forum_outlined, size: 48, color: AppColors.textMuted),
            ),
            const SizedBox(height: 16),
            Text(
              isBuyer ? 'Pilih Toko untuk Berkomunikasi' : 'Pilih Percakapan Pembeli',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 6),
            Text(
              isBuyer
                  ? 'Buka percakapan dari daftar di sebelah kiri atau klik "Chat Toko" setelah menyelesaikan checkout.'
                  : 'Kelola pertanyaan dan diskusi pembeli mengenai ketersediaan hidangan dan pengambilan pesanan.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
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
          color: isMe ? AppColors.primaryRed : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(4),
            bottomRight: isMe ? const Radius.circular(4) : const Radius.circular(16),
          ),
          border: isMe ? null : Border.all(color: AppColors.surfaceBorder),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
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
                color: isMe ? Colors.white70 : AppColors.primaryRed,
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
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${msg.timestamp.hour.toString().padLeft(2, '0')}:${msg.timestamp.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    fontSize: 10,
                    color: isMe ? Colors.white60 : AppColors.textLight,
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  Icon(
                    msg.isRead ? Icons.done_all_rounded : Icons.done_rounded,
                    size: 13,
                    color: msg.isRead ? AppColors.pastelYellow : Colors.white60,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
