import 'package:infwallet/const.dart';
import 'package:sqflite/sqflite.dart' hide Transaction;

import '../db.dart';
import 'transaction.dart';

class Debt {
  int id;
  int aid;
  String dbType;
  double amount;
  String note;
  int dbDate;
  List<Transaction> txList;
  Debt({
    this.id = 0,
    this.aid,
    this.amount = 0,
    this.dbDate,
    this.dbType,
    this.note,
    this.txList,
  });

  Debt.fromMap(Map<String, dynamic> map) {
    id = map['id'] ?? 0;
    note = map['note'];
    aid = map['aid'];
    dbType = map['dbType'];
    dbDate = map['dbDate'];
    amount = map['amount'];
  }

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'note': note,
      'dbType': dbType,
      'amount': amount,
      'aid': aid,
      'dbDate': dbDate,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }
}

enum DebtType {
  LEND,
  BORROW,
}

Future<List<Debt>> getDebts() async {
  Database db = await DBHelper.getDB();
  List<Map<String, dynamic>> results = await db.query(
    'debt',
    orderBy: 'dbDate desc',
  );

  List<Debt> dbList = [];
  for (var result in results) {
    Debt debt = Debt.fromMap(result);
    List txs = await getTxsByDebtId(debt.id);
    debt.txList = txs;
    dbList.add(debt);
  }

  return dbList;
}

Future<int> upsertDebt(Debt debt) async {
  Database db = await DBHelper.getDB();
  Map<String, dynamic> map = debt.toMap();
  if (debt.id > 0) {
    Transaction oTx = await getOriginTxByDebtId(debt);
    if(oTx !=null ){
      oTx.amount = debt.amount;
      oTx.txType = debt.dbType == BORROW ? INCOME : EXPENSE;
      await upsertTx(oTx);
    }
    return await db.update('debt', map, where: 'id=?', whereArgs: [debt.id]);
  } else {
    map.remove('id');
    return await db.insert('debt', map);
  }
}

Future deleteDebtById(Debt debt) async {
  Database db = await DBHelper.getDB();
  await db.delete('debt', where: 'id=?', whereArgs: [debt.id]);
  await deleteTxByDebtId(debt.id);
}
