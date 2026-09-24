import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart';

class DBHelper {
  // Singleton Pattern: ताकि पूरे ऐप में डेटाबेस का एक ही कनेक्शन रहे
  static final DBHelper _instance = DBHelper._internal();
  factory DBHelper() => _instance;
  DBHelper._internal();

  static Database? _database;

  // डेटाबेस को कॉल करने का फंक्शन
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  // डेटाबेस को शुरू (Initialize) करना
  Future<Database> _initDB() async {
    // फोन की स्टोरेज में डेटाबेस फाइल का रास्ता बनाना
    String path = join(await getDatabasesPath(), 'mechaniq_obd.db');
    
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  // टेबल बनाना (जब ऐप पहली बार इंस्टॉल होगा)
  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE dtc_codes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        code TEXT,
        description TEXT,
        vehicle_type TEXT
      )
    ''');
    
    debugPrint("SQLite Database and Table created successfully.");
    
    // ऐप इंस्टॉल होते ही कुछ डिफ़ॉल्ट/ऑफलाइन कोड्स डाल देना
    await _insertInitialData(db);
  }

  // शुरुआत में GitHub वाले ओपन-सोर्स कोड्स (डेटा) को यहाँ इंसर्ट करेंगे
  Future<void> _insertInitialData(Database db) async {
    List<Map<String, dynamic>> initialCodes = [
      {'code': 'P0300', 'description': 'Random/Multiple Cylinder Misfire Detected', 'vehicle_type': 'All'},
      {'code': 'P0171', 'description': 'System Too Lean (Bank 1)', 'vehicle_type': 'All'},
      {'code': 'U0100', 'description': 'Lost Communication with ECM/PCM', 'vehicle_type': 'EV'},
      {'code': 'B1000', 'description': 'Airbag ECU Fault', 'vehicle_type': 'Honda'},
      // TODO: GitHub की JSON/CSV फाइलों का पूरा डेटा यहाँ लूप चलाकर सेव करेंगे
    ];

    for (var code in initialCodes) {
      await db.insert('dtc_codes', code);
    }
    debugPrint("Initial DTC codes loaded into offline database.");
  }

  // किसी भी DTC कोड का मतलब (Description) खोजना
  Future<String?> getCodeDescription(String code) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'dtc_codes',
      where: 'code = ?',
      whereArgs: [code],
    );

    if (maps.isNotEmpty) {
      return maps.first['description'] as String;
    }
    return "Unknown Error Code"; // अगर कोड डेटाबेस में न मिले
  }
}
