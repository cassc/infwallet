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
            '账户',
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
            '借贷',
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
            '标签',
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
            '图表',
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
          title: Text('Settings'),
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

void showDeleteTxDialog(BuildContext context, okCallback) {
  showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('警告！'),
          content: Text('确认删除此交易？'),
          actions: <Widget>[
            FlatButton(
              child: Text('取消'),
              onPressed: () => _closePop(context),
            ),
            FlatButton(
              child: Text('删除'),
              onPressed: okCallback,
            ),
          ],
        );
      });
}

void showDeleteAccountDialog(BuildContext context, okCallback) {
  showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('警告！'),
          content: Text('相关交易记录将同时删除！确认要删除吗？'),
          actions: <Widget>[
            FlatButton(
              child: Text('取消'),
              onPressed: () => _closePop(context),
            ),
            FlatButton(
              child: Text('删除'),
              onPressed: okCallback,
            ),
          ],
        );
      });
}

void showDeleteDebtDialog(BuildContext context, okCallback) {
  showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('警告！'),
          content: Text('相关交易记录将一并删除，确认删除吗？'),
          actions: <Widget>[
            FlatButton(
              child: Text('取消'),
              onPressed: () => _closePop(context),
            ),
            FlatButton(
              child: Text('删除'),
              onPressed: okCallback,
            ),
          ],
        );
      });
}

void showDeleteTagDialog(BuildContext context, okCallback) {
  showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Warning'),
          content: Text('Really delete this tag?'),
          actions: <Widget>[
            FlatButton(
              child: Text('Cancel'),
              onPressed: () => _closePop(context),
            ),
            FlatButton(
              child: Text('OK'),
              onPressed: okCallback,
            ),
          ],
        );
      });
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
