import 'package:flutter_test/flutter_test.dart';
import 'package:kasirmadura/data/models/product.dart';

void main() {
  test('Product.fromJson parses data correctly', () {
    final json = {
      'id': 1,
      'nama': 'Indomie',
      'hargaJual': 3000,
      'stok': 10,
      'satuan': 'pcs',
      'imageName': 'indomie.png',
    };

    final product = Product.fromJson(json);

    expect(product.id, 1);
    expect(product.nama, 'Indomie');
    expect(product.hargaJual, 3000.0);
    expect(product.stok, 10);
    expect(product.satuan, 'pcs');
    expect(product.imageName, 'indomie.png');
  });

  test('Product.fromJson handles null imageName', () {
    final json = {
      'id': 2,
      'nama': 'Teh Botol',
      'hargaJual': 4000,
      'stok': 5,
      'satuan': 'botol',
      'imageName': null,
    };

    final product = Product.fromJson(json);

    expect(product.imageName, '');
  });
}
