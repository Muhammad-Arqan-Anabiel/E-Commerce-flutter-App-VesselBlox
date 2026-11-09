import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/order_model.dart';
import '../models/roblox_user_model.dart';
import '../services/order_service.dart';
import '../services/pricing_service.dart';
import '../services/roblox_service.dart';
import '../theme/app_theme.dart';
import 'roblox_user_card.dart';

class OrderModalSheet extends StatefulWidget {
  final String method;
  final int amount;
  final int beforeTax;
  final String currency;
  final double subtotal;
  final double discount;
  final double total;
  final bool isCart;
  final List<CartItemSummary>? cartItems;
  final String? initialGiftGame;
  final String? initialGiftItem;
  final String lang;
  final OrderService orderService;
  final Function(OrderModel order)? onOrderCreated;

  const OrderModalSheet({
    Key? key,
    required this.method,
    required this.amount,
    required this.beforeTax,
    required this.currency,
    required this.subtotal,
    required this.discount,
    required this.total,
    this.isCart = false,
    this.cartItems,
    this.initialGiftGame,
    this.initialGiftItem,
    required this.lang,
    required this.orderService,
    this.onOrderCreated,
  }) : super(key: key);

  @override
  State<OrderModalSheet> createState() => _OrderModalSheetState();
}

class _OrderModalSheetState extends State<OrderModalSheet> {
  int _currentStep = 1; // 1: Form, 2: Gamepass Tutorial, 3: Payment, 4: Proof

  // Form controllers
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _instagramController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _gamepassUrlController = TextEditingController();
  final TextEditingController _giftGameController = TextEditingController();
  final TextEditingController _giftItemController = TextEditingController();

  RobloxUser? _detectedUser;
  bool _userConfirmed = false;
  bool _searchingUser = false;
  bool _groupAck = false;
  String _selectedPaymentMethod = 'qris';
  bool _submitting = false;
  bool _hasProofFile = false;
  Timer? _debounceTimer;

  bool get isId => widget.lang == 'id';
  bool get isGamepass => widget.method == 'gamepass';
  int get totalSteps => isGamepass ? 4 : 3;

