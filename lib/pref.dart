import 'package:shared_preferences/shared_preferences.dart';

const KEY_DEFAULT_ACCOUNT = 'default-account';
const KEY_DEFAULT_TXTYPE = 'default-txtype';
const KEY_DEFAULT_DEBTTYPE = 'default-dbtype';

Future setDefaultAccountId(int aid) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setInt(KEY_DEFAULT_ACCOUNT, aid);
}

Future<int> getDefaultAccountId() async {
  final prefs = await SharedPreferences.getInstance();
  return await prefs.get(KEY_DEFAULT_ACCOUNT);
}

Future setDefaultTxType(String txType) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(KEY_DEFAULT_TXTYPE, txType);
}

Future<String> getDefaultTxType() async {
  final prefs = await SharedPreferences.getInstance();
  return await prefs.get(KEY_DEFAULT_TXTYPE);
}

Future setDefaultDbType(String txType) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(KEY_DEFAULT_DEBTTYPE, txType);
}

Future<String> getDefaultDbType() async {
  final prefs = await SharedPreferences.getInstance();
  return await prefs.get(KEY_DEFAULT_DEBTTYPE);
}
