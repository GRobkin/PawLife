// views/pet_form_screen.dart
//
// Crear y editar mascota. Es la misma pantalla para las dos cosas: si se le
// pasa una `mascota` viene con los datos cargados y guarda con PATCH, y si no
// está vacía y crea con POST.
//
// Devuelve `true` al hacer pop cuando guardó algo, para que la pantalla que la
// abrió sepa que tiene que recargar.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/pawlife_models.dart';
import '../services/pawlife_repository.dart';
import '../services/photo_service.dart';
import '../theme/app_colors.dart';
import 'widgets/foto_mascota.dart';

/// Lo que puede elegirse en el menú de la foto. "Quitar" no es un origen, así
/// que no cabe en `OrigenFoto`.
enum _AccionFoto { galeria, camara, quitar }

class PetFormScreen extends StatefulWidget {
  const PetFormScreen({super.key, this.mascota});

  /// null = crear. Con valor = editar esa mascota.
  final Mascota? mascota;

  @override
  State<PetFormScreen> createState() => _PetFormScreenState();
}

class _PetFormScreenState extends State<PetFormScreen> {
  final _repositorio = PawLifeRepository();
  final _fotos = PhotoService();

  late final TextEditingController _nombre;
  late final TextEditingController _raza;
  late final TextEditingController _notas;
  final _peso = TextEditingController();

  late Especie _especie;
  DateTime? _fechaNacimiento;

  /// La foto como data URI, ya reducida y codificada. Es el valor que se
  /// guarda tal cual en `fotoUrl`, así que no hay diferencia entre "la que
  /// tenía" y "la que acaba de elegir": es el mismo campo.
  String? _foto;

  bool _guardando = false;
  String? _error;

  bool get _esEdicion => widget.mascota != null;

  @override
  void initState() {
    super.initState();

    final mascota = widget.mascota;
    _nombre = TextEditingController(text: mascota?.nombre ?? '');
    _raza = TextEditingController(text: mascota?.raza ?? '');
    _notas = TextEditingController(text: mascota?.notas ?? '');
    _especie = mascota == null ? Especie.perro : mascota.especieConocida;
    _fechaNacimiento = mascota?.fechaNacimiento;
    _foto = mascota?.fotoUrl;
  }

  @override
  void dispose() {
    _nombre.dispose();
    _raza.dispose();
    _notas.dispose();
    _peso.dispose();
    super.dispose();
  }

