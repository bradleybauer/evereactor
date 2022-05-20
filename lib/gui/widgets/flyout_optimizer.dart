import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/optimizer.dart';
import '../my_theme.dart';
import 'hover_button.dart';

class OptimizerFlyout extends StatelessWidget {
  const OptimizerFlyout({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<OptimizerController>(context);
    final theme = Provider.of<MyTheme>(context);
    final color = theme.secondaryContainer;
    return PhysicalModel(
      color: Colors.transparent,
      shadowColor: theme.shadow,
      elevation: 2,
      borderRadius: BorderRadius.circular(4),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: Container(
        constraints: const BoxConstraints(maxHeight: 75, maxWidth: 250),
        color: color,
        child: Center(
          child: Wrap(
            direction: Axis.vertical,
            crossAxisAlignment: WrapCrossAlignment.center,
            alignment: WrapAlignment.center,
            spacing: 8,
            children: [
              Wrap(
                direction: Axis.horizontal,
                crossAxisAlignment: WrapCrossAlignment.center,
                alignment: WrapAlignment.center,
                spacing: 8,
                children: [
                  HoverButton(
                      builder: (hovered) => Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Icon(Icons.play_arrow, size: 12, color: hovered ? theme.onPrimary : theme.onSurface),
                          ),
                      onTap: controller.startOptimizer,
                      color: theme.surface,
                      hoveredColor: theme.primary,
                      hoveredElevation: 0,
                      borderRadius: 3),
                  HoverButton(
                      builder: (hovered) => Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: Icon(Icons.stop, size: 12, color: hovered ? theme.onPrimary : theme.onSurface),
                          ),
                      onTap: controller.stopOptimizer,
                      color: theme.surface,
                      hoveredColor: theme.primary,
                      hoveredElevation: 0,
                      borderRadius: 3),
                  Text('Expose:', style: TextStyle(fontSize: 12, fontFamily: 'NotoSans', color: theme.on(color))),
                  MyToggleButtons(
                    onChange: (b) {
                      if (b) {
                        controller.setExposeBasic();
                      } else {
                        controller.setExposeAdv();
                      }
                    },
                    exposeBasic: controller.isBasicExposed(),
                  ),
                ],
              ),
              Text('Time Bonus: ' + (controller.getTimeBonus() * 100).toStringAsFixed(3) + '%',
                  style: TextStyle(fontSize: 12, fontFamily: 'NotoSans', color: theme.on(color))),
            ],
          ),
        ),
      ),
    );
  }
}

class MyToggleButtons extends StatelessWidget {
  const MyToggleButtons({
    required this.onChange,
    required this.exposeBasic,
    Key? key,
  }) : super(key: key);

  static const padding = EdgeInsets.fromLTRB(4, 3, 4, 3);

  final bool exposeBasic;

  final void Function(bool) onChange;

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<MyTheme>(context);
    final selected = theme.tertiaryContainer;
    final onSelected = theme.onTertiaryContainer;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        HoverButton(
            builder: (hovered) {
              return Padding(
                  padding: MyToggleButtons.padding,
                  child: Text(
                    'basic',
                    style: TextStyle(
                        fontFamily: 'NotoSans',
                        fontSize: 12,
                        color: hovered
                            ? theme.onPrimary
                            : exposeBasic
                                ? onSelected
                                : theme.onBackground),
                  ));
            },
            borderRadius: 4,
            onTap: () => onChange(true),
            hoveredElevation: 0,
            color: exposeBasic ? selected : theme.background,
            splashColor: theme.onPrimary.withOpacity(.25),
            hoveredColor: theme.primary),
        const SizedBox(width: 5),
        HoverButton(
            builder: (hovered) {
              return Padding(
                  padding: MyToggleButtons.padding,
                  child: Text(
                    'optimized',
                    style: TextStyle(
                        fontFamily: 'NotoSans',
                        fontSize: 12,
                        color: hovered
                            ? theme.onPrimary
                            : !exposeBasic
                                ? onSelected
                                : theme.onBackground),
                  ));
            },
            borderRadius: 4,
            onTap: () => onChange(false),
            hoveredElevation: 0,
            splashColor: theme.onPrimary.withOpacity(.25),
            color: !exposeBasic ? selected : theme.background,
            hoveredColor: theme.primary)
      ],
    );
  }
}
