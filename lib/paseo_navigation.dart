import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'viewmodel/paseo_viewmodel.dart';
import 'view/screens/paseo_screen.dart';

void abrirPaseo(BuildContext context, String mascotaId) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => ChangeNotifierProvider(
        create: (_) => PaseoViewModel(mascotaId: mascotaId),
        child: PaseoScreen(mascotaId: mascotaId),
      ),
    ),
  );
}
