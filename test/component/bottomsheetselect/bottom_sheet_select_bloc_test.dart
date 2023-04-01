import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_wallet/ui/component/bottomsheetselect/bottom_sheet_select_bloc.dart';

void main() {
  group('BottomSheetSelectBloc', () {
    List<String> items = ["item1", "item2", "item3"];
    late BottomSheetSelectBloc<String> bottomSheetSelectBloc;

    setUp(() {
      bottomSheetSelectBloc = BottomSheetSelectBloc<String>(items[1], items);
    });

    test("test initial state", () {
      expect(
          bottomSheetSelectBloc.state,
          BottomSheetSelectState<String>(
              status: BottomSheetSelectStatus.closed,
              selectedItem: items[1],
              items: items));
    });

    blocTest(
      'emits [opened] when OpenEvent()',
      build: () => bottomSheetSelectBloc,
      act: (bloc) => bottomSheetSelectBloc.add(OpenEvent<String>()),
      expect: () => [
        BottomSheetSelectState<String>(
            status: BottomSheetSelectStatus.opened,
            selectedItem: items[1],
            items: items)
      ],
    );

    blocTest(
      'emits [closed] when ClosedEvent()',
      build: () => bottomSheetSelectBloc,
      seed: () => BottomSheetSelectState<String>(
          status: BottomSheetSelectStatus.opened,
          selectedItem: items[1],
          items: items),
      act: (bloc) => bottomSheetSelectBloc.add(ClosedEvent<String>()),
      expect: () => [
        BottomSheetSelectState<String>(
            status: BottomSheetSelectStatus.closed,
            selectedItem: items[1],
            items: items)
      ],
    );

    blocTest(
      'emits [closing] when SelectedEvent() with same value',
      build: () => bottomSheetSelectBloc,
      seed: () => BottomSheetSelectState<String>(
          status: BottomSheetSelectStatus.opened,
          selectedItem: items[1],
          items: items),
      act: (bloc) => bottomSheetSelectBloc.add(SelectedEvent<String>(items[1])),
      expect: () => [
        BottomSheetSelectState<String>(
            status: BottomSheetSelectStatus.closing,
            selectedItem: items[1],
            items: items)
      ],
    );

    blocTest(
      'emits [valueChanged] when SelectedEvent() with new value',
      build: () => bottomSheetSelectBloc,
      seed: () => BottomSheetSelectState<String>(
          status: BottomSheetSelectStatus.opened,
          selectedItem: items[1],
          items: items),
      act: (bloc) => bottomSheetSelectBloc.add(SelectedEvent<String>(items[0])),
      expect: () => [
        BottomSheetSelectState<String>(
            status: BottomSheetSelectStatus.valueChanged,
            selectedItem: items[0],
            items: items)
      ],
    );
  });
}
