import 'package:flutter/material.dart';
import '../servicios/autenticacion_servicio.dart';
import '../servicios/base_datos_servicio.dart';
import '../modelos/mantenimiento.dart';
import '../utilidades/validadores.dart';

class PantallaFormularioMantenimiento extends StatefulWidget {
  final Mantenimiento? mantenimiento;

  PantallaFormularioMantenimiento({this.mantenimiento});

  @override
  _PantallaFormularioMantenimientoState createState() =>
      _PantallaFormularioMantenimientoState();
}

class _PantallaFormularioMantenimientoState
    extends State<PantallaFormularioMantenimiento> {
  final _formularioKey = GlobalKey<FormState>();
  final _tipoServicioController = TextEditingController();
  final _fechaController = TextEditingController();
  final _kilometrajeController = TextEditingController();
  final _observacionesController = TextEditingController();

  final _autenticacionServicio = AutenticacionServicio();
  final _baseDatosServicio = BaseDatosServicio();

  bool _cargando = false;
  DateTime _fechaSeleccionada = DateTime.now();

  final List<String> _tiposServicio = [
    'Cambio de aceite',
    'Revisión técnica',
    'Reemplazo de frenos',
    'Cambio de filtros',
    'Revisión de motor',
    'Cambio de llantas',
    'Revisión de suspensión',
    'Mantenimiento general',
    'Otro',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.mantenimiento != null) {
      _cargarDatosMantenimiento();
    }
    _fechaController.text = _formatearFecha(_fechaSeleccionada);
  }

  void _cargarDatosMantenimiento() {
    final mantenimiento = widget.mantenimiento!;
    _tipoServicioController.text = mantenimiento.tipoServicio;
    _fechaController.text = mantenimiento.fecha;
    _kilometrajeController.text = mantenimiento.kilometraje.toString();
    _observacionesController.text = mantenimiento.observaciones;

    try {
      _fechaSeleccionada = DateTime.parse(mantenimiento.fecha);
    } catch (e) {
      _fechaSeleccionada = DateTime.now();
    }
  }

  @override
  void dispose() {
    _tipoServicioController.dispose();
    _fechaController.dispose();
    _kilometrajeController.dispose();
    _observacionesController.dispose();
    super.dispose();
  }

  String _formatearFecha(DateTime fecha) {
    return '${fecha.year}-${fecha.month.toString().padLeft(2, '0')}-${fecha.day.toString().padLeft(2, '0')}';
  }

  Future<void> _seleccionarFecha() async {
    final DateTime? fechaElegida = await showDatePicker(
      context: context,
      initialDate: _fechaSeleccionada,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      locale: Locale('es', 'ES'),
    );

    if (fechaElegida != null && fechaElegida != _fechaSeleccionada) {
      setState(() {
        _fechaSeleccionada = fechaElegida;
        _fechaController.text = _formatearFecha(fechaElegida);
      });
    }
  }

  Future<void> _guardarMantenimiento() async {
    if (_formularioKey.currentState!.validate()) {
      setState(() {
        _cargando = true;
      });

      try {
        final usuario = _autenticacionServicio.usuarioActual;
        if (usuario == null) {
          throw 'Usuario no autenticado';
        }

        final mantenimiento = Mantenimiento(
          id: widget.mantenimiento?.id,
          tipoServicio: _tipoServicioController.text.trim(),
          fecha: _fechaController.text,
          kilometraje: int.parse(_kilometrajeController.text),
          observaciones: _observacionesController.text.trim(),
          idUsuario: usuario.uid,
        );

        if (widget.mantenimiento == null) {
          await _baseDatosServicio.insertarMantenimiento(mantenimiento);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Mantenimiento agregado correctamente'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          await _baseDatosServicio.actualizarMantenimiento(mantenimiento);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Mantenimiento actualizado correctamente'),
              backgroundColor: Colors.green,
            ),
          );
        }

        Navigator.pop(context, true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar mantenimiento: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }

      setState(() {
        _cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final esEdicion = widget.mantenimiento != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(esEdicion ? 'Editar Mantenimiento' : 'Nuevo Mantenimiento'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.0),
        child: Form(
          key: _formularioKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              DropdownButtonFormField<String>(
                value: _tiposServicio.contains(_tipoServicioController.text)
                    ? _tipoServicioController.text
                    : null,
                decoration: InputDecoration(
                  labelText: 'Tipo de servicio',
                  prefixIcon: Icon(Icons.build),
                ),
                items: _tiposServicio.map((tipo) {
                  return DropdownMenuItem(value: tipo, child: Text(tipo));
                }).toList(),
                onChanged: (valor) {
                  if (valor != null) {
                    _tipoServicioController.text = valor;
                  }
                },
                validator: (valor) => Validadores.validarCampoObligatorio(
                  valor,
                  'Tipo de servicio',
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _fechaController,
                decoration: InputDecoration(
                  labelText: 'Fecha',
                  prefixIcon: Icon(Icons.calendar_today),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.edit_calendar),
                    onPressed: _seleccionarFecha,
                  ),
                ),
                readOnly: true,
                onTap: _seleccionarFecha,
                validator: (valor) =>
                    Validadores.validarCampoObligatorio(valor, 'Fecha'),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _kilometrajeController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Kilometraje',
                  prefixIcon: Icon(Icons.speed),
                  suffixText: 'km',
                ),
                validator: Validadores.validarKilometraje,
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _observacionesController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Observaciones',
                  prefixIcon: Icon(Icons.notes),
                  alignLabelWithHint: true,
                ),
                validator: (valor) =>
                    Validadores.validarCampoObligatorio(valor, 'Observaciones'),
              ),
              SizedBox(height: 32),
              ElevatedButton(
                onPressed: _cargando ? null : _guardarMantenimiento,
                child: _cargando
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text(
                        esEdicion
                            ? 'Actualizar Mantenimiento'
                            : 'Guardar Mantenimiento',
                        style: TextStyle(fontSize: 16),
                      ),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
