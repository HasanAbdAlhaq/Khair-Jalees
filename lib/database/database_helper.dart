import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'dart:async';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = new DatabaseHelper.internal();
  factory DatabaseHelper() => _instance;

  static Database _db;

  Future<Database> get db async {
    if (_db != null) {
      return _db;
    }
    _db = await initDb();
    return _db;
  }

  DatabaseHelper.internal();

  initDb() async {
    Directory documentDirectory;
    try {
      documentDirectory = await getApplicationDocumentsDirectory();
    } catch (e) {
      print(e.toString());
    }
    String path = join(documentDirectory.path, "app_database.db");

    // ByteData data = await rootBundle.load(join('assets', 'sqlite.db'));
    // List<int> bytes =
    //     data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

    // // Save copied asset to documents
    // await new File(path).writeAsBytes(bytes);

    var ourDb = await openDatabase(path);
    return ourDb;
  }
}
