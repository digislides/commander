import 'dart:io';

import 'dart:convert';
import 'package:crypto/crypto.dart';

import 'commander.dart';

class Config {
  String id;

  String password;

  Config({this.id, this.password});
}

Future<void> comm(Config config) async {
  final conn = await WebSocket.connect(
      "ws://localhost:10000/api/commander/${config.id}");

  final enc = Hmac(sha256, config.password.codeUnits);

  final commander = await Commander.make();

  conn.listen((v) async {
    if (v is! String) return;

    final map = json.decode(v);

    final cmd = map["cmd"];

    if (cmd == "screencast") {
      final path = await commander.takeScreenShot();
      final bytes = await File(path).readAsBytes();
      conn.add(json.encode({
        "id": map["id"],
        "repcmd": cmd,
        "file": bytes,
      }));
    } else if (cmd == "exec") {
      final process = await commander.exec(map["command"]);
      process.stdout.listen((d) {
        conn.add(jsonEncode({
          "id": map["id"],
          "repcmd": cmd,
          "stdout": d,
        }));
      });
      process.stderr.listen((d) {
        conn.add(jsonEncode({
          "id": map["id"],
          "repcmd": cmd,
          "stderr": d,
        }));
      });
      process.exitCode.then((c) {
        conn.add(jsonEncode({
          "id": map["id"],
          "repcmd": cmd,
          "exitCode": c,
        }));
      });
    } else if (cmd == "reboot") {
      await commander.reboot();
    } else if (cmd == "auth") {
      conn.add(jsonEncode({
        "id": map["id"],
        "repcmd": cmd,
        "reply": enc.convert(map["challenge"]).bytes,
      }));
    } else if (cmd == "auth_fail") {
      // TODO
    }
  });
}
