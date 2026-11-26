import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_run_tracker_app/main.dart';
import 'package:flutter_run_tracker_app/views/show_all_run_ui.dart';

void main() {
  testWidgets('Splash screen shows, then goes to ShowAllRunUi', (tester) async {
    await tester.pumpWidget(const FlutterRunTrackerApp());

    // หน้า splash แสดงชื่อแอป
    expect(find.text('RUN TRACKER'), findsOneWidget);

    // รอครบ 3 วินาที แล้วต้องเปลี่ยนไปหน้า ShowAllRunUi
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    expect(find.byType(ShowAllRunUi), findsOneWidget);
    expect(find.text('RUN TRACKER'), findsNothing);
  });
}
