# RUTX Móvil

Aplicación Android para la plataforma de venta en ruta RUTX.

## Descripción

App móvil para vendedores en ruta que permite:
- Autenticación y gestión de sesión
- Descarga de catálogos y clientes asignados (sincronización matutina)
- Registro de ventas con funcionamiento offline
- Recepción de notificaciones de oficina
- Resumen y cierre de jornada

## Stack

- **Framework:** Flutter 3.x + Dart
- **Plataforma:** Android (gama baja)
- **Almacenamiento local:** Hive / SQLite
- **API REST:** Sincronizador Módulo 3

## Arquitectura

```
lib/
├── main.dart                    # Punto de entrada
├── app/
│   ├── app.dart                 # MaterialApp con configuración
│   ├── routes.dart              # Nomenclatura de rutas
│   └── theme.dart               # Tema visual de la app
├── core/
│   ├── constants/
│   │   ├── api_endpoints.dart   # URLs de la API
│   │   └── app_constants.dart   # Constantes generales
│   ├── errors/
│   │   ├── exceptions.dart      # Excepciones personalizadas
│   │   └── failures.dart        # Fallas del sistema
│   ├── network/
│   │   ├── connectivity_service.dart  # Estado de red
│   │   └── http_client.dart          # Cliente HTTP base
│   └── utils/
│       ├── date_utils.dart      # Utilidades de fecha
│       └── formatters.dart      # Formateo de datos
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── datasources/     # Fuentes de datos (API + local)
│   │   │   ├── models/          # Modelos de datos
│   │   │   └── repositories/    # Implementación de repositorios
│   │   ├── domain/
│   │   │   ├── entities/        # Entidades de negocio
│   │   │   ├── repositories/    # Contratos de repositorios
│   │   │   └── usecases/        # Casos de uso
│   │   └── presentation/
│   │       ├── bloc/            # Estado (BLoC/Cubit)
│   │       ├── pages/           # Pantallas
│   │       └── widgets/         # Widgets reutilizables
│   ├── sync/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── catalog/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── sales/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── notifications/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   └── summary/
│       ├── data/
│       ├── domain/
│       └── presentation/
└── shared/
    ├── widgets/                 # Componentes compartidos
    └── services/                # Servicios compartidos
```

## Licencia

Propietario - Teknologix / RUTX
