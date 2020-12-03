import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:infwallet/model/account.dart';
import 'package:infwallet/model/debts.dart';

import '../const.dart';
import 'debt_list.dart';
import 'shared.dart';

class DebtDetailsPage extends StatelessWidget {
  final Debt debt;
  final Account account;
  DebtDetailsPage(this.debt, this.account);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: quitApp,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text(FlutterI18n.translate(context, 'debt')),
          actions: _genActionBtns(context),
        ),
        body: _buildDebtDetails(context),
        drawer: genSideDrawer(context),
      ),
    );
  }

  Widget _buildDebtDetails(ctx) {
    return ListView(
      padding: EdgeInsets.all(20),
      children: <Widget>[
        _debtAmountRow(ctx),
        _debtPaidRow(ctx),
        _debtAccountRow(ctx),
        _debtDateRow(ctx),
        _debtNoteRow(ctx),
      ],
    );
  }

  Widget _debtAmountRow(context) {
    String typeStr = debt.dbType == BORROW ? FlutterI18n.translate(context, 'borrow') : FlutterI18n.translate(context, 'lend');

    String amountStr = "${debt.amount} ${account.currencySymbol}";
    return Card(
      elevation: 16,
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              typeStr,
              textAlign: TextAlign.left,
            ),
            SizedBox(
              height: 8,
            ),
            Text(
              amountStr,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _debtPaidRow(context) {
    String txTypeStr = debt.dbType == BORROW ? FlutterI18n.translate(context, 'paid') : FlutterI18n.translate(context, 'received');
    double txTotalAmount = 0;
    if (debt.txList != null && debt.txList.length > 0) {
      txTotalAmount =
          debt.txList.map((tx) => tx.amount).reduce((val, el) => val + el);
    }
    return Card(
      elevation: 16,
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              txTypeStr,
              textAlign: TextAlign.left,
            ),
            SizedBox(
              height: 8,
            ),
            Text(
              '$txTotalAmount ${account.currencySymbol}',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _debtNoteRow(context) {
    return Card(
      elevation: 16,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              FlutterI18n.translate(context, 'note'),
              textAlign: TextAlign.left,
            ),
            SizedBox(
              height: 8,
            ),
            Text(
              '${debt.note}',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _debtDateRow(context) {
    String dateString = DateTime.fromMillisecondsSinceEpoch(debt.dbDate)
        .toString()
        .substring(0, 16);

    print('id: ${debt.id} dt: ${debt.dbDate}');
    return Card(
      elevation: 16,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Date',
              textAlign: TextAlign.left,
            ),
            SizedBox(
              height: 8,
            ),
            Text(
              dateString,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _debtAccountRow(context) {
    return Card(
      elevation: 16,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              FlutterI18n.translate(context, 'account'),
              textAlign: TextAlign.left,
            ),
            SizedBox(
              height: 8,
            ),
            Text(
              '${account.title}',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  dynamic _makeDelCallback(BuildContext context) {
    return () async {
      await deleteDebtById(debt);
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DebtListPage(),
          ));
    };
  }

  dynamic _genActionBtns(context) {
    // debt edit disabled
    // Widget editDebtButton = IconButton(
    //   icon: Icon(Icons.edit),
    //   onPressed: () {
    //     Navigator.push(context, MaterialPageRoute(builder: (context) {
    //       return DebtEditPage(debt);
    //     }));
    //   },
    // );
    List<Widget> actions = [];
    if (debt.id > 0) {
      actions.add(IconButton(
        icon: Icon(Icons.delete),
        onPressed: () {
          showDeleteDebtDialog(context, _makeDelCallback(context));
        },
      ));
    }
    return actions;
  }
}
