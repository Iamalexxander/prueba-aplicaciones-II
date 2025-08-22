class Validadores {
  static String? validarEmail(String? valor) {
    if (valor == null || valor.isEmpty) {
      return 'El correo electrónico es obligatorio';
    }
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!regex.hasMatch(valor)) {
      return 'Ingresa un correo electrónico válido';
    }
    return null;
  }

  static String? validarPassword(String? valor) {
    if (valor == null || valor.isEmpty) {
      return 'La contraseña es obligatoria';
    }
    if (valor.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    return null;
  }

  static String? validarCampoObligatorio(String? valor, String nombreCampo) {
    if (valor == null || valor.trim().isEmpty) {
      return '$nombreCampo es obligatorio';
    }
    return null;
  }

  static String? validarKilometraje(String? valor) {
    if (valor == null || valor.isEmpty) {
      return 'El kilometraje es obligatorio';
    }
    final kilometraje = int.tryParse(valor);
    if (kilometraje == null || kilometraje < 0) {
      return 'Ingresa un kilometraje válido';
    }
    return null;
  }
}
