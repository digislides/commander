import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:crossplat_objectid/crossplat_objectid.dart';

import 'package:dscript_exec/dscript_exec.dart' as ds;

class Commander {
  final Directory tempDir;

  Commander._(this.tempDir) {}

  Future<String> takeScreenShot() async {
    final p =
        path.join(tempDir.path, "scrots", ObjectId().toHexString() + ".png");
    try {
      final res = await Process.run('import', ['-window', 'root', p]);
    } catch(e) {
      print(e);
    }
    return p;
  }

  Future<void> reboot() async {
    await ds.exec("reboot").run();
  }

  Future<Process> exec(String command) async {
    return Process.start("bash", ["-c", '"$command"']);
  }

  static Future<Commander> make() async {
    final dir = await Directory.systemTemp.createTemp('cmd');
    await Directory(path.join(dir.path, "scrots")).create(recursive: true);
    return Commander._(dir);
  }
}
