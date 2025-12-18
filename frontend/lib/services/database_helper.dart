import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';

part 'database_helper.g.dart';

// Tables
class Patients extends Table {
  TextColumn get id => text()();
  TextColumn get patientUiid => text().nullable()();
  TextColumn get name => text()();
  TextColumn get gender => text()();
  DateTimeColumn get dob => dateTime()();
  TextColumn get phone => text().nullable()();
  TextColumn get address => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))(); // pending, synced
  
  @override
  Set<Column> get primaryKey => {id};
}

class Visits extends Table {
  TextColumn get id => text()();
  TextColumn get patientId => text().references(Patients, #id)();
  TextColumn get doctorId => text()();
  TextColumn get complaint => text().nullable()();
  TextColumn get diagnosis => text().nullable()();
  TextColumn get treatment => text().nullable()();
  RealColumn get billingAmount => real().withDefault(const Constant(0.0))();
  DateTimeColumn get visitDate => dateTime().withDefault(currentDateAndTime)();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();
  
  @override
  Set<Column> get primaryKey => {id};
}

class Bills extends Table {
  TextColumn get id => text()();
  TextColumn get visitId => text().references(Visits, #id)();
  RealColumn get amount => real()();
  TextColumn get status => text().withDefault(const Constant('unpaid'))();
  TextColumn get paymentMethod => text().nullable()();
  TextColumn get syncStatus => text().withDefault(const Constant('pending'))();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Patients, Visits, Bills])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
  
  // CRUD Operations
  Future<List<Patient>> getAllPatients() => select(patients).get();
  Future<int> insertPatient(Patient patient) => into(patients).insert(patient);
  
  // Sync Query
  Future<List<Patient>> getPendingPatients() => (select(patients)..where((tbl) => tbl.syncStatus.equals('pending'))).get();
  Future<void> markPatientSynced(String id) => (update(patients)..where((tbl) => tbl.id.equals(id))).write(const PatientsCompanion(syncStatus: Value('synced')));
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'hms_offline.sqlite'));
    return NativeDatabase(file);
  });
}
