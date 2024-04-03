import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_wallet/ui/util/custom_colors.dart';

class QrlDateField extends StatefulWidget {
  final void Function(DateTime? value) _onChange;
  final String? title;
  final DateTime? initialValue;
  final bool mandatory;

  const QrlDateField(
    this._onChange, {
    Key? key,
    this.title,
    this.initialValue,
    this.mandatory = false,
  }) : super(key: key);

  @override
  State<QrlDateField> createState() => _QrlDateFieldState();
}

class _QrlDateFieldState extends State<QrlDateField> {
  static const Color _defaultColor = CustomColors.qrlYellowColor;
  late final TextEditingController _textController;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    if (widget.initialValue != null) {
      _selectedDate = widget.initialValue!;
      _textController.value = TextEditingValue(
          text: DateFormat("MMM d yyyy").format(_selectedDate!));
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _textController,
      readOnly: true,
      decoration: InputDecoration(
        helperStyle: const TextStyle(color: _defaultColor),
        border: const OutlineInputBorder(
            borderSide: BorderSide(color: _defaultColor)),
        enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: _defaultColor)),
        focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: _defaultColor, width: 2)),
        labelText: widget.title,
        labelStyle: const TextStyle(color: _defaultColor),
        floatingLabelBehavior: FloatingLabelBehavior.always,
        suffixIcon: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (!widget.mandatory && _textController.text.isNotEmpty)
              IconButton(
                icon: const Icon(
                  Icons.clear,
                  color: CustomColors.qrlYellowColor,
                ),
                onPressed: () {
                  if (mounted) {
                    setState(() {
                      _textController.clear();
                      _selectedDate = null;
                      widget._onChange(null);
                    });
                  }
                },
              ),
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Icon(
                Icons.event,
                color: CustomColors.qrlYellowColor,
              ),
            ),
          ],
        ),
      ),
      onTap: () {
        FocusScope.of(context).requestFocus(FocusNode());
        _selectDate(context);
      },
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              surface: CustomColors.qrlDarkBlueMaterial,
              onSurface: Colors.white,
              onPrimary: CustomColors.qrlDarkBlueMaterial,
              primary: CustomColors.qrlYellowMaterial,
            ),
            dialogBackgroundColor: CustomColors.qrlDarkBlueMaterial,
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                side: const BorderSide(
                    color: CustomColors.qrlLightBlueColor, width: 1),
                foregroundColor: CustomColors.qrlLightBlueColor,
                backgroundColor: CustomColors.qrlLightBlueColorBackground,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      String formattedDate = DateFormat("MMM d yyyy").format(picked);
      if (mounted) {
        setState(() {
          _textController.value = TextEditingValue(text: formattedDate);
          _selectedDate = picked;
          widget._onChange(picked);
        });
      }
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
