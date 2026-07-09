import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/di/app_providers.dart';
import '../../../core/constants/constants.dart';
import '../../../core/services/backup/backup_service.dart';
import '../../../core/services/cloud/drive_upload_service.dart';
import '../../widgets/app_snack_bar.dart';
import 'auto_export_state.dart';

final autoExportNotifierProvider = NotifierProvider<AutoExportNotifier, AutoExportState>(
  AutoExportNotifier.new,
);

class AutoExportNotifier extends Notifier<AutoExportState> {
  @override
  AutoExportState build() {
    final sharedPreferences = ref.watch(sharedPreferencesProvider);
    final hour = sharedPreferences.getInt(Constants.autoExportHourKey);
    final minute = sharedPreferences.getInt(Constants.autoExportMinuteKey);
    final isAllowed = sharedPreferences.getBool(Constants.autoExportAllowedKey) ?? false;

    return AutoExportState(hour: hour, minute: minute, isAllowed: isAllowed);
  }

  Future<void> changeTime({required int hour, required int minute}) async {
    final sharedPreferences = ref.read(sharedPreferencesProvider);
    await sharedPreferences.setInt(Constants.autoExportHourKey, hour);
    await sharedPreferences.setInt(Constants.autoExportMinuteKey, minute);

    state = state.copyWith(hour: hour, minute: minute);
  }

  /// Checks [input] against the backup password. Matching enables auto-export;
  /// a mismatch disables it.
  Future<void> verifyBackupPassword(String input) async {
    final sharedPreferences = ref.read(sharedPreferencesProvider);
    final isAllowed = input == Constants.backupPassword;
    await sharedPreferences.setBool(Constants.autoExportAllowedKey, isAllowed);

    state = state.copyWith(isAllowed: isAllowed);

    if (isAllowed) {
      AppSnackBar.show('Mật khẩu đúng. Đã bật tự động sao lưu.');
    } else {
      AppSnackBar.showError('Mật khẩu không đúng. Đã tắt tự động sao lưu.');
    }
  }

  /// Runs the daily backup export if it's due.
  ///
  /// Rules:
  /// - Already exported today -> skip.
  /// - Before today's scheduled time and yesterday was exported (on track) -> skip.
  /// - Otherwise (past today's scheduled time, or a day was missed) -> export now.
  Future<void> checkAndRunIfDue() async {
    if (!state.isConfigured || !state.isAllowed) return;

    final sharedPreferences = ref.read(sharedPreferencesProvider);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final scheduledToday = DateTime(now.year, now.month, now.day, state.hour!, state.minute!);

    final lastDateString = sharedPreferences.getString(Constants.autoExportLastDateKey);
    final lastDate = lastDateString != null ? DateTime.tryParse(lastDateString) : null;

    if (lastDate != null && _isSameDate(lastDate, today)) return;

    final yesterday = today.subtract(const Duration(days: 1));
    final exportedYesterday = lastDate != null && _isSameDate(lastDate, yesterday);

    if (now.isBefore(scheduledToday) && exportedYesterday) return;

    try {
      final result = await BackupService.exportToLocal();
      await sharedPreferences.setString(Constants.autoExportLastDateKey, today.toIso8601String());

      try {
        await DriveUploadService.uploadFiles(
          files: result.fileContents,
          parentFolderId: Constants.driveBackupFolderId,
          subfolderName: result.timestamp,
        );
        AppSnackBar.show('Đã tự động sao lưu ${result.fileContents.length} file và tải lên Google Drive');
      } catch (e) {
        AppSnackBar.showError('Tự động sao lưu thành công nhưng tải lên Google Drive thất bại: $e');
      }
    } catch (e) {
      AppSnackBar.showError('Tự động sao lưu thất bại: $e');
    }
  }

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
