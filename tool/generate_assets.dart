// ignore_for_file: avoid_print
import 'dart:io';
import 'dart:typed_data';

void main() {
  print('Generating local assets for HomeGuardian...');

  // Warm Minimalist Palette colors:
  // Background: #F8F3EC (248, 243, 236)
  // Sand: #E9D8C8 (233, 216, 200)
  // Terracotta: #B96F50 (185, 111, 80)
  // Brown: #87513D (135, 81, 61)
  // Dark Brown: #47352D (71, 53, 45)
  // White: #FFFFFF (255, 255, 255)

  _generateImage(
    'assets/illustrations/home_banner.png',
    width: 600,
    height: 300,
    bgR: 248, bgG: 243, bgB: 236,
    pattern: 'house_banner',
  );

  _generateImage(
    'assets/illustrations/empty_tasks.png',
    width: 320,
    height: 320,
    bgR: 248, bgG: 243, bgB: 236,
    pattern: 'tasks_icon',
  );

  _generateImage(
    'assets/illustrations/empty_appliances.png',
    width: 320,
    height: 320,
    bgR: 248, bgG: 243, bgB: 236,
    pattern: 'appliances_icon',
  );

  _generateImage(
    'assets/illustrations/empty_reminders.png',
    width: 320,
    height: 320,
    bgR: 248, bgG: 243, bgB: 236,
    pattern: 'reminders_icon',
  );

  _generateImage(
    'assets/illustrations/maintenance_service.png',
    width: 320,
    height: 320,
    bgR: 248, bgG: 243, bgB: 236,
    pattern: 'maintenance_icon',
  );

  _generateImage(
    'assets/illustrations/family_household.png',
    width: 320,
    height: 320,
    bgR: 248, bgG: 243, bgB: 236,
    pattern: 'family_icon',
  );

  // Appliances
  _generateImage(
    'assets/images/appliances/refrigerator.png',
    width: 256,
    height: 256,
    bgR: 248, bgG: 243, bgB: 236,
    pattern: 'fridge',
  );

  _generateImage(
    'assets/images/appliances/washing_machine.png',
    width: 256,
    height: 256,
    bgR: 248, bgG: 243, bgB: 236,
    pattern: 'washer',
  );

  _generateImage(
    'assets/images/appliances/air_conditioner.png',
    width: 256,
    height: 256,
    bgR: 248, bgG: 243, bgB: 236,
    pattern: 'ac',
  );

  _generateImage(
    'assets/images/appliances/microwave.png',
    width: 256,
    height: 256,
    bgR: 248, bgG: 243, bgB: 236,
    pattern: 'microwave',
  );

  _generateImage(
    'assets/images/appliances/default_appliance.png',
    width: 256,
    height: 256,
    bgR: 248, bgG: 243, bgB: 236,
    pattern: 'default_gear',
  );

  print('All assets generated successfully!');
}

