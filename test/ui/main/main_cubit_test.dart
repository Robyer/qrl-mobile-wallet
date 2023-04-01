import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_wallet/ui/main/main_cubit.dart';

void main() {
  group('MainCubit', () {
    late MainCubit mainCubit;

    setUp(() {
      mainCubit = MainCubit();
    });

    test("test initial state", () {
      expect(mainCubit.state, 0);
    });

    blocTest(
      'emits [2] when updateSelectedIndex(2)',
      build: () => mainCubit,
      act: (bloc) => mainCubit.updateSelectedIndex(2),
      expect: () => [2],
    );
  });
}
