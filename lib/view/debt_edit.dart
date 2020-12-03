import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:infwallet/utils.dart';
import 'package:infwallet/model/account.dart';
import 'package:infwallet/model/transaction.dart';
import 'package:infwallet/view/debt_list.dart';
import '../model/debts.dart';
import '../pref.dart';
import 'account_edit.dart';
import 'shared.dart';

class DebtEditPage extends StatefulWidget {
  final Debt debt;

  DebtEditPage(this.debt);

  @override
  DebtEditState createState() => DebtEditState();
}

class DebtEditState extends State<DebtEditPage> {
  Debt _debt = Debt();
  List<Account> _acList = [];
  final _formKey = GlobalKey<FormState>();
  bool isEdit = true;
  bool _shouldAddTx = true;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  @override
  Widget build(BuildContext context) {
    String title = isEdit ? '编辑借贷' : '新建借贷';
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(title),
        actions: _genActionBtns(context),
      ),
      body: _buildDebtEdit(),
      drawer: genSideDrawer(context),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.save),
        onPressed: _saveAndReturn,
      ),
    );
  }

  Widget _buildDebtEdit() {
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
            leading: Icon(Icons.account_balance_wallet),
            dense: true,
            title: _typeSelect(),
          ),
          ListTile(
            leading: Icon(Icons.account_balance),
            dense: true,
            title: _amountField(),
            trailing: Text('${currencySymbolFromAid(_debt.aid, _acList)}'),
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
          _txChecker(),
        ],
      ),
    );
  }

  void _initData() async {
    var acList = await getAccounts();
    final aid = await getDefaultAccountId();
    final dbType = await getDefaultDbType();

    setState(() {
      _debt = widget.debt;
      _acList = acList;
      _debt.dbDate = _debt.dbDate ?? DateTime.now().millisecondsSinceEpoch;
      isEdit = _debt != null && _debt.id > 0;
      _debt.aid = _debt.aid ?? aid;
      _debt.dbType = _debt.dbType ?? dbType;
    });
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

    final hint = FlutterI18n.translate(context, 'hint_select_account');
    return DropdownButtonFormField<int>(
      hint: Text(hint),
      validator: (val) => (val == null || val < 1) ? hint : null,
      value: _debt.aid,
      onChanged: (val) {
        setState(() {
          _debt.aid = val;
        });
      },
      items: dropdownList,
    );
  }

  Widget _typeSelect() {
    return DropdownButtonFormField(
      hint: Text(FlutterI18n.translate(context, 'lend_or_borrow')),
      validator: (val) => (val == null) ? FlutterI18n.translate(context, 'please_select') : null,
      value: _debt?.dbType ?? null,
      onChanged: (val) {
        setState(() {
          _debt.dbType = val;
        });
      },
      items: [
        DropdownMenuItem(
          child: Text(FlutterI18n.translate(context, 'borrow')),
          value: 'borrow',
        ),
        DropdownMenuItem(
          child: Text(FlutterI18n.translate(context, 'lend')),
          value: 'lend',
        ),
      ],
    );
  }

  Widget _amountField() {
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
      initialValue: '${_debt.amount}',
      onSaved: (val) {
        setState(() {
          _debt.amount = double.parse(val);
        });
      },
    );
  }

  Widget _noteField() {
    return TextFormField(
      validator: (val) => null,
      initialValue: _debt.note,
      decoration: InputDecoration(
        isDense: true,
        labelText: FlutterI18n.translate(context, 'note'),
      ),
      onSaved: (val) {
        setState(() {
          _debt.note = val;
        });
      },
    );
  }

  Widget _dateField() {
    final DateTime initDate = _debt.dbDate == null
        ? DateTime.now()
        : DateTime.fromMillisecondsSinceEpoch(_debt.dbDate);

    final onChanged = (dt) {
      if (dt != null) {
        setState(() {
          _debt.dbDate = dt.millisecondsSinceEpoch;
        });
      }
    };

    return datetimePicker(initDate, onChanged);
  }

  Widget _txChecker() {
    if (isEdit) {
      return SizedBox(
        height: 0,
      );
    }

    return ListTile(
      leading: Icon(Icons.check),
      dense: true,
      title: CheckboxListTile(
        title: Text(FlutterI18n.translate(context, 'ask_also_create_transaction')),
        value: _shouldAddTx,
        onChanged: (val) {
          setState(() {
            _shouldAddTx = val;
          });
        },
      ),
    );
  }

  void _saveAndReturn() async {
    final FormState form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      await upsertDebt(_debt);
      setDefaultDbType(_debt.dbType);

      if (!isEdit && _shouldAddTx) {
        Transaction tx = Transaction.copyFromDebt(_debt);
        await upsertTx(tx);
      }
      // todo when editing debt, associated tx should also be modifed
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DebtListPage(),
          ));
    }
  }

  Future _deleteDebt() async {
    await deleteDebtById(_debt);
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DebtListPage(),
        ));
  }

  dynamic _genActionBtns(context) {
    List<Widget> actions = [];
    if (_debt.id > 0) {
      actions.add(IconButton(
        icon: Icon(Icons.delete),
        onPressed: () => showDeleteDebtDialog(context, _deleteDebt),
      ));
    }
    return actions;
  }
}
