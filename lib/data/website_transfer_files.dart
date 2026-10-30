import 'dart:convert';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'website_backup.dart';

abstract interface class WebsiteTransferFiles {
  Future<String?> read();
  Future<bool> save(String content);
}

class DeviceWebsiteTransferFiles implements WebsiteTransferFiles {
  const DeviceWebsiteTransferFiles();

  @override
  Future<String?> read() async {
    final file = await FilePicker.pickFile(
      dialogTitle: 'Importa les webs',
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (file == null) return null;
    if ((await file.length() ?? 0) > WebsiteBackup.maxBytes) {
      throw const FormatException('El fitxer supera el límit d’1 MB.');
    }
    final bytes = BytesBuilder(copy: false);
    await for (final chunk in file.readAsByteStream()) {
      if (bytes.length + chunk.length > WebsiteBackup.maxBytes) {
        throw const FormatException('El fitxer supera el límit d’1 MB.');
      }
      bytes.add(chunk);
    }
    try {
      return utf8.decode(bytes.takeBytes());
    } catch (_) {
      throw const FormatException(
        'El fitxer no és un document de text UTF-8 vàlid.',
      );
    }
  }

  @override
  Future<bool> save(String content) async {
    final date = DateTime.now().toIso8601String().substring(0, 10);
    final path = await FilePicker.saveFile(
      dialogTitle: 'Exporta les webs',
      fileName: 'eduweb-webs-$date.json',
      mimeType: 'application/json',
      bytes: Uint8List.fromList(utf8.encode(content)),
    );
    return path != null;
  }
}
