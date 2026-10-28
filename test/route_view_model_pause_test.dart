import 'package:flutter_test/flutter_test.dart';
import 'package:pawlife/viewmodels/route_view_model.dart';

void main() {
  late DateTime ahora;
  late RouteViewModel vm;

  Map<String, Object?> punto(double lat, double lng, DateTime t) => {
    'lat': lat,
    'lng': lng,
    'timestampMillis': t.millisecondsSinceEpoch,
    'accuracy': 5.0,
  };

  void pasar(int segundos) => ahora = ahora.add(Duration(seconds: segundos));

  setUp(() {
    ahora = DateTime(2026, 10, 28, 10);
    vm = RouteViewModel(reloj: () => ahora)..comenzarSesionParaPruebas();
  });

  tearDown(() => vm.dispose());

  test('pausar congela el tiempo y reanudar lo retoma', () {
    pasar(60);
    vm.pauseWalk();
    expect(vm.elapsed, const Duration(seconds: 60));
    pasar(300);
    expect(vm.isPaused, isTrue);
    vm.resumeWalk();
    expect(vm.elapsed, const Duration(seconds: 60));
    pasar(30);
    final sesion = vm.stopWalk();
    expect(sesion.duration, const Duration(seconds: 90));
  });

  test('en pausa no entran puntos ni suma distancia', () {
    vm.recibirPuntoParaPruebas(punto(-34.9000, -56.1600, ahora));
    pasar(20);
    vm.recibirPuntoParaPruebas(punto(-34.9002, -56.1600, ahora));
    final antes = vm.distanceMeters;
    expect(antes, greaterThan(0));
    vm.pauseWalk();
    pasar(20);
    vm.recibirPuntoParaPruebas(punto(-34.9004, -56.1600, ahora));
    expect(vm.distanceMeters, antes);
    expect(vm.routePoints.length, 2);
  });

  test('tras reanudar el primer punto no cuenta el salto de la pausa', () {
    vm.recibirPuntoParaPruebas(punto(-34.9000, -56.1600, ahora));
    pasar(20);
    vm.recibirPuntoParaPruebas(punto(-34.9002, -56.1600, ahora));
    final antes = vm.distanceMeters;
    vm.pauseWalk();
    pasar(600);
    vm.resumeWalk();
    vm.recibirPuntoParaPruebas(punto(-34.9100, -56.1600, ahora));
    expect(vm.distanceMeters, antes);
    expect(vm.routePoints.length, 3);
    pasar(20);
    vm.recibirPuntoParaPruebas(punto(-34.9102, -56.1600, ahora));
    expect(vm.distanceMeters, greaterThan(antes));
  });

  test('terminar estando en pausa conserva el tiempo congelado', () {
    pasar(45);
    vm.pauseWalk();
    pasar(500);
    final sesion = vm.stopWalk();
    expect(sesion.duration, const Duration(seconds: 45));
    expect(vm.isPaused, isFalse);
  });

  test('pausar o reanudar fuera de turno no hace nada', () {
    vm.resumeWalk();
    expect(vm.isPaused, isFalse);
    vm.pauseWalk();
    vm.pauseWalk();
    expect(vm.isPaused, isTrue);
  });
}
