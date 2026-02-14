# mac 初始化脚本升级计划（先规划，不直接改）

本文档用于给 `debianinit` 的 mac 初始化能力做一次现代化升级规划，目标是降低脚本失效风险、减少破坏性改动，并与当前开发环境（Neovim + 现代工具链）对齐。

## 现状结论

当前 `osx.sh` 是一份历史脚本，核心问题不是“脚本不能跑”，而是“依赖和分发方式已经过时”。典型风险如下：

- Homebrew 安装方式仍是旧 `ruby -e` 入口，已不推荐。
- 直接使用 `easy_install/pip` 安装 Python 包，缺少隔离与版本策略。
- `macvim --override-system-vim` 的时代假设已不成立，编辑器应迁移到 `neovim`。
- 某些下载链接和应用版本高度陈旧（例如旧版 Skim、Spectacle、Alfred 2）。
- 脚本把“系统初始化”和“个人偏好安装”揉在一起，导致维护成本高。

## 升级目标

- 可重复执行：脚本重复运行不会破坏现有环境。
- 可观测：每一步有明确日志与失败提示。
- 可分层：基础系统层、开发工具层、个人应用层拆分。
- 可迁移：明确与 `~/.dotfiles`、`Neovim`、`uv`/`python` 工作流的接口。

## 建议的分层结构

建议后续把 mac 初始化拆成以下文件（本次仅规划，不落地改动）：

1. `mac/bootstrap.sh`
   - Xcode CLT 检查
   - Homebrew 检查/安装
   - 基础命令（git/curl/wget/tmux/trash）

2. `mac/dev_tools.sh`
   - Neovim、ripgrep、fd、node、lazygit 等开发工具
   - Python 相关仅安装运行时，不做全局 pip 污染

3. `mac/apps.sh`
   - GUI 应用安装（建议优先 `brew install --cask`）
   - 对历史链接下载的应用做替换或删除

4. `mac/preferences.sh`
   - `defaults write` 一类系统偏好

5. `mac/post_check.sh`
   - 环境验收：命令可用性、版本、关键路径

## 升级步骤（推荐顺序）

### 阶段 0：冻结现状

- 保留现有 `osx.sh` 不改，作为回退入口。
- 新建 `mac/` 目录并逐步迁移逻辑。

### 阶段 1：先替换高风险点

- 替换 Homebrew 安装逻辑为官方当前方式。
- 去除 `easy_install`，不再在系统 Python 上安装科学计算包。
- 把编辑器默认从 `macvim` 转为 `neovim`。

### 阶段 2：拆分模块并做幂等化

- 每个脚本开头增加依赖检查函数（command exists + version check）。
- 所有安装操作采用“已安装跳过”策略。
- 对远程下载使用可校验来源（优先 cask/release 页面）。

### 阶段 3：与 dotfiles/neovim 对齐

- 仅负责拉取 `~/.dotfiles`，不在该仓库内写死过多个人配置。
- Neovim 配置交给 `~/.config/nvim` 或 dotfiles 管理，不在初始化脚本硬编码细节。

## 验收标准

- 新机器从零执行后，30 分钟内具备可用开发环境。
- 重复执行不报错且不重复安装。
- 失败点可定位（哪个脚本、哪一行、哪个命令失败）。
- 与现有 `.dotfiles`、Neovim 配置可协同工作。

## 不在本次计划内

- 不立刻替换全部 GUI 应用。
- 不强推系统级 Python 科学栈。
- 不直接改写你当前 `.dotfiles` 的历史逻辑。

---

当前建议是：先把这份文档当作重构蓝图，等你确认后再分阶段提交脚本改造，避免一次性大改导致初始化链条断裂。
