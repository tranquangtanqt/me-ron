# DATABASE.md - Database Schema Reference

Database: SQLite (`app_database.db`), version: 2 (see `lib/core/services/database/database_config.dart`)

## Tables

### Address

| Column    | Type     | Constraints                |
| --------- | -------- | --------------------------- |
| code      | TEXT     | PRIMARY KEY, NOT NULL       |
| name      | TEXT     |                              |
| createdAt | DATETIME | DEFAULT CURRENT_TIMESTAMP   |
| updatedAt | DATETIME | DEFAULT CURRENT_TIMESTAMP   |

### Categories

| Column      | Type     | Constraints                |
| ----------- | -------- | --------------------------- |
| id          | INTEGER  | PRIMARY KEY AUTOINCREMENT   |
| name        | TEXT     |                              |
| description | TEXT     |                              |
| createdAt   | DATETIME | DEFAULT CURRENT_TIMESTAMP   |
| updatedAt   | DATETIME | DEFAULT CURRENT_TIMESTAMP   |

### Users

Khách hàng (không phải tài khoản đăng nhập của ứng dụng).

| Column    | Type     | Constraints                |
| --------- | -------- | --------------------------- |
| id        | INTEGER  | PRIMARY KEY AUTOINCREMENT   |
| name      | TEXT     |                              |
| address   | TEXT     |                              |
| phone     | TEXT     |                              |
| note      | TEXT     |                              |
| createdAt | DATETIME | DEFAULT CURRENT_TIMESTAMP   |
| updatedAt | DATETIME | DEFAULT CURRENT_TIMESTAMP   |

### Products

| Column      | Type     | Constraints                       |
| ----------- | -------- | ---------------------------------- |
| id          | INTEGER  | PRIMARY KEY AUTOINCREMENT          |
| categoryId  | INTEGER  | FK → Categories(id)                |
| name        | TEXT     |                                     |
| imageUrl    | TEXT     |                                     |
| price       | INTEGER  |                                     |
| description | TEXT     |                                     |
| createdAt   | DATETIME | DEFAULT CURRENT_TIMESTAMP          |
| updatedAt   | DATETIME | DEFAULT CURRENT_TIMESTAMP          |

### Orders

| Column           | Type     | Constraints                |
| ---------------- | -------- | --------------------------- |
| id               | INTEGER  | PRIMARY KEY AUTOINCREMENT   |
| userId           | INTEGER  | FK → Users(id)               |
| status           | INTEGER  | 1 = shipping (đã lên đơn), 2 = completed (đã thanh toán), 3 = cancelled (huỷ) |
| deliveryDatetime | DATETIME | DEFAULT CURRENT_TIMESTAMP   |
| paymentDatetime  | DATETIME | DEFAULT CURRENT_TIMESTAMP   |
| discountValue    | INTEGER  |                              |
| subTotal         | INTEGER  |                              |
| total            | INTEGER  | total = subTotal - discountValue |
| note             | TEXT     |                              |
| createdAt        | DATETIME | DEFAULT CURRENT_TIMESTAMP   |
| updatedAt        | DATETIME | DEFAULT CURRENT_TIMESTAMP   |

### OrderItems

| Column        | Type     | Constraints                |
| ------------- | -------- | --------------------------- |
| id            | INTEGER  | PRIMARY KEY AUTOINCREMENT   |
| orderId       | INTEGER  | FK → Orders(id)              |
| productId     | INTEGER  | FK → Products(id)            |
| snapshotName  | TEXT     | tên món tại thời điểm đặt   |
| snapshotPrice | INTEGER  | đơn giá tại thời điểm đặt   |
| quantity      | INTEGER  |                              |
| lineTotal     | INTEGER  | lineTotal = snapshotPrice * quantity |
| createdAt     | DATETIME | DEFAULT CURRENT_TIMESTAMP   |
| updatedAt     | DATETIME | DEFAULT CURRENT_TIMESTAMP   |

### Purchases

Đợt nhập hàng / mua nguyên liệu.

| Column    | Type     | Constraints                |
| --------- | -------- | --------------------------- |
| id        | INTEGER  | PRIMARY KEY AUTOINCREMENT   |
| date      | TEXT     | DEFAULT (DATE('now'))       |
| total     | INTEGER  |                              |
| createdAt | DATETIME | DEFAULT CURRENT_TIMESTAMP   |
| updatedAt | DATETIME | DEFAULT CURRENT_TIMESTAMP   |

### PurchaseItems

| Column     | Type     | Constraints                |
| ---------- | -------- | --------------------------- |
| id         | INTEGER  | PRIMARY KEY AUTOINCREMENT   |
| purchaseId | INTEGER  | FK → Purchases(id)           |
| name       | TEXT     |                              |
| price      | INTEGER  |                              |
| createdAt  | DATETIME | DEFAULT CURRENT_TIMESTAMP   |
| updatedAt  | DATETIME | DEFAULT CURRENT_TIMESTAMP   |

### Transactions

Dùng cho luồng backup/import dữ liệu (`backup_data_screen.dart`, `import_data_screen.dart`), không phải bảng giao dịch chính của đơn hàng.

| Column              | Type     | Constraints                |
| ------------------- | -------- | --------------------------- |
| id                  | INTEGER  | PRIMARY KEY AUTOINCREMENT   |
| paymentMethod       | TEXT     |                              |
| customerName        | TEXT     |                              |
| description         | TEXT     |                              |
| createdById         | TEXT     | FK → Users(id)                |
| receivedAmount      | INTEGER  |                              |
| returnAmount        | INTEGER  |                              |
| totalAmount         | INTEGER  |                              |
| totalOrderedProduct | INTEGER  |                              |
| createdAt           | DATETIME | DEFAULT CURRENT_TIMESTAMP   |
| updatedAt           | DATETIME | DEFAULT CURRENT_TIMESTAMP   |

### QueuedActions

Hàng đợi thao tác đồng bộ (offline-first queue, ví dụ đồng bộ lên Google Drive).

| Column     | Type     | Constraints                |
| ---------- | -------- | --------------------------- |
| id         | INTEGER  | PRIMARY KEY AUTOINCREMENT   |
| repository | TEXT     |                              |
| method     | TEXT     |                              |
| param      | TEXT     |                              |
| isCritical | INTEGER  | 0 = false, 1 = true         |
| createdAt  | DATETIME | DEFAULT CURRENT_TIMESTAMP   |

## Migrations

- **v1 → v2**: thêm bảng `Purchases`, `PurchaseItems`.

## Relationships

```
Categories 1───* Products
Users      1───* Orders
Orders     1───* OrderItems ──* Products
Purchases  1───* PurchaseItems
```
