---
name: update-user-guide
description: Use after adding, removing, or changing any user-facing feature in this Flutter app (new screen, new button/menu item, changed form fields, changed navigation/routes, changed report content, changed settings/backup behavior, a feature getting hidden or un-hidden from the UI). Updates USER_GUIDE.md so it stays in sync with the real UI. Trigger on requests like "thêm tính năng...", "sửa màn hình...", "đổi luồng...", or right after finishing an Edit/Write to files under lib/presentation/screens/**, lib/app/routes/**.
---

# Cập nhật USER_GUIDE.md

Mục tiêu: `USER_GUIDE.md` ở gốc repo phải luôn phản ánh đúng những gì người dùng thực sự thấy và
bấm được trên giao diện — không hơn, không kém.

## Khi nào chạy skill này

Ngay sau khi một thay đổi trong phiên làm việc hiện tại (hoặc các commit gần nhất nếu được yêu cầu
rà soát) đụng tới hành vi người dùng cuối, ví dụ:

- Thêm/xoá/đổi tên 1 màn hình (`lib/presentation/screens/**`), 1 route (`lib/app/routes/app_routes.dart`).
- Thêm/xoá/đổi 1 trường trong form, 1 nút bấm, 1 bộ lọc, 1 quy tắc nghiệp vụ (validation, cảnh
  báo, khoá field...).
- Thêm/xoá 1 báo cáo, 1 cột trong bảng danh sách, 1 hành động trong màn hình Cài đặt/Sao lưu.
- Bật lại (un-comment) hoặc ẩn đi (comment) một tính năng đã có sẵn trong code.

Không cần chạy nếu thay đổi chỉ là refactor nội bộ, đổi tên biến/file, sửa style/format, hoặc sửa
lỗi không đổi hành vi hiển thị.

## Các bước

1. **Xác định phạm vi thay đổi**: đọc lại diff/edit vừa thực hiện (hoặc `git diff`/`git log` nếu
   được yêu cầu rà soát toàn bộ) để biết chính xác widget/route/behavior nào đã đổi.
2. **Đọc lại `USER_GUIDE.md` hiện tại**, xác định mục tương ứng theo cấu trúc đang có (mục 1–10
   theo từng tab điều hướng, cộng "Phụ lục A" liệt kê tính năng đã code nhưng bị ẩn khỏi UI).
3. **Đối chiếu với code thực tế trước khi viết** — không suy đoán:
   - Một nút/hành động chỉ được coi là "đang hoạt động" nếu nó thực sự được render (không nằm
     trong comment `//` hoặc `/* */`) và có route đăng ký trong `app_routes.dart` (nếu điều
     hướng qua `context.push/go`).
   - Nếu vừa **thêm** một tính năng mới nhưng đường vào UI đang bị comment/ẩn (giống các trường
     hợp có sẵn ở Phụ lục A), ghi nó vào Phụ lục A thay vì mô tả như tính năng khả dụng.
   - Nếu vừa **bật lại** một tính năng từng nằm trong Phụ lục A, xoá dòng tương ứng khỏi Phụ lục A
     và viết mô tả đầy đủ vào mục chính.
4. **Cập nhật đúng phần bị ảnh hưởng**:
   - Nếu là 1 trường/nút/quy tắc mới trong màn hình đã có mục → chỉnh sửa đoạn mô tả màn hình đó,
     giữ nguyên văn phong (tiếng Việt, gạch đầu dòng ngắn gọn, in đậm tên nút/trường bằng
     `**...**`, dùng khối trích dẫn `>` cho lưu ý/cảnh báo quan trọng).
   - Nếu là 1 màn hình/luồng hoàn toàn mới không khớp mục nào → thêm mục mới theo đúng số thứ tự
     kế tiếp, và nếu nó có mặt trên thanh điều hướng chính thì cập nhật luôn bảng ở mục "1. Điều
     hướng chính".
   - Nếu 1 tính năng bị xoá khỏi app → xoá đoạn mô tả tương ứng (không để sót tham chiếu chết).
5. **Không tự bịa chi tiết**: nếu không chắc một hành vi cụ thể (ví dụ điều kiện disable của 1
   nút), đọc thẳng code liên quan (`grep`/`Read` file widget + notifier tương ứng) trước khi mô tả,
   giống cách các mục hiện tại được viết dựa trên code thật (ví dụ: cơ chế khoá dòng món khi đổi
   giá, cơ chế cảnh báo trùng đơn, quy tắc tự động sao lưu).
6. Giữ file `USER_GUIDE.md` tự nhất quán: không tạo mục trùng lặp, không phá format bảng Markdown
   hiện có, tên file vẫn bằng tiếng Anh nhưng nội dung bên trong bằng tiếng Việt.

## Sau khi cập nhật

Báo ngắn gọn cho người dùng những mục nào trong `USER_GUIDE.md` vừa được sửa/thêm, không cần dán
lại toàn bộ nội dung file trừ khi được yêu cầu.
