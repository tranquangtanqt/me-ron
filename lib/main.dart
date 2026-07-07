import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'app/di/app_providers.dart';
import 'core/services/database/database_service.dart';
import 'core/utilities/console_logger.dart';
import 'firebase_options.dart';
import 'presentation/widgets/app_snack_bar.dart';

void main() async {
  // Initialize binding
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  cl(
    'Firebase app initialized: ${Firebase.app().name} (project: ${Firebase.app().options.projectId})',
    title: 'Firebase',
  );
  unawaited(_verifyFirebaseConnection());

  // Initialize app local db
  await DatabaseService.instance.init();

  // Initialize date formatting
  await initializeDateFormatting();

  // Initialize shared preferences
  final sharedPreferences = await SharedPreferences.getInstance();

  // Set/lock screen orientation
  //await SystemChrome.setPreferredOrientations([]);
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Set Default SystemUIOverlayStyle
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
      statusBarColor: Colors.transparent,
    ),
  );

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(sharedPreferences)],
      child: const App(),
    ),
  );
}

/// Performs a real network round-trip to Firestore to confirm the app
/// can actually reach the Firebase backend, not just that the SDK initialized.
Future<void> _verifyFirebaseConnection() async {
  try {
    await FirebaseFirestore.instance
        .collection('_connection_check')
        .limit(1)
        .get(const GetOptions(source: Source.server));

    _notifyFirebaseConnection('Đã kết nối đám mây thành công.');
    cl('Firebase connection check: OK (reached Firestore server)', title: 'Firebase');
  } on FirebaseException catch (e) {
    // A response from the server (even permission-denied) still proves connectivity.
    _notifyFirebaseConnection('Đã kết nối đám mây thành công.');
    cl(
      'Firebase connection check: reached server, response=${e.code}',
      title: 'Firebase',
      type: LogType.warning,
    );
  } catch (e) {
    _notifyFirebaseConnection('Kết nối đám mây thất bại. Vui lòng kiểm tra mạng.', isError: true);
    cl('Firebase connection check: FAILED — $e', title: 'Firebase', type: LogType.error);
  }
}

void _notifyFirebaseConnection(String message, {bool isError = false}) {
  try {
    if (isError) {
      AppSnackBar.showError(message);
    } else {
      // AppSnackBar.show(message);
    }
  } catch (_) {
    // Giao diện chưa sẵn sàng để hiện thông báo (ví dụ phản hồi quá nhanh lúc khởi động) -> bỏ qua.
  }
}
