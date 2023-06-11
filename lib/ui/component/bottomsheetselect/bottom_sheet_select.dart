import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_wallet/ui/component/bottomsheetselect/bottom_sheet_select_bloc.dart';
import 'package:mobile_wallet/ui/util/custom_colors.dart';
import 'package:mobile_wallet/ui/util/util.dart';

class BottomSheetSelect<T> extends StatelessWidget {
  final T selectedItem;
  final List<T> items;
  final ValueChanged<T> valueChanged;
  final String Function(T value)? labelConverter;
  final Widget Function(T value)? labelWidgetConverter;
  final String? floatingLabelValue;
  final String Function(T value)? itemConverter;
  final Widget Function(T value)? itemWidgetConverter;

  const BottomSheetSelect({
    super.key,
    required this.selectedItem,
    required this.items,
    required this.valueChanged,
    this.labelConverter,
    this.labelWidgetConverter,
    this.floatingLabelValue,
    this.itemConverter,
    this.itemWidgetConverter,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<BottomSheetSelectBloc<T>>(
        create: (_) => BottomSheetSelectBloc<T>(selectedItem, items),
        child: _BottomSheetSelectWidget<T>(
            valueChanged,
            labelConverter,
            labelWidgetConverter,
            floatingLabelValue,
            itemConverter,
            itemWidgetConverter));
  }
}

class _BottomSheetSelectWidget<T> extends StatelessWidget {
  final ValueChanged<T> _valueChanged;
  final String Function(T value)? _labelConverter;
  final Widget Function(T value)? _labelWidgetConverter;
  final String? _floatingLabelValue;
  final String Function(T value)? _itemConverter;
  final Widget Function(T value)? _itemWidgetConverter;

  const _BottomSheetSelectWidget(
    this._valueChanged,
    this._labelConverter,
    this._labelWidgetConverter,
    this._floatingLabelValue,
    this._itemConverter,
    this._itemWidgetConverter,
  );

  @override
  Widget build(BuildContext context) {
    return BlocListener<BottomSheetSelectBloc<T>, BottomSheetSelectState<T>>(
      listenWhen: (previous, current) =>
          (previous.status == BottomSheetSelectStatus.opened &&
              current.status == BottomSheetSelectStatus.valueChanged) ||
          (previous.status == BottomSheetSelectStatus.opened &&
              current.status == BottomSheetSelectStatus.closing) ||
          (previous.status == BottomSheetSelectStatus.closed &&
              current.status == BottomSheetSelectStatus.opened),
      listener: (context, state) {
        if (state.status == BottomSheetSelectStatus.opened) {
          Util.dismissKeyboard(context);
          _showModal(context, state.items);
        }
        if (state.status == BottomSheetSelectStatus.valueChanged) {
          _valueChanged.call(state.selectedItem);
          Navigator.of(context).pop();
        }
        if (state.status == BottomSheetSelectStatus.closing) {
          Navigator.of(context).pop();
        }
      },
      child: _buildSelect(context),
    );
  }

  void _showModal(context, List<T> items) {
    showModalBottomSheet(
            context: context,
            builder: (modal) {
              return BlocProvider<BottomSheetSelectBloc<T>>.value(
                value: BlocProvider.of<BottomSheetSelectBloc<T>>(context),
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xff163246),
                        CustomColors.qrlDarkBlueMaterial,
                      ],
                      stops: [0.1, 0.8],
                    ),
                  ),
                  child: ListView.separated(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      separatorBuilder: (context, index) => Divider(
                            height: 1,
                            color: Colors.grey[500],
                          ),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        return InkWell(
                            child: _buildValue(context, items[index]),
                            onTap: () {
                              BlocProvider.of<BottomSheetSelectBloc<T>>(context)
                                  .add(SelectedEvent(items[index]));
                            });
                      }),
                ),
              );
            })
        .whenComplete(() => BlocProvider.of<BottomSheetSelectBloc<T>>(context)
            .add(ClosedEvent()));
  }

  Widget _buildSelect(BuildContext context) {
    Widget selectWidget;
    if (_labelConverter != null) {
      selectWidget = _buildWithLabelConverter();
    } else if (_labelWidgetConverter != null) {
      selectWidget = _buildWithLabelWidgetConverter();
    } else {
      selectWidget = const Text("");
    }
    Center center = Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          InkWell(
            child: selectWidget,
            onTap: () => BlocProvider.of<BottomSheetSelectBloc<T>>(context)
                .add(OpenEvent()),
          ),
        ],
      ),
    );
    return _floatingLabelValue != null
        ? _wrapWithFloatingLabel(center)
        : center;
  }

  Widget _buildWithLabelConverter() {
    return Padding(
      padding: _floatingLabelValue != null
          ? const EdgeInsets.only(top: 16, bottom: 16)
          : const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          BlocBuilder<BottomSheetSelectBloc<T>, BottomSheetSelectState<T>>(
            buildWhen: (previous, current) =>
                current.status == BottomSheetSelectStatus.closed,
            builder: (context, state) {
              if (state.status == BottomSheetSelectStatus.closed) {
                return Text(
                  _labelConverter!.call(state.selectedItem),
                  textAlign: TextAlign.left,
                );
              }
              return const Text("");
            },
          ),
          const Icon(
            Icons.arrow_drop_down,
            color: CustomColors.qrlYellowColor,
          ),
        ],
      ),
    );
  }

  Widget _buildWithLabelWidgetConverter() {
    return BlocBuilder<BottomSheetSelectBloc<T>, BottomSheetSelectState<T>>(
      buildWhen: (previous, current) =>
          current.status == BottomSheetSelectStatus.closed,
      builder: (context, state) {
        if (state.status == BottomSheetSelectStatus.closed) {
          return _labelWidgetConverter!.call(state.selectedItem);
        }
        return const Text("");
      },
    );
  }

  Widget _wrapWithFloatingLabel(Widget child) {
    return Center(
      child: SizedBox(
        width: 512,
        child: Padding(
          padding:
              const EdgeInsets.only(top: 8, bottom: 8, left: 24, right: 24),
          child: InputDecorator(
            decoration: InputDecoration(
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: const BorderSide(
                      width: 1, color: CustomColors.qrlYellowColor)),
              contentPadding:
                  const EdgeInsets.only(left: 12, right: 12, top: 0, bottom: 0),
              labelText: _floatingLabelValue,
              labelStyle: const TextStyle(color: CustomColors.qrlYellowColor),
              floatingLabelBehavior: FloatingLabelBehavior.always,
              border: const OutlineInputBorder(),
            ),
            child: child,
          ),
        ),
      ),
    );
  }

  Widget _buildValue(BuildContext context, T item) {
    if (this._itemWidgetConverter != null) {
      return this._itemWidgetConverter!.call(item);
    } else {
      String value = "";
      if (this._itemConverter != null) {
        value = this._itemConverter!.call(item);
      }
      return Padding(
        padding:
            const EdgeInsets.only(bottom: 16, top: 16, right: 16, left: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IntrinsicWidth(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        value,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }
}
