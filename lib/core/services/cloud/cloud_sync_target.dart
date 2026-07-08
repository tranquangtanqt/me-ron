import '../database/database_config.dart';

class CloudSyncTarget {
  final String tableName;
  final String title;
  final String? identityColumn;

  const CloudSyncTarget({
    required this.tableName,
    required this.title,
    this.identityColumn,
  });
}

/// Tables kept in sync with the cloud, in dependency order
/// (Address → Categories → Users → Products → Orders → OrderItems → Purchases → PurchaseItems).
const cloudSyncTargets = <CloudSyncTarget>[
  CloudSyncTarget(
    tableName: DatabaseConfig.addressTableName,
    title: 'Địa chỉ (Address)',
  ),
  CloudSyncTarget(
    tableName: DatabaseConfig.categoriesTableName,
    title: 'Danh mục món ăn (Categories)',
    identityColumn: 'id',
  ),
  CloudSyncTarget(
    tableName: DatabaseConfig.userTableName,
    title: 'Khách hàng (Users)',
    identityColumn: 'id',
  ),
  CloudSyncTarget(
    tableName: DatabaseConfig.productTableName,
    title: 'Món ăn (Products)',
    identityColumn: 'id',
  ),
  CloudSyncTarget(
    tableName: DatabaseConfig.orderTableName,
    title: 'Đơn hàng (Orders)',
    identityColumn: 'id',
  ),
  CloudSyncTarget(
    tableName: DatabaseConfig.orderItemTableName,
    title: 'Chi tiết đơn hàng (OrderItems)',
    identityColumn: 'id',
  ),
  CloudSyncTarget(
    tableName: DatabaseConfig.purchaseTableName,
    title: 'Phiếu nhập (Purchases)',
    identityColumn: 'id',
  ),
  CloudSyncTarget(
    tableName: DatabaseConfig.purchaseItemTableName,
    title: 'Chi tiết phiếu nhập (PurchaseItems)',
    identityColumn: 'id',
  ),
];
