import 'dart:convert';
import 'dart:io';

void main() async {
  final server = await HttpServer.bind('127.0.0.1', 5048);
  print('Mock Sincronizador corriendo en http://127.0.0.1:5048');

  await for (final request in server) {
    final path = request.uri.path;
    final method = request.method;

    if (method == 'POST' && path == '/api/auth/login') {
      await _handleLogin(request);
    } else if (method == 'GET' && path.startsWith('/api/v1/sync/morning/')) {
      await _handleSyncMorning(request);
    } else if (method == 'POST' && path == '/api/v1/ventas') {
      await _handleSaveSale(request);
    } else {
      request.response.statusCode = 404;
      request.response.write('{"error":"Not Found"}');
    }
    await request.response.close();
  }
}

Future<void> _handleLogin(HttpRequest request) async {
  final body = jsonDecode(await utf8.decodeStream(request));
  final usuario = body['usuario'] as String?;
  final password = body['password'] as String?;

  await Future.delayed(const Duration(milliseconds: 500));

  if (usuario == 'vendedor@gmail.com' && password == 'rutx2026') {
    request.response.statusCode = 200;
    request.response.headers.contentType = ContentType.json;
    request.response.write(jsonEncode({
      'token':
          'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.mock.${usuario!.hashCode}',
    }));
  } else {
    request.response.statusCode = 401;
    request.response.headers.contentType = ContentType.json;
    request.response.write(jsonEncode({'error': 'Credenciales inválidas'}));
  }
}

Future<void> _handleSaveSale(HttpRequest request) async {
  await Future.delayed(const Duration(milliseconds: 300));
  request.response.statusCode = 201;
  request.response.headers.contentType = ContentType.json;
  request.response.write(jsonEncode({'status': 'ok', 'docto_ve_id': 99999}));
}

Future<void> _handleSyncMorning(HttpRequest request) async {
  await Future.delayed(const Duration(milliseconds: 800));

  final response = {
    'clientes': [
      {
        'cliente_id': 1,
        'nombre_cliente': 'Abarrotes Mendoza',
        'calle': 'Calle Juárez 45',
        'colonia': 'Centro',
        'codigo_postal': '37000',
        'limite_credito': 5000.0,
      },
      {
        'cliente_id': 2,
        'nombre_cliente': 'Minisuper El Roble',
        'calle': 'Av. Hidalgo 120',
        'colonia': 'San Rafael',
        'codigo_postal': '37120',
        'limite_credito': 8000.0,
      },
      {
        'cliente_id': 3,
        'nombre_cliente': 'Tienda Don Pepe',
        'calle': 'Calle Morelos 8',
        'colonia': 'Centro',
        'codigo_postal': '37000',
        'limite_credito': 4000.0,
      },
      {
        'cliente_id': 4,
        'nombre_cliente': 'Comercial Reyes',
        'calle': 'Blvd. Norte 230',
        'colonia': 'Norte',
        'codigo_postal': '37500',
        'limite_credito': 15000.0,
      },
      {
        'cliente_id': 5,
        'nombre_cliente': 'Super Familia',
        'calle': 'Av. Sur 77',
        'colonia': 'Sur',
        'codigo_postal': '37800',
        'limite_credito': 6000.0,
      },
      {
        'cliente_id': 6,
        'nombre_cliente': 'Abarrotes La Esquina',
        'calle': 'Av. Central 505',
        'colonia': 'Oriente',
        'codigo_postal': '37900',
        'limite_credito': 3000.0,
      },
    ],
    'productos': [
      {
        'articulo_id': 1,
        'nombre': 'Refresco Cola 600ml',
        'clave': 'REF001',
        'precio': 18.0,
        'estatus': 'A',
      },
      {
        'articulo_id': 2,
        'nombre': 'Refresco Naranja 600ml',
        'clave': 'REF002',
        'precio': 18.0,
        'estatus': 'A',
      },
      {
        'articulo_id': 3,
        'nombre': 'Agua Natural 1L',
        'clave': 'REF003',
        'precio': 12.0,
        'estatus': 'A',
      },
      {
        'articulo_id': 4,
        'nombre': 'Jugo Mango 500ml',
        'clave': 'REF004',
        'precio': 22.0,
        'estatus': 'A',
      },
      {
        'articulo_id': 5,
        'nombre': 'Galletas Vainilla 200g',
        'clave': 'REF005',
        'precio': 28.0,
        'estatus': 'A',
      },
      {
        'articulo_id': 6,
        'nombre': 'Galletas Chocolate 200g',
        'clave': 'REF006',
        'precio': 28.0,
        'estatus': 'A',
      },
      {
        'articulo_id': 7,
        'nombre': 'Chicles Menta x10',
        'clave': 'REF007',
        'precio': 5.0,
        'estatus': 'A',
      },
    ],
  };

  request.response.statusCode = 200;
  request.response.headers.contentType = ContentType.json;
  request.response.write(jsonEncode(response));
}
