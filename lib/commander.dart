import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:crossplat_objectid/crossplat_objectid.dart';


import 'package:commandline_splitter/commandline_splitter.dart' as commandline;

class Commander {
  final Directory tempDir;

  Commander._(this.tempDir) {}

  Future<String> takeScreenShot() async {
    final p =
        path.join(tempDir.path, "scrots", ObjectId().toHexString() + ".png");
    try {
      final res = await Process.run('import', ['-window', 'root', p]);
    } catch (e) {
      print(e);
    }
    return p;
  }

  Future<void> reboot() async {
    await Process.run("reboot", []);
  }

  Future<Process> exec(String command) async {
    final cmd = commandline.split(command);
    return Process.start(
        cmd.first, cmd.length >= 2 ? cmd.sublist(1).toList() : []);
  }

  static Future<Commander> make() async {
    final dir = await Directory.systemTemp.createTemp('cmd');
    await Directory(path.join(dir.path, "scrots")).create(recursive: true);
    return Commander._(dir);
  }
}
