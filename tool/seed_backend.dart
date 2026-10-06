import 'dart:convert';
import 'dart:io';

/// Minimal development API for the vehicle catalogue.
///
/// The app expects `GET /vehicles` to answer with a JSON envelope the
/// ProductRemoteDatasource understands ({"products": [...]}, {"data": [...]}
/// or a bare array) using the fields `id`, `title`, `price`, `thumbnail`.
///
/// Run it with:
///
///     dart run tool/seed_backend.dart
///
/// It binds 0.0.0.0 (not loopback) so a phone on the same Wi-Fi network can
/// reach it at this machine's LAN address - see API_BASE_URL in .env.
Future<void> main(List<String> args) async {
  const port = 8000;
  final server = await HttpServer.bind(InternetAddress.anyIPv4, port);

  stdout.writeln('Seed backend listening on 0.0.0.0:$port');
  stdout.writeln('  LAN   http://192.168.18.237:$port/vehicles');
  stdout.writeln('  Local http://127.0.0.1:$port/vehicles');
  stdout.writeln('Press Ctrl+C to stop.');

  await for (final request in server) {
    try {
      await _handle(request);
    } catch (e) {
      request.response.statusCode = HttpStatus.internalServerError;
      _writeJson(request.response, {'error': '$e'});
      await request.response.close();
    }
  }
}

Future<void> _handle(HttpRequest request) async {
  final path = request.uri.path;
  final method = request.method.toUpperCase();

  stdout.writeln(
    '${DateTime.now().toIso8601String().substring(11, 19)} '
    '$method $path from ${request.connectionInfo?.remoteAddress.address}',
  );

  // CORS - harmless on mobile, required if you ever try the web target.
  request.response.headers
    ..set('Access-Control-Allow-Origin', '*')
    ..set('Access-Control-Allow-Methods', 'GET, OPTIONS')
    ..set('Access-Control-Allow-Headers', 'Content-Type, Accept');

  if (method == 'OPTIONS') {
    request.response.statusCode = HttpStatus.noContent;
    await request.response.close();
    return;
  }

  if (method != 'GET') {
    request.response.statusCode = HttpStatus.methodNotAllowed;
    _writeJson(request.response, {'error': 'Only GET is supported'});
    await request.response.close();
    return;
  }

  switch (path) {
    case '/':
      _writeJson(request.response, {
        'service': 'vehicle-seed-backend',
        'endpoints': ['/vehicles', '/vehicles/<id>', '/health'],
      });
    case '/health':
      _writeJson(request.response, {'status': 'ok'});
    case '/vehicles':
      _writeJson(request.response, {'products': vehicles});
    default:
      final match = RegExp(r'^/vehicles/(\d+)$').firstMatch(path);
      if (match != null) {
        final id = int.parse(match.group(1)!);
        final vehicle = vehicles.where((v) => v['id'] == id).firstOrNull;
        if (vehicle == null) {
          request.response.statusCode = HttpStatus.notFound;
          _writeJson(request.response, {'error': 'No vehicle with id $id'});
        } else {
          _writeJson(request.response, vehicle);
        }
      } else {
        request.response.statusCode = HttpStatus.notFound;
        _writeJson(request.response, {'error': 'Not found: $path'});
      }
  }

  await request.response.close();
}

void _writeJson(HttpResponse response, Object body) {
  response.headers.contentType = ContentType.json;
  response.write(jsonEncode(body));
}

/// Catalogue payload. Thumbnails use picsum.photos so they resolve without
/// any local assets or API keys.
final List<Map<String, dynamic>> vehicles = [
  _vehicle(1, 'Toyota Corolla 2020', 45.0, 'corolla'),
  _vehicle(2, 'Honda Civic 2021', 52.5, 'civic'),
  _vehicle(3, 'Hyundai i20 2019', 38.0, 'i20'),
  _vehicle(4, 'Suzuki Swift 2022', 41.0, 'swift'),
  _vehicle(5, 'Toyota Fortuner 2021', 95.0, 'fortuner'),
  _vehicle(6, 'Mahindra Thar 2022', 78.0, 'thar'),
  _vehicle(7, 'Maruti Alto K10 2018', 25.0, 'alto'),
  _vehicle(8, 'Kia Seltos 2023', 68.0, 'seltos'),
];

Map<String, dynamic> _vehicle(
  int id,
  String title,
  double price,
  String seed,
) => {
  'id': id,
  'title': title,
  'price': price,
  'thumbnail': 'https://picsum.photos/seed/$seed/600/400',
};
