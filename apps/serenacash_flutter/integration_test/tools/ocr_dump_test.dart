// Ferramenta de desenvolvimento, não um teste do aplicativo: roda o OCR do aparelho (ML Kit) sobre
// fotos de etiquetas e imprime, para cada foto, as linhas reconhecidas com suas caixas. Essas
// leituras viram os casos de regressão do interpretador de etiquetas (test/fixtures/labels), para
// que o gabarito parta da leitura real do motor, e não de uma transcrição feita à mão.
//
// Uso (as fotos não ficam no repositório):
//   1. copiar as fotos .jpg para assets/_ocr/ e declarar "assets: [assets/_ocr/]" no pubspec.yaml;
//   2. SERENA_APP_ID_SUFFIX=.itest flutter test integration_test/tools/ocr_dump_test.dart -d <aparelho>
//   3. tool/ocr_fixtures.py <saída do passo 2> grava test/fixtures/labels/*.json;
//   4. desfazer o passo 1.
//
// Sem fotos declaradas, não faz nada.
import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path_provider/path_provider.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('dump OCR lines of the label photos', (tester) async {
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    final photos =
        manifest
            .listAssets()
            .where(
              (a) =>
                  a.startsWith('assets/_ocr/') &&
                  a.toLowerCase().endsWith('.jpg'),
            )
            .toList()
          ..sort();
    if (photos.isEmpty) return;
    final tmp = await getTemporaryDirectory();
    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    for (final asset in photos) {
      final bytes = (await rootBundle.load(asset)).buffer.asUint8List();
      final name = asset.split('/').last;
      final file = File('${tmp.path}/$name')..writeAsBytesSync(bytes);
      final sw = Stopwatch()..start();
      final result = await recognizer.processImage(
        InputImage.fromFilePath(file.path),
      );
      sw.stop();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      final out = {
        'image': name,
        'width': frame.image.width,
        'height': frame.image.height,
        'ocrMs': sw.elapsedMilliseconds,
        'lines': [
          for (var b = 0; b < result.blocks.length; b++)
            for (final line in result.blocks[b].lines)
              {
                'text': line.text,
                'block': b,
                'left': line.boundingBox.left.round(),
                'top': line.boundingBox.top.round(),
                'width': line.boundingBox.width.round(),
                'height': line.boundingBox.height.round(),
                if (line.confidence != null)
                  'confidence': double.parse(
                    line.confidence!.toStringAsFixed(3),
                  ),
                if (line.angle != null)
                  'angle': double.parse(line.angle!.toStringAsFixed(1)),
              },
        ],
      };
      file.deleteSync();
      // Printed in short base64 pieces: the test log is the only thing that survives the run.
      final b64 = base64Encode(utf8.encode(jsonEncode(out)));
      for (var i = 0; i < b64.length; i += 700) {
        // ignore: avoid_print
        print(
          'OCRJSON|$name|${b64.substring(i, i + 700 > b64.length ? b64.length : i + 700)}',
        );
      }
    }
    await recognizer.close();
    // ignore: avoid_print
    print('OCR-DUMP ${photos.length} fotos');
  });
}
