class AppConstants {
  AppConstants._();

  static const String appName = 'atom';
  static const String appVersion = '1.1.0';
  static const String currencySymbol = '₹';

  // Room Statuses
  static const String statusAvailable = 'AVAILABLE';
  static const String statusOccupied = 'OCCUPIED';
  static const String statusEndingSoon = 'ENDING_SOON';
  static const String statusPaused = 'PAUSED';
  static const String statusMaintenance = 'MAINTENANCE';
  static const String statusDeactivated = 'DEACTIVATED';

  // Equipment Types
  static const List<String> equipmentTypes = [
    'PS5',
    'PS4',
    'Xbox Series X',
    'Xbox Series S',
    'Gaming PC',
    'Nintendo Switch',
    'VR Headset',
  ];

  // Session Statuses
  static const String sessionActive = 'ACTIVE';
  static const String sessionOvertime = 'OVERTIME';
  static const String sessionPaused = 'PAUSED';
  static const String sessionCompleted = 'COMPLETED';
  static const String sessionCancelled = 'CANCELLED';

  // Payment Statuses
  static const String paymentPaid = 'PAID';
  static const String paymentUnpaid = 'UNPAID';

  // Payment Methods
  static const String methodCash = 'CASH';

  // Session Duration Presets in Minutes
  static const List<int> durationPresets = [30, 60, 90, 120];

  // Extension Presets in Minutes
  static const List<int> extensionPresets = [15, 30, 60];
}
