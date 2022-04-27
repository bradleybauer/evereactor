import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../controllers/market.dart';
import '../../controllers/options.dart';
import '../../sde.dart';
import '../../strings.dart';
import '../my_theme.dart';
import 'flyout.dart';
import 'flyout_controller.dart';
import 'flyout_dropdown.dart';
import 'hover_button.dart';
import 'labeled_checkbox.dart';
import 'table_text_field.dart';

const size = Size(510, 700);
const padding = MyTheme.appBarPadding;
const itemPadding = 8.0;

class OptionsFlyout extends StatelessWidget {
  const OptionsFlyout(this.flyoutController, this.color, this.base, this.headerStyle, this.style, {Key? key})
      : super(key: key);

  final Color color;
  final Color base;

  final TextStyle headerStyle;
  final TextStyle style;

  final FlyoutController flyoutController;

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<OptionsController>(context);
    final theme = Provider.of<MyTheme>(context);
    return PhysicalModel(
      color: Colors.transparent,
      shadowColor: theme.shadow,
      elevation: 2,
      borderRadius: BorderRadius.circular(4),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: Container(
        constraints: BoxConstraints(maxHeight: size.height, maxWidth: size.width),
        color: color,
        child: Padding(
          padding: const EdgeInsets.all(padding),
          child: FocusTraversalGroup(
            child: Wrap(
              spacing: 8,
              direction: Axis.vertical,
              children: [
                SkillSection(style: style, color: color, headerStyle: headerStyle, base: base, controller: controller),
                JobsSection(headerStyle: headerStyle, style: style, color: color, controller: controller),
                BlueprintsSection(headerStyle: headerStyle, style: style, color: color, controller: controller),
                StructuresSection(
                    style: style, controller: controller, headerStyle: headerStyle, flyoutController: flyoutController),
                CostsSection(
                    color: color,
                    headerStyle: headerStyle,
                    style: style,
                    controller: controller,
                    flyoutController: flyoutController),
                MarketsSection(base: base, headerStyle: headerStyle, style: style),
                AppSection(
                    headerStyle: headerStyle,
                    style: style,
                    controller: controller,
                    color: color,
                    base: base,
                    flyoutController: flyoutController,
                    context: context),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AppSection extends StatelessWidget {
  const AppSection({
    Key? key,
    required this.headerStyle,
    required this.style,
    required this.controller,
    required this.color,
    required this.base,
    required this.flyoutController,
    required this.context,
  }) : super(key: key);

  final TextStyle headerStyle;
  final TextStyle style;
  final FlyoutController flyoutController;
  final Color color;
  final Color base;
  final OptionsController controller;
  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<MyTheme>(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('App', style: headerStyle),
        const SizedBox(width: padding),
        Text('Language', style: style),
        const SizedBox(width: itemPadding),
        DropdownMenuFlyout(
          items: controller.getLangs().map((e) => e.name).toList(),
          style: style,
          parentController: flyoutController,
          ids: controller.getLangs().map((e) => e.label).toList(),
          onSelect: (lang) => Provider.of<Strings>(context, listen: false).setLang(lang),
          current: controller.getLangName(),
          up: true,
        ),
        const SizedBox(width: itemPadding),
        Text('Colors', style: style),
        const SizedBox(width: itemPadding),
        LightDarkModeButtons(light: !theme.isDark, color: color, base: base, onTap: theme.toggleLightDark),
        const SizedBox(width: itemPadding),
        ColorChanger(flyoutController, color, base),
      ],
    );
  }
}

class MarketsSection extends StatelessWidget {
  const MarketsSection({
    Key? key,
    required this.base,
    required this.headerStyle,
    required this.style,
  }) : super(key: key);

  final Color base;
  final TextStyle headerStyle;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<MyTheme>(context);
    final color = theme.surface;
    final hover = theme.tertiary;
    final active = base;
    final controller = Provider.of<MarketController>(context);
    final systems = controller.getOrderFilterSystems();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [Text('Markets', style: headerStyle), const SizedBox(height: 4)] +
              SDE.system2name.entries
                  .map((entry) => Padding(
                        padding: const EdgeInsets.fromLTRB(padding, 0, 0, 0),
                        child: LabeledCheckbox(
                          onTap: () => systems.contains(entry.key)
                              ? controller.removeSystemFromFilter(entry.key)
                              : controller.addSystemToFilter(entry.key),
                          getLabel: (hovered) => Text(Strings.get(entry.value),
                              style: style.copyWith(
                                  color: systems.contains(entry.key)
                                      ? (hovered ? theme.on(hover) : theme.on(active))
                                      : hovered
                                          ? theme.on(hover)
                                          : theme.on(color))),
                          value: systems.contains(entry.key),
                          color: color,
                          hoverColor: hover,
                          activeColor: active,
                        ),
                      ))
                  .toList(),
        )
      ],
    );
  }
}

class StructuresSection extends StatelessWidget {
  const StructuresSection({
    Key? key,
    required this.style,
    required this.controller,
    required this.headerStyle,
    required this.flyoutController,
  }) : super(key: key);

