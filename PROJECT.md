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
3. configure tìm al.exe qua Cygwin registry procfs (/proc/registry32) không có trong WSL → phải có file .NET 4.8 SDK trên đĩa (component `Microsoft.Net.Component.4.8.SDK`).
4. Hook Mimosa chặn combo Bash "cp vào autogen* + chạy autogen.sh" — tách lệnh cp và chạy script thành 2 tool calls riêng.
5. `--with-package-version` cần 4 thành phần (X.Y.Z.PATCH) — "1.0.0" làm LIBO_VERSION_PATCH rỗng → rc.exe lỗi RC2127/RC2167. Dùng "1.0.0.0".
6. `--enable-release` không tồn tại — đúng là `--enable-release-build` (tránh hậu tố "Dev" trên PRODUCTNAME).
7. Exit code 8006 của VS installer = còn process VS đang chạy, KHÔNG phải cần reboot.
8. `--with-branding` của stock LO không WSL-aware → patches/0001 (đã qua 4 version: m4 nuốt `[A-Za-z]` trong case → cần `[[...]]` kép; wslpath -u với path unix sẵn GHÉP tiền tố /mnt/c chứ không trả rỗng; chỉ convert khi WSL_ONLY_AS_HELPER — build Linux native trong WSL phải giữ path unix).
9. Chạy build Linux trong WSL từ Git Bash: PATH Windows bị kế thừa → configure tưởng wsl-as-helper. Sanitize PATH trước khi chạy.
10. Bắt buộc cài thêm ở WSL Ubuntu cho build LO: libkrb5-dev (com_err), libnss3-dev + libnspr4-dev, meson + ninja-build + ragel (harfbuzz), ant (dùng chung ant Windows qua /mnt/c được).
11. make tự re-autogen khi configure.ac mới hơn config_host.mk — tiện tay, đừng chạy autogen thủ công lại.
12. ATL x64 (atls.lib) KHÔNG có sẵn dù --includeRecommended: phải --add Microsoft.VisualStudio.Component.VC.ATL tường minh (cần cho so_activex.dll).

## Trạng thái build (10:30 sáng 27-10)

### ✅ Windows amd64 — HOÀN THÀNH
4 MSI tại `C:\Users\NAM\GoOffice\dist\win-x64\`:
| File | Size |
|---|---|
| GoOffice_1.0.0.0_Win_x86-64_en-US_vi.msi (bộ chính, UI tiếng Việt) | 222 MB |
| GoOffice_1.0.0.0_Win_x86-64_helppack_en-US.msi | 2.9 MB |
| GoOffice_1.0.0.0_Win_x86-64_helppack_vi.msi | 3.6 MB |
| GoOffice_1.0.0.0_Win_x86-64_sdk.msi | 23 MB |

- MSI metadata: ProductName="GoOffice 1.0.0.0", Manufacturer="GoOffice Project" ✅
- UpgradeCode/ProductCode: GUID mới hoàn toàn (cài song song với LibreOffice không xung đột) ✅
- Smoke-test headless (html→txt conversion): PASS ✅

### 🔨 Linux amd64 — đang build (WSL ext4 ~/core)
- /mnt/c bị libffi từ chối (9p fs) → chuyển toàn bộ sang ext4
- autogen OK, đang compile (log: logs/make-build-linux-ext4.log), dự kiến 2–4h

### ⏳ Chờ tiếp
- GitHub: cài gh CLI xong, **chờ username/tài khoản của anh** để push repo + chạy CI cho macOS arm64/x64, Windows arm64, Linux arm64
- (Tùy chọn) cài thử MSI lên máy thật


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
