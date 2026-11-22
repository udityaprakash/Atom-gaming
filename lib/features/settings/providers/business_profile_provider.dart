import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/database/database_provider.dart';

class BusinessProfileData {
  final String storeName;
  final String storePhone;
  final String storeAddress;
  final String receiptFooter;

  const BusinessProfileData({
    this.storeName = 'atom Gaming Zone',
    this.storePhone = '',
    this.storeAddress = '',
    this.receiptFooter = 'Thank you for gaming with us! Visit again.',
  });
}

/// Reactive stream provider that emits latest business profile settings whenever updated
final businessProfileStreamProvider = StreamProvider<BusinessProfileData>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.select(db.appSettings).watch().map((settings) {
    final map = {for (final s in settings) s.key: s.value};
    final name = map['store_name']?.trim();
    final phone = map['store_phone']?.trim();
    final address = map['store_address']?.trim();
    final footer = map['receipt_footer']?.trim();

    return BusinessProfileData(
      storeName: (name != null && name.isNotEmpty) ? name : 'atom Gaming Zone',
      storePhone: phone ?? '',
      storeAddress: address ?? '',
      receiptFooter: (footer != null && footer.isNotEmpty)
          ? footer
          : 'Thank you for gaming with us! Visit again.',
    );
  });
});
