import 'dart:convert';

import 'package:infwallet/const.dart';
import 'package:infwallet/model/transaction.dart';
import 'package:infwallet/view/overview_page.dart';
import 'package:intl/intl.dart';

String expenseBarChartScript() {
  return '''
  var colors = ['#5793f3', '#d14a61', '#675bba'];
  var yFormatter = function(val){
    return (val / 1000).toFixed(0) + 'K'; 
  }
  var pieTooltipFormatter = function(){
    
  }
    ''';
}

Map<String, double> valsByYearMonth(List<TimeSeriesAmount> dataList) {
  return dataList.map((e) {
    String ym = DateFormat('yyyyMM').format(e.time);
    return {ym: e.value};
  }).reduce((r, e) {
    String k = e.keys.first; // a date with format: yyyyMM
    double v = r[k]; // existing value for this date
    if (v != null) {
      r[k] += e[k];
    } else {
      r[k] = e[k];
    }
    return r;
  });
}

/// for examples, see https://echarts.apache.org/examples/en/
String expenseBarChartOption(List<TimeSeriesAmount> inList,
    List<TimeSeriesAmount> expenseList, List<TimeSeriesAmount> netList) {
  Map<String, double> netMap = valsByYearMonth(netList);
  Map<String, double> inMap = valsByYearMonth(inList);
  Map<String, double> outMap = valsByYearMonth(expenseList);

  List<String> dates = netMap.keys.toList();
  dates.sort((a, b) => a.compareTo(b));
  String xDataStr = jsonEncode(dates);

  List<double> yNetData = dates.map((e) => netMap[e]).toList();
  String yNetDataStr = jsonEncode(yNetData);

  List<double> yInData = dates.map((e) {
    return inMap[e] ?? 0.0;
  }).toList();

  List<double> yOutData = dates.map((e) {
    return outMap[e] ?? 0.0;
  }).toList();

  String yInDataStr = jsonEncode(yInData);
  String yExpenseDataStr = jsonEncode(yOutData);

  // The names must match in order to display legends correctly
  List<String> dataSources = ['Income', 'Expense', 'Net'];
  String dataSourceStr = jsonEncode(dataSources);

  int zoomStart = 80;
  int zoomEnd = 100;
  if (dates.length < 12) {
    zoomStart = 0;
  }

// https://echarts.apache.org/examples/en/editor.html?c=bar-stack
  return '''
{
    tooltip: {
        trigger: 'axis',
        axisPointer: {           
            type: 'shadow'     
        }
    },
    legend: {
        data: $dataSourceStr
    },
    grid: {
        left: '3%',
        right: '4%',
        bottom: '3%',
        containLabel: true
    },
    xAxis: [
        {
            type: 'category',
            data: $xDataStr
        }
    ],
    yAxis: [
        {
            type: 'value',
            axisLabel: {
                formatter: yFormatter
            }
        }
    ],
    series: [
        {
            name: 'Income',
            type: 'bar',
            data: $yInDataStr
        },
        {
            name: 'Expense',
            type: 'bar',
            data: $yExpenseDataStr
        },
        {
            name: 'Net',
            type: 'bar',
            data: $yNetDataStr
        }
    ],
    dataZoom: [{
        start: $zoomStart,
        end: $zoomEnd,
        handleIcon: 'M10.7,11.9v-1.3H9.3v1.3c-4.9,0.3-8.8,4.4-8.8,9.4c0,5,3.9,9.1,8.8,9.4v1.3h1.3v-1.3c4.9-0.3,8.8-4.4,8.8-9.4C19.5,16.3,15.6,12.2,10.7,11.9z M13.3,24.4H6.7V23h6.6V24.4z M13.3,19.6H6.7v-1.4h6.6V19.6z',
        handleSize: '60%',
        handleStyle: {
            color: '#fff',
            shadowBlur: 3,
            shadowColor: 'rgba(0, 0, 0, 0.6)',
            shadowOffsetX: 2,
            shadowOffsetY: 2
        }
    }],
}
''';
}

