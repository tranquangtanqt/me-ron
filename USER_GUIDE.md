# USER_GUIDE.md - Hướng dẫn sử dụng ứng dụng

Ứng dụng quản lý bán hàng (đặt món, nhập hàng, khách hàng, thống kê) chạy **offline-first** trên
SQLite local, có thể sao lưu/đồng bộ dữ liệu lên Google Drive / Firestore.

> Tài liệu này mô tả đúng những gì đang hoạt động trên giao diện hiện tại. Một vài màn hình đã
> được lập trình sẵn nhưng đang **bị ẩn/khoá** khỏi menu — các chỗ đó được ghi chú rõ bằng khối
> trích dẫn (>) ngay tại mục liên quan, và tổng hợp lại ở [Phụ lục A](#phụ-lục-a-tính-năng-đã-code-nhưng-chưa-bật-trên-giao-diện).

## 1. Điều hướng chính

Sau khi mở ứng dụng, thanh điều hướng dưới cùng có 5 mục:

| Tab       | Icon | Nội dung                                     |
| --------- | ---- | --------------------------------------------- |
| Trang chủ | 🏠   | Lối tắt tới các chức năng chính + giỏ hàng nhanh |
| Orders    | 🗂️   | Danh sách & tạo đơn đặt hàng                   |
| Thống kê  | 🧾   | 4 loại báo cáo doanh thu / món ăn / khách hàng |
| Danh mục  | 🗃️   | Quản lý Địa chỉ và Danh mục món ăn             |
| Cài đặt   | ⚙️   | Giao diện, lịch tự động sao lưu, sao lưu dữ liệu |

Ứng dụng dùng SQLite local (`app_database.db`) làm nguồn dữ liệu chính — mọi thao tác vẫn hoạt
động khi không có mạng; việc đồng bộ lên đám mây là thao tác **thủ công** (xem mục 10), không tự
động chạy nền liên tục.

## 2. Trang chủ

### Lối tắt

- **Đặt hàng** → mở màn hình Đặt hàng (`/order`).
- **Mua hàng** → mở màn hình Mua hàng (`/purchase`).
- **Khách hàng** → mở màn hình quản lý Khách hàng (`/user`).
- **Món ăn** → mở màn hình quản lý Món ăn (`/product`).
- **Thống kê** → mở màn hình Thống kê (`/report`).

### Panel giỏ hàng thanh toán nhanh

Kéo panel ở đáy màn hình lên để mở giỏ hàng — đây là luồng bán hàng nhanh kiểu **POS**, tách biệt
hoàn toàn với luồng "Đặt hàng" chính (không tạo bản ghi trong bảng `Orders`, mà tạo một
**Giao dịch** trong bảng `Transactions` — xem mục 9). Trong panel:

- Danh sách món đã thêm vào giỏ, mỗi dòng cho chỉnh số lượng hoặc xoá khỏi giỏ.
- Dòng tổng cộng ở cuối (`Total (số món)` — tổng tiền).
- Nút dưới cùng: khi giỏ chưa mở rộng hiện `"<n> Products = <tổng tiền>"`, bấm để mở rộng panel;
  khi mở rộng đổi thành nút **Pay** để sang bước nhập thông tin thanh toán.

## 3. Đặt hàng (Orders)

### Danh sách đơn

- Lọc theo trạng thái bằng các chip: **Tất cả / Đã lên đơn / Đã thanh toán / Huỷ**.
- Lọc theo khách hàng: gõ tên vào ô autocomplete, bấm nút "x" để bỏ lọc.
- Lọc theo khoảng ngày giao hàng: **Từ ngày – Đến ngày** (mặc định là hôm nay), chạm để mở lịch
  chọn ngày.
- Bộ lọc tự động tìm kiếm ngay khi mở màn hình và mỗi khi đổi trạng thái/khách hàng; còn khi đổi
  ngày thì cần bấm nút kính lúp để tìm.
- Kéo xuống để làm mới (pull-to-refresh); danh sách phân trang — cuộn hết trang rồi bấm
  **"Xem thêm"** để tải tiếp.
- Mỗi thẻ đơn tô màu nền theo trạng thái (Đã thanh toán: xanh lá nhạt, Huỷ: đỏ nhạt, Đã lên đơn:
  không tô màu). Chạm vào thẻ để mở màn hình sửa đơn.

### Nút "Chi tiết" (góc trên bên phải danh sách)

Tải **toàn bộ** đơn hàng (không giới hạn theo trang) và gộp theo từng khách hàng, hiển thị tổng
tiền mỗi khách. Nếu còn ít nhất 1 đơn ở trạng thái "Đã lên đơn", nút **"Thanh toán toàn bộ"** xuất
hiện trên AppBar:

- Bấm vào sẽ hỏi xác nhận, sau đó lần lượt chuyển **tất cả** đơn đang "Đã lên đơn" của danh sách
  hiện tại sang trạng thái "Đã thanh toán".
- Nếu 1 trong các đơn đã ở trạng thái "Đã thanh toán" từ trước, hệ thống sẽ báo lỗi và huỷ thao
  tác thanh toán hàng loạt (tránh thanh toán trùng).

### Nút "Thêm" — tạo đơn mới

1. Chọn khách hàng (autocomplete, có thể xoá lựa chọn bằng nút "x").
2. Bấm **"Thêm món"** để thêm từng dòng: chọn món ăn từ dropdown, tăng/giảm số lượng bằng nút
   `-`/`+` (tối thiểu 1), hoặc bấm dấu `x` để xoá dòng.
3. Nhập **Giảm giá** (nếu có).
4. Tổng tiền tự tính và hiển thị ở góc phải: `Tổng = Tạm tính - Giảm giá` (không âm).
5. Chọn **Ngày giao hàng**.
6. Bật công tắc **"Đã thanh toán trước"** nếu khách trả tiền ngay lúc lên đơn — khi bật sẽ hiện
   thêm ô chọn **Ngày thanh toán**.
7. Nhập **Ghi chú** (tuỳ chọn).
8. Bấm **Lưu** (icon ở AppBar).

> **Cảnh báo trùng đơn**: khi lưu (cả tạo mới lẫn sửa), nếu khách hàng đã có đơn khác trong cùng
> ngày giao hàng (không tính đơn đã huỷ, và khi sửa thì không tính chính đơn đang sửa), ứng dụng
> hiện hộp thoại "Cảnh báo trùng đơn" với 2 lựa chọn: **Hủy** (quay lại chỉnh sửa) hoặc
> **Vẫn lưu** (tiếp tục lưu như bình thường).

### Sửa đơn

Mở lại y hệt form tạo đơn, với 1 quy tắc riêng: nếu giá bán của một món trong đơn **đã bị đổi**
so với đơn giá được lưu tại thời điểm đặt (snapshot), dòng món đó sẽ **bị khoá hoàn toàn** (làm mờ,
không cho đổi món / đổi số lượng / xoá dòng) để giữ nguyên lịch sử đơn giá cũ. Muốn thay đổi món đó
phải xoá cả đơn và tạo lại.

### Huỷ đơn / Xoá đơn

Ở cuối màn hình sửa đơn:

- **Huỷ đơn** (chỉ hiện khi đơn chưa ở trạng thái Huỷ): chuyển trạng thái đơn sang "Huỷ", vẫn giữ
  lại toàn bộ dữ liệu đơn để tra cứu, không tính vào các báo cáo doanh thu.
- **Xóa đơn**: xoá hẳn đơn (và các dòng món của đơn) khỏi hệ thống, không thể hoàn tác.

## 4. Mua hàng (Purchase)

Dùng để ghi nhận các đợt nhập nguyên liệu / mua hàng theo từng ngày (phiếu nhập):

- Chọn **Ngày nhập** (mặc định hôm nay).
- Bấm **"Thêm hàng"** để thêm từng khoản mục: nhập **Tên hàng** và **Giá tiền**; mỗi dòng có nút
  xoá riêng.
- **Tổng** tự cộng từ giá các khoản mục và hiển thị ở góc phải.
- Bấm **Lưu** (icon AppBar) để tạo/cập nhật phiếu.
- Nút **Xóa phiếu** ở cuối màn hình sửa để xoá cả phiếu nhập (và toàn bộ khoản mục bên trong).

Danh sách phiếu nhập ở màn hình chính hiển thị theo ngày; chạm vào 1 phiếu để sửa.

## 5. Khách hàng (User)

- Ô **tìm kiếm theo tên** ở đầu danh sách: nhập tên rồi bấm nút kính lúp (hoặc Enter) để lọc,
  không phân biệt hoa/thường. Việc lọc thực hiện ngay trên danh sách đã tải (toàn bộ khách hàng
  được tải 1 lần, không phân trang), nên tìm kiếm phản hồi tức thì.
- Danh sách hiển thị dạng bảng: **STT / Tên / Số ĐT / Địa chỉ**. Chạm vào 1 dòng để mở màn hình
  sửa.
- Nút **"Thêm"** (góc trên phải) → mở form tạo khách hàng mới với các trường: **Tên**,
  **Số điện thoại**, **Địa chỉ**, **Ghi chú**.
- **Xoá khách hàng**: chỉ thực hiện được từ bên trong màn hình sửa (nút Xóa ở cuối form), danh
  sách không có nút xoá nhanh.
- **Trùng tên**: khi Lưu (thêm mới hoặc sửa), nếu tên khách hàng trùng với 1 khách hàng khác đã
  có trong hệ thống (không phân biệt hoa/thường), ứng dụng báo lỗi
  `Tên khách hàng "..." đã tồn tại` và không cho lưu. Khi **sửa**, hệ thống tự loại trừ chính
  khách hàng đang sửa khỏi việc kiểm tra này — nên giữ nguyên tên cũ (không đổi) vẫn lưu được
  bình thường.

Khách hàng ở đây được dùng để gán cho đơn đặt hàng và xuất hiện trong các báo cáo.

## 6. Món ăn (Product)

- Ô **tìm kiếm theo tên** ở đầu danh sách: nhập tên món rồi bấm nút kính lúp (hoặc Enter) để lọc.
  Khác với Khách hàng, danh sách món ăn tải phân trang từ server, nên tìm kiếm sẽ gọi lại truy vấn
  (tìm theo kiểu "chứa chuỗi", không phân biệt hoa/thường) thay vì lọc trên dữ liệu đã tải; kéo
  xuống cuối danh sách kết quả tìm kiếm vẫn tải thêm được (giữ nguyên từ khoá).
- Danh sách hiển thị dạng bảng: **STT / Tên / Giá**, sắp theo thứ tự tải về. Chạm vào 1 dòng để
  sửa.
- Nút **"Thêm"** → form tạo món ăn mới gồm: **Danh mục** (autocomplete, chọn từ Danh mục món ăn),
  **Tên món ăn**, **Giá bán**, **Mô tả**.

> Phần chọn/tải **ảnh món ăn** và nút **Xóa món ăn** đã được viết trong code (`_ImageSection`,
> `_DeleteButton` trong `product_form_screen.dart`) nhưng hiện đang bị **comment/ẩn**, chưa dùng
> được từ giao diện — món ăn hiện chỉ có thể Thêm/Sửa, không xoá hay gắn ảnh được qua UI.

## 7. Danh mục (tab dưới cùng)

Tab "Danh mục" gồm 2 mục quản lý dữ liệu nền dùng chung cho các màn hình khác:

### Địa chỉ

- Bảng gồm **Mã** và **Tên** (toà nhà/khu vực). Chạm dòng để sửa.
- Nút **"Thêm"** → form nhập **Mã** và **Tên**.
- Xoá địa chỉ thực hiện trong màn hình sửa (nút Xóa).

### Danh mục món ăn

- Bảng gồm **Tên**, **Mô tả**, và cột **"Tùy chọn"** có sẵn 2 icon **Sửa** (✏️) / **Xóa** (🗑️)
  ngay trên từng dòng — đây là màn hình **duy nhất** cho xoá trực tiếp từ danh sách (có hộp thoại
  xác nhận trước khi xoá).
- Nút **"Thêm"** → form nhập **Tên** và **Mô tả**.

## 8. Thống kê (Report)

4 báo cáo con, mỗi báo cáo có bộ lọc khoảng ngày riêng (một số báo cáo lọc thêm theo khách
hàng/món ăn):

### Theo đơn hàng

- 2 ô tổng: **Tổng số đơn** và **Tổng thành tiền** (không tính đơn Huỷ).
- Dải thẻ ngang theo từng trạng thái (Đã lên đơn/Đã thanh toán/Huỷ): số đơn + thành tiền mỗi
  trạng thái.
- Khối "Tổng cộng theo món": tổng số lượng bán ra của từng món trong khoảng ngày đã chọn.
- Danh sách chi tiết từng đơn hàng bên dưới, phân trang giống màn hình Đặt hàng.

### Theo món ăn

- Bộ lọc: chọn món ăn cụ thể (tuỳ chọn) + khoảng ngày.
- **Tổng số món**: tổng số lượng đã bán trong khoảng ngày.
- Dải thẻ ngang từng món, sắp theo số lượng bán giảm dần, mỗi thẻ hiện **số lượng** và
  **thành tiền** (đơn giá × số lượng cộng dồn).
- Danh sách chi tiết đơn hàng liên quan bên dưới.

### Tổng hợp

Gộp số liệu 2 nguồn trong cùng khoảng ngày để nhìn nhanh tổng quan thu/chi:

- **Đơn hàng**: Tổng số đơn, Tổng thành tiền, và bảng chia theo từng món ăn.
- **Mua hàng**: Tổng số phiếu nhập, Tổng thành tiền, và bảng chia theo từng khoản mục đã nhập.

### Theo khách hàng tiềm năng

Xếp hạng khách hàng theo tổng tiền đã đặt hàng trong khoảng ngày đã chọn — dùng để nhận diện
khách hàng thân thiết/mua nhiều.

## 9. Giao dịch (Transactions)

Đây là lịch sử của luồng bán hàng nhanh (POS) mô tả ở mục 2, giao diện còn giữ nguyên tiếng Anh
(khác với phần còn lại của app):

1. Ở Trang chủ, thêm món vào giỏ, mở panel, bấm **Pay**.
2. Nhập: **Received Amount** (tiền khách đưa), **Payment Method** (Bank/Cash), **Customer Name**
   (tuỳ chọn), **Description** (tuỳ chọn). Nút **Pay** chỉ bật khi số tiền khách đưa ≥ tổng tiền.
3. Xác nhận → tạo 1 Giao dịch, tự động chuyển sang màn hình **chi tiết giao dịch**.

### Danh sách giao dịch (`/transactions`)

Có ô tìm kiếm theo mã giao dịch (Transaction ID), phân trang khi cuộn tới cuối danh sách.

### Chi tiết giao dịch

Hiển thị đầy đủ: Transaction ID, Payment Method, Created By, Created At, Customer Name,
Description, danh sách món (tên, đơn giá × số lượng, thành tiền), Total, Payment Received, Change
(tiền thối). Có nút **in lại hoá đơn** (icon máy in trên AppBar) — gọi tới máy in nhiệt đã kết nối
ở Cài đặt máy in.

## 10. Cài đặt

- **Thông tin tài khoản**: tên và địa chỉ hiện tại (đọc từ hồ sơ người dùng).
- **Thay đổi chủ đề**: công tắc bật/tắt Chế độ tối.
- **Giờ tự động sao lưu**: chọn 1 mốc giờ trong ngày. Mỗi lần mở app, hệ thống kiểm tra và tự
  chạy sao lưu nếu: hôm nay chưa sao lưu, **và** (đã quá giờ hẹn hôm nay **hoặc** hôm qua bị bỏ
  lỡ không sao lưu). Chỉ chạy khi đã cấu hình giờ **và** mật khẩu sao lưu đã được xác thực đúng
  (xem mục dưới) — vì ứng dụng không chạy nền, việc tự sao lưu chỉ được kiểm tra tại thời điểm mở
  app, không phải đúng giờ hẹn.
- **Mật khẩu sao lưu**: nhập mã để bật (đúng) hoặc tắt (sai) quyền tự động sao lưu theo lịch ở
  trên. Không ảnh hưởng tới việc sao lưu/khôi phục thủ công ở mục bên dưới (các thao tác thủ công
  không yêu cầu mật khẩu).
- **Sao lưu** (`/setting/backup-data`) → mở màn hình con:
  - **Xuất file sao lưu**: xuất toàn bộ dữ liệu ra file `.tsv` (mỗi bảng 1 file) lưu vào bộ nhớ
    máy tại `Download/MeRon/<thời-gian-xuất>/`, sau đó tự động tải các file này lên thư mục con
    tương ứng trên Google Drive.
  - **Nhập dữ liệu từ tệp sao lưu** (`/import`): cho từng bảng riêng lẻ — Địa chỉ, Danh mục món
    ăn, Khách hàng, Món ăn, Đơn hàng, Chi tiết đơn hàng, Phiếu nhập, Chi tiết phiếu nhập — chọn 1
    file `.tsv` (nếu không tự chọn, ứng dụng sẽ tự dò file mới nhất theo tên bảng trong thư mục
    backup nội bộ của app). **Lưu ý quan trọng: nhập dữ liệu sẽ XÓA TOÀN BỘ dữ liệu hiện có của
    bảng đó rồi mới ghi đè bằng dữ liệu trong file** — không phải thao tác cộng thêm.
  - **Xóa toàn bộ dữ liệu ở máy**: xoá sạch dữ liệu local ở tất cả các bảng nghiệp vụ (Đơn hàng,
    Món ăn, Khách hàng, Danh mục, Địa chỉ, Phiếu nhập, Giao dịch, hàng đợi đồng bộ...). Yêu cầu
    xác nhận **2 lần liên tiếp**, không thể hoàn tác.
  - **Tải lên / Tải về / Xóa dữ liệu đám mây**: đồng bộ **từng bảng riêng lẻ** (Địa chỉ, Danh mục
    món ăn, Khách hàng, Món ăn, Đơn hàng, Chi tiết đơn hàng, Phiếu nhập, Chi tiết phiếu nhập) với
    Firestore. Thao tác **Xóa** ở đây **không có hộp thoại xác nhận** — bấm là xoá luôn, cần thận
    trọng.
  - **Tải lên / Tải về / Xóa dữ liệu đám mây (Toàn bộ)**: chạy tuần tự cho tất cả các bảng ở trên
    cùng lúc. Riêng nút **Xóa (Toàn bộ)** có xác nhận **2 lần** trước khi thực hiện.

> "Printer Settings" (cấu hình máy in nhiệt: loại kết nối USB/Bluetooth/BLE/Network, khổ giấy
> 58/72/80mm, dò & kết nối thiết bị, in thử) và "About" (thông tin phiên bản ứng dụng) đã có sẵn
> màn hình hoàn chỉnh nhưng nút mở chúng đang bị **ẩn khỏi menu Cài đặt** (bị comment trong code).
> Tính năng in hoá đơn ở mục Giao dịch (mục 9) phụ thuộc vào máy in đã chọn ở đây, nên nếu chưa có
> đường vào màn hình này thì việc in sẽ báo lỗi "chưa chọn máy in".

## Phụ lục A: Tính năng đã code nhưng chưa bật trên giao diện

| Vị trí trong code                                     | Trạng thái hiện tại                                    |
| ------------------------------------------------------ | -------------------------------------------------------- |
| `product_form_screen.dart` — chọn/cắt ảnh món ăn        | UI bị comment, không hiện trên form Món ăn                |
| `product_form_screen.dart` — nút Xóa món ăn              | UI bị comment, không xoá được món ăn qua giao diện         |
| `product_detail_screen.dart`                            | Toàn bộ file bị comment, không có route dẫn tới            |
| `setting_screen.dart` — nút "Printer Settings"           | Widget có sẵn, bị comment khỏi danh sách nút Cài đặt        |
| `setting_screen.dart` — nút "About"                      | Widget có sẵn, bị comment khỏi danh sách nút Cài đặt        |

Đây là các điểm nên lưu ý nếu người dùng thấy tài liệu/hình ảnh quảng cáo nhắc tới nhưng không tìm
thấy trên app, hoặc nếu định bật lại thì chỉ cần bỏ comment ở các vị trí trên.
