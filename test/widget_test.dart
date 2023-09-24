import 'package:flutter_test/flutter_test.dart';
import 'package:user_app/main.dart';

void main() {
  testWidgets('Blank Test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());
  });
}
