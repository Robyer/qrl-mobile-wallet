part of 'bottom_sheet_select_bloc.dart';

abstract class BottomSheetSelectEvent<T> extends Equatable {
  const BottomSheetSelectEvent();

  @override
  List<Object?> get props => [];
}

class OpenEvent<T> extends BottomSheetSelectEvent<T> {}

class ClosedEvent<T> extends BottomSheetSelectEvent<T> {}

class SelectedEvent<T> extends BottomSheetSelectEvent<T> {
  final T _selectedItem;

  const SelectedEvent(this._selectedItem);

  @override
  List<Object?> get props => [_selectedItem];
}