void _generateImage(
  String path, {
  required int width,
  required int height,
  required int bgR,
  required int bgG,
  required int bgB,
  required String pattern,
}) {
  final rawData = Uint8List(height * (1 + width * 4));
  var offset = 0;

  for (var y = 0; y < height; y++) {
    rawData[offset++] = 0; // Filter: None
    for (var x = 0; x < width; x++) {
      int r = bgR;
      int g = bgG;
      int b = bgB;
      int a = 255;

      // Draw rounded decorative container in center
      final cx = width / 2;
      final cy = height / 2;
      final dx = x - cx;
      final dy = y - cy;
      final distSq = dx * dx + dy * dy;

      if (pattern == 'house_banner') {
        // Warm gradient banner with subtle hills and a house silhouette
        final sunDx = x - (width * 0.75);
        final sunDy = y - (height * 0.35);
        if (sunDx * sunDx + sunDy * sunDy < 45 * 45) {
          // Warm Terracotta Sun
          r = 185; g = 111; b = 80;
        } else if (y > height * 0.7) {
          // Sand ground
          r = 233; g = 216; b = 200;
        } else if (x > width * 0.25 && x < width * 0.55 && y > height * 0.4 && y <= height * 0.7) {
          // House body
          r = 255; g = 255; b = 255;
          // Windows and door
          if ((x > width * 0.32 && x < width * 0.38 && y > height * 0.48 && y < height * 0.58) ||
              (x > width * 0.42 && x < width * 0.48 && y > height * 0.48 && y < height * 0.58)) {
            r = 185; g = 111; b = 80; // Terracotta window
          } else if (x > width * 0.37 && x < width * 0.43 && y > height * 0.58 && y <= height * 0.7) {
            r = 135; g = 81; b = 61; // Brown door
          }
        } else if (x >= width * 0.22 && x <= width * 0.58 && y <= height * 0.4 && y >= height * 0.22) {
          // Triangular roof approximation
          final roofHeight = height * 0.4 - y;
          final roofHalfWidth = (width * 0.58 - width * 0.22) / 2;
          final normalizedDist = (x - (width * 0.4)).abs();
          if (normalizedDist <= roofHalfWidth * (1.0 - (roofHeight / (height * 0.18)))) {
            r = 185; g = 111; b = 80; // Roof terracotta
          }
        }
      } else {
        // Circular decorative container
        final radius = width * 0.4;
        if (distSq < radius * radius) {
          r = 233; g = 216; b = 200; // Sand circle background
          final innerRadius = radius * 0.88;
          if (distSq < innerRadius * innerRadius) {
            r = 255; g = 255; b = 255; // White inner card
          }

          // Center icons
          if (pattern == 'fridge') {
            if (dx.abs() < width * 0.18 && dy > -height * 0.25 && dy < height * 0.25) {
              r = 185; g = 111; b = 80; // Fridge body
              // Split door line
              if (dy.abs() < 2 || (dx > -width * 0.14 && dx < -width * 0.11)) {
                r = 255; g = 255; b = 255; // Door seam & handle
              }
            }
          } else if (pattern == 'washer') {
            if (dx.abs() < width * 0.2 && dy.abs() < height * 0.2) {
              r = 135; g = 81; b = 61; // Washer frame
              if (distSq < (width * 0.12) * (width * 0.12)) {
                r = 185; g = 111; b = 80; // Porthole
                if (distSq < (width * 0.08) * (width * 0.08)) {
                  r = 248; g = 243; b = 236; // Inner drum
                }
              }
            }
          } else if (pattern == 'ac') {
            if (dx.abs() < width * 0.26 && dy > -height * 0.12 && dy < height * 0.12) {
              r = 185; g = 111; b = 80;
              if (dy > height * 0.03 && dy < height * 0.06 && dx.abs() < width * 0.22) {
                r = 248; g = 243; b = 236; // Louver grill
              }
            }
          } else if (pattern == 'microwave') {
            if (dx.abs() < width * 0.24 && dy.abs() < height * 0.15) {
              r = 135; g = 81; b = 61;
              if (dx < width * 0.08 && dx > -width * 0.2 && dy.abs() < height * 0.1) {
                r = 248; g = 243; b = 236; // Glass window
              }
            }
          } else if (pattern == 'tasks_icon') {
            if (dx.abs() < width * 0.18 && dy.abs() < height * 0.22) {
              r = 185; g = 111; b = 80;
              if (dx.abs() < width * 0.14 && dy > -height * 0.15 && dy < height * 0.18) {
                r = 255; g = 255; b = 255; // Paper
                if (dy.toInt() % 14 < 4 && dx > -width * 0.08 && dx < width * 0.08) {
                  r = 135; g = 81; b = 61; // Lines
                }
              }
            }
          } else if (pattern == 'reminders_icon') {
            // Bell shape
            if (distSq < (width * 0.16) * (width * 0.16) && dy < height * 0.1) {
              r = 185; g = 111; b = 80;
            }
            if (dy > height * 0.1 && dy < height * 0.16 && dx.abs() < width * 0.06) {
              r = 135; g = 81; b = 61; // Bell clapper
            }
          } else if (pattern == 'maintenance_icon') {
            // Crossed tools
            if ((dx - dy).abs() < width * 0.04 && distSq < (width * 0.22) * (width * 0.22)) {
              r = 185; g = 111; b = 80;
            } else if ((dx + dy).abs() < width * 0.04 && distSq < (width * 0.22) * (width * 0.22)) {
              r = 135; g = 81; b = 61;
            }
          } else {
            // Default gear / circle
            if (distSq < (width * 0.18) * (width * 0.18)) {
              r = 185; g = 111; b = 80;
              if (distSq < (width * 0.08) * (width * 0.08)) {
                r = 255; g = 255; b = 255;
              }
            }
          }
        }
      }

      rawData[offset++] = r;
      rawData[offset++] = g;
      rawData[offset++] = b;
      rawData[offset++] = a;
    }
  }

  final pngBytes = _encodePng(width, height, rawData);
  File(path).writeAsBytesSync(pngBytes);
  print('Generated: $path (${pngBytes.length} bytes)');
}

Uint8List _encodePng(int width, int height, Uint8List rawData) {
  final compressed = zlib.encode(rawData);

  final builder = BytesBuilder();
  // PNG signature
  builder.add([0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A]);

  // IHDR chunk
  final ihdr = ByteData(13);
  ihdr.setUint32(0, width, Endian.big);
  ihdr.setUint32(4, height, Endian.big);
  ihdr.setUint8(8, 8); // bit depth
  ihdr.setUint8(9, 6); // color type RGBA
  ihdr.setUint8(10, 0); // compression
  ihdr.setUint8(11, 0); // filter
  ihdr.setUint8(12, 0); // interlace
  _writeChunk(builder, 'IHDR', ihdr.buffer.asUint8List());

  // IDAT chunk
  _writeChunk(builder, 'IDAT', Uint8List.fromList(compressed));

  // IEND chunk
  _writeChunk(builder, 'IEND', Uint8List(0));

  return builder.toBytes();
}

void _writeChunk(BytesBuilder builder, String type, Uint8List data) {
  final len = ByteData(4)..setUint32(0, data.length, Endian.big);
  builder.add(len.buffer.asUint8List());

  final typeBytes = type.codeUnits;
  builder.add(typeBytes);
  builder.add(data);

  final crcData = Uint8List(typeBytes.length + data.length);
  crcData.setRange(0, typeBytes.length, typeBytes);
  crcData.setRange(typeBytes.length, crcData.length, data);

  final crcVal = _crc32(crcData);
  final crcBytes = ByteData(4)..setUint32(0, crcVal, Endian.big);
  builder.add(crcBytes.buffer.asUint8List());
}

int _crc32(Uint8List data) {
  var crc = 0xFFFFFFFF;
  for (var byte in data) {
    crc ^= byte;
    for (var i = 0; i < 8; i++) {
      if ((crc & 1) != 0) {
        crc = (crc >> 1) ^ 0xEDB88320;
      } else {
        crc = crc >> 1;
      }
    }
  }
  return crc ^ 0xFFFFFFFF;
}
