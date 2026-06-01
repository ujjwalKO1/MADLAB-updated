import 'package:flutter_test/flutter_test.dart';
import 'package:campus_pulse/main.dart';

void main() {
  testWidgets('App loads onboarding screen', (WidgetTester tester) async {
    await tester.pumpWidget(const CampusPulseApp());
    expect(find.text('Campus Pulse'), findsOneWidget);
    expect(find.text("I'm a Student"), findsOneWidget);
    expect(find.text("I'm a Club Head"), findsOneWidget);
  });
}
