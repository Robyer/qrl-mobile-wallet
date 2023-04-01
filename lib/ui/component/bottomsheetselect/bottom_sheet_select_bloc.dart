import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'bottom_sheet_select_event.dart';

part 'bottom_sheet_select_state.dart';

class BottomSheetSelectBloc<T>
    extends Bloc<BottomSheetSelectEvent<T>, BottomSheetSelectState<T>> {
  BottomSheetSelectBloc(T selectedItem, List<T> items)
      : super(BottomSheetSelectState<T>(
            selectedItem: selectedItem, items: items)) {
    on<OpenEvent<T>>((event, emit) async {
      if (state.status != BottomSheetSelectStatus.opened) {
        emit(state.copyWith(status: BottomSheetSelectStatus.opened));
      }
    });

    on<ClosedEvent<T>>((event, emit) async {
      if (state.status != BottomSheetSelectStatus.closed) {
        emit(state.copyWith(status: BottomSheetSelectStatus.closed));
      }
    });

    on<SelectedEvent<T>>((event, emit) async {
      if (state.selectedItem != event._selectedItem) {
        emit(state.copyWith(
            status: BottomSheetSelectStatus.valueChanged,
            selectedItem: event._selectedItem));
      } else if (state.status != BottomSheetSelectStatus.closed) {
        emit(state.copyWith(status: BottomSheetSelectStatus.closing));
      }
    });
  }
}
