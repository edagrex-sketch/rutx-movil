import 'dart:io';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'daos/cliente_dao.dart';
import 'daos/producto_dao.dart';
import 'daos/venta_dao.dart';
import 'daos/notificacion_dao.dart';
import 'entities/cliente_entity.dart';
import 'entities/producto_entity.dart';
import 'entities/venta_pendiente_entity.dart';
import 'entities/venta_pendiente_entity.dart';
import 'entities/notificacion_entity.dart';
import '../constants/api_constants.dart';

class AppDatabase {
  static final AppDatabase _instance = AppDatabase._();
  factory AppDatabase() => _instance;
  AppDatabase._();

  Database? _database;
  late ClienteDao clienteDao;
  late ProductoDao productDao;
  late VentaDao ventaDao;
  late NotificacionDao notificacionDao;

  static const int _version = 3;
  static const String _dbName = 'rutx_movil.db';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    }
    final dir = await getApplicationDocumentsDirectory();
    final path = join(dir.path, _dbName);

    return await openDatabase(
      path,
      version: _version,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    await db.execute('DROP TABLE IF EXISTS clientes');
    await db.execute('DROP TABLE IF EXISTS productos');
    await db.execute('DROP TABLE IF EXISTS ventas_pendientes');
    await db.execute('DROP TABLE IF EXISTS notificaciones');
    await _onCreate(db, newVersion);
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
        estatus TEXT DEFAULT 'A',
        clave TEXT,
        precio REAL
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
    if (_database != null) return;
    final db = await database;
    clienteDao = ClienteDao(db);
    productDao = ProductoDao(db);
    ventaDao = VentaDao(db);
    notificacionDao = NotificacionDao(db);

    // Auto-seed ONLY if no clients exist (sync will provide real data)
    final clientesCount = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM clientes')) ?? 0;
    if (clientesCount == 0) {
      await seedDatabase();
    }
  }

  Future<void> seedDatabase() async {
    // 1. Clientes
    await clienteDao.insertAll([
      Cliente(clienteId: 2579, nombreCliente: 'Cliente de Prueba Microsip', calle: 'Calle Verdadera 123', colonia: 'Centro', codigoPostal: '37000', limiteCredito: 50000.0),
    ]);

    // 2. Productos
    await productDao.insertAll([
      Producto(articuloId: 312, nombre: 'Artículo de Prueba', estatus: 'A', clave: 'PROD312', precio: 89.50),
    ]);

    // 3. Notificaciones
    await notificacionDao.insertAll([
      Notificacion(mensaje: 'Promoción refrescos hoy|Oficina Central|08:00|Confirmado', leida: true, fechaCreacion: '2026-07-02 08:00:00'),
      Notificacion(mensaje: 'Meta del día actualizada|Gerente de Ventas|09:30|', leida: true, fechaCreacion: '2026-07-02 09:30:00'),
      Notificacion(mensaje: 'Producto sin stock|Almacén|10:15|', leida: false, fechaCreacion: '2026-07-02 10:15:00'),
      Notificacion(mensaje: 'Recordatorio cierre|Oficina Central|14:00|', leida: false, fechaCreacion: '2026-07-02 14:00:00'),
    ]);


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
