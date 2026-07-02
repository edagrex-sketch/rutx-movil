class Producto {
  final int articuloId;
  final String nombre;
  final String estatus;
  final String clave;
  final double precio;

  Producto({
    required this.articuloId,
    required this.nombre,
    this.estatus = 'A',
    required this.clave,
    required this.precio,
  });

  Map<String, dynamic> toMap() => {
        'articulo_id': articuloId,
        'nombre': nombre,
        'estatus': estatus,
        'clave': clave,
        'precio': precio,
      };

  factory Producto.fromMap(Map<String, dynamic> map) {
    final id = map['articulo_id'] as int;
    return Producto(
      articuloId: id,
      nombre: map['nombre'] as String,
      estatus: map['estatus'] as String? ?? 'A',
      clave: map['clave'] as String? ?? 'REF${id.toString().padLeft(3, '0')}',
      precio: (map['precio'] as num?)?.toDouble() ?? ((id % 5 + 2) * 5).toDouble(),
    );
  }
}
