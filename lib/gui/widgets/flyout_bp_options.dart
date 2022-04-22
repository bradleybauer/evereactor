import 'package:EveIndy/gui/widgets/table_text_field.dart';
import 'package:flutter/material.dart';

import '../my_theme.dart';
import 'flyout.dart';
import 'hover_button.dart';

class BpOptionsTableWidget extends StatelessWidget {
  const BpOptionsTableWidget({required this.style, Key? key}) : super(key: key);

  static const size = Size(172, 32);

  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: theme.appBarPadding),
      child: Flyout(
        verticalOffset: 0,
        openMode: FlyoutOpenMode.hover,
        align: FlyoutAlign.childLeftCenter,
        contentSize: size,
        content: const BpOptionsFlyoutContent(),
        closeTimeout: const Duration(),
        child: HoverButton(
          hoveredElevation: 0,
          borderRadius: 3,
          builder: (hovered) => const Padding(padding: EdgeInsets.all(4.0), child: Icon(Icons.settings, size: 13)),
          //factory_outlined, size:14)),
          onTap: () {},
          color: theme.background,
          hoveredColor: theme.tertiaryContainer,
          mouseCursor: MouseCursor.defer,
        ),
      ),
    );
  }
}

class BpOptionsFlyoutContent extends StatelessWidget {
  const BpOptionsFlyoutContent({Key? key}) : super(key: key);

  static const padding = 8.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: theme.surfaceVariant,
        borderRadius: BorderRadius.circular(4),
      ),
      width: BpOptionsTableWidget.size.width,
      height: BpOptionsTableWidget.size.height,
      child: Row(
        children: [
          const SizedBox(width: padding),
          Tooltip(
            message: 'Material Efficiency',
            preferBelow: false,
            verticalOffset: 15,
            child: TableTextField(onChanged: (text) {}, initialText: '', hintText: 'ME', width: 25, maxNumDigits: 2),
          ),
          const SizedBox(width: padding),
          Tooltip(
            message: 'Time Efficiency',
            preferBelow: false,
            verticalOffset: 15,
            child: TableTextField(onChanged: (text) {}, initialText: '', hintText: 'TE', width: 25, maxNumDigits: 2),
          ),
          const SizedBox(width: padding),
          Tooltip(
            message: 'Max number of runs per blueprint',
            preferBelow: false,
            verticalOffset: 15,
            child: TableTextField(onChanged: (text) {}, initialText: '', hintText: 'Runs', width: 47, maxNumDigits: 6),
          ),
          const SizedBox(width: padding),
          Tooltip(
            message: 'Max number of blueprints',
            preferBelow: false,
            verticalOffset: 15,
            child: TableTextField(onChanged: (text) {}, initialText: '', hintText: 'BPs', width: 35, maxNumDigits: 3),
          ),
          const SizedBox(width: padding),
        ],
      ),
    );
  }
}
