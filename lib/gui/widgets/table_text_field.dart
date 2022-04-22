import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../my_theme.dart';
import 'table_targets.dart';

class TableTextField extends StatefulWidget {
  const TableTextField({
    Key? key,
    required this.onChanged,
    required this.initialText,
  }) : super(key: key);

  static const double width = 40;
  static const double height = TargetsTable.itemHeight * .7;

  final String initialText;
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
      decoration: InputDecoration(
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(3), borderSide: BorderSide(width: 0.0, color: theme.primary)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(3), borderSide: BorderSide(width: 0.0, color: theme.primary)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(3), borderSide: BorderSide(width: 0.0, color: theme.outline.withOpacity(.2))),
        fillColor: theme.background,
        filled: true,
        constraints: BoxConstraints.tight(const Size(TableTextField.width, TableTextField.height)),
        contentPadding: const EdgeInsets.all(2.0),
      ),
      textAlign: TextAlign.right,
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
            if (text.length > 5) {
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
