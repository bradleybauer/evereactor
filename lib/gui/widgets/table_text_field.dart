import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../my_theme.dart';
import 'table_targets.dart';

class TableTextField extends StatefulWidget {
  const TableTextField({
    Key? key,
    required this.onChanged,
    this.initialText = '',
    this.width = 40,
    this.maxNumDigits = 5,
    this.hintText = '',
    this.textAlign = TextAlign.right,
  }) : super(key: key);

  static const double height = TargetsTable.itemHeight * .7;

  final double width;
  final int maxNumDigits;
  final String initialText;
  final String hintText;
  final TextAlign textAlign;
  final void Function(String) onChanged;

  @override
  State<TableTextField> createState() => _TableTextFieldState();
}

class _TableTextFieldState extends State<TableTextField> {
  final controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller.text = widget.initialText;
  }

  @override
  void didUpdateWidget(TableTextField oldWidget) {
    controller.text = widget.initialText;
    controller.notifyListeners();
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: widget.onChanged,
      controller: controller,
      textAlign: widget.textAlign,
      decoration: InputDecoration(
        hintText: widget.hintText,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(3), borderSide: BorderSide(width: 0.0, color: theme.primary)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(3), borderSide: BorderSide(width: 0.0, color: theme.primary)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(3), borderSide: BorderSide(width: 0.0, color: theme.outline.withOpacity(.2))),
        fillColor: theme.background,
        filled: true,
        constraints: BoxConstraints.tight(Size(widget.width, TableTextField.height)),
        contentPadding: const EdgeInsets.all(2.0),
      ),
      style: TextStyle(fontSize: 11, fontFamily: 'NotoSans', color: theme.onBackground),
      keyboardType: const TextInputType.numberWithOptions(decimal: false, signed: false),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r"[0-9]")),
        TextInputFormatter.withFunction((oldValue, newValue) {
          try {
            final text = newValue.text;
            if (text.startsWith('0')) {
              return oldValue;
            }
            if (text.length > widget.maxNumDigits) {
              return oldValue;
            }
            if (text.isNotEmpty) {
              // try parse
              int value = int.parse(text);
            }
            return newValue;
          } catch (e) {}
          return oldValue;
        }),
      ],
    );
  }
}