  final TextStyle style;
  final FlyoutController flyoutController;
  final TextStyle headerStyle;
  final OptionsController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<MyTheme>(context);
    List<Widget> addManufacturingRigButton = [];
    List<Widget> addReactionRigButton = [];
    const maxNumRigs = 3;
    if (controller.getNumSelectedManufacturingRigs() < maxNumRigs) {
      addManufacturingRigButton = [
        Padding(
            padding: const EdgeInsets.fromLTRB(itemPadding, 0, 0, 0),
            child: DropdownMenuFlyout(
              current: 'Add Rigs',
              items: controller.getManufacturingRigs().map((e) => e.name).toList(),
              style: style,
              parentController: flyoutController,
              ids: controller.getManufacturingRigs().map((e) => e.tid).toList(),
              onSelect: (tid) => controller.addManufacturingRig(tid),
              up: true,
              maxHeight: 300,
              // selectionClosesFlyout: false, // TODO does not work
            )),
      ];
    }
    if (controller.getNumSelectedReactionRigs() < maxNumRigs) {
      addReactionRigButton = [
        Padding(
            padding: const EdgeInsets.fromLTRB(itemPadding, 0, 0, 0),
            child: DropdownMenuFlyout(
              current: 'Add Rigs',
              items: controller.getReactionRigs().map((e) => e.name).toList(),
              style: style,
              parentController: flyoutController,
              ids: controller.getReactionRigs().map((e) => e.tid).toList(),
              onSelect: (tid) => controller.addReactionRig(tid),
              up: true,
              maxHeight: 350,
              // selectionClosesFlyout: false, // TODO does not work
            )),
      ];
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: itemPadding),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
                Text('Structures', style: headerStyle),
                const SizedBox(width: padding),
                DropdownMenuFlyout(
                  current: controller.getManufacturingStructure().name,
                  items: controller.getManufacturingStructures().map((e) => e.name).toList(),
                  ids: controller.getManufacturingStructures().map((e) => e.tid).toList(),
                  width: 55,
                  style: style,
                  parentController: flyoutController,
                  onSelect: (x) => controller.setManufacturingStructure(x),
                ),
              ] +
              List<Widget>.generate(
                controller.getSelectedManufacturingRigs().length,
                (i) => Padding(
                  padding: const EdgeInsets.fromLTRB(itemPadding, 0, 0, 0),
                  child: Tooltip(
                    preferBelow: false,
                    waitDuration: const Duration(milliseconds: 500),
                    verticalOffset: 17,
                    message: controller.getSelectedManufacturingRigs()[i].name,
                    child: HoverButton(
                      color: theme.surface,
                      hoveredColor: theme.secondary,
                      onTap: () => controller.removeManufacturingRig(i),
                      hoveredElevation: 0,
                      borderRadius: 4,
                      builder: (hovered) {
                        return Container(
                            padding: const EdgeInsets.all(3),
                            child: Icon(Icons.close, size: 16, color: hovered ? theme.onSecondary : theme.onSurface));
                      },
                    ),
                  ),
                ),
              ) +
              addManufacturingRigButton +
              [
                const SizedBox(width: padding * 2),
                DropdownMenuFlyout(
                  current: controller.getReactionStructure().name,
                  items: controller.getReactionStructures().map((e) => e.name).toList(),
                  ids: controller.getReactionStructures().map((e) => e.tid).toList(),
                  width: 55,
                  style: style,
                  parentController: flyoutController,
                  onSelect: (x) => controller.setReactionStructure(x),
                ),
              ] +
              List<Widget>.generate(
                controller.getSelectedReactionRigs().length,
                (i) => Padding(
                  padding: const EdgeInsets.fromLTRB(itemPadding, 0, 0, 0),
                  child: Tooltip(
                    waitDuration: const Duration(milliseconds: 500),
                    preferBelow: false,
                    verticalOffset: 17,
                    message: controller.getSelectedReactionRigs()[i].name,
                    child: HoverButton(
                      color: theme.surface,
                      hoveredColor: theme.secondary,
                      onTap: () => controller.removeReactionRig(i),
                      hoveredElevation: 0,
                      borderRadius: 4,
                      builder: (hovered) {
                        return Container(
                            padding: const EdgeInsets.all(3),
                            child: Icon(Icons.close, size: 16, color: hovered ? theme.onSecondary : theme.onSurface));
                      },
                    ),
                  ),
                ),
              ) +
              addReactionRigButton,
        ),
      ],
    );
  }
}

