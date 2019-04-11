import 'dart:io';
import 'dart:async';

import 'dart:convert';

import 'commander.dart';

class Config {
  String id;

  String password;

  Config({this.id, this.password});
}

Future<void> comm(Config config) async {
  final conn = await WebSocket.connect(
      "ws://localhost:10000/api/commander/${config.id}");

  final commander = await Commander.make();

  conn.add(jsonEncode({
    "repcmd": "auth",
    "pwd": "1234as",
  }));

  final heartbeat = Timer.periodic(Duration(minutes: 1), (_) async {
    conn.add(jsonEncode({
      "repcmd": "hb",
    }));
  });

  conn.listen((v) async {
    if (v is! String) return;

    final map = json.decode(v);

    print(map);

    final cmd = map["cmd"];

    if (cmd == "screenshot") {
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
    } else if (cmd == "auth_fail") {
      // TODO
    }
  });
}
