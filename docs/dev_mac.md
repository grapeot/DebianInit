# Mac 初始化：Agent-Oriented Generative Kernel

本文档是 `mac/` 脚本的引导知识。Agent 装机时以脚本为准、以本文档解释决策和坑。

传统万能脚本必须对环境做 rigid 假设，隔几年就要重写。这里把装机拆成：

1. **核心套件**（确定性层）：`mac/bootstrap.sh` — 无条件基础层。
2. **引导知识**（prompt 层）：本文档 — 偏好、安装策略、已知坑。
3. **杠杆工具集**（工具层）：brew、mas-cli、curl、gum。脚本没覆盖的，Agent 现场组合。

当前实现已经脚本化，不是“只写文档、让 Agent 从零装”。文档负责别装错 cask、别走 App Store 版 Tailscale。

## 执行模型

```
./mac/setup.sh          # 总入口，要求 Darwin + arm64
        │
        ▼
  阶段 1  mac/bootstrap.sh     失败则中止
  阶段 2+3 mac/apps.sh         gum 多选，失败不阻断 setup.sh
  阶段 4  DaVinci              apps.sh 若勾选会调 davinci.sh
                               setup.sh 只检查 /Applications 是否已在
  阶段 5  mac/verify.sh        失败只警告
```

各脚本可单独跑。`setup.sh` 在非 Darwin 或非 Apple Silicon 上直接退出。Homebrew 只处理 `/opt/homebrew`（arm64）。

## 已确认决策

- **Homebrew**：官方安装脚本；本仓库的 Mac 路径只支持 Apple Silicon。
- **Python**：uv 官方 installer，不经过 brew，不用 pyenv。
- **编辑器**：Neovim（`brew install neovim`），不是 MacVim。
- **字体**：`brew install --cask font-meslo-lg-nerd-font`
- **窗口管理**：Rectangle（`brew install --cask rectangle`），不是 Spectacle。
- **删除项**：Haskell、code-server、sshfs+macfuse、mongodb-community、pyenv。旧 Skim / Spectacle / Alfred 2 不再装。
- **Tailscale**：standalone `tailscale-app`，不用 App Store。[原因见下方](#tailscale-安装说明)
- **Rust**：官方 rustup（`sh.rustup.rs -y`），不是 brew `rust`。
- **Antigravity Tools**：GitHub Release 的 aarch64 DMG，不是 `brew tap lbjlaq/antigravity-manager`。

## 应用清单（与 `mac/apps.sh` 对齐）

gum 里默认全选，用户取消勾选即跳过。

### GUI（brew cask，除非注明）

| 应用 | 安装名 | 备注 |
|------|--------|------|
| Claude | `claude` | |
| ChatGPT | `chatgpt` | |
| ChatGPT Atlas | `chatgpt-atlas` | |
| Cursor | `cursor` | |
| Codex | `codex` | CLI cask |
| LM Studio | `lm-studio` | |
| Ollama | `ollama-app` | 注意不是 formula `ollama` |
| VS Code | `visual-studio-code` | |
| Android Studio | `android-studio` | |
| Docker | `docker-desktop` | 注意不是 `docker` |
| iTerm | `iterm2` | |
| Telegram | `telegram` | 独立版，非 App Store |
| Zoom | `zoom` | |
| DaVinci Resolve | `mac/davinci.sh` | Blackmagic API，见下方 |
| Gyroflow | `gyroflow` | |
| BambuStudio | `bambu-studio` | |
| OpenSCAD | `openscad` | |
| Roon | `roon` | 需订阅 |
| Tailscale | `tailscale-app` | standalone |
| Windows App | `windows-app` | |
| 1Password | `1password` | |
| Firefox | `firefox` | |
| Rectangle | `rectangle` | |
| Antigravity | `antigravity` | |
| Antigravity Tools | GitHub Release DMG | `lbjlaq/Antigravity-Manager`，aarch64 |

### App Store（mas-cli）

```bash
mas install 424390742    # Compressor
mas install 1444636541   # Photomator
# Xcode：脚本只 open App Store，不自动装
```

### 无条件 CLI（`mac/bootstrap.sh`）

```
coreutils wget tmux ripgrep htop btop macmon p7zip rsync nmap
shellcheck tig socat gh git-lfs exiftool neovim fd lazygit zellij
```

另装：gum、uv、mas、Meslo Nerd Font、oh-my-zsh、`.dotfiles`（`deploy_mac.sh`）。

### 可选 CLI（`apps.sh` 第二屏）

```
ffmpeg sox zbar pandoc marp-cli
borgbackup cmake go swig
astrometry-net argyll-cms
Rust (rustup)
```

## DaVinci Resolve

没有 brew cask。`mac/davinci.sh`：

1. 已存在 `/Applications/DaVinci Resolve` 则跳过
2. `GET /api/support/latest-stable-version/davinci-resolve/mac` 取 `downloadId`
3. POST 到 `https://www.blackmagicdesign.com/api/register/us/download/{downloadId}`
4. 下载 `swr.cloud.blackmagicdesign.com` 签名 URL（约 6.5GB；扩展名以响应为准，可能是 `.zip` 不是 `.dmg`）
5. API 失败则 `open` 官网让用户手动下

URL 里的 `verify=` 是带 Unix 时间戳的限时 token，不能缓存或写死。

## Tailscale 安装说明

用 standalone，不用 App Store 版。App Store 版受沙箱限制：

- Screen Time web filter 会阻断连接
- 无法检测第三方 VPN 冲突
- 更新要等 Apple 审核
- 没有 `tailscale ssh`，也不能当 Tailscale SSH server

`brew install --cask tailscale-app`

从 App Store 版迁移：删应用 → 清废纸篓 → 重启 → 再装 standalone。残留系统扩展会冲突（GitHub issue #17891）。

## 已知坑

- `brew install --cask tailscale` 不存在，正确名是 `tailscale-app`。同类：`ollama-app`、`docker-desktop`；`codex` 是 CLI，桌面应用是 `codex-app`。装前 `brew info --cask`。
- Intel Homebrew 在 `/usr/local/bin/brew`。当前 `setup.sh` 直接拒绝非 arm64，脚本不再兼容那条路径。
- uv 装在 `~/.local/bin` 或 `~/.cargo/bin`，不走 brew。
- `mas install` 可自动化 App Store，但 Xcode 体积和依赖不适合脚本装。
- `~/.oh-my-zsh` 若只有空目录/cache，bootstrap 的“已安装”判断会误跳过。需要 `oh-my-zsh.sh` 在场。

## 与仓库文件的关系

| 文件 | 作用 |
|------|------|
| `mac/setup.sh` | 总入口 |
| `mac/bootstrap.sh` | 阶段 1 |
| `mac/apps.sh` | 阶段 2+3 |
| `mac/davinci.sh` | DaVinci |
| `mac/verify.sh` | 阶段 5 |
| `docs/dev_mac.md` | 本文档，给 Agent 的决策层 |
| `docs/working.md` | 变更记录 |

仓库里没有 `osx.sh`。

## 验收

`mac/verify.sh` 检查 brew/git/nvim/tmux/rg/fd/lazygit/gh/zellij/gum/uv、若干 `/Applications` 应用、`DSDontWriteNetworkStores`、`.dotfiles`、oh-my-zsh、git `Yan Wang` / `grapeot@outlook.com`。未勾选的 GUI 应用记为 skip，不算失败。
