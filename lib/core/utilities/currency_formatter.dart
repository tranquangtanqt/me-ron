import 'package:intl/intl.dart';

import '../locale/app_locale.dart';

/// Currency Formatter dependent on [AppLocale]
class CurrencyFormatter {
  CurrencyFormatter._();

  static const int defaultDecimalDigits = 0;

  static String format(num data, {int? decimalDigits}) {
    return NumberFormat.simpleCurrency(
      locale: 'en_US',
      decimalDigits: decimalDigits ?? defaultDecimalDigits,
    ).format(data);
  }

  static String compact(num data, {int? decimalDigits, bool withSymbol = true}) {
    return NumberFormat.compactSimpleCurrency(
      locale: 'en_US',
      name: withSymbol ? null : '',
      decimalDigits: decimalDigits ?? defaultDecimalDigits,
    ).format(data);
  }

  static String withoutSymbol(num data, {int? decimalDigits}) {
    return NumberFormat.currency(
      locale: 'en_US',
      decimalDigits: decimalDigits ?? defaultDecimalDigits,
      symbol: "",
    ).format(data);
  }

  static String currencySymbol() {
    return NumberFormat.simpleCurrency(
      locale: 'en_US',
    ).currencySymbol;
  }

  static String formatVND(num data, {int? decimalDigits}) {
    final formatter = NumberFormat.currency(
      locale: 'vi_VN',
      symbol: '₫',
      decimalDigits: 0,
    );

    String result = formatter.format(data);
    return result;
  }
}
