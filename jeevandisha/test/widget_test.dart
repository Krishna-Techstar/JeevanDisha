import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:jeevandisha/main.dart';

void main() {
  testWidgets('App boots with design system', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: JeevanDishaApp()));
    expect(find.text('JeevanDisha'), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
  });
}
