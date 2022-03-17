import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RestrictedTextInputFormField extends StatelessWidget {
  const RestrictedTextInputFormField({
    required this.formKey,
    required this.initialValue,
    required this.regex,
    required this.formatterFunction,
    required this.validator,
    required this.decoration,
    required this.nextFocusOnEditingComplete,
    this.textAlign,
    this.textStyle,
    Key? key,
  }) : super(key: key);

  final bool nextFocusOnEditingComplete;
  final GlobalKey<FormState> formKey;
  final String initialValue;
  final InputDecoration decoration;
  final TextAlign? textAlign;
  final TextStyle? textStyle;

  final String regex;
  final TextEditingValue Function(TextEditingValue, TextEditingValue) formatterFunction;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      // autovalidateMode: AutovalidateMode.onUserInteraction,
      initialValue: initialValue,
      decoration: decoration,
      textAlign: textAlign ?? TextAlign.start,
      style: textStyle,
      onChanged: (value) {
        formKey.currentState!.validate();
      },
      onFieldSubmitted: (st) {
        // print('onFieldSubmitted');
        formKey.currentState!.validate();
        FocusScope.of(context).nextFocus();
      },
      onEditingComplete: () {
        // TextEditingController
        // print('onEditingComplete');
        if (nextFocusOnEditingComplete) {
          // FocusScope.of(context).nextFocus();
          FocusScope.of(context).nextFocus();
        }
      },
      validator: validator,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(regex)),
        TextInputFormatter.withFunction(formatterFunction),
      ],
    );
  }
}

@immutable
class IntegerInputFormField extends RestrictedTextInputFormField {
  IntegerInputFormField({
    Key? key,
    required formKey,
    required initialValue,
    required validator,
    required decoration,
    required maxNumDigits,
    required nextFocusOnEditingComplete,
    TextAlign? textAlign,
    TextStyle? textStyle,
  }) : super(
            key: key,
            formKey: formKey,
            initialValue: initialValue,
            decoration: decoration,
            regex: r"[0-9]",
            textAlign: textAlign,
            textStyle: textStyle,
            nextFocusOnEditingComplete: nextFocusOnEditingComplete,
            formatterFunction: (oldValue, newValue) {
              // print(oldValue);
              // print(newValue);
              try {
                String text = newValue.text;
                if (text.isNotEmpty) {
                  if (text[0] == '0' && text != '0') text = '';
                  if (text.length > maxNumDigits) text = '';
                  int.parse(text);
                }
                return newValue;
              } catch (e) {}
              return oldValue;
            },
            validator: validator);
}

class SettingsIntegerInputFormField extends IntegerInputFormField {
  SettingsIntegerInputFormField(
      {Key? key, required formKey, required initialValue, required labelText, required validator, required maxNumDigits})
      : super(
          key: key,
          formKey: formKey,
          initialValue: initialValue,
          validator: validator,
          maxNumDigits: maxNumDigits,
          nextFocusOnEditingComplete: false,
          decoration: InputDecoration(
            labelText: labelText,
            constraints: const BoxConstraints.tightForFinite(width: 210, height: double.infinity),
            contentPadding: const EdgeInsets.all(9),
            isDense: true,
            // isCollapsed: true,
            border: const OutlineInputBorder(),
          ),
        );
}

class TableIntegerInputFormField extends IntegerInputFormField {
  TableIntegerInputFormField({Key? key, required formKey, required initialValue, required validator, required maxNumDigits})
      : super(
          key: key,
          formKey: formKey,
          initialValue: initialValue,
          validator: validator,
          maxNumDigits: maxNumDigits,
          textAlign: TextAlign.right,
          nextFocusOnEditingComplete: true,
          decoration: InputDecoration(
              errorStyle: const TextStyle(height: 0),
              constraints: BoxConstraints.tightForFinite(width: (maxNumDigits == 4 ? 51 : 42), height: 21),
              contentPadding: const EdgeInsets.all(4),
              isDense: true,
              isCollapsed: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(3),
              )),
        );
}

@immutable
class PercentInputFormField extends RestrictedTextInputFormField {
  PercentInputFormField({
    Key? key,
    required formKey,
    required initialValue,
    required labelText,
    required validator,
  }) : super(
            key: key,
            formKey: formKey,
            initialValue: initialValue,
            nextFocusOnEditingComplete: false,
            decoration: InputDecoration(
              labelText: labelText,
              constraints: const BoxConstraints.tightForFinite(width: 210, height: double.infinity),
              contentPadding: const EdgeInsets.all(9),
              isDense: true,
              // isCollapsed: true,
              border: const OutlineInputBorder(),
            ),
            regex: r"[0-9.]",
            formatterFunction: (oldValue, newValue) {
              try {
                String text = newValue.text;
                if (text.isNotEmpty) {
                  if (text.length > 1 && text.startsWith('0') && text[1] != '.') text = '';
                  if (text[0] == '.') text = '0' + text;
                  double.parse(text);
                }
                return newValue;
              } catch (e) {}
              return oldValue;
            },
            validator: validator);
}
