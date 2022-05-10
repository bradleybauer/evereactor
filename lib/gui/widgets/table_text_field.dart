import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../my_theme.dart';

class TableTextField extends StatefulWidget {
  const TableTextField({
    required this.onChanged,
    required this.textColor,
    required this.activeBorderColor,
    this.fillColor = Colors.transparent,
    this.initialText = '',
    this.width = 40,
    this.height = 21,
    this.maxNumDigits = 5,
    this.hintText = '',
    this.textAlign = TextAlign.right,
    this.allowEmptyString = false,
    this.floatingPoint = false,
    this.allowOverwrite = false,
    this.hintStyle,
    this.focusNode,
    // this.formKey,
    super.key,
  });

  // final GlobalKey<FormState>? formKey;
  final FocusNode? focusNode;
  final double height;

  final double width;
  final Color fillColor;
  final Color textColor;
  final Color activeBorderColor;
  final int maxNumDigits;
  final String initialText;
  final String hintText;
  final TextAlign textAlign;
  final TextStyle? hintStyle;
  final void Function(String) onChanged;
  final bool allowEmptyString;
  final bool floatingPoint;
  final bool allowOverwrite;

  @override
  State<TableTextField> createState() => _TableTextFieldState();
}

class _TableTextFieldState extends State<TableTextField> {
  final controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller.text = widget.initialText;
    controller.selection = TextSelection.fromPosition(TextPosition(offset: controller.text.length));
    controller.notifyListeners();
  }

  @override
  void didUpdateWidget(TableTextField oldWidget) {
    if (shouldReplaceControllerTextWithWidgetText()) {
      controller.text = widget.initialText;
      controller.selection = TextSelection.fromPosition(TextPosition(offset: controller.text.length));
      controller.notifyListeners();
    }
    super.didUpdateWidget(oldWidget);
  }

  bool shouldReplaceControllerTextWithWidgetText() {
    bool shouldUpdate = controller.text == '';
    if (!shouldUpdate) {
      try {
        final parser = widget.floatingPoint ? double.parse : int.parse;
        final num controllerValue = parser(controller.text);
        final num widgetValue = parser(widget.initialText);
        shouldUpdate |= controllerValue != widgetValue;
      } catch (e) {}
    }
    return shouldUpdate;
  }

  String removeLeadingCharacterAndSubsequenZeros(String str) {
    var ret = str.substring(1);
    while (ret[0] == '0' && ret.length > 1) {
      ret = ret.substring(1);
    }
    if (ret[0] == '0') {
      ret = '';
    }
    return ret;
  }

  TextEditingValue intFormatter(TextEditingValue oldValue, TextEditingValue newValue) {
    if (widget.allowEmptyString && newValue.text == '') {
      return newValue;
    }
    if (!widget.allowOverwrite && newValue.text.length > widget.maxNumDigits) {
      return oldValue;
    }
    try {
      final text = newValue.text;
      if (text.startsWith('0') && text.length > 1) {
        final ret = removeLeadingCharacterAndSubsequenZeros(text);
        if (ret == '') {
          return oldValue;
        } else {
          return TextEditingValue(text: ret, selection: TextSelection.fromPosition(TextPosition(offset: ret.length)));
        }
      }
      // weird i know
      if (text.length == widget.maxNumDigits + 1) {
        final ret = removeLeadingCharacterAndSubsequenZeros(text);
        return TextEditingValue(text: ret, selection: TextSelection.fromPosition(TextPosition(offset: ret.length)));
      }
      if (text.length > widget.maxNumDigits) {
        return oldValue;
      }
      if (text.isNotEmpty) {
        int value = int.parse(text);
      }
      return newValue;
    } catch (e) {}
    return oldValue;
  }

  TextEditingValue floatFormatter(TextEditingValue oldValue, TextEditingValue newValue) {
    if (widget.allowEmptyString && newValue.text == '') {
      return newValue;
    }
    try {
      final text = newValue.text;
      if (text.length > widget.maxNumDigits) {
        return oldValue;
      }
      if (text == '.') {
        return TextEditingValue(text: '0.', selection: TextSelection.fromPosition(TextPosition(offset: 2)));
      }
      if (text.isNotEmpty) {
        double value = double.parse(text);
      }
      return newValue;
    } catch (e) {}
    return oldValue;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<MyTheme>(context);
    return TextField(
      focusNode: widget.focusNode,
      onChanged: widget.onChanged,
      controller: controller,
      textAlign: widget.textAlign,
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: widget.hintStyle,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(3),
            borderSide: BorderSide(width: 0.0, color: widget.activeBorderColor)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(3),
            borderSide: BorderSide(width: 0.0, color: widget.activeBorderColor)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(3),
            borderSide: BorderSide(width: 0.0, color: theme.outline.withOpacity(.2))),
        fillColor: widget.fillColor,
        filled: true,
        constraints: BoxConstraints.tight(Size(widget.width, widget.height)),
        contentPadding: const EdgeInsets.all(2.0),
      ),
      style: TextStyle(fontSize: 11, fontFamily: 'NotoSans', color: widget.textColor),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(widget.floatingPoint ? r"[0-9.]" : r"[0-9]")),
        TextInputFormatter.withFunction(widget.floatingPoint ? floatFormatter : intFormatter),
      ],
    );
  }
}
