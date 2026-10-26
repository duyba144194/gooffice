# GoOffice — Pháp lý & Tuân thủ MPL 2.0

> Trạng thái: khung tuân thủ đã xong; hoàn tất checklist khi ship bản đầu tiên.
> Cập nhật: 2026-10-26

## 1. Cơ sở pháp lý

GoOffice là **bản phái sinh (fork)** của LibreOffice, được phân phối lại theo
**Mozilla Public License 2.0** (MPL 2.0). MPL 2.0 cho phép:

- Sử dụng, sửa đổi, phân phối lại mã nguồn và bản nhị phân.
- Phân phối dưới tên thương hiệu riêng (**được phép**), miễn là:
  - Không dùng trademark của bên gốc để gây hiểu lầm về nguồn gốc.
  - Giữ nguyên các thông báo bản quyền & license trong source được sửa đổi.
  - Là bản "Larger Work" (fork toàn bộ) — file MPL-covered vẫn giữ MPL 2.0.

## 2. Nghĩa vụ đang được thực thi

| Nghĩa vụ | Trạng thái |
|---|---|
| Giữ nguyên văn bản MPL 2.0 và thông báo bản quyền trong source | ✅ (`COPYING.MPL`, `COPYING`, `COPYING.LGPL` trong source tree, được đưa vào bản đóng gói) |
| Không dùng trademark "LibreOffice" cho sản phẩm của mình | ✅ Tên sản phẩm = GoOffice; logo riêng; `--with-product-name=GoOffice` |
| Không dùng logo TDF/LibreOffice | ✅ Bộ nhận diện GoOffice tự thiết kế (`branding/`) |
| Không kích hoạt online-update trỏ về server TDF | ✅ `--disable-online-update` trong mọi autogen.input |
| Không kích hoạt breakpad (gửi crash về server TDF) | ✅ không bật `--enable-breakpad` |
| Make source available khi phân phối binary | ⏳ Cần: repo GitHub public chứa (a) toàn bộ patch + branding + cấu hình build của GoOffice, (b) chỉ rõ base = LibreOffice 26.8.2.2 (tag) + URL tải source gốc. MPL 2.0 §3.2(a) cho phép phân phối source dạng "cách để tái tạo" — repo này đáp ứng |
| Ghi công nguồn gốc trong About dialog | ⏳ Kiểm tra sau build: About phải nêu rõ nguồn gốc LibreOffice (chuỗi giữ trong source) |
| License của các thư viện bundled | ⏳ LO build tự sinh license files vào instdir; xác nhận khi đóng gói MSI/DMG/deb |

## 3. Điểm cần LIÊM CHÍNH (trước khi phát hành công khai)

1. **Manufacturer MSI**: MSI có Manufacturer = "GoOffice Project" (từ --with-vendor).
   Nâng thành pháp nhân/tên thật khi phân phối thương mại.
2. **About dialog**: `--with-extra-buildid=GoOffice 1.0.0 (LibreOffice 26.8.2)` ghi rõ
   nguồn gốc. KHÔNG xóa các dòng "Portions Copyright..." trong resource gốc.
3. **Không khuyến khích người dùng xóa license files** khỏi thư mục cài đặt.
4. Nếu đóng góp patch ngược upstream (như patches/0001) — patch thuộc về dự án gốc.

## 4. Giấy phép của repo gooffice

Brand/assets/scripts do chúng ta tự viết → dùng **MPL 2.0** cho toàn repo
để đơn giản hợp nhất với phần phái sinh.

## 5. Tham chiếu

- MPL 2.0: https://www.mozilla.org/en-US/MPL/2.0/
- Trademark TDF: https://www.libreoffice.org/about-us/who-are-we/trademarks/
- MPL 2.0 FAQ (Larger Work): https://www.mozilla.org/en-US/MPL/2.0/FAQ/
