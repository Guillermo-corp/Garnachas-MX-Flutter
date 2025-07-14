import 'package:flutter/material.dart';
import '../models/platillo.dart';

final List<Product> cartItems = [];
final ValueNotifier<int> cartItemCount = ValueNotifier<int>(0);

void _updateCartCount() {
  cartItemCount.value = cartItems.fold(0, (sum, item) => sum + item.quantity);
}

void addToCart(Product product) {
  final index = cartItems.indexWhere((item) => item.id == product.id);
  if (index != -1) {
    cartItems[index].quantity += 1;
  } else {
    final newProduct = product.copyWith(quantity: 1);
    cartItems.add(newProduct);
  }
  _updateCartCount();
}

void removeFromCart(String productId) {
  cartItems.removeWhere((item) => item.id == productId);
  _updateCartCount();
}

void clearCart() {
  cartItems.clear();
  _updateCartCount();
}

int getTotalCartItems() {
  return cartItemCount.value;
}

int getCartTotalInCents() {
  final total = cartItems.fold(0.0, (sum, item) => sum + item.price * item.quantity);
  return (total * 100).toInt();
}

void applyDiscountToCartItems(double porcentaje) {
  for (int i = 0; i < cartItems.length; i++) {
    final item = cartItems[i];
    cartItems[i] = item.copyWith(
      priceWithDiscount: item.price * (1 - porcentaje),
    );
  }
}

void removeDiscountFromCartItems() {
  for (int i = 0; i < cartItems.length; i++) {
    final item = cartItems[i];
    cartItems[i] = item.copyWith(priceWithDiscount: null);
  }
}
