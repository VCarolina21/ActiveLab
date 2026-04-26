import 'package:flutter_test/flutter_test.dart';
import 'package:activelab/main.dart';

void main() {
  testWidgets('Cek aplikasi jalan', (WidgetTester tester) async {
    await tester.pumpWidget(ActiveLabApp());
  });
}