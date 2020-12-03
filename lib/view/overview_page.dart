import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:infwallet/const.dart';
import 'package:infwallet/model/account.dart';
import 'package:infwallet/model/transaction.dart';
import 'package:charts_flutter/flutter.dart';

import 'shared.dart';

const String TAG_UNKNOWN = '其它';

class OverviewPage extends StatefulWidget {
  @override
  _OverviewPageState createState() => _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage> {
  // final GlobalKey<AnimatedCircularChartState> _pieChartKey =
  //     new GlobalKey<AnimatedCircularChartState>();

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
    return WillPopScope(
      onWillPop: quitApp,
      child: Scaffold(
        appBar: AppBar(
          title: Text('图表'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: ListView(
              children: <Widget>[
                buildAccountSelector(),
                SizedBox(height: 20),
                Center(child: Text('总支出')),
                Container(
                  child: buildLineChart(),
                  height: 300,
                ),
                SizedBox(
                  height: 20,
                ),
                Center(child: Text('$year.$month月支出分类')),
                GestureDetector(
                  onPanUpdate: (details) {
                    int now = DateTime.now().millisecondsSinceEpoch;
                    if (details.delta.dx > 5) {
                      print("swipe right ${details.delta.dx}");
                      if (now - lastSwipe > 500) {
                        addToMonth(-1);
                      }
                    } else if (details.delta.dx < -5) {
                      print("swipe left ${details.delta.dx}");
                      if (now - lastSwipe > 500) {
                        addToMonth(1);
                      }
                    }
                    lastSwipe = now;
                  },
                  child: Container(
                    child: buildPieChart(),
                    height: 300,
                  ),
                ),
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
  }

  Widget buildLineChart() {
    List<Series<dynamic, String>> dataList = genDataList();

    return BarChart(
      dataList,
      animate: true,
      barGroupingType: BarGroupingType.grouped,
      // border
      defaultRenderer: BarRendererConfig(
        groupingType: BarGroupingType.grouped,
        strokeWidthPx: 2.0,
      ),
      // legend
      behaviors: [
        SeriesLegend(),
      ],
    );
  }

  List<Series<dynamic, String>> genDataList() {
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

    List<Series<TimeSeriesAmount, String>> serList = [];

    if (netList.length > 1) {
      serList.add(Series<TimeSeriesAmount, String>(
        id: '收入',
        domainFn: (TimeSeriesAmount dateVal, _) =>
            '${dateVal.time.year}.${dateVal.time.month}',
        measureFn: (TimeSeriesAmount dateVal, _) => dateVal.value,
        data: incomeList,
        // fillColorFn: (_, __) => MaterialPalette.green.shadeDefault,
      ));
      serList.add(Series<TimeSeriesAmount, String>(
        id: '支出',
        domainFn: (TimeSeriesAmount dateVal, _) =>
            '${dateVal.time.year}.${dateVal.time.month}',
        measureFn: (TimeSeriesAmount dateVal, _) => dateVal.value,
        data: expenseList,
        // fillColorFn: (_, __) => MaterialPalette.red.shadeDefault,
      ));
      serList.add(Series<TimeSeriesAmount, String>(
        id: '总收支',
        domainFn: (TimeSeriesAmount dateVal, _) =>
            '${dateVal.time.year}.${dateVal.time.month}',
        measureFn: (TimeSeriesAmount dateVal, _) => dateVal.value,
        data: netList,
        // fill color
        // fillColorFn: (_, __) => MaterialPalette.white,
      ));
    }
    return serList;
  }

  Widget buildAccountSelector() {
    if (_acList == null || _acList.isEmpty) {
      return Container(
        child: Text('无账户'),
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

  Widget buildPieChart() {
    return PieChart(
      genPieDataFromTXList(),
      animate: true,
      defaultRenderer: ArcRendererConfig(
          arcWidth: 60, arcRendererDecorators: [ArcLabelDecorator()]),
    );
  }

  List<Series<TagAmount, String>> genPieDataFromTXList() {
    if (_txList == null || _txList.isEmpty) {
      return [];
    }

    Map<String, TagAmount> dataByTag = HashMap();

    for (Transaction tx in _txList) {
      if (tx.txType != EXPENSE) {
        continue;
      }
      if (tx.aid != activeAccount.id) {
        continue;
      }

      DateTime dt = DateTime.fromMillisecondsSinceEpoch(tx.txDate);

      if (!isThisMonth(dt)) {
        continue;
      }

      var tagList = tx.tagList;
      if (tagList == null || tagList.isEmpty) {
        attachTx(dataByTag, TAG_UNKNOWN, tx);
      } else {
        for (String tag in tagList) {
          attachTx(dataByTag, tag, tx);
        }
      }
    }

    return [
      Series<TagAmount, String>(
        id: 'Expense By Tag',
        domainFn: (TagAmount ta, _) => '${ta.tag}',
        measureFn: (TagAmount ta, _) => ta.value,
        data: dataByTag.values.toList(),
        labelAccessorFn: (TagAmount ta, _) =>
            '${ta.tag}\n${ta.value.toStringAsFixed(2)}',
      )
    ];
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
    return nYear != null &&
        nMonth != null &&
        nYear >= startYear &&
        nMonth >= startMonth &&
        nYear <= endYear &&
        nMonth <= endMonth;
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
