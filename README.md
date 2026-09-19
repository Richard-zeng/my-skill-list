# My Skill List

沉淀我自建与收集的优秀 Agent Skills，覆盖项目协作、研究分析、日常工作与个人兴趣。

希望把实践中有效的方法整理成可复用的工作流：遇到相似问题时，可以直接调用，并在使用中持续改进。

目前包含 **11 个 Skill（9 个原创、1 个第三方、1 个改编）**，主要面向 **Codex** 使用，后续会继续加入精选第三方作品。

## Skills 导航

| 场景 | Skills | 收录日期 |
| --- | --- | --- |
| 🤝 Agent 协作 | [初始化项目团队](skills/bootstrap-project-agent-team/) | 2026-08-17 |
| 🤝 Agent 协作 | [编排项目团队](skills/orchestrate-project-team/) | 2026-08-17 |
| 🤝 Agent 协作 | [OpenCode 任务委派](skills/opencode/) | 2026-09-07 |
| 🤝 Agent 协作 | [Kimi 设计与开发委派](skills/kimi/) | 2026-09-19 |
| 🤝 Agent 协作 | [项目下一步三件事](skills/project-next-three/) | 2026-09-19 |
| 🧰 Skill 管理 | [发布 Skill](skills/publish-skill/) | 2026-09-06 |
| 🔍 项目研究 | [GitHub 项目速读](skills/github-project-brief/) | 2026-08-17 |
| 📊 图解与可视化 | [Archify](skills/archify/) | 2026-09-06 |
| 📝 工作记录 | [写日报](skills/write-daily-report/) | 2026-08-17 |
| 💼 求职面试 | [面经整理](skills/interview-experience-organizer/) | 2026-08-17 |
| 🎲 游戏辅助 | [璀璨宝石助手](skills/splendor-web-player/) | 2026-08-17 |

收录日期以各 Skill 首次加入本仓库的 Git 提交日期为准。

## 🤝 Agent 协作

### [初始化项目团队](skills/bootstrap-project-agent-team/) · `bootstrap-project-agent-team`

**原创** · 收录于 2026-08-17 · 为新建或现有项目搭建多 Agent 协作基础。

根据项目需要配置角色、协作协议与任务路由，完成团队初始化和启动握手，为后续开发与验收建立清晰的分工。

**适合用在：** 项目刚启动，或准备将已有项目接入多 Agent 协作流程时。

> 使用 $bootstrap-project-agent-team，为当前项目初始化 Agent 协作团队。

### [编排项目团队](skills/orchestrate-project-team/) · `orchestrate-project-team`

**原创** · 收录于 2026-08-17 · 推进已初始化团队的日常协作与交付。

组织管理、调研、开发和独立验收之间的任务流转，支持团队调整、版本启动、状态查询与失败返修。

**适合用在：** 团队已经搭建完成，需要推进一个版本或了解当前交付进展时。

> 使用 $orchestrate-project-team，查询当前团队状态和版本进展。

这两个 Skill 配套使用：前者负责初始化，后者负责后续运行。完整流程依赖 Codex 的项目、任务与跨任务通信能力。

### [OpenCode 任务委派](skills/opencode/) · `opencode`

**原创** · 收录于 2026-09-07 · 通过本地 OpenCode CLI 委派代码探索、实现与审查任务。

支持附加文件、延续或分叉会话，记录会话 ID、任务结果与执行摘要。默认使用 OpenCode 本地配置的模型，仅在明确指定时传入模型参数。

**适合用在：** 希望让 OpenCode 分析项目、完成开发或提供独立代码审查时。

> 使用 $opencode，检查当前项目的代码结构，说明主要模块及其职责。

需要 Bash、jq、已安装的 OpenCode CLI 和可用的模型认证；支持执行本地命令的 Agent 均可使用。执行权限由 OpenCode 本地配置决定，附加文件会发送给选定的模型服务。

### [Kimi 设计与开发委派](skills/kimi/) · `kimi`

**改编** · 收录于 2026-09-19 · 通过本地 Kimi Code CLI 委派 UI/UX 设计、前端实现、代码评审与媒体分析。

支持优先文件提示、会话续接、紧凑进度与 Markdown 结果，适合需要界面设计判断的开发任务；仅在明确要求 Kimi 或选择本 Skill 时调用。

**适合用在：** 希望让 Kimi 评审界面、优化前端实现或分析本地截图与视频时。

> 使用 $kimi，评审当前项目的页面布局，并给出改进建议。

