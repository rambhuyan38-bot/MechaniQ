import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class PidProfile {
  final int? id;
  final String mode;
  final String pid;
  final String description;
  final String formula;
  final double minValue;
  final double maxValue;
  final String unit;
  final String type; // 'SAEJ1979', 'EV', 'K9K'

  PidProfile({
    this.id,
    required this.mode,
    required this.pid,
    required this.description,
    required this.formula,
    required this.minValue,
    required this.maxValue,
    required this.unit,
    required this.type,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'mode': mode,
      'pid': pid,
      'description': description,
      'formula': formula,
      'min_value': minValue,
      'max_value': maxValue,
      'unit': unit,
      'type': type,
    };
  }

  factory PidProfile.fromMap(Map<String, dynamic> map) {
    return PidProfile(
      id: map['id'] as int?,
      mode: map['mode'] as String,
      pid: map['pid'] as String,
      description: map['description'] as String,
      formula: map['formula'] as String,
      minValue: (map['min_value'] as num).toDouble(),
      maxValue: (map['max_value'] as num).toDouble(),
      unit: map['unit'] as String,
      type: map['type'] as String,
    );
  }
}

class DbHelper {
  static final DbHelper instance = DbHelper._privateConstructor();
  static Database? _database;

  DbHelper._privateConstructor();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'mechaniq_profiles.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE pids (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        mode TEXT NOT NULL,
        pid TEXT NOT NULL,
        description TEXT NOT NULL,
        formula TEXT NOT NULL,
        min_value REAL NOT NULL,
        max_value REAL NOT NULL,
        unit TEXT NOT NULL,
        type TEXT NOT NULL
      )
    ''');

    await _insertDefaultProfiles(db);
  }

  Future<void> _insertDefaultProfiles(Database db) async {
    final List<PidProfile> defaults = [
      // SAEJ1979 Default PIDs
      PidProfile(
        mode: '01',
        pid: '0C',
        description: 'Engine RPM',
        formula: '((A*256)+B)/4',
        minValue: 0.0,
        maxValue: 8000.0,
        unit: 'rpm',
        type: 'SAEJ1979',
      ),
      PidProfile(
        mode: '01',
        pid: '0D',
        description: 'Vehicle Speed',
        formula: 'A',
        minValue: 0.0,
        maxValue: 255.0,
        unit: 'km/h',
        type: 'SAEJ1979',
      ),
      PidProfile(
        mode: '01',
        pid: '05',
        description: 'Engine Coolant Temperature',
        formula: 'A-40',
        minValue: -40.0,
        maxValue: 215.0,
        unit: '°C',
        type: 'SAEJ1979',
      ),
      // EV Custom PIDs
      PidProfile(
        mode: '21',
        pid: '01',
        description: 'EV Battery State of Charge',
        formula: 'A/2',
        minValue: 0.0,
        maxValue: 100.0,
        unit: '%',
        type: 'EV',
      ),
      PidProfile(
        mode: '21',
        pid: '02',
        description: 'EV Battery Temperature',
        formula: 'A-40',
        minValue: -40.0,
        maxValue: 120.0,
        unit: '°C',
        type: 'EV',
      ),
      // K9K (Renault/Datsun/Nissan Diesel Engine) Custom PIDs
      PidProfile(
        mode: '22',
        pid: '1105',
        description: 'K9K Common Rail Fuel Pressure',
        formula: '((A*256)+B)*10',
        minValue: 0.0,
        maxValue: 1600.0,
        unit: 'bar',
        type: 'K9K',
      ),
      PidProfile(
        mode: '22',
        pid: '11A3',
        description: 'K9K Turbo Boost Pressure',
        formula: '((A*256)+B)/100',
        minValue: 0.0,
        maxValue: 3.0,
        unit: 'bar',
        type: 'K9K',
      ),
    ];

    for (var item in defaults) {
      await db.insert('pids', item.toMap());
    }
  }

  Future<List<PidProfile>> getPidsByType(String type) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'pids',
      where: 'type = ?',
      whereArgs: [type],
    );

    return List.generate(maps.length, (i) {
      return PidProfile.fromMap(maps[i]);
    });
  }

  Future<int> insertCustomPid(PidProfile pid) async {
    final db = await database;
    return await db.insert('pids', pid.toMap());
  }

  Future<int> deletePid(int id) async {
    final db = await database;
    return await db.delete(
      'pids',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}