import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker_app/main.dart';

void main() {
  testWidgets('App loads splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const ExpenseTrackerApp());
    // Verify app title / splash branding appears
    expect(find.text('ExpenseTracker'), findsOneWidget);
  });
}
