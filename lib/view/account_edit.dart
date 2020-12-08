import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:infwallet/const.dart';
import 'package:infwallet/model/account.dart';
import 'package:infwallet/view/account_list.dart';

import 'shared.dart';

class AccountEditPage extends StatefulWidget {
  final Account account;
  AccountEditPage({this.account});
  @override
  AccountEditState createState() => AccountEditState();
}

class AccountEditState extends State<AccountEditPage> {
  Account account = Account();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    setState(() {
      account = widget.account ?? Account();
    });
  }

  @override
  Widget build(BuildContext context) {
    String title = account.id == 0 ? FlutterI18n.translate(context, 'create_account') : FlutterI18n.translate(context, 'edit_account');
    List<Widget> actions = [];
    if (account.id > 0) {
      actions.add(IconButton(
        icon: Icon(Icons.delete),
        onPressed: () => showDeleteAccountDialog(context, _delAccount),
      ));
    }
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(title),
        actions: actions,
      ),
      body: _buildAccountEdit(),
      drawer: genSideDrawer(context),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.save),
        onPressed: _saveAndReturn,
      ),
    );
  }

  Widget _buildAccountEdit() {
    String currency = account.currencySymbol ?? '?';
    return Form(
      key: _formKey,
      child: ListView(
        padding: EdgeInsets.all(20),
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.account_balance),
            dense: true,
            title: TextFormField(
              initialValue: account.title,
              validator: (val) => val.isEmpty ? FlutterI18n.translate(context, 'enter_account_name') : null,
              decoration: InputDecoration(
                isDense: true,
                labelText: FlutterI18n.translate(context, 'account_name'),
              ),
              onSaved: (val) {
                setState(() {
                  account.title = val;
                });
              },
            ),
          ),
          ListTile(
            leading: Icon(Icons.account_balance_wallet),
            dense: true,
            title: _currencySelButton(),
          ),
          ListTile(
            leading: Icon(Icons.account_balance),
            dense: true,
            title: TextFormField(
              initialValue: '${account.balance}',
              validator: (val) {
                try {
                  double.parse(val);
                  return null;
                } catch (e) {
                  return FlutterI18n.translate(context, 'invalid_num');
                }
              },
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                isDense: true,
                labelText: FlutterI18n.translate(context, 'initial_balance'),
              ),
              onSaved: (val) {
                setState(() {
                  account.balance = double.parse(val);
                });
              },
            ),
            trailing: Text(currency),
          ),
        ],
      ),
    );
  }

  Widget _currencySelButton() {
    return DropdownButtonFormField(
      validator: (val) => val == null ? FlutterI18n.translate(context, 'please_select_currency') : null,
      value: account.currencySymbol,
      onChanged: (cr) {
        setState(() {
          account.currencySymbol = cr;
        });
      },
      hint: Text(FlutterI18n.translate(context, 'please_select_currency')),
      items: currenciesList.map((cr) {
        return DropdownMenuItem(
          child: Text(cr),
          value: cr,
        );
      }).toList(),
    );
  }

  void _saveAndReturn() async {
    final FormState form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      if (account.id > 0) {
        await updateAccountById(account);
      } else {
        await addAccount(account);
      }
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AccountListPage(),
          ));
    }
  }

  void _delAccount() async {
    log('deleting account $account');
    await deleteAccountById(account.id);
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AccountListPage(),
        ));
  }
}
