/// A vehicle as returned by the catalogue API / stored in the SQLite cache.
///
/// The presentation layer only ever sees this type - it has no knowledge of
/// JSON column names or HTTP payloads.
class ProductEntity {
  const ProductEntity({
    required this.id,
    required this.price,
    required this.thumbnail,
    required this.title,
  });

  final int id;
  final String title;
  final double price;
  final String thumbnail;
}