  Future<void> _elegirFoto() async {
    // El menú devuelve su propio enum en vez de OrigenFoto porque "quitar" no
    // es un origen, y null ya significa "cerró el menú sin elegir": cerrarlo
    // deslizándolo no debe borrar la foto.
    final accion = await showModalBottomSheet<_AccionFoto>(
      context: context,
      builder: (contexto) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Elegir de la galería'),
              onTap: () => Navigator.of(contexto).pop(_AccionFoto.galeria),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Tomar una foto'),
              onTap: () => Navigator.of(contexto).pop(_AccionFoto.camara),
            ),
            if (_foto != null)
              ListTile(
                leading: const Icon(
                  Icons.delete_outline,
                  color: AppColors.alerta,
                ),
                title: const Text(
                  'Quitar foto',
                  style: TextStyle(color: AppColors.alerta),
                ),
                onTap: () => Navigator.of(contexto).pop(_AccionFoto.quitar),
              ),
          ],
        ),
      ),
    );

    if (!mounted || accion == null) return;

    if (accion == _AccionFoto.quitar) {
      setState(() => _foto = null);
      return;
    }

    try {
      final foto = await _fotos.elegirFoto(
        accion == _AccionFoto.camara ? OrigenFoto.camara : OrigenFoto.galeria,
      );
      if (foto == null || !mounted) return;

      setState(() => _foto = foto);
    } on PhotoException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    }
  }

  Future<void> _elegirFecha() async {
    final hoy = DateTime.now();

    final elegida = await showDatePicker(
      context: context,
      initialDate:
          _fechaNacimiento ?? DateTime(hoy.year - 1, hoy.month, hoy.day),
      // No se puede haber nacido en el futuro, y 30 años cubre de sobra a
      // cualquier perro o gato.
      firstDate: DateTime(hoy.year - 30),
      lastDate: hoy,
      helpText: 'Fecha de nacimiento',
    );

    if (elegida != null && mounted) {
      setState(() => _fechaNacimiento = elegida);
    }
  }

  String? _validar() {
    if (_nombre.text.trim().isEmpty) return 'Escribí el nombre.';

    final pesoTexto = _peso.text.trim().replaceAll(',', '.');
    if (pesoTexto.isNotEmpty) {
      final valor = double.tryParse(pesoTexto);
      if (valor == null) return 'El peso no es un número válido.';
      if (valor <= 0 || valor > 200) {
        return 'El peso tiene que estar entre 0 y 200 kg.';
      }
    }

    return null;
  }

  Future<void> _guardar() async {
    if (_guardando) return;

    final error = _validar();
    if (error != null) {
      setState(() => _error = error);
      return;
    }

    setState(() {
      _guardando = true;
      _error = null;
    });

    try {
      final nombre = _nombre.text.trim();
      final raza = _raza.text.trim();
      final notas = _notas.text.trim();
      final mascota = widget.mascota;

      if (mascota == null) {
        // La foto ya viene codificada, así que se manda en la misma creación:
        // no hace falta crear primero para conocer el id, como sí haría falta
        // si el archivo se subiera a un almacenamiento aparte.
        final creada = await _repositorio.createMascota(
          nombre: nombre,
          especie: _especie.etiqueta,
          raza: raza.isEmpty ? null : raza,
          fechaNacimiento: _fechaNacimiento,
          fotoUrl: _foto,
          notas: notas.isEmpty ? null : notas,
        );

        await _guardarPesoInicial(creada.id);
      } else {
        // Se construye la Mascota a mano en vez de con copyWith porque este
        // formulario tiene que poder VACIAR campos: copyWith usa `?? this.x`,
        // así que un null significaría "no cambies" y quitar la foto o borrar
        // la raza no tendría efecto. Aquí un null es un null.
        await _repositorio.updateMascota(
          Mascota(
            id: mascota.id,
            nombre: nombre,
            especie: _especie.etiqueta,
            raza: raza.isEmpty ? null : raza,
            fechaNacimiento: _fechaNacimiento,
            fotoUrl: _foto,
            notas: notas.isEmpty ? null : notas,
          ),
        );
      }

      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _guardando = false;
        _error = e.toString();
      });
    }
  }

  /// El peso del formulario se guarda como el primer registro del historial,
  /// que es donde vive en el backend (users/{uid}/mascotas/{id}/pesos).
  Future<void> _guardarPesoInicial(String mascotaId) async {
    final pesoTexto = _peso.text.trim().replaceAll(',', '.');
    if (pesoTexto.isEmpty) return;

    final valor = double.tryParse(pesoTexto);
    if (valor == null) return;

    await _repositorio.createPeso(mascotaId, valorKg: valor);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondo,
      appBar: AppBar(
        backgroundColor: AppColors.fondo,
        elevation: 0,
        foregroundColor: AppColors.verdeOscuro,
        title: const Text(
          'PawLife',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 4, 22, 28),
          children: [
            Text(
              _esEdicion ? 'Editar mascota' : 'Agregar mascota',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(
              _esEdicion
                  ? 'Actualizá los datos de ${widget.mascota!.nombre}.'
                  : 'Contanos sobre tu compañero para personalizar sus cuidados.',
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 24),
            Center(child: _buildSelectorFoto()),
            const SizedBox(height: 24),
            _buildTarjetaCampos(),
            if (_error != null) ...[
              const SizedBox(height: 18),
              _BannerError(_error!),
            ],
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _guardando ? null : _guardar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.verdeAcento,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _guardando
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: Colors.white,
                        ),
                      )
                    : Text(
                        _esEdicion ? 'Guardar cambios' : 'Guardar mascota',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _guardando
                    ? null
                    : () => Navigator.of(context).pop(false),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.black87,
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: AppColors.borde),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectorFoto() {
    final imagen = proveedorDeFoto(_foto);

    return GestureDetector(
      onTap: _guardando ? null : _elegirFoto,
      child: Column(
        children: [
          Container(
            width: 104,
            height: 104,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFE6EBF2),
              image: imagen == null
                  ? null
                  : DecorationImage(image: imagen, fit: BoxFit.cover),
            ),
            child: imagen != null
                ? null
                : const Icon(
                    Icons.add_a_photo_outlined,
                    size: 32,
                    color: Colors.black38,
                  ),
          ),
          const SizedBox(height: 8),
          Text(
            imagen == null ? 'Subir foto' : 'Cambiar foto',
            style: const TextStyle(fontSize: 13, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildTarjetaCampos() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Rotulo('Nombre'),
          const SizedBox(height: 8),
          _Campo(controlador: _nombre, pista: 'Ej. Bella'),
          const SizedBox(height: 18),
          const _Rotulo('Especie'),
          const SizedBox(height: 8),
          _buildSelectorEspecie(),
          const SizedBox(height: 18),
          const _Rotulo('Raza'),
          const SizedBox(height: 8),
          _Campo(controlador: _raza, pista: 'Ej. Golden Retriever'),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _Rotulo('Fecha de nacimiento'),
                    const SizedBox(height: 8),
                    _buildCampoFecha(),
                  ],
                ),
              ),
              // El peso solo al crear: en edición se registra desde el detalle,
              // porque cada peso es una entrada del historial y guardar el
              // formulario dos veces dejaría registros duplicados del mismo día.
              if (!_esEdicion) ...[
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _Rotulo('Peso (kg)'),
                      const SizedBox(height: 8),
                      _Campo(
                        controlador: _peso,
                        pista: '0.0',
                        teclado: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        formateadores: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              _Rotulo('Notas'),
              Text(
                'Opcional',
                style: TextStyle(fontSize: 12, color: Colors.black45),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _Campo(
            controlador: _notas,
            pista: 'Alergias, número de microchip, manías...',
            lineas: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildSelectorEspecie() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF3F8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          for (final especie in Especie.values)
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _especie = especie),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 11),
                  decoration: BoxDecoration(
                    color: _especie == especie
                        ? AppColors.verdeOscuro
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (especie != Especie.otra) ...[
                        Icon(
                          especie == Especie.perro
                              ? Icons.pets
                              : Icons.cruelty_free,
                          size: 15,
                          color: _especie == especie
                              ? Colors.white
                              : Colors.black54,
                        ),
                        const SizedBox(width: 6),
                      ],
                      Text(
                        especie.etiqueta,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _especie == especie
                              ? Colors.white
                              : Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCampoFecha() {
    final fecha = _fechaNacimiento;

    return GestureDetector(
      onTap: _guardando ? null : _elegirFecha,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFFBFCFD),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borde),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                fecha == null ? 'dd/mm/aaaa' : _formatearFecha(fecha),
                style: TextStyle(
                  color: fecha == null ? Colors.black38 : Colors.black87,
                ),
              ),
            ),
            const Icon(
              Icons.calendar_today_outlined,
              size: 17,
              color: Colors.black45,
            ),
          ],
        ),
      ),
    );
  }

  /// Se formatea a mano en vez de con `intl` para no depender de un paquete
  /// que hoy solo llega como dependencia transitiva.
  static String _formatearFecha(DateTime fecha) {
    final dia = fecha.day.toString().padLeft(2, '0');
    final mes = fecha.month.toString().padLeft(2, '0');

    return '$dia/$mes/${fecha.year}';
  }
}

