import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/// Service for uploading images to ImgBB
class ImgBBService {
  // TODO: Replace with your actual ImgBB API key
  static const String _apiKey = '583f2385696ff905a6fd751587bb8e75';
  static const String _uploadUrl = 'https://api.imgbb.com/1/upload';

  /// Upload image to ImgBB and return the URL
  Future<String> uploadImage(File imageFile) async {
    try {
      // Read image as base64
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      // Prepare multipart request
      final request = http.MultipartRequest('POST', Uri.parse('$_uploadUrl?key=$_apiKey'));
      
      // Add image as base64
      request.fields['image'] = base64Image;
      
      // Optional: Add filename
      final filename = imageFile.path.split('/').last;
      request.fields['name'] = filename;

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        
        if (jsonResponse['success'] == true) {
          // Return the display URL
          return jsonResponse['data']['display_url'] as String;
        } else {
          throw Exception('ImgBB upload failed: ${jsonResponse['error']}');
        }
      } else {
        throw Exception('ImgBB upload failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error uploading to ImgBB: $e');
      rethrow;
    }
  }

  /// Upload image with expiration (in seconds)
  Future<String> uploadImageWithExpiration(File imageFile, int expirationSeconds) async {
    try {
      // Validate expiration (60 to 15552000 seconds)
      if (expirationSeconds < 60 || expirationSeconds > 15552000) {
        throw Exception('Expiration must be between 60 and 15552000 seconds');
      }

      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_uploadUrl?key=$_apiKey&expiration=$expirationSeconds'),
      );
      
      request.fields['image'] = base64Image;
      request.fields['name'] = imageFile.path.split('/').last;

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        
        if (jsonResponse['success'] == true) {
          return jsonResponse['data']['display_url'] as String;
        } else {
          throw Exception('ImgBB upload failed: ${jsonResponse['error']}');
        }
      } else {
        throw Exception('ImgBB upload failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error uploading to ImgBB with expiration: $e');
      rethrow;
    }
  }

  /// Get full response with all image URLs (original, thumb, medium)
  Future<Map<String, dynamic>> uploadImageDetailed(File imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      final request = http.MultipartRequest('POST', Uri.parse('$_uploadUrl?key=$_apiKey'));
      request.fields['image'] = base64Image;
      request.fields['name'] = imageFile.path.split('/').last;

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        
        if (jsonResponse['success'] == true) {
          return jsonResponse['data'] as Map<String, dynamic>;
        } else {
          throw Exception('ImgBB upload failed: ${jsonResponse['error']}');
        }
      } else {
        throw Exception('ImgBB upload failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error uploading to ImgBB: $e');
      rethrow;
    }
  }
}
