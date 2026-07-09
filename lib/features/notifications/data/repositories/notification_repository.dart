import '../../../../core/database/app_database.dart';
import '../../../../core/database/entities/notificacion_entity.dart';
import '../datasources/notification_remote_datasource.dart';

class NotificationRepository {
  final NotificationRemoteDataSource _remoteDataSource = NotificationRemoteDataSource();

  Future<void> fetchAndPersist(int vendedorId) async {
    try {
      final db = AppDatabase();
      await db.initialize();

      final existing = await db.notificacionDao.getAll();
      final existingKeys = existing.map((n) => n.mensaje).toSet();

      final remotos = await _remoteDataSource.fetchNotificaciones(vendedorId);

      final nuevas = <Notificacion>[];
      for (final r in remotos) {
        final key = r.contenido;
        if (!existingKeys.contains(key)) {
          nuevas.add(Notificacion(
            mensaje: key,
            fechaCreacion: r.fechaEnvio,
          ));
        }
      }

      if (nuevas.isNotEmpty) {
        await db.notificacionDao.insertAll(nuevas);
      }
    } catch (_) {}
  }

  Future<List<Notificacion>> getAll() async {
    final db = AppDatabase();
    await db.initialize();
    return db.notificacionDao.getAll();
  }

  Future<int> getUnreadCount() async {
    final db = AppDatabase();
    await db.initialize();
    return db.notificacionDao.countNoLeidas();
  }

  Future<void> markAsRead(int id) async {
    final db = AppDatabase();
    await db.initialize();
    await db.notificacionDao.markAsRead(id);
  }

  Future<void> updateMensaje(int id, String nuevoMensaje) async {
    final db = AppDatabase();
    await db.initialize();
    await db.notificacionDao.updateMensaje(id, nuevoMensaje);
  }

  Future<void> markAllAsRead() async {
    final db = AppDatabase();
    await db.initialize();
    await db.notificacionDao.markAllAsRead();
  }

  Future<void> deleteAll() async {
    final db = AppDatabase();
    await db.initialize();
    await db.notificacionDao.deleteAll();
  }

  Future<void> reseed() async {
    final db = AppDatabase();
    await db.initialize();
    await db.notificacionDao.deleteAll();
    await db.seedDatabase();
  }
}
