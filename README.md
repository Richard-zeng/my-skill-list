# My Skill List

沉淀我自建与收集的优秀 Agent Skills，覆盖项目协作、研究分析、日常工作与个人兴趣。

希望把实践中有效的方法整理成可复用的工作流：遇到相似问题时，可以直接调用，并在使用中持续改进。

目前包含 **7 个 Skill（6 个原创、1 个第三方）**，主要面向 **Codex** 使用，后续会继续加入精选第三方作品。

## Skills 导航

| 场景 | Skills | 收录日期 |
| --- | --- | --- |
| 🤝 Agent 协作 | [初始化项目团队](skills/bootstrap-project-agent-team/) | 2026-08-17 |
| 🤝 Agent 协作 | [编排项目团队](skills/orchestrate-project-team/) | 2026-08-17 |
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
├── github-project-brief/           # GitHub 项目速读
├── archify/                        # 可交互图解
├── write-daily-report/             # 写日报
├── interview-experience-organizer/ # 面经整理
└── splendor-web-player/            # 璀璨宝石助手
```

每个目录以 `SKILL.md` 为入口，按需包含 `references/`、`scripts/`、`assets/` 等配套内容。

## 来源与致谢

当前仓库包含 6 个原创 Skill，以及来自 [tt-a1i/archify](https://github.com/tt-a1i/archify) 的第三方 Skill **Archify**。

Archify 代码遵循包内 [MIT LICENSE](skills/archify/LICENSE)，保留 tt-a1i 与 Cocoon AI 的版权信息；品牌图标另见 [第三方素材声明](skills/archify/THIRD_PARTY_NOTICES.md)。

本仓库暂未设置统一许可证，各 Skill 的版权与许可按其对应说明处理。后续收录的第三方作品会注明原作者、项目链接及许可信息；基于他人作品修改的版本会标注为“改编”。
