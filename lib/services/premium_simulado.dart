// services/premium_simulado.dart
//
// Compra de Premium SIMULADA: todavía no hay tienda ni cobro (decisión del
// 28/10/2026). Sirve para probar el recorrido completo de compra. Se guarda
// solo en este dispositivo y por cuenta; el servidor no se entera y no da
// acceso a nada que el servidor proteja.

import 'package:shared_preferences/shared_preferences.dart';

enum PlanPremium { mensual, anual }

class PremiumSimulado {
  PremiumSimulado(this.uid);

  final String uid;

  String get _clave => 'premium_simulado_hasta_$uid';

  Future<DateTime?> vigenteHasta() async {
    final prefs = await SharedPreferences.getInstance();
    final valor = DateTime.tryParse(prefs.getString(_clave) ?? '');
    if (valor == null || valor.isBefore(DateTime.now())) return null;
    return valor;
  }

  Future<DateTime> comprar(PlanPremium plan) async {
    final hasta = DateTime.now().add(
      Duration(days: plan == PlanPremium.anual ? 365 : 30),
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_clave, hasta.toIso8601String());
    return hasta;
  }

  Future<void> cancelar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_clave);
  }
}
