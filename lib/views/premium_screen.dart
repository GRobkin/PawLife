import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/app_localizations.dart';
import '../l10n/error_messages.dart';
import '../l10n/formatting.dart';
import '../models/pawlife_models.dart';
import '../services/api_client.dart';
import '../services/pawlife_repository.dart';
import '../services/plan_premium.dart';
import '../theme/app_palette.dart';
import 'widgets/motion.dart';
import 'widgets/esqueletos.dart';

/// Premium: qué incluye, los planes y la compra. El servidor dice si hay un
/// Premium real (concedido por el equipo); la compra de esta pantalla es
/// SIMULADA, se guarda solo en el dispositivo y no cobra nada.
class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key, this.repository});

  final PawLifeRepository? repository;

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

/// Precios de muestra: todavía no hay precios ni tienda decididos.
const _precioMensual = 'USD 2.99';
const _precioAnual = 'USD 23.99';

class _PremiumScreenState extends State<PremiumScreen> {
  late final _repo = widget.repository ?? PawLifeRepository();
  Map<String, dynamic>? _state;
  ({int mascotas, int tareas})? _uso;
  String? _error;
  PlanPremium _plan = PlanPremium.anual;

  AppLocalizations get t => AppLocalizations.of(context);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _error = null);
    try {
      final state = await _repo.fetchPremium();
      if (mounted) setState(() => _state = state);
      // El uso es informativo: si falla, simplemente no se muestra.
      if (state['activo'] != true) _cargarUso();
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = apiErrorText(t, e));
    } catch (_) {
      if (mounted) setState(() => _error = t.premiumLoadError);
    }
  }

  Future<void> _cargarUso() async {
    try {
      final resultados = await Future.wait<Object?>([
        _repo.fetchMascotas(),
        _repo.fetchRecordatorios(soloPendientes: true),
      ]);
      final mascotas = (resultados[0] as List).length;
      final tareas = (resultados[1] as List<Recordatorio>)
          .where((r) => r.tipo == 'tarea')
          .length;
      if (mounted) setState(() => _uso = (mascotas: mascotas, tareas: tareas));
    } catch (_) {}
  }

  Future<void> _comprar() async {
    final estado = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => _HojaCompra(plan: _plan, repo: _repo),
    );
    if (estado == null || !mounted) return;
    setState(() => _state = estado);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(t.premiumSuccess)));
  }

  Future<void> _cancelarPrueba() async {
    try {
      await _repo.cancelarPremiumDePrueba();
      await _load();
    } on ApiException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(apiErrorText(t, e))));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = _state;
    return Scaffold(
      appBar: AppBar(title: Text(t.premiumTitle)),
      body: _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_error!, textAlign: TextAlign.center),
                    TextButton(onPressed: _load, child: Text(t.retry)),
                  ],
                ),
              ),
            )
          : TransicionCarga(
              child: state == null
                  ? const EsqueletoPremium(key: ValueKey('cargando'))
                  : _contenido(state),
            ),
    );
  }

  Widget _contenido(Map<String, dynamic> state) {
    final fuentes = state['fuentes'];
    final activo = state['activo'] == true;
    final hasta = DateTime.tryParse('${state['venceEn'] ?? ''}')?.toLocal();
    final soloPrueba =
        activo &&
        fuentes is Map &&
        fuentes['prueba'] == true &&
        fuentes['manual'] != true &&
        fuentes['pago'] != true;
    return Center(
      key: const ValueKey('premium'),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            AparecerAlEntrar(
              child: _Cabecera(
                activo: activo,
                titulo: activo && hasta != null
                    ? (soloPrueba
                          ? t.premiumSimulatedActive(
                              formatDateTime(context, hasta),
                            )
                          : t.premiumActiveUntil(
                              formatDateTime(context, hasta),
                            ))
                    : t.premiumHeadline,
                detalle: activo && fuentes is Map && !soloPrueba
                    ? [
                        if (fuentes['manual'] == true) t.premiumSourceManual,
                        if (fuentes['pago'] == true) t.premiumSourcePaid,
                      ].join(' · ')
                    : null,
                prueba: soloPrueba,
                textoPrueba: t.premiumTestBadge,
              ),
            ),
            const SizedBox(height: 26),
            Text(
              t.premiumBenefitsTitle,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            // Solo lo que de verdad cambia entre los planes.
            AparecerAlEntrar(
              indice: 1,
              child: _TablaPlanes(
                gratis: t.premiumCompareFree,
                premium: t.premiumComparePremium,
                filas: [
                  (
                    Icons.pets,
                    t.premiumRowPets,
                    t.premiumRowPetsFree,
                    t.premiumRowPetsPremium,
                  ),
                  (
                    Icons.checklist_rtl,
                    t.premiumRowTasks,
                    t.premiumRowTasksFree,
                    t.premiumRowTasksPremium,
                  ),
                  (
                    Icons.style_outlined,
                    t.premiumRowCards,
                    t.premiumRowCardsFree,
                    t.premiumRowCardsPremium,
                  ),
                ],
              ),
            ),
            if (!activo && _uso != null) ...[
              const SizedBox(height: 16),
              AparecerAlEntrar(
                indice: 2,
                child: _MedidorUso(
                  titulo: t.premiumUsageTitle,
                  filas: [
                    (t.premiumUsagePets, _uso!.mascotas, 2),
                    (t.premiumUsageTasks, _uso!.tareas, 5),
                  ],
                ),
              ),
            ],
            if (!activo) ...[
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: _TarjetaPlan(
                      nombre: t.premiumPlanMonthly,
                      precio: _precioMensual,
                      periodo: t.premiumPerMonth,
                      elegido: _plan == PlanPremium.mensual,
                      onTap: () => setState(() => _plan = PlanPremium.mensual),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _TarjetaPlan(
                      nombre: t.premiumPlanYearly,
                      precio: _precioAnual,
                      periodo: t.premiumPerYear,
                      etiqueta: t.premiumSave,
                      elegido: _plan == PlanPremium.anual,
                      onTap: () => setState(() => _plan = PlanPremium.anual),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Presionable(
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _comprar,
                    style: FilledButton.styleFrom(
                      backgroundColor: context.botonFondo,
                      foregroundColor: context.botonTexto,
                      padding: const EdgeInsets.symmetric(vertical: 17),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      t.premiumSubscribe,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
            ],
            if (soloPrueba) ...[
              const SizedBox(height: 12),
              Center(
                child: TextButton(
                  onPressed: _cancelarPrueba,
                  child: Text(t.premiumCancelSimulated),
                ),
              ),
            ],
            const SizedBox(height: 14),
            Text(
              t.premiumNoPurchases,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: context.textoTenue),
            ),
          ],
        ),
      ),
    );
  }
}

