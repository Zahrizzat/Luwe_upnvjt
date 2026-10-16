import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../models/user_model.dart';
import '../../providers/app_state.dart';

class StoreVerificationScreen extends StatefulWidget {
  final AppState state;

  const StoreVerificationScreen({super.key, required this.state});

  @override
  State<StoreVerificationScreen> createState() => _StoreVerificationScreenState();
}

class _StoreVerificationScreenState extends State<StoreVerificationScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _storeNameCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _phoneCtrl;
  late String _selectedLocation;
  String? _selectedPhoto;
  bool _isLoading = false;
  bool _isEditing = false;

  final List<String> _campusLocations = [
    'Kantin Giri Reksa • Samping FIK',
    'Kantin Giri Santoso',
    'Gedung FIK (Fakultas Ilmu Komputer) Lt. 1',
    'Gedung FT (Fakultas Teknik) Barat',
    'Gedung FEB (Fakultas Ekonomi & Bisnis)',
    'Gedung FISIP Kantin Timur',
    'Gedung FAD (Desain & Seni)',
    'Pusat Kegiatan Mahasiswa (PKM) UPNVJT',
  ];

  final List<String> _samplePhotos = [
    'https://images.unsplash.com/photo-1555396273-367ea4eb4db5?auto=format&fit=crop&w=600&q=80',
    'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4?auto=format&fit=crop&w=600&q=80',
    'https://images.unsplash.com/photo-1544005313-94ddf0286df2?auto=format&fit=crop&w=600&q=80',
    'https://images.unsplash.com/photo-1556679343-c7306c1976bc?auto=format&fit=crop&w=600&q=80',
  ];

  @override
  void initState() {
    super.initState();
    final user = widget.state.currentUser;
    _storeNameCtrl = TextEditingController(text: user.storeName);
    _descCtrl = TextEditingController(text: user.storeDescription ?? '');
    _phoneCtrl = TextEditingController(text: user.storeContactPhone ?? user.phoneNumber);
    _selectedLocation = user.storeLocation.isNotEmpty && _campusLocations.contains(user.storeLocation)
        ? user.storeLocation
        : _campusLocations.first;
    _selectedPhoto = _samplePhotos.first;
  }

  @override
  void dispose() {
    _storeNameCtrl.dispose();
    _descCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final error = await widget.state.submitStoreApplication(
      storeName: _storeNameCtrl.text.trim(),
      storeLocation: _selectedLocation,
      description: _descCtrl.text.trim(),
      contactPhone: _phoneCtrl.text.trim(),
      storePhoto: _selectedPhoto,
    );

    if (mounted) {
      setState(() {
        _isLoading = false;
        _isEditing = false;
      });

      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: AppColors.error),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pengajuan toko berhasil dikirim! Menunggu verifikasi tim kampus.'),
            backgroundColor: AppColors.primary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = widget.state.currentUser;
    final status = user.verificationStatus;

    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Verifikasi & Pendaftaran Toko Kampus',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: _buildBody(status),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(StoreVerificationStatus status) {
    if (_isEditing || status == StoreVerificationStatus.none) {
      return _buildFormView();
    }

    switch (status) {
      case StoreVerificationStatus.pending:
        return _buildPendingView();
      case StoreVerificationStatus.approved:
        return _buildApprovedView();
      case StoreVerificationStatus.rejected:
        return _buildRejectedView();
      case StoreVerificationStatus.none:
        return _buildFormView();
    }
  }

  // 1. Form View (Belum Mengajukan atau Sedang Edit Ulang)
  Widget _buildFormView() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.surfaceBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.storefront_rounded, color: AppColors.primary, size: 28),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Formulir Pengajuan Stan Kuliner UPNVJT',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Daftarkan stan kantin atau usaha kuliner mahasiswa Anda untuk diverifikasi oleh pengelola.',
                        style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 20),

            // Nama Toko
            const Text('Nama Stan / Toko Kuliner *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            TextFormField(
              controller: _storeNameCtrl,
              decoration: const InputDecoration(
                hintText: 'Contoh: Warung Sambal UPN, Kopi Mahasiswa FIK',
                prefixIcon: Icon(Icons.badge_outlined, size: 20),
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Nama toko wajib diisi' : null,
            ),
            const SizedBox(height: 18),

            // Lokasi Stan di Lingkungan Kampus
            const Text('Area / Lokasi Stan di Kampus UPNVJT *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              initialValue: _selectedLocation,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.place_outlined, size: 20),
              ),
              items: _campusLocations.map((loc) => DropdownMenuItem(value: loc, child: Text(loc, style: const TextStyle(fontSize: 13)))).toList(),
              onChanged: (v) {
                if (v != null) setState(() => _selectedLocation = v);
              },
            ),
            const SizedBox(height: 18),

            // Kontak WhatsApp Penjual
            const Text('Kontak WhatsApp Aktif Pemilik Stan *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            TextFormField(
              controller: _phoneCtrl,
              decoration: const InputDecoration(
                hintText: 'Contoh: 081234567890',
                prefixIcon: Icon(Icons.phone_outlined, size: 20),
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Nomor telepon wajib diisi' : null,
            ),
            const SizedBox(height: 18),

            // Deskripsi Stan
            const Text('Deskripsi Usaha & Menu Utama *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            TextFormField(
              controller: _descCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Jelaskan menu yang dijual, jam buka stan, dan keunikan kuliner Anda...',
              ),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Deskripsi toko wajib diisi' : null,
            ),
            const SizedBox(height: 20),

            // Pilihan Foto Stan / Banner
            const Text('Foto Representatif Stan / Kuliner', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            Row(
              children: _samplePhotos.map((url) {
                final isSelected = _selectedPhoto == url;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _selectedPhoto = url),
                    child: Container(
                      height: 70,
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? AppColors.primary : AppColors.surfaceBorder,
                          width: isSelected ? 3 : 1,
                        ),
                        image: DecorationImage(image: NetworkImage(url), fit: BoxFit.cover),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 28),

            // Buttons
            Row(
              children: [
                if (_isEditing)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => setState(() => _isEditing = false),
                      child: const Text('Batal'),
                    ),
                  ),
                if (_isEditing) const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _handleSubmit,
                    icon: _isLoading
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : const Icon(Icons.send_rounded, size: 18),
                    label: Text(
                      _isLoading ? 'Mengirim Pengajuan...' : 'Kirim Pengajuan Toko',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 2. Pending Verification View
  Widget _buildPendingView() {
    final user = widget.state.currentUser;

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFFD54F)),
            ),
            child: Row(
              children: [
                const Icon(Icons.hourglass_top_rounded, color: Color(0xFFFFA000), size: 32),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Status: Menunggu Verifikasi Kampus',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFF795548)),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Pengajuan toko Anda telah berhasil dikirim dan sedang dalam proses peninjauan oleh tim kemahasiswaan & kantin UPNVJT (estimasi 1x24 jam).',
                        style: TextStyle(fontSize: 12, color: Color(0xFF8D6E63), height: 1.4),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Detail Pengajuan
          const Text('Rincian Data Toko yang Diajukan:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          _buildInfoRow('Nama Stan', user.storeName),
          _buildInfoRow('Lokasi Stan', user.storeLocation),
          _buildInfoRow('WhatsApp', user.storeContactPhone ?? user.phoneNumber),
          _buildInfoRow('Deskripsi', user.storeDescription ?? '-'),

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),

          const Text(
            'Catatan Hak Akses:',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 6),
          const Text(
            'Selama menunggu verifikasi, akun Anda tetap aktif sebagai Pembeli. Anda belum dapat mengelola menu atau dashboard penjual hingga status disetujui.',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4),
          ),

          const SizedBox(height: 24),

          // Demo simulation tools for quick testing
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.canvas,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.surfaceBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.admin_panel_settings_rounded, size: 16, color: AppColors.textMuted),
                    SizedBox(width: 6),
                    Text(
                      'PENGUJIAN & SIMULASI KEPUTUSAN ADMIN',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textMuted),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () async {
                          setState(() => _isLoading = true);
                          await widget.state.reviewCurrentStoreApplication(true);
                          if (mounted) setState(() => _isLoading = false);
                        },
                        icon: const Icon(Icons.check_circle_rounded, size: 16),
                        label: const Text('Simulasi Setujui Toko', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: const BorderSide(color: AppColors.error),
                        ),
                        onPressed: () async {
                          setState(() => _isLoading = true);
                          await widget.state.reviewCurrentStoreApplication(
                            false,
                            reason: 'Lokasi stan belum terdaftar dalam denah resmi Kantin Kampus UPNVJT. Harap perbarui data stan Anda.',
                          );
                          if (mounted) setState(() => _isLoading = false);
                        },
                        icon: const Icon(Icons.cancel_rounded, size: 16),
                        label: const Text('Simulasi Tolak Toko', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 3. Approved View
  Widget _buildApprovedView() {
    final user = widget.state.currentUser;

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.cream.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.goldenYellow),
            ),
            child: Row(
              children: [
                const Icon(Icons.verified_rounded, color: AppColors.primaryRed, size: 36),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Status: Toko Disetujui & Terverifikasi!',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.primaryRed),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Selamat! Stan kuliner ${user.storeName} telah resmi disetujui. Anda kini memiliki hak akses penuh untuk mengelola katalog menu dan pesanan masuk.',
                        style: const TextStyle(fontSize: 12, color: AppColors.accentOrange, height: 1.4, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Detail Toko
          const Text('Informasi Stan Resmi:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          _buildInfoRow('Nama Stan', user.storeName),
          _buildInfoRow('Lokasi Kampus', user.storeLocation),
          _buildInfoRow('Kontak WhatsApp', user.storeContactPhone ?? user.phoneNumber),

          const SizedBox(height: 28),

          // Tombol Masuk ke Mode Penjual
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () {
                widget.state.switchToSellerMode();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Beralih ke Mode Penjual: ${user.storeName}'),
                    backgroundColor: AppColors.primary,
                  ),
                );
              },
              icon: const Icon(Icons.storefront_rounded, size: 20),
              label: const Text(
                'Masuk ke Mode Penjual',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 4. Rejected View
  Widget _buildRejectedView() {
    final user = widget.state.currentUser;

    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEBEE),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFEF9A9A)),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 36),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Status: Pengajuan Toko Ditolak',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Color(0xFFB71C1C)),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        user.rejectionReason ?? 'Dokumen pendukung atau lokasi stan belum terdaftar di pengelola kantin kampus.',
                        style: const TextStyle(fontSize: 13, color: Color(0xFFC62828), height: 1.4, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          const Text(
            'Jangan khawatir! Anda dapat memperbaiki data stan kuliner dan mengirimkan pengajuan ulang verifikasi.',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
          ),
          const SizedBox(height: 24),

          // Tombol Perbaiki & Ajukan Ulang
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () {
                setState(() => _isEditing = true);
              },
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text(
                'Perbaiki & Ajukan Ulang Verifikasi',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: AppColors.textMuted, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}
