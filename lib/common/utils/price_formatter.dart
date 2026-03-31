import 'package:intl/intl.dart';

final _currencyFormatter = NumberFormat.currency(locale: 'zh_CN', symbol: '¥', decimalDigits: 2);

String formatPrice(double value) {
  return _currencyFormatter.format(value);
}
