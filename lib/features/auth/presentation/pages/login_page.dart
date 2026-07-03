import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/database/app_database.dart';
import '../../data/auth_repository.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../../../sync/presentation/pages/download_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _authRepository = AuthRepository();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _rememberMe = true;
  bool _isLoading = false;

  void _handleLogin() async {
    setState(() => _isLoading = true);
    
    final success = await _authRepository.login(
      _usernameController.text,
      _passwordController.text,
      _rememberMe,
    );
    
    if (mounted) {
      setState(() => _isLoading = false);

      if (success) {
        final db = AppDatabase();
        await db.initialize();
        final clientes = await db.clienteDao.getAll();
        final productos = await db.productDao.getAll();
        final hasData = clientes.isNotEmpty && productos.isNotEmpty;
        if (!mounted) return;

        if (hasData) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const DownloadPage()),
          );
        }
      } else {
        // Mostrar mensaje de error si las credenciales fallan o el servidor no responde
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error al iniciar sesión. Revisa tus credenciales o conexión.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Column(
        children: [
          // Encabezado Azul Oscuro
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 80, bottom: 40, left: 24, right: 24),
            color: AppTheme.primaryColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: const BoxDecoration(
                        color: AppTheme.accentColor,
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Text(
                          'RX',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'RUTX',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Accede con tu cuenta para comenzar tu jornada.',
                  style: TextStyle(color: AppTheme.secondaryColor, fontSize: 16),
                ),
              ],
            ),
          ),
          // Formulario
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Usuario', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _usernameController,
                    decoration: const InputDecoration(
                      hintText: 'Tu nombre de usuario',
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text('Contraseña', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      hintText: '••••••••',
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          color: AppTheme.textSecondary,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Checkbox(
                        value: _rememberMe,
                        activeColor: AppTheme.primaryColor,
                        onChanged: (value) {
                          setState(() {
                            _rememberMe = value ?? false;
                          });
                        },
                      ),
                      const Text('Recordar sesión', style: TextStyle(color: AppTheme.textPrimary)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    child: _isLoading
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white))
                        : const Text('Iniciar sesión', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 32),
                  Center(
                    child: RichText(
                      text: const TextSpan(
                        text: '¿Problemas para entrar? ',
                        style: TextStyle(color: AppTheme.textSecondary),
                        children: [
                          TextSpan(
                            text: 'Contactar soporte',
                            style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
