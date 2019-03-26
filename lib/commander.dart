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
    await ds.exec("import", ['-window', 'root', p]).run();
    return p;
  }

  Future<void> reboot() async {
    await ds.exec("reboot").run();
  }

  Future<void> exec(String executable, List<String> args) async {
    await ds.exec(executable, args).run();
  }

  static Future<Commander> make() async {
    final dir = await Directory.systemTemp.createTemp('cmd');
    return Commander._(dir);
  }
}
