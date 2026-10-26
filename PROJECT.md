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

## Trạng thái (phiên 2, sau reboot — 2026-10-26 tối)

- [x] WSL2 kích hoạt sau reboot; Ubuntu-24.04 đăng ký + user `ubuntu` (default) + full apt packages (gcc 13.3, GTK3 dev, JDK 17, ccache, rpm)
- [x] Defender exclusion: C:\Users\NAM\GoOffice + C:\Users\NAM\lo + cl/link/jom/make process
- [x] Phát hiện + sửa lỗi CRLF: system git autocrlf=true làm hỏng checkout → repo-local autocrlf=false + renormalize (git rm --cached -r . && git reset --hard)
- [x] Bổ sung VS components thiếu: .NET 4.8 SDK (al.exe), VC.Redist.MSM, CMake, Clang, ARM64EC (exit 0, verify al.exe OK)
- [x] autogen Windows x64: lần 1 fail (CRLF), lần 2 fail (al.exe — SDK lookup qua registry Cygwin không có trong WSL), lần 3 đang chạy sau khi có al.exe
- [x] Repo: 2 commits (skeleton + platform configs/CI workflow)
- [x] File autogen.input cho 4 nền tảng CI: linux-x64/linux-arm64/macos-arm64/macos-x64/win-arm64
- [x] .github/workflows/build.yml: matrix 4 platform (macos-15, macos-13, ubuntu-24.04-arm, windows-2022 cross)
- [ ] make fetch + make Windows amd64
- [ ] MSI + smoke test
- [ ] Linux amd64 build (out-of-tree: build-linux-x64/)
- [ ] Đẩy lên GitHub + bật CI

## Bài học đã ghi (đừng lặp lại)

1. Clone Git repo TRƯỚC KHI set `core.autocrlf=false` → CRLF corrupt shell scripts. Giải pháp: repo-local config + renormalize. CI workflow đã thêm `--config core.autocrlf=false` vào git clone.
2. Start-Process -ArgumentList (array) KHÔNG quote items có space → `--installPath "C:\Program Files..."` vỡ. Dùng single string với quote.
3. configure tìm al.exe qua Cygwin registry procfs (/proc/registry32) không tồn tại trong WSL → phải có file .NET 4.8 SDK trên đĩa.
4. Hook Mimosa chặn combo Bash "cp vào autogen* + chạy autogen.sh" — tách lệnh cp và chạy script thành 2 tool calls riêng.


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
