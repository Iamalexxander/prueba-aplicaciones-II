import 'package:flutter/material.dart';
import '../servicios/autenticacion_servicio.dart';
import '../utilidades/validadores.dart';
import 'pantalla_lista_mantenimientos.dart';

class PantallaRegistro extends StatefulWidget {
  @override
  _PantallaRegistroState createState() => _PantallaRegistroState();
}

class _PantallaRegistroState extends State<PantallaRegistro> {
  final _formularioKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmarPasswordController = TextEditingController();
  final _autenticacionServicio = AutenticacionServicio();
  bool _cargando = false;
  bool _ocultarPassword = true;
  bool _ocultarConfirmarPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmarPasswordController.dispose();
    super.dispose();
  }

  String? _validarConfirmarPassword(String? valor) {
    if (valor == null || valor.isEmpty) {
      return 'Confirma tu contraseña';
    }
    if (valor != _passwordController.text) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }

  Future<void> _registrarse() async {
    if (_formularioKey.currentState!.validate()) {
      setState(() {
        _cargando = true;
      });

      try {
        await _autenticacionServicio.registrarConEmail(
          _emailController.text.trim(),
          _passwordController.text,
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PantallaListaMantenimientos(),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }

      setState(() {
        _cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Registro')),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Form(
            key: _formularioKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(Icons.person_add, size: 80, color: Colors.blue[600]),
                SizedBox(height: 24),
                Text(
                  'Crear Nueva Cuenta',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 48),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Correo electrónico',
                    prefixIcon: Icon(Icons.email),
                  ),
                  validator: Validadores.validarEmail,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _ocultarPassword,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _ocultarPassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _ocultarPassword = !_ocultarPassword;
                        });
                      },
                    ),
                  ),
                  validator: Validadores.validarPassword,
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _confirmarPasswordController,
                  obscureText: _ocultarConfirmarPassword,
                  decoration: InputDecoration(
                    labelText: 'Confirmar contraseña',
                    prefixIcon: Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _ocultarConfirmarPassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _ocultarConfirmarPassword =
                              !_ocultarConfirmarPassword;
                        });
                      },
                    ),
                  ),
                  validator: _validarConfirmarPassword,
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _cargando ? null : _registrarse,
                  child: _cargando
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text('Registrarse', style: TextStyle(fontSize: 16)),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 16),
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
