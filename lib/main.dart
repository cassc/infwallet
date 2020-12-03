import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_i18n/loaders/decoders/yaml_decode_strategy.dart';
import 'view/transaction_list.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  final FlutterI18nDelegate flutterI18nDelegate = FlutterI18nDelegate(
    translationLoader: FileTranslationLoader(
      useCountryCode: false,
      fallbackFile: 'assets/i18n/en.yaml',
      basePath: 'assets/i18n',
      decodeStrategies: [YamlDecodeStrategy()],
    ),
  );

  WidgetsFlutterBinding.ensureInitialized();

  // init i18n
  await flutterI18nDelegate.load(null);

  runApp(MyApp(flutterI18nDelegate));
}

class MyApp extends StatelessWidget {
  final FlutterI18nDelegate flutterI18nDelegate;
  MyApp(this.flutterI18nDelegate);

  @override
  Widget build(BuildContext context) {
  
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'OpenWalet',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TransactionListPage(),
      localizationsDelegates: [
        flutterI18nDelegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate
      ],
    );
  }
}
