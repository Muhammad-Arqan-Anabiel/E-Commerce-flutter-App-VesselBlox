import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/order_service.dart';
import '../services/prefs_service.dart';
import '../services/pricing_service.dart';
import '../theme/app_theme.dart';
import 'ticket_chat_screen.dart';

class MyOrdersScreen extends StatefulWidget {
  final PrefsService prefs;
  final OrderService orderService;
  final VoidCallback? onGoHome;

  const MyOrdersScreen({
    super.key,
    required this.prefs,
    required this.orderService,
    this.onGoHome,
  });

  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    setState(() => _isLoading = true);
    await widget.orderService.refreshOrders();
    if (mounted) setState(() => _isLoading = false);
  }

  Color _getStatusBgColor(String status) {
    switch (status) {
      case 'completed':
        return const Color(0xFF065F46); // emerald dark
      case 'processing':
      case 'awaiting_delivery':
        return const Color(0xFF1E40AF); // blue dark
      case 'cancelled':
        return const Color(0xFF991B1B); // red dark
      default:
        return const Color(0xFF92400E); // amber dark
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

  String _getMethodLabel(String method, bool isId) {
    switch (method) {
      case 'gamepass':
        return isId ? 'Gamepass (Tax 30%)' : 'Gamepass (30% Tax)';
      case 'gifting':
        return isId ? 'Game Gifting (Langsung)' : 'Game Gifting (Direct)';
      case 'groupfunds':
        return isId ? 'Group Funds (0% Tax)' : 'Group Funds (0% Tax)';
      default:
        return method.toUpperCase();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isId = widget.prefs.lang == 'id';
    final orders = widget.orderService.orders;
    final numberFmt = NumberFormat.decimalPattern(isId ? 'id_ID': 'en_US');

    return Scaffold(
      backgroundColor: AppTheme.voidBlack,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppTheme.purple,
          backgroundColor: AppTheme.cardSurface,
          onRefresh: _refresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
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
                      const Text('🧾', style: TextStyle(fontSize: 12)),
                      const SizedBox(width: 6),
                      Text(
                        isId ? 'Riwayat Transaksi' : 'Transaction History',
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
                  isId ? 'Pesanan Saya' : 'My Orders',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  isId
                      ? 'Daftar pesanan Robux yang pernah kamu buat. Klik pada salah satu pesanan untuk membuka chat tiket privat bersama staf.'
                      : 'List of Robux orders you have made. Tap any order to open your private staff support chat.',
                  style: const TextStyle(
                    color: AppTheme.ash,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),

                // Content
                if (_isLoading && orders.isEmpty) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      color: AppTheme.cardSurface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.hairline),
                    ),
                    child: Center(
                      child: Column(
                        children: [
                          const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            isId ? 'Memuat daftar pesanan...' : 'Loading orders...',
                            style: const TextStyle(color: AppTheme.ashDim, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else if (orders.isEmpty) ...[
                  // Empty State
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 48),
                    decoration: BoxDecoration(
                      color: AppTheme.cardSurface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.hairline),
                    ),
                    child: Column(
                      children: [
                        const Text('🛍️', style: TextStyle(fontSize: 48)),
                        const SizedBox(height: 16),
                        Text(
                          isId ? 'Belum Ada Pesanan' : 'No Orders Found',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isId
                              ? 'Kamu belum memiliki riwayat pesanan. Mulai beli Robux sekarang langsung dari beranda.'
                              : 'You have not made any orders yet. Start purchasing Robux directly from the home screen.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppTheme.ash,
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          onPressed: widget.onGoHome,
                          child: Text(
                            isId ? 'Beli Robux Sekarang →' : 'Order Robux Now →',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  // Orders List
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: orders.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (ctx, idx) {
                      final order = orders[idx];
                      final statusBg = _getStatusBgColor(order.status);
                      final statusFg = _getStatusTextColor(order.status);

                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TicketChatScreen(
                                order: order,
                                orderService: widget.orderService,
                                lang: widget.prefs.lang,
                              ),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppTheme.cardSurface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppTheme.hairlineStrong),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Top line: Order ID + Status
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        order.orderId,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: statusBg,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          order.statusLabel(widget.prefs.lang),
                                          style: TextStyle(
                                            color: statusFg,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    _getMethodLabel(order.method, isId),
                                    style: const TextStyle(
                                      color: AppTheme.ashDim,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              const Divider(color: AppTheme.hairline, height: 1),
                              const SizedBox(height: 14),

                              // Info Grid 3 Columns
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'ROBLOX USER',
                                          style: TextStyle(
                                            color: AppTheme.ashDim,
                                            fontSize: 9,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          '@${order.robloxUsername}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
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
                                          style: const TextStyle(
                                            color: AppTheme.ashDim,
                                            fontSize: 9,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          '${numberFmt.format(order.amountRobux)} R\$',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          isId ? 'TOTAL BAYAR' : 'TOTAL PAID',
                                          style: const TextStyle(
                                            color: AppTheme.ashDim,
                                            fontSize: 9,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                        const SizedBox(height: 3),
                                        Text(
                                          PricingService.formatMoney(
                                            order.total,
                                            order.currency,
                                            widget.prefs.lang,
                                          ),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),

                              // Button action to ticket chat
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.black,
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    elevation: 0,
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => TicketChatScreen(
                                          order: order,
                                          orderService: widget.orderService,
                                          lang: widget.prefs.lang,
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.chat_bubble_outline, size: 14),
                                  label: Text(
                                    isId ? 'Buka Chat Tiket Staf →' : 'Open Staff Ticket →',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
