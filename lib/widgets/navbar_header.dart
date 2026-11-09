import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/prefs_service.dart';
import '../theme/app_theme.dart';

class NavbarHeader extends StatelessWidget {
  final PrefsService prefs;

  const NavbarHeader({Key? key, required this.prefs}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        bottom: 12,
        left: 16,
        right: 16,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.voidBg,
        border: Border(
          bottom: BorderSide(color: AppTheme.hairline, width: 1),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo & Title
          Row(
            children: [
              Image.asset(
                'assets/images/vesselblox_mark_v2.png',
                width: 32,
                height: 32,
                errorBuilder: (_, __, ___) => Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppTheme.purplePrimary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Text('V', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    'VesselBlox',
                    style: TextStyle(
                      color: AppTheme.textWhite,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    'ROBUX MARKETPLACE',
                    style: TextStyle(
                      color: AppTheme.textAshDim,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Actions: Language Toggle, Currency Toggle, Discord
          Row(
            children: [
              // Currency Toggle Pill
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.cardWash,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.hairline),
                ),
                child: Row(
                  children: [
                    _currencyBtn('IDR'),
                    _currencyBtn('USD'),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Language Toggle
              InkWell(
                onTap: () {
                  prefs.setLang(prefs.lang == 'id' ? 'en' : 'id');
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppTheme.cardWash,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.hairline),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.language, size: 14, color: AppTheme.textAsh),
                      const SizedBox(width: 4),
                      Text(
                        prefs.lang.toUpperCase(),
                        style: const TextStyle(
                          color: AppTheme.textWhite,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Discord Icon
              InkWell(
                onTap: () async {
                  final url = Uri.parse('https://discord.gg/PnuN3hYme');
                  try {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  } catch (_) {}
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: AppTheme.discordColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.discordColor.withOpacity(0.4)),
                  ),
                  child: const Icon(
                    Icons.sports_esports,
                    size: 15,
                    color: Color(0xFFA5B4FC),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _currencyBtn(String curr) {
    final active = prefs.currency == curr;
    return InkWell(
      onTap: () => prefs.setCurrency(curr),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: active ? AppTheme.textWhite : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          curr,
          style: TextStyle(
            color: active ? AppTheme.pureBlack : AppTheme.textAsh,
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}
