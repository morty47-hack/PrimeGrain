import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  ApiService._();

  // ✅ USE YOUR PC IP (NOT localhost)
  static const String baseUrl = 'http://192.168.1.250/primegrain/api';

  // ✅ STK PUSH ENDPOINT
  static const String stkPushUrl =
      'http://192.168.1.250/primegrain/api/stk_push.php';
  
  static Uri get stkPushUri => Uri.parse(stkPushUrl);

  // =========================
  // 🔥 LOGIN
  // =========================
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final uri = Uri.parse('$baseUrl/login.php');

    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    return _handleResponse(res);
  }

  // =========================
  // 🔥 STK PUSH (M-PESA)
  // =========================
  static Future<Map<String, dynamic>> stkPush({
    required String phone,
    required int amount,
  }) async {
    final res = await http.post(
      stkPushUri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'phone': phone,
        'amount': amount,
      }),
    );

    // ✅ DEBUG (VERY IMPORTANT)
    print("STK STATUS: ${res.statusCode}");
    print("STK RESPONSE: ${res.body}");

    return _handleResponse(res);
  }

  // =========================
  // 🔥 CART CLEAR
  // =========================
  static Future<void> cartClear({required int userId}) async {
    await _post('cart/clear.php', {'user_id': userId});
  }

  static Future<Map<String, dynamic>> cartAddItem({
    required int userId,
    required int productId,
    required double kg,
    String? segment,
  }) async {
    final payload = <String, dynamic>{
      'user_id': userId,
      'product_id': productId,
      'kg': kg,
    };

    if (segment != null) {
      payload['segment'] = segment;
    }

    return _post('cart/add_item.php', payload);
  }

  static Future<Map<String, dynamic>> cartList({
    required int userId,
  }) async {
    return _post('cart/list.php', {'user_id': userId});
  }

  static Future<Map<String, dynamic>> cartRemoveItem({
    required int userId,
    required int productId,
  }) async {
    return _post('cart/remove_item.php', {
      'user_id': userId,
      'product_id': productId,
    });
  }

  static Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> body,
  ) async {
    final uri = Uri.parse('$baseUrl/$path');

    final res = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    print("POST [$path] STATUS: ${res.statusCode}");
    print("POST [$path] RESPONSE: ${res.body}");

    return _handleResponse(res);
  }

  static Map<String, dynamic> _handleResponse(http.Response res) {
    try {
      final body = res.body;

      if (body.isEmpty) {
        throw Exception("Empty response from server");
      }

      final decoded = jsonDecode(body);

      if (decoded is! Map<String, dynamic>) {
        throw Exception("Invalid JSON format");
      }

      return decoded;
    } catch (e) {
      throw Exception("Response error: $e");
    }
  }
}
