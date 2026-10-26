# GoOffice — Kế hoạch & Trạng thái

> Bộ office mã nguồn mở dựa trên LibreOffice, mang thương hiệu GoOffice.
> Cập nhật: 2026-10-26

## Quyết định đã chốt

| Hạng mục | Quyết định |
|---|---|
| Tên sản phẩm | **GoOffice** |
| Nền tảng gốc | LibreOffice **26.8.2** (tag git `libreoffice-26.8.2.2`) — bản stable mới nhất |
| Cách làm | Build toàn bộ từ mã nguồn + rebrand (`--with-product-name`, `--with-vendor`, bộ nhận diện riêng) |
| Nền tảng đích | Windows amd64 + arm64, Linux amd64 + arm64, macOS arm64 + x64 |
| Máy local (i9-12900H, 32GB, Win11) | Build Windows amd64 + Linux amd64 (WSL2 Ubuntu 24.04) |
| GitHub Actions CI (repo public) | Build macOS arm64 + x64, Windows arm64, Linux arm64 |
| Pháp lý | Tuân thủ MPL 2.0: giữ nguyên văn bản license, công khai source (repo GitHub), không dùng tên/logo trademark của The Document Foundation |

## Bố cục thư mục

- `C:\Users\NAM\GoOffice\` — vùng build nặng (source LibreOffice, toolchain, log)
  - `src/core/` — mã nguồn LibreOffice 26.8.2.2 (git shallow)
  - `dl/` — bộ cài, JDK
  - `logs/` — log cài đặt & build
- `C:\Users\NAM\Desktop\office\` — **repo gooffice** (nơi này): branding, patch, script build, CI workflow → push lên GitHub cho Actions

## Trạng thái

- [x] Khảo sát máy (CPU/RAM/đĩa/mạng) — đạt yêu cầu build
- [x] Chốt tên/chiến lược/hạ tầng/phiên bản
- [x] Cài VS 2022 BuildTools: MSVC 14.44.35207 — cl.exe x64 + arm64 + ATL (exit 0, log `logs/admin-setup.log`)
- [x] Cài WSL platform 3.0.3 + Ubuntu-24.04 (distro đã download, **cần reboot**)
- [x] Tải JDK 17.0.20 → `C:\Users\NAM\GoOffice\tools\jdk17`
- [x] Clone source LibreOffice 26.8.2.2 → `C:\Users\NAM\GoOffice\src\core` (shallow, 149k files)
- [x] Setup `~/bin` (make-msvc, jom, clang-format, pkgconf) + `~/lo` (perl 5.40 portable + Font::TTF, ant 1.10.17, junit 4.10) — checksum khớp chính thức
- [x] Bộ branding GoOffice v1 (`branding/`): intro.png 644×199 + 2x, logo/logo-sc (svg + inverted), about.svg, donate trong suốt
- [x] autogen.input Windows x64 (`autogen/win-x64.input`) + `scripts/build-win-x64.sh`
- [ ] **REBOOT MÁY** (WSL cần reboot; kiểm tra VT-x trong BIOS nếu sau reboot WSL vẫn báo virtualization)
- [ ] Sau reboot: (1) `wsl --status`, (2) cấu hình Ubuntu (user, apt install pkg-config automake make gperf bison nasm flex zip gettext), (3) chạy `scripts/build-win-x64.sh`
- [ ] autogen + make fetch (~2GB tarballs) + build Windows amd64 (~2-4h)
- [ ] Đóng gói MSI Windows amd64
- [ ] Build Linux amd64 trong WSL → deb/rpm
- [ ] CI: macOS arm64 + x64 → DMG
- [ ] CI: Windows arm64 → MSI
- [ ] CI: Linux arm64 → deb/rpm
- [ ] Smoke-test + tài liệu MPL compliance

## Ghi chú kỹ thuật (cho phiên sau)

- Build Windows = WSL chỉ chạy `autogen.sh`; `make` chạy từ **Git Bash** (host x86_64-pc-cygwin). Không build bên trong WSL.
- autogen dùng: `--with-product-name=GoOffice --with-vendor="GoOffice Project" --with-branding=C:/Users/NAM/Desktop/office/branding --with-package-version=1.0.0 --with-lang=vi` (bundle UI tiếng Việt), KHÔNG dùng online-update/breakpad của TDF.
- LTO tắt cho local build (nhanh, ít RAM); CI release bật LTO như TDF.
- File branding hướng dẫn tại `configure.ac:15575+`: intro.png, intro-highres.png, logo.svg, logo_inverted.svg, logo-sc.svg, logo-sc_inverted.svg, about.svg, donate1.png, donate2.png.
- Windows ARM64 cross-config mẫu: `distro-configs/LibreOfficeWinArm64.conf` (`--host=aarch64-pc-cygwin`) — cần component VS `2022_cross.vsconfig` trên CI runner.
- Cân nhắc sau reboot (admin, 1 click UAC): thêm Windows Defender exclusion cho `C:\Users\NAM\GoOffice` để build nhanh hơn đáng kể.

## Ước lượng

- Cài môi trường: đã xong ~70% (chờ reboot)
- Build lần đầu mỗi nền tảng: 2–5h (lần sau có ccache sẽ nhanh hơn)
- Tổng đĩa cần: ~250–350GB (còn 647GB free — ổn)
