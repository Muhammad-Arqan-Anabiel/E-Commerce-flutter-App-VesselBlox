import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/order_model.dart';
import '../services/order_service.dart';
import '../services/prefs_service.dart';
import '../services/pricing_service.dart';
import '../theme/app_theme.dart';
import 'ticket_chat_screen.dart';

class OrderStatusScreen extends StatefulWidget {
  final PrefsService prefs;
  final OrderService orderService;
  final String? initialOrderId;

  const OrderStatusScreen({
    super.key,
    required this.prefs,
    required this.orderService,
    this.initialOrderId,
  });

  @override
  State<OrderStatusScreen> createState() => _OrderStatusScreenState();
}

class _OrderStatusScreenState extends State<OrderStatusScreen> {
  late TextEditingController _controller;
  OrderModel? _foundOrder;
  bool _isLoading = false;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialOrderId ?? '');
    if (widget.initialOrderId != null && widget.initialOrderId!.isNotEmpty) {
      _lookup(widget.initialOrderId!);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _lookup(String idStr) async {
    final clean = idStr.trim().toUpperCase();
    if (clean.isEmpty) return;

    final isId = widget.prefs.lang == 'id';
    if (!clean.startsWith('VB-')) {
      setState(() {
        _errorMsg = isId
            ? 'Format Order ID salah. Contoh yang benar: VB-XXXXXX'
            : 'Invalid Order ID format. Example: VB-XXXXXX';
        _foundOrder = null;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMsg = null;
      _foundOrder = null;
    });

    final order = await widget.orderService.getOrder(clean);

    if (mounted) {
      setState(() {
        _isLoading = false;
        if (order != null) {
          _foundOrder = order;
        } else {
          _errorMsg = isId
              ? 'Pesanan dengan ID "$clean" tidak ditemukan. Pastikan huruf dan angka sudah sesuai.'
              : 'Order "$clean" not found. Please double-check your Order ID.';
        }
      });
    }
  }

  Color _getStatusBgColor(String status) {
    switch (status) {
      case 'completed':
        return const Color(0xFF065F46);
      case 'processing':
      case 'awaiting_delivery':
        return const Color(0xFF1E40AF);
      case 'cancelled':
        return const Color(0xFF991B1B);
      default:
        return const Color(0xFF92400E);
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status) {
      case 'completed':
        return const Color(0xFF6EE7B7);
      case 'processing':
      case 'awaiting_delivery':
        return const Color(0xFF93C5FD);
      case 'cancelled':
        return const Color(0xFFFCA5A5);
      default:
        return const Color(0xFFFCD34D);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isId = widget.prefs.lang == 'id';
    final recentIds = widget.orderService.orders.map((o) => o.orderId).toList();
    final numberFmt = NumberFormat.decimalPattern(isId ? 'id_ID': 'en_US');

    return Scaffold(
      backgroundColor: AppTheme.voidBlack,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Tag
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: AppTheme.wash,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.hairline),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('💬', style: TextStyle(fontSize: 12)),
                    const SizedBox(width: 6),
                    Text(
                      isId ? 'Live Support Ticket' : 'Live Support Ticket',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),

              // Title & Subtitle
              Text(
                isId ? 'Cek Status Pesanan & Chat Admin' : 'Check Order Status & Staff Chat',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                isId
                    ? 'Masukkan Order ID yang kamu dapatkan setelah membuat pesanan untuk melanjutkan tiket chat langsung dengan tim VesselBlox.'
                    : 'Enter your Order ID received after checkout to resume your direct chat ticket with the VesselBlox team.',
                style: const TextStyle(
                  color: AppTheme.ash,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),

              // Search Box Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.cardSurface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.hairlineStrong),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppTheme.wash,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppTheme.hairlineStrong),
                            ),
                            child: TextField(
                              controller: _controller,
                              textCapitalization: TextCapitalization.characters,
                              style: const TextStyle(
                                color: Colors.white,
                                fontFamily: 'monospace',
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                letterSpacing: 1.0,
                              ),
                              decoration: InputDecoration(
                                hintText: isId ? 'Contoh: VB-X7Y9': 'Example: VB-X7Y9',
                                hintStyle: const TextStyle(
                                  color: AppTheme.ashDim,
                                  fontFamily: 'monospace',
                                  fontSize: 14,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.purple,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          onPressed: _isLoading ? null : () => _lookup(_controller.text),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : Text(
                                  isId ? 'Cari' : 'Search',
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                                ),
                        ),
                      ],
                    ),

                    // Recent shortcuts
                    if (recentIds.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      const Divider(color: AppTheme.hairline, height: 1),
                      const SizedBox(height: 12),
                      Text(
                        isId ? 'Pesanan terakhir di perangkat ini:' : 'Recent orders on this device:',
                        style: const TextStyle(color: AppTheme.ashDim, fontSize: 11),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: recentIds.take(5).map((idStr) {
                          return InkWell(
                            onTap: () {
                              _controller.text = idStr;
                              _lookup(idStr);
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: AppTheme.wash,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppTheme.hairline),
                              ),
                              child: Text(
                                idStr,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'monospace',
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],

                    // Error Box
                    if (_errorMsg != null) ...[
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.red.withOpacity(0.3)),
                        ),
                        child: Text(
                          _errorMsg!,
                          style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Found Order Result Card
              if (_foundOrder != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppTheme.cardSurface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.hairlineStrong),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                _foundOrder!.orderId,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: _getStatusBgColor(_foundOrder!.status),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  _foundOrder!.statusLabel(widget.prefs.lang),
                                  style: TextStyle(
                                    color: _getStatusTextColor(_foundOrder!.status),
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            _foundOrder!.method.toUpperCase(),
                            style: const TextStyle(
                              color: AppTheme.ashDim,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      const Divider(color: AppTheme.hairline, height: 1),
                      const SizedBox(height: 14),

                      // Grid details
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'ROBLOX USER',
                                  style: TextStyle(color: AppTheme.ashDim, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  '@${_foundOrder!.robloxUsername}',
                                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isId ? 'JUMLAH ROBUX' : 'ROBUX AMOUNT',
                                  style: const TextStyle(color: AppTheme.ashDim, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  '${numberFmt.format(_foundOrder!.amountRobux)} R\$',
                                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isId ? 'TOTAL BAYAR' : 'TOTAL PAID',
                                  style: const TextStyle(color: AppTheme.ashDim, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  PricingService.formatMoney(
                                    _foundOrder!.total,
                                    _foundOrder!.currency,
                                    widget.prefs.lang,
                                  ),
                                  style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isId ? 'METODE PEMBAYARAN' : 'PAYMENT METHOD',
                                  style: const TextStyle(color: AppTheme.ashDim, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  _foundOrder!.paymentMethod,
                                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),

                      // Direct button to open ticket
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => TicketChatScreen(
                                  order: _foundOrder!,
                                  orderService: widget.orderService,
                                  lang: widget.prefs.lang,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.forum, size: 18),
                          label: Text(
                            isId ? 'Buka Ruang Chat Privat Bersama Admin →' : 'Open Private Chat with Support Staff →',
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
