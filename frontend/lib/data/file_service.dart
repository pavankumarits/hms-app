import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'dart:io'; 
import 'package:flutter/foundation.dart';
import '../data/api_client.dart';

class FileService {
  final Dio _dio = ApiClient().dio;

  Future<void> uploadFile(PlatformFile file) async {
    String fileName = file.name;
    
    // Determine content type
    MediaType? contentType;
    if (fileName.endsWith('.pdf')) {
      contentType = MediaType('application', 'pdf');
    } else if (fileName.endsWith('.jpg') || fileName.endsWith('.jpeg')) {
      contentType = MediaType('image', 'jpeg');
    } else if (fileName.endsWith('.png')) {
      contentType = MediaType('image', 'png');
    }

    try {
      MultipartFile multipartFile;
      
      if (kIsWeb) {
        // On Web, use bytes
         multipartFile = MultipartFile.fromBytes(
          file.bytes!,
          filename: fileName,
          contentType: contentType,
        );
      } else {
        // On Mobile/Desktop, use path
        multipartFile = await MultipartFile.fromFile(
          file.path!,
          filename: fileName,
          contentType: contentType,
        );
      }

      FormData formData = FormData.fromMap({
        'file': multipartFile,
      });

      await _dio.post('/files/upload/', data: formData);
    } catch (e) {
      throw Exception('Failed to upload file: $e');
    }
  }
}
