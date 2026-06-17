import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart' show Uint8List, kIsWeb, debugPrint;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'local_storage_service.dart';

/// ApiService — Layanan terpusat untuk komunikasi dengan Backend REST API MySQL
class ApiService {
  ApiService._();

  /// IP komputer/host default (dapat diubah manual sesuai IP Wi-Fi Anda)
  static String baseUrl = 'http://localhost:3000/api/v1';

  /// Getter Header API otomatis menyisipkan Token JWT
  static Map<String, String> get _headers {
    final token = LocalStorageService.instance.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Menyelaraskan URL gambar lokal backend (misal: "uploads/filename.jpg")
  /// menjadi URL lengkap absolut (misal: "http://192.168.1.5:5000/uploads/filename.jpg")
  static String resolveImageUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('blob:') || path.startsWith('data:')) {
      return path;
    }
    if (path.startsWith('http') && path.contains('/uploads/')) {
      final index = path.indexOf('/uploads/');
      final relativePath = path.substring(index + 1); // "uploads/..."
      final cleanPath = '/$relativePath';
      final serverUrl = baseUrl.replaceAll('/api/v1', '');
      return '$serverUrl$cleanPath';
    }
    if (path.startsWith('http')) {
      if (kIsWeb) {
        final encodedUrl = Uri.encodeComponent(path);
        return '$baseUrl/proxy?url=$encodedUrl';
      }
      return path;
    }
    final cleanPath = path.startsWith('/') ? path : '/$path';
    final serverUrl = baseUrl.replaceAll('/api/v1', '');
    return '$serverUrl$cleanPath';
  }

  /// GET Request
  static Future<http.Response> get(String endpoint) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      debugPrint('API GET: $url');
      return await http.get(url, headers: _headers);
    } catch (e) {
      debugPrint('API GET Error: $e');
      rethrow;
    }
  }

  /// POST Request
  static Future<http.Response> post(String endpoint, Object? body) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      debugPrint('API POST: $url');
      return await http.post(
        url,
        headers: _headers,
        body: body != null ? jsonEncode(body) : null,
      );
    } catch (e) {
      debugPrint('API POST Error: $e');
      rethrow;
    }
  }

  /// PUT Request
  static Future<http.Response> put(String endpoint, Object? body) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      debugPrint('API PUT: $url');
      return await http.put(
        url,
        headers: _headers,
        body: body != null ? jsonEncode(body) : null,
      );
    } catch (e) {
      debugPrint('API PUT Error: $e');
      rethrow;
    }
  }

  /// DELETE Request
  static Future<http.Response> delete(String endpoint) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      debugPrint('API DELETE: $url');
      return await http.delete(url, headers: _headers);
    } catch (e) {
      debugPrint('API DELETE Error: $e');
      rethrow;
    }
  }

  /// Multipart Request (untuk upload Gambar/File via kamera & galeri)
  static Future<http.Response> multipartRequest(
    String method,
    String endpoint, {
    Map<String, String>? fields,
    String? fileKey,
    String? filePath,
    Uint8List? fileBytes,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      debugPrint('API Multipart ($method): $url');
      final request = http.MultipartRequest(method, url);

      // Sisipkan header (kecuali Content-Type karena request body bertipe multipart)
      _headers.forEach((k, v) {
        if (k != 'Content-Type') {
          request.headers[k] = v;
        }
      });

      // Tambahkan data field teks
      if (fields != null) {
        request.fields.addAll(fields);
      }

      // Tambahkan data file
      if (fileKey != null) {
        if (kIsWeb) {
          Uint8List? uploadBytes = fileBytes;
          if (uploadBytes == null && filePath != null && filePath.isNotEmpty) {
            try {
              final uri = Uri.parse(filePath);
              final response = await http.get(uri);
              if (response.statusCode == 200) {
                uploadBytes = response.bodyBytes;
              }
            } catch (e) {
              debugPrint(
                'Error fetching bytes from web filePath ($filePath): $e',
              );
            }
          }
          if (uploadBytes != null) {
            request.files.add(
              http.MultipartFile.fromBytes(
                fileKey,
                uploadBytes,
                filename: 'upload.jpg',
                contentType: MediaType('image', 'jpeg'),
              ),
            );
          } else {
            debugPrint('Web upload failed: no bytes available for $fileKey');
          }
        } else {
          if (fileBytes != null) {
            request.files.add(
              http.MultipartFile.fromBytes(
                fileKey,
                fileBytes,
                filename: 'upload.jpg',
                contentType: MediaType('image', 'jpeg'),
              ),
            );
          } else if (filePath != null && filePath.isNotEmpty) {
            request.files.add(
              await http.MultipartFile.fromPath(
                fileKey,
                filePath,
                contentType: MediaType('image', 'jpeg'),
              ),
            );
          }
        }
      }

      final streamedResponse = await request.send();
      return await http.Response.fromStream(streamedResponse);
    } catch (e) {
      debugPrint('API Multipart Error: $e');
      rethrow;
    }
  }
}
