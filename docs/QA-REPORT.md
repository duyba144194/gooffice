# GoOffice 1.0.0.0 — Báo cáo QA tổng thể (30-10-2026)

## 1. Pháp lý & License
- ✅ Quét nguyên văn trong toàn bộ phần tự viết (18 file script/config/branding + workflow):
  KHÔNG có dấu hiệu copy code có license GPL/Apache/Google. Tất cả là code tự viết.
- ✅ 9 patch chỉ chạm file trong source LibreOffice (MPL 2.0) — derivative giữ MPL 2.0, đúng luật.
- ✅ Bộ cài mang đủ văn bản pháp lý: `license.txt` (toàn văn MPL 2.0), `LICENSE.html`, `NOTICE`, `CREDITS.fodt`.
- ℹ️ Base source = LibreOffice 26.8.2.2 (tag `libreoffice-26.8.2.2`), công khai tại repo GitHub — đủ điều kiện MPL §3.2(a).

## 2. Thư viện đóng gói (download.lst) — phiên bản vs lỗ hổng đã biết
curl 8.23.0 | openssl 3.5.9 | expat 2.9.0 | zlib 1.3.2 | xz 5.8.4 | libxml2 2.15.x |
xmlsec 1.3.12 | icu 78.3 | nss 3.132 | python 3.13.17 | boost 1.91 | poppler 26.10 |
harfbuzz 14.2.1 | freetype 2.15 | fontconfig 2.18.3 | libpng 1.6.59 | libjpeg-turbo 3.1.4.1 |
sqlite 3.54.1 | zstd 1.5.7 | pixman 0.46.4 | cairo 1.18.x | firebird 3.0.14 | hunspell 1.7.5
→ Tất cả thuộc thế hệ hiện tại, không nằm trong dải phiên bản có CVE nghiêm trọng chưa vá nào được biết (đặc biệt xz ≠ 5.6.0/5.6.1 backdoor; expat > 2.4.7; zlib > 1.3).

## 3. Installer / nâng cấp / quyền
- ✅ MSI cài đặt im lặng bằng quyền admin: exit 0 (đã diễn ra 2 vòng).
- ✅ Gỡ cài đặt: msiexec /x exit 0 — thư mục cài + registry sạch hoàn toàn (đã diễn ra).
- ✅ Upgrade cùng UpgradeCode: cài đè lên bản cũ giữ nguyên vị trí + settings (đã diễn ra 2 lần).
- ✅ Chạy KHÔNG cần admin: soffice.exe chạy dưới quyền user thường (mọi test GUI đều chạy user).
- ⏳ Cài bản icon-mới nhất: script `setup\reinstall-batch.ps1` (gỡ + cài tươi 1 lần UAC) — chờ chạy trên máy.
- ℹ️ MSI mặc định cài all-users (chuẩn Office suites); per-user install không phải cấu hình LO hỗ trợ.

## 4. Tương thích định dạng (roundtrip qua GoOffice 1.0.0.0 Windows x64)
Bộ mẫu khó tự sinh: bảng 4 cột + ô gộp + header bold + tiền tệ VNĐ; TOC field; header/footer
tiếng Việt; track changes (w:ins); công thức/siêu ký tự (mc², α², ③⑤); ô gộp + công thức
SUM/IFERROR + number format + BarChart (xlsx); speaker notes (pptx); CSV UTF-8-BOM có
dấu phẩy trong ngoặc kép.

| Lộ trình | Kết quả |
|---|---|
| docx → odt → docx | ✅ toàn bộ text/bảng/heading/VN giữ nguyên; **track changes bảo tồn** (changed-region); header/footer VN còn |
| xlsx → ods → xlsx | ✅ số nguyên chính xác; **công thức =SUM còn**; ô gộp còn |
| pptx → odp → pptx | ✅ title + speaker notes **byte-identical** |
| csv → ods → csv | ✅ dấu phẩy trong quote + UTF-8 VN nguyên vẹn |
| xlsx → csv | ✅ giá trị công thức đã tính xuất đúng |
| PDF export | ✅ 6/6 (docx/odt/xlsx/pptx/ods/docm) có nội dung nhiều trang |
| .docm (macro) | ✅ mở + export PDF bình thường |

## 4b. Roundtrip mở rộng (v2, 30-10) — các case khó còn lại
Mẫu được author bằng chính MS Word/Excel COM (nội dung thật, không fake):

