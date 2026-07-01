import 'app_database.dart';
import 'entities/cliente_entity.dart';
import 'entities/producto_entity.dart';
import 'entities/venta_pendiente_entity.dart';
import 'entities/notificacion_entity.dart';

class DatabaseService {
  final AppDatabase _appDb = AppDatabase();

  Future<void> initialize() async {
    await _appDb.initialize();
  }

  Future<void> guardarClientes(List<Cliente> clientes) async {
    await _appDb.clienteDao.insertAll(clientes);
  }

  Future<List<Cliente>> obtenerClientes() async {
    return await _appDb.clienteDao.getAll();
  }

  Future<Cliente?> obtenerClientePorId(int id) async {
    return await _appDb.clienteDao.getById(id);
  }

  Future<List<Cliente>> buscarClientes(String query) async {
    return await _appDb.clienteDao.search(query);
  }

  Future<void> guardarProductos(List<Producto> productos) async {
    await _appDb.productDao.insertAll(productos);
  }

  Future<List<Producto>> obtenerProductos() async {
    return await _appDb.productDao.getAll();
  }

  Future<Producto?> obtenerProductoPorId(int id) async {
    return await _appDb.productDao.getById(id);
  }

  Future<List<Producto>> buscarProductos(String query) async {
    return await _appDb.productDao.search(query);
  }

  Future<void> guardarVenta(VentaPendiente venta) async {
    await _appDb.ventaDao.insert(venta);
  }

  Future<List<VentaPendiente>> obtenerVentasPendientes() async {
    return await _appDb.ventaDao.getPendientes();
  }

  Future<List<VentaPendiente>> obtenerTodasLasVentas() async {
    return await _appDb.ventaDao.getAll();
  }

  Future<List<VentaPendiente>> obtenerVentasDelDia(String fecha) async {
    return await _appDb.ventaDao.getDelDia(fecha);
  }

  Future<void> actualizarEstadoVenta(String id, String estado) async {
    await _appDb.ventaDao.updateEstado(id, estado);
  }

  Future<Map<String, dynamic>> obtenerResumenDelDia(String fecha) async {
    return await _appDb.ventaDao.getResumenDelDia(fecha);
  }

  Future<void> guardarNotificaciones(List<Notificacion> notificaciones) async {
    await _appDb.notificacionDao.insertAll(notificaciones);
  }

  Future<List<Notificacion>> obtenerNotificaciones() async {
    return await _appDb.notificacionDao.getAll();
  }

  Future<List<Notificacion>> obtenerNotificacionesNoLeidas() async {
    return await _appDb.notificacionDao.getNoLeidas();
  }

  Future<int> contarNotificacionesNoLeidas() async {
    return await _appDb.notificacionDao.countNoLeidas();
  }

  Future<void> marcarNotificacionLeida(int id) async {
    await _appDb.notificacionDao.markAsRead(id);
  }

  Future<void> marcarTodasLeidas() async {
    await _appDb.notificacionDao.markAllAsRead();
  }

  Future<void> limpiarDatosDelDia() async {
    await _appDb.limpiarDatosDelDia();
  }

  Future<void> close() async {
    await _appDb.close();
  }
}