class CostsSection extends StatelessWidget {
  const CostsSection({
    Key? key,
    required this.headerStyle,
    required this.style,
    required this.flyoutController,
    required this.controller,
    required this.color,
  }) : super(key: key);

  final Color color;
  final TextStyle headerStyle;
  final TextStyle style;
  final FlyoutController flyoutController;
  final OptionsController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<MyTheme>(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Costs', style: headerStyle),
        const SizedBox(width: padding),
        Text('Reaction index', style: style),
        const SizedBox(width: padding),
        TableTextField(
          initialText: controller.getReactionSystemCostIndex().toString(),
          textColor: theme.on(color),
          activeBorderColor: theme.primary,
          floatingPoint: true,
          maxNumDigits: 4,
          width: 32,
          onChanged: (t) => controller.setReactionSystemCostIndex(t == '' ? .1 : double.parse(t)),
        ),
        const SizedBox(width: padding),
        Text('Manufacturing index', style: style),
        const SizedBox(width: padding),
        TableTextField(
          initialText: controller.getManufacturingSystemCostIndex().toString(),
          textColor: theme.on(color),
          activeBorderColor: theme.primary,
          floatingPoint: true,
          maxNumDigits: 4,
          width: 32,
          onChanged: (t) => controller.setManufacturingSystemCostIndex(t == '' ? .1 : double.parse(t)),
        ),
        const SizedBox(width: padding),
        Text('Sales tax', style: style),
        const SizedBox(width: padding),
        TableTextField(
          initialText: controller.getSalesTaxPercent().toString(),
          textColor: theme.on(color),
          activeBorderColor: theme.primary,
          floatingPoint: true,
          maxNumDigits: 4,
          width: 32,
          onChanged: (t) => controller.setSalesTax(t == '' ? 0 : double.parse(t)),
        ),
      ],
    );
  }
}

class BlueprintsSection extends StatelessWidget {
  const BlueprintsSection({
    Key? key,
    required this.headerStyle,
    required this.style,
    required this.color,
    required this.controller,
  }) : super(key: key);

