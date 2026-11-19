import 'package:intl/intl.dart';

final _money = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
final _dateTime = DateFormat('dd/MM/yyyy HH:mm', 'pt_BR');
final _shortDate = DateFormat('dd/MM', 'pt_BR');

String money(double v) => _money.format(v);
String dateTimeStr(DateTime d) => _dateTime.format(d);
String shortDate(DateTime d) => _shortDate.format(d);
String num2(double v) => NumberFormat('#,##0.00', 'pt_BR').format(v);
String num0(double v) => NumberFormat('#,##0', 'pt_BR').format(v);

/// Aceita vírgula ou ponto como separador decimal.
double? parseNum(String? s) {
  if (s == null) return null;
  return double.tryParse(s.trim().replaceAll(',', '.'));
}
