import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:faker/faker.dart';
import 'package:http/http.dart' as http;
import 'package:pocketbase/pocketbase.dart';
import 'package:http_parser/http_parser.dart' show MediaType;

// PocketBase product seeder
// - Logs in as admin
// - Ensures target collection exists (optional)
// - Creates N fake products with name, price, imageUrl, and optional uploaded image

Future<void> main(List<String> args) async {
  final flags = _parseArgs(args);

  String readEnv(String key, [String? fallback]) =>
      Platform.environment[key] ?? fallback ?? '';

  final base = flags['base'] ?? readEnv('POCKETBASE_URL', 'http://127.0.0.1:8090');
  final email = flags['email'] ?? readEnv('POCKETBASE_ADMIN_EMAIL', 'admin@ubu.ac.th');
  final password = flags['password'] ?? readEnv('POCKETBASE_ADMIN_PASSWORD', '');
  final collection = flags['collection'] ?? 'product';
  final imageUpload = (flags['imageUpload'] ?? 'false').toLowerCase() != 'false';
  final ensure = (flags['ensure'] ?? 'false').toLowerCase() != 'false';
  final nameField = flags['nameField'] ?? 'name';
  final priceField = flags['priceField'] ?? 'price';
  final imageUrlField = flags['imageUrlField'] ?? 'imageURL';
  final imageField = flags['imageField'] ?? 'image';
  final count = int.tryParse(flags['count'] ?? '100') ?? 100;

  stdout.writeln('PocketBase Seeder');
  stdout.writeln('- base: $base');
  stdout.writeln('- collection: $collection');
  stdout.writeln('- count: $count');
  stdout.writeln('- imageUpload: $imageUpload');
  stdout.writeln('- ensureCollection: $ensure');
  stdout.writeln('- field mapping: { $nameField, $priceField, $imageUrlField, $imageField }');

  // Health check
  try {
    final health = await http.get(Uri.parse('$base/api/health'));
    if (health.statusCode != 200) {
      stderr.writeln('Warning: health check HTTP ${health.statusCode}: ${health.body}');
    }
  } catch (e) {
    stderr.writeln('Warning: health check failed: $e');
  }

  final pb = PocketBase(base);
  try {
    stdout.writeln('Authenticating as admin...');
    await pb.admins.authWithPassword(email, password);
  } on ClientException catch (e) {
    _printClientError('Admin auth failed', e);
    stderr.writeln('Hint: verify admin exists and password is correct in the UI at $base/_/');
    exitCode = 2;
    return;
  }

  // Optional: create collection if missing (schema matches ProductModel)
  if (ensure) {
    await _ensureCollection(pb, collection);
  } else {
    // Just verify it exists
    try {
      await pb.collections.getOne(collection);
    } on ClientException catch (e) {
      _printClientError('Collection not found (use --ensure true to create)', e);
      exitCode = 3;
      return;
    }
  }

  final faker = Faker();
  final rnd = Random();

  int ok = 0;
  for (var i = 0; i < count; i++) {
    final name = _productName(faker, rnd);
    final price = _price(rnd);
    final imageUrl = 'https://picsum.photos/seed/pb_${i + 1}/600/400';

    try {
      // If uploading an image, download and attach as file
      if (imageUpload) {
        final imgResp = await http.get(Uri.parse(imageUrl));
        if (imgResp.statusCode != 200) throw 'image download ${imgResp.statusCode}';

        await pb.collection(collection).create(
          body: {
            nameField: name,
            priceField: price,
            imageUrlField: imageUrl,
          },
          files: [
            http.MultipartFile.fromBytes(
              imageField,
              imgResp.bodyBytes,
              filename: 'product_${i + 1}.jpg',
              contentType: MediaType('image', 'jpeg'),
            ),
          ],
        );
      } else {
        await pb.collection(collection).create(body: {
          nameField: name,
          priceField: price,
          imageUrlField: imageUrl,
        });
      }

      ok++;
      if (i % 10 == 0 || i == count - 1) {
        stdout.writeln('Created $ok/$count ...');
      }
    } on ClientException catch (e) {
      _printClientError('Create failed [$i]', e);
    } catch (e) {
      stderr.writeln('Create failed [$i]: $e');
    }

    await Future<void>.delayed(const Duration(milliseconds: 60));
  }

  stdout.writeln('Done. Created $ok/$count records.');
}

Map<String, String> _parseArgs(List<String> args) {
  final m = <String, String>{};
  for (var i = 0; i < args.length; i++) {
    final a = args[i];
    if (!a.startsWith('--')) continue;
    final k = a.substring(2);
    final v = (i + 1 < args.length && !args[i + 1].startsWith('--')) ? args[++i] : 'true';
    m[k] = v;
  }
  return m;
}

String _productName(Faker faker, Random rnd) {
  final brands = ['Acme', 'Nova', 'Orion', 'Vertex', 'Nimbus', 'Atlas'];
  final adjectives = ['Pro', 'Lite', 'Max', 'Prime', 'Ultra', 'Mini'];
  final noun = faker.lorem.word();
  return '${brands[rnd.nextInt(brands.length)]} ${adjectives[rnd.nextInt(adjectives.length)]} ${_cap(noun)}';
}

double _price(Random rnd) => double.parse(((rnd.nextDouble() * 495) + 5).toStringAsFixed(2));

String _cap(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

Future<void> _ensureCollection(PocketBase pb, String collection) async {
  try {
    await pb.collections.getOne(collection);
    return; // exists
  } on ClientException catch (e) {
    if (e.statusCode != 404) {
      _printClientError('Collection check failed', e);
      return;
    }
  }

  try {
    await pb.collections.create(body: {
      'name': collection,
      'type': 'base',
      'schema': [
        {
          'name': 'name',
          'type': 'text',
          'required': true,
          'options': {'min': 1, 'max': 200},
        },
        {
          'name': 'price',
          'type': 'number',
          'required': true,
          'options': {'min': 0},
        },
        {
          'name': 'imageUrl',
          'type': 'url',
        },
        {
          'name': 'image',
          'type': 'file',
          'options': {
            'maxSelect': 1,
            'maxSize': 10 * 1024 * 1024,
            'mimeTypes': ['image/jpeg', 'image/png', 'image/webp']
          },
        },
      ],
      'listRule': '',
      'viewRule': '',
      'createRule': '',
      'updateRule': '',
      'deleteRule': '',
    });
    stdout.writeln('Created collection: $collection');
  } on ClientException catch (e) {
    _printClientError('Create collection failed', e);
  }
}

void _printClientError(String label, ClientException e) {
  final sb = StringBuffer('$label: ');
  sb.write('{status: ${e.statusCode ?? '-'}, message: ');
  try {
    final data = e.response;
    if (data != null) sb.write(jsonEncode(data));
  } catch (_) {}
  sb.write('}');
  stderr.writeln(sb.toString());
}
