import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class BackupMetadata {
  final String fileName;
  final String filePath;
  final int fileSizeBytes;
  final DateTime createdAt;

  const BackupMetadata({
    required this.fileName,
    required this.filePath,
    required this.fileSizeBytes,
    required this.createdAt,
  });

  String get formattedSize {
    if (fileSizeBytes < 1024) return '$fileSizeBytes B';
    if (fileSizeBytes < 1024 * 1024) {
      return '${(fileSizeBytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(fileSizeBytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }
}

class BackupService {
  BackupService._();

  static const String _dbFileName = 'atom.sqlite';
  static const String _backupDirName = 'backups';

  /// Creates a local SQLite database snapshot backup file
  static Future<BackupMetadata> createBackup() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final dbFile = File(p.join(docsDir.path, _dbFileName));

    if (!await dbFile.exists()) {
      throw Exception('Active database file not found at ${dbFile.path}');
    }

    final backupDir = Directory(p.join(docsDir.path, _backupDirName));
    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }

    final timestampStr = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final backupFileName = 'atom_backup_$timestampStr.db';
    final targetFile = File(p.join(backupDir.path, backupFileName));

    await dbFile.copy(targetFile.path);
    final stat = await targetFile.stat();

    return BackupMetadata(
      fileName: backupFileName,
      filePath: targetFile.path,
      fileSizeBytes: stat.size,
      createdAt: DateTime.now(),
    );
  }

  /// Lists all locally saved backups ordered by newest first
  static Future<List<BackupMetadata>> getBackupsList() async {
    final docsDir = await getApplicationDocumentsDirectory();
    final backupDir = Directory(p.join(docsDir.path, _backupDirName));

    if (!await backupDir.exists()) {
      return [];
    }

    final list = <BackupMetadata>[];
    final entities = await backupDir.list().toList();

    for (final entity in entities) {
      if (entity is File && entity.path.endsWith('.db')) {
        final stat = await entity.stat();
        list.add(BackupMetadata(
          fileName: p.basename(entity.path),
          filePath: entity.path,
          fileSizeBytes: stat.size,
          createdAt: stat.modified,
        ));
      }
    }

    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  /// Validates SQLite database header integrity
  static Future<bool> validateBackup(File backupFile) async {
    if (!await backupFile.exists()) return false;
    final length = await backupFile.length();
    if (length < 100) return false;

    // Check first 16 bytes for standard SQLite header: "SQLite format 3\x00"
    final stream = backupFile.openRead(0, 16);
    final bytes = await stream.first;
    final header = String.fromCharCodes(bytes.take(15));
    return header == 'SQLite format 3';
  }

  /// Restores database from a selected backup file
  static Future<void> restoreBackup(File backupFile) async {
    final isValid = await validateBackup(backupFile);
    if (!isValid) {
      throw Exception('Selected backup file is invalid or corrupted.');
    }

    final docsDir = await getApplicationDocumentsDirectory();
    final activeDbFile = File(p.join(docsDir.path, _dbFileName));

    // Overwrite active database file with backup
    await backupFile.copy(activeDbFile.path);
  }

  /// Deletes a backup snapshot
  static Future<void> deleteBackup(File backupFile) async {
    if (await backupFile.exists()) {
      await backupFile.delete();
    }
  }

  /// Shares a backup database file via native platform share sheet
  static Future<void> shareBackup(BackupMetadata backup) async {
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(backup.filePath)],
        subject: 'atom Database Backup: ${backup.fileName}',
      ),
    );
  }
}
