import 'dart:developer';
import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:simple_permissions/simple_permissions.dart';
import 'package:permission_handler/permission_handler.dart';

class DBHelper {
  static Database db;
  static Future<Database> getDB() async {
    if (db != null) {
      return db;
    }

    bool allowStore = await _requestStoragePermission();

    if (!allowStore) {
      throw Exception('Storage permission request failed!');
    }
    // var databasesPath = await getDatabasesPath();
    Directory extDir = await getExternalStorageDirectory();
    String root = join(extDir.path, 'infwallet');
    String path = join(root, 'infwallet.db');

    backupDb(root, 'infwallet.db');

    db = await openDatabase(
      path,
      version: 5,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
    return db;
  }

  static Future close() async => db?.close();

  static _onCreate(Database db, int newVersion) async {
    await db.execute(
        'CREATE TABLE account(id INTEGER PRIMARY KEY, title TEXT, currencySymbol text, balance double)');
    await db.execute(
        'CREATE TABLE `transaction` (id INTEGER PRIMARY KEY, aid int, dbid int, amount double, note text, tags text, txDate int, txType text)');
    await db.execute(
        'CREATE TABLE debt(id INTEGER PRIMARY KEY, aid int,  dbType TEXT,  amount double, note text, dbDate datetime)');
    await db.execute(
        'CREATE TABLE tag(id INTEGER PRIMARY KEY, title TEXT, color Text)');
  }

  static _onUpgrade(Database db, int oldVer, int newVer) async {
    await db.execute('alter table `transaction` add dbid int');
  }
}

void backupDb(String root, String dbfile) {
  final file = File(join(root, dbfile));
  final today = DateTime.now();
  final backupName = '${today.year}_${today.month}_${today.day}_$dbfile';
  final backupPath = join(root, 'backup', backupName);
  final backup = File(backupPath);
  if (file.existsSync() && !backup.existsSync()) {
    backup.parent.createSync(recursive: true);
    file.copySync(backupPath);
    print('backup to $backupPath success');
  }
}

Future<bool> _requestStoragePermission() async {
  bool status = await Permission.storage.isGranted;
  if (status){
    return status;
  }

  if (await Permission.storage.isRestricted) {
    log('Permission is restricted!');
    return false;
  }

  return await Permission.storage.request().isGranted;

}
