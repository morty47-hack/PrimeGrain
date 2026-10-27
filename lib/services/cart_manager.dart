import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/cart_item.dart';
import 'api_service.dart';
import 'session_service.dart';

class CartManager {
  CartManager._();

  static final CartManager instance = CartManager._();

  final ValueNotifier<List<CartItem>> items = ValueNotifier<List<CartItem>>([]);
  static const _cachePrefix = 'cart_cache_user_';

  int _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  double _asDouble(dynamic value) {
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  Future<void> refreshFromServer() async {
    final userId = await SessionService.getUserId();
    if (userId == null) {
      items.value = [];
      return;
    }

    final cached = await _loadCachedItems(userId);
    try {
      final data = await ApiService.cartList(userId: userId);
      final rawItems = (data['cart_items'] as List<dynamic>?) ??
          (data['items'] as List<dynamic>?) ??
          const [];

      final parsed = rawItems.map((e) {
        final m = e as Map<String, dynamic>;
        final productId = _asInt(m['product_id'] ?? m['id']);
        CartItem? cachedMatch;
        for (final c in cached) {
          if (c.productId == productId) {
            cachedMatch = c;
            break;
          }
        }

        return CartItem(
          cartId: _asInt(m['cart_id'] ?? m['id']),
          productId: productId,
          name: (m['name'] as String?) ?? '',
          image: (m['image'] as String?) ?? '',
          description: (m['description'] as String?) ?? '',
          segmentLabel: (m['segment_label'] as String?) ??
              (m['segment'] as String?) ??
              cachedMatch?.segmentLabel ??
              'Customer',
          unitPrice: _asDouble(m['unit_price']),
          kg: _asDouble(m['kg']),
          lineTotal: _asDouble(m['line_total']),
          isSelected: cachedMatch?.isSelected ?? true,
        );
      }).toList();

      if (parsed.isEmpty && cached.isNotEmpty) {
        items.value = cached;
      } else {
        items.value = parsed;
        await _saveCachedItems(userId, parsed);
      }
    } catch (_) {
      items.value = cached;
    }
  }

  Future<void> addItemToServer({
    required String appProductId,
    required String name,
    required String segmentLabel,
    required double unitPrice,
    required double kg,
  }) async {
    final userId = await SessionService.getUserId();
    if (userId == null) {
      throw Exception('Not logged in');
    }

    final productId = int.tryParse(appProductId);
    if (productId == null || productId <= 0) {
      throw Exception('Invalid product selected');
    }

    await ApiService.cartAddItem(
      userId: userId,
      productId: productId,
      kg: kg,
      segment: segmentLabel,
    );

    // Keep cart visible even if backend list endpoint shape differs.
    final existingIndex =
        items.value.indexWhere((item) => item.productId == productId);
    if (existingIndex >= 0) {
      final current = items.value[existingIndex];
      final updated = current.copyWith(
        kg: current.kg + kg,
        lineTotal: current.total + (unitPrice * kg),
        segmentLabel: segmentLabel,
      );
      final next = [...items.value];
      next[existingIndex] = updated;
      items.value = next;
    } else {
      items.value = [
        ...items.value,
        CartItem(
          cartId: 0,
          productId: productId,
          name: name,
          image: '',
          description: '',
          segmentLabel: segmentLabel,
          unitPrice: unitPrice,
          kg: kg,
          lineTotal: unitPrice * kg,
        ),
      ];
    }
    await _saveCachedItems(userId, items.value);

    await refreshFromServer();
  }

  Future<void> removeItemFromServer({required int productId}) async {
    final userId = await SessionService.getUserId();
    if (userId == null) {
      throw Exception('Not logged in');
    }
    await ApiService.cartRemoveItem(userId: userId, productId: productId);
    await refreshFromServer();
    await _saveCachedItems(userId, items.value);
  }

  Future<void> _saveCachedItems(int userId, List<CartItem> list) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = jsonEncode(list.map((e) => e.toJson()).toList());
    await prefs.setString('$_cachePrefix$userId', payload);
  }

  Future<List<CartItem>> _loadCachedItems(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('$_cachePrefix$userId');
    if (raw == null || raw.isEmpty) return const [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return const [];
      return decoded
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .map(CartItem.fromJson)
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> clearServer() async {
    final userId = await SessionService.getUserId();
    if (userId == null) {
      items.value = [];
      return;
    }
    await ApiService.cartClear(userId: userId);
    await refreshFromServer();
    await _saveCachedItems(userId, items.value);
  }

  double get total => items.value.fold(0.0, (sum, item) => sum + item.total);

  double get selectedTotal => items.value
      .where((item) => item.isSelected)
      .fold(0.0, (sum, item) => sum + item.total);

  void toggleSelection({
    required int productId,
    required bool isSelected,
  }) {
    items.value = items.value
        .map(
          (item) => item.productId == productId
              ? item.copyWith(isSelected: isSelected)
              : item,
        )
        .toList();
  }
}
