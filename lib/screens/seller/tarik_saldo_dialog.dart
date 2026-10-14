import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../models/withdrawal_model.dart';
import '../../providers/app_state.dart';

class TarikSaldoDialog extends StatefulWidget {
  final AppState state;

  const TarikSaldoDialog({super.key, required this.state});

  @override
  State<TarikSaldoDialog> createState() => _TarikSaldoDialogState();
}

class _TarikSaldoDialogState extends State<TarikSaldoDialog> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _accountNameController = TextEditingController();
  final TextEditingController _accountNumberController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  String _selectedMethod = 'Bank BCA';
  final List<String> _paymentMethods = [
    'Bank BCA',
    'Bank Mandiri',
    'Bank BRI',
    'Bank BNI',
    'Bank Jatim',
    'GoPay',
    'OVO',
    'DANA',
    'ShopeePay',
  ];

  bool _isConfirmed = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _accountNameController.text = widget.state.currentUser.name;
    widget.state.refreshSellerFinancials();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _amountController.dispose();
    _accountNameController.dispose();
    _accountNumberController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String _formatRupiah(int amount) {
    if (amount == 0) return 'Rp 0';
    final str = amount.toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      buffer.write(str[i]);
      count++;
      if (count % 3 == 0 && i > 0) {
        buffer.write('.');
      }
    }
    return 'Rp ${buffer.toString().split('').reversed.join('')}';
  }

  Future<void> _submitWithdrawal() async {
    setState(() {
      _errorMessage = null;
      _successMessage = null;
    });

    if (!_formKey.currentState!.validate()) return;
    if (!_isConfirmed) {
      setState(() => _errorMessage = 'Harap centang konfirmasi kebenaran data rekening penerima.');
      return;
    }

    final amount = int.tryParse(_amountController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    if (amount <= 0) {
      setState(() => _errorMessage = 'Nominal penarikan harus berupa angka positif.');
      return;
    }

    if (amount < 10000) {
      setState(() => _errorMessage = 'Batas minimum penarikan adalah Rp 10.000.');
      return;
    }

    if (amount > widget.state.sellerAvailableBalance) {
      setState(() => _errorMessage = 'Nominal melebihi saldo tersedia (${_formatRupiah(widget.state.sellerAvailableBalance)}).');
      return;
    }

    final error = await widget.state.requestWithdrawal(
      amount: amount,
      paymentMethod: _selectedMethod,
      accountName: _accountNameController.text.trim(),
      accountNumber: _accountNumberController.text.trim(),
      notes: _notesController.text.trim(),
    );

    if (mounted) {
      if (error == null) {
        setState(() {
          _successMessage = 'Pengajuan penarikan sebesar ${_formatRupiah(amount)} berhasil dikirim dan berstatus Menunggu Diproses.';
          _amountController.clear();
          _notesController.clear();
          _isConfirmed = false;
        });
        _tabController.animateTo(1); // pindah ke riwayat
      } else {
        setState(() => _errorMessage = error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final available = state.sellerAvailableBalance;
    final pending = state.sellerPendingWithdrawal;
    final totalOmset = state.sellerTotalOmset;
    final withdrawals = state.sellerWithdrawals;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680, maxHeight: 760),
        child: Column(
          children: [
            // Modal Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.surfaceBorder)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.account_balance_wallet_rounded, color: AppColors.primary, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Kelola Saldo & Penarikan Stan',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                        ),
                        Text(
                          state.currentUser.storeName.isNotEmpty
                              ? state.currentUser.storeName
                              : 'Stan Kuliner Mahasiswa UPN',
                          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Financial Summary Banner
            Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'SALDO TERSEDIA',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white60, letterSpacing: 0.5),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatRupiah(available),
                          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Dapat ditarik ke rekening / e-wallet',
                          style: TextStyle(fontSize: 11, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  Container(width: 1, height: 48, color: Colors.white24),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'SEDANG DIPROSES',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.amberAccent, letterSpacing: 0.5),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatRupiah(pending),
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.amberAccent),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Total Omset: ${_formatRupiah(totalOmset)}',
                          style: const TextStyle(fontSize: 10, color: Colors.white60),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Tabs
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: AppColors.surfaceBorder)),
              ),
              child: TabBar(
                controller: _tabController,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textMuted,
                indicatorColor: AppColors.primary,
                indicatorWeight: 3,
                labelStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                tabs: [
                  const Tab(text: 'Ajukan Penarikan Baru'),
                  Tab(text: 'Riwayat Penarikan (${withdrawals.length})'),
                ],
              ),
            ),

            // Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildFormTab(context, available),
                  _buildHistoryTab(withdrawals),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormTab(BuildContext context, int available) {
    final isSubmitting = widget.state.isWithdrawalSubmitting;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_errorMessage != null)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.errorLight,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(_errorMessage!, style: const TextStyle(color: AppColors.error, fontSize: 12, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),

            if (_successMessage != null)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.secondaryLight,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.secondary.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline_rounded, color: AppColors.secondary, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(_successMessage!, style: const TextStyle(color: AppColors.secondaryDark, fontSize: 12, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),

            const Text(
              'Nominal Penarikan Saldo',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                prefixText: 'Rp ',
                hintText: 'Minimal 10.000',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Masukkan nominal penarikan';
                final val = int.tryParse(v.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
                if (val < 10000) return 'Nominal penarikan minimal Rp 10.000';
                if (val > available) return 'Nominal tidak boleh melebihi saldo tersedia (${_formatRupiah(available)})';
                return null;
              },
            ),
            const SizedBox(height: 8),

            // Quick nominal chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildQuickAmountChip('Rp 20.000', 20000, available),
                  _buildQuickAmountChip('Rp 50.000', 50000, available),
                  _buildQuickAmountChip('Rp 100.000', 100000, available),
                  _buildQuickAmountChip('Tarik Semua', available, available, isMax: true),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Bank / E-Wallet Selection
            const Text(
              'Metode / Rekening Tujuan',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              initialValue: _selectedMethod,
              decoration: InputDecoration(
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              items: _paymentMethods.map((m) {
                return DropdownMenuItem(value: m, child: Text(m, style: const TextStyle(fontSize: 13)));
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedMethod = val);
              },
            ),
            const SizedBox(height: 14),

            // Account Name
            const Text(
              'Nama Pemilik Rekening / Akun',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _accountNameController,
              decoration: InputDecoration(
                hintText: 'Sesuai buku tabungan / aplikasi e-wallet',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              validator: (v) => v == null || v.trim().isEmpty ? 'Masukkan nama pemilik rekening' : null,
            ),
            const SizedBox(height: 14),

            // Account Number
            const Text(
              'Nomor Rekening / No. HP E-Wallet',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _accountNumberController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                hintText: 'Contoh: 1234567890 atau 081234567890',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              validator: (v) => v == null || v.trim().isEmpty ? 'Masukkan nomor rekening atau e-wallet' : null,
            ),
            const SizedBox(height: 14),

            // Notes
            const Text(
              'Catatan Tambahan (Opsional)',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _notesController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Keterangan khusus pencairan...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            const SizedBox(height: 14),

            // Confirmation Checkbox
            CheckboxListTile(
              value: _isConfirmed,
              onChanged: (val) => setState(() => _isConfirmed = val ?? false),
              title: const Text(
                'Saya telah memeriksa dan memastikan data nomor rekening penerima sudah benar.',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
              ),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 18),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: (available < 10000 || isSubmitting) ? null : _submitWithdrawal,
                icon: isSubmitting
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.send_rounded, size: 18),
                label: Text(
                  isSubmitting ? 'Memproses Pengajuan...' : 'Ajukan Penarikan Sekarang',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAmountChip(String label, int value, int available, {bool isMax = false}) {
    final isApplicable = value > 0 && value <= available;
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: ActionChip(
        label: Text(label),
        onPressed: isApplicable
            ? () {
                setState(() {
                  _amountController.text = value.toString();
                });
              }
            : null,
        backgroundColor: AppColors.canvas,
        labelStyle: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: isApplicable ? AppColors.primary : AppColors.textMuted,
        ),
      ),
    );
  }

  Widget _buildHistoryTab(List<WithdrawalModel> list) {
    if (list.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: AppColors.surfaceMuted,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.history_rounded, size: 36, color: AppColors.textMuted),
              ),
              const SizedBox(height: 16),
              const Text(
                'Belum Ada Riwayat Penarikan',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 6),
              const Text(
                'Pengajuan penarikan dana stan kamu akan tercatat secara transparan di sini.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: list.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, idx) {
        final item = list[idx];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.surfaceBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        _formatRupiah(item.amount),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '• ${item.paymentMethod}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                  _buildStatusBadge(item.status),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Penerima: ${item.accountName} (${_maskAccountNumber(item.accountNumber)})',
                style: const TextStyle(fontSize: 12, color: AppColors.textPrimary, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                'Diajukan pada: ${_formatDate(item.requestedAt)}',
                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
              if (item.rejectionReason != null && item.rejectionReason!.isNotEmpty) ...[
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.errorLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Alasan Penolakan: ${item.rejectionReason}',
                    style: const TextStyle(fontSize: 11, color: AppColors.error, fontWeight: FontWeight.w600),
                  ),
                ),
              ],

              // Simulator buttons for Demo / Testing if pending
              if (item.status == WithdrawalStatus.pending) ...[
                const SizedBox(height: 10),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text('Simulasi Admin: ', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                    TextButton.icon(
                      onPressed: () async {
                        await widget.state.simulateReviewWithdrawal(
                          withdrawalId: item.id!,
                          approve: true,
                        );
                        setState(() {});
                      },
                      icon: const Icon(Icons.check, size: 14, color: AppColors.secondary),
                      label: const Text('Setujui / Transfer', style: TextStyle(fontSize: 11, color: AppColors.secondary)),
                    ),
                    TextButton.icon(
                      onPressed: () async {
                        await widget.state.simulateReviewWithdrawal(
                          withdrawalId: item.id!,
                          approve: false,
                          reason: 'Nomor rekening dan nama bank tidak sesuai.',
                        );
                        setState(() {});
                      },
                      icon: const Icon(Icons.close, size: 14, color: AppColors.error),
                      label: const Text('Tolak & Kembalikan', style: TextStyle(fontSize: 11, color: AppColors.error)),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(WithdrawalStatus status) {
    Color bg;
    Color fg;
    String text;

    switch (status) {
      case WithdrawalStatus.pending:
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFFD97706);
        text = 'Menunggu Diproses';
        break;
      case WithdrawalStatus.approved:
        bg = const Color(0xFFE0F2FE);
        fg = const Color(0xFF0284C7);
        text = 'Disetujui';
        break;
      case WithdrawalStatus.completed:
        bg = AppColors.secondaryLight;
        fg = AppColors.secondaryDark;
        text = 'Selesai Ditransfer';
        break;
      case WithdrawalStatus.rejected:
        bg = AppColors.errorLight;
        fg = AppColors.error;
        text = 'Ditolak';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: fg),
      ),
    );
  }

  String _maskAccountNumber(String acc) {
    if (acc.length <= 4) return acc;
    return '****${acc.substring(acc.length - 4)}';
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
