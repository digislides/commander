import 'dart:io';

import 'package:commander/commander.dart';

main(List<String> arguments) async {
  final cmd = await Commander.make();
  final path = await cmd.takeScreenShot();
  print(path);
}
