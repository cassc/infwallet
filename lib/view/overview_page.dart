import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_echarts/flutter_echarts.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:infwallet/components/charts.dart';
import 'package:infwallet/const.dart';
import 'package:infwallet/model/account.dart';
import 'package:infwallet/model/transaction.dart';

import 'shared.dart';

const String TAG_UNKNOWN = 'NA';

class OverviewPage extends StatefulWidget {
  @override
  _OverviewPageState createState() => _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage> {
  // final GlobalKey<AnimatedCircularChartState> _pieChartKey =
  //     new GlobalKey<AnimatedCircularChartState>();

  List<TimeSeriesAmount> _expenseList = [];
  List<TimeSeriesAmount> _incomeList = [];
  List<TimeSeriesAmount> _netList = [];

  List<Transaction> _txList = [];
  List<Account> _acList = [];
  Account activeAccount;
  // year month for pie chart display
  int year;
  int month;

  int startYear;
  int endYear;
  int startMonth;
  int endMonth;
  int lastSwipe = 0;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  @override
  Widget build(BuildContext context) {
    String monthExpenseTitle = FlutterI18n.translate(context, 'month_expense',
        translationParams: {
          'year': year.toString(),
          'month': month.toString()
        });
    return WillPopScope(
      onWillPop: quitApp,
      child: Scaffold(
        appBar: AppBar(
          title: Text(FlutterI18n.translate(context, 'chart')),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: ListView(
              children: <Widget>[
                buildAccountSelector(),
                SizedBox(height: 20),
                GestureDetector(
                  onPanUpdate: (details) {
                    int now = DateTime.now().millisecondsSinceEpoch;
                    if (details.delta.dx > 5) {
                      log("swipe right ${details.delta.dx}");
                      if (now - lastSwipe > 500) {
                        addToMonth(-1);
                      }
                    } else if (details.delta.dx < -5) {
                      log("swipe left ${details.delta.dx}");
                      if (now - lastSwipe > 500) {
                        addToMonth(1);
                      }
                    }
                    lastSwipe = now;
                  },
                  child: buildPieChart(monthExpenseTitle),
                ),
                SizedBox(
                  height: 20,
                ),
                Center(
                    child: Text(FlutterI18n.translate(context, 'txsummary'))),
                buildBarChart(),
                SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        ),
        drawer: genSideDrawer(context),
      ),
    );
  }

  void _initData() async {
    var txList = await getTxs();
    var acList = await getAccounts();

    if (acList.isEmpty || txList.isEmpty) {
      return;
    }

    DateTime end = DateTime.fromMillisecondsSinceEpoch(txList.first.txDate);
    DateTime start = DateTime.fromMillisecondsSinceEpoch(txList.last.txDate);

    setState(() {
      _txList = txList;
      _acList = acList;
      activeAccount = _acList.first;
      startYear = start.year;
      startMonth = start.month;
      endYear = end.year;
      endMonth = end.month;
      year = endYear;
      month = endMonth;
    });

    _genDataList();
  }

  Widget buildBarChart() {
    log('building bar chart');
    if (_netList.isEmpty) {
      return Center(
        child: Text('No data'),
      );
    }

    final optionStr =
        expenseBarChartOption(_incomeList, _expenseList, _netList);
    // log('barChartOption: $optionStr');

    return Container(
      width: 360,
      height: 240,
      child: Echarts(
        extraScript: expenseBarChartScript(),
        option: optionStr,
      ),
    );
  }

  void _genDataList() {
    List<TimeSeriesAmount> netList = [];
    List<TimeSeriesAmount> incomeList = [];
    List<TimeSeriesAmount> expenseList = [];
    for (Transaction tx in _txList.reversed) {
      if (tx.aid != activeAccount.id) {
        continue;
      }
      DateTime dt = DateTime.fromMillisecondsSinceEpoch(tx.txDate);
      int month = dt.month;
      int year = dt.year;
      dt = DateTime(year, month, 1);
      bool isIncome = tx.txType == INCOME;
      double value = tx.amount;
      double amount = isIncome ? tx.amount : (0 - tx.amount);

      if (netList.isEmpty || netList.last.time != dt) {
        netList.add(TimeSeriesAmount(dt, amount));
      } else {
        netList.last.value += amount;
      }

      if (isIncome) {
        if (incomeList.isEmpty || incomeList.last.time != dt) {
          incomeList.add(TimeSeriesAmount(dt, value));
        } else {
          incomeList.last.value += value;
        }
        if (expenseList.isEmpty || expenseList.last.time != dt) {
          expenseList.add(TimeSeriesAmount(dt, 0));
        }
      } else {
        if (incomeList.isEmpty || incomeList.last.time != dt) {
          incomeList.add(TimeSeriesAmount(dt, 0));
        }
        if (expenseList.isEmpty || expenseList.last.time != dt) {
          expenseList.add(TimeSeriesAmount(dt, value));
        } else {
          expenseList.last.value += value;
        }
      }
    }

    log('found ${netList.length} tx entries');

    setState(() {
      _expenseList = expenseList;
      _incomeList = incomeList;
      _netList = netList;
    });
  }

  Widget buildAccountSelector() {
    if (_acList == null || _acList.isEmpty) {
      return Container(
        child: Text(FlutterI18n.translate(context, 'no_account_exists')),
      );
    }
    return DropdownButton(
      icon: Icon(Icons.account_balance_wallet),
      elevation: 12,
      isExpanded: true,
      value: activeAccount?.id,
      onChanged: (aid) {
        setState(() {
          activeAccount = _acList.firstWhere((ac) => ac.id == aid);
          _genDataList();
        });
      },
      items: _acList.map((ac) {
        return DropdownMenuItem(
          child: Text(
            ac.title,
          ),
          value: ac.id,
        );
      }).toList(),
    );
  }

  Widget buildPieChart(String title) {
    List<Transaction> txs = [..._txList];
    if (activeAccount != null) {
      txs = txs.where((tx) => tx.aid == activeAccount.id).toList();
    }

    if (txs.isEmpty) {
      return Container();
    }
    String optionStr = pieChartNightingaleOption(title, year, month, txs);

    return Container(
      width: 480,
      height: 420,
      alignment: AlignmentDirectional.topCenter,
      child: Echarts(
        extraScript: expenseBarChartScript(),
        option: optionStr,
      ),
    );
  }

  void attachTx(Map<String, TagAmount> tagData, String tag, Transaction tx) {
    // double val = tx.txType == INCOME ? tx.amount : -tx.amount;
    double val = tx.amount;
    if (tagData.containsKey(tag)) {
      TagAmount old = tagData[tag];
      tagData[tag] = TagAmount(tag, old.value + val);
    } else {
      tagData[tag] = TagAmount(tag, val);
    }
  }

  void addToMonth(int i) {
    int nMonth = month + i;
    int nYear = year;
    if (nMonth > 12) {
      nMonth = 1;
      nYear++;
    } else if (nMonth < 1) {
      nMonth = 12;
      nYear--;
    }

    if (yearInRange(nYear, nMonth)) {
      setState(() {
        year = nYear;
        month = nMonth;
      });
    }
  }

  bool yearInRange(int nYear, int nMonth) {
    if (nYear == null || nMonth == null) {
      return false;
    }
    var months = nYear * 12 + nMonth;
    var start = startYear * 12 + startMonth;
    var end = endYear * 12 + endMonth;
    return months <= end && months >= start;
  }

  bool isThisMonth(DateTime dt) {
    return dt.year == year && dt.month == month;
  }
}

class TimeSeriesAmount {
  DateTime time;
  double value;

  TimeSeriesAmount(this.time, this.value);
}

class TagAmount {
  String tag;
  double value;
  TagAmount(this.tag, this.value);
}
