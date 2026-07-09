class Constants {
  // Prevents instantiation and extension
  Constants._();

  static const googleServerClientId = String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID');

  static const String selectedDeviceIdKey = 'selected_device_id';
  static const String selectedConnectionTypeKey = 'selected_connection_type';
  static const String selectedPaperSizeKey = 'selected_paper_size';
  static const String selectedBrightnessKey = 'selected_brightness';

  static const int minSyncIntervalToleranceForCriticalInMinutes = 5;
  static const int minSyncIntervalToleranceForLessCriticalInMinutes = 100;

  static const double listTileFontSize = 13;

  // Google OAuth scopes required for user authentication
  static const List<String> authScopes = [
    'https://www.googleapis.com/auth/userinfo.profile',
    'https://www.googleapis.com/auth/userinfo.email',
  ];

  // Non-critical error libraries that should be logged but not navigate to error screen
  static const nonCriticalErrorLibraries = {
    'image resource service',
  };

  static const String dateFormatDDMMYYYY = 'dd/MM/yyyy';

  // Shared Google Drive folder that backup exports are uploaded to
  static const String driveBackupFolderId = '1c0cznqHuK3hCUdLC5LRtSJoSGb1qM_qT';

  // Auto-export daily backup schedule
  static const String autoExportHourKey = 'auto_export_hour';
  static const String autoExportMinuteKey = 'auto_export_minute';
  static const String autoExportLastDateKey = 'auto_export_last_date';
  static const String autoExportAllowedKey = 'auto_export_allowed';
  static const String backupPassword = '123';
}
