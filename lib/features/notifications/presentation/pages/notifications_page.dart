import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/entities/notificacion_entity.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<Notificacion> _notifications = [];
  int _unreadCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final db = AppDatabase();
    await db.initialize();
    
    // Seed notifications if database is empty
    final count = await db.notificacionDao.db.rawQuery('SELECT COUNT(*) as count FROM notificaciones');
    final countVal = Sqflite.firstIntValue(count) ?? 0;
    
    if (countVal == 0) {
      // Seed details in a custom json or text if needed. For Sprint 1, we save standard messages.
      // We will parse message details using structured text: "Title|Sender|Time|Status"
      await db.notificacionDao.insertAll([
        Notificacion(
          mensaje: 'Promoción refrescos hoy|Oficina Central|08:00|Confirmado',
          leida: true,
          fechaCreacion: '2026-07-02 08:00:00',
        ),
        Notificacion(
          mensaje: 'Meta del día actualizada|Gerente de Ventas|09:30|',
          leida: true,
          fechaCreacion: '2026-07-02 09:30:00',
        ),
        Notificacion(
          mensaje: 'Producto sin stock|Almacén|10:15|',
          leida: false,
          fechaCreacion: '2026-07-02 10:15:00',
        ),
        Notificacion(
          mensaje: 'Recordatorio cierre|Oficina Central|14:00|',
          leida: false,
          fechaCreacion: '2026-07-02 14:00:00',
        ),
      ]);
    }

    final list = await db.notificacionDao.getAll();
    final unread = await db.notificacionDao.countNoLeidas();

    if (mounted) {
      setState(() {
        _notifications = list;
        _unreadCount = unread;
        _isLoading = false;
      });
    }
  }

  void _markAsRead(int id) async {
    final db = AppDatabase();
    await db.initialize();
    await db.notificacionDao.markAsRead(id);
    _loadNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Notificaciones',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.accentColor))
          : Column(
              children: [
                // Unread Count Banner
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE3F2FD), // Light blue
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.notifications_none_outlined, color: AppTheme.primaryColor),
                        const SizedBox(width: 12),
                        Text(
                          '$_unreadCount mensajes sin leer',
                          style: const TextStyle(
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Notifications List
                Expanded(
                  child: _notifications.isEmpty
                      ? const Center(
                          child: Text(
                            'No tienes notificaciones.',
                            style: TextStyle(color: AppTheme.textSecondary),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _notifications.length,
                          itemBuilder: (context, index) {
                            final n = _notifications[index];
                            final parts = n.mensaje.split('|');
                            final title = parts[0];
                            final sender = parts.length > 1 ? parts[1] : 'Sistema';
                            final time = parts.length > 2 ? parts[2] : '00:00';
                            final status = parts.length > 3 ? parts[3] : '';

                            final isUnread = !n.leida;
                            final avatarLetter = sender.isNotEmpty ? sender[0].toUpperCase() : 'N';

                            return GestureDetector(
                              onTap: () {
                                if (isUnread && n.id != null) {
                                  _markAsRead(n.id!);
                                }
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: AppTheme.lightGrey),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.01),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Avatar
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: isUnread
                                            ? AppTheme.primaryColor
                                            : const Color(0xFFE0E0E0),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Center(
                                        child: Text(
                                          avatarLetter,
                                          style: TextStyle(
                                            color: isUnread ? Colors.white : AppTheme.textPrimary,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 16),

                                    // Notification Details
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  title,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                    color: AppTheme.textPrimary,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                time,
                                                style: const TextStyle(
                                                  color: AppTheme.textSecondary,
                                                  fontSize: 13,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            sender,
                                            style: const TextStyle(
                                              color: AppTheme.textSecondary,
                                              fontSize: 14,
                                            ),
                                          ),
                                          if (status.isNotEmpty) ...[
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.check_circle_outline,
                                                  color: Colors.green,
                                                  size: 16,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  status,
                                                  style: const TextStyle(
                                                    color: Colors.green,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 13,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
