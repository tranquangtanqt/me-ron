class DatabaseConfig {
  // Prevents instantiation and extension
  DatabaseConfig._();

  static const String dbPath = 'app_database.db';
  static const int version = 1;

  static const String addressTableName = 'Address';
  static const String userTableName = 'Users';
  static const String categoriesTableName = 'Categories';
  static const String productTableName = 'Products';
  static const String orderTableName = 'Orders';
  static const String paymentTableName = 'Payments';
  static const String paymentOrderTableName = 'PaymentOrders';
  static const String orderItemTableName = 'OrderItems';
  static const String transactionTableName = 'Transactions';
  static const String queuedActionTableName = 'QueuedActions';

  static const String createAddressTable =
  '''
CREATE TABLE IF NOT EXISTS '$addressTableName' (
    'code' TEXT NOT NULL,
    'name' TEXT,
    'createdAt' DATETIME DEFAULT CURRENT_TIMESTAMP,
    'updatedAt' DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY ('code')
);
''';

  static const String createCategoryTable =
  '''
CREATE TABLE IF NOT EXISTS '$categoriesTableName' (
    'id' INTEGER PRIMARY KEY AUTOINCREMENT,
    'name' TEXT,
    'description' TEXT,
    createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
    updatedAt DATETIME DEFAULT CURRENT_TIMESTAMP
);
''';

  static const String createUserTable =
      '''
CREATE TABLE IF NOT EXISTS '$userTableName' (
    'id' INTEGER PRIMARY KEY AUTOINCREMENT,
    'name' TEXT,
    'address' TEXT,
    'phone' TEXT,
    'note' TEXT,
    'createdAt' DATETIME DEFAULT CURRENT_TIMESTAMP,
    'updatedAt' DATETIME DEFAULT CURRENT_TIMESTAMP
);
''';

  static const String createProductTable =
      '''
CREATE TABLE IF NOT EXISTS '$productTableName' (
    'id' INTEGER PRIMARY KEY AUTOINCREMENT,
    'categoryId' INTEGER,
    'name' TEXT,
    'imageUrl' TEXT,
    'price' INTEGER,
    'description' TEXT,
    createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
    updatedAt DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY ('categoryId') REFERENCES 'categories' ('id')
);
''';

  static const String createOrderTable =
  '''
CREATE TABLE IF NOT EXISTS '$orderTableName' (
    'id' INTEGER PRIMARY KEY AUTOINCREMENT,
    'userId' INTEGER,
    'status' INTEGER,
    'deliveryDatetime' DATETIME DEFAULT CURRENT_TIMESTAMP,
    'discountValue' INTEGER,
    'subTotal' INTEGER,
    'total' INTEGER,
    'note' TEXT,
    'createdAt' DATETIME DEFAULT CURRENT_TIMESTAMP,
    'updatedAt' DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY ('userId') REFERENCES 'users' ('id')
);
''';
// total = subTotal - discountValue
//  tong = tong - giam gia

  static const String createOrderItemTable =
  '''
CREATE TABLE IF NOT EXISTS '$orderItemTableName' (
    'id' INTEGER PRIMARY KEY AUTOINCREMENT,
    'orderId' INTEGER,
    'productId' INTEGER,
    'snapshotName' TEXT,
    'snapshotPrice' INTEGER,
    'quantity' INTEGER,
    'lineTotal' INTEGER,
    'createdAt' DATETIME DEFAULT CURRENT_TIMESTAMP,
    'updatedAt' DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY ('orderId') REFERENCES 'orders' ('id'),
    FOREIGN KEY ('productId') REFERENCES 'products' ('id')
);
''';
// lineTotal = snapshotPrice * quantity
// tong cua dong hien tai = gia * so luong
  static const String createPaymentTable =
  '''
CREATE TABLE IF NOT EXISTS '$paymentTableName' (
    'id' INTEGER PRIMARY KEY AUTOINCREMENT,
    'paymentMethod' INTEGER,
    'amount' INTEGER,
    'paymentDate' DATETIME DEFAULT CURRENT_TIMESTAMP,
    'createdAt' DATETIME DEFAULT CURRENT_TIMESTAMP,
    'updatedAt' DATETIME DEFAULT CURRENT_TIMESTAMP
);
''';
// amount: số tiền khách trả.
// ví dụ lần 1: 50.000, lần 2: 40.000
  static const String createPaymentOrderTable =
  '''
CREATE TABLE IF NOT EXISTS '$paymentOrderTableName' (
    'id' INTEGER PRIMARY KEY AUTOINCREMENT,
    'paymentId' INTEGER NOT NULL,
    'orderId' INTEGER NOT NULL,
    'paidAmount' INTEGER NOT NULL,
    'createdAt' DATETIME DEFAULT CURRENT_TIMESTAMP,
    'updatedAt' DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (paymentId) REFERENCES Payments(id),
    FOREIGN KEY (orderId) REFERENCES Orders(id)
);
''';
//paidAmount: số tiền chia cô từng đơn dựa vào payment.amount

  static const String createTransactionTable =
      '''
CREATE TABLE IF NOT EXISTS '$transactionTableName' (
    'id' INTEGER PRIMARY KEY AUTOINCREMENT,
    'paymentMethod' TEXT,
    'customerName' TEXT,
    'description' TEXT,
    'createdById' TEXT,
    'receivedAmount' INTEGER,
    'returnAmount' INTEGER,
    'totalAmount' INTEGER,
    'totalOrderedProduct' INTEGER,
    'createdAt' DATETIME DEFAULT CURRENT_TIMESTAMP,
    'updatedAt' DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY ('createdById') REFERENCES 'User' ('id')
);
''';

  static const String createQueuedActionTable =
      '''
CREATE TABLE IF NOT EXISTS '$queuedActionTableName' (
    'id' INTEGER PRIMARY KEY AUTOINCREMENT,
    'repository' TEXT,
    'method' TEXT,
    'param' TEXT,
    'isCritical' INTEGER,
    'createdAt' DATETIME DEFAULT CURRENT_TIMESTAMP
);
''';

  static const String insertAddressTable =
  '''
INSERT INTO '$addressTableName' ('code', 'name')
VALUES  ('W1', 'Tòa nhà W1'),
       ('W2', 'Tòa nhà W2'),
       ('W3', 'Tòa nhà W3'),
       ('W4', 'Tòa nhà W4'),
       ('00', 'Khác');
''';

  static const String insertCategoriesTable =
  '''
INSERT INTO '$categoriesTableName' ('name', 'description')
VALUES  ('Bánh bao', NULL),
       ('Sữa chua', NULL),
       ('Kem', NULL),
       ('Khác', NULL);
''';

  static const String insertProductTable =
  '''
INSERT INTO '$productTableName' ('categoryId', 'name', 'price')
VALUES  (1, 'Bánh bao không nhân', 5000),
       (1, 'Bánh bao thịt trứng', 10000),
       (1, 'Bánh bao pho mai', 15000);
''';

  static const String insertUserTable =
  '''
INSERT INTO '$userTableName' ('name', 'address', 'phone')
VALUES  
  ('W2 907 Chị Huyền', 'Tòa nhà W2', '0123456789'),
  ('W2 911 Chị Dung', 'Tòa nhà W2', '0123456789'),
  ('W3 AAA', 'Tòa nhà W3', '0123456789');
''';

  static const String insertOrderTable =
  '''
INSERT INTO '$orderTableName' ('userId', 'status', 'discountValue', 'subTotal', 'total', 'deliveryDatetime')
VALUES  ('1', '1', 1000, 25000, 24000, '2026-06-02T00:00:00.000'),
       ('1', '1', 2000, 10000, 8000, '2026-06-02T00:00:00.000'),
       ('2', '1', 3000, 30000, 28000, '2026-06-02T00:00:00.000');
''';

  static const String insertOrderItemTable =
  '''
INSERT INTO '$orderItemTableName' ('orderId', 'productId', 'snapshotName', 'snapshotPrice', 'quantity', 'lineTotal')
VALUES  
  ('1', '1', 'Bánh bao không nhân', 5000, 1, 5000),
  ('1', '2', 'Bánh bao thịt trứng', 10000, 2, 20000),
  ('2', '1', 'Bánh bao không nhân', 5000, 2, 10000),
  ('3', '2', 'Bánh bao thịt trứng', 10000, 3, 30000);
''';
}
