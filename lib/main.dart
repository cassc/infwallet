import 'package:flutter/material.dart';

import 'view/transaction_list.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'OpenWalet',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TransactionListPage(),
    );
  }
}
