import 'package:flutter_test/flutter_test.dart';
import 'package:jibon_admin/main.dart';

void main() {
  testWidgets('Admin panel smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const JibonAdminApp());
  });
}