import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../theme/app_colors.dart';
import 'motion.dart';

/// Banner de Home que lleva a la pantalla de Premium. Solo se muestra a quien
/// no tiene Premium. Fondo verde bosque con una huella a medio salir por la
/// derecha: es una invitación, no un aviso de error ni un anuncio.
class BannerPremium extends StatelessWidget {
  const BannerPremium({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Semantics(
      button: true,
      label: '${t.premiumBannerTitle}. ${t.premiumBannerBody}',
      excludeSemantics: true,
      child: Presionable(
        // Mide lo que ocupa su contenido aunque el espacio sea abierto.
        child: IntrinsicHeight(
          child: Material(
            color: Colors.transparent,
            child: Ink(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1B4A3A), AppColors.verdeOscuro],
                ),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(22),
                onTap: onTap,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -14,
                        bottom: -22,
                        child: Transform.rotate(
                          angle: -0.35,
                          child: Icon(
                            Icons.pets,
                            size: 120,
                            color: AppColors.verdeAcento.withValues(
                              alpha: 0.12,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 12, 16),
                        child: Row(
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.verdeAcento.withValues(
                                  alpha: 0.18,
                                ),
                                border: Border.all(
                                  color: AppColors.verdeAcento.withValues(
                                    alpha: 0.5,
                                  ),
                                ),
                              ),
                              child: const Icon(
                                Icons.workspace_premium,
                                color: AppColors.verdeAcento,
                                size: 26,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    t.premiumBannerTitle,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    t.premiumBannerBody,
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.78,
                                      ),
                                      fontSize: 13,
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(
                              Icons.chevron_right_rounded,
                              color: AppColors.verdeAcento,
                              size: 28,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
