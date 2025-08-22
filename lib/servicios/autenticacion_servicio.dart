import 'package:firebase_auth/firebase_auth.dart';

class AutenticacionServicio {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  User? get usuarioActual => _firebaseAuth.currentUser;

  Stream<User?> get estadoAutenticacion => _firebaseAuth.authStateChanges();

  Future<UserCredential?> registrarConEmail(
    String email,
    String password,
  ) async {
    try {
      UserCredential resultado = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      return resultado;
    } on FirebaseAuthException catch (e) {
      throw _manejarErroresAuth(e);
    }
  }

  Future<UserCredential?> iniciarSesionConEmail(
    String email,
    String password,
  ) async {
    try {
      UserCredential resultado = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return resultado;
    } on FirebaseAuthException catch (e) {
      throw _manejarErroresAuth(e);
    }
  }

  Future<void> cerrarSesion() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw 'Error al cerrar sesión';
    }
  }

  String _manejarErroresAuth(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No se encontró ningún usuario con este correo electrónico.';
      case 'wrong-password':
        return 'La contraseña es incorrecta.';
      case 'email-already-in-use':
        return 'Ya existe una cuenta con este correo electrónico.';
      case 'weak-password':
        return 'La contraseña es muy débil.';
      case 'invalid-email':
        return 'El correo electrónico no es válido.';
      case 'too-many-requests':
        return 'Demasiados intentos fallidos. Intenta más tarde.';
      default:
        return 'Error de autenticación: ${e.message}';
    }
  }
}
