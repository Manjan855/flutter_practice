import 'package:flutter_practice/features/products/domain/entities/product_entity.dart';

/// Transport model: maps the API JSON (and the SQLite row cache) onto
/// [ProductEntity].
///
/// Parsing is defensive on purpose - a single malformed row from the backend
/// must not take down the whole catalogue.
class ProductModel extends ProductEntity {
  const ProductModel({
    required super.id,
    required super.price,
    required super.title,
    required super.thumbnail,
  });

  /// From an API payload. Returns `null` when the row has no usable id.
  static ProductModel? tryFromJson(Object? json) {
    if (json is! Map) return null;

    final id = _asInt(json['id']);
    if (id == null) return null;

    return ProductModel(
      id: id,
      price: _asDouble(json['price']) ?? 0,
      title: _asString(json['title']) ?? 'Untitled',
      thumbnail: _asString(json['thumbnail']) ?? '',
    );
  }

  /// Convenience factory for callers that already know the row is valid.
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final model = tryFromJson(json);
    if (model == null) {
      throw FormatException('Invalid product payload: $json');
    }
    return model;
  }

  /// From a `sqflite` row (`price REAL`, `id INTEGER`).
  factory ProductModel.fromMap(Map<String, Object?> map) {
    return ProductModel(
      id: _asInt(map['id']) ?? 0,
      price: _asDouble(map['price']) ?? 0,
      title: _asString(map['title']) ?? 'Untitled',
      thumbnail: _asString(map['thumbnail']) ?? '',
    );
  }

  Map<String, Object?> toMap() => {
    'id': id,
    'title': title,
    'price': price,
    'thumbnail': thumbnail,
  };

  // --- coercion helpers -----------------------------------------------------

  static int? _asInt(Object? value) {
    if (value is int) return value;
    if (value is double) return value.round();
    if (value is String) return int.tryParse(value.trim());
    return null;
  }

  static double? _asDouble(Object? value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value.trim());
    return null;
  }

  static String? _asString(Object? value) {
    if (value is String) return value;
    if (value == null) return null;
    return value.toString();
  }
}
