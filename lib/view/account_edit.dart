import 'package:flutter/material.dart';
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
    String title = account.id == 0 ? '新建账户' : '编辑账户';
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
              validator: (val) => val.isEmpty ? "请输入账户名称" : null,
              decoration: InputDecoration(
                isDense: true,
                labelText: '账户名称',
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
                  return '请输入有效数字';
                }
              },
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                isDense: true,
                labelText: '初始余额',
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
      validator: (val) => val == null ? '请选择币种' : null,
      value: account.currencySymbol,
      onChanged: (cr) {
        setState(() {
          account.currencySymbol = cr;
        });
      },
      hint: Text('请选择此账户的币种'),
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
    print('deleting account $account');
    await deleteAccountById(account.id);
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => AccountListPage(),
        ));
  }
}
