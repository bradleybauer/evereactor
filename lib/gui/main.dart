import 'package:EveIndy/gui/theme/current_theme.dart';
import 'package:flutter/material.dart';

import 'package:EveIndy/gui/theme/my_theme.dart';

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    currentTheme.addListener(() {
      setState(() {});
    });
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EveIndy',
      theme: MyTheme.lightTheme,
      darkTheme: MyTheme.darkTheme,
      themeMode: currentTheme.currentTheme,
      home: const Scaffold(
        body: Center(
          child: Text("hai"),
        ),
      ),
    );
  }
}
