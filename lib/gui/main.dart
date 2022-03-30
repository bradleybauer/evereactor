import 'package:flutter/material.dart';

import 'package:EveIndy/gui/my_theme.dart';
import 'package:EveIndy/gui/widgets/home_page.dart';

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

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EveIndy',
      home: const HomePage(),
      theme: theme.theme,
    );
  }
}
