import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class AppLocale {
  // Prevents instantiation and extension
  AppLocale._();

  static Locale defaultLocale = const Locale('vi', 'VN');
  static String defaultPhoneCode = '+84';
  static String defaultCurrencyCode = '₫';

  static const List<Locale> supportedLocales = [
    Locale('vi', 'VN'),
    Locale('en', 'EN'),
  ];

  static const List<LocalizationsDelegate> localizationsDelegates = [
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];
}
