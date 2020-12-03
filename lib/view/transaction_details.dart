import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:infwallet/model/account.dart';
import 'package:infwallet/model/tags.dart';
import 'package:infwallet/model/transaction.dart';
import 'package:infwallet/view/shared.dart';
import 'package:infwallet/view/tag_wrap.dart';
import 'package:infwallet/view/transaction_edit.dart';
import 'package:infwallet/view/transaction_list.dart';

class TransactionDetailsPage extends StatelessWidget {
  final Transaction tx;
  final Account account;
  final List<Tag> allTagList;

  TransactionDetailsPage(this.tx, this.account, this.allTagList);

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
          title: Text(FlutterI18n.translate(context, 'tx_details')),
          actions: [
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return TransactionEditPage(tx);
                }));
              },
            ),
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                showDeleteTxDialog(context, _makeDelCallback(context));
              },
            ),
          ],
        ),
        body: _buildTranssactionDetails(context),
        drawer: genSideDrawer(context),
      ),
    );
  }

  Widget _buildTranssactionDetails(ctx) {
    return ListView(
      padding: EdgeInsets.all(20),
      children: <Widget>[
        _txAmountRow(ctx),
        _txTagRow(ctx),
        _txAccountRow(ctx),
        _txDateRow(ctx),
        _txNoteRow(ctx),
      ],
    );
  }

  Widget _txAmountRow(context) {
    String sign = tx.txType == 'income' ? '+' : '-';
    String amountStr = "$sign ${tx.amount} ${account.currencySymbol}";
    return Card(
      elevation: 16,
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              FlutterI18n.translate(context, 'amount'),
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

  Widget _txNoteRow(context) {
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
              '${tx.note}',
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

  Widget _txDateRow(context) {
    String date = DateTime.fromMillisecondsSinceEpoch(tx.txDate)
        .toString()
        .substring(0, 16);
    return Card(
      elevation: 16,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              FlutterI18n.translate(context, 'tx_time'),
              textAlign: TextAlign.left,
            ),
            SizedBox(
              height: 8,
            ),
            Text(
              '$date',
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

  Widget _txAccountRow(context) {
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

  Widget _txTagRow(context) {
    return Card(
      elevation: 16,
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                FlutterI18n.translate(context, 'tag'),
                textAlign: TextAlign.left,
              ),
              SizedBox(
                height: 8,
              ),
              TagWrap(tx.tagList, allTagList),
            ],
          ),
        ),
      ),
    );
  }

  dynamic _makeDelCallback(context) {
    return () async {
      await deleteTxById(tx);
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TransactionListPage(),
          ));
    };
  }
}
