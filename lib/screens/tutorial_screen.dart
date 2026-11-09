import 'package:flutter/material.dart';
import '../services/prefs_service.dart';
import '../theme/app_theme.dart';

class TutorialScreen extends StatefulWidget {
  final PrefsService prefs;
  final VoidCallback? onGoHome;

  const TutorialScreen({
    super.key,
    required this.prefs,
    this.onGoHome,
  });

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  int _activeTab = 0; // 0: Gamepass, 1: Gifting, 2: Group Funds

  @override
  Widget build(BuildContext context) {
    final isId = widget.prefs.lang == 'id';

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
                    const Text('📖', style: TextStyle(fontSize: 12)),
                    const SizedBox(width: 6),
                    Text(
                      isId ? 'Panduan Lengkap' : 'Step-by-Step Guide',
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
                isId ? 'Tutorial Pembuatan & Pemesanan' : 'Robux Ordering Tutorial',
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
                    ? 'Panduan terperinci cara membuat Gamepass, menerima item Game Gifting, atau bergabung ke Group Funds resmi VesselBlox.'
                    : 'Detailed guide on creating a Gamepass, receiving in-game gift items, or joining our official Group Funds.',
                style: const TextStyle(
                  color: AppTheme.ash,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 18),

              // Tab Selector
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppTheme.wash,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.hairline),
                ),
                child: Row(
                  children: [
                    _tabButton(0, 'Gamepass', Icons.local_activity),
                    _tabButton(1, 'Game Gifting', Icons.card_giftcard),
                    _tabButton(2, 'Group Funds', Icons.groups),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Tab Content
              if (_activeTab == 0) _buildGamepassTab(isId),
              if (_activeTab == 1) _buildGiftingTab(isId),
              if (_activeTab == 2) _buildGroupFundsTab(isId),

              const SizedBox(height: 24),

              // CTA Button
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
                  onPressed: widget.onGoHome,
                  child: Text(
                    isId ? 'Beli Robux Sekarang →' : 'Order Robux Now →',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tabButton(int index, String label, IconData icon) {
    final selected = _activeTab == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _activeTab = index),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: selected ? AppTheme.purple : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 14,
                color: selected ? Colors.white : AppTheme.ash,
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  color: selected ? Colors.white : AppTheme.ash,
                  fontSize: 11,
                  fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGamepassTab(bool isId) {
    return Container(
      padding: const EdgeInsets.all(18),
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
              const Text('🎮', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isId ? 'Cara Membuat Gamepass Roblox' : 'How to Create a Roblox Gamepass',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _stepItem(1, isId
              ? 'Buka create.roblox.com di browser dan login dengan akun Roblox yang akan menerima Robux.'
              : 'Open create.roblox.com in your browser and log in with your Roblox account.'),
          _stepItem(2, isId
              ? 'Pilih salah satu Experience / Tempat milikmu, pastikan statusnya Public (bukan Private).'
              : 'Select one of your Experiences / Places, ensure status is Public.'),
          _stepItem(3, isId
              ? 'Di menu sebelah kiri (Monetization), klik Passes, lalu tekan Create a Pass.'
              : 'In left menu (Monetization), click Passes, then click Create a Pass.'),
          _stepItem(4, isId
              ? 'Upload gambar bebas dan beri nama, lalu klik Create Pass.'
              : 'Upload any image and name it, then click Create Pass.'),
          _stepItem(5, isId
              ? 'Buka Pass yang baru dibuat, masuk ke tab Sales, aktifkan toggle Item for Sale.'
              : 'Open the newly created Pass, go to Sales tab, toggle Item for Sale to ON.'),
          _stepItem(6, isId
              ? 'Masukkan harga sesuai rincian kalkulator VesselBlox (contoh: 1.429 R\$ agar kamu menerima 1.000 R\$ bersih). Nonaktifkan Regional Pricing.'
              : 'Set price matching your VesselBlox total (e.g. 1,429 R\$ so you receive 1,000 R\$ net). Turn off Regional Pricing.'),
          _stepItem(7, isId
              ? 'Simpan (Save Changes), lalu salin link URL Pass tersebut dan tempelkan ke formulir pesanan VesselBlox.'
              : 'Save changes, copy the Gamepass URL, and paste it into the VesselBlox order form.'),
          const SizedBox(height: 16),
          // Checklist Box
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.wash,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.hairline),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isId ? '✓ CHECKLIST SEBELUM MEMBELI' : '✓ PRE-PURCHASE CHECKLIST',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                _checklistItem(isId
                    ? 'Harga Gamepass sudah disetel dengan benar (termasuk pajak 30%).'
                    : 'Gamepass price matches exact before-tax calculation.'),
                _checklistItem(isId
                    ? 'Experience berstatus Public sehingga staf kami dapat membelinya.'
                    : 'Experience is Public so our staff can purchase it.'),
                _checklistItem(isId
                    ? 'Robux akan berstatus Pending selama 3-5 hari (ketentuan resmi Roblox).'
                    : 'Robux will be Pending for 3-5 days (official Roblox policy).'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGiftingTab(bool isId) {
    return Container(
      padding: const EdgeInsets.all(18),
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
              const Text('🎁', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isId ? 'Alur Game Gifting Langsung' : 'In-Game Direct Gifting Guide',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _stepItem(1, isId
              ? 'Pilih salah satu dari 6 game populer kami di tab Gifting (Blox Fruits, Fisch, Blade Ball, dll) atau pilih Game Not Listed.'
              : 'Choose from our 6 featured games in Gifting tab or choose Game Not Listed.'),
          _stepItem(2, isId
              ? 'Pilih gamepass yang diinginkan atau masukkan nama item & nominal robux in-game.'
              : 'Select desired gamepasses or enter custom item name & robux nominal.'),
          _stepItem(3, isId
              ? 'Isi username Roblox kamu dengan benar.'
              : 'Provide your accurate Roblox username.'),
          _stepItem(4, isId
              ? 'Selesaikan transfer dan upload bukti pembayaran.'
              : 'Complete payment and upload the transfer receipt.'),
          _stepItem(5, isId
              ? 'Staf kami akan menghubungi kamu lewat chat tiket privat dan mengirimkan item langsung di server game Roblox.'
              : 'Staff will connect with you via private ticket chat and deliver the item directly in-game.'),
        ],
      ),
    );
  }

  Widget _buildGroupFundsTab(bool isId) {
    return Container(
      padding: const EdgeInsets.all(18),
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
              const Text('👥', style: TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isId ? 'Ketentuan Group Funds Roblox' : 'Group Funds Payout Rules',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _stepItem(1, isId
              ? 'Gabung ke grup resmi Roblox VesselBlox sebelum membuat pesanan.'
              : 'Join our official Roblox VesselBlox group before placing your order.'),
          _stepItem(2, isId
              ? 'Pastikan akun Roblox kamu sudah berada di dalam grup minimal 14 hari penuh (kebijakan anti-fraud resmi Roblox Corp).'
              : 'Ensure your account has been in the group for at least 14 days (official Roblox Corp anti-fraud rule).'),
          _stepItem(3, isId
              ? 'Staf toko akan mengirimkan Robux instan tanpa pending langsung ke saldo akunmu melalui payout resmi grup.'
              : 'Staff will transfer instant clean Robux with zero pending hold directly via official group payout.'),
        ],
      ),
    );
  }

  Widget _stepItem(int step, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            margin: const EdgeInsets.only(top: 1, right: 10),
            decoration: BoxDecoration(
              color: AppTheme.wash,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppTheme.hairlineStrong),
            ),
            child: Center(
              child: Text(
                step.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppTheme.ash,
                fontSize: 12.5,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _checklistItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('• ', style: TextStyle(color: Color(0xFF10B981), fontSize: 14)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: AppTheme.ash, fontSize: 11.5, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}
