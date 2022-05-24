import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart' as sql;

class SQLHelper {
  Future<String> getLocalPath() async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  static Future<sql.Database> db() async {
    return sql.openDatabase(
      //"/data/user/0/com.example.compromised_password/files/haveibeenpawnedsmall.sqlite",
      //"/sdcard/Download/haveibeenpawnedsmall.sqlite",
      "/storage/745F-D902/Download/haveibeenpawned.sqlite",
      version: 1,
    );
  }

  static Future<List<Map<String, dynamic>>> getPwnedPassword(
      String hash) async {
    final db = await SQLHelper.db();
    return db.query('passwords',
        where: "hash = ?", whereArgs: [hash], limit: 1);
  }
}
