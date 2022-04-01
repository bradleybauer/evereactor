import 'package:flutter/material.dart';

import 'my_theme.dart';
import 'widgets/home_page.dart';

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    theme.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EveIndy',
      home: HomePage(MyTheme.appHeight, MyTheme.appWidth),
      theme: theme.theme,
    );
  }
}
