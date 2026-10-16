import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/cart_item_model.dart';
import '../models/product_rating_model.dart';
import '../providers/app_state.dart';

class RatingDialog extends StatefulWidget {
  final CartItemModel orderItem;
  final String orderCode;
  final String storeId;
  final String storeName;
  final AppState state;
  final ProductRatingModel? existingRating;

  const RatingDialog({
    super.key,
    required this.orderItem,
    required this.orderCode,
    required this.storeId,
    required this.storeName,
    required this.state,
    this.existingRating,
  });

  @override
  State<RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<RatingDialog> {
  int _selectedStars = 5;
  late final TextEditingController _reviewController;
  int _hoveredStars = 0;
  bool _isSubmitting = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _selectedStars = widget.existingRating?.stars ?? 5;
    _reviewController = TextEditingController(text: widget.existingRating?.reviewText ?? '');
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  String _getStarLabel(int stars) {
    switch (stars) {
      case 1:
        return 'Sangat Kecewa (1/5)';
      case 2:
        return 'Kurang Enak (2/5)';
      case 3:
        return 'Cukup Lumayan (3/5)';
      case 4:
        return 'Enak & Puas (4/5)';
      case 5:
        return 'Sangat Enak & Rekomendasi! (5/5)';
      default:
        return 'Pilih Rating Bintang';
    }
  }

  Color _getStarColor(int stars) {
    if (stars <= 2) return const Color(0xFFDC2626);
    if (stars == 3) return const Color(0xFFF59E0B);
    return const Color(0xFFD97706);
  }

  Future<void> _handleSubmit() async {
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final error = await widget.state.submitProductRating(
      productId: widget.orderItem.item.id,
      productName: widget.orderItem.item.name,
      storeId: widget.storeId,
      orderCode: widget.orderCode,
      stars: _selectedStars,
      reviewText: _reviewController.text.trim(),
    );

    if (!mounted) return;

    setState(() => _isSubmitting = false);

    if (error != null) {
      setState(() => _errorMessage = error);
    } else {
      Navigator.pop(context, true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.existingRating != null
                ? 'Penilaian untuk "${widget.orderItem.item.name}" berhasil diperbarui!'
                : 'Terima kasih! Penilaian untuk "${widget.orderItem.item.name}" berhasil dikirim.',
          ),
          backgroundColor: AppColors.secondary,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.orderItem.item;
    final isEditing = widget.existingRating != null;
    final activeStars = _hoveredStars > 0 ? _hoveredStars : _selectedStars;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEF3C7),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.star_rounded, color: Color(0xFFD97706), size: 22),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isEditing ? 'Ubah Penilaian Produk' : 'Beri Penilaian Produk',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                          ),
                          Text(
                            'Pesanan #${widget.orderCode}',
                            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Product Info Card
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.canvas,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.surfaceBorder),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: SizedBox(
                        width: 56,
                        height: 56,
                        child: Image.network(
                          item.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (ctx, err, stack) => Container(
                            color: AppColors.surfaceMuted,
                            child: const Icon(Icons.fastfood, size: 24, color: AppColors.textLight),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.textPrimary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.storeName,
                            style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Jumlah: ${widget.orderItem.quantity} porsi • Rp ${item.price}',
                            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Rating Stars Selector
              Center(
                child: Column(
                  children: [
                    const Text(
                      'Bagaimana kualitas makanan & rasanya?',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        final starIndex = index + 1;
                        final isFilled = starIndex <= activeStars;
                        return MouseRegion(
                          onEnter: (_) => setState(() => _hoveredStars = starIndex),
                          onExit: (_) => setState(() => _hoveredStars = 0),
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedStars = starIndex),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              child: AnimatedScale(
                                duration: const Duration(milliseconds: 150),
                                scale: isFilled ? 1.15 : 1.0,
                                child: Icon(
                                  Icons.star_rounded,
                                  size: 40,
                                  color: isFilled ? const Color(0xFFD97706) : Colors.grey.shade300,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStarColor(activeStars).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _getStarLabel(activeStars),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: _getStarColor(activeStars),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Written Review
              const Text(
                'Ulasan Tertulis (Opsional):',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _reviewController,
                maxLines: 4,
                maxLength: 500,
                style: const TextStyle(fontSize: 13),
                decoration: const InputDecoration(
                  hintText: 'Tuliskan ulasan jujur tentang rasa, bumbu, porsi, atau kemasan makanan ini untuk membantu mahasiswa lain...',
                  contentPadding: EdgeInsets.all(14),
                ),
              ),
              const SizedBox(height: 12),

              // Error display
              if (_errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.errorLight,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.error),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: AppColors.error, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(fontSize: 12, color: AppColors.error, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                    child: const Text('Batal'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    onPressed: _isSubmitting ? null : _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    icon: _isSubmitting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.send_rounded, size: 16),
                    label: Text(
                      isEditing ? 'Perbarui Penilaian' : 'Kirim Penilaian',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
