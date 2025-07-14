import 'package:flutter/material.dart';
import '../models/platillo.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _products = [...demoProducts];

  String? _cuponCodigo;
  double? _cuponDescuento;

  List<Product> get productos => _products;

  String? get cuponCodigo => _cuponCodigo;
  double? get cuponDescuento => _cuponDescuento;

  void applyVoucher(double porcentaje, {String? codigo}) {
    _products = _products.map((p) {
      final newPrice = p.price * (1 - porcentaje);
      return p.copyWith(priceWithDiscount: newPrice);
    }).toList();
    _cuponCodigo = codigo;
    _cuponDescuento = porcentaje;
    notifyListeners();
  }

  void removeVoucher() {
    _products = _products
        .map((p) => p.copyWith(priceWithDiscount: null))
        .toList();
    _cuponCodigo = null;
    _cuponDescuento = null;
    notifyListeners();
  }

  void setCuponCodigo(String? codigo) {
    _cuponCodigo = codigo;
    notifyListeners();
  }
}
