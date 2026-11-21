/// 金额格式化：¥1,234.50
String formatMoney(double value) {
  final negative = value < 0;
  final abs = value.abs();
  final text = abs.toStringAsFixed(2);
  final parts = text.split('.');
  final intPart = parts[0];
  final buffer = StringBuffer();
  for (var i = 0; i < intPart.length; i++) {
    if (i > 0 && (intPart.length - i) % 3 == 0) buffer.write(',');
    buffer.write(intPart[i]);
  }
  return '${negative ? '-' : ''}¥$buffer.${parts[1]}';
}

/// 距离格式化：850m / 1.2km
String formatDistance(double km) =>
    km < 1 ? '${(km * 1000).round()}m' : '${km.toStringAsFixed(1)}km';

/// 日期格式化：2026-11-21
String formatDate(DateTime d) =>
    '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

/// 日期时间格式化：2026-11-21 15:30
String formatDateTime(DateTime d) =>
    '${formatDate(d)} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
