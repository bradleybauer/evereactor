import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../adapters/options.dart';
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
  const OptionsFlyout(this.controller, this.color, this.base, this.headerStyle, this.style, {Key? key})
      : super(key: key);

  final Color color;
  final Color base;

  final TextStyle headerStyle;
  final TextStyle style;

  final FlyoutController controller;

  @override
  Widget build(BuildContext context) {
    final adapter = Provider.of<OptionsAdapter>(context);
    final theme = Provider.of<MyTheme>(context);
    return PhysicalModel(
      color: Colors.transparent,
      shadowColor: theme.shadow,
      elevation: 2,
      borderRadius: BorderRadius.circular(4),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      child: Container(
        constraints: BoxConstraints(maxHeight: size.height, maxWidth: size.width),
        // width: size.width,
        // height: size.height,
        color: color,
        child: Padding(
          padding: const EdgeInsets.all(padding),
          child: FocusTraversalGroup(
            child: Wrap(
              spacing: 8,
              direction: Axis.vertical,
              children: [
                SkillSection(style: style, color: color, headerStyle: headerStyle, base: base, adapter: adapter),
                JobsSection(headerStyle: headerStyle, style: style, color: color, adapter: adapter),
                BlueprintsSection(headerStyle: headerStyle, style: style, color: color, adapter: adapter),
                StructuresSection(style: style, controller: controller, headerStyle: headerStyle, adapter: adapter),
                CostsSection(headerStyle: headerStyle, style: style, adapter: adapter),
                MarketsSection(base: base, headerStyle: headerStyle, style: style),
                AppSection(
                    headerStyle: headerStyle,
                    style: style,
                    controller: controller,
                    color: color,
                    base: base,
                    adapter: adapter,
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
    required this.adapter,
    required this.context,
  }) : super(key: key);

  final TextStyle headerStyle;
  final TextStyle style;
  final FlyoutController controller;
  final Color color;
  final Color base;
  final OptionsAdapter adapter;
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
          items: adapter.getLangs().map((e) => e.name).toList(),
          style: style,
          parentController: controller,
          ids: adapter.getLangs().map((e) => e.label).toList(),
          onSelect: (lang) => Provider.of<Strings>(context, listen: false).setLang(lang),
          current: adapter.getLangName(),
          up: true,
        ),
        const SizedBox(width: itemPadding),
        Text('Colors', style: style),
        const SizedBox(width: itemPadding),
        LightDarkModeButtons(light: !theme.isDark, color: color, base: base, onTap: theme.toggleLightDark),
        const SizedBox(width: itemPadding),
        ColorChanger(controller, color, base),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [Text('Markets', style: headerStyle), const SizedBox(height: 4)] +
              SDE.system2name.entries
                  .map((i) => Padding(
                        padding: const EdgeInsets.fromLTRB(padding, 0, 0, 0),
                        child: LabeledCheckbox(
                          onTap: () => print('Name of system:' + i.key.toString() + ' is ' + Strings.get(i.value)),
                          getLabel: (hovered, value) => Text(Strings.get(i.value),
                              style: style.copyWith(
                                  color: value
                                      ? (hovered ? theme.on(hover) : theme.on(active))
                                      : hovered
                                          ? theme.on(hover)
                                          : theme.on(color))),
                          value: false,
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
    required this.adapter,
  }) : super(key: key);

  final TextStyle style;
  final FlyoutController controller;
  final TextStyle headerStyle;
  final OptionsAdapter adapter;

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<MyTheme>(context);
    List<Widget> addManufacturingRigButton = [];
    List<Widget> addReactionRigButton = [];
    final maxNumRigs = 3;
    if (adapter.getNumSelectedManufacturingRigs() < maxNumRigs) {
      addManufacturingRigButton = [
        Padding(
            padding: const EdgeInsets.fromLTRB(itemPadding, 0, 0, 0),
            child: DropdownMenuFlyout(
              current: 'Add Rigs',
              items: adapter.getManufacturingRigs().map((e) => e.name).toList(),
              style: style,
              parentController: controller,
              ids: adapter.getManufacturingRigs().map((e) => e.tid).toList(),
              onSelect: (tid) => adapter.addManufacturingRig(tid),
              up: true,
              maxHeight: 300,
            )),
      ];
    }
    if (adapter.getNumSelectedReactionRigs() < maxNumRigs) {
      addReactionRigButton = [
        Padding(
            padding: const EdgeInsets.fromLTRB(itemPadding, 0, 0, 0),
            child: DropdownMenuFlyout(
              current: 'Add Rigs',
              items: adapter.getReactionRigs().map((e) => e.name).toList(),
              style: style,
              parentController: controller,
              ids: adapter.getReactionRigs().map((e) => e.tid).toList(),
              onSelect: (tid) => adapter.addReactionRig(tid),
              up: true,
              maxHeight: 350,
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
                  current: adapter.getManufacturingStructure().name,
                  items: adapter.getManufacturingStructures().map((e) => e.name).toList(),
                  ids: adapter.getManufacturingStructures().map((e) => e.tid).toList(),
                  width: 55,
                  style: style,
                  parentController: controller,
                  onSelect: (x) => adapter.setManufacturingStructure(x),
                ),
              ] +
              List<Widget>.generate(
                adapter.getSelectedManufacturingRigs().length,
                (i) => Padding(
                  padding: const EdgeInsets.fromLTRB(itemPadding, 0, 0, 0),
                  child: Tooltip(
                    preferBelow: false,
                    verticalOffset: 17,
                    message: adapter.getSelectedManufacturingRigs()[i].name,
                    child: HoverButton(
                      color: theme.surface,
                      hoveredColor: theme.secondary,
                      onTap: () => adapter.removeManufacturingRig(i),
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
              addManufacturingRigButton + [
                const SizedBox(width: padding*2),
                DropdownMenuFlyout(
                  current: adapter.getReactionStructure().name,
                  items: adapter.getReactionStructures().map((e) => e.name).toList(),
                  ids: adapter.getReactionStructures().map((e) => e.tid).toList(),
                  width: 55,
                  style: style,
                  parentController: controller,
                  onSelect: (x) => adapter.setReactionStructure(x),
                ),
              ] +
              List<Widget>.generate(
                adapter.getSelectedReactionRigs().length,
                (i) => Padding(
                  padding: const EdgeInsets.fromLTRB(itemPadding, 0, 0, 0),
                  child: Tooltip(
                    preferBelow: false,
                    verticalOffset: 17,
                    message: adapter.getSelectedReactionRigs()[i].name,
                    child: HoverButton(
                      color: theme.surface,
                      hoveredColor: theme.secondary,
                      onTap: () => adapter.removeReactionRig(i),
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
    required this.adapter,
  }) : super(key: key);

  final TextStyle headerStyle;
  final TextStyle style;
  final OptionsAdapter adapter;

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
          initialText: adapter.getReactionSystemCostIndex().toString(),
          textColor: theme.onTertiaryContainer,
          activeBorderColor: theme.primary,
          floatingPoint: true,
          maxNumDigits: 4,
          width: 32,
          onChanged: (t) => adapter.setReactionSystemCostIndex(t == '' ? .1 : double.parse(t)),
        ),
        const SizedBox(width: padding),
        Text('Manufacturing index', style: style),
        const SizedBox(width: padding),
        TableTextField(
          initialText: adapter.getManufacturingSystemCostIndex().toString(),
          textColor: theme.onTertiaryContainer,
          activeBorderColor: theme.primary,
          floatingPoint: true,
          maxNumDigits: 4,
          width: 32,
          onChanged: (t) => adapter.setManufacturingSystemCostIndex(t == '' ? .1 : double.parse(t)),
        ),
        const SizedBox(width: padding),
        Text('Sales tax', style: style),
        const SizedBox(width: padding),
        TableTextField(
          initialText: adapter.getSalesTax().toString(),
          textColor: theme.onTertiaryContainer,
          activeBorderColor: theme.primary,
          floatingPoint: true,
          maxNumDigits: 4,
          width: 32,
          onChanged: (t) => adapter.setSalesTax(t == '' ? 0 : double.parse(t)),
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
    required this.adapter,
  }) : super(key: key);

  final TextStyle headerStyle;
  final TextStyle style;
  final Color color;
  final OptionsAdapter adapter;

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
              initialText: adapter.getME().toString(),
              textColor: theme.on(color),
              activeBorderColor: theme.primary,
              maxNumDigits: 2,
              width: 25,
              onChanged: (t) => adapter.setME(t == '' ? 0 : int.parse(t)),
            ),
            const SizedBox(width: MyTheme.appBarPadding),
            Text('TE', style: style),
            const SizedBox(width: itemPadding),
            TableTextField(
              initialText: adapter.getTE().toString(),
              textColor: theme.on(color),
              activeBorderColor: theme.primary,
              maxNumDigits: 2,
              width: 25,
              onChanged: (t) => adapter.setTE(t == '' ? 0 : int.parse(t)),
            ),
            const SizedBox(width: MyTheme.appBarPadding),
            Text('Max number of blueprints', style: style),
            const SizedBox(width: itemPadding),
            TableTextField(
              initialText: adapter.getMaxNumBlueprints().toString(),
              textColor: theme.on(color),
              activeBorderColor: theme.primary,
              maxNumDigits: 3,
              width: 30,
              onChanged: (t) => adapter.setMaxNumBlueprints(t == '' ? 20 : int.parse(t)),
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
    required this.adapter,
  }) : super(key: key);

  final TextStyle headerStyle;
  final TextStyle style;
  final Color color;
  final OptionsAdapter adapter;

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
          initialText: adapter.getReactionSlots().toString(),
          textColor: theme.on(color),
          activeBorderColor: theme.primary,
          maxNumDigits: 4,
          onChanged: (t) => adapter.setReactionSlots(t == '' ? 60 : int.parse(t)),
        ),
        const SizedBox(width: padding),
        Text('Manufacturing jobs', style: style),
        const SizedBox(width: padding),
        TableTextField(
          initialText: adapter.getManufacturingSlots().toString(),
          textColor: theme.on(color),
          activeBorderColor: theme.primary,
          maxNumDigits: 4,
          onChanged: (t) => adapter.setManufacturingSlots(t == '' ? 60 : int.parse(t)),
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
    required this.adapter,
  }) : super(key: key);

  final TextStyle style;
  final Color color;
  final TextStyle headerStyle;
  final Color base;
  final OptionsAdapter adapter;

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<MyTheme>(context);
    final skills = adapter.getSkills();
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
              onChanged: (t) => adapter.setSkillLevel(skills[j].tid, t == '' ? 3 : int.parse(t)),
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
                          onTap: () => adapter.setAllSkillLevels(i + 3),
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
