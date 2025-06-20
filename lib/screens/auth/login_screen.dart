// lib/screens/auth/login_screen.dart (or where it's located)
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:servel/screens/preguntas/questionnaire_screen.dart';
import 'dart:convert';
// REMOVE: import 'package:shared_preferences/shared_preferences.dart'; // <--- REMOVE THIS
import 'package:flutter_secure_storage/flutter_secure_storage.dart'; // <--- ADD THIS

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isLoading = false;

  final String _baseUrl = 'http://10.0.2.2:8000/api';

  // Instantiate FlutterSecureStorage
  final FlutterSecureStorage _storage = const FlutterSecureStorage(); // <--- ADD THIS

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return; 
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Future<void> _loginUser() async {
    print('DEBUG: _loginUser() called'); // Nuevo: Inicio de la función
    if (!_formKey.currentState!.validate()) {
      print('DEBUG: Validation failed'); // Nuevo: Fallo de validación
      return;
    }

    setState(() {
      _isLoading = true;
      print('DEBUG: _isLoading set to true'); // Nuevo: Indicador de carga ON
    });

    final String username = _usernameController.text.trim();
    final String password = _passwordController.text;

    try {
      print('DEBUG: Making HTTP POST request to $_baseUrl/login/'); // Nuevo: Antes de la petición
      final response = await http.post(
        Uri.parse('$_baseUrl/login/'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, String>{
          'username': username,
          'password': password,
        }),
      );

      print('DEBUG: HTTP response received. Status: ${response.statusCode}'); // Nuevo: Después de la respuesta

      if (!mounted) {
        print('DEBUG: Widget unmounted after response received. Returning.'); // Nuevo: Si el widget ya no está montado
        return;
      }

      if (response.statusCode == 200) {
        print('DEBUG: Login successful. Processing response data.'); // Nuevo: Login exitoso
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        final String token = responseData['token'];

        await _storage.write(key: 'auth_token', value: token);
        print('DEBUG: Token guardado en FlutterSecureStorage: $token');

        _showSnackBar('¡Login exitoso. Bienvenido!');
        print('DEBUG: Navigating to QuestionnaireScreen'); // Nuevo: Antes de navegar
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => QuestionnaireScreen(tipoEleccionId: 1, tipoEleccionNombre: 'Presidencial'),
          ),
        );
        print('DEBUG: Navigation completed. LoginScreen is now unmounted.'); // Nuevo: Después de la navegación
      } else {
        print('DEBUG: Login failed. Status: ${response.statusCode} - Body: ${response.body}'); // Nuevo: Login fallido
        String errorMessage = 'Error al iniciar sesión.';
        try {
          final Map<String, dynamic> errorData = jsonDecode(response.body);
          if (errorData.containsKey('non_field_errors')) {
            errorMessage += '\n${errorData['non_field_errors'][0]}';
          } else {
            print('DEBUG: Unexpected error response body: ${response.body}');
            errorMessage += '\nDetalles: ${response.body}';
          }
        } catch (e) {
          print('DEBUG: Error parsing error response: ${response.body}. Exception: $e');
          errorMessage += '\nDetalles: ${response.body}';
        }
        _showSnackBar(errorMessage, isError: true);
      }
    } catch (e) {
      print('DEBUG: Exception caught during login: $e'); // Nuevo: Excepción capturada
      _showSnackBar('Error de conexión. Verifica tu conexión a internet.', isError: true);
    } finally {
      print('DEBUG: Finally block entered.'); // Nuevo: Entrada al bloque finally
      if (mounted) {
        print('DEBUG: Widget is still mounted. Setting _isLoading to false.'); // Nuevo: Ocultando carga
        setState(() {
          _isLoading = false;
        });
      } else {
        print('DEBUG: Widget is NOT mounted. _isLoading will not be set to false.'); // Nuevo: No se oculta carga
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ... (resto de tu código de build, no necesita cambios aquí) ...
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const Text(
                  'Bienvenido de Nuevo',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Nombre de Usuario o Email',
                    prefixIcon: const Icon(Icons.person),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: const Color.fromARGB(255, 255, 255, 255),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingresa tu usuario o email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: const Icon(Icons.lock),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: const Color.fromARGB(255, 255, 255, 255),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor, ingresa tu contraseña';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _loginUser,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xffe2000d),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Iniciar Sesión',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/register');
                  },
                  child: const Text(
                    '¿No tienes una cuenta? Regístrate',
                    style: TextStyle(color: Color(0xffe2000d)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}