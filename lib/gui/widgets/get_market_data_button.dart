import 'package:EveIndy/controllers/market.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../strings.dart';
import '../my_theme.dart';
import 'hover_button.dart';

class GetMarketDataButton extends StatefulWidget {
  const GetMarketDataButton({Key? key}) : super(key: key);

  @override
  State<GetMarketDataButton> createState() => _GetMarketDataButtonState();
}

// TODO this is just temporary code
class _GetMarketDataButtonState extends State<GetMarketDataButton> {
  double _loadingProgress = 0.0;

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<MyTheme>(context);
    final controller = Provider.of<MarketController>(context);
    Widget widget;
    switch (controller.getEsiState()) {
      case EsiState.Idle:
        widget = HoverButton(
            onTap: () {
              controller.updateMarketData(
                progressCallback: (progress) {
                  setState(() => _loadingProgress = progress);
                },
              );
            },
            builder: (hovered) {
              return Center(
                child: Text(Strings.getMarketData,
                    style: TextStyle(
                        fontFamily: 'NotoSans',
                        fontSize: 12,
                        color: hovered ? theme.onPrimary : theme.onSurfaceVariant)),
              );
            },
            borderColor: theme.outline,
            borderRadius: 4,
            color: theme.surfaceVariant,
            splashColor: theme.onPrimary.withOpacity(.25),
            hoveredColor: theme.primary);
        break;

      case EsiState.CurrentlyFetchingData:
        widget = Container(
          decoration: BoxDecoration(
            border: Border.all(color: theme.outline),
            borderRadius: BorderRadius.circular(4),
            color: theme.surfaceVariant,
          ),
          child: Center(
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 14, maxHeight: 14),
                  child:
                  CircularProgressIndicator(
                    value: _loadingProgress == 0.0 ? null : _loadingProgress,
                    strokeWidth: 3,
                  ),
              ),
              SizedBox(width: MyTheme.appBarPadding),
              Text("Downloading", style: TextStyle(fontFamily: 'NotoSans', fontSize: 12)),
            ]),
          ),
        );
        break;
      // case _ButtonState.WAITING:
      //   widget = Tooltip(
      //     message: 'We are only able to get new market data from the ESI once every 5 minutes.',
      //     verticalOffset: 20,
      //     child: Container(
      //       decoration: BoxDecoration(
      //         border: Border.all(color: theme.outline),
      //         borderRadius: BorderRadius.circular(4),
      //         color: theme.surfaceVariant,
      //       ),
      //       child: const Center(child: Text("waiting", style: TextStyle(fontFamily: 'NotoSans', fontSize: 12))),
      //     ),
      //   );
      //   break;
    }

    return ConstrainedBox(
      constraints: BoxConstraints.tight(Size(130, MyTheme.appBarButtonHeight)),
      child: widget,
    );
  }
}