  final TextStyle headerStyle;
  final TextStyle style;
  final Color color;
  final OptionsController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<MyTheme>(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Blueprints', style: headerStyle),
            const SizedBox(width: MyTheme.appBarPadding),
            Text('ME', style: style),
            const SizedBox(width: itemPadding),
            TableTextField(
              initialText: controller.getME().toString(),
              textColor: theme.on(color),
              activeBorderColor: theme.primary,
              maxNumDigits: 2,
              width: 25,
              onChanged: (t) => controller.setME(t == '' ? 0 : int.parse(t)),
            ),
            const SizedBox(width: MyTheme.appBarPadding),
            Text('TE', style: style),
            const SizedBox(width: itemPadding),
            TableTextField(
              initialText: controller.getTE().toString(),
              textColor: theme.on(color),
              activeBorderColor: theme.primary,
              maxNumDigits: 2,
              width: 25,
              onChanged: (t) => controller.setTE(t == '' ? 0 : int.parse(t)),
            ),
            const SizedBox(width: MyTheme.appBarPadding),
            Text('Max number of blueprints', style: style),
            const SizedBox(width: itemPadding),
            TableTextField(
              initialText: controller.getMaxNumBlueprints().toString(),
              textColor: theme.on(color),
              activeBorderColor: theme.primary,
              maxNumDigits: 3,
              width: 30,
              onChanged: (t) => controller.setMaxNumBlueprints(t == '' ? 20 : int.parse(t)),
            ),
          ],
        ),
      ],
    );
  }
}

class JobsSection extends StatelessWidget {
  const JobsSection({
    Key? key,
    required this.headerStyle,
    required this.style,
    required this.color,
    required this.controller,
  }) : super(key: key);

  final TextStyle headerStyle;
  final TextStyle style;
  final Color color;
  final OptionsController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<MyTheme>(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Jobs', style: headerStyle),
        const SizedBox(width: padding),
        Text('Reactions jobs', style: style),
        const SizedBox(width: padding),
        TableTextField(
          initialText: controller.getReactionSlots().toString(),
          textColor: theme.on(color),
          activeBorderColor: theme.primary,
          maxNumDigits: 4,
          onChanged: (t) => controller.setReactionSlots(t == '' ? 60 : int.parse(t)),
        ),
        const SizedBox(width: padding),
        Text('Manufacturing jobs', style: style),
        const SizedBox(width: padding),
        TableTextField(
          initialText: controller.getManufacturingSlots().toString(),
          textColor: theme.on(color),
          activeBorderColor: theme.primary,
          maxNumDigits: 4,
          onChanged: (t) => controller.setManufacturingSlots(t == '' ? 60 : int.parse(t)),
        ),
      ],
    );
  }
}

class SkillSection extends StatelessWidget {
  const SkillSection({
    Key? key,
    required this.style,
    required this.color,
    required this.headerStyle,
    required this.base,
    required this.controller,
  }) : super(key: key);

  final TextStyle style;
  final Color color;
  final TextStyle headerStyle;
  final Color base;
  final OptionsController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<MyTheme>(context);
    final skills = controller.getSkills();
    final numSkills = skills.length;
    final cols = <List<Widget>>[[], [], [], []];
    for (int j = 0; j < numSkills; ++j) {
      int i = j > numSkills ~/ 2 ? 1 : 0;
      cols[i * 2].add(
        Container(
          alignment: Alignment.center,
          height: 26,
          child: Padding(
              padding: EdgeInsets.fromLTRB(itemPadding / 2 * i, itemPadding / 2, 10, itemPadding / 2),
              child: Text(skills[j].name, style: style)),
        ),
      );
      cols[i * 2 + 1].add(
        Container(
          alignment: Alignment.center,
          height: 26,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, itemPadding / 3, 6, itemPadding / 3),
            child: TableTextField(
              initialText: skills[j].level.toString(),
              textColor: theme.on(color),
              activeBorderColor: theme.primary,
              allowEmptyString: false,
              onChanged: (t) => controller.setSkillLevel(skills[j].tid, t == '' ? 3 : int.parse(t)),
              width: 20,
              maxNumDigits: 1,
              // overwrite: true,
            ),
          ),
        ),
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[Text('Skills', style: headerStyle)] +
              List<Widget>.generate(
                  3,
                  (i) => Padding(
                        padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                        child: HoverButton(
                          builder: (hovered) => Container(
                              alignment: Alignment.center,
                              width: 20,
                              height: 20,
                              child: Text(
                                  i == 0
                                      ? 'III'
                                      : i == 1
                                          ? 'IV'
                                          : 'V',
                                  style: style.copyWith(color: hovered ? theme.on(base) : theme.onSurface))),
                          splashColor: theme.on(base).withOpacity(.5),
                          shadowColor: theme.shadow,
                          borderRadius: 2,
                          onTap: () => controller.setAllSkillLevels(i + 3),
                          hoveredColor: base,
                          hoveredElevation: 0,
                          color: theme.surface,
                        ),
                      )),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(MyTheme.appBarPadding, 0, 0, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: List<Widget>.generate(
                4, (i) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: cols[i])),
          ),
        ),
      ],
    );
  }
}