List<String> expenseTagsInMonth(List<Transaction> thisMonthExpList) {
  if (thisMonthExpList == null || thisMonthExpList.isEmpty) {
    return [];
  }

  // get all tags in this month
  return thisMonthExpList.expand((e) => e.tagList).toSet().toList();
}

List<Transaction> expenseListInMonth(
    int year, int month, List<Transaction> txList) {
  return txList.where((tx) {
    var date = DateTime.fromMillisecondsSinceEpoch(tx.txDate);
    return tx.txType == EXPENSE && date.year == year && date.month == month;
  }).toList();
}

List<Map<String, dynamic>> pieDataInMonth(
    List<Transaction> thisMonthExpList, List<String> allTags) {
  if (thisMonthExpList == null || thisMonthExpList.isEmpty) {
    return [];
  }

  // return a list, eg. [{'value': totalAmount, 'name': tag}, ...]
  var dataList = allTags.map((tag) {
    double sum = thisMonthExpList
        .where((tx) => tx.tagList.contains(tag))
        .map((e) => e.amount)
        .reduce((value, element) => value + element);
    return {'value': sum.roundToDouble(), 'name': tag};
  }).toList();
  dataList.sort((a, b) {
    if ((a['value'] as double) - (b['value'] as double) > 0) {
      return 1;
    }
    return -1;
  });
  return dataList;
}

String pieChartNightingaleOption(
    String title, int year, int month, List<Transaction> txList) {
  var thisMonthExpenseList = expenseListInMonth(year, month, txList);
  var tags = expenseTagsInMonth(thisMonthExpenseList);
  var dataStr = jsonEncode(pieDataInMonth(thisMonthExpenseList, tags));
  var legendStr = jsonEncode(tags);

  return '''
  {
    title: {
        text: '$title',
        left: 'center'
    },
    tooltip: {
        trigger: 'item',
        formatter: '{a} <br/>{b} : {c} ({d}%)'
    },
    legend: {
        left: 'center',
        top: 'bottom',
        data: $legendStr
    },
    toolbox: {
        show: true,
        feature: {
            mark: {show: true},
            dataView: {show: true, readOnly: false},
            magicType: {
                show: true,
                type: ['pie', 'funnel']
            },
            restore: {show: true},
            saveAsImage: {show: false}
        }
    },
    series: [
        {
            name: 'Expense Area',
            type: 'pie',
            radius: [20, 90],
            roseType: 'area',
            data: $dataStr
        }
    ]
}
''';
}

/// https://echarts.apache.org/examples/en/editor.html?c=pie-custom
String pieChartOption(
    String title, int year, int month, List<Transaction> txList) {
  var thisMonthExpenseList = expenseListInMonth(year, month, txList);
  var tags = expenseTagsInMonth(thisMonthExpenseList);
  var dataStr = jsonEncode(pieDataInMonth(thisMonthExpenseList, tags));

  return '''

{
    title: {
        text: '$title',
        left: 'center',
        top: 20,
        bottom: 10,
        textStyle: {
            color: 'black'
        }
    },

    tooltip: {
        trigger: 'item',
        formatter: '{a} <br/>{b} : {c} ({d}%)'
    },

    visualMap: {
        show: false,
        min: 80,
        max: 600,
        inRange: {
            colorLightness: [0, 1]
        }
    },
    series: [
        {
            name: 'Expense',
            type: 'pie',
            radius: '55%',
            center: ['50%', '50%'],
            data: $dataStr,
            roseType: 'radius',
            label: {
                color: 'black',
            },
            labelLine: {
                lineStyle: {
                    color: 'rgba(120, 120, 120, 0.8)'
                },
                smooth: 0.2,
                length: 10,
                length2: 20
            },
            itemStyle: {
                color: 'green',
                shadowBlur: 20,
                shadowColor: 'rgba(0, 0, 0, 0.5)'
            },

            animationType: 'scale',
            animationEasing: 'elasticOut',
            animationDelay: function (idx) {
                return Math.random() * 200;
            }
        }
    ]
}

  ''';
}
