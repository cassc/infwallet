import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:infwallet/model/account.dart';
import 'package:infwallet/model/tags.dart';
import 'package:infwallet/model/transaction.dart';
import 'package:devicelocale/devicelocale.dart';
import 'shared.dart';
import 'transaction_details.dart';
import 'transaction_edit.dart';

class TransactionListPage extends StatefulWidget {
  @override
  TransactionListPageState createState() => TransactionListPageState();
}

class TransactionListPageState extends State<TransactionListPage> {
  List<Transaction> _txList = [];
  List<Account> _accountList = [];
  List<Tag> _tagList = [];
  int activeAid;

  @override
  void initState() {
    super.initState();
    _initLang();
    _initData();
  }

  void _initLang() async {
    String oslang = await Devicelocale.currentLocale;
    print('get locale: ' + oslang);
    if (oslang.toLowerCase().contains('zh')) {
      oslang = 'zh';
    } else {
      oslang = 'en';
    }

    await FlutterI18n.refresh(context, Locale(oslang));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: quitApp,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            '交易记录',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          actions: txActions(),
        ),
        body: _buildTransactionList(),
        drawer: genSideDrawer(context),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TransactionEditPage(Transaction()),
                ));
          },
        ),
      ),
    );
  }

  Widget _buildTransactionList() {
    if (_txList.length == 0) {
      return Container();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8.0),
      itemCount: _txList.length,
      itemBuilder: (BuildContext context, int index) {
        Transaction tx = _txList[index];
        String circleChar = _txCircleChar(tx);
        Color circleColor = _txCircleColor(tx);
        String dateString = DateTime.fromMillisecondsSinceEpoch(tx.txDate)
            .toString()
            .substring(0, 16);
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: circleColor,
            child: Text(circleChar),
          ),
          title: Text(dateString), //
          trailing: Text(
            '${tx.amount} ${currencySymbolFromAid(tx.aid, _accountList)}',
            style: TextStyle(
                color: tx.txType == 'income' ? Colors.green : Colors.red),
          ),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(
              builder: (context) {
                Account account =
                    _accountList.firstWhere((ac) => ac.id == tx.aid);
                return TransactionDetailsPage(tx, account, _tagList);
              },
            ));
          },
        );
      },
    );
  }

  Future _initData() async {
    await initTags();

    var acList = await getAccounts();
    var tagList = await getTags();
    setState(() {
      _accountList = acList;
      _tagList = tagList;
    });
    await _initTxList();
  }

  Future _initTxList() async {
    var txList = await getTxs();
    setState(() {
      if (activeAid != null && activeAid > 0) {
        _txList = txList.where((tx) {
          return tx.aid == activeAid;
        }).toList();
      } else {
        _txList = txList;
      }
    });
  }

  String _txCircleChar(Transaction tx) {
    String c = '';
    if (tx.note == null || tx.note.isEmpty) {
      if (tx.tagList != null && tx.tagList.length > 0) {
        return tx.tagList.first.substring(0, 1);
      }
    } else {
      return tx.note.substring(0, 1);
    }

    return c;
  }

  Color _txCircleColor(Transaction tx) {
    Color color = Colors.blue;
    if (tx.tagList != null && tx.tagList.length > 0) {
      String tagS = tx.tagList.first;
      Tag tag = _tagList.firstWhere((tag) {
        return tag.title == tagS;
      }, orElse: () {
        return null;
      });
      return tag == null ? color : tag.color;
    }
    return color;
  }

  List<Widget> txActions() {
    return [
      Padding(
        padding: EdgeInsets.only(top: 6),
        child: Theme(
          data: Theme.of(context).copyWith(canvasColor: Colors.blue),
          child: DropdownButton(
            hint: Text('请选择', style: TextStyle(color: Colors.white)),
            style: TextStyle(color: Colors.white),
            icon: Icon(
              Icons.local_bar,
              color: Colors.white,
            ),
            value: activeAid,
            onChanged: (val) {
              activeAid = val;
              _initTxList();
            },
            items: _accountList.map((ac) {
              return DropdownMenuItem(
                child: Text(ac.title),
                value: ac.id,
              );
            }).toList(),
          ),
        ),
      )
    ];
  }
}
