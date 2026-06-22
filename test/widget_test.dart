import 'package:flutter_test/flutter_test.dart';
import 'package:drug/main.dart';
import 'package:drug/constants/app_text.dart';

void main() {
  testWidgets('Welcome Page smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const YouthShieldApp());

    // Verify that the Welcome Page renders with the title and subtitle
    expect(find.text(AppText.appTitle), findsOneWidget);
    expect(find.text(AppText.appSubtitle), findsOneWidget);
  });
}
