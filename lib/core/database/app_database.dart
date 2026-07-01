import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'daos/cliente_dao.dart';
import 'daos/producto_dao.dart';
import 'daos/venta_dao.dart';
import 'daos/notificacion_dao.dart';

class AppDatabase {
  static final AppDatabase _instance = AppDatabase._();
  factory AppDatabase() => _instance;
  AppDatabase._();

  Database? _database;
  late final ClienteDao clienteDao;
  late final ProductoDao productDao;
  late final VentaDao ventaDao;
  late final NotificacionDao notificacionDao;

  static const int _version = 1;
  static const String _dbName = 'rutx_movil.db';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = join(dir.path, _dbName);

    return await openDatabase(
      path,
      version: _version,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE clientes (
        cliente_id INTEGER PRIMARY KEY,
        nombre_cliente TEXT NOT NULL,
        calle TEXT,
        colonia TEXT,
        codigo_postal TEXT,
        limite_credito REAL DEFAULT 0.0
      )
    ''');

    await db.execute('''
      CREATE TABLE productos (
        articulo_id INTEGER PRIMARY KEY,
        nombre TEXT NOT NULL,
        estatus TEXT DEFAULT 'A'
      )
    ''');

    await db.execute('''
      CREATE TABLE ventas_pendientes (
        venta_movil_id TEXT PRIMARY KEY,
        vendedor_id INTEGER NOT NULL,
        cliente_id INTEGER NOT NULL,
        cliente_nombre TEXT NOT NULL,
        fecha_hora TEXT NOT NULL,
        estado TEXT DEFAULT 'pendiente',
        total REAL DEFAULT 0.0,
        detalles_json TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE notificaciones (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        mensaje TEXT NOT NULL,
        leida INTEGER DEFAULT 0,
        fecha_creacion TEXT NOT NULL
      )
    ''');
  }

  Future<void> initialize() async {
    final db = await database;
    clienteDao = ClienteDao(db);
    productDao = ProductoDao(db);
    ventaDao = VentaDao(db);
    notificacionDao = NotificacionDao(db);
  }

  Future<void> limpiarDatosDelDia() async {
    await clienteDao.deleteAll();
    await productDao.deleteAll();
    await ventaDao.deleteAll();
    await notificacionDao.deleteAll();
  }

  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }
}
