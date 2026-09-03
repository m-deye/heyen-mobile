import 'order_line.dart';

class RecurringCart {
  const RecurringCart({
    required this.name,
    required this.lines,
    required this.updatedAt,
  });

  final String name;
  final List<OrderLine> lines;
  final DateTime updatedAt;

  int get itemCount =>
      lines.fold<int>(0, (total, line) => total + line.quantity);
}
