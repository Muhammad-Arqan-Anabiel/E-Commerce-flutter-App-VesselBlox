import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../services/order_service.dart';
import '../services/pricing_service.dart';
import '../theme/app_theme.dart';

class TicketChatScreen extends StatefulWidget {
  final OrderModel order;
  final OrderService orderService;
  final String lang;

  const TicketChatScreen({
    Key? key,
    required this.order,
    required this.orderService,
    required this.lang,
  }) : super(key: key);

  @override
  State<TicketChatScreen> createState() => _TicketChatScreenState();
}

class _TicketChatScreenState extends State<TicketChatScreen> {
  final TextEditingController _msgController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool get isId => widget.lang == 'id';

  @override
  void dispose() {
    _msgController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _msgController.text.trim();
    if (text.isEmpty) return;
    _msgController.clear();
    widget.orderService.addMessageToOrder(widget.order.orderId, text, 'buyer');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // Look up latest order instance
    final order = widget.orderService.getOrderById(widget.order.orderId) ?? widget.order;

    return Scaffold(
      backgroundColor: AppTheme.voidBg,
      appBar: AppBar(
        backgroundColor: AppTheme.pureBlack,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  order.orderId,
                  style: const TextStyle(
                    color: AppTheme.textWhite,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.emeraldGreen.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    isId ? 'VERIFIKASI' : 'VERIFYING',
                    style: const TextStyle(
                      color: AppTheme.emeraldGreen,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            Text(
              '@${order.robloxUsername} • ${PricingService.formatInt(order.amountRobux, widget.lang)} R\$',
              style: const TextStyle(color: AppTheme.textAshDim, fontSize: 11),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Order summary banner at top of chat
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: AppTheme.cardBg,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text('🛡️', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 6),
                    Text(
                      isId ? 'Tiket Privat Staf VesselBlox' : 'Private Staff Ticket',
                      style: const TextStyle(color: AppTheme.textAsh, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Text(
                  PricingService.formatMoney(order.total, order.currency, widget.lang),
                  style: const TextStyle(color: AppTheme.textWhite, fontSize: 12, fontWeight: FontWeight.w900),
                ),
              ],
            ),
          ),
          const Divider(color: AppTheme.hairline, height: 1),

          // Messages List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: order.messages.length,
              itemBuilder: (context, index) {
                final msg = order.messages[index];
                return _buildMessageBubble(msg);
              },
            ),
          ),

          // Input Bar
          Container(
            padding: EdgeInsets.only(
              left: 12,
              right: 12,
              top: 8,
              bottom: MediaQuery.of(context).padding.bottom + 8,
            ),
            decoration: const BoxDecoration(
              color: AppTheme.pureBlack,
              border: Border(top: BorderSide(color: AppTheme.hairline)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _msgController,
                    style: const TextStyle(color: AppTheme.textWhite, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: isId ? 'Tulis pesan untuk staf toko...' : 'Type a message to staff...',
                      hintStyle: const TextStyle(color: AppTheme.textAshDim, fontSize: 12),
                      filled: true,
                      fillColor: AppTheme.cardWash,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _sendMessage,
                  icon: const Icon(Icons.send_rounded, color: AppTheme.purpleLight, size: 22),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(TicketMessage msg) {
    final isBuyer = msg.sender == 'buyer';
    final isSystem = msg.sender == 'system';

    if (isSystem) {
      return Center(
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.cardWash,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.hairline),
          ),
          child: Text(
            msg.text,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppTheme.textAshDim, fontSize: 11),
          ),
        ),
      );
    }

    return Align(
      alignment: isBuyer ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isBuyer ? AppTheme.purplePrimary : AppTheme.cardWash,
          borderRadius: BorderRadius.circular(16).copyWith(
            bottomRight: isBuyer ? const Radius.circular(2) : const Radius.circular(16),
            bottomLeft: !isBuyer ? const Radius.circular(2) : const Radius.circular(16),
          ),
          border: Border.all(color: isBuyer ? Colors.transparent : AppTheme.hairline),
        ),
        child: Column(
          crossAxisAlignment: isBuyer ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isBuyer) ...[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text('🛡️ Staf Toko', style: TextStyle(color: AppTheme.purpleLight, fontSize: 10, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 4),
            ],
            Text(
              msg.text,
              style: const TextStyle(color: AppTheme.textWhite, fontSize: 13, height: 1.3),
            ),
            const SizedBox(height: 4),
            Text(
              msg.time,
              style: TextStyle(
                color: isBuyer ? Colors.white70 : AppTheme.textAshDim,
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
