import 'menu_item_model.dart';
import 'product_rating_model.dart';

/// Model metrik performa masing-masing produk toko
class ProductPerformanceItem {
  final MenuItemModel product;
  final int totalSoldUnits;
  final int totalRevenue;
  final double? averageRating;
  final int reviewCount;

  const ProductPerformanceItem({
    required this.product,
    required this.totalSoldUnits,
    required this.totalRevenue,
    required this.averageRating,
    required this.reviewCount,
  });
}

class SellerRatingAnalytics {
  final double? averageStoreRating;
  final int totalReviews;
  final MenuItemModel? highestRatedProduct;
  final double? highestProductRating;
  final MenuItemModel? lowestRatedProduct;
  final double? lowestProductRating;
  final List<ProductRatingModel> recentReviews;
  final MenuItemModel? bestSellingProduct;
  final int bestSellingCount;
  final List<ProductPerformanceItem> productPerformances;

  const SellerRatingAnalytics({
    required this.averageStoreRating,
    required this.totalReviews,
    this.highestRatedProduct,
    this.highestProductRating,
    this.lowestRatedProduct,
    this.lowestProductRating,
    required this.recentReviews,
    this.bestSellingProduct,
    this.bestSellingCount = 0,
    this.productPerformances = const [],
  });

  bool get hasRatings => averageStoreRating != null && totalReviews > 0;
  bool get hasSales => bestSellingProduct != null && bestSellingCount > 0;
}
