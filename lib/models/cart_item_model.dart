import 'menu_item_model.dart';

class CartItemModel {
  final MenuItemModel item;
  int quantity;
  final String selectedSpiceLevel;
  final String note;

  CartItemModel({
    required this.item,
    this.quantity = 1,
    this.selectedSpiceLevel = 'Level 1 (Sedang)',
    this.note = '',
  });

  int get subtotal => item.price * quantity;

  CartItemModel copyWith({
    MenuItemModel? item,
    int? quantity,
    String? selectedSpiceLevel,
    String? note,
  }) {
    return CartItemModel(
      item: item ?? this.item,
      quantity: quantity ?? this.quantity,
      selectedSpiceLevel: selectedSpiceLevel ?? this.selectedSpiceLevel,
      note: note ?? this.note,
    );
  }
}
