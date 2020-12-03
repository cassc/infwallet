import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:infwallet/model/account.dart';

import 'account_details.dart';
import 'account_edit.dart';
import 'shared.dart';

class AccountListPage extends StatefulWidget {
  @override
  AccountListState createState() => AccountListState();
}

class AccountListState extends State<AccountListPage> {
  List<Account> _accountList = [];

  @override
  void initState() {
    super.initState();
    _loadAccounts();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: quitApp,
      child: Scaffold(
        appBar: genAppBar(title: '账户列表'),
        body: _buildAccountList(),
        drawer: genSideDrawer(context),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AccountEditPage(),
                ));
          },
        ),
      ),
    );
  }

  Widget _buildAccountList() {
    if (_accountList.length == 0) {
      return Container();
    }
    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: _accountList.length,
      itemBuilder: (BuildContext context, int index) {
        Account account = _accountList[index];
        String title = account.title;
        double balance = account.balance;
        String currency = account.currencySymbol;
        String balanceStr = '${balance.toStringAsFixed(2)} $currency';
        return ListTile(
          leading: CircleAvatar(
            child: Text(title.substring(0, 1)),
          ),
          title: Text(title),
          trailing: Text(balanceStr),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(
              builder: (context) {
                return AccountDetailsPage(account);
              },
            ));
          },
        );
      },
    );
  }

  Future _loadAccounts() async {
    var acList = await getAccounts();
    setState(() {
      _accountList = acList;
    });
  }
}
