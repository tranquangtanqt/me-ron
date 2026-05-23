class DatabaseConfig {
  // Prevents instantiation and extension
  DatabaseConfig._();

  static const String dbPath = 'app_database.db';
  static const int version = 1;

  static const String addressTableName = 'Address';
  static const String userTableName = 'Users';
  static const String categoriesTableName = 'Categories';
  static const String productTableName = 'Products';
  static const String transactionTableName = 'Transactions';
  static const String orderedProductTableName = 'OrderedProducts';
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
    'id' INTEGER NOT NULL,
    'name' TEXT,
    'description' TEXT,
    createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
    updatedAt DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY ('id')
);
''';

  static const String createUserTable =
      '''
CREATE TABLE IF NOT EXISTS '$userTableName' (
    'id' TEXT NOT NULL,
    'email' TEXT,
    'phone' TEXT,
    'name' TEXT,
    'gender' TEXT,
    'birthdate' TEXT,
    'imageUrl' TEXT,
    'authProvider' TEXT,
    'createdAt' DATETIME DEFAULT CURRENT_TIMESTAMP,
    'updatedAt' DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY ('id')
);
''';

  static const String createProductTable =
      '''
CREATE TABLE IF NOT EXISTS '$productTableName' (
    'id' INTEGER NOT NULL,
    'createdById' TEXT,
    'name' TEXT,
    'imageUrl' TEXT,
    'stock' INTEGER,
    'sold' INTEGER,
    'price' INTEGER,
    'description' TEXT,
    createdAt DATETIME DEFAULT CURRENT_TIMESTAMP,
    updatedAt DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY ('id'),
    FOREIGN KEY ('createdById') REFERENCES 'User' ('id')
);
''';

  static const String createTransactionTable =
      '''
CREATE TABLE IF NOT EXISTS '$transactionTableName' (
    'id' INTEGER NOT NULL,
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
    PRIMARY KEY ('id'),
    FOREIGN KEY ('createdById') REFERENCES 'User' ('id')
);
''';

  static const String createOrderedProductTable =
      '''
CREATE TABLE IF NOT EXISTS '$orderedProductTableName' (
    'id' INTEGER NOT NULL,
    'transactionId' INTEGER,
    'productId' INTEGER,
    'quantity' INTEGER,
    'stock' INTEGER,
    'name' TEXT,
    'imageUrl' TEXT,
    'price' INTEGER,
    'createdAt' DATETIME DEFAULT CURRENT_TIMESTAMP,
    'updatedAt' DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY ('id'),
    FOREIGN KEY ('transactionId') REFERENCES 'Transaction' ('id'),
    FOREIGN KEY ('productId') REFERENCES 'Product' ('id')
);
''';

  static const String createQueuedActionTable =
      '''
CREATE TABLE IF NOT EXISTS '$queuedActionTableName' (
    'id' INTEGER NOT NULL,
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
}
