import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'my_theme.dart';
import 'widgets/main.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<MyTheme>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EveReactor',
      home: const HomePage(),
      theme: theme.theme,
      themeMode: ThemeMode.light,
    );
  }
}
