import 'package:flutter/material.dart';
import '../services/cart_service.dart';
import '../theme/app_theme.dart';

class FloatingCartButton extends StatelessWidget {
  final CartService cart;
  final bool isId;
  final VoidCallback onTap;

  const FloatingCartButton({
    Key? key,
    required this.cart,
    required this.isId,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (cart.itemCount == 0) return const SizedBox.shrink();

    return Positioned(
      bottom: 20,
      right: 16,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(30),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppTheme.textWhite,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: AppTheme.purplePrimary.withOpacity(0.5), width: 2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppTheme.purplePrimary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '🛒 ${isId ? "Keranjang" : "Cart"} (${cart.totalQuantity})',
                  style: const TextStyle(
                    color: AppTheme.pureBlack,
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppTheme.pureBlack.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${cart.totalRobux} R\$',
                    style: const TextStyle(
                      color: AppTheme.pureBlack,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
