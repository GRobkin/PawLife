import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../models/route_point.dart';
import '../../theme/app_colors.dart';

/// Traza sin calles ni coordenadas: sirve también sin conexión y en el PNG.
class WalkRouteTrace extends StatelessWidget {
  const WalkRouteTrace({
    super.key,
    required this.points,
    this.startColor = AppColors.verdeOscuro,
  });

  final List<RoutePoint> points;

  /// Color del punto de inicio. En superficies oscuras hay que aclararlo.
  final Color startColor;

  @override
  Widget build(BuildContext context) => Semantics(
    label: points.isEmpty ? 'Sin ruta GPS' : 'Traza del recorrido',
    child: CustomPaint(
      painter: WalkRoutePainter(points, startColor: startColor),
      child: points.isEmpty
          ? const Center(child: Icon(Icons.location_off_outlined, size: 36))
          : null,
    ),
  );
}

class WalkRoutePainter extends CustomPainter {
  WalkRoutePainter(this.points, {this.startColor = AppColors.verdeOscuro});
  final List<RoutePoint> points;
  final Color startColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty || size.shortestSide <= 24) return;
    // Mercator conserva la forma local. Se desenvuelve la longitud para rutas
    // que cruzan el meridiano 180° y se limita la latitud cerca de los polos.
    final projected = <Offset>[];
    double? previousX;
    for (final point in points) {
      var x = point.longitude * math.pi / 180;
      if (previousX != null) {
        while (x - previousX > math.pi) {
          x -= 2 * math.pi;
        }
        while (x - previousX < -math.pi) {
          x += 2 * math.pi;
        }
      }
      previousX = x;
      final lat = point.latitude.clamp(-85.0, 85.0) * math.pi / 180;
      projected.add(Offset(x, -math.log(math.tan(math.pi / 4 + lat / 2))));
    }
    final minX = projected.map((p) => p.dx).reduce(math.min);
    final maxX = projected.map((p) => p.dx).reduce(math.max);
    final minY = projected.map((p) => p.dy).reduce(math.min);
    final maxY = projected.map((p) => p.dy).reduce(math.max);
    final spanX = math.max(maxX - minX, 0.000001);
    final spanY = math.max(maxY - minY, 0.000001);
    final scale = math.min(
      (size.width - 40) / spanX,
      (size.height - 40) / spanY,
    );
    final center = Offset((minX + maxX) / 2, (minY + maxY) / 2);
    final offsets = projected
        .map((p) => (p - center) * scale + size.center(Offset.zero))
        .toList();
    final path = Path()..moveTo(offsets.first.dx, offsets.first.dy);
    for (final p in offsets.skip(1)) {
      path.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.verdeAcento
        ..strokeWidth = 6
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke,
    );
    canvas.drawCircle(offsets.first, 8, Paint()..color = startColor);
    if (offsets.length > 1) {
      canvas.drawCircle(offsets.last, 8, Paint()..color = AppColors.alerta);
      canvas.drawCircle(offsets.last, 3, Paint()..color = Colors.white);
    }
  }

  @override
  bool shouldRepaint(WalkRoutePainter oldDelegate) =>
      oldDelegate.points != points || oldDelegate.startColor != startColor;
}
