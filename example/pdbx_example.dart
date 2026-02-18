import 'dart:io';

import 'package:pdbx/pdbx.dart';

void main() async {
  // 1. Initialize the manager with a file path
  final file = File('my_passwords.pdbx');
  final manager = PdbxManager(file);

  const masterPassword = 'your-strong-password';

  try {
    // 2. Create a new encrypted storage
    print('Creating storage...');
    await manager.createStorage(masterPassword);

    // 3. Unlock the storage to start working
    await manager.unlock(masterPassword);
    print('Storage unlocked. Status: ${manager.indexLoaded}');

    // 4. Create a folder (Group)
    final socialGroup = await manager.createGroup(title: 'Social Networks');
    print('Group created: ${socialGroup.title} (ID: ${socialGroup.id})');

    // 5. Create a new password entry
    final newEntry = await manager.createEntry(
      title: 'GitHub',
      username: 'dev_user',
      password: 'extremely-secure-password',
      groupId: socialGroup.id,
      notes: 'Work account',
    );
    print('Entry saved: ${newEntry.title}');

    // 6. Search for entries
    final results = manager.searchEntriesInStorage('git');
    if (results.isNotEmpty) {
      // 7. Fetch full decrypted data for the first result
      final entry = await manager.fetchEntry(results.first);
      print('Found entry: ${entry.title}');
      print('Username: ${entry.username}');
      print('Password: ${entry.password}'); // Decrypted only in memory
    }

    // 8. Lock the storage when done
    // This wipes the master key from memory for security
    manager.lock();
    print('Storage locked. Security session ended.');
  } on PdbxAuthException {
    print('Error: Invalid master password.');
  } on PdbxException catch (e) {
    print('Error: ${e.message}');
  } finally {
    // Cleanup for example purposes
    if (await file.exists()) await file.delete();
  }
}
