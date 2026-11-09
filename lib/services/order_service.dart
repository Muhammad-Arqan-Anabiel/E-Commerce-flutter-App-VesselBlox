import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/order_model.dart';

class OrderService extends ChangeNotifier {
  final List<OrderModel> _orders = [];

  List<OrderModel> get orders => List.unmodifiable(_orders);

  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString('vb_orders');
      if (saved != null && saved.isNotEmpty) {
        final list = jsonDecode(saved) as List<dynamic>;
        _orders.clear();
        for (final item in list) {
          _orders.add(OrderModel.fromJson(item as Map<String, dynamic>));
        }
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> refreshOrders() async {
    await init();
  }

  Future<void> _save() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final list = _orders.map((o) => o.toJson()).toList();
      await prefs.setString('vb_orders', jsonEncode(list));
    } catch (_) {}
  }

  static String generateOrderId() {
    final stamp = DateTime.now().millisecondsSinceEpoch.toRadixString(36).toUpperCase();
    final rand = Random().nextInt(1296).toRadixString(36).toUpperCase().padLeft(2, '0');
    final suffix = stamp.length >= 4 ? stamp.substring(stamp.length - 4) : stamp;
    return 'VB-$suffix$rand';
  }

  Future<OrderModel> createOrder({
    required String method,
    required int amountRobux,
    required int beforeTaxRobux,
    required String currency,
    required double subtotal,
    required double discount,
    required double total,
    required String robloxUsername,
    int? robloxId,
    String? robloxAvatar,
    String? email,
    String? instagram,
    String? notes,
    String? gamepassUrl,
    String? giftGame,
    String? giftItem,
    bool isCart = false,
    List<CartItemSummary>? cartItems,
    required String paymentMethod,
    String? proofPath,
    String lang = 'id',
  }) async {
    final newOrderId = generateOrderId();
    final now = DateTime.now();
    final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    final initialMessages = [
      TicketMessage(
        sender: 'system',
        text: lang == 'id'
            ? 'Tiket dibuka. Bukti pembayaran sudah diterima, staf akan segera memproses pesananmu.'
            : 'Ticket opened. Payment proof received, our staff is taking your order.',
        time: timeStr,
      ),
      TicketMessage(
        sender: 'staff',
        text: lang == 'id'
            ? 'Halo kak @$robloxUsername! Bukti pembayaran sudah kami terima dan sedang diverifikasi oleh staf VesselBlox. Mohon ditunggu sebentar ya kak!'
            : 'Hello @$robloxUsername! We have received your payment proof and our team is verifying it. Please hold on!',
        time: timeStr,
      ),
    ];

    final order = OrderModel(
      orderId: newOrderId,
      method: method,
      amountRobux: amountRobux,
      beforeTaxRobux: beforeTaxRobux,
      currency: currency,
      subtotal: subtotal,
      discount: discount,
      total: total,
      robloxUsername: robloxUsername,
      robloxId: robloxId,
      robloxAvatar: robloxAvatar,
      email: email,
      instagram: instagram,
      notes: notes,
      gamepassUrl: gamepassUrl,
      giftGame: giftGame,
      giftItem: giftItem,
      isCart: isCart,
      cartItems: cartItems,
      paymentMethod: paymentMethod,
      proofPath: proofPath,
      createdAt: now,
      messages: initialMessages,
    );

    _orders.insert(0, order);
    notifyListeners();
    await _save();

    // Async sync to Firebase Firestore REST API
    _syncToFirestore(order);

    return order;
  }

  OrderModel? getOrderById(String orderId) {
    try {
      return _orders.firstWhere(
        (o) => o.orderId.toUpperCase().trim() == orderId.toUpperCase().trim(),
      );
    } catch (_) {
      return null;
    }
  }

  Future<OrderModel?> getOrder(String orderId) async {
    final local = getOrderById(orderId);
    if (local != null) return local;

    // Try fetching from Firestore REST if not found locally
    try {
      final clean = orderId.toUpperCase().trim();
      final url = Uri.parse(
        'https://firestore.googleapis.com/v1/projects/vesselblox-d23d1/databases/(default)/documents/orders/$clean',
      );
      final res = await http.get(url).timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final fields = data['fields'] as Map<String, dynamic>?;
        if (fields != null) {
          final fetched = OrderModel(
            orderId: clean,
            method: fields['method']?['stringValue'] ?? 'gamepass',
            amountRobux: int.tryParse(fields['amountRobux']?['integerValue'] ?? '0') ?? 0,
            beforeTaxRobux: int.tryParse(fields['beforeTaxRobux']?['integerValue'] ?? '0') ?? 0,
            currency: fields['currency']?['stringValue'] ?? 'IDR',
            subtotal: (fields['subtotal']?['doubleValue'] ?? 0.0).toDouble(),
            discount: (fields['discount']?['doubleValue'] ?? 0.0).toDouble(),
            total: (fields['total']?['doubleValue'] ?? 0.0).toDouble(),
            robloxUsername: fields['robloxUsername']?['stringValue'] ?? 'Player',
            status: fields['status']?['stringValue'] ?? 'pending',
            paymentMethod: fields['paymentMethod']?['stringValue'] ?? 'Transfer Bank',
            createdAt: DateTime.now(),
            messages: [
              TicketMessage(
                sender: 'system',
                text: 'Tiket dipulihkan dari server.',
                time: 'Baru saja',
              ),
            ],
          );
          _orders.insert(0, fetched);
          notifyListeners();
          _save();
          return fetched;
        }
      }
    } catch (_) {}

    return null;
  }

  void addMessageToOrder(String orderId, String text, String sender) {
    final index = _orders.indexWhere((o) => o.orderId == orderId);
    if (index >= 0) {
      final now = DateTime.now();
      final timeStr = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
      _orders[index].messages.add(
        TicketMessage(sender: sender, text: text, time: timeStr),
      );
      notifyListeners();
      _save();

      // If buyer sent message, simulate staff auto-reply after 3.5 seconds
      if (sender == 'buyer') {
        Future.delayed(const Duration(milliseconds: 3500), () {
          final currentIdx = _orders.indexWhere((o) => o.orderId == orderId);
          if (currentIdx >= 0) {
            final replyTime = DateTime.now();
            final rTimeStr = '${replyTime.hour.toString().padLeft(2, '0')}:${replyTime.minute.toString().padLeft(2, '0')}';
            _orders[currentIdx].messages.add(
              TicketMessage(
                sender: 'staff',
                text: 'Baik kak, pesan Anda sudah tercatat oleh staf admin kami yang bertugas. Pesanan akan diselesaikan secepatnya!',
                time: rTimeStr,
              ),
            );
            notifyListeners();
            _save();
          }
        });
      }
    }
  }

  Future<void> _syncToFirestore(OrderModel order) async {
    try {
      final url = Uri.parse(
        'https://firestore.googleapis.com/v1/projects/vesselblox-d23d1/databases/(default)/documents/orders?documentId=${order.orderId}',
      );
      await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'fields': {
            'orderId': {'stringValue': order.orderId},
            'method': {'stringValue': order.method},
            'amountRobux': {'integerValue': order.amountRobux.toString()},
            'currency': {'stringValue': order.currency},
            'total': {'doubleValue': order.total},
            'robloxUsername': {'stringValue': order.robloxUsername},
            'status': {'stringValue': order.status},
            'paymentMethod': {'stringValue': order.paymentMethod},
            'createdAt': {'timestampValue': order.createdAt.toUtc().toIso8601String()},
          }
        }),
      ).timeout(const Duration(seconds: 4));
    } catch (_) {
      // Offline fallback
    }
  }
}