/// Comparación lado a lado de lo que cambia entre el plan gratuito y Premium.
class _TablaPlanes extends StatelessWidget {
  const _TablaPlanes({
    required this.gratis,
    required this.premium,
    required this.filas,
  });

  final String gratis;
  final String premium;
  final List<(IconData, String, String, String)> filas;

  @override
  Widget build(BuildContext context) {
    TextStyle cab(Color c) =>
        TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: c);
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
      decoration: BoxDecoration(
        color: context.superficie,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Expanded(flex: 5, child: SizedBox.shrink()),
              Expanded(
                flex: 3,
                child: Text(
                  gratis,
                  textAlign: TextAlign.center,
                  style: cab(context.textoSuave),
                ),
              ),
              Expanded(
                flex: 3,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: context.mentaSuave,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    premium,
                    textAlign: TextAlign.center,
                    style: cab(context.marca),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          for (final f in filas) ...[
            Divider(height: 1, color: context.bordeSuave),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: Row(
                      children: [
                        Icon(f.$1, size: 18, color: context.marca),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            f.$2,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: context.texto,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      f.$3,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: context.textoSuave),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text(
                      f.$4,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: context.marca,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Cabecera extends StatelessWidget {
  const _Cabecera({
    required this.activo,
    required this.titulo,
    required this.prueba,
    required this.textoPrueba,
    this.detalle,
  });

  final bool activo;
  final String titulo;
  final String? detalle;
  final bool prueba;
  final String textoPrueba;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 24),
      decoration: BoxDecoration(
        color: context.botonFondo,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: context.botonTexto.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  activo ? Icons.workspace_premium : Icons.auto_awesome,
                  color: context.botonTexto,
                ),
              ),
              const Spacer(),
              if (prueba)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: context.botonTexto.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    textoPrueba,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: context.botonTexto,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'PawLife Premium',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w900,
              letterSpacing: -1,
              height: 1,
              color: context.botonTexto,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            titulo,
            style: TextStyle(
              fontSize: 15,
              height: 1.35,
              color: context.botonTexto.withValues(alpha: 0.85),
            ),
          ),
          if (detalle != null && detalle!.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              detalle!,
              style: TextStyle(
                fontSize: 13,
                color: context.botonTexto.withValues(alpha: 0.7),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TarjetaPlan extends StatelessWidget {
  const _TarjetaPlan({
    required this.nombre,
    required this.precio,
    required this.periodo,
    required this.elegido,
    required this.onTap,
    this.etiqueta,
  });

  final String nombre;
  final String precio;
  final String periodo;
  final String? etiqueta;
  final bool elegido;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: elegido,
      button: true,
      child: Presionable(
        child: AnimatedContainer(
          duration: reducirMovimiento(context)
              ? Duration.zero
              : const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            color: elegido ? context.mentaSuave : context.superficie,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: elegido ? context.marca : context.bordeSuave,
              width: elegido ? 2 : 1,
            ),
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            nombre,
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: context.texto,
                            ),
                          ),
                        ),
                        Icon(
                          elegido
                              ? Icons.radio_button_checked
                              : Icons.radio_button_off,
                          size: 20,
                          color: elegido ? context.marca : context.textoTenue,
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: precio,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                color: context.texto,
                              ),
                            ),
                            TextSpan(
                              text: periodo,
                              style: TextStyle(
                                fontSize: 13,
                                color: context.textoSuave,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (etiqueta != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: context.botonFondo,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          etiqueta!,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: context.botonTexto,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Hoja de confirmación al estilo de la tienda, pero simulada.
class _HojaCompra extends StatefulWidget {
  const _HojaCompra({required this.plan, required this.repo});

  final PlanPremium plan;
  final PawLifeRepository repo;

  @override
  State<_HojaCompra> createState() => _HojaCompraState();
}

class _HojaCompraState extends State<_HojaCompra> {
  bool _procesando = false;
  String? _error;

  Future<void> _confirmar() async {
    setState(() {
      _procesando = true;
      _error = null;
    });
    try {
      // Una pausa breve, como haría la tienda, para que el recorrido se
      // sienta real al probarlo.
      final estado = await widget.repo.comprarPremiumDePrueba(
        widget.plan == PlanPremium.anual ? 'anual' : 'mensual',
      );
      HapticFeedback.mediumImpact();
      if (mounted) Navigator.pop(context, estado);
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _procesando = false;
          _error = apiErrorText(AppLocalizations.of(context), e);
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _procesando = false;
          _error = AppLocalizations.of(context).premiumPurchaseError;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final anual = widget.plan == PlanPremium.anual;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.premiumConfirmTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.relleno,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(Icons.workspace_premium, color: context.marca),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'PawLife Premium · '
                      '${anual ? t.premiumPlanYearly : t.premiumPlanMonthly}',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  Text(
                    anual
                        ? '$_precioAnual${t.premiumPerYear}'
                        : '$_precioMensual${t.premiumPerMonth}',
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              t.premiumNoPurchases,
              style: TextStyle(fontSize: 12, color: context.textoTenue),
            ),
            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _procesando ? null : _confirmar,
                style: FilledButton.styleFrom(
                  backgroundColor: context.botonFondo,
                  foregroundColor: context.botonTexto,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _procesando
                    ? SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: context.botonTexto,
                        ),
                      )
                    : Text(
                        t.premiumConfirm,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Cuánto del plan gratuito se está usando: barras que se llenan al límite.
class _MedidorUso extends StatelessWidget {
  const _MedidorUso({required this.titulo, required this.filas});

  final String titulo;
  final List<(String, int, int)> filas;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.superficie,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: context.textoSuave,
            ),
          ),
          const SizedBox(height: 12),
          for (final f in filas) ...[
            Row(
              children: [
                Expanded(
                  child: Text(
                    f.$1,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: context.texto,
                    ),
                  ),
                ),
                Text(
                  '${f.$2} / ${f.$3}',
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    color: f.$2 >= f.$3 ? context.alertaTexto : context.marca,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: (f.$2 / f.$3).clamp(0.0, 1.0)),
                duration: reducirMovimiento(context)
                    ? Duration.zero
                    : const Duration(milliseconds: 700),
                curve: Curves.easeOutCubic,
                builder: (_, v, _) => LinearProgressIndicator(
                  value: v,
                  minHeight: 8,
                  backgroundColor: context.mentaSuave,
                  color: f.$2 >= f.$3 ? context.alertaTexto : context.marca,
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}
