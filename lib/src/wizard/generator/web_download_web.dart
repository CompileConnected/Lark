import 'dart:js_interop';
import 'dart:typed_data';
import 'package:web/web.dart' as web;

void downloadZip(List<int> bytes, String filename) {
  final uint8List = Uint8List.fromList(bytes);
  final jsArrayBuffer = uint8List.buffer.toJS;
  final blob = web.Blob([jsArrayBuffer].toJS);
  final url = web.URL.createObjectURL(blob);
  final anchor = web.HTMLAnchorElement()
    ..href = url
    ..download = filename
    ..style.display = 'none';
  web.document.body!.appendChild(anchor);
  anchor.click();
  anchor.remove();
  web.URL.revokeObjectURL(url);
}
