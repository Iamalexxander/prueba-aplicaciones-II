// ignore_for_file: file_names

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../modelos/mantenimiento.dart';

class BaseDatosServicio {
  static Database? _baseDatos;

  Future<Database> get baseDatos async {
    if (_baseDatos != null) return _baseDatos!;
    _baseDatos = await _inicializarBaseDatos();
    return _baseDatos!;
  }

  Future<Database> _inicializarBaseDatos() async {
    String ruta = join(await getDatabasesPath(), 'mantenimientos.db');
    return await openDatabase(ruta, version: 1, onCreate: _crearBaseDatos);
  }

  Future<void> _crearBaseDatos(Database db, int version) async {
    await db.execute('''
      CREATE TABLE mantenimientos(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tipo_servicio TEXT NOT NULL,
        fecha TEXT NOT NULL,
        kilometraje INTEGER NOT NULL,
        observaciones TEXT NOT NULL,
        id_usuario TEXT NOT NULL
      )
    ''');
  }

  Future<int> insertarMantenimiento(Mantenimiento mantenimiento) async {
    final db = await baseDatos;
    return await db.insert('mantenimientos', mantenimiento.aMap());
  }

  Future<List<Mantenimiento>> obtenerMantenimientosPorUsuario(
    String idUsuario,
  ) async {
    final db = await baseDatos;
    final List<Map<String, dynamic>> mapas = await db.query(
      'mantenimientos',
      where: 'id_usuario = ?',
      whereArgs: [idUsuario],
      orderBy: 'fecha DESC',
    );

    return List.generate(mapas.length, (i) {
      return Mantenimiento.deMap(mapas[i]);
    });
  }

  Future<int> actualizarMantenimiento(Mantenimiento mantenimiento) async {
    final db = await baseDatos;
    return await db.update(
      'mantenimientos',
      mantenimiento.aMap(),
      where: 'id = ? AND id_usuario = ?',
      whereArgs: [mantenimiento.id, mantenimiento.idUsuario],
    );
  }

  Future<int> eliminarMantenimiento(int id, String idUsuario) async {
    final db = await baseDatos;
    return await db.delete(
      'mantenimientos',
      where: 'id = ? AND id_usuario = ?',
      whereArgs: [id, idUsuario],
    );
  }

  Future<void> cerrarBaseDatos() async {
    final db = await baseDatos;
    await db.close();
  }
}
