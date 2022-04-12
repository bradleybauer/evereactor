import 'package:flutter/material.dart';

import 'my_theme.dart';
import 'widgets/main.dart';

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // theme.addListener(() {
    //   setState(() {});
    // });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EveIndy',
      home: const HomePage(),
      theme: theme.theme,
      themeMode: ThemeMode.light,
    );
  }
}
