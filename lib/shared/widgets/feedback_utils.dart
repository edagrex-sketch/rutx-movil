import 'package:flutter/material.dart';
import '../../core/errors/app_error.dart';

void showError(BuildContext context, AppError error) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.white, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(error.mensajeUsuario)),
        ],
      ),
      backgroundColor: Colors.redAccent,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 4),
      action: error.esRecuperable
          ? SnackBarAction(
              label: 'Reintentar',
              textColor: Colors.white,
              onPressed: () {},
            )
          : null,
    ),
  );
}

void showSuccess(BuildContext context, String mensaje) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.white, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(mensaje)),
        ],
      ),
      backgroundColor: Colors.green,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 3),
    ),
  );
}

void showInfo(BuildContext context, String mensaje) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.white, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(mensaje)),
        ],
      ),
      backgroundColor: Colors.orange,
      behavior: SnackBarBehavior.floating,
      duration: const Duration(seconds: 4),
    ),
  );
}
