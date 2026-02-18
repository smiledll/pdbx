import 'dart:io';

import 'package:pdbx/pdbx.dart';

void main() async {
  final file = File('');
  final manager = PdbxManager(file);

  const password = 'your-strong-password';

  await manager.createStorage(password);
  await manager.unlock(password);
}
