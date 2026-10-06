import 'package:flutter_practice/features/products/data/models/product_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProductModel.tryFromJson', () {
    test('parses a well-formed payload', () {
      final model = ProductModel.tryFromJson({
        'id': 7,
        'title': 'Tractor',
        'price': 250.5,
        'thumbnail': 'https://example.com/t.png',
      });

      expect(model, isNotNull);
      expect(model!.id, 7);
      expect(model.title, 'Tractor');
      expect(model.price, 250.5);
      expect(model.thumbnail, 'https://example.com/t.png');
    });

    test('coerces id and price when the backend sends strings', () {
      final model = ProductModel.tryFromJson({
        'id': '42',
        'price': '99.99',
        'title': 'Bulldozer',
        'thumbnail': '',
      });

      expect(model!.id, 42);
      expect(model.price, 99.99);
    });

    test('rounds a double id down to an int', () {
      expect(ProductModel.tryFromJson({'id': 12.0})?.id, 12);
      expect(ProductModel.tryFromJson({'id': 12.7})?.id, 13);
    });

    test('rejects a payload with no usable id', () {
      expect(ProductModel.tryFromJson({'title': 'No id'}), isNull);
      expect(ProductModel.tryFromJson({'id': null}), isNull);
      expect(ProductModel.tryFromJson({'id': 'not-a-number'}), isNull);
    });

    test('rejects non-map payloads', () {
      expect(ProductModel.tryFromJson(null), isNull);
      expect(ProductModel.tryFromJson('string'), isNull);
      expect(ProductModel.tryFromJson([1, 2, 3]), isNull);
    });

    test('applies safe defaults for optional fields', () {
      final model = ProductModel.tryFromJson({'id': 1});

      expect(model!.title, 'Untitled');
      expect(model.thumbnail, '');
      expect(model.price, 0);
    });
  });

  group('ProductModel.fromMap (sqflite row)', () {
    test('reads the cached columns', () {
      final model = ProductModel.fromMap({
        'id': 3,
        'title': 'Cached',
        'price': 10.0,
        'thumbnail': 'thumb.png',
      });

      expect(model.id, 3);
      expect(model.title, 'Cached');
      expect(model.price, 10.0);
      expect(model.thumbnail, 'thumb.png');
    });

    test('survives a row with nulls', () {
      final model = ProductModel.fromMap({
        'id': 4,
        'title': null,
        'price': null,
        'thumbnail': null,
      });

      expect(model.id, 4);
      expect(model.title, 'Untitled');
      expect(model.price, 0);
      expect(model.thumbnail, '');
    });
  });

  group('round trip', () {
    test('toMap -> fromMap preserves every field', () {
      const original = ProductModel(
        id: 9,
        title: 'JCB',
        price: 4500,
        thumbnail: 'jcb.png',
      );

      final restored = ProductModel.fromMap(original.toMap());

      expect(restored.id, original.id);
      expect(restored.title, original.title);
      expect(restored.price, original.price);
      expect(restored.thumbnail, original.thumbnail);
    });
  });
}
