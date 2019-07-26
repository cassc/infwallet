import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';
import 'package:simple_permissions/simple_permissions.dart';

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
    String path = join(extDir.path, 'openwallet', 'openwallet.db');

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
    await db.execute(
        'alter table `transaction` add dbid int');
  }
}

Future<bool> _requestStoragePermission() async {
  if (!Platform.isAndroid) {
    return false;
  }

  PermissionStatus permissionStatus = await SimplePermissions.requestPermission(
      Permission.WriteExternalStorage);
  if (!(permissionStatus == PermissionStatus.authorized)) {
    print('Request file write permission failed: $permissionStatus');
    return false;
  } else {
    return true;
  }
}

// Future backupOrRestore(String dbpath) async {
//   File backupFile;
//   File dbFile;
//   try {
//     if (!Platform.isAndroid) {
//       // TOOD backup for iOS platform
//       return;
//     }

//     PermissionStatus permissionStatus =
//         await SimplePermissions.requestPermission(
//             Permission.WriteExternalStorage);
//     if (!(permissionStatus == PermissionStatus.authorized)) {
//       print('Request file write permission failed: $permissionStatus');
//       return;
//     }

//     Directory extDir = await getExternalStorageDirectory();
//     String backupPath = '${extDir.path}/openwallet.db';
//     backupFile = File(backupPath);
//     dbFile = File(dbpath);
//     bool dbExist = await dbFile.exists();
//     bool backupExist = await backupFile.exists();

//     if (!dbExist && backupExist) {
//       print('restore db from $backupPath');
//       await backupFile.copy(dbpath);
//       return;
//     }

//     if (!dbExist) {
//       return;
//     }

//     print('backup database to $backupPath');
//     await dbFile.copy(backupPath);
//     print('Backup success: $backupPath');
//   } catch (e) {
//     print('Ignore db backup error: $e');
//   }
// }
