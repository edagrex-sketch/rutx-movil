class Cliente {
  final int clienteId;
  final String nombreCliente;
  final String? calle;
  final String? colonia;
  final String? codigoPostal;
  final double limiteCredito;

  Cliente({
    required this.clienteId,
    required this.nombreCliente,
    this.calle,
    this.colonia,
    this.codigoPostal,
    this.limiteCredito = 0.0,
  });

  Map<String, dynamic> toMap() => {
        'cliente_id': clienteId,
        'nombre_cliente': nombreCliente,
        'calle': calle,
        'colonia': colonia,
        'codigo_postal': codigoPostal,
        'limite_credito': limiteCredito,
      };

  factory Cliente.fromMap(Map<String, dynamic> map) => Cliente(
        clienteId: map['cliente_id'] as int,
        nombreCliente: map['nombre_cliente'] as String,
        calle: map['calle'] as String?,
        colonia: map['colonia'] as String?,
        codigoPostal: map['codigo_postal'] as String?,
        limiteCredito: (map['limite_credito'] as num?)?.toDouble() ?? 0.0,
      );
}
