import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:openwallet/model/account.dart';
import 'package:openwallet/model/debts.dart';

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
          title: Text('借贷'),
          actions: _genActionBtns(context),
        ),
        body: _buildDebtDetails(),
        drawer: genSideDrawer(context),
      ),
    );
  }

  Widget _buildDebtDetails() {
    return ListView(
      padding: EdgeInsets.all(20),
      children: <Widget>[
        _debtAmountRow(),
        _debtPaidRow(),
        _debtAccountRow(),
        _debtDateRow(),
        _debtNoteRow(),
      ],
    );
  }

  Widget _debtAmountRow() {
    String typeStr = debt.dbType == BORROW ? '借入' : '贷出';

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

  Widget _debtPaidRow() {
    String txTypeStr = debt.dbType == BORROW ? '已偿还' : '已收到';
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

  Widget _debtNoteRow() {
    return Card(
      elevation: 16,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '备注',
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

  Widget _debtDateRow() {
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

  Widget _debtAccountRow() {
    return Card(
      elevation: 16,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '账户',
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
