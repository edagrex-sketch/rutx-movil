import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'daos/cliente_dao.dart';
import 'daos/producto_dao.dart';
import 'daos/venta_dao.dart';
import 'daos/notificacion_dao.dart';
import 'entities/cliente_entity.dart';
import 'entities/producto_entity.dart';
import 'entities/venta_pendiente_entity.dart';
import 'entities/notificacion_entity.dart';

class AppDatabase {
  static final AppDatabase _instance = AppDatabase._();
  factory AppDatabase() => _instance;
  AppDatabase._();

  Database? _database;
  late ClienteDao clienteDao;
  late ProductoDao productDao;
  late VentaDao ventaDao;
  late NotificacionDao notificacionDao;

  static const int _version = 2;
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

    // Auto-seed if empty
    final countVal = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM clientes')) ?? 0;
    if (countVal == 0) {
      await seedDatabase();
    }
  }

  Future<void> seedDatabase() async {
    // 1. Clientes
    await clienteDao.insertAll([
      Cliente(clienteId: 1, nombreCliente: 'Abarrotes Mendoza', calle: 'Calle Juárez 45', colonia: 'Centro', codigoPostal: '37000', limiteCredito: 5000.0),
      Cliente(clienteId: 2, nombreCliente: 'Minisuper El Roble', calle: 'Av. Hidalgo 120', colonia: 'San Rafael', codigoPostal: '37120', limiteCredito: 8000.0),
      Cliente(clienteId: 3, nombreCliente: 'Tienda Don Pepe', calle: 'Calle Morelos 8', colonia: 'Centro', codigoPostal: '37000', limiteCredito: 4000.0),
      Cliente(clienteId: 4, nombreCliente: 'Comercial Reyes', calle: 'Blvd. Norte 230', colonia: 'Norte', codigoPostal: '37500', limiteCredito: 15000.0),
      Cliente(clienteId: 5, nombreCliente: 'Super Familia', calle: 'Av. Sur 77', colonia: 'Sur', codigoPostal: '37800', limiteCredito: 6000.0),
      Cliente(clienteId: 6, nombreCliente: 'Abarrotes La Esquina', calle: 'Av. Central 505', colonia: 'Oriente', codigoPostal: '37900', limiteCredito: 3000.0),
    ]);

    // 2. Productos
    await productDao.insertAll([
      Producto(articuloId: 1, nombre: 'Refresco Cola 600ml', estatus: 'A', clave: 'REF001', precio: 18.0),
      Producto(articuloId: 2, nombre: 'Refresco Naranja 600ml', estatus: 'A', clave: 'REF002', precio: 18.0),
      Producto(articuloId: 3, nombre: 'Agua Natural 1L', estatus: 'A', clave: 'AGU001', precio: 12.0),
      Producto(articuloId: 4, nombre: 'Jugo Mango 500ml', estatus: 'A', clave: 'JUG001', precio: 22.0),
      Producto(articuloId: 5, nombre: 'Galletas Vainilla 200g', estatus: 'A', clave: 'GAL001', precio: 28.0),
      Producto(articuloId: 6, nombre: 'Galletas Chocolate 200g', estatus: 'A', clave: 'GAL002', precio: 28.0),
      Producto(articuloId: 7, nombre: 'Chicles Menta x10', estatus: 'A', clave: 'CHI001', precio: 5.0),
    ]);

    // 3. Notificaciones
    await notificacionDao.insertAll([
      Notificacion(mensaje: 'Promoción refrescos hoy|Oficina Central|08:00|Confirmado', leida: true, fechaCreacion: '2026-07-02 08:00:00'),
      Notificacion(mensaje: 'Meta del día actualizada|Gerente de Ventas|09:30|', leida: true, fechaCreacion: '2026-07-02 09:30:00'),
      Notificacion(mensaje: 'Producto sin stock|Almacén|10:15|', leida: false, fechaCreacion: '2026-07-02 10:15:00'),
      Notificacion(mensaje: 'Recordatorio cierre|Oficina Central|14:00|', leida: false, fechaCreacion: '2026-07-02 14:00:00'),
    ]);

    // 4. Ventas
    final today = DateTime.now().toIso8601String().substring(0, 10);
    await ventaDao.insert(VentaPendiente(
      ventaMovilId: 'VTA-Mendoza',
      vendedorId: 7,
      clienteId: 1,
      clienteNombre: 'Abarrotes Mendoza',
      fechaHora: '$today 09:15:00',
      estado: 'enviada',
      total: 1480.0,
      detalles: [],
    ));
    await ventaDao.insert(VentaPendiente(
      ventaMovilId: 'VTA-Roble',
      vendedorId: 7,
      clienteId: 2,
      clienteNombre: 'Minisuper El Roble',
      fechaHora: '$today 10:40:00',
      estado: 'enviada',
      total: 650.0,
      detalles: [],
    ));
    await ventaDao.insert(VentaPendiente(
      ventaMovilId: 'VTA-DonPepe',
      vendedorId: 7,
      clienteId: 3,
      clienteNombre: 'Tienda Don Pepe',
      fechaHora: '$today 11:55:00',
      estado: 'pendiente',
      total: 390.0,
      detalles: [],
    ));
    await ventaDao.insert(VentaPendiente(
      ventaMovilId: 'VTA-Reyes',
      vendedorId: 7,
      clienteId: 4,
      clienteNombre: 'Comercial Reyes',
      fechaHora: '$today 12:30:00',
      estado: 'error',
      total: 820.0,
      detalles: [],
    ));
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
