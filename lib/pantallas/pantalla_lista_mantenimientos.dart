import 'package:flutter/material.dart';
import '../servicios/autenticacion_servicio.dart';
import '../servicios/base_datos_servicio.dart';
import '../modelos/mantenimiento.dart';
import 'pantalla_login.dart';
import 'pantalla_formulario_mantenimiento.dart';

class PantallaListaMantenimientos extends StatefulWidget {
  @override
  _PantallaListaMantenimientosState createState() =>
      _PantallaListaMantenimientosState();
}

class _PantallaListaMantenimientosState
    extends State<PantallaListaMantenimientos> {
  final _autenticacionServicio = AutenticacionServicio();
  final _baseDatosServicio = BaseDatosServicio();
  List<Mantenimiento> _mantenimientos = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarMantenimientos();
  }

  Future<void> _cargarMantenimientos() async {
    setState(() {
      _cargando = true;
    });

    try {
      final usuario = _autenticacionServicio.usuarioActual;
      if (usuario != null) {
        final mantenimientos = await _baseDatosServicio
            .obtenerMantenimientosPorUsuario(usuario.uid);
        setState(() {
          _mantenimientos = mantenimientos;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar mantenimientos: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }

    setState(() {
      _cargando = false;
    });
  }

  Future<void> _cerrarSesion() async {
    try {
      await _autenticacionServicio.cerrarSesion();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => PantallaLogin()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cerrar sesión: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _eliminarMantenimiento(Mantenimiento mantenimiento) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmar eliminación'),
        content: Text(
          '¿Estás seguro de que quieres eliminar este mantenimiento?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text('Eliminar'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );

    if (confirmar == true) {
      try {
        final usuario = _autenticacionServicio.usuarioActual;
        if (usuario != null && mantenimiento.id != null) {
          await _baseDatosServicio.eliminarMantenimiento(
            mantenimiento.id!,
            usuario.uid,
          );
          _cargarMantenimientos();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Mantenimiento eliminado correctamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar mantenimiento: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _irAFormulario([Mantenimiento? mantenimiento]) async {
    final resultado = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            PantallaFormularioMantenimiento(mantenimiento: mantenimiento),
      ),
    );

    if (resultado == true) {
      _cargarMantenimientos();
    }
  }

  Widget _construirTarjetaMantenimiento(Mantenimiento mantenimiento) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: Colors.blue[600],
          child: Icon(Icons.build, color: Colors.white),
        ),
        title: Text(
          mantenimiento.tipoServicio,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 8),
            Text(
              'Fecha: ${mantenimiento.fecha}',
              style: TextStyle(fontSize: 14),
            ),
            Text(
              'Kilometraje: ${mantenimiento.kilometraje} km',
              style: TextStyle(fontSize: 14),
            ),
            if (mantenimiento.observaciones.isNotEmpty)
              Text(
                'Observaciones: ${mantenimiento.observaciones}',
                style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (valor) {
            if (valor == 'editar') {
              _irAFormulario(mantenimiento);
            } else if (valor == 'eliminar') {
              _eliminarMantenimiento(mantenimiento);
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'editar',
              child: Row(
                children: [
                  Icon(Icons.edit, color: Colors.blue),
                  SizedBox(width: 8),
                  Text('Editar'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'eliminar',
              child: Row(
                children: [
                  Icon(Icons.delete, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Eliminar'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mantenimientos'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _cerrarSesion,
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: _cargando
          ? Center(child: CircularProgressIndicator())
          : _mantenimientos.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.car_repair, size: 80, color: Colors.grey[400]),
                  SizedBox(height: 16),
                  Text(
                    'No hay mantenimientos registrados',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Agrega tu primer mantenimiento',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _cargarMantenimientos,
              child: ListView.builder(
                itemCount: _mantenimientos.length,
                itemBuilder: (context, index) {
                  return _construirTarjetaMantenimiento(_mantenimientos[index]);
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _irAFormulario(),
        child: Icon(Icons.add),
        backgroundColor: Colors.blue[600],
        tooltip: 'Agregar mantenimiento',
      ),
    );
  }
}
