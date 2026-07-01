class Producto {
  final int articuloId;
  final String nombre;
  final String estatus;

  Producto({
    required this.articuloId,
    required this.nombre,
    this.estatus = 'A',
  });

  Map<String, dynamic> toMap() => {
        'articulo_id': articuloId,
        'nombre': nombre,
        'estatus': estatus,
      };

  factory Producto.fromMap(Map<String, dynamic> map) => Producto(
        articuloId: map['articulo_id'] as int,
        nombre: map['nombre'] as String,
        estatus: map['estatus'] as String? ?? 'A',
      );
}
