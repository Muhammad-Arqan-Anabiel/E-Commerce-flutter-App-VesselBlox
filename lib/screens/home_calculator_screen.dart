import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/order_service.dart';
import '../services/prefs_service.dart';
import '../services/pricing_service.dart';
import '../theme/app_theme.dart';
import '../widgets/inverted_white_slab.dart';
import '../widgets/order_modal_sheet.dart';
import '../widgets/support_hub_card.dart';
import 'ticket_chat_screen.dart';

class HomeCalculatorScreen extends StatefulWidget {
  final PrefsService prefs;
  final OrderService orderService;
  final VoidCallback onOpenGifting;
  final VoidCallback onOpenGroupFunds;
  final VoidCallback onOpenMyOrders;
  final VoidCallback onOpenOrderStatus;

  const HomeCalculatorScreen({
    Key? key,
    required this.prefs,
    required this.orderService,
    required this.onOpenGifting,
    required this.onOpenGroupFunds,
    required this.onOpenMyOrders,
    required this.onOpenOrderStatus,
  }) : super(key: key);

  @override
  State<HomeCalculatorScreen> createState() => _HomeCalculatorScreenState();
}

class _HomeCalculatorScreenState extends State<HomeCalculatorScreen> {
  String _method = 'gamepass'; // 'gamepass' | 'gifting' | 'groupfunds'
  final TextEditingController _amountController = TextEditingController(text: '1000');
  int _amount = 1000;

  bool get isId => widget.prefs.lang == 'id';

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _onAmountChanged(String val) {
    final clean = val.replaceAll(RegExp(r'[^0-9]'), '');
    final parsed = int.tryParse(clean) ?? 0;
    setState(() => _amount = parsed);
  }

  void _setAmount(int val) {
    _amountController.text = val.toString();
    setState(() => _amount = val);
  }

