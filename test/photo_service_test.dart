import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:pawlife/services/photo_service.dart';

void main() {
  test('PNG se convierte a JPEG real y se reduce conservando proporción', () {
    final source = img.Image(width: 600, height: 300, numChannels: 4);
    img.fill(source, color: img.ColorRgba8(20, 150, 80, 255));
    final jpeg = prepararFotoJpeg(img.encodePng(source));
    expect(jpeg.take(2), [255, 216]);
    final decoded = img.decodeJpg(jpeg)!;
    expect(decoded.width, 256);
    expect(decoded.height, 128);
  });

  test('JPEG elimina metadatos EXIF antes de enviar', () {
    final source = img.Image(width: 12, height: 8);
    source.exif.imageIfd['ImageDescription'] = 'synthetic-private-marker';
    final jpeg = prepararFotoJpeg(img.encodeJpg(source));
    expect(
      String.fromCharCodes(jpeg),
      isNot(contains('synthetic-private-marker')),
    );
    expect(img.decodeJpg(jpeg)!.width, 12);
  });

  test('rechaza bytes falsos y archivos excesivos', () {
    expect(
      () => prepararFotoJpeg(Uint8List.fromList([1, 2, 3])),
      throwsA(isA<PhotoException>()),
    );
    expect(
      () => prepararFotoJpeg(Uint8List(10 * 1024 * 1024 + 1)),
      throwsA(isA<PhotoException>()),
    );
  });

  test('aplica orientación EXIF antes de retirar los metadatos', () {
    final source = img.Image(width: 12, height: 8);
    source.exif.imageIfd['Orientation'] = 6;
    final result = img.decodeJpg(prepararFotoJpeg(img.encodeJpg(source)))!;
    expect(result.width, 8);
    expect(result.height, 12);
  });

  test('rechaza dimensiones desmedidas aunque el PNG ocupe pocos bytes', () {
    final source = img.Image(width: 4097, height: 1);
    expect(
      () => prepararFotoJpeg(img.encodePng(source)),
      throwsA(isA<PhotoException>()),
    );
  });
}
