class TicketMessage {
  final String sender; // 'system' | 'staff' | 'buyer'
  final String text;
  final String time;

  TicketMessage({
    required this.sender,
    required this.text,
    required this.time,
  });

  Map<String, dynamic> toJson() => {
    'sender': sender,
    'text': text,
    'time': time,
  };

  factory TicketMessage.fromJson(Map<String, dynamic> json) => TicketMessage(
    sender: json['sender'] ?? 'system',
    text: json['text'] ?? '',
    time: json['time'] ?? 'Just now',
  );
}

class CartItemSummary {
  final String passId;
  final String passName;
  final String gameName;
  final int passRobux;
  final int quantity;
  final String? passIcon;

  CartItemSummary({
    required this.passId,
    required this.passName,
    required this.gameName,
    required this.passRobux,
    required this.quantity,
    this.passIcon,
  });

  Map<String, dynamic> toJson() => {
    'passId': passId,
    'passName': passName,
    'gameName': gameName,
    'passRobux': passRobux,
    'quantity': quantity,
    'passIcon': passIcon,
  };

  factory CartItemSummary.fromJson(Map<String, dynamic> json) => CartItemSummary(
    passId: json['passId'] ?? '',
    passName: json['passName'] ?? '',
    gameName: json['gameName'] ?? '',
    passRobux: json['passRobux'] ?? 0,
    quantity: json['quantity'] ?? 1,
    passIcon: json['passIcon'],
  );
}

class OrderModel {
  final String orderId;
  final String method; // 'gamepass' | 'gifting' | 'groupfunds'
  final int amountRobux;
  final int beforeTaxRobux;
  final String currency; // 'IDR' | 'USD'
  final double subtotal;
  final double discount;
  final double total;
  final String robloxUsername;
  final int? robloxId;
  final String? robloxAvatar;
  final String? email;
  final String? instagram;
  final String? notes;
  final String? gamepassUrl;
  final String? giftGame;
  final String? giftItem;
  final bool isCart;
  final List<CartItemSummary>? cartItems;
  final String status; // 'pending_verification' | 'processing' | 'delivered' | 'completed'
  final String paymentMethod;
  final String? proofPath;
  final DateTime createdAt;
  final List<TicketMessage> messages;

  OrderModel({
    required this.orderId,
    required this.method,
    required this.amountRobux,
    required this.beforeTaxRobux,
    required this.currency,
    required this.subtotal,
    required this.discount,
    required this.total,
    required this.robloxUsername,
    this.robloxId,
    this.robloxAvatar,
    this.email,
    this.instagram,
    this.notes,
    this.gamepassUrl,
    this.giftGame,
    this.giftItem,
    this.isCart = false,
    this.cartItems,
    this.status = 'pending_verification',
    required this.paymentMethod,
    this.proofPath,
    required this.createdAt,
    required this.messages,
  });

  Map<String, dynamic> toJson() => {
    'orderId': orderId,
    'method': method,
    'amountRobux': amountRobux,
    'beforeTaxRobux': beforeTaxRobux,
    'currency': currency,
    'subtotal': subtotal,
    'discount': discount,
    'total': total,
    'robloxUsername': robloxUsername,
    'robloxId': robloxId,
    'robloxAvatar': robloxAvatar,
    'email': email,
    'instagram': instagram,
    'notes': notes,
    'gamepassUrl': gamepassUrl,
    'giftGame': giftGame,
    'giftItem': giftItem,
    'isCart': isCart,
    'cartItems': cartItems?.map((e) => e.toJson()).toList(),
    'status': status,
    'paymentMethod': paymentMethod,
    'proofPath': proofPath,
    'createdAt': createdAt.toIso8601String(),
    'messages': messages.map((m) => m.toJson()).toList(),
  };

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
    orderId: json['orderId'] ?? '',
    method: json['method'] ?? 'gamepass',
    amountRobux: json['amountRobux'] ?? 0,
    beforeTaxRobux: json['beforeTaxRobux'] ?? 0,
    currency: json['currency'] ?? 'IDR',
    subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
    discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
    total: (json['total'] as num?)?.toDouble() ?? 0.0,
    robloxUsername: json['robloxUsername'] ?? '',
    robloxId: json['robloxId'],
    robloxAvatar: json['robloxAvatar'],
    email: json['email'],
    instagram: json['instagram'],
    notes: json['notes'],
    gamepassUrl: json['gamepassUrl'],
    giftGame: json['giftGame'],
    giftItem: json['giftItem'],
    isCart: json['isCart'] ?? false,
    cartItems: (json['cartItems'] as List<dynamic>?)
        ?.map((e) => CartItemSummary.fromJson(e as Map<String, dynamic>))
        .toList(),
    status: json['status'] ?? 'pending_verification',
    paymentMethod: json['paymentMethod'] ?? 'qris',
    proofPath: json['proofPath'],
    createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    messages: (json['messages'] as List<dynamic>?)
            ?.map((m) => TicketMessage.fromJson(m as Map<String, dynamic>))
            .toList() ??
        [],
  );

  String statusLabel(String lang) {
    final isId = lang == 'id';
    switch (status) {
      case 'completed':
        return isId ? 'Selesai' : 'Completed';
      case 'processing':
        return isId ? 'Diproses' : 'Processing';
      case 'awaiting_delivery':
        return isId ? 'Menunggu Pengiriman' : 'Awaiting Delivery';
      case 'cancelled':
        return isId ? 'Dibatalkan' : 'Cancelled';
      default:
        return isId ? 'Menunggu Verifikasi' : 'Pending Verification';
    }
  }
}
