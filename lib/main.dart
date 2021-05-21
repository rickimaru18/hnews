import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hnews/env.dart';
import 'package:hnews/pages/home_page.dart';
import 'package:hnews/providers/repository.dart';
import 'package:hnews/routes.dart';
import 'package:hnews/themes.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Future.wait(<Future<void>>[
    Env.init(),
    SystemChrome.setPreferredOrientations(<DeviceOrientation>[
      DeviceOrientation.portraitUp,
    ])
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Provider<Repository>(
      create: (_) => Repository(),
      child: MaterialApp(
        title: 'HNews',
        theme: themes,
        initialRoute: HomePage.ROUTE,
        routes: routes,
      ),
    );
  }
}
