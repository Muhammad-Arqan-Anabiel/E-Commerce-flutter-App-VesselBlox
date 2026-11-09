import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/prefs_service.dart';
import '../theme/app_theme.dart';

class MoreScreen extends StatelessWidget {
  final PrefsService prefs;
  final VoidCallback onOpenOrderStatus;
  final VoidCallback onOpenMyOrders;
  final VoidCallback onOpenTutorial;
  final VoidCallback onOpenReferral;
  final VoidCallback onOpenCalculator;
  final VoidCallback onOpenGifting;

  const MoreScreen({
    super.key,
    required this.prefs,
    required this.onOpenOrderStatus,
    required this.onOpenMyOrders,
    required this.onOpenTutorial,
    required this.onOpenReferral,
    required this.onOpenCalculator,
    required this.onOpenGifting,
  });

  @override
  Widget build(BuildContext context) {
    final isId = prefs.lang == 'id';

    return Scaffold(
      backgroundColor: AppTheme.voidBlack,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.hairlineStrong),
                      ),
                      child: const Center(
                        child: Icon(Icons.apps_rounded, color: Colors.white, size: 28),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      isId ? 'Layanan & Fitur Lainnya' : 'More Services & Features',
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
                          ? 'Pusat akses cepat ke fitur pendukung VesselBlox: cek status pesanan, panduan tutorial, riwayat transaksi, kode referral, dan bantuan komunitas.'
                          : 'Quick access hub for all supporting VesselBlox tools: order tracking, guides, order history, referrals, and community support.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppTheme.ash,
                        fontSize: 12.5,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Feature cards
              _featureCard(
                tag: isId ? 'LIVE SUPPORT' : 'LIVE SUPPORT',
                badge: isId ? 'AKTIF' : 'ACTIVE',
                badgeColor: const Color(0xFF10B981),
                icon: '💬',
                title: isId ? 'Cek Status & Chat Admin' : 'Check Status & Staff Chat',
                desc: isId
                    ? 'Lacak progres pesananmu secara real-time dan kirim pesan langsung ke staf VesselBlox.'
                    : 'Track order progress in real-time and chat directly with VesselBlox support staff.',
                cta: isId ? 'Buka Tiket →' : 'Open Ticket →',
                onTap: onOpenOrderStatus,
              ),
              const SizedBox(height: 12),

              _featureCard(
                tag: isId ? 'TRANSAKSI' : 'TRANSACTIONS',
                badge: isId ? 'RIWAYAT' : 'HISTORY',
                badgeColor: Colors.blueAccent,
                icon: '🧾',
                title: isId ? 'Riwayat Pesanan Saya' : 'My Order History',
                desc: isId
                    ? 'Lihat kembali daftar seluruh pesanan Robux yang pernah kamu beli di perangkat ini.'
                    : 'Review all your past Robux transactions made on this device.',
                cta: isId ? 'Lihat Pesanan →' : 'View Orders →',
                onTap: onOpenMyOrders,
              ),
              const SizedBox(height: 12),

              _featureCard(
                tag: isId ? 'EDUKASI' : 'EDUCATION',
                badge: isId ? 'PANDUAN' : 'GUIDE',
                badgeColor: Colors.amberAccent,
                icon: '📖',
                title: isId ? 'Panduan Tutorial' : 'Ordering Tutorial',
                desc: isId
                    ? 'Langkah lengkap cara membuat Gamepass Roblox, setting harga pajak 30%, dan join Group Funds.'
                    : 'Full guide on creating a Roblox Gamepass, setting prices with 30% tax, and joining Group Funds.',
                cta: isId ? 'Buka Panduan →' : 'Open Guide →',
                onTap: onOpenTutorial,
              ),
              const SizedBox(height: 12),

              _featureCard(
                tag: isId ? 'PROMOSI' : 'PROMOTION',
                badge: isId ? 'DISKON 1.8%' : '1.8% OFF',
                badgeColor: AppTheme.purple,
                icon: '🎟️',
                title: isId ? 'Program Referral & Diskon' : 'Referral Program & Codes',
                desc: isId
                    ? 'Gunakan kode referral resmi "VESSEL" untuk klaim potongan harga otomatis.'
                    : 'Use official referral code "VESSEL" for automatic instant discounts.',
                cta: isId ? 'Lihat Kode →' : 'View Code →',
                onTap: onOpenReferral,
              ),
              const SizedBox(height: 12),

              _featureCard(
                tag: isId ? 'KOMUNITAS' : 'COMMUNITY',
                badge: '24/7 ONLINE',
                badgeColor: const Color(0xFF5865F2),
                icon: '👾',
                title: isId ? 'Komunitas Discord VesselBlox' : 'VesselBlox Discord Community',
                desc: isId
                    ? 'Bergabung dengan ribuan pemain Roblox lainnya, dapatkan info giveaway mingguan & update restock Robux.'
                    : 'Join thousands of Roblox players, get weekly giveaway updates and restock notifications.',
                cta: isId ? 'Join Discord Server ↗' : 'Join Discord Server ↗',
                onTap: () async {
                  final uri = Uri.parse('https://discord.gg/PnuN3hYme');
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
              ),
              const SizedBox(height: 24),

              // Quick Navigation To Delivery Methods Card
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
                      isId ? 'METODE TOP UP UTAMA' : 'CORE TOP UP METHODS',
                      style: const TextStyle(
                        color: AppTheme.ashDim,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isId ? 'Ingin langsung memesan Robux atau Item?' : 'Ready to order Robux or Items?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isId
                          ? 'Buka kalkulator untuk Gamepass & Group Funds, atau jelajahi katalog Game Gifting.'
                          : 'Open calculator for Gamepass & Group Funds, or browse Game Gifting catalog.',
                      style: const TextStyle(
                        color: AppTheme.ash,
                        fontSize: 11.5,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.purple,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            onPressed: onOpenCalculator,
                            child: Text(
                              isId ? '⚡ Kalkulator Robux' : '⚡ Robux Calculator',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.white,
                              side: const BorderSide(color: AppTheme.hairlineStrong),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: onOpenGifting,
                            child: Text(
                              isId ? '🎁 Game Gifting' : '🎁 Game Gifting',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _featureCard({
    required String tag,
    required String badge,
    required Color badgeColor,
    required String icon,
    required String title,
    required String desc,
    required String cta,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardSurface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppTheme.hairlineStrong),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top tag & badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  tag,
                  style: const TextStyle(
                    color: AppTheme.ashDim,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: badgeColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: badgeColor.withOpacity(0.4)),
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(
                      color: badgeColor,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Icon + Title
            Row(
              children: [
                Text(icon, style: const TextStyle(fontSize: 22)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Description
            Text(
              desc,
              style: const TextStyle(
                color: AppTheme.ash,
                fontSize: 12,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 14),

            // CTA footer line
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  cta,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, color: AppTheme.ash, size: 12),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