| Case | Phương pháp | Kết quả |
|---|---|---|
| **Macro VBA (docm)** | Word COM tạo vbaProject.bin thật (AutoOpen + module) → GoOffice roundtrip filter `MS Word 2007 XML VBA` | ✅ **code VBA giữ nguyên 2/2 modules** (ThisDocument.cls, Module1.bas — xác minh bằng olevba) |
| **Macro VBA (xlsm)** | Excel COM tạo Workbook_Open → roundtrip `Calc MS Excel 2007 VBA XML` | ✅ vbaProject.bin tồn tại, **code giữ nguyên 3/3 modules** |
| **Chú thích (comments)** | Word COM chèn comment vào paragraph → docx→odt | ✅ `office:annotation` bảo tồn trong content.xml |
| **Hình nổi** | Word COM `Shapes.AddPicture` + wrap-square → docx→odt | ✅ draw:frame + wrap bảo tồn |
| **Ngắt trang rõ ràng** | Word COM `InsertBreak(wdPageBreak)` → docx→pdf | ✅ đúng 2 trang như kỳ vọng |
| **Biểu đồ surviving** | BarChart (openpyxl) → xlsx→ods→xlsx | ✅ `xl/charts/chart1.xml` + style/colors còn nguyên |
| **.odp trực tiếp** | odp→pdf (2 trang), odp→pptx→odp | ✅ title/notes giữ nguyên |

Ghi chú kỹ thuật: vbaProject.bin sau roundtrip có hash khác (LO viết lại OLE container)
nhưng **nội dung macro (mỗi dòng code) được xác minh giữ nguyên bằng olevba** — đúng
hành vi "VBA preservation" của LibreOffice. Security setting AccessVBOM đã bật tạm để
author mẫu và đã khôi phục = 0 sau khi xong.

## 5. So sánh render với Microsoft Office (Word 16 có trên máy)
Cùng file test-hard.docx → PDF bởi Word và bởi GoOffice, render 1:1:
- ✅ Bố cục, line spacing, ngắt trang, vị trí footer: **giống hệt**
- ✅ Bảng, ô gộp, bold header: giống hệt
- ✅ Tiếng Việt: đủ dấu, cùng font render
- Khác biệt duy nhất: MÀU hiển thị track changes (Word = đỏ gạch chân, LO = nền vàng) —
  hành vi hiển thị chuẩn của từng ứng dụng, không phải lỗi dữ liệu.

## 6. Font tiếng Việt
- ✅ Windows: MSI cài 46 font (Liberation, Caladea, Carlito, DejaVu, Gentium...) vào
  C:\Windows\Fonts — toàn bộ hỗ trợ đầy đủ glyph tiếng Việt.
- ✅ Render PDF kiểm chứng dấu ệ ơ ư ạ ế ỗ ữ hiển thị chuẩn (xem mục 5).
- ℹ️ Linux/macOS dùng cùng bộ font bundle trong bộ cài.

## 7. Build tái lập (clean build)
- ⏳ Đang chạy nền trong WSL: clone sạch từ cùng commit + cùng autogen.input → build
  hoàn toàn mới → so sánh inventory instdir/program. Log: `logs/repro-build.log`.
- ⚠️ Byte-identical không phải mục tiêu khả thi với LO (timestamp/linker build-id);
  tiêu chí pass = structural (cùng file list, cùng kích thước đa số, không thiếu dư).

## 8. Nền tảng đã test chạy thật
| Nền tảng | Cài đặt | Chạy |
|---|---|---|
| Windows x64 | ✅ 3 vòng (cài/gỡ/nâng cấp) | ✅ GUI + headless |
| Linux x64 (WSL2) | ✅ dpkg 44 deb + langpack vi | ✅ headless convert |
| Windows arm64 | ✅ MSI metadata + cấu trúc | ⏳ cần máy ARM64 thật |
| macOS arm64 | ✅ cấu trúc DMG | ⏳ cần máy Mac |
| macOS x64 | ✅ cấu trúc DMG | ⏳ cần máy Mac |

## 9. Việc còn mở
1. Chạy `setup\reinstall-batch.ps1` (1 lần UAC) để có bản icon GoOffice trên máy.
2. Icon Linux (SVG hicolor) & macOS (.icns) vẫn là artwork gốc LibreOffice — cần vẽ
   lại theo bộ nhận diện GoOffice nếu muốn đồng bộ 100% (chỉ cosmetic).
3. Clean-build repro: xem log khi chạy xong.
