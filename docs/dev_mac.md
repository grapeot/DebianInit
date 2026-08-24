# Mac 初始化：Agent-Oriented Generative Kernel

本文档是 `DebianInit` macOS 初始化系统的架构规范与引导知识库。为 AI Agent 装机、环境重构以及维护 `mac/` 目录下的自动化脚本提供决策依据与上下文。

---

## 1. 设计哲学：Generative Kernel

传统的万能 Shell 脚本存在天然的脆弱性（brittleness）：硬编码的 URL、包管理器参数变更、操作系统版本升级都会让静态脚本在 1–2 年内失效。

参考 [超越 DRY：AI 原生软件工程的思考](https://yage.ai/ai-software-engineering.html) 中提出的 Generative Kernel 概念，我们将 macOS 装机解构为三层架构：

```
┌─────────────────────────────────────────────────────────────┐
│ 1. 引导知识（Prompt / Spec 层）：docs/dev_mac.md             │
│    用户的环境偏好、Cask 映射、决策依据、已知踩坑点与避障策略    │
├─────────────────────────────────────────────────────────────┤
│ 2. 核心套件（确定性执行层）：mac/bootstrap.sh, mac/setup.sh  │
│    无条件运行的基础层：Xcode CLT, Homebrew, uv, 核心 CLI 工具│
├─────────────────────────────────────────────────────────────┤
│ 3. 杠杆工具集（运行时工具层）：brew, mas-cli, curl, gum, AI Agent │
│    运行时交互筛选、动态下载、签名 API 逆向、失败兜底处理      │
└─────────────────────────────────────────────────────────────┘
```

**Agent 执行原则**：
- 能够直接脚本化的基础环节，通过 `mac/` 脚本快速幂等执行。
- 遇脚本未涵盖的应用或参数变更，Agent 以本文档为准则，动态调用工具进行现场解决。
- 严防静默失效：验证环节（`mac/verify.sh`）对系统状态进行逐项审计。

---

## 2. 执行模型与流程

```
./mac/setup.sh (主入口，要求 macOS Darwin + Apple Silicon arm64)
       │
       ▼
 ┌─ 阶段 1：确定性基础层 (mac/bootstrap.sh) ─────────────┐
 │  • Xcode Command Line Tools                           │
 │  • Homebrew (/opt/homebrew)                           │
 │  • gum (charmbracelet TUI 交互引擎)                    │
 │  • uv (Python 现代工具链)                              │
 │  • 核心 CLI 矩阵 (20 个工具，含 zellij, neovim, lazygit)│
 │  • Meslo Nerd Font 字体                                │
 │  • mas-cli (Mac App Store 自动化)                     │
 │  • oh-my-zsh（仅检查目录存在）+ .dotfiles（目录不存在时才 clone / deploy_mac.sh）│
 │  • Git 身份: Yan Wang <grapeot@outlook.com>           │
 │  • macOS 偏好: DSDontWriteNetworkStores = TRUE        │
 └───────────────────────────────────────────────────────┘
       │  (关键阶段：失败即中止)
       ▼
 ┌─ 阶段 2+3：交互选择与安装 (mac/apps.sh) ──────────────┐
 │  • 屏幕 1: 25 款 GUI 桌面应用 (默认全选，可取消)        │
 │    其中 23 个 brew cask + DaVinci 特殊处理 + Antigravity Tools GitHub DMG │
 │  • 屏幕 2: 11 款 brew formula + Rust (rustup.rs)       │
 │  • 屏幕 3: 3 款 Mac App Store 应用 (mas-cli)          │
 │  • 若勾选 DaVinci Resolve，由此阶段调用 mac/davinci.sh │
 └───────────────────────────────────────────────────────┘
       │  (非关键阶段：单项失败记录并继续)
       ▼
 ┌─ 阶段 4：DaVinci Resolve 存在性检查 (mac/setup.sh) ───┐
 │  • 不调用 davinci.sh                                   │
 │  • 若 /Applications/DaVinci Resolve 已存在则跳过        │
 │  • 否则提示单独运行 mac/davinci.sh                      │
 └───────────────────────────────────────────────────────┘
       │
       ▼
 ┌─ 阶段 5：完整性验收 (mac/verify.sh) ──────────────────┐
 │  • CLI 二进制文件可用性与版本检查                     │
 │  • /Applications 核心应用安装验证                     │
 │  • 系统偏好、~/.dotfiles 与 ~/.oh-my-zsh 目录存在性、Git 配置核对 │
 └───────────────────────────────────────────────────────┘
```

---

## 3. 架构与工具链决策

| 组件 / 工具 | 当前决策 | 决策依据 / 废弃替代说明 |
|---|---|---|
| **CPU 架构** | 仅支持 Apple Silicon (`arm64`) | `mac/setup.sh` 对 Darwin + `arm64` 做硬性检查并退出；`bootstrap.sh` / `apps.sh` / `davinci.sh` / `verify.sh` 自身无架构守卫。 |
| **包管理器** | Homebrew (`/opt/homebrew`) | macOS 事实标准，自动配置 shellenv。 |
| **Python** | **uv** (`curl -LsSf https://astral.sh/uv/install.sh`) | 彻底替代 pyenv 与系统全局 pip。不通过 Homebrew 安装，安装至 `~/.local/bin` 或 `~/.cargo/bin`。 |
| **Rust** | 官方 **rustup** (`sh.rustup.rs -y`) | 保持与 Rust 官方工具链一致，避免 Homebrew 版 rust 无法自由切换 toolchain 的问题。 |
| **编辑器** | **Neovim** (`brew install neovim`) | 替代历史上的 MacVim；配合 `.dotfiles` 的 Lua 配置。 |
| **终端复用** | **tmux** + **zellij** | 兼顾传统 tmux 与现代化 zellij。 |
| **字体** | `font-meslo-lg-nerd-font` | 统一终端图标与 powerline 显示。 |
| **窗口管理** | **Rectangle** (`rectangle`) | 替代已被废弃的 Spectacle。 |
| **Tailscale** | **Standalone 独立版** (`tailscale-app`) | 坚决不使用 Mac App Store 版本，[原因见下文](#4-tailscale-专项策略)。 |
| **历史清理** | 已移除所有陈旧依赖 | 彻底移除 Haskell (ghc/cabal)、code-server、sshfs+macfuse、mongodb-community、Alfred 2、Skim。 |

---

## 4. Tailscale 专项策略

**必须安装独立版**（`brew install --cask tailscale-app`），严禁安装 Mac App Store 商店版。

### 为什么避免 App Store 版？
1. **Screen Time Web Filter 冲突**：macOS 开启屏幕时间过滤时，会静默阻断 App Store 沙箱版 Tailscale 的网络通道（社区最常见的网络异常诱因）。
2. **VPN / 代理冲突无法识别**：沙箱限制导致其无法探测 Cloudflare WARP、Little Snitch 等第三方网络扩展冲突。
3. **缺少 CLI 能力**：不支持 `tailscale ssh` 命令，且无法让当前 Mac 作为 Tailscale SSH Server。
4. **版本审核滞后**：关键安全补丁受制于 Apple 商店审核周期。

### 迁移清理步骤
若机器曾安装过 App Store 版本，必须执行完全清理：
1. 退出 Tailscale 并将 `/Applications/Tailscale.app` 移入废纸篓。
2. 清空废纸篓并**重启 macOS**（彻底卸载残留的 Network Extension）。
3. 执行 `brew install --cask tailscale-app`。

---

## 5. DaVinci Resolve 自动化逆向下载

DaVinci Resolve 官方未提供 Homebrew Cask，并在官网设置了信息登记表单。`mac/davinci.sh` 实现了程序化自动化下载：

1. **版本查询**：
   `GET https://www.blackmagicdesign.com/api/support/latest-stable-version/davinci-resolve/mac`
   解析响应 JSON 提取 `downloadId`。
2. **免验注册**：
   `POST https://www.blackmagicdesign.com/api/register/us/download/{downloadId}`
   附带基础 payload，API 不对登记信息真实性做校验。
3. **获取签名 URL**：
   响应中返回 `swr.cloud.blackmagicdesign.com` 的限时签名下载地址。
   > ⚠️ **注意**：URL 中 `verify=` 参数包含 Unix 时间戳，具备严格时效性，绝对不可硬编码或做静态缓存。
4. **下载并打开**：
   使用单线程 `curl -L --progress-bar` 下载，大小约为 6.5 GB（扩展名按 URL 判断为 `.zip` / `.dmg` / `.pkg`）。脚本**不解压**，完成后执行 `open` 唤起安装器或归档。
5. **异常降级**：
   若 Blackmagic 接口规范发生重大变更，脚本将调用 `open https://www.blackmagicdesign.com/products/davinciresolve` 并提示用户手动下载。

---

## 6. 应用与工具矩阵清单

### GUI 应用（`mac/apps.sh` 屏幕 1，共 25 项）

| 应用名称 | Cask / 安装标识 | 类型 / 备注 |
|---|---|---|
| Claude | `claude` | AI 桌面客户端 |
| ChatGPT | `chatgpt` | OpenAI 官方客户端 |
| ChatGPT Atlas | `chatgpt-atlas` | 桌面扩展工具 |
| Cursor | `cursor` | AI 原生代码编辑器 |
| Codex | `codex` | OpenAI 命令行 / 开发者工具 |
| LM Studio | `lm-studio` | 本地大模型运行环境 |
| Ollama | `ollama-app` | 桌面应用（注意：非 formula `ollama`） |
| VS Code | `visual-studio-code` | 代码编辑器 |
| Android Studio | `android-studio` | Android 移动开发 IDE |
| Docker Desktop | `docker-desktop` | 容器化引擎（注意：非 CLI `docker`） |
| iTerm2 | `iterm2` | 高性能终端仿真器 |
| Telegram | `telegram` | 通讯客户端（官方独立版） |
| Zoom | `zoom` | 视频会议 |
| DaVinci Resolve | `mac/davinci.sh` | 专用 API 自动化脚本 |
| Gyroflow | `gyroflow` | 视频陀螺仪增稳工具 |
| BambuStudio | `bambu-studio` | 拓竹 3D 打印切片软件 |
| OpenSCAD | `openscad` | 实体 3D CAD 建模工具 |
| Roon | `roon` | Hi-Fi 音乐播放管理 |
| Tailscale | `tailscale-app` | 独立版网络组网客户端 |
| Windows App | `windows-app` | Microsoft 远程桌面客户端 |
| 1Password | `1password` | 密码与凭据管理器 |
| Firefox | `firefox` | Web 浏览器 |
| Rectangle | `rectangle` | 窗口平铺管理 |
| Antigravity | `antigravity` | 天文观测工具 |
| Antigravity Tools | GitHub Release DMG | `lbjlaq/Antigravity-Manager` aarch64 DMG 下载 |

### 核心无条件 CLI（`mac/bootstrap.sh`，共 20 项）

```
coreutils wget tmux ripgrep htop btop macmon p7zip rsync nmap
shellcheck tig socat gh git-lfs exiftool neovim fd lazygit zellij
```

### 可选 CLI 与库（`mac/apps.sh` 屏幕 2，共 12 项：11 个 formula + rustup）

```
ffmpeg sox zbar pandoc marp-cli
borgbackup cmake go swig
astrometry-net argyll-cms
Rust (via official rustup)
```

### Mac App Store 应用（`mac/apps.sh` 屏幕 3，共 3 项）

```bash
mas install 424390742    # Compressor (Apple 专业视频转码)
mas install 1444636541   # Photomator (图像编辑工具)
# Xcode: 脚本执行 open "macappstore://apps.apple.com/app/id497799835"，不走 mas install
```

---

## 7. 常见踩坑与排错守则

1. **Cask 命名陷阱**：
   - 必须使用 `tailscale-app`（`brew install --cask tailscale` 不存在）。
   - 必须使用 `ollama-app`、`docker-desktop`。
   - `codex` 是 CLI 工具，`codex-app` 是桌面应用。
2. **PATH 与 Shell 环境变量**：
   - Apple Silicon Homebrew 路径为 `/opt/homebrew/bin/brew`。
   - `uv` 位于 `~/.local/bin` 或 `~/.cargo/bin`。
   - `rustup` 环境变量位于 `~/.cargo/env`。
   - `.zshrc` 是指向 `.dotfiles` 的软链接，请勿在安装脚本中破坏该链接。
3. **oh-my-zsh 检测**：
   - Agent 维护时应检查核心引导文件 `~/.oh-my-zsh/oh-my-zsh.sh`，不能仅判断目录是否存在（某些系统镜像存在仅含 `cache/` 的空目录）。
   - 当前 `mac/bootstrap.sh` 与 `setup_ubuntu.sh` **仅**判断 `~/.oh-my-zsh` 目录是否存在，空 stub 目录会被当成已安装而跳过。

---

## 8. 验收标准 (`mac/verify.sh`)

- [x] 所有核心 CLI 命令（`brew`, `git`, `nvim`, `tmux`, `rg`, `fd`, `lazygit`, `gh`, `zellij`, `gum`, `uv`）均正常位于 PATH 且可执行。
- [x] Git 全局配置匹配：`user.name == "Yan Wang"`, `user.email == "grapeot@outlook.com"`。
- [x] 检查 `$HOME/.dotfiles` 与 `$HOME/.oh-my-zsh` **目录存在**（不校验软链接目标，也不检查 `oh-my-zsh.sh`）。
- [x] macOS `DSDontWriteNetworkStores` 偏好设置为 `TRUE`（`defaults read` 值为 `1`）。
- [x] 对一组**固定**的 `/Applications` 应用做存在性检查（iTerm、Visual Studio Code、Claude、ChatGPT、Cursor、Firefox、Telegram、Rectangle、1Password、Tailscale、Zoom、DaVinci Resolve）；缺失记为 optional warn，不按 TUI 选择过滤。
