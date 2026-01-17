import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fms_app/providers/app_Manager.dart';
import 'package:fms_app/utils/app_theme.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

class ApiService {
  // Use 127.0.0.1 for better compatibility
  static const String baseUrl = 'http://127.0.0.1:8000/api';

  /// Multipart POST request for file uploads
  /// Works with both File (mobile) and Uint8List (web)
  Future<http.Response?> multipartPost({
    required String endpoint,
    required Map<String, String> fields,
    Uint8List? fileBytes,
    String? fileName,
    String fileFieldName = 'logo',
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/$endpoint');
      print('🚀 Making multipart request to: $uri');

      var request = http.MultipartRequest('POST', uri);

      // Add all form fields
      request.fields.addAll(fields);
      print('📝 Fields: ${fields.keys.join(", ")}');

      // Add file if provided (using bytes - works for web and mobile)
      if (fileBytes != null && fileName != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            fileFieldName,
            fileBytes,
            filename: fileName,
          ),
        );
        print('📎 File attached: $fileName (${fileBytes.length} bytes)');
      }

      // Add headers
      request.headers.addAll({
        'Accept': 'application/json',
      });

      print('⏳ Sending request...');

      // Send with timeout
      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('⏱️ Request timeout after 30 seconds');
        },
      );

      final response = await http.Response.fromStream(streamedResponse);

      print('✅ Response Status: ${response.statusCode}');
      print('📥 Response Body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return response;
      } else {
        try {
          final errorData = jsonDecode(response.body);
          throw Exception(errorData['message'] ?? 'Request failed with status ${response.statusCode}');
        } catch (e) {
          throw Exception('Request failed: ${response.body}');
        }
      }

    } on http.ClientException catch (e) {
      print('❌ ClientException: $e');
      print('');
      print('🔧 TROUBLESHOOTING:');
      print('1. Is Laravel running? (php artisan serve)');
      print('2. Check CORS middleware is registered');
      print('3. Check browser DevTools Console for errors');


      throw Exception(
          '❌ Cannot connect to server\n\n'
              'Possible causes:\n'
              '• Laravel server not running\n'
              '• CORS not configured\n'
              '• Network error'
      );

    } catch (e) {
      print('❌ Error: $e');
      rethrow;
    }
  }

  /// Simple GET request
  Future<http.Response?> get(
      String endpoint,
      BuildContext context, {
        Map<String, dynamic>? params,
      }) async {
    try {
      // 1️⃣ Build the URI with optional query parameters
      await Future.delayed(const Duration(seconds: 1));
      Uri uri = Uri.parse('$baseUrl/$endpoint');
      if (params != null && params.isNotEmpty) {
        uri = uri.replace(
          queryParameters: params.map((key, value) => MapEntry(key, value.toString())),
        );
      }

      // 2️⃣ Prepare headers
      final String token = AppManager().loginToken;
      final headers = {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      };

      // 3️⃣ Debug output
      print('🚀 GET Request: $uri');
      print('🛡 Headers: $headers');

      // 4️⃣ Make the request with timeout
      final response = await http.get(uri, headers: headers).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          showCustomSnackBar(context, 'Request timeout');
          throw Exception('Request timeout');
        },
      );

      // 5️⃣ Debug response
      print('✅ Status: ${response.statusCode}');
      print('📥 Body: ${response.body}');

      return response;
    } catch (e) {
      print('❌ GET error: $e');
      rethrow;
    }
  }




  /// Simple POST request with JSON body
  Future<http.Response?> post(
      String endpoint,
      Map<String, dynamic> body,
      BuildContext context,
   bool   isTokenNeed ,
      ) async {
    try {
      final uri = Uri.parse('$baseUrl/$endpoint');
     // print('🚀 POST: $uri');
      final String token = AppManager().loginToken;
      print(body.toString());
      final response = await http.post(
        uri,
        headers:isTokenNeed?  {
          'Content-Type': 'application/json',
          'Authorization':"Bearer $token",
        } :{
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          showCustomSnackBar(context, 'Request timeout');
         // Navigator.pop(context);
          throw Exception('Request timeout');
        },
      );
      final responseData = jsonDecode(response.body);
if(response.statusCode==200 ||response.statusCode==201 ){

  showCustomSnackBar(context, ' ${responseData["message"]}',color: Colors.green);
}else{
  print("${responseData}");
  showCustomSnackBar(context, ' ${responseData["message"]}');
  throw Exception(' ${responseData.toString()}');
}
      return response;

    } on http.ClientException catch (e) {
      //print('❌ ClientException: $e');
      showCustomSnackBar(context, 'Cannot connect to server');
     // throw Exception('Cannot connect to server');
    } catch (e) {
      print('❌ Error: $e');
      rethrow;
    }
    return null;
  }

  Future<http.Response?> put(
      String endpoint,
      Map<String, dynamic> body,
      BuildContext context,
      bool isTokenNeed,
      ) async {
    try {
      final uri = Uri.parse('$baseUrl/$endpoint');
      debugPrint('🔄 PUT: $uri');
      debugPrint('📦 Body: $body');

      final String token = AppManager().loginToken;

      final response = await http.put( // ✅ Changed from post to put
        uri,
        headers: isTokenNeed
            ? {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': "Bearer $token",
        }
            : {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          if (context.mounted) {
            showCustomSnackBar(context, 'Request timeout');
          }
          throw Exception('Request timeout');
        },
      );

      debugPrint('✅ Status: ${response.statusCode}');
      debugPrint('📥 Body: ${response.body}');

      // ✅ Fixed: Check if status is NOT 200/201 (use == for OR condition)
      if (response.statusCode != 200 && response.statusCode != 201) {
        try {
          final responseData = jsonDecode(response.body);
          if (context.mounted) {
            showCustomSnackBar(context, '${responseData["message"] ?? "Request failed"}');
          }
        } catch (e) {
          // If response is not JSON (HTML error page)
          debugPrint('❌ Response is not JSON: ${response.body}');
          if (context.mounted) {
            showCustomSnackBar(context, 'Server error: ${response.statusCode}');
          }
        }
      }

      return response;
    } on http.ClientException catch (e) {
      debugPrint('❌ ClientException: $e');
      if (context.mounted) {
        showCustomSnackBar(context, 'Cannot connect to server');
      }
      return null; // ✅ Added return
    } on TimeoutException catch (e) {
      debugPrint('❌ TimeoutException: $e');
      if (context.mounted) {
        showCustomSnackBar(context, 'Request timeout');
      }
      return null; // ✅ Added return
    } catch (e) {
      debugPrint('❌ Error: $e');
      if (context.mounted) {
        showCustomSnackBar(context, 'Request failed');
      }
      rethrow;
    }
  }
  Future<http.Response?> delete(String endpoint, context,bool   isTokenNeed ,) async {
    try {
      final uri = Uri.parse('$baseUrl/$endpoint');
      print('🚀 DELETE: $uri');
      final String token = AppManager().loginToken;
      final response = await http.delete(
        uri,
        headers:isTokenNeed?   {
          'Content-Type': 'application/json',
          'Authorization':"Bearer $token",
        } :{
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Request timeout');
        },
      );

      print('✅ Status: ${response.statusCode}');
      print('📥 Body: ${response.body}');

      return response;

    } catch (e) {
      print('❌ Error: $e');
      rethrow;
    }
  }

  static Future<http.Response> multipartFilePost({
    required String endpoint,
    required Map<String, dynamic> data,
    List<XFile>? images,
    String imageKey = 'images',

  }) async {
    final token = AppManager().loginResponse["token"];

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/$endpoint'),
    );

    request.headers.addAll({
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
    });

    // Add fields
    request.fields.addAll(
      data.map((k, v) => MapEntry(k, v.toString())),
    );

    // Add images (if any)
    if (images != null && images.isNotEmpty) {
      for (int i = 0; i < images.length; i++) {
        if (kIsWeb) {
          request.files.add(
            http.MultipartFile.fromBytes(
              '$imageKey[$i]',
              await images[i].readAsBytes(),
              filename: images[i].name,
            ),
          );
        } else {
          request.files.add(
            await http.MultipartFile.fromPath(
              '$imageKey[$i]',
              images[i].path,
            ),
          );
        }
      }
    }

    final streamedResponse = await request.send();
    return http.Response.fromStream(streamedResponse);
  }
}