class _Rotulo extends StatelessWidget {
  const _Rotulo(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Text(
      texto,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }
}

class _Campo extends StatelessWidget {
  const _Campo({
    required this.controlador,
    required this.pista,
    this.teclado,
    this.lineas = 1,
    this.formateadores,
  });

  final TextEditingController controlador;
  final String pista;
  final TextInputType? teclado;
  final int lineas;
  final List<TextInputFormatter>? formateadores;

  @override
  Widget build(BuildContext context) {
    final borde = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.borde),
    );

    return TextField(
      controller: controlador,
      keyboardType: teclado,
      maxLines: lineas,
      inputFormatters: formateadores,
      textCapitalization: lineas > 1
          ? TextCapitalization.sentences
          : TextCapitalization.words,
      decoration: InputDecoration(
        hintText: pista,
        hintStyle: const TextStyle(color: Colors.black38),
        filled: true,
        fillColor: const Color(0xFFFBFCFD),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 16,
        ),
        border: borde,
        enabledBorder: borde,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: AppColors.verdeOscuro,
            width: 1.4,
          ),
        ),
      ),
    );
  }
}

class _BannerError extends StatelessWidget {
  const _BannerError(this.mensaje);

  final String mensaje;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.alertaSuave,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF5C6C6)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.error_outline, size: 19, color: AppColors.alerta),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              mensaje,
              style: const TextStyle(fontSize: 13, color: Color(0xFF8E2A22)),
            ),
          ),
        ],
      ),
    );
  }
}
