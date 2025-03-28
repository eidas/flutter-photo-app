import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import '../constants/app_constants.dart';

class FileUtils {
  // アプリのドキュメントディレクトリを取得
  static Future<Directory> getAppDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final directory = Directory('${appDir.path}/${AppConstants.appDirName}');
    
    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    
    return directory;
  }
  
  // 一時ファイル保存用ディレクトリの取得
  static Future<Directory> getTemporaryDirectory() async {
    final tempDir = await getTemporaryDirectory();
    return tempDir;
  }
  
  // 一意のファイル名を生成
  static String generateUniqueFileName(String extension) {
    final uuid = const Uuid().v4();
    return '$uuid.$extension';
  }
  
  // ファイルをバイト配列として読み込み
  static Future<Uint8List> readFileAsBytes(String filePath) async {
    final file = File(filePath);
    return await file.readAsBytes();
  }
}
