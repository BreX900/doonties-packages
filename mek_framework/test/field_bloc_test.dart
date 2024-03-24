import 'package:flutter_test/flutter_test.dart';
import 'package:mek/mek.dart';

void main() {
  group('FieldBloc', () {
    const delay = Duration.zero;
    const error = 'error';

    test('value/initialValue/isDirty is updated correctly without validators', () {
      final fieldBloc = FieldBloc(
        debounceTime: Duration.zero,
        initialValue: 0,
      );
      var state = const FieldBlocState(
        isEnabled: true,
        isValidating: false,
        isDirty: false,
        initialValue: 0,
        updatedValue: 0,
        value: 0,
        error: null,
      );
      expect(fieldBloc.state, state);

      fieldBloc.changeValue(1);
      state = state.change((c) => c
        ..isDirty = true
        ..value = 1);
      expect(fieldBloc.state, state);

      fieldBloc.updateValue(2);
      state = state.change((c) => c
        ..isDirty = false
        ..value = 2
        ..updatedValue = 2);
      expect(fieldBloc.state, state);

      fieldBloc.changeValue(3);
      state = state.change((c) => c
        ..isDirty = true
        ..value = 3);
      expect(fieldBloc.state, state);

      fieldBloc.updateInitialValue(4);
      state = state.change((c) => c
        ..isDirty = false
        ..initialValue = 4);
      expect(fieldBloc.state, state);
    });

    test('error updated correctly with validator', () {
      final fieldBloc = FieldBloc<int?>(
        debounceTime: Duration.zero,
        initialValue: null,
        validator: Validation.from((value) => value == null ? error : null).call,
      );
      expect(fieldBloc.state.error, isNotNull);

      // changeValue

      fieldBloc.changeValue(1);
      expect(fieldBloc.state.error, isNull);

      fieldBloc.changeValue(null);
      expect(fieldBloc.state.error, isNotNull);

      // updateValue

      fieldBloc.updateValue(2);
      expect(fieldBloc.state.error, isNull);

      fieldBloc.updateValue(null);
      expect(fieldBloc.state.error, isNotNull);

      // updateInitialValue

      fieldBloc.updateInitialValue(3);
      expect(fieldBloc.state.error, isNull);

      fieldBloc.updateInitialValue(null);
      expect(fieldBloc.state.error, isNotNull);
    });

    test('error updated correctly with async validator', () async {
      final fieldBloc = FieldBloc<int?>(
        debounceTime: Duration.zero,
        initialValue: null,
        asyncValidator: (value) => Future(() => value == null ? error : null),
      );

      expect(fieldBloc.state.isValidating, true);
      await Future<void>.delayed(delay);
      expect(fieldBloc.state.isValidating, false);
      expect(fieldBloc.state.error, isNotNull);

      // changeValue

      fieldBloc.changeValue(1);
      expect(fieldBloc.state.isValidating, true);
      await Future<void>.delayed(delay);
      expect(fieldBloc.state.isValidating, false);
      expect(fieldBloc.state.error, isNull);

      fieldBloc.changeValue(null);
      expect(fieldBloc.state.isValidating, true);
      await Future<void>.delayed(delay);
      expect(fieldBloc.state.isValidating, false);
      expect(fieldBloc.state.error, isNotNull);

      // updateValue

      fieldBloc.updateValue(1);
      expect(fieldBloc.state.isValidating, true);
      await Future<void>.delayed(delay);
      expect(fieldBloc.state.isValidating, false);
      expect(fieldBloc.state.error, isNull);

      fieldBloc.updateValue(null);
      expect(fieldBloc.state.isValidating, true);
      await Future<void>.delayed(delay);
      expect(fieldBloc.state.isValidating, false);
      expect(fieldBloc.state.error, isNotNull);

      // updateInitialValue

      fieldBloc.updateInitialValue(1);
      expect(fieldBloc.state.isValidating, true);
      await Future<void>.delayed(delay);
      expect(fieldBloc.state.isValidating, false);
      expect(fieldBloc.state.error, isNull);

      fieldBloc.updateInitialValue(null);
      expect(fieldBloc.state.isValidating, true);
      await Future<void>.delayed(delay);
      expect(fieldBloc.state.isValidating, false);
      expect(fieldBloc.state.error, isNotNull);
    });

    test('error updated correctly with double async validation', () async {
      final fieldBloc = FieldBloc<int?>(
        debounceTime: Duration.zero,
        initialValue: null,
        asyncValidator: (value) => Future(() => value == null ? error : null),
      );

      await Future<void>.delayed(delay);

      fieldBloc.changeValue(1);
      expect(fieldBloc.state.isValidating, true);
      fieldBloc.changeValue(1);
      expect(fieldBloc.state.isValidating, true);
      await Future<void>.delayed(delay);
      expect(fieldBloc.state.isValidating, false);
      expect(fieldBloc.state.error, isNull);

      fieldBloc.changeValue(null);
      expect(fieldBloc.state.isValidating, true);
      fieldBloc.changeValue(1);
      expect(fieldBloc.state.isValidating, true);
      await Future<void>.delayed(delay);
      expect(fieldBloc.state.isValidating, false);
      expect(fieldBloc.state.error, isNull);
    });
  });
}
