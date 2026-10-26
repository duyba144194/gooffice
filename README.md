# GoOffice

Bộ ứng dụng văn phòng mã nguồn mở dựa trên **LibreOffice 26.8.2** (MPL 2.0), mang thương hiệu GoOffice, build cho 5 nền tảng: Windows amd64/arm64, Linux amd64/arm64, macOS arm64/x64.

## Cấu trúc repo

```
branding/          Bộ nhận diện GoOffice (intro.png, logo*.svg, about.svg, donate*.png)
autogen/           File autogen.input cho từng nền tảng build
scripts/           Script build local (Windows x64, Linux x64)
patches/           Patch riêng cho source LibreOffice (nếu cần)
.github/workflows/ CI GitHub Actions cho macOS arm64/x64, Windows arm64, Linux arm64
```

## Build local

- **Windows amd64**: `scripts/build-win-x64.sh` (từ Git Bash; cần VS2022 + WSL Ubuntu như đã setup)
- **Linux amd64**: `scripts/build-linux-x64.sh` (trong WSL Ubuntu-24.04)

## Bản release (GitHub Actions)

Workflows build và xuất artifact: MSI (Windows), DMG (macOS), deb/rpm (Linux).

## Pháp lý / MPL 2.0

- GoOffice là một bản phân phối lại (fork) của LibreOffice theo giấy phép **MPL 2.0**.
- Toàn bộ mã nguồn dùng để build công khai tại repo này và tại https://www.libreoffice.org/download/source/ (bản gốc 26.8.2).
- Tên và logo "LibreOffice" là trademark của The Document Foundation — GoOffice không sử dụng các trademark đó; mọi nhận diện hiển thị là GoOffice.
- Các văn bản license gốc (COPYING.MPL, COPYING, COPYING.LGPL...) được giữ nguyên trong bản phân phối.
- GoOffice không dùng cơ chế online-update/breakpad (crash report) của TDF.
