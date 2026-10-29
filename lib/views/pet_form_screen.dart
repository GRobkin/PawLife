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
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../l10n/app_localizations.dart';
import '../l10n/error_messages.dart';
import '../l10n/formatting.dart';
import '../models/pawlife_models.dart';
import '../services/api_client.dart';
import '../services/pawlife_repository.dart';
import '../services/photo_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_palette.dart';
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
    final t = AppLocalizations.of(context);
    final accion = await showModalBottomSheet<_AccionFoto>(
      context: context,
      builder: (contexto) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: Text(t.pickFromGallery),
              onTap: () => Navigator.of(contexto).pop(_AccionFoto.galeria),
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: Text(t.takePhoto),
              onTap: () => Navigator.of(contexto).pop(_AccionFoto.camara),
            ),
            if (_foto != null)
              ListTile(
                leading: Icon(Icons.delete_outline, color: context.alertaTexto),
                title: Text(
                  t.removePhoto,
                  style: TextStyle(color: context.alertaTexto),
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
      setState(() => _error = photoErrorText(t, e));
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
      helpText: AppLocalizations.of(context).birthDate,
    );

    if (elegida != null && mounted) {
      setState(() => _fechaNacimiento = elegida);
    }
  }

  String? _validar() {
    final t = AppLocalizations.of(context);
    if (_nombre.text.trim().isEmpty) return t.errEnterPetName;

    final pesoTexto = _peso.text.trim().replaceAll(',', '.');
    if (pesoTexto.isNotEmpty) {
      final valor = double.tryParse(pesoTexto);
      if (valor == null) return t.errWeightInvalid;
      if (valor <= 0 || valor > 200) {
        return t.errWeightRange;
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
        // Los errores del servidor (p. ej. el tope del plan gratuito) se
        // muestran traducidos, no como texto crudo.
        _error = e is ApiException
            ? apiErrorText(AppLocalizations.of(context), e)
            : e.toString();
      });
    }
  }

  /// El peso del formulario se guarda como el primer registro del historial,
  /// asociado a la mascota mediante mascotaId en el backend.
  Future<void> _guardarPesoInicial(String mascotaId) async {
    final pesoTexto = _peso.text.trim().replaceAll(',', '.');
    if (pesoTexto.isEmpty) return;

    final valor = double.tryParse(pesoTexto);
    if (valor == null) return;

    await _repositorio.createPeso(mascotaId, valorKg: valor);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: context.fondoPantalla,
      appBar: AppBar(
        backgroundColor: context.fondoPantalla,
        elevation: 0,
        foregroundColor: context.marca,
        title: Text('PawLife', style: Theme.of(context).textTheme.titleLarge),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 4, 22, 28),
          children: [
            Text(
              _esEdicion ? t.editPet : t.addPet,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 6),
            Text(
              _esEdicion
                  ? t.editPetSubtitle(widget.mascota!.nombre)
                  : t.addPetSubtitle,
              style: TextStyle(fontSize: 14, color: context.textoSuave),
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
                  foregroundColor: context.sobreAcento,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _guardando
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: context.sobreAcento,
                        ),
                      )
                    : Text(
                        _esEdicion ? t.profileSave : t.savePet,
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
                  foregroundColor: context.texto,
                  backgroundColor: context.superficie,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: context.bordeSuave),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  t.cancel,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectorFoto() {
    final t = AppLocalizations.of(context);
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
              color: context.relleno,
              image: imagen == null
                  ? null
                  : DecorationImage(image: imagen, fit: BoxFit.cover),
            ),
            child: imagen != null
                ? null
                : Icon(
                    Icons.add_a_photo_outlined,
                    size: 32,
                    color: context.textoTenue,
                  ),
          ),
          const SizedBox(height: 8),
          Text(
            imagen == null ? t.uploadPhoto : t.changePhoto,
            style: TextStyle(fontSize: 13, color: context.textoSuave),
          ),
        ],
      ),
    );
  }

  Widget _buildTarjetaCampos() {
    final t = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: context.superficie,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Rotulo(t.nameLabel),
          const SizedBox(height: 8),
          _Campo(controlador: _nombre, pista: t.nameHint),
          const SizedBox(height: 18),
          _Rotulo(t.speciesLabel),
          const SizedBox(height: 8),
          _buildSelectorEspecie(),
          const SizedBox(height: 18),
          _Rotulo(t.breedLabel),
          const SizedBox(height: 8),
          _Campo(controlador: _raza, pista: t.breedHint),
          const SizedBox(height: 18),
          // Etiquetas y campos van en DOS filas, no en dos columnas de una
          // etiqueta más su campo.
          //
          // Puestos en columnas, "Fecha de nacimiento" se parte en dos líneas
          // y "Peso (kg)" no, así que cada campo arrancaba a una altura
          // distinta y se veían escalonados. Separándolos, la fila de
          // etiquetas toma la altura de la más alta y los dos campos quedan
          // alineados sea cual sea el largo del texto o la escala de fuente
          // del teléfono.
          Row(
            children: [
              Expanded(child: _Rotulo(t.birthDate)),
              // El peso solo al crear: en edición se registra desde el detalle,
              // porque cada peso es una entrada del historial y guardar el
              // formulario dos veces dejaría registros duplicados del mismo día.
              if (!_esEdicion) ...[
                const SizedBox(width: 14),
                Expanded(child: _Rotulo(t.weightKgLabel)),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _buildCampoFecha()),
              if (!_esEdicion) ...[
                const SizedBox(width: 14),
                Expanded(
                  child: _Campo(
                    controlador: _peso,
                    pista: '0.0',
                    teclado: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    formateadores: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                    ],
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 18),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _Rotulo(t.notesLabel),
              Text(
                t.optional,
                style: TextStyle(fontSize: 12, color: context.textoTenue),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _Campo(controlador: _notas, pista: t.notesHint, lineas: 3),
        ],
      ),
    );
  }

  Widget _buildSelectorEspecie() {
    final t = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: context.relleno,
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
                        ? context.botonFondo
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FaIcon(
                        _iconoDe(especie),
                        size: 14,
                        color: _especie == especie
                            ? context.botonTexto
                            : context.textoSuave,
                      ),
                      const SizedBox(width: 7),
                      Text(
                        switch (especie) {
                          Especie.perro => t.speciesDog,
                          Especie.gato => t.speciesCat,
                          Especie.otra => t.speciesOther,
                        },
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _especie == especie
                              ? context.botonTexto
                              : context.textoSuave,
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

  /// Material Icons no tiene gato ni perro: lo más cercano es `cruelty_free`,
  /// que es un conejo. De ahí la dependencia de Font Awesome solo para esto.
  static FaIconData _iconoDe(Especie especie) => switch (especie) {
    Especie.perro => FontAwesomeIcons.dog,
    Especie.gato => FontAwesomeIcons.cat,
    Especie.otra => FontAwesomeIcons.paw,
  };

  Widget _buildCampoFecha() {
    final fecha = _fechaNacimiento;

    return GestureDetector(
      onTap: _guardando ? null : _elegirFecha,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: context.campo,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.bordeSuave),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                fecha == null
                    ? AppLocalizations.of(context).datePlaceholder
                    : formatDate(context, fecha),
                style: TextStyle(
                  color: fecha == null ? context.textoTenue : context.texto,
                ),
              ),
            ),
            Icon(
              Icons.calendar_today_outlined,
              size: 17,
              color: context.textoTenue,
            ),
          ],
        ),
      ),
    );
  }
}

class _Rotulo extends StatelessWidget {
  const _Rotulo(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) {
    return Text(
      texto,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: context.texto,
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
      borderSide: BorderSide(color: context.bordeSuave),
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
        hintStyle: TextStyle(color: context.textoTenue),
        filled: true,
        fillColor: context.campo,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 16,
        ),
        border: borde,
        enabledBorder: borde,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: context.marca, width: 1.4),
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
        color: context.errorFondo,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.errorBorde),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, size: 19, color: context.errorIcono),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              mensaje,
              style: TextStyle(fontSize: 13, color: context.errorTexto),
            ),
          ),
        ],
      ),
    );
  }
}