  void _openCheckoutModal() {
    final quote = PricingService.calculateQuote(
      method: _method,
      amount: _amount < 100 ? 100 : _amount,
      currency: widget.prefs.currency,
      usdIdrRate: widget.prefs.usdIdrRate,
      referralValid: true,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => OrderModalSheet(
        method: _method,
        amount: quote.amount,
        beforeTax: quote.beforeTax,
        currency: quote.currency,
        subtotal: quote.subtotal,
        discount: quote.discount,
        total: quote.total,
        isCart: false,
        lang: widget.prefs.lang,
        orderService: widget.orderService,
        onOrderCreated: (order) {
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final minLimit = PricingService.minRobux[_method] ?? 1000;
    final isAmountValid = _amount >= minLimit;

    PricingQuote? quote;
    if (_amount > 0) {
      quote = PricingService.calculateQuote(
        method: _method,
        amount: _amount,
        currency: widget.prefs.currency,
        usdIdrRate: widget.prefs.usdIdrRate,
        referralValid: true,
      );
    }

    final quickChips = _method == 'gifting' ? [350, 500, 1000, 2000] : [1000, 2000, 5000, 10000];

    return Scaffold(
      backgroundColor: AppTheme.voidBg,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.purplePrimary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.purplePrimary.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppTheme.purpleLight,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    isId ? 'Kalkulator Robux Resmi' : 'Official Robux Calculator',
                    style: const TextStyle(
                      color: AppTheme.purpleLight,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Hero Title
            Text(
              isId ? 'Beli Robux Legal & Aman' : 'Buy Clean & Verified Robux',
              style: const TextStyle(
                color: AppTheme.textWhite,
                fontSize: 24,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              isId
                  ? 'Pilih metode pengiriman favoritmu, hitung estimasi harga transparan, dan nikmati proses kilat 24/7.'
                  : 'Choose delivery method, calculate transparent prices, and enjoy fast 24/7 fulfillment.',
              style: const TextStyle(
                color: AppTheme.textAsh,
                fontSize: 12,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),

            // Delivery Method Selector (White BG, Black Text when Active!)
            Text(
              isId ? 'PILIH METODE BELI' : 'SELECT DELIVERY METHOD',
              style: const TextStyle(
                color: AppTheme.textAshDim,
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 8),

            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppTheme.cardWash,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.hairline),
              ),
              child: Row(
                children: [
                  _methodTab('gamepass', 'Gamepass'),
                  _methodTab('gifting', 'Game Gifting'),
                  _methodTab('groupfunds', 'Group Funds'),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Desired Robux Input Box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.hairline),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _method == 'gamepass'
                            ? (isId ? 'Robux yang Kamu Terima (Bersih)' : 'Robux You Receive (Clean)')
                            : (isId ? 'Jumlah Robux Diinginkan' : 'Desired Robux Amount'),
                        style: const TextStyle(
                          color: AppTheme.textAsh,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Min ${PricingService.formatInt(minLimit, widget.prefs.lang)} R\$',
                        style: const TextStyle(color: AppTheme.textAshDim, fontSize: 10),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Big Input
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          onChanged: _onAmountChanged,
                          style: const TextStyle(
                            color: AppTheme.textWhite,
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                          decoration: const InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      const Text(
                        'Robux',
                        style: TextStyle(
                          color: AppTheme.textAsh,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Quick Chips
                  Row(
                    children: [
                      Text(
                        isId ? 'Pintasan:' : 'Quick:',
                        style: const TextStyle(color: AppTheme.textAshDim, fontSize: 10),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: quickChips.map((chip) {
                              final active = _amount == chip;
                              return Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: InkWell(
                                  onTap: () => _setAmount(chip),
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: active ? AppTheme.textWhite : AppTheme.cardWash,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: active ? Colors.white : AppTheme.hairline,
                                      ),
                                    ),
                                    child: Text(
                                      PricingService.formatInt(chip, widget.prefs.lang),
                                      style: TextStyle(
                                        color: active ? AppTheme.pureBlack : AppTheme.textAsh,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // INVERTED WHITE SLAB (Only for Gamepass!)
            if (_method == 'gamepass' && quote != null) ...[
              InvertedWhiteSlab(
                gamepassPrice: quote.beforeTax,
                isId: isId,
              ),
              const SizedBox(height: 14),

              // Holding Notice
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.cardWash,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.hairline),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('⏳', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isId ? 'Aturan Resmi Roblox: Wajib Pending 5–7 Hari' : 'Roblox Rule: 5–7 Days Holding',
                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isId
                                ? 'Robux via Gamepass diproses admin 5-15 menit, lalu masuk pending di Roblox sebelum otomatis cair ke saldo.'
                                : 'Robux via Gamepass is fulfilled in 5-15 min, held by Roblox as Pending Robux for 5-7 days before release.',
                            style: const TextStyle(color: AppTheme.textAshDim, fontSize: 10, height: 1.3),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // GIFTING BANNER (Only for Gifting!)
            if (_method == 'gifting') ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.cardBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.hairline),
                ),
                child: Row(
                  children: [
                    const Text('🎁', style: TextStyle(fontSize: 24)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isId ? 'Katalog Game Gifting Lengkap' : 'Complete Game Gifting Catalog',
                            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isId
                                ? 'Pilih gamepass Blox Fruits, Fisch, Pet Sim 99, Blade Ball & Rivals langsung dengan keranjang.'
                                : 'Choose passes for Blox Fruits, Fisch, Pet Sim 99, Blade Ball & Rivals with live cart.',
                            style: const TextStyle(color: AppTheme.textAsh, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: widget.onOpenGifting,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.textWhite,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text(
                        isId ? 'Katalog →' : 'Catalog →',
                        style: const TextStyle(color: AppTheme.pureBlack, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // GROUP FUNDS BANNER (Only for Group Funds!)
            if (_method == 'groupfunds') ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.cardBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.hairline),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isId ? 'ROBLOX GROUP FUNDS (0% PAJAK)' : 'ROBLOX GROUP FUNDS (0% TAX)',
                          style: const TextStyle(color: AppTheme.textAshDim, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text('👥 Syarat 14 Hari', style: TextStyle(color: Colors.white, fontSize: 9)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isId
                          ? 'Payout Langsung ke Akun Tanpa Potongan 30%'
                          : 'Direct Group Payouts with 0% Tax Deduction',
                      style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isId
                          ? 'Roblox mewajibkan akun sudah berada di grup minimal 14 hari sebelum payout.'
                          : 'Roblox requires account to be in group for 14+ days before payouts.',
                      style: const TextStyle(color: AppTheme.textAsh, fontSize: 11),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Receipt Breakdown
            if (quote != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.hairline),
                ),
                child: Column(
                  children: [
                    if (_method == 'gamepass') ...[
                      _receiptRow(
                        isId ? 'Pajak Roblox (30%)' : 'Roblox Fee (30%)',
                        '${PricingService.formatInt(quote.robloxTax, widget.prefs.lang)} R\$',
                      ),
                      const SizedBox(height: 8),
                    ],
                    _receiptRow(
                      'Subtotal',
                      PricingService.formatMoney(quote.subtotal, widget.prefs.currency, widget.prefs.lang),
                    ),
                    if (quote.discount > 0) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Diskon Referral (1.8% off)',
                            style: TextStyle(color: AppTheme.emeraldGreen, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '-${PricingService.formatMoney(quote.discount, widget.prefs.currency, widget.prefs.lang)}',
                            style: const TextStyle(color: AppTheme.emeraldGreen, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                    const Divider(color: AppTheme.hairline, height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          PricingService.formatMoney(quote.total, widget.prefs.currency, widget.prefs.lang),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Checkout Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isAmountValid ? _openCheckoutModal : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.purplePrimary,
                  disabledBackgroundColor: AppTheme.purplePrimary.withOpacity(0.3),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 6,
                ),
                child: Text(
                  isAmountValid
                      ? (isId ? 'Lanjut ke Pembayaran →' : 'Proceed to Payment →')
                      : (isId ? 'Minimal ${PricingService.formatInt(minLimit, widget.prefs.lang)} Robux' : 'Min ${PricingService.formatInt(minLimit, widget.prefs.lang)} Robux'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // SUPPORT HUB CARD (Pusat Bantuan - Sudah Beli? Lacak Pesanan Anda | Tombol Kanan: Riwayat Pesanan Saya)
            SupportHubCard(
              isId: isId,
              onCheckStatus: widget.onOpenOrderStatus,
              onMyOrders: widget.onOpenMyOrders,
            ),
            const SizedBox(height: 20),

            // Community Discord Card
            InkWell(
              onTap: () async {
                final url = Uri.parse('https://discord.gg/PnuN3hYme');
                try {
                  await launchUrl(url, mode: LaunchMode.externalApplication);
                } catch (_) {}
              },
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.discordColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.discordColor.withOpacity(0.4)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppTheme.discordColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.sports_esports, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Discord Community',
                            style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            isId
                                ? 'Gabung bersama ribuan gamer untuk restock & giveaway'
                                : 'Join thousands of gamers for restocks & giveaways',
                            style: const TextStyle(color: Color(0xFFA5B4FC), fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, color: Color(0xFFA5B4FC), size: 14),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _methodTab(String key, String label) {
    final active = _method == key;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _method = key),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? AppTheme.textWhite : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: active ? AppTheme.pureBlack : AppTheme.textAsh,
                fontSize: 11,
                fontWeight: active ? FontWeight.w900 : FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _receiptRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(color: AppTheme.textAsh, fontSize: 12)),
        Text(value, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
