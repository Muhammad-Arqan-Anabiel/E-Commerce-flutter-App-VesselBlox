import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class PrefsService extends ChangeNotifier {
  String _lang = 'id';
  String _currency = 'IDR';
  double _usdIdrRate = 16300.0;
  bool _initialized = false;

  String get lang => _lang;
  String get currency => _currency;
  double get usdIdrRate => _usdIdrRate;
  bool get isId => _lang == 'id';
  bool get initialized => _initialized;

  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _lang = prefs.getString('vb_lang') ?? 'id';
      _currency = prefs.getString('vb_cur') ?? 'IDR';
      _initialized = true;
      notifyListeners();

      // Fetch live exchange rate in background
      _fetchLiveExchangeRate();
    } catch (_) {
      _initialized = true;
      notifyListeners();
    }
  }

  Future<void> setLang(String newLang) async {
    if (_lang == newLang) return;
    _lang = newLang;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('vb_lang', newLang);
    } catch (_) {}
  }

  Future<void> setCurrency(String newCurrency) async {
    if (_currency == newCurrency) return;
    _currency = newCurrency;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('vb_cur', newCurrency);
    } catch (_) {}
  }

  Future<void> _fetchLiveExchangeRate() async {
    try {
      final res = await http.get(
        Uri.parse('https://open.er-api.com/v6/latest/USD'),
      ).timeout(const Duration(seconds: 5));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final rate = data['rates']?['IDR'];
        if (rate != null && rate is num && rate > 10000) {
          _usdIdrRate = rate.toDouble();
          notifyListeners();
        }
      }
    } catch (_) {
      // Graceful fallback to default 16300
    }
  }
}
