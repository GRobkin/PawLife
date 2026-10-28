import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../l10n/error_messages.dart';
import '../l10n/formatting.dart';
import '../services/api_client.dart';
import '../services/pawlife_repository.dart';
import '../theme/app_palette.dart';

/// Estado de Premium de la cuenta. Es solo de lectura: el servidor decide si
/// está activo y hasta cuándo; no hay compras dentro de la app todavía.
class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key, this.repository});

  final PawLifeRepository? repository;

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  late final _repo = widget.repository ?? PawLifeRepository();
  Map<String, dynamic>? _state;
  String? _error;

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
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = apiErrorText(t, e));
    } catch (_) {
      if (mounted) setState(() => _error = t.premiumLoadError);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = _state;
    final active = state?['activo'] == true;
    final until = DateTime.tryParse('${state?['venceEn'] ?? ''}')?.toLocal();
    final sources = state?['fuentes'];
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
          : state == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: context.superficie,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        active ? Icons.workspace_premium : Icons.lock_outline,
                        size: 32,
                        color: active ? context.marca : context.textoTenue,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        active && until != null
                            ? t.premiumActiveUntil(
                                formatDateTime(context, until),
                              )
                            : t.premiumInactive,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      if (active && sources is Map) ...[
                        const SizedBox(height: 8),
                        if (sources['manual'] == true)
                          Text(
                            t.premiumSourceManual,
                            style: TextStyle(color: context.textoSuave),
                          ),
                        if (sources['pago'] == true)
                          Text(
                            t.premiumSourcePaid,
                            style: TextStyle(color: context.textoSuave),
                          ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  t.premiumNoPurchases,
                  style: TextStyle(color: context.textoSuave),
                ),
              ],
            ),
    );
  }
}
