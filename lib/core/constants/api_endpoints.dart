class ApiEndpoints {
  static const String baseUrl = 'http://localhost:5047';
  
  // Auth
  static const String login = '$baseUrl/api/auth/login';
  
  // Sync
  static String syncMorning(int vendedorId) => '$baseUrl/api/v1/sync/morning/$vendedorId';
  static const String syncClosing = '$baseUrl/api/v1/sync/closing';
  
  // Clients
  static const String clients = '$baseUrl/api/v1/clientes';
  
  // Sales
  static const String sales = '$baseUrl/api/v1/ventas';
  
  // Queue
  static const String queue = '$baseUrl/api/v1/queue';
  static String queueStatus(String operacionId) => '$baseUrl/api/v1/queue/status/$operacionId';
  static String queueRetry(String operacionId) => '$baseUrl/api/v1/queue/retry/$operacionId';
}