上游支持 macOS/Linux，依赖 Bash 3.2+、jq 和已安装并认证的 Kimi Code CLI；本仓库增加 Windows Git Bash 适配及 Kimi CLI 1.50.0 的非交互输出兼容。非交互模式可能修改文件或执行命令，图片生成与编辑不属于本 Skill 的能力。

来源：[oil-oil/kimi](https://github.com/oil-oil/kimi)，基于上游提交 [d0ef340](https://github.com/oil-oil/kimi/tree/d0ef34045f78333c6652e7c977da19c6ee83b2a4)。保留 MIT 许可证及品牌声明，并改编 Skill 和脚本以支持 Windows 路径、UTF-8、JSONL 输出与会话恢复提示。

### [项目下一步三件事](skills/project-next-three/) · `project-next-three`

**原创** · 收录于 2026-09-19 · 综合项目会话与实际进展，选出近期最值得做的三件事。

通过 Kimi 多轮讨论核验候选与取舍，分别给出事项、原因、收益、工作计划和工作量。优先选择小范围、可验收的行动，排除已完成事项，并根据用户反馈校准后续判断。

**适合用在：** 项目信息分散在多个会话中，需要决定下一步做什么，或重新评估此前建议时。

> 使用 $project-next-three，分析当前项目下一步最值得做的三件事。

依赖已安装并认证的 [Kimi Skill](skills/kimi/)，以及可访问的项目会话或导出记录；会披露历史覆盖缺口，默认只给建议，规则持久修改遵循用户授权。

## 🧰 Skill 管理

### [发布 Skill](skills/publish-skill/) · `publish-skill`

**原创** · 收录于 2026-09-06 · 将指定的本地 Skill 发布或更新到本仓库。

按名称或路径定位源 Skill，整理运行所需文件，在独立工作区中同步 README 的导航、详细介绍、目录树与来源信息，再完成检查、提交、推送发布分支与创建 PR。完成检查后等待用户亲自在 GitHub 合并；核验 PR 已合并后，同步本地目标分支并清理本次临时分支和 worktree。也支持只创建 PR 或仅预览发布差异。

PR 创建遇到工具限制时，先核验是否已创建，再按条件尝试一个已授权的替代通道；无法确认结果则保留现场，避免重复创建。

**适合用在：** 新建了一个 Skill，或更新了已有 Skill，希望快速同步到自己的收藏仓库时。

> 使用 $publish-skill，把 github-project-brief 推到我的仓库。

默认目标固定为 `Richard-zeng/my-skill-list`，需要 Git、可用的 GitHub PR 工具以及推送和创建 PR 的权限；合并由用户亲自执行，并遵循仓库的 CI 与审批要求；其他使用者需先将目标仓库配置改为自己的地址。

## 🔍 项目研究

### [GitHub 项目速读](skills/github-project-brief/) · `github-project-brief`

**原创** · 收录于 2026-08-17 · 将公开 GitHub 仓库整理为有证据的中文项目分析报告。

结合 README、代码结构、Issue、Release 与提交记录，梳理项目定位、实现方式、活跃情况和使用限制，帮助判断是否值得学习、集成或二次开发。

**适合用在：** 发现一个感兴趣的开源项目，想先理解它解决什么问题、适不适合自己时。

> 使用 $github-project-brief，分析 https://github.com/owner/repo，重点判断它是否适合接入我的工作流。

## 📊 图解与可视化

### [Archify](skills/archify/) · `archify`

**第三方** · 收录于 2026-09-06 · 将自然语言、Mermaid 或代码结构转为可交互的图解。

支持架构图、工作流、时序图、数据流与生命周期图，输出可独立打开的 HTML，帮助理解系统结构和运行过程。

**适合用在：** 梳理项目架构、解释复杂流程，或将代码中的关系整理成可浏览的图解时。

> 使用 $archify，为这个项目生成可交互的架构图。

需要 Node.js 18 或更高版本；真实浏览器校验还需要 Chrome/Chromium。当前收录版本为 `2.17.0-dev.1`，固定至上游提交 [d8e4daf](https://github.com/tt-a1i/archify/tree/d8e4daf2610d512821365f41b139d874b29efe81/archify)。

来源：[tt-a1i/archify](https://github.com/tt-a1i/archify)。本仓库采用上游工具整理独立运行包，保留 Skill 正文与运行代码，移除开发依赖和开发命令。可设置 `ARCHIFY_UPDATE_CHECK_DISABLED=1` 关闭可选的联网更新提醒及提醒状态写入。

## 📝 工作记录

### [写日报](skills/write-daily-report/) · `write-daily-report`

**原创** · 收录于 2026-08-17 · 从当天材料中提取工作事实，整理成清晰的日报。

支持基于日记、工作进展、会议记录、飞书材料或已有草稿生成日报，重点区分当天成果、未推进事项、问题与下一步动作。

**适合用在：** 工作信息分散在多处，需要整理成准确、简洁的当日记录时。

> 使用 $write-daily-report，根据以下工作记录整理今天的日报。

使用外部材料需要相应访问能力；迁移到其他项目时，可能需要调整保存路径。

## 💼 求职面试

### [面经整理](skills/interview-experience-organizer/) · `interview-experience-organizer`

**原创** · 收录于 2026-08-17 · 将原始面试记录整理成可复习、可改进的面经。

从逐字稿、面试笔记或面后回忆中整理问答，补充回答改进点、参考回答和可能的后续追问。

**适合用在：** 面试结束后复盘表现，或准备下一轮面试时。

> 使用 $interview-experience-organizer，整理以下面试记录，重点分析回答中的不足和可能的追问。

首次使用会确认背景信息与材料授权范围；个人资料的持久保存需要单独授权。

## 🎲 游戏辅助

### [璀璨宝石助手](skills/splendor-web-player/) · `splendor-web-player`

**原创** · 收录于 2026-08-17 · 分析网页端《璀璨宝石》棋局，提供行动建议或辅助操作。

结合可见牌面、筹码、发展卡与回合状态，检查动作合法性并分析可选策略。

**适合用在：** 想理解当前局面的选择，或在网页对局中获得辅助时。

> 使用 $splendor-web-player，分析当前棋局，说明可选动作和推荐理由。

依赖可用的浏览器控制工具，使用时需确认网页规则与游戏变体。

## 安装与使用

选择需要的 Skill，将其**整个目录**复制到安装位置，保留附带的脚本、模板和参考文件。

| 使用范围 | 安装位置 |
| --- | --- |
| 个人全局使用 | `~/.codex/skills/` |
| 当前项目使用 | 项目中的 `.agents/skills/` |

安装后，可通过名称调用：

```text
使用 $github-project-brief 分析 owner/repo
```

也可以通过自然语言表达需求，由 Agent 根据 Skill 描述识别：

```text
帮我研究一下这个 GitHub 项目，看看是否值得集成。
```

每个 Skill 的具体流程、依赖与限制，以对应目录中的 `SKILL.md` 为准。

## 仓库结构

```text
skills/
├── bootstrap-project-agent-team/   # 初始化项目团队
├── orchestrate-project-team/       # 编排项目团队
├── opencode/                       # 通过 OpenCode 委派任务
├── kimi/                           # 通过 Kimi 委派设计与开发任务
├── project-next-three/             # 项目下一步三件事
├── publish-skill/                  # 发布 Skill 到本仓库
├── github-project-brief/           # GitHub 项目速读
├── archify/                        # 可交互图解
├── write-daily-report/             # 写日报
├── interview-experience-organizer/ # 面经整理
└── splendor-web-player/            # 璀璨宝石助手
```

每个目录以 `SKILL.md` 为入口，按需包含 `references/`、`scripts/`、`assets/` 等配套内容。

## 来源与致谢

当前仓库包含 9 个原创 Skill，以及第三方 Skill **Archify**（[tt-a1i/archify](https://github.com/tt-a1i/archify)）和改编 Skill **Kimi**（基于 [oil-oil/kimi](https://github.com/oil-oil/kimi)，增加 Windows 与 CLI 兼容适配）。

Archify 代码遵循包内 [MIT LICENSE](skills/archify/LICENSE)，保留 tt-a1i 与 Cocoon AI 的版权信息；品牌图标另见 [第三方素材声明](skills/archify/THIRD_PARTY_NOTICES.md)。

Kimi 遵循包内 [MIT LICENSE](skills/kimi/LICENSE)，保留 Kimi Skill contributors 的版权信息；Kimi 品牌标识不属于该 MIT 许可，另见 [品牌声明](skills/kimi/NOTICE)。

本仓库暂未设置统一许可证，各 Skill 的版权与许可按其对应说明处理。后续收录的第三方作品会注明原作者、项目链接及许可信息；基于他人作品修改的版本会标注为“改编”。
