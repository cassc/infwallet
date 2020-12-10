import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:infwallet/db.dart';
import 'package:infwallet/view/shared.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';
import 'package:file_picker/file_picker.dart';

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

  _restoreData() async {
    FilePickerResult result = await FilePicker.platform.pickFiles();
    if (result != null) {
      File file = File(result.files.single.path);
      File db = await getDbFile();
      try {
        await DBHelper.close();
        file.copy(db.path);
        final title = FlutterI18n.translate(context, 'success');
        final body = FlutterI18n.translate(context, 'restoreSuccess');
        popup(context, title, body);
      } catch (e) {
        final title = FlutterI18n.translate(context, 'error');
        final body = FlutterI18n.translate(context, 'restoreFailed');
        popup(context, title, body);
      }
    }
  }

  restoreData() async {
    await confirmDialog(context, FlutterI18n.translate(context, 'backup'),
        FlutterI18n.translate(context, 'restoreWarning'), _restoreData);
  }

  backupData() async {
    File db = await getDbFile();
    final params = SaveFileDialogParams(sourceFilePath: db.path);
    final filePath = await FlutterFileDialog.saveFile(params: params);

    if (filePath != null) {
      log('File saved to $filePath');
      String title = FlutterI18n.translate(context, 'success');
      String body = FlutterI18n.translate(context, 'backupSuccess');
      popup(context, title, body);
    }else{
      log('Backup canceled');
    }
  }

  Widget _backupRow() {
    return _wrapRow(
      Row(
        children: <Widget>[
          Container(
            child: Text(FlutterI18n.translate(context, "backupData")),
          ),
          Spacer(),
          ButtonTheme(
            minWidth: 30,
            height: 30,
            textTheme: ButtonTextTheme.primary,
            padding: EdgeInsets.symmetric(vertical: 4, horizontal: 9),
            child: RaisedButton(
              color: COLOR_BG,
              child: I18nText("backup"),
              onPressed: backupData,
            ),
          ),
        ],
      ),
    );
  }

  Widget _restoreRow() {
    return _wrapRow(
      Row(
        children: <Widget>[
          Container(
            child: Text(FlutterI18n.translate(context, "restoreData")),
          ),
          Spacer(),
          ButtonTheme(
            minWidth: 30,
            height: 30,
            textTheme: ButtonTextTheme.primary,
            padding: EdgeInsets.symmetric(vertical: 4, horizontal: 9),
            child: RaisedButton(
              color: COLOR_BG,
              child: I18nText("restore"),
              onPressed: restoreData,
            ),
          ),
        ],
      ),
    );
  }

  Widget _build() {
    List<Widget> items = [
      _backupRow(),
      _restoreRow(),
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
