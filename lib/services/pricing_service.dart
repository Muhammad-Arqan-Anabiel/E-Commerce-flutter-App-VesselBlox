import 'package:intl/intl.dart';

class PricingQuote {
  final String method;
  final int amount;
  final int beforeTax;
  final int robloxTax;
  final String currency;
  final double subtotal;
  final double discount;
  final double total;
  final bool referralApplied;

  PricingQuote({
    required this.method,
    required this.amount,
    required this.beforeTax,
    required this.robloxTax,
    required this.currency,
    required this.subtotal,
    required this.discount,
    required this.total,
    required this.referralApplied,
  });
}

typedef QuoteResult = PricingQuote;

class PricingService {
  static const int referralBp = 180; // 1.8%
  static const int referralMaxRobuxExclusive = 1500;
  static const int idrRoundUpTo = 100;

  static const Map<String, int> unitPriceUsdMicro = {
    'gamepass': 7100,    // 0.0071
    'gifting': 7100,     // 0.0071
    'groupfunds': 10000, // 0.0100
  };

  static const Map<String, int> robloxTaxPercent = {
    'gamepass': 30,
    'gifting': 0,
    'groupfunds': 0,
  };

  static const Map<String, int> minRobux = {
    'gamepass': 1000,
    'gifting': 100,
    'groupfunds': 1000,
  };

  static const Map<String, int> maxRobux = {
    'gamepass': 100000,
    'gifting': 100000,
    'groupfunds': 100000,
  };

  static int beforeTaxFor(int n, int tax) {
    if (tax <= 0) return n;
    return ((n * 100) / (100 - tax)).ceil();
  }

  static int netRobuxFrom(int p, int tax) {
    if (tax <= 0) return p;
    return ((p * (100 - tax)) / 100).floor();
  }

  static PricingQuote quote({
    required String method,
    required int amount,
    required String currency,
    double usdIdr = 16300.0,
    bool referralValid = true,
  }) {
    return calculateQuote(
      method: method,
      amount: amount,
      currency: currency,
      usdIdrRate: usdIdr,
      referralValid: referralValid,
    );
  }

  static PricingQuote calculateQuote({
    required String method,
    required int amount,
    required String currency,
    double usdIdrRate = 16300.0,
    bool referralValid = true,
  }) {
    final taxPercent = robloxTaxPercent[method] ?? 0;
    final unitMicro = unitPriceUsdMicro[method] ?? 7100;
    final beforeTax = beforeTaxFor(amount, taxPercent);
    final robloxTax = beforeTax - netRobuxFrom(beforeTax, taxPercent);

    final referralApplied = referralValid && amount < referralMaxRobuxExclusive;

    final usdMicro = amount * unitMicro;
    double raw;
    if (currency == 'USD') {
      raw = (usdMicro / 10000.0).roundToDouble() / 100.0; // in dollars
    } else {
      raw = (usdMicro / 1000000.0) * usdIdrRate; // in IDR
    }

    double round(double val) {
      if (currency == 'USD') {
        return (val * 100).round() / 100.0;
      } else {
        return ((val / idrRoundUpTo).ceil() * idrRoundUpTo).toDouble();
      }
    }

    final subtotal = round(raw);
    final total = referralApplied ? round(raw * (1.0 - (referralBp / 10000.0))) : subtotal;
    final discount = subtotal - total;

    return PricingQuote(
      method: method,
      amount: amount,
      beforeTax: beforeTax,
      robloxTax: robloxTax,
      currency: currency,
      subtotal: subtotal,
      discount: discount,
      total: total,
      referralApplied: referralApplied,
    );
  }

  static String formatMoney(double value, String currency, String lang) {
    if (currency == 'USD') {
      final formatter = NumberFormat.currency(
        locale: lang == 'id' ? 'id_ID' : 'en_US',
        symbol: r'$',
        decimalDigits: 2,
      );
      return formatter.format(value);
    } else {
      final formatter = NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'Rp ',
        decimalDigits: 0,
      );
      return formatter.format(value);
    }
  }

  static String formatInt(int n, String lang) {
    final formatter = NumberFormat.decimalPattern(lang == 'id' ? 'id_ID' : 'en_US');
    return formatter.format(n);
  }
}
