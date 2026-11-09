import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SupportHubCard extends StatelessWidget {
  final bool isId;
  final VoidCallback onCheckStatus;
  final VoidCallback onMyOrders;

  const SupportHubCard({
    Key? key,
    required this.isId,
    required this.onCheckStatus,
    required this.onMyOrders,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isId ? 'PUSAT BANTUAN' : 'SUPPORT HUB',
            style: const TextStyle(
              color: AppTheme.textAshDim,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isId ? 'Sudah Beli? Lacak Pesanan Anda' : 'Already Ordered? Track Your Status',
            style: const TextStyle(
              color: AppTheme.textWhite,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isId
                ? 'Gunakan Order ID Anda untuk mengecek status pesanan atau mengobrol dengan staf kami.'
                : 'Use your Order ID to check real-time order status or chat with our admin.',
            style: const TextStyle(
              color: AppTheme.textAsh,
              fontSize: 11,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),

          // Two action buttons: Left Purple, Right Hairline / White Text (Riwayat Pesanan Saya)
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: onCheckStatus,
                  icon: const Text('💬', style: TextStyle(fontSize: 12)),
                  label: Text(
                    isId ? 'Cek Status' : 'Check Status',
                    style: const TextStyle(
                      color: AppTheme.textWhite,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.purplePrimary,
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onMyOrders,
                  icon: const Text('🧾', style: TextStyle(fontSize: 12)),
                  label: Text(
                    isId ? 'Pesanan Saya' : 'My Orders',
                    style: const TextStyle(
                      color: AppTheme.textWhite,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: AppTheme.cardWash,
                    side: const BorderSide(color: AppTheme.hairline),
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
