import 'package:hello_world/models/dog.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DBHelper {
  static Database _db;
  static const String ID = 'id';
  static const String NAME = 'name';
  static const String AGE = 'age';
  static const String TABLE = 'Dog';
  static const String DB_NAME = 'dog.db';

  Future<Database> get db async {
    if (_db != null) {
      return _db;
    }

    _db = await initDb();
    return _db;
  }

  initDb() async {
    var databasesPath = await getDatabasesPath();
    String path = join(databasesPath, DB_NAME);
    var db = await openDatabase(path, version: 1, onCreate: _onCreate);
    return db;
  }

  _onCreate(Database db, int version) async {
    await db.execute(
        "CREATE TABLE $TABLE($ID INTEGER PRIMARY KEY, $NAME TEXT, $AGE INTEGER)");
  }

  ///Funtion to add/save
  Future<Dog> save(Dog dog) async {
    var dbClient = await db;
    dog.id = await dbClient.insert(TABLE, dog.toMap());
    return dog;
  }

  ///Funtion to get dogs
  Future<List<Dog>> getDogs() async {
    var dbClient = await db;
    List<Map> maps = await dbClient.query(TABLE, columns: [ID, NAME, AGE]);
    List<Dog> dogs = [];
    if (maps.length > 0) {
      for (int i = 0; i < maps.length; i++) {
        dogs.add(Dog.fromMap(maps[i]));
      }
    }
    return dogs;
  }

  ///Funtion to delete
  Future<int> delete(int id) async {
    var dbClient = await db;
    return await dbClient.delete(TABLE, where: '$ID = ?', whereArgs: [id]);
  }

  ///Funtion to update
  Future<int> update(Dog dog) async {
    var dbClient = await db;
    return await dbClient
        .update(TABLE, dog.toMap(), where: '$ID = ?', whereArgs: [dog.id]);
  }

  ///Funtion to close database
  Future close() async {
    var dbClient = await db;
    dbClient.close();
  }
}
