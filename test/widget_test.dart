import 'package:flutter_test/flutter_test.dart';

import 'package:oboeru_flutter/app.dart';

void main() {
  testWidgets('App loads without error', (WidgetTester tester) async {
    await tester.pumpWidget(const OboeruApp());
    expect(find.text('Oboeru'), findsOneWidget);
  });
}
