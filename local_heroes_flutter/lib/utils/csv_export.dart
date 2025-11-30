import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/hero_model.dart';

/// Utility class for exporting heroes data to CSV.
class CsvExport {
  /// Export a list of heroes to CSV and share.
  static Future<void> exportAndShare(List<LocalHero> heroes) async {
    if (heroes.isEmpty) {
      return;
    }

    final csvContent = _generateCsvContent(heroes);
    final file = await _saveCsvToFile(csvContent);

    await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'Local Heroes - Kept List',
      text: 'Here are the local heroes I\'ve saved!',
    );
  }

  /// Generate CSV content from heroes list.
  static String _generateCsvContent(List<LocalHero> heroes) {
    final headers = ['ID', 'Name', 'Field', 'Bio', 'Contact Info', 'Kept At'];

    final rows = heroes.map((hero) {
      return [
        hero.id,
        hero.name,
        hero.field,
        hero.bio,
        hero.contactInfo ?? '',
        hero.keptAt?.toIso8601String() ?? '',
      ];
    }).toList();

    final csvData = [headers, ...rows];
    return const ListToCsvConverter().convert(csvData);
  }

  /// Save CSV content to a temporary file.
  static Future<File> _saveCsvToFile(String csvContent) async {
    final directory = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${directory.path}/local_heroes_$timestamp.csv');
    return await file.writeAsString(csvContent);
  }
}
