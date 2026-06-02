import 'package:flutter_test/flutter_test.dart';
import 'package:campus_pulse/main.dart';

void main() {
  testWidgets('App loads onboarding screen', (WidgetTester tester) async {
    await tester.pumpWidget(const EvntNxtApp());
    expect(find.text('EvntNxt'), findsOneWidget);
    expect(find.text("I'm a Student"), findsOneWidget);
    expect(find.text("I'm a Club Head"), findsOneWidget);
  });
}
