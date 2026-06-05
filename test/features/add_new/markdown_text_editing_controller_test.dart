import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Reflections/features/add_new/presentation/widgets/markdown_text_editing_controller.dart';

void main() {
  group('MarkdownTextEditingController Tests', () {
    late MarkdownTextEditingController controller;

    setUp(() {
      controller = MarkdownTextEditingController(
        getTextColor: () => Colors.black,
      );
    });

    tearDown(() {
      controller.dispose();
    });

    test('renders plain text without styles', () {
      controller.text = 'Hello World';
      final span = controller.buildTextSpan(
        context: TextContext(),
        withComposing: false,
      );

      expect(span.children, isNotNull);
      expect(span.children!.length, equals(1));
      expect(span.children![0].toPlainText(), equals('Hello World'));
    });

    test('parses checklist unchecked items correctly', () {
      controller.text = '- [ ] Buy groceries';
      final span = controller.buildTextSpan(
        context: TextContext(),
        withComposing: false,
      );

      expect(span.children, isNotNull);
      // Now 2 spans: [styled prefix][content] — no ghost chars
      expect(span.children!.length, equals(2));

      // First: the raw prefix "- [ ] " rendered dim
      expect(span.children![0].toPlainText(), equals('- [ ] '));

      // Second: content text
      expect(span.children![1].toPlainText(), equals('Buy groceries'));
    });

    test('parses checklist checked items correctly', () {
      controller.text = '- [x] Read a book';
      final span = controller.buildTextSpan(
        context: TextContext(),
        withComposing: false,
      );

      expect(span.children, isNotNull);
      // Now 2 spans: [styled prefix][content] — no ghost chars
      expect(span.children!.length, equals(2));

      // First: the raw prefix "- [x] " rendered dim
      expect(span.children![0].toPlainText(), equals('- [x] '));

      // Second: content text
      expect(span.children![1].toPlainText(), equals('Read a book'));
    });

    test('parses bullet items correctly', () {
      controller.text = '- Item 1';
      final span = controller.buildTextSpan(
        context: TextContext(),
        withComposing: false,
      );

      expect(span.children, isNotNull);
      // Now 2 spans: [styled prefix][content] — no ghost chars
      expect(span.children!.length, equals(2));
      expect(span.children![0].toPlainText(), equals('- '));
      expect(span.children![1].toPlainText(), equals('Item 1'));
    });

    test('parses bold tags correctly', () {
      controller.text = 'This is **bold** text';
      final span = controller.buildTextSpan(
        context: TextContext(),
        withComposing: false,
      );

      expect(span.children, isNotNull);
      
      // Let's verify we have bold styled text
      final boldSpans = span.children!.where((s) => s.style?.fontWeight == FontWeight.bold);
      expect(boldSpans, isNotEmpty);
      expect(boldSpans.first.toPlainText(), equals('bold'));
    });

    test('parses custom text colors correctly', () {
      controller.text = 'Some <color=red>red text</color>';
      final span = controller.buildTextSpan(
        context: TextContext(),
        withComposing: false,
      );

      expect(span.children, isNotNull);
      final redSpans = span.children!.where((s) => s.style?.color == const Color(0xFFEF5350));
      expect(redSpans, isNotEmpty);
      expect(redSpans.first.toPlainText(), equals('red text'));
    });

    test('auto-continues checklists on newline', () {
      controller.value = const TextEditingValue(
        text: '- [ ] Item 1',
        selection: TextSelection.collapsed(offset: 12),
      );
      
      // Simulate typing '\n' at the end of the text
      controller.value = const TextEditingValue(
        text: '- [ ] Item 1\n',
        selection: TextSelection.collapsed(offset: 13),
      );

      expect(controller.text, equals('- [ ] Item 1\n- [ ] '));
      expect(controller.selection.start, equals(19));
    });

    test('auto-clears checklist on newline if empty', () {
      controller.value = const TextEditingValue(
        text: '- [ ] ',
        selection: TextSelection.collapsed(offset: 6),
      );
      
      // Simulate typing '\n' when empty checklist item
      controller.value = const TextEditingValue(
        text: '- [ ] \n',
        selection: TextSelection.collapsed(offset: 7),
      );

      expect(controller.text, equals('\n'));
      expect(controller.selection.start, equals(1));
    });

    test('auto-continues bullets on newline', () {
      controller.value = const TextEditingValue(
        text: '- Item 1',
        selection: TextSelection.collapsed(offset: 8),
      );
      
      controller.value = const TextEditingValue(
        text: '- Item 1\n',
        selection: TextSelection.collapsed(offset: 9),
      );

      expect(controller.text, equals('- Item 1\n- '));
      expect(controller.selection.start, equals(11));
    });

    test('auto-continues numbered lists and increments number on newline', () {
      controller.value = const TextEditingValue(
        text: '1. Hello',
        selection: TextSelection.collapsed(offset: 8),
      );
      
      controller.value = const TextEditingValue(
        text: '1. Hello\n',
        selection: TextSelection.collapsed(offset: 9),
      );

      expect(controller.text, equals('1. Hello\n2. '));
      expect(controller.selection.start, equals(12));
    });
  });
}

// A simple dummy BuildContext for building text spans
class TextContext extends BuildContext {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
