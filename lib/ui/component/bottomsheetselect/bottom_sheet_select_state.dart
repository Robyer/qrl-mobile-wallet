part of 'bottom_sheet_select_bloc.dart';

enum BottomSheetSelectStatus { closed, opened, valueChanged, closing }

class BottomSheetSelectState<T> extends Equatable {
  final BottomSheetSelectStatus status;
  final T selectedItem;
  final List<T> items;

  const BottomSheetSelectState(
      {this.status = BottomSheetSelectStatus.closed,
      required this.selectedItem,
      required this.items});

  BottomSheetSelectState<T> copyWith(
      {BottomSheetSelectStatus? status, T? selectedItem, List<T>? items}) {
    return BottomSheetSelectState<T>(
      status: status ?? this.status,
      selectedItem: selectedItem ?? this.selectedItem,
      items: items ?? this.items,
    );
  }

  @override
  List<Object?> get props => [status, items, selectedItem];
}
