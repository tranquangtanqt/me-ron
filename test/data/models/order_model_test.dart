import 'package:flutter_test/flutter_test.dart';
import 'package:me_ron/data/models/order_model.dart';

void main() {
  group('OrderModel.fromJson', () {
    test('parses nested items from JSON when present', () {
      final json = {
        'id': 1,
        'items': [
          {
            'id': 10,
            'productId': 2,
            'snapshotName': 'Tea',
            'quantity': 3,
            'lineTotal': 300,
          }
        ],
      };

      final model = OrderModel.fromJson(json);

      expect(model.items, isNotNull);
      expect(model.items, hasLength(1));
      expect(model.items!.first.productId, 2);
      expect(model.items!.first.snapshotName, 'Tea');
    });

    test('creates a single item from flat order-row fields', () {
      final json = {
        'id': 1,
        'orderItemId': 10,
        'productId': 2,
        'snapshotName': 'Tea',
        'quantity': 3,
        'lineTotal': 300,
      };

      final model = OrderModel.fromJson(json);

      expect(model.items, isNotNull);
      expect(model.items, hasLength(1));
      expect(model.items!.first.productId, 2);
      expect(model.items!.first.quantity, 3);
    });
  });
}
