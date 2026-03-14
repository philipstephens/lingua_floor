import 'package:flutter_test/flutter_test.dart';
import 'package:lingua_floor/app/lingua_floor_app.dart';

void main() {
  testWidgets('shows LinguaFloor join scaffold', (WidgetTester tester) async {
    await tester.pumpWidget(const LinguaFloorApp());

    expect(find.text('LinguaFloor'), findsOneWidget);
    expect(find.text('Enter as host'), findsOneWidget);
    expect(find.text('Enter as participant'), findsOneWidget);
  });
}
