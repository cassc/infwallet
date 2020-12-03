import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:infwallet/const.dart';
import 'package:infwallet/model/debts.dart';
import 'package:infwallet/model/account.dart';
import 'package:infwallet/model/transaction.dart';
import 'package:infwallet/view/transaction_edit.dart';

import 'debt_details.dart';
import 'debt_edit.dart';
import 'shared.dart';

class DebtListPage extends StatefulWidget {
  @override
  DebtListState createState() => DebtListState();
}

class DebtListState extends State<DebtListPage> {
  List<Debt> _dbList = [];
  List<Account> _acList = [];
  @override
  void initState() {
    super.initState();
    _getData();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: quitApp,
      child: Scaffold(
        appBar: genAppBar(title: '借贷列表'),
        body: _buildDebtList(),
        drawer: genSideDrawer(context),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DebtEditPage(Debt()),
                ));
          },
        ),
      ),
    );
  }

  Widget _buildDebtList() {
    if (_dbList == null || _dbList.isEmpty) {
      return Container();
    }
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: _dbList.length,
      itemBuilder: (BuildContext context, int index) {
        Debt debt = _dbList[index];
        return _buildDebtItem(debt);
      },
    );
  }

  void _getData() async {
    List<Account> acList = await getAccounts();
    List<Debt> dbList = await getDebts();
    setState(() {
      _acList = acList;
      _dbList = dbList;
    });
  }

  Widget _receivOrPay(Debt debt) {
    if (debt.dbType == 'lend') {
      return RaisedButton(
        elevation: 8,
        color: Colors.amberAccent,
        child: Text(FlutterI18n.translate(context, 'receive')),
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => TransactionEditPage(Transaction(
                        dbid: debt.id,
                        amount: debt.amount,
                        txType: INCOME,
                        note:FlutterI18n.translate(context, 'receive_from_loan')  ,
                        aid: debt.aid,
                      ))));
        },
      );
    } else {
      return RaisedButton(
        child: Text(FlutterI18n.translate(context, 'payback')),
        color: Colors.greenAccent,
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => TransactionEditPage(Transaction(
                        dbid: debt.id,
                        amount: debt.amount,
                        txType: EXPENSE,
                        note:FlutterI18n.translate(context, 'payback_loan') ,
                        aid: debt.aid,
                      ))));
        },
      );
    }
  }

  Widget _buildDebtItem(Debt debt) {
    String note = debt.note;
    String circleChar =
        (note == null || note.isEmpty) ? '' : note.substring(0, 1);
    String dateString = DateTime.fromMillisecondsSinceEpoch(debt.dbDate)
        .toString()
        .substring(0, 16);

        String typeStr = debt.dbType == BORROW ?FlutterI18n.translate(context, 'borrow')  : FlutterI18n.translate(context, 'lend');
    String amountStr =
        '${debt.amount} ${currencySymbolFromAid(debt.aid, _acList)}';
        String txTypeStr = debt.dbType == BORROW ? FlutterI18n.translate(context, 'payback') : FlutterI18n.translate(context, 'receive');
    double txTotalAmount = 0;
    if (debt.txList != null && debt.txList.length > 0) {
      txTotalAmount =
          debt.txList.map((tx) => tx.amount).reduce((val, el) => val + el);
    }

    return Card(
      elevation: 12,
      margin: EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          ListTile(
            leading: CircleAvatar(
              child: Text(circleChar),
            ),
            title: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  '$typeStr $amountStr',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 8,
                ),
                Text(
                  '$txTypeStr $txTotalAmount',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 10,
                ),
              ],
            ),
            subtitle: Text(dateString),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(
                builder: (context) {
                  Account ac = _acList.firstWhere((ac) => ac.id == debt.aid);
                  return DebtDetailsPage(debt, ac);
                },
              ));
            },
          ),
          Padding(
            padding: EdgeInsets.only(right: 18, bottom: 8),
            child: _receivOrPay(debt),
          ),
        ],
      ),
    );
  }
}
