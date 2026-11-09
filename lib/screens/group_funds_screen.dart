import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/prefs_service.dart';
import '../services/pricing_service.dart';
import '../services/order_service.dart';
import '../theme/app_theme.dart';
import '../widgets/order_modal_sheet.dart';
import '../widgets/support_hub_card.dart';
import 'ticket_chat_screen.dart';

class GroupFundsScreen extends StatefulWidget {
  final PrefsService prefs;
  final OrderService orderService;
  final VoidCallback? onOpenTutorial;
  final VoidCallback? onOpenMyOrders;
  final VoidCallback? onOpenOrderStatus;

  const GroupFundsScreen({
    super.key,
    required this.prefs,
    required this.orderService,
    this.onOpenTutorial,
    this.onOpenMyOrders,
    this.onOpenOrderStatus,
  });

  @override
  State<GroupFundsScreen> createState() => _GroupFundsScreenState();
}

class _GroupFundsScreenState extends State<GroupFundsScreen> {
  late TextEditingController _controller;
  int _amount = 1000;
  final List<int> _quickAmounts = [500, 1000, 2000, 5000];

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '1000');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onAmountChanged(String val) {
    final clean = val.replaceAll(RegExp(r'[^0-9]'), '');
    setState(() {
      _amount = clean.isNotEmpty ? int.tryParse(clean) ?? 0 : 0;
    });
  }

  void _setAmount(int amt) {
    setState(() {
      _amount = amt;
      _controller.text = amt.toString();
    });
  }

  QuoteResult? _getQuote() {
    if (_amount < 100 || _amount > 100000) return null;
    try {
      return PricingService.quote(
        method: 'groupfunds',
        amount: _amount,
        currency: widget.prefs.currency,
        usdIdr: widget.prefs.usdIdrRate,
        referralValid: true,
      );
    } catch (_) {
      return null;
    }
  }

  void _handleProceed(QuoteResult quote) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => OrderModalSheet(
        method: 'groupfunds',
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
    final isId = widget.prefs.lang == 'id';
    final quote = _getQuote();
    final numberFmt = NumberFormat.decimalPattern(isId ? 'id_ID': 'en_US');

    return Scaffold(
      backgroundColor: AppTheme.voidBlack,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Badge
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
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isId ? '0% Potongan Pajak • Saldo Bersih' : '0% Roblox Fee • Clean Payouts',
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
                isId ? 'Roblox Group Funds' : 'Roblox Group Funds Payouts',
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
                    ? 'Robux dikirim langsung melalui sistem payout resmi Group Roblox VesselBlox. Kamu menerima 100% nominal Robux penuh tanpa potongan pajak 30%.'
                    : 'Robux is transferred directly via official VesselBlox Roblox group payouts. You receive 100% full net Robux with zero 30% tax cut.',
                style: const TextStyle(
                  color: AppTheme.ash,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),

              // 14 Days Rule Notice Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.cardSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.hairlineStrong),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('👥', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            isId ? 'Aturan Wajib Roblox: 14 Hari Hold' : 'Mandatory Roblox Rule: 14-Day Hold',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isId
                          ? 'Berdasarkan regulasi resmi Roblox Corp, akun baru wajib menjadi anggota group minimal selama 14 hari penuh sebelum grup diizinkan mengirim payout Robux ke akunmu.'
                          : 'Under official Roblox Corp security policies, your account must be a group member for at least 14 full days before the group can distribute Robux payouts to you.',
                      style: const TextStyle(
                        color: AppTheme.ash,
                        fontSize: 12,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.purple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () async {
                          final uri = Uri.parse('https://www.roblox.com/groups/33719001/VesselBlox-Official' );
                          if (await canLaunchUrl(uri)) {
                            await launchUrl(uri, mode: LaunchMode.externalApplication);
                          }
                        },
                        icon: const Icon(Icons.group_add, size: 16),
                        label: Text(
                          isId ? 'Gabung Group Roblox Sekarang →' : 'Join Roblox Group Now →',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Benefits 2 Cards
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0C0E14),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.hairline),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('⚡', style: TextStyle(fontSize: 22)),
                          const SizedBox(height: 8),
                          Text(
                            isId ? 'Tanpa Pajak 30%' : 'Zero 30% Tax',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isId
                                ? 'Beli 1.000 R\$, terima 1.000 R\$ utuh.'
                                : 'Buy 1,000 R\$, get 1,000 R\$ net.',
                            style: const TextStyle(
                              color: AppTheme.ash,
                              fontSize: 11,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0C0E14),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.hairline),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('🛡️', style: TextStyle(fontSize: 22)),
                          const SizedBox(height: 8),
                          Text(
                            isId ? '100% Saldo Bersih' : '100% Clean Funds',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isId
                                ? 'Berasal dari dev game terverifikasi.'
                                : 'Originates from verified dev sales.',
                            style: const TextStyle(
                              color: AppTheme.ash,
                              fontSize: 11,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Step-by-step Tutorial Link
              InkWell(
                onTap: widget.onOpenTutorial,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0C0E14),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.hairline),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.menu_book, color: AppTheme.ash, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isId ? 'PANDUAN STEP-BY-STEP' : 'STEP-BY-STEP GUIDE',
                              style: const TextStyle(
                                color: AppTheme.ashDim,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isId ? 'Baca Tutorial Lengkap Group Funds' : 'Read Full Group Funds Guide',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, color: AppTheme.ash, size: 14),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Order Form Card
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
                    Text(
                      isId ? 'FORM PEMESANAN' : 'ORDER FORM',
                      style: const TextStyle(
                        color: AppTheme.ashDim,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isId ? 'Pesan Robux Group Funds' : 'Order Group Funds Robux',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Amount input label
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isId ? 'Nominal Robux Bersih' : 'Net Robux Desired',
                          style: const TextStyle(color: AppTheme.ash, fontSize: 12),
                        ),
                        const Text(
                          'Min 100 R\$',
                          style: TextStyle(color: AppTheme.ashDim, fontSize: 11),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Input Box
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppTheme.wash,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.hairlineStrong),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              onChanged: _onAmountChanged,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                                hintText: '1000',
                                hintStyle: TextStyle(color: AppTheme.ashDim),
                              ),
                            ),
                          ),
                          const Text(
                            'Robux',
                            style: TextStyle(
                              color: AppTheme.ash,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Quick Chips
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          isId ? 'Pintasan:' : 'Quick:',
                          style: const TextStyle(color: AppTheme.ashDim, fontSize: 11),
                        ),
                        ..._quickAmounts.map((amt) {
                          final selected = _amount == amt;
                          return InkWell(
                            onTap: () => _setAmount(amt),
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: selected ? Colors.white : AppTheme.wash,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: selected ? Colors.white : AppTheme.hairline,
                                ),
                              ),
                              child: Text(
                                numberFmt.format(amt),
                                style: TextStyle(
                                  color: selected ? Colors.black : AppTheme.ash,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Quote summary
                    if (quote != null) ...[
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppTheme.wash,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: AppTheme.hairline),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  isId ? 'Robux Diterima' : 'Robux Received',
                                  style: const TextStyle(color: AppTheme.ash, fontSize: 12),
                                ),
                                Text(
                                  '${numberFmt.format(quote.amount)} R\$',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  isId ? 'Pajak Roblox' : 'Roblox Fee',
                                  style: const TextStyle(color: AppTheme.ash, fontSize: 12),
                                ),
                                Text(
                                  isId ? '0 R\$ (Bebas Pajak)' : '0 R\$ (Fee-free)',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Subtotal',
                                  style: TextStyle(color: AppTheme.ash, fontSize: 12),
                                ),
                                Text(
                                  PricingService.formatMoney(quote.subtotal, quote.currency, widget.prefs.lang),
                                  style: const TextStyle(color: Colors.white, fontSize: 12),
                                ),
                              ],
                            ),
                            if (quote.discount > 0) ...[
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    isId ? 'Diskon Referral VESSEL (1.8%)' : 'VESSEL Discount (1.8%)',
                                    style: const TextStyle(
                                      color: Color(0xFF10B981),
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '-${PricingService.formatMoney(quote.discount, quote.currency, widget.prefs.lang)}',
                                    style: const TextStyle(
                                      color: Color(0xFF10B981),
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            const SizedBox(height: 10),
                            const Divider(color: AppTheme.hairline, height: 1),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  isId ? 'Total Pembayaran' : 'Total Payment',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  PricingService.formatMoney(quote.total, quote.currency, widget.prefs.lang),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Action Button (White background, Black text)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          onPressed: () => _handleProceed(quote),
                          child: Text(
                            isId ? 'Beli Lewat Group Funds →' : 'Proceed with Group Funds →',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ] else ...[
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red.withOpacity(0.3)),
                        ),
                        child: Text(
                          isId
                              ? 'Nominal minimal 100 R\$ dan maksimal 100.000 R\$.'
                              : 'Minimum 100 R\$ and maximum 100,000 R\$.',
                          style: const TextStyle(color: Colors.redAccent, fontSize: 12),
                        ),
                      ),
                    ],

                    const SizedBox(height: 12),
                    Text(
                      isId
                          ? 'Pastikan akunmu sudah 14 hari di dalam group sebelum memesan agar tidak gagal transfer.'
                          : 'Ensure your account has met the 14-day hold criteria to ensure successful payout.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppTheme.ashDim,
                        fontSize: 11,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SupportHubCard(
                isId: isId,
                onCheckStatus: widget.onOpenOrderStatus ?? () {},
                onMyOrders: widget.onOpenMyOrders ?? () {},
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
