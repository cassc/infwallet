import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:infwallet/db.dart';
import 'package:infwallet/view/shared.dart';
import 'package:sqflite/sqflite.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage>
    with SingleTickerProviderStateMixin {
  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  Widget _wrapRow(Widget row) {
    return Container(
      padding: EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
          border: BorderDirectional(
        bottom: BorderSide(
          color: BORDER_COLOR,
          width: 4,
        ),
      )),
      child: row,
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: quitApp,
      child: Scaffold(
        appBar: AppBar(
          title: Text(FlutterI18n.translate(context, 'settings')),
        ),
        body: _build(),
        drawer: genSideDrawer(context),
      ),
    );
  }

  final _formKey = GlobalKey<FormState>();

  exportData() async {
    Database db = await DBHelper.getDB();

    // todo export transactions to csv
  }

  Widget _exportRow() {
    return _wrapRow(
      Row(
        children: <Widget>[
          Container(
            child: Text(FlutterI18n.translate(context, "exportData")),
          ),
          Spacer(),
          ButtonTheme(
            minWidth: 30,
            height: 30,
            textTheme: ButtonTextTheme.primary,
            padding: EdgeInsets.symmetric(vertical: 4, horizontal: 9),
            child: RaisedButton(
              color: COLOR_BG,
              child: I18nText("export"),
              onPressed: exportData,
            ),
          ),
        ],
      ),
    );
  }

  Widget _build() {
    List<Widget> items = [
      _exportRow(),
    ];

    return Container(
      child: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 20),
          children: items,
        ),
      ),
    );
  }
}
