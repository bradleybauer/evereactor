import 'package:flutter/material.dart';

class LabeledCheckbox extends StatelessWidget {
  const LabeledCheckbox({
    Key? key,
    required this.label,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  final String label;
  final bool value;
  final Function(bool?) onChanged;

  static const double width = 105;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: () {
          onChanged(!value);
        },
        child: FocusTraversalGroup(
          descendantsAreFocusable: false,
          child: ConstrainedBox(
            constraints: const BoxConstraints.tightForFinite(height: double.infinity, width: width),
            // constraints: const BoxConstraints.tightForFinite(height: double.infinity, width: double.infinity),
            child: Row(
              children: <Widget>[
                Checkbox(
                    hoverColor: Colors.transparent,
                    overlayColor: MaterialStateProperty.all(Colors.transparent),
                    value: value,
                    onChanged: (bool? newValue) {
                      onChanged(newValue);
                    }),
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 8.0, 0),
                  child: Text(label),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
