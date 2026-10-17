import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../providers/app_state.dart';

class EditStoreProfileDialog extends StatefulWidget {
  final AppState state;

  const EditStoreProfileDialog({super.key, required this.state});

  @override
  State<EditStoreProfileDialog> createState() => _EditStoreProfileDialogState();
}

class _EditStoreProfileDialogState extends State<EditStoreProfileDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _sellerNameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _avatarCtrl;

  late TextEditingController _storeNameCtrl;
  late TextEditingController _storeLocationCtrl;
  late TextEditingController _storeDescCtrl;
  late TextEditingController _storeLogoCtrl;
  late TextEditingController _storeBannerCtrl;

  String _selectedFaculty = 'Fakultas Ilmu Komputer (FIK)';
  bool _isLoading = false;

  static const List<String> upnFaculties = [
    'Fakultas Ilmu Komputer (FIK)',
    'Fakultas Ekonomi dan Bisnis (FEB)',
    'Fakultas Teknik (FT)',
    'Fakultas Pertanian (FP)',
    'Fakultas Arsitektur dan Desain (FAD)',
    'Fakultas Ilmu Sosial dan Ilmu Politik (FISIP)',
    'Fakultas Hukum (FH)',
    'Fakultas Kedokteran (FK)',
  ];

  @override
  void initState() {
    super.initState();
    final user = widget.state.currentUser;
    final store = widget.state.currentSellerStore;

    _sellerNameCtrl = TextEditingController(text: user.name);
    _phoneCtrl = TextEditingController(text: user.phoneNumber);
    _avatarCtrl = TextEditingController(text: user.avatarUrl);

    _storeNameCtrl = TextEditingController(text: store?.name ?? user.storeName);
    _storeLocationCtrl = TextEditingController(text: store?.location ?? user.storeLocation);
    _storeDescCtrl = TextEditingController(text: store?.description ?? user.storeDescription ?? '');
    _storeLogoCtrl = TextEditingController(text: store?.logoUrl ?? user.avatarUrl);
    _storeBannerCtrl = TextEditingController(text: store?.bannerUrl ?? '');

    final currentFac = store?.faculty ?? user.faculty;
    final match = upnFaculties.firstWhere(
      (f) => f.toLowerCase() == currentFac.toLowerCase() ||
          f.toLowerCase().contains(currentFac.toLowerCase()) ||
          currentFac.toLowerCase().contains(f.toLowerCase()),
      orElse: () => upnFaculties.first,
    );
    _selectedFaculty = match;
  }

  @override
  void dispose() {
    _sellerNameCtrl.dispose();
    _phoneCtrl.dispose();
    _avatarCtrl.dispose();
    _storeNameCtrl.dispose();
    _storeLocationCtrl.dispose();
    _storeDescCtrl.dispose();
    _storeLogoCtrl.dispose();
    _storeBannerCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final ok = await widget.state.updateSellerStoreProfile(
      sellerName: _sellerNameCtrl.text.trim(),
      phoneNumber: _phoneCtrl.text.trim(),
      avatarUrl: _avatarCtrl.text.trim(),
      storeName: _storeNameCtrl.text.trim(),
      storeLocation: _storeLocationCtrl.text.trim(),
      storeDescription: _storeDescCtrl.text.trim(),
      storeFaculty: _selectedFaculty,
      storeLogoUrl: _storeLogoCtrl.text.trim(),
      storeBannerUrl: _storeBannerCtrl.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (ok) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Informasi toko & profil berhasil diperbarui!'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gagal memperbarui informasi. Silakan periksa kembali.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640, maxHeight: 760),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Scaffold(
            backgroundColor: AppColors.canvas,
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              title: const Text(
                'Edit Profil Penjual & Informasi Toko',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
              centerTitle: false,
              actions: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                ),
              ],
            ),
            body: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section 1: Profil Penjual
                    _buildSectionHeader(
                      icon: Icons.person_rounded,
                      title: 'Informasi Akun Penjual',
                      subtitle: 'Identitas civitas akademika pengelola toko',
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.surfaceBorder),
                      ),
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _sellerNameCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Nama Lengkap Penjual *',
                              prefixIcon: Icon(Icons.badge_outlined, size: 20),
                            ),
                            validator: (val) => (val == null || val.trim().isEmpty) ? 'Nama tidak boleh kosong' : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _phoneCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Nomor WhatsApp / HP Aktif *',
                              prefixIcon: Icon(Icons.phone_android_rounded, size: 20),
                            ),
                            validator: (val) => (val == null || val.trim().isEmpty) ? 'Nomor HP tidak boleh kosong' : null,
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _avatarCtrl,
                            decoration: const InputDecoration(
                              labelText: 'URL Foto Profil (Avatar)',
                              prefixIcon: Icon(Icons.image_outlined, size: 20),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Section 2: Informasi Toko / Usaha Mahasiswa
                    _buildSectionHeader(
                      icon: Icons.storefront_rounded,
                      title: 'Informasi Toko Usaha / Danusan Mahasiswa',
                      subtitle: 'Informasi yang tampil di beranda dan detail toko pembeli',
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.surfaceBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            controller: _storeNameCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Nama Toko / Usaha Mahasiswa *',
                              hintText: 'Contoh: Danus SIFO, Danus FIK, Danus FEB',
                              prefixIcon: Icon(Icons.storefront_rounded, size: 20),
                            ),
                            validator: (val) => (val == null || val.trim().isEmpty) ? 'Nama toko tidak boleh kosong' : null,
                          ),
                          const SizedBox(height: 14),

                          // Fakultas Asal Usaha
                          const Text(
                            'Fakultas Asal Usaha Mahasiswa *',
                            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            initialValue: _selectedFaculty,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.account_balance_rounded, size: 20),
                              contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            ),
                            items: upnFaculties.map((fac) {
                              return DropdownMenuItem(
                                value: fac,
                                child: Text(fac, style: const TextStyle(fontSize: 13)),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedFaculty = val);
                            },
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            '*Menunjukkan fakultas asal usaha mahasiswa, bukan alamat pengiriman',
                            style: TextStyle(fontSize: 11, color: AppColors.textMuted, fontStyle: FontStyle.italic),
                          ),
                          const SizedBox(height: 14),

                          // Titik Lokasi Berjualan
                          TextFormField(
                            controller: _storeLocationCtrl,
                            decoration: const InputDecoration(
                              labelText: 'Titik Lokasi Berjualan di Kampus *',
                              hintText: 'Contoh: Selasar Depan Lab Gedung FIK Lt. 1',
                              prefixIcon: Icon(Icons.place_rounded, size: 20),
                            ),
                            validator: (val) => (val == null || val.trim().isEmpty) ? 'Lokasi berjualan tidak boleh kosong' : null,
                          ),
                          const SizedBox(height: 14),

                          // Deskripsi Toko
                          TextFormField(
                            controller: _storeDescCtrl,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              labelText: 'Deskripsi Toko / Danusan *',
                              hintText: 'Jelaskan produk kuliner andalan atau kegiatan danusan mahasiswa...',
                              alignLabelWithHint: true,
                            ),
                            validator: (val) => (val == null || val.trim().isEmpty) ? 'Deskripsi tidak boleh kosong' : null,
                          ),
                          const SizedBox(height: 14),

                          // Logo URL
                          TextFormField(
                            controller: _storeLogoCtrl,
                            decoration: const InputDecoration(
                              labelText: 'URL Logo Toko',
                              prefixIcon: Icon(Icons.photo_size_select_actual_outlined, size: 20),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Banner URL
                          TextFormField(
                            controller: _storeBannerCtrl,
                            decoration: const InputDecoration(
                              labelText: 'URL Foto Sampul / Banner Toko',
                              prefixIcon: Icon(Icons.panorama_outlined, size: 20),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Actions Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        OutlinedButton(
                          onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          child: const Text('Batal'),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton.icon(
                          onPressed: _isLoading ? null : _handleSave,
                          icon: _isLoading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                )
                              : const Icon(Icons.check_rounded, size: 18),
                          label: Text(_isLoading ? 'Menyimpan...' : 'Simpan Perubahan'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader({required IconData icon, required String title, required String subtitle}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
