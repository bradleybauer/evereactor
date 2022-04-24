import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../my_theme.dart';

class TableTextField extends StatefulWidget {
  const TableTextField({
    Key? key,
    required this.onChanged,
    required this.textColor,
    required this.borderColor,
    this.fillColor = Colors.transparent,
    this.initialText = '',
    this.width = 40,
    this.height = 21,
    this.maxNumDigits = 5,
    this.hintText = '',
    this.textAlign = TextAlign.right,
    this.allowEmptyString = false,
    this.hintStyle,
  }) : super(key: key);

  final double height;

  final double width;
  final Color fillColor;
  final Color textColor;
  final Color borderColor;
  final int maxNumDigits;
  final String initialText;
  final String hintText;
  final TextAlign textAlign;
  final TextStyle? hintStyle;
  final void Function(String) onChanged;
  final bool allowEmptyString;

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
        hintStyle: widget.hintStyle,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(3), borderSide: BorderSide(width: 0.0, color: widget.borderColor)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(3), borderSide: BorderSide(width: 0.0, color: widget.borderColor)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(3),
            borderSide: BorderSide(width: 0.0, color: theme.outline.withOpacity(.5))),
        fillColor: widget.fillColor,
        filled: true,
        constraints: BoxConstraints.tight(Size(widget.width, widget.height)),
        contentPadding: const EdgeInsets.all(2.0),
      ),
      style: TextStyle(fontSize: 11, fontFamily: 'NotoSans', color: widget.textColor),
      keyboardType: const TextInputType.numberWithOptions(decimal: false, signed: false),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r"[0-9]")),
        TextInputFormatter.withFunction((oldValue, newValue) {
          if (widget.allowEmptyString && newValue.text == '') {
            return newValue;
          }
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
