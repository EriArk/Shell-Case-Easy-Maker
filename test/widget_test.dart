import 'package:flutter_test/flutter_test.dart';
import 'package:shell_case_easy_maker/app/app_strings.dart';
import 'package:shell_case_easy_maker/app/case_maker_app.dart';

void main() {
  testWidgets('workspace shell shows semantic enclosure UI', (tester) async {
    await tester.pumpWidget(const CaseMakerApp());
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.appTitle), findsOneWidget);
    expect(find.text(AppStrings.inspectorTitle), findsOneWidget);
    expect(find.text(AppStrings.previewReady), findsOneWidget);
    expect(find.textContaining('120 mm'), findsOneWidget);
  });
}
