import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class InvertedWhiteSlab extends StatefulWidget {
  final int gamepassPrice;
  final bool isId;

  const InvertedWhiteSlab({
    Key? key,
    required this.gamepassPrice,
    required this.isId,
  }) : super(key: key);

  @override
  State<InvertedWhiteSlab> createState() => _InvertedWhiteSlabState();
}

class _InvertedWhiteSlabState extends State<InvertedWhiteSlab> {
  bool _copied = false;

  void _copyPrice() {
    Clipboard.setData(ClipboardData(text: widget.gamepassPrice.toString()));
    setState(() => _copied = true);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.isId
              ? 'Harga Gamepass (${widget.gamepassPrice} Robux) tersalin!'
              : 'Gamepass price (${widget.gamepassPrice} Robux) copied!',
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: AppTheme.cardWash,
      ),
    );
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppTheme.textWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.08),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Label & Copy Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.isId ? 'ATUR HARGA GAMEPASS KE' : 'SET GAMEPASS PRICE TO',
                style: TextStyle(
                  color: AppTheme.pureBlack.withOpacity(0.7),
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.8,
                ),
              ),
              InkWell(
                onTap: _copyPrice,
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.pureBlack.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _copied ? Icons.check : Icons.copy,
                        size: 13,
                        color: AppTheme.pureBlack,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _copied
                            ? (widget.isId ? 'Tersalin' : 'Copied')
                            : (widget.isId ? 'Salin' : 'Copy'),
                        style: const TextStyle(
                          color: AppTheme.pureBlack,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Big Bold Number
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                widget.gamepassPrice.toString(),
                style: const TextStyle(
                  color: AppTheme.pureBlack,
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                'Robux',
                style: TextStyle(
                  color: AppTheme.pureBlack.withOpacity(0.8),
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // Subtitle
          Text(
            widget.isId
                ? 'Harga Gamepass sebelum pajak Roblox 30%. Pembeli menerima Robux bersih.'
                : 'Gamepass price before Roblox 30% tax. You will receive clean Robux.',
            style: TextStyle(
              color: AppTheme.pureBlack.withOpacity(0.6),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
