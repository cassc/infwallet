import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'dart:math';

import 'package:infwallet/model/account.dart';
import 'package:infwallet/model/tags.dart';
import 'package:infwallet/view/settings.dart';

import 'account_list.dart';
import 'debt_list.dart';
import 'overview_page.dart';
import 'tag_manage.dart';
import 'transaction_list.dart';

const COLOR_BG = Color.fromRGBO(0, 159, 171, 1);
const BORDER_COLOR = Color.fromRGBO(145, 179, 184, 0.05);

AppBar genAppBar({String title: ''}) {
  return AppBar(
    title: Text(
      title,
      style: TextStyle(
        color: Colors.white,
      ),
    ),
    actions: [
      // IconButton(
      //   icon: Icon(Icons.search),
      //   onPressed: () {},
      // )
    ],
  );
}

Widget genSideDrawer(BuildContext context) {
  Color darkcolor = Theme.of(context).primaryColorDark;
  TextStyle textStyle = TextStyle(
    fontWeight: FontWeight.bold,
    color: Colors.black87,
  );
  return Drawer(
    child: ListView(
      padding: EdgeInsets.all(0),
      children: [
        DrawerHeader(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'InfWallet',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: Colors.white,
                  ),
                ),
                /*  Row(
                  children: [
                    IconButton(
                      color: Colors.white,
                      icon: Icon(Icons.import_export_rounded),
                      onPressed: () {},
                    ),
                  ],
                ), */
              ]),
          decoration: BoxDecoration(
            color: Colors.blue,
          ),
        ),
        ListTile(
          leading: Icon(
            Icons.transform,
            color: darkcolor,
          ),
          title: Text(
            FlutterI18n.translate(context, 'transactions'),
            style: textStyle,
          ),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TransactionListPage(),
            ),
          ),
        ),
        ListTile(
          leading: Icon(
            Icons.account_balance_wallet,
            color: darkcolor,
          ),
          title: Text(
            FlutterI18n.translate(context, 'account'),
            style: textStyle,
          ),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AccountListPage(),
            ),
          ),
        ),
        ListTile(
          leading: Icon(
            Icons.attach_money,
            color: darkcolor,
          ),
          title: Text(
            FlutterI18n.translate(context, 'debt'),
            style: textStyle,
          ),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DebtListPage(),
            ),
          ),
        ),
        ListTile(
          leading: Icon(
            Icons.card_membership,
            color: darkcolor,
          ),
          title: Text(
            FlutterI18n.translate(context, 'tag'),
            style: textStyle,
          ),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TagManagePage(),
            ),
          ),
        ),
        ListTile(
          leading: Icon(
            Icons.graphic_eq,
            color: darkcolor,
          ),
          title: Text(
            FlutterI18n.translate(context, 'chart'),
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OverviewPage(),
            ),
          ),
        ),
        ListTile(
          leading: Icon(Icons.settings),
          title: Text(FlutterI18n.translate(context, 'settings')),
          onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SettingsPage(),
              )),
        ),
      ],
    ),
  );
}

void _closePop(BuildContext context) {
  Navigator.of(context).pop();
}

Future confirmDialog(
    BuildContext context, String title, String body, okCallback) {
  return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(body),
          actions: <Widget>[
            FlatButton(
              child: Text(FlutterI18n.translate(context, 'cancel')),
              onPressed: () => _closePop(context),
            ),
            FlatButton(
              child: Text(FlutterI18n.translate(context, 'confirm')),
              onPressed: (){
                _closePop(context);
                okCallback();
              },
            ),
          ],
        );
      });
}

void popup(BuildContext context, String title, String body) {
  showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(body),
          actions: <Widget>[
            FlatButton(
              child: Text(FlutterI18n.translate(context, 'ok')),
              onPressed: () => _closePop(context),
            ),
          ],
        );
      });
}

void showDeleteTxDialog(BuildContext context, okCallback) {
  confirmDialog(context, FlutterI18n.translate(context, 'warning'),
      FlutterI18n.translate(context, 'confirm_delete_tx'), okCallback);
}

void showDeleteAccountDialog(BuildContext context, okCallback) {
  confirmDialog(context, FlutterI18n.translate(context, 'warning'),
      FlutterI18n.translate(context, 'delete_account_warning'), okCallback);
}

void showDeleteDebtDialog(BuildContext context, okCallback) {
  confirmDialog(context, FlutterI18n.translate(context, 'warning'),
      FlutterI18n.translate(context, 'delete_debt_warning'), okCallback);
}

void showDeleteTagDialog(BuildContext context, okCallback) {
  confirmDialog(context, FlutterI18n.translate(context, 'warning'),
      FlutterI18n.translate(context, 'delete_tag_warning'), okCallback);
}

String currencySymbolFromAid(int aid, List<Account> acList) {
  if (aid == null || aid < 1 || acList == null || acList.isEmpty) {
    return '?';
  }
  final currency = acList.firstWhere((ac) => ac.id == aid);
  return currency.currencySymbol;
}

Tag tagByTitle(title, tagList) {
  return tagList.firstWhere((tag) {
    return tag.title == title;
  });
}

/// Construct a color from a hex code string, of the format #RRGGBB.
Color hexToColor(String code) => Color(int.parse(code.substring(1), radix: 16));
// Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);

String colorToHex(Color color) => '#${color.value.toRadixString(16)}';

Future<bool> quitApp() async {
  SystemChannels.platform.invokeMethod('SystemNavigator.pop');
  return true;
}

Color genColor() {
  return Color((Random().nextDouble() * 0xFFFFFF).toInt() << 0)
      .withOpacity(1.0);
}
