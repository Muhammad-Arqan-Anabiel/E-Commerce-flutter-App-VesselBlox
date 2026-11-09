import 'package:flutter/material.dart';
import '../data/games_data.dart';
import '../models/game_model.dart';
import '../models/order_model.dart';
import '../services/cart_service.dart';
import '../services/order_service.dart';
import '../services/prefs_service.dart';
import '../services/pricing_service.dart';
import '../theme/app_theme.dart';
import '../widgets/floating_cart_button.dart';
import '../widgets/order_modal_sheet.dart';
import '../widgets/support_hub_card.dart';
import 'ticket_chat_screen.dart';

class GiftingCatalogScreen extends StatefulWidget {
  final PrefsService prefs;
  final CartService cart;
  final OrderService orderService;
  final VoidCallback onOpenMyOrders;
  final VoidCallback onOpenOrderStatus;

  const GiftingCatalogScreen({
    Key? key,
    required this.prefs,
    required this.cart,
    required this.orderService,
    required this.onOpenMyOrders,
    required this.onOpenOrderStatus,
  }) : super(key: key);

  @override
  State<GiftingCatalogScreen> createState() => _GiftingCatalogScreenState();
}

class _GiftingCatalogScreenState extends State<GiftingCatalogScreen> {
  bool get isId => widget.prefs.lang == 'id';