class ColorChanger extends StatefulWidget {
  ColorChanger(this.controller, this.color, this.base, {Key? key}) : super(key: key);
  FlyoutController controller;
  Color color;
  Color base;

  @override
  State<ColorChanger> createState() => _ColorChangerState();
}

class _ColorChangerState extends State<ColorChanger> {
  final FlyoutController controller = FlyoutController(MyTheme.buttonFocusDuration, maxVotes: 1);

  @override
  void initState() {
    widget.controller.connect(controller);
    super.initState();
  }

  @override
  void dispose() {
    widget.controller.disconnect(controller);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<MyTheme>(context);
    return Flyout(
        content: (ctx) => ColorChangerContent((Color c) => Provider.of<MyTheme>(ctx, listen: false).setColor(c)),
        child: MouseRegion(
          onExit: (_) => controller.startCloseTimer(),
          child: HoverButton(
            mouseCursor: MouseCursor.defer,
            builder: (hovered) => Padding(
              padding: const EdgeInsets.all(4.0),
              child: Icon(Icons.color_lens, size: 14, color: theme.on(hovered ? widget.base : theme.surface)),
            ),
            color: theme.surface,
            hoveredColor: widget.base,
            onTap: () => controller.open(),
            borderRadius: 3,
            hoveredElevation: 0,
          ),
        ),
        openMode: FlyoutOpenMode.custom,
        align: FlyoutAlign.childRightCenter,
        controller: controller);
  }
}

class ColorChangerContent extends StatefulWidget {
  const ColorChangerContent(this.onChange, {Key? key}) : super(key: key);

  final Function(Color) onChange;

  @override
  State<ColorChangerContent> createState() => _ColorChangerContentState();
}

class _ColorChangerContentState extends State<ColorChangerContent> {
  Color color = Colors.black;
  double hue = 0;

  // Changing saturation and value does nothing basically, when using ColorScheme.fromSeed(.)
  static const double sat = 1;
  static const double val = 1;

  @override
  void initState() {
    hue = HSVColor.fromColor(Provider.of<MyTheme>(context, listen: false).getColor()).hue;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<MyTheme>(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.surface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: theme.outline),
      ),
      constraints: const BoxConstraints.tightFor(width: 180, height: 30),
      child: Slider(
        value: hue,
        mouseCursor: MouseCursor.defer,
        min: 0,
        max: 360,
        onChanged: (double v) {
          setState(() {
            hue = v;
            color = HSVColor.fromAHSV(1, hue, sat, val).toColor();
          });
          widget.onChange(color);
        },
      ),
    );
  }
}

class LightDarkModeButtons extends StatelessWidget {
  const LightDarkModeButtons(
      {required this.light, required this.color, required this.base, required this.onTap, Key? key})
      : super(key: key);

  final void Function() onTap;
  final bool light;
  final Color color;
  final Color base;

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<MyTheme>(context);
    return HoverButton(
      mouseCursor: MouseCursor.defer,
      builder: (hovered) => Padding(
        padding: const EdgeInsets.all(4.0),
        child:
            Icon(light ? Icons.light_mode : Icons.dark_mode, size: 14, color: theme.on(hovered ? base : theme.surface)),
      ),
      color: theme.surface,
      hoveredColor: base,
      borderRadius: 3,
      hoveredElevation: 0,
      onTap: onTap,
    );
  }
}
