import 'package:infwallet/db.dart';
import 'package:sqflite/sqflite.dart';

class Account {
  int id;
  String currencySymbol;
  double balance;
  String title;
  Account({
    this.id = 0,
    this.currencySymbol,
    this.balance = 0,
    this.title = '',
  });

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'title': title,
      'currencySymbol': currencySymbol,
      'balance': balance,
    };
    if (id != null) {
      map['id'] = id;
    }
    return map;
  }

  Account.fromMap(Map<String, dynamic> map) {
    id = map['id'] ?? 0;
    title = map['title'];
    balance = map['balance'];
    currencySymbol = map['currencySymbol'];
  }
}

Future<int> addAccount(Account account) async {
  Database db = await DBHelper.getDB();
  Map<String, dynamic> map = account.toMap();
  map.remove('id');
  return await db.insert('account', map);
}

Future deleteAccountById(int id) async {
  Database db = await DBHelper.getDB();
  await db.delete('account', where: 'id=?', whereArgs: [id]);
}

Future<int> updateAccountById(Account account) async {
  Database db = await DBHelper.getDB();
  Map<String, dynamic> map = account.toMap();
  map.remove('id');
  return await db.update(
    'account',
    map,
    where: 'id=?',
    whereArgs: [account.id],
  );
}

Future<List<Account>> getAccounts() async {
  Database db = await DBHelper.getDB();
  List<Map<String, dynamic>> results = await db.query('account');
  return results.map((result) {
    return Account.fromMap(result);
  }).toList();
}

Future addAccountBalanceById(double amount, int id) async {
  Database db = await DBHelper.getDB();

  await db.execute(
      'update account set balance = balance+? where id=?', [amount, id]);
}