  void _openGamepassModal(RobloxGame game) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _GamepassSelectionSheet(
        game: game,
        cart: widget.cart,
        prefs: widget.prefs,
        onOpenCart: () {
          Navigator.pop(ctx);
          _openCartSheet();
        },
      ),
    );
  }

  void _openCartSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _CartSheet(
        cart: widget.cart,
        prefs: widget.prefs,
        onCheckout: () {
          Navigator.pop(ctx);
          _checkoutCart();
        },
      ),
    );
  }

  void _checkoutCart() {
    if (widget.cart.itemCount == 0) return;

    final quote = PricingService.calculateQuote(
      method: 'gifting',
      amount: widget.cart.totalRobux < 100 ? 100 : widget.cart.totalRobux,
      currency: widget.prefs.currency,
      usdIdrRate: widget.prefs.usdIdrRate,
      referralValid: true,
    );

    final gameNames = widget.cart.items.map((i) => i.gameName).toSet().join(', ');
    final itemDetails = widget.cart.items
        .map((i) => '${i.passName} (${i.passRobux} R\$ x${i.quantity})')
        .join(' + ');

    final cartSummaries = widget.cart.items
        .map((i) => CartItemSummary(
              passId: i.passId,
              passName: i.passName,
              gameName: i.gameName,
              passRobux: i.passRobux,
              quantity: i.quantity,
              passIcon: i.passIcon,
            ))
        .toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => OrderModalSheet(
        method: 'gifting',
        amount: widget.cart.totalRobux,
        beforeTax: quote.beforeTax,
        currency: quote.currency,
        subtotal: quote.subtotal,
        discount: quote.discount,
        total: quote.total,
        isCart: true, // KARENA KERANJANG: INPUT GAME TARGET & NAMA ITEM DIHAPUS
        cartItems: cartSummaries,
        initialGiftGame: gameNames,
        initialGiftItem: itemDetails,
        lang: widget.prefs.lang,
        orderService: widget.orderService,
        onOrderCreated: (order) {
          widget.cart.clearCart();
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

  void _openCustomUnlistedOrder() {
    final quote = PricingService.calculateQuote(
      method: 'gifting',
      amount: 500,
      currency: widget.prefs.currency,
      usdIdrRate: widget.prefs.usdIdrRate,
      referralValid: true,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => OrderModalSheet(
        method: 'gifting',
        amount: 500,
        beforeTax: quote.beforeTax,
        currency: quote.currency,
        subtotal: quote.subtotal,
        discount: quote.discount,
        total: quote.total,
        isCart: false, // GAME NOT LISTED: INPUT GAME TARGET & NAMA ITEM AKAN MUNCUL!
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
    return Scaffold(
      backgroundColor: AppTheme.voidBg,
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Header Badge & Cart Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.purplePrimary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppTheme.purplePrimary.withOpacity(0.3)),
                      ),
                      child: Row(
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
                            isId ? 'Katalog Resmi In-Game' : 'Official In-Game Gifting',
                            style: const TextStyle(
                              color: AppTheme.purpleLight,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (widget.cart.itemCount > 0)
                      InkWell(
                        onTap: _openCartSheet,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTheme.textWhite,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Text(
                                '🛒 ${widget.cart.totalQuantity}',
                                style: const TextStyle(color: AppTheme.pureBlack, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${widget.cart.totalRobux} R\$',
                                style: const TextStyle(color: AppTheme.purplePrimary, fontSize: 11, fontWeight: FontWeight.w900),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),

                // Title
                Text(
                  isId ? 'Game Gifting Roblox Terpopuler' : 'Popular Roblox Game Gifting',
                  style: const TextStyle(
                    color: AppTheme.textWhite,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isId
                      ? 'Beli gamepass resmi langsung ke akunmu lewat gifting in-game. Ketuk game untuk melihat seluruh gamepass asli dan masukkan ke keranjang.'
                      : 'Buy official gamepasses sent directly to your account. Tap any game to view all official passes and add to cart.',
                  style: const TextStyle(
                    color: AppTheme.textAsh,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),

                // 6 Featured Games Cards
                ...featuredRobloxGames.map((game) {
                  final lowestRobux = game.gamepasses.map((p) => p.robux).reduce((a, b) => a < b ? a : b);
                  final quote = PricingService.calculateQuote(
                    method: 'gifting',
                    amount: lowestRobux,
                    currency: widget.prefs.currency,
                    usdIdrRate: widget.prefs.usdIdrRate,
                  );

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppTheme.cardBg,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppTheme.hairline),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Game Thumbnail Banner
                        Stack(
                          children: [
                            AspectRatio(
                              aspectRatio: 16 / 9,
                              child: Image.asset(
                                game.thumbnail,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: AppTheme.cardWash,
                                  child: const Center(
                                    child: Icon(Icons.videogame_asset, size: 40, color: AppTheme.textAsh),
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              height: 120,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    AppTheme.cardBg.withOpacity(0.95),
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                            // Tag
                            Positioned(
                              top: 12,
                              left: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.75),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: AppTheme.purplePrimary.withOpacity(0.4)),
                                ),
                                child: Text(
                                  game.tag,
                                  style: const TextStyle(
                                    color: AppTheme.purpleLight,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                              ),
                            ),
                            // Pass Count
                            Positioned(
                              top: 12,
                              right: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.75),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: Colors.white12),
                                ),
                                child: Text(
                                  '${game.gamepasses.length} Gamepass',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        // Card Content
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                game.name,
                                style: const TextStyle(
                                  color: AppTheme.textWhite,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                game.desc,
                                style: const TextStyle(
                                  color: AppTheme.textAsh,
                                  fontSize: 11,
                                  height: 1.4,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 14),

                              // Bottom Row: Price & Action Button (WHITE BG, BLACK TEXT)
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        isId ? 'MULAI DARI' : 'STARTS FROM',
                                        style: const TextStyle(
                                          color: AppTheme.textAshDim,
                                          fontSize: 9,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                      Text(
                                        PricingService.formatMoney(quote.total, widget.prefs.currency, widget.prefs.lang),
                                        style: const TextStyle(
                                          color: AppTheme.textWhite,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ],
                                  ),

                                  // White background with black text!
                                  ElevatedButton(
                                    onPressed: () => _openGamepassModal(game),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.textWhite,
                                      foregroundColor: AppTheme.pureBlack,
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: Row(
                                      children: [
                                        Text(
                                          isId
                                              ? 'Pilih Gamepass (${game.gamepasses.length})'
                                              : 'Select Pass (${game.gamepasses.length})',
                                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900),
                                        ),
                                        const SizedBox(width: 4),
                                        const Text('→', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 10),

                // CUSTOM REQUEST BANNER: Game Not Listed Here? (TOMBOL TETAP UNGU bg-purple-600!)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppTheme.cardBg,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppTheme.hairline),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isId ? 'GAME NOT LISTED HERE?' : 'GAME NOT LISTED HERE?',
                        style: const TextStyle(
                          color: AppTheme.purpleLight,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isId
                            ? 'Punya Game / Gamepass Khusus yang Diinginkan?'
                            : 'Want a Custom Gamepass or In-Game Item?',
                        style: const TextStyle(
                          color: AppTheme.textWhite,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isId
                            ? 'Game tidak ada di 6 daftar di atas? Kami mendukung semua game Roblox dengan fitur gifting dan gamepass. Masukkan nama game target, nama item, atau link gamepass kamu.'
                            : 'Game not among the 6 games above? We support all Roblox games with gifting and gamepass delivery. Specify game name, item name, or gamepass link.',
                        style: const TextStyle(color: AppTheme.textAsh, fontSize: 11, height: 1.4),
                      ),
                      const SizedBox(height: 14),

                      // TOMBOL TETAP UNGU BG-PURPLE-600 SESUAI PERMINTAAN!
                      SizedBox(
                        width: double.infinity,
                        height: 44,
                        child: ElevatedButton(
                          onPressed: _openCustomUnlistedOrder,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.purplePrimary,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 4,
                          ),
                          child: Text(
                            isId ? 'Pesan Game / Gamepass Custom →' : 'Order Custom Game & Gamepass →',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // SUPPORT HUB CARD (Pusat Bantuan - Sudah Beli? Lacak Pesanan Anda | Tombol Kanan: Riwayat Pesanan Saya)
                SupportHubCard(
                  isId: isId,
                  onCheckStatus: widget.onOpenOrderStatus,
                  onMyOrders: widget.onOpenMyOrders,
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),

          // Floating Cart Button
          FloatingCartButton(
            cart: widget.cart,
            isId: isId,
            onTap: _openCartSheet,
          ),
        ],
      ),
    );
  }
}

// GAMEPASS SELECTION BOTTOM SHEET
class _GamepassSelectionSheet extends StatefulWidget {
  final RobloxGame game;
  final CartService cart;
  final PrefsService prefs;
  final VoidCallback onOpenCart;

  const _GamepassSelectionSheet({
    Key? key,
    required this.game,
    required this.cart,
    required this.prefs,
    required this.onOpenCart,
  }) : super(key: key);

  @override
  State<_GamepassSelectionSheet> createState() => _GamepassSelectionSheetState();
}

class _GamepassSelectionSheetState extends State<_GamepassSelectionSheet> {
  String _searchQuery = '';

  bool get isId => widget.prefs.lang == 'id';

  @override
  Widget build(BuildContext context) {
    final filteredPasses = widget.game.gamepasses.where((p) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return p.name.toLowerCase().contains(q) || p.desc.toLowerCase().contains(q);
    }).toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: const BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.hairlineStrong,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Game Header & Search
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.asset(
                    widget.game.thumbnail,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.game.name,
                        style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900),
                      ),
                      Text(
                        '${widget.game.gamepasses.length} Gamepass Resmi',
                        style: const TextStyle(color: AppTheme.purpleLight, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: AppTheme.textAsh),
                ),
              ],
            ),
          ),

          // Search Field
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              style: const TextStyle(color: Colors.white, fontSize: 12),
              decoration: InputDecoration(
                hintText: isId ? 'Cari gamepass...' : 'Search passes...',
                hintStyle: const TextStyle(color: AppTheme.textAshDim, fontSize: 12),
                prefixIcon: const Icon(Icons.search, size: 16, color: AppTheme.textAshDim),
                filled: true,
                fillColor: AppTheme.cardWash,
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              ),
            ),
          ),
          const Divider(color: AppTheme.hairline, height: 16),

          // List of official gamepasses
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: filteredPasses.length,
              itemBuilder: (context, index) {
                final pass = filteredPasses[index];
                final inCart = widget.cart.getItemInCart(pass.id);
                final quote = PricingService.calculateQuote(
                  method: 'gifting',
                  amount: pass.robux,
                  currency: widget.prefs.currency,
                  usdIdrRate: widget.prefs.usdIdrRate,
                );

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.cardWash,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppTheme.hairline),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badge Icon
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppTheme.hairline),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.asset(
                            pass.icon,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const Icon(Icons.star, color: AppTheme.purpleLight),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppTheme.purplePrimary.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '${pass.robux} R\$',
                                    style: const TextStyle(color: AppTheme.purpleLight, fontSize: 10, fontWeight: FontWeight.w900),
                                  ),
                                ),
                                if (pass.popular) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: AppTheme.amberGold.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text('⭐ POPULER', style: TextStyle(color: AppTheme.amberGold, fontSize: 8, fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              pass.name,
                              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              pass.desc,
                              style: const TextStyle(color: AppTheme.textAsh, fontSize: 10, height: 1.3),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),

                            // Price & Add to Cart button (White bg, black text)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  PricingService.formatMoney(quote.total, widget.prefs.currency, widget.prefs.lang),
                                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900),
                                ),

                                // In Cart: + / - controls. Not In Cart: + Keranjang
                                if (inCart != null)
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: AppTheme.hairlineStrong),
                                    ),
                                    child: Row(
                                      children: [
                                        _counterBtn('-', () {
                                          setState(() {
                                            widget.cart.updateQuantity(pass.id, inCart.quantity - 1);
                                          });
                                        }),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 8),
                                          child: Text(
                                            '${inCart.quantity}',
                                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        _counterBtn('+', () {
                                          setState(() {
                                            widget.cart.updateQuantity(pass.id, inCart.quantity + 1);
                                          });
                                        }),
                                      ],
                                    ),
                                  )
                                else
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        widget.cart.addToCart(widget.game, pass);
                                      });
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.textWhite,
                                      foregroundColor: AppTheme.pureBlack,
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      elevation: 0,
                                    ),
                                    child: Text(
                                      isId ? '+ Keranjang' : '+ Add',
                                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          // Bottom Bar in modal
          if (widget.cart.itemCount > 0)
            Container(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 12,
                bottom: MediaQuery.of(context).padding.bottom + 12,
              ),
              decoration: const BoxDecoration(
                color: AppTheme.pureBlack,
                border: Border(top: BorderSide(color: AppTheme.hairline)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '🛒 ${widget.cart.totalQuantity} Gamepass di Keranjang',
                        style: const TextStyle(color: AppTheme.purpleLight, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${widget.cart.totalRobux} R\$',
                        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: widget.onOpenCart,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.textWhite,
                      foregroundColor: AppTheme.pureBlack,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text(
                      isId ? 'Buka Keranjang & Hitung →' : 'Open Cart & Calculate →',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _counterBtn(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: AppTheme.textWhite,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(color: AppTheme.pureBlack, fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

// CART SHEET
class _CartSheet extends StatefulWidget {
  final CartService cart;
  final PrefsService prefs;
  final VoidCallback onCheckout;

  const _CartSheet({
    Key? key,
    required this.cart,
    required this.prefs,
    required this.onCheckout,
  }) : super(key: key);

  @override
  State<_CartSheet> createState() => _CartSheetState();
}

class _CartSheetState extends State<_CartSheet> {
  bool get isId => widget.prefs.lang == 'id';

  @override
  Widget build(BuildContext context) {
    final quote = PricingService.calculateQuote(
      method: 'gifting',
      amount: widget.cart.totalRobux < 100 ? 100 : widget.cart.totalRobux,
      currency: widget.prefs.currency,
      usdIdrRate: widget.prefs.usdIdrRate,
      referralValid: true,
    );

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(color: AppTheme.hairlineStrong, borderRadius: BorderRadius.circular(2)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text('🛒', style: TextStyle(fontSize: 18)),
                    const SizedBox(width: 8),
                    Text(
                      isId ? 'Keranjang Gamepass Kamu' : 'Your Gamepass Cart',
                      style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: AppTheme.textAsh),
                ),
              ],
            ),
          ),
          const Divider(color: AppTheme.hairline, height: 1),

          Expanded(
            child: widget.cart.itemCount == 0
                ? Center(
                    child: Text(
                      isId ? 'Keranjang masih kosong.' : 'Cart is currently empty.',
                      style: const TextStyle(color: AppTheme.textAsh),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: widget.cart.items.length,
                    itemBuilder: (context, index) {
                      final item = widget.cart.items[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.cardWash,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.hairline),
                        ),
                        child: Row(
                          children: [
                            Image.asset(item.passIcon, width: 36, height: 36, fit: BoxFit.contain),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item.passName, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                                  Text(item.gameName, style: const TextStyle(color: AppTheme.purpleLight, fontSize: 10)),
                                  Text('${item.passRobux} R\$ / pcs', style: const TextStyle(color: AppTheme.textAshDim, fontSize: 10)),
                                ],
                              ),
                            ),
                            // + - controls
                            Row(
                              children: [
                                InkWell(
                                  onTap: () => setState(() => widget.cart.updateQuantity(item.passId, item.quantity - 1)),
                                  child: Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
                                    child: const Center(child: Text('-', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold))),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8),
                                  child: Text('${item.quantity}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                ),
                                InkWell(
                                  onTap: () => setState(() => widget.cart.updateQuantity(item.passId, item.quantity + 1)),
                                  child: Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
                                    child: const Center(child: Text('+', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold))),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),

          // Total & Checkout
          if (widget.cart.itemCount > 0)
            Container(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 14,
                bottom: MediaQuery.of(context).padding.bottom + 14,
              ),
              decoration: const BoxDecoration(
                color: AppTheme.pureBlack,
                border: Border(top: BorderSide(color: AppTheme.hairline)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(isId ? 'Total Nominal Robux:' : 'Total Robux:', style: const TextStyle(color: AppTheme.textAsh, fontSize: 11)),
                      Text('${widget.cart.totalRobux} R\$', style: const TextStyle(color: AppTheme.purpleLight, fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(isId ? 'Total Pembayaran:' : 'Total Payment:', style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                      Text(
                        PricingService.formatMoney(quote.total, widget.prefs.currency, widget.prefs.lang),
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      onPressed: widget.onCheckout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.textWhite,
                        foregroundColor: AppTheme.pureBlack,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Text(
                        isId ? 'Lanjut ke Pembayaran →' : 'Proceed to Checkout →',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
