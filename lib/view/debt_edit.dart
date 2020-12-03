import 'package:flutter/material.dart';
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
          child: Text('请先创建账户'),
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
      hint: Text('请选择账户'),
      validator: (val) => (val == null || val < 1) ? '请选择账户' : null,
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
      hint: Text('借入还是贷出?'),
      validator: (val) => (val == null) ? '请选择借贷类型' : null,
      value: _debt?.dbType ?? null,
      onChanged: (val) {
        setState(() {
          _debt.dbType = val;
        });
      },
      items: [
        DropdownMenuItem(
          child: Text('借入'),
          value: 'borrow',
        ),
        DropdownMenuItem(
          child: Text('贷出'),
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
            return '请输入正数！';
          }
        } catch (e) {
          return '请输入有效数字！';
        }
      },
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        isDense: true,
        labelText: '金额',
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
        labelText: '备注',
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

    /*  var df = DateTimeField(
      initialValue: initDate,
      validator: (dt) => dt == null ? '请选择日期及时间' : null,
      format: DateFormat('yyyy-MM-dd HH:mm'),
      decoration: InputDecoration(
          labelText: 'Date/Time', hasFloatingPlaceholder: false),
      onShowPicker: null,
      onChanged: (dt) {
        if (dt != null) {
          setState(() {
            _debt.dbDate = dt.millisecondsSinceEpoch;
          });
        }
      },
    ); */
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
        title: Text('自动创建一条关联交易?'),
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
