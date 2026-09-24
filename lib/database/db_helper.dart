import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/vehicle.dart';

class DbHelper {
  static final DbHelper instance = DbHelper._init();
  static Database? _database;

  DbHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('mechaniq.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE dtc_codes (
        code TEXT PRIMARY KEY,
        definition TEXT,
        severity TEXT,
        riderExplanation TEXT,
        possibleCauses TEXT,
        recommendedTest TEXT,
        repairCostOem REAL,
        repairCostAftermarket REAL,
        laborCost REAL
      )
    ''');

    await db.execute('''
      CREATE TABLE generic_pids (
        pid TEXT PRIMARY KEY,
        mode TEXT,
        name TEXT,
        min REAL,
        max REAL,
        unit TEXT,
        formula TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE ev_pids (
        pid TEXT PRIMARY KEY,
        mode TEXT,
        name TEXT,
        min REAL,
        max REAL,
        unit TEXT,
        formula TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE k9k_pids (
        pid TEXT PRIMARY KEY,
        mode TEXT,
        name TEXT,
        min REAL,
        max REAL,
        unit TEXT,
        formula TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE honda_init (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        step_name TEXT,
        hex_command TEXT,
        delay_ms INTEGER
      )
    ''');

    // Populate static data to ensure robust offline mode & parse functionality
    await _populateDtcCodes(db);
    await _populateGenericPids(db);
    await _populateEvPids(db);
    await _populateK9kPids(db);
    await _populateHondaInit(db);
  }

  Future _populateDtcCodes(Database db) async {
    final dtcs = [
      {
        'code': 'P0100',
        'definition': 'Mass or Volume Air Flow Circuit Malfunction',
        'severity': 'Medium',
        'riderExplanation': 'Your vehicle might experience rough idling or sudden engine power drop. Safe to ride for short distance to service station.',
        'possibleCauses': 'Damaged MAF sensor, vacuum leak, clogged air filter, oxidized sensor connector.',
        'recommendedTest': 'Verify MAF sensor voltage readings via diagnostic live graphs and inspect engine air ducting for splits.',
        'repairCostOem': 6500.0,
        'repairCostAftermarket': 3200.0,
        'laborCost': 600.0
      },
      {
        'code': 'P0300',
        'definition': 'Random/Multiple Cylinder Misfire Detected',
        'severity': 'Critical',
        'riderExplanation': 'Dangerous misfiring. Catalytic converter damage may occur if run repeatedly. Stop riding immediately.',
        'possibleCauses': 'Worn-out spark plugs, weak ignition coils, clogged fuel injectors, or low compression.',
        'recommendedTest': 'Run ignition spark diagnostic sequence and test fuel rail pressure.',
        'repairCostOem': 4500.0,
        'repairCostAftermarket': 1800.0,
        'laborCost': 850.0
      },
      {
        'code': 'P0A80',
        'definition': 'Replace Hybrid/EV Battery Pack',
        'severity': 'Critical',
        'riderExplanation': 'EV high voltage traction battery cells are highly unbalanced. Drive in safe/limp mode only.',
        'possibleCauses': 'Degraded battery cell module, corroded busbars, failing Battery Management System (BMS).',
        'recommendedTest': 'Perform individual battery cell voltage variance diagnostic using specialized EV scanner logs.',
        'repairCostOem': 180000.0,
        'repairCostAftermarket': 110000.0,
        'laborCost': 15000.0
      }
    ];

    for (var val in dtcs) {
      await db.insert('dtc_codes', val);
    }
  }

  Future _populateGenericPids(Database db) async {
    final pids = [
      {'pid': '0C', 'mode': '01', 'name': 'Engine RPM', 'min': 0.0, 'max': 8000.0, 'unit': 'RPM', 'formula': '((A*256)+B)/4'},
      {'pid': '0D', 'mode': '01', 'name': 'Vehicle Speed', 'min': 0.0, 'max': 255.0, 'unit': 'km/h', 'formula': 'A'},
      {'pid': '05', 'mode': '01', 'name': 'Engine Coolant Temp', 'min': -40.0, 'max': 215.0, 'unit': '°C', 'formula': 'A-40'},
      {'pid': '42', 'mode': '01', 'name': 'Control Module Voltage', 'min': 0.0, 'max': 65.5, 'unit': 'V', 'formula': '((A*256)+B)/1000'}
    ];
    for (var val in pids) {
      await db.insert('generic_pids', val);
    }
  }

  Future _populateEvPids(Database db) async {
    final evPids = [
      {'pid': '01', 'mode': '22', 'name': 'EV Traction Battery State of Charge', 'min': 0.0, 'max': 100.0, 'unit': '%', 'formula': 'A'},
      {'pid': '02', 'mode': '22', 'name': 'EV Battery Temperature', 'min': -40.0, 'max': 120.0, 'unit': '°C', 'formula': 'A-40'},
      {'pid': '03', 'mode': '22', 'name': 'EV Motor RPM', 'min': 0.0, 'max': 15000.0, 'unit': 'RPM', 'formula': '(A*256)+B'}
    ];
    for (var val in evPids) {
      await db.insert('ev_pids', val);
    }
  }

  Future _populateK9kPids(Database db) async {
    final k9k = [
      {'pid': '1102', 'mode': '21', 'name': 'K9K Fuel Rail Pressure', 'min': 0.0, 'max': 1600.0, 'unit': 'bar', 'formula': '((A*256)+B)*10'},
      {'pid': '1105', 'mode': '21', 'name': 'K9K Boost Pressure Reference', 'min': 500.0, 'max': 2500.0, 'unit': 'mbar', 'formula': '(A*256)+B'}
    ];
    for (var val in k9k) {
      await db.insert('k9k_pids', val);
    }
  }

  Future _populateHondaInit(Database db) async {
    final sequences = [
      {'step_name': 'Fast Init Start', 'hex_command': 'AT SP 5', 'delay_ms': 100},
      {'step_name': 'Tester Present', 'hex_command': 'AT AL', 'delay_ms': 50},
      {'step_name': 'Establish Honda Session', 'hex_command': '10 C0', 'delay_ms': 200}
    ];
    for (var val in sequences) {
      await db.insert('honda_init', val);
    }
  }

  Future<DtcRecord?> queryDtc(String code) async {
    final db = await database;
    final maps = await db.query(
      'dtc_codes',
      where: 'code = ?',
      whereArgs: [code],
    );
    if (maps.isNotEmpty) {
      return DtcRecord(
        code: maps.first['code'] as String,
        definition: maps.first['definition'] as String,
        severity: maps.first['severity'] as String,
        riderExplanation: maps.first['riderExplanation'] as String,
        possibleCauses: maps.first['possibleCauses'] as String,
        recommendedTest: maps.first['recommendedTest'] as String,
        repairCostOem: maps.first['repairCostOem'] as double,
        repairCostAftermarket: maps.first['repairCostAftermarket'] as double,
        laborCost: maps.first['laborCost'] as double,
      );
    }
    return null;
  }

  Future<List<PidMetadata>> getPidsForType(String type) async {
    final db = await database;
    final List<Map<String, dynamic>> maps;
    if (type == 'EV') {
      maps = await db.query('ev_pids');
    } else if (type == 'K9K') {
      maps = await db.query('k9k_pids');
    } else {
      maps = await db.query('generic_pids');
    }

    return List.generate(maps.length, (i) {
      return PidMetadata(
        mode: maps[i]['mode'] as String,
        pid: maps[i]['pid'] as String,
        name: maps[i]['name'] as String,
        min: maps[i]['min'] as double,
        max: maps[i]['max'] as double,
        unit: maps[i]['unit'] as String,
        formula: maps[i]['formula'] as String,
      );
    });
  }

  Future<List<Map<String, dynamic>>> getHondaInitSequence() async {
    final db = await database;
    return await db.query('honda_init', orderBy: 'id ASC');
  }
}