  @override
  void initState() {
    super.initState();
    if (widget.initialGiftGame != null) {
      _giftGameController.text = widget.initialGiftGame!;
    }
    if (widget.initialGiftItem != null) {
      _giftItemController.text = widget.initialGiftItem!;
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _usernameController.dispose();
    _emailController.dispose();
    _instagramController.dispose();
    _notesController.dispose();
    _gamepassUrlController.dispose();
    _giftGameController.dispose();
    _giftItemController.dispose();
    super.dispose();
  }

  void _onUsernameChanged(String val) {
    _debounceTimer?.cancel();
    setState(() {
      _userConfirmed = false;
      _detectedUser = null;
    });

    final name = val.trim();
    if (name.length < 3) return;

    setState(() => _searchingUser = true);
    _debounceTimer = Timer(const Duration(milliseconds: 600), () async {
      final user = await RobloxService.lookupUser(name);
      if (mounted) {
        setState(() {
          _detectedUser = user;
          _searchingUser = false;
        });
      }
    });
  }

  bool _isStep1Valid() {
    if (_detectedUser == null || !_userConfirmed) return false;
    if (widget.method == 'groupfunds' && !_groupAck) return false;
    // Jika custom gifting unlisted: wajib isi game target & item name
    if (widget.method == 'gifting' && !widget.isCart) {
      if (_giftGameController.text.trim().isEmpty || _giftItemController.text.trim().isEmpty) {
        return false;
      }
    }
    return true;
  }

  bool _isGamepassUrlValid() {
    final url = _gamepassUrlController.text.trim().toLowerCase();
    return url.contains('roblox.com') && url.contains(RegExp(r'[0-9]{4,}'));
  }

  void _nextStep() {
    if (_currentStep == 1) {
      if (isGamepass) {
        setState(() => _currentStep = 2);
      } else {
        setState(() => _currentStep = 3);
      }
    } else if (_currentStep == 2) {
      setState(() => _currentStep = 3);
    } else if (_currentStep == 3) {
      setState(() => _currentStep = 4);
    }
  }

  void _prevStep() {
    if (_currentStep == 4) {
      setState(() => _currentStep = 3);
    } else if (_currentStep == 3) {
      setState(() => _currentStep = isGamepass ? 2 : 1);
    } else if (_currentStep == 2) {
      setState(() => _currentStep = 1);
    }
  }

  Future<void> _submitOrder() async {
    setState(() => _submitting = true);
    try {
      final order = await widget.orderService.createOrder(
        method: widget.method,
        amountRobux: widget.amount,
        beforeTaxRobux: widget.beforeTax,
        currency: widget.currency,
        subtotal: widget.subtotal,
        discount: widget.discount,
        total: widget.total,
        robloxUsername: _detectedUser?.username ?? _usernameController.text.trim(),
        robloxId: _detectedUser?.id,
        robloxAvatar: _detectedUser?.avatarUrl,
        email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        instagram: _instagramController.text.trim().isEmpty ? null : _instagramController.text.trim(),
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        gamepassUrl: _gamepassUrlController.text.trim().isNotEmpty ? _gamepassUrlController.text.trim() : null,
        giftGame: widget.method == 'gifting'
            ? (widget.isCart ? (widget.initialGiftGame ?? 'Katalog Gifting') : _giftGameController.text.trim())
            : null,
        giftItem: widget.method == 'gifting'
            ? (widget.isCart ? (widget.initialGiftItem ?? 'Gamepasses') : _giftItemController.text.trim())
            : null,
        isCart: widget.isCart,
        cartItems: widget.cartItems,
        paymentMethod: _selectedPaymentMethod,
        proofPath: _hasProofFile ? 'proof_uploaded.jpg' : null,
        lang: widget.lang,
      );

      if (mounted) {
        Navigator.pop(context);
        widget.onOrderCreated?.call(order);
      }
    } catch (_) {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final stepLabel = isId
        ? 'Langkah $_currentStep dari $totalSteps'
        : 'Step $_currentStep of $totalSteps';

    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: AppTheme.hairlineStrong, width: 1.5),
        ),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Drag Handle & Close
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.hairlineStrong,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header Info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stepLabel.toUpperCase(),
                      style: const TextStyle(
                        color: AppTheme.textAshDim,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _stepTitle(),
                      style: const TextStyle(
                        color: AppTheme.textWhite,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: AppTheme.textAsh, size: 20),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // Order quick summary badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppTheme.purplePrimary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.purplePrimary.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.method == 'gamepass'
                        ? '⚡ Gamepass'
                        : (widget.method == 'gifting' ? '🎁 Game Gifting' : '👥 Group Funds'),
                    style: const TextStyle(
                      color: AppTheme.purpleLight,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '•  ${PricingService.formatInt(widget.amount, widget.lang)} Robux  •  ${PricingService.formatMoney(widget.total, widget.currency, widget.lang)}',
                    style: const TextStyle(
                      color: AppTheme.textWhite,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Step Content
            if (_currentStep == 1) _buildStep1Form(),
            if (_currentStep == 2 && isGamepass) _buildStep2GamepassTutorial(),
            if (_currentStep == 3) _buildStep3PaymentSelection(),
            if (_currentStep == 4) _buildStep4ProofUpload(),
          ],
        ),
      ),
    );
  }

  String _stepTitle() {
    switch (_currentStep) {
      case 1:
        return isId ? 'Lengkapi Data Akun' : 'Order Details';
      case 2:
        return isId ? 'Buat Link Gamepass' : 'Create Gamepass';
      case 3:
        return isId ? 'Pilih Metode Bayar' : 'Payment Method';
      case 4:
        return isId ? 'Unggah Bukti Bayar' : 'Upload Proof';
      default:
        return '';
    }
  }

  // STEP 1: FORM DATA
  Widget _buildStep1Form() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Username Roblox Input
        Text(
          isId ? 'USERNAME ROBLOX (WAJIB)' : 'ROBLOX USERNAME (REQUIRED)',
          style: const TextStyle(
            color: AppTheme.textAsh,
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _usernameController,
          onChanged: _onUsernameChanged,
          style: const TextStyle(color: AppTheme.textWhite, fontSize: 14),
          decoration: InputDecoration(
            hintText: isId ? 'Contoh: FrostyCool13' : 'e.g. FrostyCool13',
            hintStyle: const TextStyle(color: AppTheme.textAshDim, fontSize: 13),
            filled: true,
            fillColor: AppTheme.cardWash,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.hairline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.hairline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.textWhite),
            ),
            suffixIcon: _searchingUser
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.purpleLight),
                    ),
                  )
                : null,
          ),
        ),

        // Detected Roblox User Profile Card
        if (_detectedUser != null) ...[
          const SizedBox(height: 10),
          RobloxUserCard(
            user: _detectedUser!,
            confirmed: _userConfirmed,
            isId: isId,
            onConfirm: () => setState(() => _userConfirmed = true),
            onChange: () => setState(() => _userConfirmed = false),
          ),
        ],
        const SizedBox(height: 14),

        // Email Input
        Text(
          isId ? 'ALAMAT EMAIL (OPSIONAL)' : 'EMAIL ADDRESS (OPTIONAL)',
          style: const TextStyle(
            color: AppTheme.textAsh,
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(color: AppTheme.textWhite, fontSize: 14),
          decoration: InputDecoration(
            hintText: 'nama@gmail.com',
            hintStyle: const TextStyle(color: AppTheme.textAshDim, fontSize: 13),
            filled: true,
            fillColor: AppTheme.cardWash,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.hairline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.hairline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.textWhite),
            ),
          ),
        ),
        const SizedBox(height: 14),

        // GIFTING LOGIC: KARENA KERANJANG vs GAME NOT LISTED HERE
        if (widget.method == 'gifting') ...[
          if (!widget.isCart) ...[
            // Game Not Listed Here: TAMPILKAN INPUT GAME TARGET & NAMA ITEM!
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.purplePrimary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.purplePrimary.withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('🎮', style: TextStyle(fontSize: 14)),
                      const SizedBox(width: 6),
                      Text(
                        isId ? 'GAME NOT LISTED / PESANAN CUSTOM' : 'GAME NOT LISTED / CUSTOM ORDER',
                        style: const TextStyle(
                          color: AppTheme.purpleLight,
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    isId ? 'GAME TARGET (ROBLOX)' : 'TARGET GAME (ROBLOX)',
                    style: const TextStyle(color: AppTheme.textAsh, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  TextField(
                    controller: _giftGameController,
                    style: const TextStyle(color: AppTheme.textWhite, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: isId ? 'Contoh: Jailbreak / MM2 / dll.' : 'e.g. Jailbreak / MM2',
                      hintStyle: const TextStyle(color: AppTheme.textAshDim, fontSize: 12),
                      filled: true,
                      fillColor: AppTheme.pureBlack,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    isId ? 'NAMA ITEM / GAMEPASS' : 'ITEM / GAMEPASS NAME',
                    style: const TextStyle(color: AppTheme.textAsh, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  TextField(
                    controller: _giftItemController,
                    style: const TextStyle(color: AppTheme.textWhite, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: isId ? 'Contoh: VIP Pass / SWAG Pack' : 'e.g. VIP Pass / SWAG Pack',
                      hintStyle: const TextStyle(color: AppTheme.textAshDim, fontSize: 12),
                      filled: true,
                      fillColor: AppTheme.pureBlack,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    isId ? 'LINK GAMEPASS / GAME ROBLOX (OPSIONAL)' : 'ROBLOX GAMEPASS / GAME LINK (OPTIONAL)',
                    style: const TextStyle(color: AppTheme.textAsh, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  TextField(
                    controller: _gamepassUrlController,
                    style: const TextStyle(color: AppTheme.textWhite, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: isId ? 'https://www.roblox.com/game-pass/... atau link game' : 'https://www.roblox.com/game-pass/... or game link',
                      hintStyle: const TextStyle(color: AppTheme.textAshDim, fontSize: 12),
                      filled: true,
                      fillColor: AppTheme.pureBlack,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isId
                        ? 'Tempelkan tautan Gamepass atau game agar staf kami bisa langsung menemukan target item kamu.'
                        : 'Paste the Gamepass or game link so our staff can directly find your target item.',
                    style: const TextStyle(color: AppTheme.textAshDim, fontSize: 10),
                  ),
                ],
              ),
            ),
          ] else ...[
            // DARI KERANJANG: HAPUS INPUT TEKS! TAMPILKAN RINGKASAN ITEM RESMI KERANJANG
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.cardWash,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.hairline),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Text('🛒', style: TextStyle(fontSize: 14)),
                          const SizedBox(width: 6),
                          Text(
                            isId ? 'ITEM DARI KERANJANG' : 'ITEMS FROM CART',
                            style: const TextStyle(
                              color: AppTheme.textAshDim,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${widget.cartItems?.length ?? 1} ${isId ? "Item" : "Items"}',
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (widget.cartItems != null && widget.cartItems!.isNotEmpty) ...[
                    ...widget.cartItems!.map((item) => Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppTheme.hairline),
                          ),
                          child: Row(
                            children: [
                              if (item.passIcon != null && item.passIcon!.isNotEmpty)
                                Container(
                                  width: 28,
                                  height: 28,
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(6),
                                    color: Colors.black,
                                  ),
                                  child: Image.asset(
                                    item.passIcon!,
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, __, ___) => const Icon(Icons.star, size: 14, color: AppTheme.purpleLight),
                                  ),
                                ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.passName,
                                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      item.gameName,
                                      style: const TextStyle(color: AppTheme.purpleLight, fontSize: 9),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                'x${item.quantity}',
                                style: const TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${item.passRobux * item.quantity} R\$',
                                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w900),
                              ),
                            ],
                          ),
                        )),
                  ] else ...[
                    Text(
                      widget.initialGiftItem ?? 'Gamepass Item',
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),
          ],
          const SizedBox(height: 14),
        ],

        // GROUP FUNDS CHECKBOX
        if (widget.method == 'groupfunds') ...[
          InkWell(
            onTap: () => setState(() => _groupAck = !_groupAck),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.cardWash,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.hairline),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Checkbox(
                    value: _groupAck,
                    onChanged: (val) => setState(() => _groupAck = val ?? false),
                    activeColor: AppTheme.purplePrimary,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      isId
                          ? 'Saya sudah bergabung ke grup resmi toko minimal 14 hari dan memahami aturan holding Roblox.'
                          : 'I have joined the official store group for 14+ days and acknowledge Roblox payout rules.',
                      style: const TextStyle(color: AppTheme.textAsh, fontSize: 11, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
        ],

        // Instagram Input (Optional)
        Text(
          isId ? 'INSTAGRAM (OPSIONAL)' : 'INSTAGRAM (OPTIONAL)',
          style: const TextStyle(
            color: AppTheme.textAsh,
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _instagramController,
          style: const TextStyle(color: AppTheme.textWhite, fontSize: 14),
          decoration: InputDecoration(
            prefixText: '@ ',
            prefixStyle: const TextStyle(color: AppTheme.textAshDim, fontSize: 14),
            hintText: 'vesselblox',
            hintStyle: const TextStyle(color: AppTheme.textAshDim, fontSize: 13),
            filled: true,
            fillColor: AppTheme.cardWash,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 14),

        // Notes Input (Optional)
        Text(
          isId ? 'CATATAN PESANAN (OPSIONAL)' : 'ORDER NOTES (OPTIONAL)',
          style: const TextStyle(
            color: AppTheme.textAsh,
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _notesController,
          maxLines: 2,
          style: const TextStyle(color: AppTheme.textWhite, fontSize: 13),
          decoration: InputDecoration(
            hintText: isId ? 'Contoh: Mohon diproses cepat ya...' : 'Any special notes for staff...',
            hintStyle: const TextStyle(color: AppTheme.textAshDim, fontSize: 12),
            filled: true,
            fillColor: AppTheme.cardWash,
            contentPadding: const EdgeInsets.all(12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 20),

        // Continue Button (White bg, black text)
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton(
            onPressed: _isStep1Valid() ? _nextStep : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.textWhite,
              disabledBackgroundColor: Colors.white24,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 0,
            ),
            child: Text(
              isId ? 'Lanjut ke Pembayaran →' : 'Proceed to Payment →',
              style: TextStyle(
                color: _isStep1Valid() ? AppTheme.pureBlack : AppTheme.textAshDim,
                fontSize: 13,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // STEP 2: GAMEPASS TUTORIAL & LINK (GAMEPASS ONLY)
  Widget _buildStep2GamepassTutorial() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.cardWash,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.hairline),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('⏳', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 8),
                  Text(
                    isId ? 'Aturan Resmi Roblox: Pending 5-7 Hari' : 'Roblox Rule: 5-7 Days Pending',
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                isId
                    ? 'Buat Gamepass di Creator Hub Roblox dengan harga tepat ${widget.beforeTax} Robux agar Anda menerima ${widget.amount} Robux bersih.'
                    : 'Create a Gamepass on Roblox Creator Hub set precisely to ${widget.beforeTax} Robux so you receive ${widget.amount} clean Robux.',
                style: const TextStyle(color: AppTheme.textAsh, fontSize: 11, height: 1.4),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Tutorial YouTube button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () async {
              final url = Uri.parse('https://www.youtube.com/results?search_query=cara+membuat+gamepass+roblox');
              try {
                await launchUrl(url, mode: LaunchMode.externalApplication);
              } catch (_) {}
            },
            icon: const Icon(Icons.play_circle_outline, color: Colors.redAccent, size: 16),
            label: Text(
              isId ? 'Tonton Tutorial Buat Gamepass di YouTube' : 'Watch Gamepass Tutorial on YouTube',
              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 11),
              side: const BorderSide(color: AppTheme.hairline),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Link Gamepass Input
        Text(
          isId ? 'TEMPEL LINK GAMEPASS ROBLOX KAMU' : 'PASTE YOUR ROBLOX GAMEPASS LINK',
          style: const TextStyle(color: AppTheme.textAsh, fontSize: 10, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _gamepassUrlController,
          onChanged: (_) => setState(() {}),
          style: const TextStyle(color: AppTheme.textWhite, fontSize: 13),
          decoration: InputDecoration(
            hintText: 'https://www.roblox.com/game-pass/12345678/...',
            hintStyle: const TextStyle(color: AppTheme.textAshDim, fontSize: 12),
            filled: true,
            fillColor: AppTheme.cardWash,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        const SizedBox(height: 20),

        // Navigation
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _prevStep,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: AppTheme.hairline),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(isId ? '← Kembali' : '← Back', style: const TextStyle(color: Colors.white)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _isGamepassUrlValid() ? _nextStep : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.textWhite,
                  disabledBackgroundColor: Colors.white24,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  isId ? 'Lanjut Bayar →' : 'Next →',
                  style: TextStyle(
                    color: _isGamepassUrlValid() ? AppTheme.pureBlack : AppTheme.textAshDim,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // STEP 3: PAYMENT SELECTION
  Widget _buildStep3PaymentSelection() {
    final methods = [
      {'id': 'qris', 'title': 'QRIS (Semua E-Wallet / Bank)', 'sub': 'Instan & Bebas Biaya Admin', 'icon': '📱'},
      {'id': 'bca', 'title': 'Bank BCA (Transfer Virtual)', 'sub': 'Verifikasi Cepat 24 Jam', 'icon': '🏦'},
      {'id': 'mandiri', 'title': 'Bank Mandiri', 'sub': 'Transfer Bank Nasional', 'icon': '🏛️'},
      {'id': 'gopay', 'title': 'GoPay', 'sub': 'Transfer Instan GoPay App', 'icon': '🟢'},
      {'id': 'shopeepay', 'title': 'ShopeePay', 'sub': 'Transfer Instan Shopee App', 'icon': '🟠'},
      {'id': 'paypal', 'title': 'PayPal / Wise (USD)', 'sub': 'International Payment Support', 'icon': '🌐'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...methods.map((m) {
          final isSelected = _selectedPaymentMethod == m['id'];
          return InkWell(
            onTap: () => setState(() => _selectedPaymentMethod = m['id']!),
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: isSelected ? AppTheme.purplePrimary.withOpacity(0.12) : AppTheme.cardWash,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? AppTheme.purpleLight : AppTheme.hairline,
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Row(
                children: [
                  Text(m['icon']!, style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          m['title']!,
                          style: TextStyle(
                            color: isSelected ? AppTheme.textWhite : Colors.white70,
                            fontSize: 12,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        Text(
                          m['sub']!,
                          style: const TextStyle(color: AppTheme.textAshDim, fontSize: 10),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    const Icon(Icons.check_circle, color: AppTheme.purpleLight, size: 18),
                ],
              ),
            ),
          );
        }),
        const SizedBox(height: 18),

        // Buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _prevStep,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: AppTheme.hairline),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(isId ? '← Kembali' : '← Back', style: const TextStyle(color: Colors.white)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _nextStep,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.textWhite,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  isId ? 'Instruksi Bayar →' : 'Next Step →',
                  style: const TextStyle(color: AppTheme.pureBlack, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // STEP 4: PROOF UPLOAD & ORDER COMPLETION
  Widget _buildStep4ProofUpload() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Payment Details Box
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.cardWash,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.hairline),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isId ? 'JUMLAH YANG WAJIB DITRANSFER' : 'TOTAL AMOUNT TO TRANSFER',
                style: const TextStyle(color: AppTheme.textAshDim, fontSize: 10, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 4),
              Text(
                PricingService.formatMoney(widget.total, widget.currency, widget.lang),
                style: const TextStyle(
                  color: AppTheme.textWhite,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              const Divider(color: AppTheme.hairline, height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Metode Pembayaran:', style: TextStyle(color: AppTheme.textAsh, fontSize: 11)),
                  Text(
                    _selectedPaymentMethod.toUpperCase(),
                    style: const TextStyle(color: AppTheme.purpleLight, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('Nomor Rekening / Merchant:', style: TextStyle(color: AppTheme.textAsh, fontSize: 11)),
                  Text(
                    '0851-8313-1490',
                    style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Proof Upload Card
        Text(
          isId ? 'UNGGAH BUKTI TRANSFER PEMBAYARAN' : 'UPLOAD PAYMENT PROOF SCREENSHOT',
          style: const TextStyle(color: AppTheme.textAsh, fontSize: 10, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),

        InkWell(
          onTap: () {
            setState(() => _hasProofFile = true);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(isId ? 'Bukti transfer dipilih!' : 'Payment proof attached!'),
                duration: const Duration(seconds: 1),
                backgroundColor: AppTheme.cardWash,
              ),
            );
          },
          borderRadius: BorderRadius.circular(14),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24),
            decoration: BoxDecoration(
              color: AppTheme.cardWash,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _hasProofFile ? AppTheme.emeraldGreen : AppTheme.hairline,
                width: 1.5,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  _hasProofFile ? Icons.check_circle : Icons.cloud_upload_outlined,
                  size: 36,
                  color: _hasProofFile ? AppTheme.emeraldGreen : AppTheme.purpleLight,
                ),
                const SizedBox(height: 8),
                Text(
                  _hasProofFile
                      ? (isId ? '✓ Bukti Transfer Siap Dikirim' : '✓ Transfer Proof Attached')
                      : (isId ? 'Ketuk untuk Memilih Foto Bukti Bayar' : 'Tap to Choose Payment Proof'),
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 2),
                Text(
                  isId ? 'Mendukung JPG, PNG, atau tangkapan layar m-banking' : 'Supports JPG, PNG or mobile banking screenshot',
                  style: const TextStyle(color: AppTheme.textAshDim, fontSize: 10),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Action Buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _submitting ? null : _prevStep,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: AppTheme.hairline),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(isId ? '← Kembali' : '← Back', style: const TextStyle(color: Colors.white)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: (_hasProofFile && !_submitting) ? _submitOrder : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.textWhite,
                  disabledBackgroundColor: Colors.white24,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _submitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                      )
                    : Text(
                        isId ? 'Kirim & Buka Tiket →' : 'Submit & Open Ticket →',
                        style: TextStyle(
                          color: _hasProofFile ? AppTheme.pureBlack : AppTheme.textAshDim,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
