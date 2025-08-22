class Mantenimiento {
  int? id;
  String tipoServicio;
  String fecha;
  int kilometraje;
  String observaciones;
  String idUsuario;

  Mantenimiento({
    this.id,
    required this.tipoServicio,
    required this.fecha,
    required this.kilometraje,
    required this.observaciones,
    required this.idUsuario,
  });

  Map<String, dynamic> aMap() {
    return {
      'id': id,
      'tipo_servicio': tipoServicio,
      'fecha': fecha,
      'kilometraje': kilometraje,
      'observaciones': observaciones,
      'id_usuario': idUsuario,
    };
  }

  factory Mantenimiento.deMap(Map<String, dynamic> map) {
    return Mantenimiento(
      id: map['id'],
      tipoServicio: map['tipo_servicio'],
      fecha: map['fecha'],
      kilometraje: map['kilometraje'],
      observaciones: map['observaciones'],
      idUsuario: map['id_usuario'],
    );
  }
}
