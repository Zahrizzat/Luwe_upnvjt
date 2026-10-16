import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_config.dart';
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
  final TextEditingController _notesController = TextEditingController();

  bool _isConfirmed = false;
  String? _errorMessage;
  String? _successMessage;

  int _currentGross = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    widget.state.refreshSellerFinancials();
    _amountController.addListener(_onAmountChanged);
  }

  void _onAmountChanged() {
    final val = int.tryParse(_amountController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    if (val != _currentGross) {
      setState(() {
        _currentGross = val;
      });
    }
  }

  @override
  void dispose() {
    _amountController.removeListener(_onAmountChanged);
    _tabController.dispose();
    _amountController.dispose();
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
      setState(() => _errorMessage = 'Harap centang konfirmasi penarikan dana ke rekening terverifikasi.');
      return;
    }

    final amount = _currentGross;
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

    final user = widget.state.currentUser;
    final error = await widget.state.requestWithdrawal(
      amount: amount,
      paymentMethod: user.bankName,
      accountName: user.bankAccountHolder,
      accountNumber: user.bankAccountNumber,
      notes: _notesController.text.trim(),
    );

    if (mounted) {
      if (error == null) {
        final net = AppConfig.calculateNetWithdrawal(amount);
        setState(() {
          _successMessage = 'Pengajuan penarikan sebesar ${_formatRupiah(amount)} (Bersih ${_formatRupiah(net)}) berhasil dikirim. Status saat ini: Menunggu Verifikasi.';
          _amountController.clear();
          _notesController.clear();
          _isConfirmed = false;
        });
        _tabController.animateTo(1); // pindah ke tab riwayat
      } else {
        setState(() => _errorMessage = error);
      }
    }
  }

  void _showEditBankAccountModal(BuildContext context) {
    final user = widget.state.currentUser;
    final bankCtrl = TextEditingController(text: user.bankName.isNotEmpty ? user.bankName : 'Bank BCA');
    final accNumCtrl = TextEditingController(text: user.bankAccountNumber);
    final accHolderCtrl = TextEditingController(text: user.bankAccountHolder.isNotEmpty ? user.bankAccountHolder : user.name);
    final modalFormKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.account_balance_rounded, color: AppColors.primary, size: 22),
              SizedBox(width: 10),
              Text('Ubah Rekening Pencairan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            ],
          ),
          content: Form(
            key: modalFormKey,
            child: SizedBox(
              width: 420,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Perubahan rekening bank memerlukan verifikasi identitas pemilik stan kuliner kampus.',
                    style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 16),
                  const Text('Nama Bank / E-Wallet', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: bankCtrl,
                    decoration: InputDecoration(
                      hintText: 'Contoh: Bank BCA / Bank Jatim / Mandiri',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Nama bank tidak boleh kosong' : null,
                  ),
                  const SizedBox(height: 12),
                  const Text('Nomor Rekening', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: accNumCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Contoh: 8291039482',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Nomor rekening tidak boleh kosong' : null,
                  ),
                  const SizedBox(height: 12),
                  const Text('Nama Pemilik Rekening', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: accHolderCtrl,
                    decoration: InputDecoration(
                      hintText: 'Harus sesuai identitas verifikasi toko',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Nama pemilik rekening wajib diisi' : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (!modalFormKey.currentState!.validate()) return;
                await widget.state.updateStoreBankAccount(
                  bankName: bankCtrl.text,
                  accountNumber: accNumCtrl.text,
                  accountHolder: accHolderCtrl.text,
                );
                if (ctx.mounted) {
                  Navigator.of(ctx).pop();
                }
                setState(() {});
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Simpan & Verifikasi'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final available = state.sellerAvailableBalance;
    final pending = state.sellerPendingWithdrawal;
    final completed = state.sellerCompletedWithdrawal;
    final totalOmset = state.sellerTotalOmset;
    final withdrawals = state.sellerWithdrawals;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720, maxHeight: 820),
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
                          'Tarik Saldo Pendapatan Toko',
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

            // Financial Summary Banner (4 Separated Categories)
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
                  // Saldo Tersedia
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'SALDO TERSEDIA',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF4ADE80), letterSpacing: 0.5),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatRupiah(available),
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Colors.white),
                        ),
                        const SizedBox(height: 2),
                        const Text('Siap diajukan', style: TextStyle(fontSize: 10, color: Colors.white60)),
                      ],
                    ),
                  ),
                  Container(width: 1, height: 42, color: Colors.white24),
                  const SizedBox(width: 12),

                  // Sedang Diproses
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
                        const Text('Tertahan proses', style: TextStyle(fontSize: 10, color: Colors.white60)),
                      ],
                    ),
                  ),
                  Container(width: 1, height: 42, color: Colors.white24),
                  const SizedBox(width: 12),

                  // Total Penarikan Selesai
                  Expanded(
                    flex: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'PENARIKAN SELESAI',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Color(0xFF38BDF8), letterSpacing: 0.5),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatRupiah(completed),
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF38BDF8)),
                        ),
                        const SizedBox(height: 2),
                        Text('Omzet: ${_formatRupiah(totalOmset)}', style: const TextStyle(fontSize: 10, color: Colors.white60)),
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
    final state = widget.state;
    final user = state.currentUser;
    final isSubmitting = state.isWithdrawalSubmitting;

    final taxFee = AppConfig.calculateTaxFee(_currentGross);
    final adminFee = AppConfig.calculateAdminFee(_currentGross);
    final netAmount = AppConfig.calculateNetWithdrawal(_currentGross);

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

            // 1. Rekening Tujuan Terverifikasi Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.verified_user_rounded, color: Color(0xFF16A34A), size: 18),
                          const SizedBox(width: 8),
                          const Text(
                            'Rekening Tujuan Terverifikasi',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                          ),
                        ],
                      ),
                      TextButton.icon(
                        onPressed: () => _showEditBankAccountModal(context),
                        icon: const Icon(Icons.edit_rounded, size: 14),
                        label: const Text('Ubah Rekening', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.surfaceBorder),
                        ),
                        child: Text(
                          user.bankName.isNotEmpty ? user.bankName : 'Bank BCA',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primary),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.maskedBankAccountNumber,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary, letterSpacing: 1),
                          ),
                          Text(
                            'a.n. ${user.bankAccountHolder.isNotEmpty ? user.bankAccountHolder : user.name}',
                            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Pencairan akan langsung ditransfer ke rekening di atas tanpa perlu memasukkan ulang nomor rekening.',
                    style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // 2. Nominal Penarikan Bruto
            const Text(
              'Nominal Penarikan (Bruto)',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                prefixText: 'Rp ',
                hintText: 'Minimal Rp 10.000',
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

            // Quick chips
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
            const SizedBox(height: 18),

            // 3. Ringkasan Perhitungan Penarikan Bersih & Potongan
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFCBD5E1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.calculate_rounded, size: 16, color: AppColors.primary),
                      SizedBox(width: 6),
                      Text('Ringkasan Perhitungan & Rincian Potongan', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Nominal Penarikan Bruto', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      Text(_formatRupiah(_currentGross), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Text('Potongan Pajak Resmi', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: AppColors.surfaceBorder),
                            ),
                            child: Text(
                              AppConfig.withdrawalTaxStatus,
                              style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: AppColors.textMuted),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        taxFee > 0 ? '- ${_formatRupiah(taxFee)}' : 'Rp 0',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: taxFee > 0 ? AppColors.error : AppColors.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Text('Biaya Administrasi Bank', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: AppColors.surfaceBorder),
                            ),
                            child: Text(
                              AppConfig.withdrawalAdminStatus,
                              style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: AppColors.textMuted),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        adminFee > 0 ? '- ${_formatRupiah(adminFee)}' : 'Rp 0',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: adminFee > 0 ? AppColors.error : AppColors.textSecondary),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Estimasi Jumlah Bersih Diterima', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
                          Text('Nominal Bruto - Potongan Berlaku', style: TextStyle(fontSize: 10, color: AppColors.textMuted)),
                        ],
                      ),
                      Text(
                        _formatRupiah(netAmount),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF16A34A)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // 4. Estimasi Waktu Proses Notice
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline_rounded, color: Color(0xFF2563EB), size: 18),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Estimasi waktu proses verifikasi & pencairan adalah 2–3 hari kerja. Waktu ini merupakan perkiraan operasional pihak kampus, bukan jaminan instan langsung masuk.',
                      style: TextStyle(fontSize: 11, color: Color(0xFF1E40AF), height: 1.3),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Notes
            const Text(
              'Catatan Tambahan (Opsional)',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _notesController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Misal: Pencairan hasil bazar danusan expo fakultas...',
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
                'Saya telah memeriksa rincian nominal bruto, potongan biaya yang berlaku, dan rekening penerima sudah benar.',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textSecondary),
              ),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 16),

            // Submit Button with Debounce Protection
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
                  _currentGross = value;
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
                'Pengajuan penarikan dana stan kamu akan tercatat secara transparan dengan audit trail di sini.',
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
                        _formatRupiah(item.grossAmount),
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
                'Rekening Tujuan: ${item.accountName} (${item.maskedAccountNumber})',
                style: const TextStyle(fontSize: 12, color: AppColors.textPrimary, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    'Pajak: ${_formatRupiah(item.taxFee)} | Admin: ${_formatRupiah(item.adminFee)} | ',
                    style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                  Text(
                    'Bersih: ${_formatRupiah(item.netAmount)}',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Color(0xFF16A34A)),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Waktu Pengajuan: ${_formatDate(item.requestedAt)} • Estimasi 2–3 hari kerja',
                style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
              ),
              if (item.rejectionReason != null && item.rejectionReason!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.errorLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Alasan Penolakan: ${item.rejectionReason}\n(Saldo tertahan telah dikembalikan otomatis ke Saldo Tersedia)',
                    style: const TextStyle(fontSize: 11, color: AppColors.error, fontWeight: FontWeight.w600),
                  ),
                ),
              ],

              // Simulator buttons for Demo / Testing
              if (item.status == WithdrawalStatus.waitingVerification || item.status == WithdrawalStatus.processing) ...[
                const SizedBox(height: 10),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Text('Simulasi Admin: ', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                    if (item.status == WithdrawalStatus.waitingVerification)
                      TextButton.icon(
                        onPressed: () async {
                          await widget.state.simulateReviewWithdrawal(
                            withdrawalId: item.id!,
                            targetStatus: WithdrawalStatus.processing,
                          );
                          setState(() {});
                        },
                        icon: const Icon(Icons.sync_rounded, size: 14, color: Color(0xFF0284C7)),
                        label: const Text('Verifikasi & Proses', style: TextStyle(fontSize: 11, color: Color(0xFF0284C7))),
                      ),
                    if (item.status == WithdrawalStatus.processing)
                      TextButton.icon(
                        onPressed: () async {
                          await widget.state.simulateReviewWithdrawal(
                            withdrawalId: item.id!,
                            targetStatus: WithdrawalStatus.completed,
                          );
                          setState(() {});
                        },
                        icon: const Icon(Icons.check_circle_rounded, size: 14, color: AppColors.secondary),
                        label: const Text('Konfirmasi Pencairan Selesai', style: TextStyle(fontSize: 11, color: AppColors.secondary)),
                      ),
                    TextButton.icon(
                      onPressed: () async {
                        await widget.state.simulateReviewWithdrawal(
                          withdrawalId: item.id!,
                          targetStatus: WithdrawalStatus.rejected,
                          reason: 'Nomor rekening atau identitas pemilik toko tidak cocok.',
                        );
                        setState(() {});
                      },
                      icon: const Icon(Icons.close_rounded, size: 14, color: AppColors.error),
                      label: const Text('Tolak & Kembalikan Saldo', style: TextStyle(fontSize: 11, color: AppColors.error)),
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

    switch (status) {
      case WithdrawalStatus.waitingVerification:
      case WithdrawalStatus.pending:
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFFD97706);
        break;
      case WithdrawalStatus.processing:
      case WithdrawalStatus.approved:
        bg = const Color(0xFFE0F2FE);
        fg = const Color(0xFF0284C7);
        break;
      case WithdrawalStatus.completed:
        bg = AppColors.secondaryLight;
        fg = AppColors.secondaryDark;
        break;
      case WithdrawalStatus.rejected:
        bg = AppColors.errorLight;
        fg = AppColors.error;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        status.label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: fg),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
