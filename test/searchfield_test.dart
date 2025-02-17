import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:searchfield/searchfield.dart';

void main() {
  Widget _boilerplate({required Widget child}) {
    return MaterialApp(
      home: Directionality(
        textDirection: TextDirection.ltr,
        child: MediaQuery(
          data: const MediaQueryData(size: Size(800.0, 600.0)),
          child: Center(
            key: const Key('centerKey'),
            child: Material(
              child: child,
            ),
          ),
        ),
      ),
    );
  }

  group('Searchfield integration tests', () {
    testWidgets(
        'Test assert: Initial value should either be null or should be present in suggestions list.',
        (WidgetTester tester) async {
      await tester.pump();

      expect(
          () => _boilerplate(
              child: SearchField<String>(
                  suggestions: ['ABC', 'DEF']
                      .map<SearchFieldListItem<String>>(
                          (e) => SearchFieldListItem(e))
                      .toList(),
                  initialValue: SearchFieldListItem<String>('ABCD'))),
          throwsAssertionError);

      await tester.pumpWidget(_boilerplate(
          child: SearchField<String>(
        key: const Key('searchfield'),
        suggestions:
            ['ABC', 'DEF'].map((e) => SearchFieldListItem<String>(e)).toList(),
      )));

      final finder = find.byType(TextFormField);
      expect(finder, findsOneWidget);
    });
    testWidgets('Searchfield should set initial Value',
        (WidgetTester tester) async {
      await tester.pumpWidget(_boilerplate(
          child: SearchField(
        key: const Key('searchfield'),
        suggestions:
            ['ABC', 'DEF'].map((e) => SearchFieldListItem<String>(e)).toList(),
        initialValue: SearchFieldListItem<String>('ABC'),
      )));
      final finder = find.text('ABC');
      expect(finder, findsOneWidget);
      final finder2 = find.text('DEF');
      expect(finder2, findsNothing);
    });

    testWidgets('ListView should be visible when searchfield is tapped',
        (WidgetTester tester) async {
      await tester.pumpWidget(_boilerplate(
          child: SearchField(
        key: const Key('searchfield'),
        suggestions: ['ABC', 'DEF', 'GHI']
            .map((e) => SearchFieldListItem<String>(e))
            .toList(),
        suggestionState: Suggestion.expand,
      )));
      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.byType(ListView), findsNothing);
      await tester.tap(find.byType(TextFormField));

      // to fix: enter Text isn't required to view the listview, since `suggestionState: Suggestion.expand`
      await tester.enterText(find.byType(TextFormField), 'a');
      await tester.pumpAndSettle();
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('Searchfield should show searched suggestions',
        (WidgetTester tester) async {
      final controller = TextEditingController();
      await tester.pumpWidget(_boilerplate(
          child: SearchField(
        key: const Key('searchfield'),
        suggestions: ['ABC', 'DEF', 'GHI', 'JKL']
            .map((e) => SearchFieldListItem<String>(e))
            .toList(),
        controller: controller,
        suggestionState: Suggestion.expand,
      )));
      final listFinder = find.byType(ListView);
      final textField = find.byType(TextFormField);
      expect(textField, findsOneWidget);
      expect(listFinder, findsNothing);
      await tester.tap(textField);
      await tester.enterText(textField, 'A');
      await tester.pumpAndSettle();
      expect(listFinder, findsOneWidget);
      expect(find.text('ABC'), findsOneWidget);
      expect(listFinder.evaluate().length, 1);
      // await tester.enterText(textField, '');
      // print('text in controller: ${controller.text}');
      // await tester.pumpAndSettle();
      // expect(listFinder.evaluate().length, kOptionsCount);
    });

    testWidgets('Searchfield should show empty widget for no results',
        (WidgetTester tester) async {
      final controller = TextEditingController();
      await tester.pumpWidget(_boilerplate(
          child: SearchField(
        key: const Key('searchfield'),
        suggestions: ['ABC', 'DEF', 'GHI', 'JKL']
            .map((e) => SearchFieldListItem<String>(e))
            .toList(),
        controller: controller,
        emptyWidget: const Text('No results'),
        suggestionState: Suggestion.expand,
      )));
      final listFinder = find.byType(ListView);
      final textField = find.byType(TextFormField);
      expect(textField, findsOneWidget);
      expect(listFinder, findsNothing);
      await tester.tap(textField);
      await tester.enterText(textField, 'A');
      await tester.pumpAndSettle();
      expect(listFinder, findsOneWidget);
      expect(find.text('ABC'), findsOneWidget);
      expect(listFinder.evaluate().length, 1);
      await tester.enterText(textField, 'text not in list');
      await tester.pumpAndSettle();
      expect(listFinder, findsNothing);
      expect(find.text('No results'), findsOneWidget);
    });
  });

  testWidgets(
      'Searchfield Suggestions should default height should be less than 175 when suggestions count < 5',
      (WidgetTester tester) async {
    final controller = TextEditingController();
    final kdefaultLengthInViewPort = 5;
    final kdefaultHeight = 35;
    final suggestionListLength = 4;
    await tester.pumpWidget(_boilerplate(
        child: SearchField(
      key: const Key('searchfield'),
      suggestions: ['ABC', 'DEF', 'GHI', 'JKL']
          .map((e) => SearchFieldListItem<String>(e))
          .toList(),
      controller: controller,
      suggestionState: Suggestion.expand,
    )));
    final listFinder = find.byType(ListView);
    final textField = find.byType(TextFormField);
    expect(textField, findsOneWidget);
    expect(listFinder, findsNothing);
    await tester.tap(textField);
    await tester.enterText(textField, '');
    await tester.pumpAndSettle();
    expect(listFinder, findsOneWidget);
    final baseSize = tester.getSize(listFinder);
    final resultingHeight = baseSize.height;
    final expectedHeight =
        min(suggestionListLength, kdefaultLengthInViewPort) * kdefaultHeight;
    expect(resultingHeight, equals(expectedHeight));
  });
  testWidgets(
      'Searchfield Suggestions default height should not exceed 175 (35*5) when suggestions count > 5)',
      (WidgetTester tester) async {
    final controller = TextEditingController();
    final kdefaultLengthInViewPort = 5;
    final kdefaultHeight = 35;
    await tester.pumpWidget(_boilerplate(
        child: SearchField(
      key: const Key('searchfield'),
      suggestions: ['ABC', 'DEF', 'GHI', 'JKL', 'MNO', 'PQR']
          .map((e) => SearchFieldListItem<String>(e))
          .toList(),
      controller: controller,
      suggestionState: Suggestion.expand,
    )));
    final listFinder = find.byType(ListView);
    final textField = find.byType(TextFormField);
    expect(textField, findsOneWidget);
    expect(listFinder, findsNothing);
    await tester.tap(textField);
    await tester.enterText(textField, '');
    await tester.pumpAndSettle();
    expect(listFinder, findsOneWidget);
    final baseSize = tester.getSize(listFinder);
    final resultingHeight = baseSize.height;
    final expectedHeight = kdefaultLengthInViewPort * kdefaultHeight;
    expect(resultingHeight, equals(expectedHeight));
  });
}
