import 'package:openwallet/const.dart';
import 'package:openwallet/model/account.dart';
import 'package:sqflite/sqflite.dart';

import '../db.dart';
import 'debts.dart';

class Transaction {
  int id;
  String note;
  int aid;
  String txType;
  double amount;
  List<String> tagList;
  int txDate;
  int dbid;
  Transaction({
    this.id = 0,
    this.aid,
    this.amount = 0,
    this.note = '',
    this.tagList,
    this.txType,
    this.txDate,
    this.dbid = 0,
  });

  Transaction.copyFromDebt(Debt debt) {
    this.id = 0;
    this.aid = debt.aid;
    this.amount = debt.amount;
    this.txType = debt.dbType == 'borrow' ? 'income' : 'expense';
    this.txDate = debt.dbDate;
    this.note = 'Transaction for debt ${debt.note}';
    this.dbid = debt.id;
  }

  Transaction.fromMap(Map<String, dynamic> map) {
    String tags = map['tags'] ?? '';

    id = map['id'] ?? 0;
    dbid = map['dbid'] ?? 0;
    note = map['note'];
    aid = map['aid'];
    txType = map['txType'];
    txDate = map['txDate'];
    amount = map['amount'];
    tagList = tags.isEmpty ? [] : tags.split(',');
  }

  Map<String, dynamic> toMap() {
    tagList = tagList ?? [];
    var map = <String, dynamic>{
      'note': note,
      'txType': txType,
      'amount': amount,
      'aid': aid,
      'txDate': txDate,
      'tags': tagList.isEmpty ? '' : tagList.join(',')
    };
    if (id != null) {
      map['id'] = id;
    }
    if (dbid != null) {
      map['dbid'] = dbid;
    }
    return map;
  }
}

enum TransactionType {
  INCOME,
  EXPENSE,
  LEND,
  BORROW,
}

Future<List<Transaction>> getTxs() async {
  Database db = await DBHelper.getDB();
  List<Map<String, dynamic>> results = await db.query(
    'transaction',
    orderBy: 'txDate desc',
  );
  return results.map((result) {
    return Transaction.fromMap(result);
  }).toList();
}

Future<Transaction> getTxById(int id) async {
  Database db = await DBHelper.getDB();

  List resultL =
      await db.query('transaction', where: 'id=?', whereArgs: [id], limit: 1);
  return Transaction.fromMap(resultL.first);
}

Future upsertTx(Transaction tx) async {
  Database db = await DBHelper.getDB();
  Map<String, dynamic> map = tx.toMap();
  double balanceChange = 0;

  if (tx.id > 0) {
    Transaction oldTx = await getTxById(tx.id);
    double oldVal = oldTx.amount * (oldTx.txType == INCOME ? 1 : -1);
    double newVal = tx.amount * (tx.txType == INCOME ? 1 : -1);
    balanceChange = newVal - oldVal;
    await db.update('transaction', map, where: 'id=?', whereArgs: [tx.id]);
  } else {
    map.remove('id');
    await db.insert('transaction', map);
    balanceChange = tx.amount * (tx.txType == INCOME ? 1 : -1);
  }

  await addAccountBalanceById(balanceChange, tx.aid);
}

Future deleteTxById(Transaction tx) async {
  Database db = await DBHelper.getDB();
  await db.delete('transaction', where: 'id=?', whereArgs: [tx.id]);
  double balanceChange = tx.txType == 'expense' ? tx.amount : (0 - tx.amount);
  await addAccountBalanceById(balanceChange, tx.aid);
}

Future<List<Transaction>> getTxsByDebtId(int dbid) async {
  Database db = await DBHelper.getDB();
  List rs = await db.query(
    'transaction',
    where: 'dbid=?',
    whereArgs: [dbid],
  );
  return rs.map((r) {
    return Transaction.fromMap(r);
  }).toList();
}

Future deleteTxByDebtId(int dbid) async {
  List<Transaction> txList = await getTxsByDebtId(dbid);
  for (Transaction tx in txList) {
    await deleteTxById(tx);
  }
}

Future<List<Transaction>> getTxsByAccount(int aid) async {
  Database db = await DBHelper.getDB();
  List<Map<String, dynamic>> results = await db.query(
    'transaction',
    where: 'aid=?',
    whereArgs: [aid],
    orderBy: 'txDate desc',
  );
  return results.map((result) {
    return Transaction.fromMap(result);
  }).toList();
}

Future<Transaction> getOriginTxByDebtId(Debt debt) async {
  Database db = await DBHelper.getDB();
  List rs = await db.query(
    'transaction',
    where: 'dbid=? order by id asc',
    whereArgs: [debt.id],
    limit: 1,
  );

  if (rs.length > 0) {
    Transaction tx = Transaction.fromMap(rs.first);
    if(tx.txDate - debt.dbDate < 10){
      return tx;
    }else{
      return null;
    }
  }
  return null;
}
