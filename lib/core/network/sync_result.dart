sealed class SyncResult {}

class SyncSuccess extends SyncResult {
  final int clientes;
  final int productos;
  SyncSuccess({required this.clientes, required this.productos});
}

class SyncFailure extends SyncResult {
  final String mensaje;
  final int intentos;
  SyncFailure({required this.mensaje, this.intentos = 3});
}
