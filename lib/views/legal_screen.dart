import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../theme/app_palette.dart';

enum LegalDoc { terms, privacy }

/// Términos de uso o política de privacidad, como texto simple y legible.
class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key, required this.doc});

  final LegalDoc doc;

  static void abrir(BuildContext context, LegalDoc doc) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => LegalScreen(doc: doc)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final terms = doc == LegalDoc.terms;
    final secciones = terms
        ? [
            (t.legalTerms1T, t.legalTerms1B),
            (t.legalTerms2T, t.legalTerms2B),
            (t.legalTerms3T, t.legalTerms3B),
            (t.legalTerms4T, t.legalTerms4B),
            (t.legalTerms5T, t.legalTerms5B),
          ]
        : [
            (t.legalPriv1T, t.legalPriv1B),
            (t.legalPriv2T, t.legalPriv2B),
            (t.legalPriv3T, t.legalPriv3B),
            (t.legalPriv4T, t.legalPriv4B),
            (t.legalPriv5T, t.legalPriv5B),
            (t.legalPriv6T, t.legalPriv6B),
            (t.legalPriv7T, t.legalPriv7B),
            (t.legalPriv8T, t.legalPriv8B),
          ];
    final theme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: context.fondoPantalla,
      appBar: AppBar(
        title: Text(terms ? t.legalTermsTitle : t.legalPrivacyTitle),
        backgroundColor: context.fondoPantalla,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Text(
            t.legalUpdated,
            style: theme.bodySmall?.copyWith(color: context.textoTenue),
          ),
          for (final (titulo, cuerpo) in secciones) ...[
            const SizedBox(height: 22),
            Text(titulo, style: theme.titleMedium),
            const SizedBox(height: 6),
            Text(cuerpo, style: theme.bodyMedium?.copyWith(height: 1.45)),
          ],
        ],
      ),
    );
  }
}
