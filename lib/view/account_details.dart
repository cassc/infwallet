import 'package:flutter/material.dart';
import 'package:infwallet/const.dart';
import 'package:infwallet/model/account.dart';
import 'package:infwallet/model/transaction.dart';
import 'package:infwallet/view/account_list.dart';

import 'account_edit.dart';
import 'shared.dart';

class AccountDetailsPage extends StatefulWidget {
  final Account account;
  AccountDetailsPage(this.account);

  @override
  State<StatefulWidget> createState() {
    return AccountDetailsPageState();
  }
}

class AccountDetailsPageState extends State<AccountDetailsPage> {
  Account _ac;
  List<Transaction> _txList;
  @override
  void initState() {
    super.initState();
    setState(() {
      _ac = widget.account;
    });
    _loadTxByAccount();
  }

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
          title: Text('账户详情'),
          actions: [
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return AccountEditPage(account: _ac);
                }));
              },
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                showDeleteAccountDialog(context, _makeDelCallback(context));
              },
            ),
          ],
        ),
        body: _buildAccountDetails(),
        drawer: genSideDrawer(context),
      ),
    );
  }

  Widget _buildAccountDetails() {
    return ListView(
      padding: EdgeInsets.all(20),
      children: <Widget>[
        _aTitleRow(),
        _aBalanceRow(),
        _monthSummaryRow(),
      ],
    );
  }

  Widget _aBalanceRow() {
    String balanceStr =
        '${_ac.balance.toStringAsFixed(2)} ${_ac.currencySymbol}';

    return Card(
      elevation: 16,
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '余额',
              textAlign: TextAlign.left,
            ),
            SizedBox(
              height: 8,
            ),
            Text(
              balanceStr,
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

  Widget _aTitleRow() {
    return Card(
      elevation: 16,
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '账户名称',
              textAlign: TextAlign.left,
            ),
            SizedBox(
              height: 8,
            ),
            Text(
              '${_ac.title}',
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

  Widget _monthSummaryRow() {
    double mIncome = 0, mExpense = 0, mBalance = 0;

    for (Transaction tx in _txList) {
      if (tx.txType == INCOME) {
        mIncome += tx.amount;
        mBalance += tx.amount;
      } else {
        mExpense += tx.amount;
        mBalance -= tx.amount;
      }
      print('txtype: ${tx.txType}, amount: ${tx.amount}, balance: $mBalance, in: $mIncome, out: $mExpense');
    }

    String mBalanceStr = '${mBalance.toStringAsFixed(2)} ${_ac.currencySymbol}';
    String mIncomeStr = '${mIncome.toStringAsFixed(2)} ${_ac.currencySymbol}';
    String mExpenseStr = '${mExpense.toStringAsFixed(2)} ${_ac.currencySymbol}';

    return Card(
      elevation: 16,
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              '本月',
              textAlign: TextAlign.left,
            ),
            SizedBox(
              height: 8,
            ),
            Column(
              children: <Widget>[
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  leading: Text("收支合计"),
                  trailing: Text(mBalanceStr),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  leading: Text("总收入"),
                  trailing: Text(mIncomeStr),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  leading: Text("总支出"),
                  trailing: Text(mExpenseStr),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  dynamic _makeDelCallback(context) {
    return () async {
      await deleteAccountById(_ac.id);
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AccountListPage(),
          ));
    };
  }

  Future _loadTxByAccount() async {
    var today = DateTime.now();
    int monthStart =
        DateTime(today.year, today.month, 1).millisecondsSinceEpoch;
    List<Transaction> txList = await getTxsByAccount(_ac.id);
    txList = txList.where((tx) {
      return tx.txDate >= monthStart;
    }).toList();
    setState(() {
      _txList = txList;
    });
  }
}
