# Working Notes

## Changelogs

### 2026-03-16

- Audit current machine: 193 brew formulae (59 explicit), 14 casks, 66 apps in /Applications
- Categorize all 27 target apps into 3 tiers: brew cask (23), App Store via mas-cli (3), API automation (1)
- Research Tailscale installation: standalone (`tailscale-app`) over App Store, due to Screen Time conflict and missing CLI features
- Research DaVinci Resolve download: reverse-engineered Blackmagic API (registration POST → signed URL), verify token is time-limited
- Rewrite `dev_mac.md` as Generative Kernel spec: design philosophy, 5-stage execution model, full app inventory with cask names
- Move `dev_mac.md` to `docs/dev_mac.md`
- Confirm removal: Haskell, code-server, sshfs+macfuse, mongodb, pyenv (replaced by uv)
- Confirm additions: neovim, fd, lazygit, gum (TUI tool)
- Implement 5-stage mac setup scripts in `mac/`: bootstrap.sh, apps.sh, davinci.sh, verify.sh, setup.sh (820 lines total)
- Fix davinci.sh: detect file extension from URL instead of hardcoding .dmg (Blackmagic returns .zip)

## Lessons Learned

- `brew install --cask tailscale` 不存在，正确的 cask 名是 `tailscale-app`。类似的还有 `ollama-app`（不是 `ollama`）、`docker-desktop`（不是 `docker`）、`codex` vs `codex-app`（CLI vs 桌面应用）。brew cask 的命名规则和直觉不总是一致，需要逐个 `brew info --cask` 确认。
- Blackmagic Design 的下载 URL 中 `verify=` 参数包含 Unix 时间戳，是限时 token。实测当天有效，次日过期。不能在脚本里硬编码。Arch AUR 和 NixOS 的 packager 已经逆向了 API 流程，可以参考 CachyOS PKGBUILD。
- macOS App Store 版 Tailscale 受沙箱限制严重：Screen Time web filter 直接阻断连接，不能当 SSH server，不能检测 VPN 冲突。从 App Store 版迁移到 standalone 时必须彻底卸载（删应用→清废纸篓→重启），否则残留的系统扩展会和新版冲突（GitHub issue #17891）。
- `mas-cli` 可以自动化 App Store 安装（`mas install <app-id>`），但 Xcode 因体积和依赖链的原因不适合通过脚本自动化，建议手动。
- Apple Silicon 和 Intel 的 Homebrew 路径不同：arm64 在 `/opt/homebrew/bin/brew`，x86_64 在 `/usr/local/bin/brew`。脚本里需要两条路径都处理，尤其是在 brew 刚安装完、还没有被加入 shell profile 的时候。
- `gum`（charmbracelet）作为 TUI 工具效果好：`gum choose --no-limit` 支持多选，比 bash `select` 或 `dialog` 更现代。需要在 bootstrap 阶段先装好。
- uv 不通过 brew 安装（用 `curl -LsSf https://astral.sh/uv/install.sh | sh`），装完后在 `~/.local/bin/`。pyenv 的功能（Python 版本管理）已被 uv 完全覆盖（`uv python install`），可以彻底弃用。
