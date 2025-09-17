import 'dart:convert';
import 'dart:io';

void main() {
  final f = File('web/manifest.json');
  if (!f.existsSync()) { 
    print('manifest: MISSING'); 
    exit(0); 
  }
  final j = jsonDecode(f.readAsStringSync());
  print('manifest.name=${j['name']}');
  print('manifest.theme_color=${j['theme_color']}');
  for (final s in ['web/icons/icon-192.png','web/icons/icon-512.png','web/icons/icon-maskable.png']) {
    print('$s: ${File(s).existsSync() ? 'OK' : 'MISSING'}');
  }
}
