import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game_model.dart';

class CartService extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);
  int get itemCount => _items.length;
  int get totalQuantity => _items.fold(0, (sum, item) => sum + item.quantity);
  int get totalRobux => _items.fold(0, (sum, item) => sum + (item.passRobux * item.quantity));

  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString('vb_cart');
      if (saved != null && saved.isNotEmpty) {
        final list = jsonDecode(saved) as List<dynamic>;
        _items.clear();
        for (final item in list) {
          _items.add(CartItem.fromJson(item as Map<String, dynamic>));
        }
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = _items.map((i) => i.toJson()).toList();
      await prefs.setString('vb_cart', jsonEncode(list));
    } catch (_) {}
  }

  void addToCart(RobloxGame game, GamepassItem pass) {
    final index = _items.indexWhere((i) => i.passId == pass.id);
    if (index >= 0) {
      _items[index].quantity += 1;
    } else {
      _items.add(
        CartItem(
          gameId: game.id,
          gameName: game.name,
          passId: pass.id,
          passName: pass.name,
          passRobux: pass.robux,
          passIcon: pass.icon,
          quantity: 1,
        ),
      );
    }
    notifyListeners();
    _save();
  }

  void updateQuantity(String passId, int quantity) {
    if (quantity <= 0) {
      removeFromCart(passId);
      return;
    }
    final index = _items.indexWhere((i) => i.passId == passId);
    if (index >= 0) {
      _items[index].quantity = quantity;
      notifyListeners();
      _save();
    }
  }

  void removeFromCart(String passId) {
    _items.removeWhere((i) => i.passId == passId);
    notifyListeners();
    _save();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
    _save();
  }

  CartItem? getItemInCart(String passId) {
    try {
      return _items.firstWhere((i) => i.passId == passId);
    } catch (_) {
      return null;
    }
  }
}
