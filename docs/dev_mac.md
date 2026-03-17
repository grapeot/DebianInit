# Mac 初始化：Agent-Oriented Generative Kernel

本文档是 `debianinit` mac 初始化能力的升级规划。核心思路从"写一个万能 shell 脚本"转向"构建一个面向 AI Agent 的 Generative Kernel"。

## 设计哲学

传统的自动化初始化脚本有一个根本性问题：它必须对环境做大量 rigid 的假设（URL 不变、命令行参数不变、安装流程不变），这使得脚本天然 brittle。每隔几年就需要人工维护一次，而每次维护的上下文早已丢失。

参考 [超越DRY：AI原生软件工程的思考](https://yage.ai/ai-software-engineering.html) 中提出的 Generative Kernel 概念，我们把这个 repo 重新定义为一个 prompt + tools 的组合体，而非一个传统脚本。具体来说：

1. **核心套件**（确定性层）：无条件执行的系统配置和基础工具安装。这些逻辑稳定，用传统脚本实现即可。
2. **引导知识**（prompt 层）：本文档本身就是引导知识。它告诉 AI Agent 用户的偏好、每个应用的安装策略、已知的坑和决策理由。AI 读完这份文档后，可以根据当时的实际情况灵活执行。
3. **杠杆工具集**（工具层）：brew、mas-cli、curl、Tavily 搜索等。AI Agent 可以在运行时组合这些工具来解决问题，而不需要我们预先写死每种情况。

这意味着安装流程不再是"跑一个脚本"，而是"把这份文档交给 AI Agent，让它帮你装机"。对于 brew 能搞定的，它直接装；搜索能找到下载链接的，它现场下载安装；必须手动操作的，它给你一个链接列表。

## 执行模型

```
用户启动 Agent，指向本文档
        │
        ▼
  ┌─ 阶段 1：无条件基础层（脚本化）──┐
  │  Xcode CLT、Homebrew、git config  │
  │  系统偏好设置（defaults write）    │
  └────────────────────────────────────┘
        │
        ▼
  ┌─ 阶段 2：交互式选择（TUI）───────┐
  │  展示可选应用列表，用户勾选      │
  │  分类：开发工具 / GUI 应用 / 字体│
  └────────────────────────────────────┘
        │
        ▼
  ┌─ 阶段 3：自动安装 ──────────────┐
  │  brew install（formula + cask）   │
  │  mas install（App Store 应用）    │
  │  curl 下载（有稳定 URL 的）       │
  └────────────────────────────────────┘
        │
        ▼
  ┌─ 阶段 4：兜底处理 ──────────────┐
  │  搜索下载链接（Tavily/web）       │
  │  或给出手动操作指引               │
  └────────────────────────────────────┘
        │
        ▼
  ┌─ 阶段 5：验收 ──────────────────┐
  │  检查关键命令可用性               │
  │  验证版本和路径                    │
  └────────────────────────────────────┘
```

## 已确认决策

- **Homebrew**：使用官方当前安装方式（`/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`）
- **Python**：不装全局科学计算包，完全迁移到 uv 生态（`curl -LsSf https://astral.sh/uv/install.sh | sh`），不再需要 pyenv
- **编辑器**：MacVim → Neovim（`brew install neovim`）
- **字体**：默认安装 Nerd Font（`brew install --cask font-meslo-lg-nerd-font`）
- **窗口管理**：Spectacle → Rectangle（`brew install --cask rectangle`）
- **删除项**：Haskell（cabal-install + ghc）、code-server、sshfs-mac + macfuse、mongodb-community、pyenv。旧版 Skim、Spectacle、Alfred 2 不再安装。
- **Tailscale**：使用 standalone 版本（`brew install --cask tailscale-app`），不用 App Store 版本。[原因见下方](#tailscale-安装说明)

## 应用清单与安装策略

### Tier 1：brew install --cask（全自动，23 个）

| 应用 | Cask 名 | 备注 |
|------|---------|------|
| Claude | `claude` | |
| ChatGPT | `chatgpt` | |
| ChatGPT Atlas | `chatgpt-atlas` | |
| Cursor | `cursor` | |
| Codex | `codex` | OpenAI CLI 工具 |
| LM Studio | `lm-studio` | |
| Ollama | `ollama-app` | 注意是 cask 不是 formula |
| VS Code | `visual-studio-code` | |
| Android Studio | `android-studio` | |
| Docker | `docker-desktop` | 注意不是 `docker` |
| iTerm | `iterm2` | |
| Telegram | `telegram` | 独立版本，非 App Store |
| Zoom | `zoom` | |
| DaVinci Resolve | 见 Tier 3 | 需手动下载 |
| Gyroflow | `gyroflow` | |
| Photomator | 见 Tier 2 | App Store only |
| BambuStudio | `bambu-studio` | |
| OpenSCAD | `openscad` | |
| Roon | `roon` | 需订阅 |
| Tailscale | `tailscale-app` | standalone 版本 |
| Windows App | `windows-app` | |
| 1Password | `1password` | |
| Firefox | `firefox` | |
| Antigravity | `antigravity` | Google 天文 app |
| Antigravity Tools | `lbjlaq/antigravity-manager/antigravity-tools` | 需先 `brew tap lbjlaq/antigravity-manager` |

brew formula 开发工具（无条件安装）：

```
coreutils wget tmux ripgrep htop btop macmon p7zip rsync nmap shellcheck tig socat
gh git-lfs exiftool neovim fd lazygit
```

brew formula 媒体/创作相关（按需）：

```
ffmpeg sox zbar pandoc marp-cli
```

brew formula 专业领域（按需）：

```
borgbackup                    # 备份
cmake go swig                 # 编译/开发
```

### Tier 2：App Store（mas-cli 可自动化，3 个）

```bash
# 需要先安装 mas-cli：brew install mas
mas install 424390742    # Compressor ($49.99)
mas install 1444636541   # Photomator (subscription)
# Xcode：体积太大且依赖多，建议手动从 App Store 安装
```

### Tier 3：DaVinci Resolve（API 自动化或手动兜底）

DaVinci Resolve 没有 brew cask，官网要求填注册表单才给下载链接。但 Blackmagic 的下载 API 已被 Linux 社区逆向工程（Arch AUR、NixOS 均有实现），可以程序化获取下载链接。

**API 流程**（参考 [CachyOS PKGBUILD](https://github.com/CachyOS/CachyOS-PKGBUILDS/blob/master/davinci-resolve/PKGBUILD) 和 [NixOS package.nix](https://github.com/NixOS/nixpkgs/blob/master/pkgs/by-name/da/davinci-resolve/package.nix)）：

1. 获取最新版本的 `downloadId`：`GET /api/support/latest-stable-version/davinci-resolve/mac`
2. POST 假注册数据到 `https://www.blackmagicdesign.com/api/register/us/download/{downloadId}`（API 不验证注册信息真实性）
3. 响应返回带签名的 `swr.cloud.blackmagicdesign.com` 下载 URL
4. 直接 curl 下载（约 6.5GB）

**注意**：URL 中的 verify token 基于 Unix 时间戳，会过期，不能缓存或硬编码。每次执行必须走完整 API 流程获取新 URL。

**Agent 执行策略**：
1. 优先尝试 API 自动下载
2. 如果 API 变更导致失败，回退到 `open "https://www.blackmagicdesign.com/products/davinciresolve"` 让用户手动下载

### 安装汇总

| 类别 | 数量 | 自动化方式 |
|------|------|-----------|
| brew cask | 23 | `brew install --cask` |
| App Store | 3 | `mas install` 或手动 |
| API 自动化 | 1 | Blackmagic API（兜底手动） |
| **合计** | **27** | **自动化率 ~100%** |

## Tailscale 安装说明

Tailscale 官方推荐使用 standalone 版本而非 App Store 版本。App Store 版本受 macOS 沙箱限制，存在以下问题：

- macOS Screen Time web filter 会阻断 Tailscale 连接（非常常见的坑）
- 无法检测第三方 VPN 冲突（Cloudflare WARP、Little Snitch 等）
- 安全更新需等待 Apple 审核
- 不支持 `tailscale ssh` CLI 命令
- 不能作为 Tailscale SSH server

standalone 版本安装：`brew install --cask tailscale-app`

如果从 App Store 版本迁移，必须先彻底卸载：删除应用 → 清空废纸篓 → 重启 → 再装 standalone 版本。残留的 App Store 系统扩展会和 standalone 冲突。

## 基础层脚本内容（无条件执行）

以下逻辑足够稳定，可以直接脚本化：

```bash
# 1. Xcode Command Line Tools
xcode-select --install 2>/dev/null || true

# 2. Homebrew
if ! command -v brew &>/dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# 3. uv (Python 工具链)
if ! command -v uv &>/dev/null; then
    curl -LsSf https://astral.sh/uv/install.sh | sh
fi

# 4. 核心 CLI 工具
brew install coreutils wget tmux ripgrep htop btop macmon p7zip rsync \
    nmap shellcheck tig socat gh git-lfs exiftool neovim fd lazygit

# 5. 字体
brew install --cask font-meslo-lg-nerd-font

# 6. mas-cli (用于 App Store 自动化)
brew install mas

# 7. oh-my-zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

# 8. git 配置
git config --global user.name "Yan Wang"
git config --global user.email grapeot@outlook.com
git config --global color.ui auto
git config --global core.fileMode false
git config --global push.default simple

# 9. dotfiles
if [ ! -d "$HOME/.dotfiles" ]; then
    git clone --recursive https://github.com/grapeot/.dotfiles "$HOME/.dotfiles"
    "$HOME/.dotfiles/deploy_mac.sh"
fi

# 10. 系统偏好
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool TRUE
```

## 与现有文件的关系

- `osx.sh`：保留不改，作为历史参考。
- 本文档（`dev_mac.md`）：作为 Generative Kernel 的引导知识，是 Agent 执行装机任务时的主要参考。
- 未来可以添加 `mac/bootstrap.sh` 将基础层脚本独立出来，但核心决策和灵活安装仍由 Agent 根据本文档执行。

## 验收标准

- 新机器从零执行后，30 分钟内具备可用开发环境。
- brew cask 应用全部一键安装，无需人工干预。
- App Store 应用通过 mas-cli 或给出明确指引。
- 失败点可定位，Agent 能给出诊断和替代方案。
- 与现有 `.dotfiles`、Neovim 配置可协同工作。
