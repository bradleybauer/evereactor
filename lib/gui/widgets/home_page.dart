import 'package:flutter/material.dart';

import 'package:EveIndy/gui/my_theme.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: Center(
        child: Container(
          child: Column(
            children: [
              Container(
                width: 200,
                height: 50,
                color: theme.colors.primary,
                child: Center(
                    child:
                        Text("primary", style: TextStyle(fontFamily: 'NotoSans', fontWeight: FontWeight.w600, color: theme.colors.onPrimary))),
              ),
              Container(
                width: 200,
                height: 50,
                color: theme.colors.secondary,
                child: Center(
                    child: Text("secondary",
                        style: TextStyle(fontFamily: 'NotoSans', fontWeight: FontWeight.w600, color: theme.colors.onSecondary))),
              ),
              Container(
                width: 200,
                height: 50,
                color: theme.colors.tertiary,
                child: Center(
                    child: Text("tertiary",
                        style: TextStyle(fontFamily: 'NotoSans', fontWeight: FontWeight.w600, color: theme.colors.onTertiary))),
              ),
              Container(
                width: 200,
                height: 50,
                color: theme.colors.error,
                child: Center(
                    child: Text('error', style: TextStyle(fontFamily: 'NotoSans', fontWeight: FontWeight.w600, color: theme.colors.onError))),
              ),
              OutlinedButton(
                onPressed: () {
                  theme.toggleTheme();
                },
                child: Text('toggle theme'),
              ),
              Expanded(
                  child: Container(
                width: 200,
                color: theme.colors.secondaryContainer,
              )),
            ],
          ),
        ),
      ),
    );
  }
}
