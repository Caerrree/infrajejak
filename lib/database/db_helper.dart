import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/hazard.dart';

/// Local SQLite database.
/// Purpose: store the *static/prepared* government dataset (JKR blackspots)
/// so it can be queried quickly offline, without re-fetching it from the
/// bundled asset every time. Dynamic community data lives in Firestore
/// instead — see [FirestoreService]. This mirrors the SQLite vs Firebase
/// split described in Section 20 of the project brief.

class DbHelper {
  DbHelper._internal();
  static final DbHelper instance = DbHelper._internal();

  Database? _db;

  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'infra_jejak.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE jkr_blackspots (
            blackspotId TEXT PRIMARY KEY,
            roadName TEXT NOT NULL,
            latitude REAL NOT NULL,
            longitude REAL NOT NULL,
            state TEXT,
            district TEXT,
            classification TEXT
          )
        ''');
      },
    );
  }

  /// Loads the bundled, pre-cleaned JKR dataset (assets/data/jkr_blackspots.json)
  /// into SQLite the first time the app runs. This is the "Store locally"
  /// step at the end of the data preparation pipeline (Section 17).

  Future<void> seedJkrDataIfEmpty() async {
    final db = await database;
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM jkr_blackspots'),
    );
    if (count != null && count > 0) return;

    final raw = await rootBundle.loadString('assets/data/jkr_blackspots.json');
    final Map<String, dynamic> json = jsonDecode(raw);
    final List records = json['records'] as List;

    final batch = db.batch();
    for (final r in records) {
      batch.insert(
        'jkr_blackspots',
        {
          'blackspotId': r['blackspotId'],
          'roadName': r['roadName'],
          'latitude': r['latitude'],
          'longitude': r['longitude'],
          'state': r['state'],
          'district': r['district'],
          'classification': r['classification'],
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  Future<List<Hazard>> getAllBlackspots() async {
    final db = await database;
    final rows = await db.query('jkr_blackspots');
    return rows.map((row) => Hazard.fromJkrJson(row)).toList();
  }
}
