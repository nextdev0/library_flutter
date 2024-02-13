import 'dart:convert';
import 'dart:io';

import 'package:lzma/lzma.dart';

Future<int> main(List<String> args) async {
  if (args.length != 1) {
    print('error\n');
    return -1;
  }

  final input = File(args[0]);
  final inputBytes = await input.readAsBytes();

  final compressed = lzma.encode(inputBytes);
  final encoded = base64Encode(compressed);

  final output = File('${args[0]}.txt');
  await output.writeAsBytes(utf8.encode(encoded));

  return 0;
}
