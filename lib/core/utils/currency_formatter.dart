import 'package:intl/intl.dart';
import '../constants/app_constants.dart';

class CurrencyFormatter {
  CurrencyFormatter._();

  static final NumberFormat _formatter = NumberFormat.currency(
    symbol: AppConstants.currencySymbol,
    decimalDigits: 0,
    locale: 'en_IN',
  );

  static final NumberFormat _decimalFormatter = NumberFormat.currency(
    symbol: AppConstants.currencySymbol,
    decimalDigits: 2,
    locale: 'en_IN',
  );

  static String format(double amount, {bool showDecimals = false}) {
    if (showDecimals || amount % 1 != 0) {
      return _decimalFormatter.format(amount);
    }
    return _formatter.format(amount);
  }
}
