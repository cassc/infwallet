import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:infwallet/utils.dart';
import 'package:infwallet/components/choice_chip.dart';
import 'package:infwallet/const.dart';
import 'package:infwallet/model/account.dart';
import 'package:infwallet/model/tags.dart';
import 'package:infwallet/model/transaction.dart';
import 'package:infwallet/pref.dart';
import 'package:infwallet/view/account_edit.dart';
import 'package:infwallet/view/tag_wrap.dart';
import 'package:infwallet/view/transaction_list.dart';

import 'shared.dart';
import 'tag_select.dart';

class TransactionEditPage extends StatefulWidget {
  final Transaction transaction;
  TransactionEditPage(this.transaction);

  @override
  TransactionEditState createState() => TransactionEditState();
}

class TransactionEditState extends State<TransactionEditPage> {
  Transaction _tx;
  List<Account> _acList = [];
  List<Tag> allTagList = [];

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    setState(() {
      _tx = widget.transaction;
    });
    _initData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String title = _tx.id == 0 ? FlutterI18n.translate(context, 'create_tx') : FlutterI18n.translate(context, 'edit_tx');

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(title),
        actions: _actionButtons(),
      ),
      body: _buildTxEdit(),
      drawer: genSideDrawer(context),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.save),
        onPressed: _saveAndReturn,
      ),
    );
  }

  Widget _buildTxEdit() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: EdgeInsets.all(20),
        children: <Widget>[
          ListTile(
            leading: Icon(Icons.account_balance_wallet),
            dense: true,
            title: _accountSelect(),
          ),
          ListTile(
            leading: Icon(Icons.card_membership),
            dense: true,
            title: _txTypeSelect(),
          ),
          ListTile(
            leading: Icon(Icons.account_balance),
            dense: true,
            title: _amountField(),
            trailing: Text('${currencySymbolFromAid(_tx.aid, _acList)}'),
          ),
          ListTile(
            leading: Icon(Icons.card_membership),
            dense: true,
            title: FlatButton(
              onPressed: () async {
                await Navigator.of(context).push(MaterialPageRoute(
                    builder: (BuildContext context) {
                      return TagSelectPage(_tx.tagList);
                    },
                    fullscreenDialog: true));
                final allTags = await getTags();
                setState(() {
                  allTagList = allTags;
                });
              },
              child: (_tx.tagList == null || _tx.tagList.isEmpty)
              ? Text(FlutterI18n.translate(context, 'select_tag'))
                  : TagWrap(_tx.tagList, allTagList),
            ),
          ),
          ListTile(
            leading: Icon(Icons.note),
            dense: true,
            title: _noteField(),
          ),
          ListTile(
            leading: Icon(Icons.calendar_view_day),
            dense: true,
            title: _dateField(),
          ),
        ],
      ),
    );
  }

  Widget _accountSelect() {
    if (_acList == null || _acList.isEmpty) {
      return RaisedButton(
        onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AccountEditPage(
                account: Account(),
              ),
            )),
        child: Container(
          child: Text(FlutterI18n.translate(context, 'hint_create_account')),
        ),
      );
    }

    List<DropdownMenuItem> dropdownList = _acList.map((ac) {
      return DropdownMenuItem(
        child: Text(ac.title),
        value: ac.id,
      );
    }).toList();

    return DropdownButtonFormField<int>(
      hint: Text(FlutterI18n.translate(context, 'hint_select_account')),
      validator: (val) => (val < 1) ? FlutterI18n.translate(context, 'please_select') : null,
      value: _tx.aid,
      onChanged: (val) {
        setState(() {
          _tx.aid = val;
        });
      },
      items: dropdownList,
    );
  }

  Widget _txTypeSelect() {
    return SingleChoiceHolder([INCOME, EXPENSE], _tx.txType ?? INCOME,
        (choice) {
      setState(() {
        _tx.txType = choice;
      });
    });
  }

  void _saveAndReturn() async {
    final FormState form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      await upsertTx(_tx);
      setDefaultAccountId(_tx.aid);
      setDefaultTxType(_tx.txType);
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TransactionListPage(),
          ));
    }
  }

  List<Widget> _actionButtons() {
    List<Widget> actions = [];

    if (_tx.id > 0) {
      actions.add(IconButton(
        icon: Icon(Icons.delete),
        onPressed: () => showDeleteTxDialog(context, _delTx),
      ));
    }

    return actions;
  }

  void _initData() async {
    var acList = await getAccounts();
    final txType = await getDefaultTxType();
    final aid = await getDefaultAccountId();
    final allTags = await getTags();
    setState(() {
      allTagList = allTags;
      _tx.tagList = _tx.tagList ?? [];
      _acList = acList;
      _tx.txDate = _tx.txDate ?? DateTime.now().millisecondsSinceEpoch;
      _tx.aid = _tx.aid ?? aid;
      _tx.txType = _tx.txType ?? txType;
    });
  }

  Widget _amountField() {
    String initAmount = (_tx.amount == 0) ? '0' : '${_tx.amount}';
    return TextFormField(
      validator: (val) {
        try {
          if (double.parse(val) > 0) {
            return null;
          } else {
            return FlutterI18n.translate(context, 'only_pos_val_allowed');
          }
        } catch (e) {
          return FlutterI18n.translate(context, 'invalid_num');
        }
      },
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        isDense: true,
        labelText: FlutterI18n.translate(context, 'amount'),
      ),
      initialValue: initAmount,
      onSaved: (val) {
        setState(() {
          _tx.amount = double.parse(val);
        });
      },
    );
  }

  Widget _noteField() {
    return TextFormField(
      validator: (val) => null,
      initialValue: _tx.note,
      decoration: InputDecoration(
        isDense: true,
        labelText: FlutterI18n.translate(context, 'note'),
      ),
      onSaved: (val) {
        setState(() {
          _tx.note = val;
        });
      },
    );
  }

  Widget _dateField() {
    final DateTime initDate = _tx.txDate == null
        ? DateTime.now()
        : DateTime.fromMillisecondsSinceEpoch(_tx.txDate);
    final onChanged = (dt) {
      if (dt != null) {
        setState(() {
          _tx.txDate = dt.millisecondsSinceEpoch;
        });
      }
    };

    return datetimePicker(initDate, onChanged);
  }

  void _delTx() async {
    await deleteTxById(_tx);
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TransactionListPage(),
        ));
  }
}
