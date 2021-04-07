import 'dart:convert';

import 'package:admob_flutter/admob_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:listadecoisa/model/coisas.dart';
import 'package:listadecoisa/model/user.dart';
import 'package:listadecoisa/view/homePage.dart';
import 'package:listadecoisa/view/loginPage.dart';
import 'package:listadecoisa/controller/global.dart' as global;
import 'package:shared_preferences/shared_preferences.dart';

import 'controller/temas.dart';
import 'controller/temas.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  Admob.initialize();
  //global.banco.db.enablePersistence();
  global.banco.db.settings = Settings(persistenceEnabled: true);
  await SharedPreferences.getInstance().then((value) async {
    global.prefs = value;
  });
  global.tema = global.prefs.getString("tema") ?? "Original";
  var auxi = global.prefs.getString("user") ?? '';
  try {
    if (global.prefs.getBool('fezLogin')) {
      global.usuario = new UserP.fromJson(json.decode(auxi));
      List<dynamic> listCat = await global.banco.getCoisas(user: global.usuario);
      if (listCat != null) {
        global.lisCoisa = listCat.map((i) => Coisas.fromSnapshot(i)).toList();
      }
    }
  } catch (e) {
    print(e);
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.light,
      statusBarColor: getPrimary(), // status bar color
    ));
    return MaterialApp(
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      title: 'Lista de Coisas',
      theme: ThemeData(
        accentColor: getSecondary(),
        primaryColor: getSecondary(),
        colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: getSecondary(),
              secondary: getSecondary(),
            ),
      ),
      home: global.usuario != null ? MyHomePage(title: 'Lista de Coisas') : Login(),
    );
  }
}
