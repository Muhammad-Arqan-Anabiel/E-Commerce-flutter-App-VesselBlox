import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/prefs_service.dart';
import '../theme/app_theme.dart';

class ReferralScreen extends StatefulWidget {
  final PrefsService prefs;
  final VoidCallback? onUseCode;

  const ReferralScreen({
    super.key,
    required this.prefs,
    this.onUseCode,
  });

  @override
  State<ReferralScreen> createState() => _ReferralScreenState();
}

class _ReferralScreenState extends State<ReferralScreen> {
  bool _copied = false;

  void _copyCode() {
    Clipboard.setData(const ClipboardData(text: 'VESSEL'));
    setState(() => _copied = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.prefs.lang == 'id'
              ? 'Kode VESSEL berhasil disalin ke clipboard!'
              : 'Code VESSEL copied to clipboard!',
        ),
        backgroundColor: AppTheme.purple,
        duration: const Duration(seconds: 2),
      ),
    );
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

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
                    const Text('🎟️', style: TextStyle(fontSize: 12)),
                    const SizedBox(width: 6),
                    Text(
                      isId ? 'Program Diskon Referral' : 'Referral Discount Program',
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
                isId ? 'Hemat 1,8% dengan Kode Referral' : 'Save 1.8% with Referral Codes',
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
                    ? 'Dapatkan potongan harga instan pada setiap pembelian Robux di bawah 1.500 Robux dengan memasukkan kode referral resmi VesselBlox.'
                    : 'Get an instant price deduction on any Robux order under 1,500 Robux by using our official referral code.',
                style: const TextStyle(
                  color: AppTheme.ash,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),

              // Featured Referral Code Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppTheme.cardSurface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.hairlineStrong),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isId ? 'KODE REFERRAL RESMI' : 'OFFICIAL REFERRAL CODE',
                      style: const TextStyle(
                        color: AppTheme.ashDim,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Code slab
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.wash,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.hairline),
                      ),
                      child: Row(
                        children: [
                          const Text('🎁', style: TextStyle(fontSize: 32)),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'VESSEL',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 26,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 3.0,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  isId
                                      ? 'Diskon 1,8% untuk pesanan < 1.500 Robux'
                                      : '1.8% off for orders < 1,500 Robux',
                                  style: const TextStyle(
                                    color: AppTheme.ashDim,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.purple,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              elevation: 0,
                            ),
                            onPressed: _copyCode,
                            child: Text(
                              _copied
                                  ? (isId ? '✓ Tersalin' : '✓ Copied')
                                  : (isId ? 'Salin': 'Copy'),
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Steps 1-2-3
                    Text(
                      isId ? 'CARA MENGGUNAKAN KODE': 'HOW TO USE THE CODE',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _stepCard(
                      1,
                      isId ? 'Pilih Nominal < 1.500 R\$' : 'Select Amount < 1,500 R\$',
                      isId
                          ? 'Diskon 1,8% otomatis aktif untuk pembelian di bawah 1.500 Robux.'
                          : '1.8% discount applies automatically to orders under 1,500 Robux.',
                    ),
                    const SizedBox(height: 8),
                    _stepCard(
                      2,
                      isId ? 'Masukkan Kode VESSEL' : 'Enter Code VESSEL',
                      isId
                          ? 'Ketik atau paste kode VESSEL di kolom Kode Referral saat checkout.'
                          : 'Type or paste code VESSEL in Referral Code input at checkout.',
                    ),
                    const SizedBox(height: 8),
                    _stepCard(
                      3,
                      isId ? 'Nikmati Potongan Harga' : 'Enjoy Direct Discount',
                      isId
                          ? 'Total pembayaran akan terpotong secara instan sebelum melakukan pembayaran.'
                          : 'Your total payment is instantly reduced before transfer.',
                    ),
                  ],
                ),
              ),
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
                  onPressed: widget.onUseCode,
                  child: Text(
                    isId ? 'Gunakan Kode Sekarang →' : 'Use Code Now →',
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

  Widget _stepCard(int num, String title, String desc) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.wash,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.hairline),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                num.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  desc,
                  style: const TextStyle(
                    color: AppTheme.ash,
                    fontSize: 11,
                    height: 1.35,
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
