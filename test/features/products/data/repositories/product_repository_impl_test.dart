import 'package:dio/dio.dart';
import 'package:flutter_practice/core/errors/failures.dart';
import 'package:flutter_practice/features/products/data/datasources/product_local_datasource.dart';
import 'package:flutter_practice/features/products/data/datasources/product_remote_datasource.dart';
import 'package:flutter_practice/features/products/data/models/product_model.dart';
import 'package:flutter_practice/features/products/data/repositories/product_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockProductRemoteDatasource extends Mock
    implements ProductRemoteDatasource {}

class MockProductLocalDatasource extends Mock
    implements ProductLocalDatasource {}

void main() {
  late MockProductRemoteDatasource remote;
  late MockProductLocalDatasource local;
  late ProductRepositoryImpl repository;

  const remoteProduct = ProductModel(
    id: 1,
    title: 'Remote vehicle',
    price: 100,
    thumbnail: 'https://example.com/a.png',
  );

  const cachedProduct = ProductModel(
    id: 2,
    title: 'Cached vehicle',
    price: 50,
    thumbnail: '',
  );

  DioException networkError() => DioException(
    type: DioExceptionType.connectionError,
    requestOptions: RequestOptions(path: '/vehicles'),
  );

  setUp(() {
    remote = MockProductRemoteDatasource();
    local = MockProductLocalDatasource();
    repository = ProductRepositoryImpl(remote, local);
  });

  group('getProducts - happy path', () {
    test('returns remote products and writes them to the cache', () async {
      when(() => remote.fetchProducts()).thenAnswer(
        (_) async => const [remoteProduct],
      );
      when(() => local.cacheProducts([remoteProduct]))
          .thenAnswer((_) async {});

      final result = await repository.getProducts();

      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Expected Right, got Left: ${failure.message}'),
        (products) => expect(products, [remoteProduct]),
      );
      verify(() => local.cacheProducts([remoteProduct])).called(1);
      verifyNever(() => local.getCachedProducts());
    });
  });

  group('getProducts - offline fallback', () {
    test('falls back to the cache when the network fails', () async {
      when(() => remote.fetchProducts()).thenThrow(networkError());
      when(() => local.getCachedProducts())
          .thenAnswer((_) async => const [cachedProduct]);

      final result = await repository.getProducts();

      expect(result.isRight(), true);
      result.fold(
        (failure) => fail('Expected Right, got Left: ${failure.message}'),
        (products) => expect(products, [cachedProduct]),
      );
    });

    test(
      'returns a network failure when the network fails and the cache is empty',
      () async {
        when(() => remote.fetchProducts()).thenThrow(networkError());
        when(() => local.getCachedProducts()).thenAnswer((_) async => const []);

        final result = await repository.getProducts();

        expect(result.isLeft(), true);
        result.fold(
          (failure) {
            expect(failure, isA<ServerFailure>());
            expect(failure.message.toLowerCase(), contains('connection'));
          },
          (products) => fail('Expected Left, got Right: $products'),
        );
      },
    );

    test('reports a distinct message for a server (HTTP) error', () async {
      when(() => remote.fetchProducts()).thenThrow(
        DioException(
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: RequestOptions(path: '/vehicles'),
            statusCode: 500,
          ),
          requestOptions: RequestOptions(path: '/vehicles'),
        ),
      );
      when(() => local.getCachedProducts()).thenAnswer((_) async => const []);

      final result = await repository.getProducts();

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure.message, contains('500')),
        (_) => fail('Expected Left'),
      );
    });
  });

  group('getProducts - unexpected errors', () {
    test('returns a generic failure without leaking the raw exception', () async {
      when(() => remote.fetchProducts())
          .thenThrow(const FormatException('bad payload'));
      when(() => local.getCachedProducts()).thenAnswer((_) async => const []);

      final result = await repository.getProducts();

      expect(result.isLeft(), true);
      result.fold(
        (failure) {
          expect(failure, isA<ServerFailure>());
          expect(failure.message, isNot(contains('FormatException')));
        },
        (_) => fail('Expected Left'),
      );
    });
  });
}
