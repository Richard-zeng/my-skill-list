# my-skill-list

`my-skill-list` 是一组经过整理、可独立复制使用的个人 Codex Skills。本仓库收录仓库维护者确认的 7 个 Skill（6 个自建、1 个第三方），保留运行所需的直接依赖，并排除本地缓存、临时生成文件和私人候选人资料。

## Skill 总览与目录

| Skill | 用途与典型触发 | 来源归属 | 目录 |
| --- | --- | --- | --- |
| bootstrap-project-agent-team | 在新建或现有 Codex 项目中安装可审计的多 Agent 团队基线；适合“启动项目团队”“安装五角色工作流”。 | 仓库维护者自建，全局 Skill 整理版 | [skills/bootstrap-project-agent-team](skills/bootstrap-project-agent-team/) |
| orchestrate-project-team | 运行已有的管理、调研、开发、验收闭环；适合“启动已确认版本”“查询团队状态”“交给开发并独立验收”。 | 仓库维护者自建，项目级 Skill 整理版 | [skills/orchestrate-project-team](skills/orchestrate-project-team/) |
| splendor-web-player | 读取并分析网页端《璀璨宝石》局面，校验合法动作并给出或执行建议。 | 仓库维护者自建，游戏项目 Skill 整理版 | [skills/splendor-web-player](skills/splendor-web-player/) |
| github-project-brief | 调研公开 GitHub 仓库，输出有证据的中文“项目速读报告”。 | 仓库维护者自建，全局 Skill 整理版 | [skills/github-project-brief](skills/github-project-brief/) |
| write-daily-report | 从日记、进展、会议、飞书材料或草稿中筛选本人当天事实并生成日报。 | 仓库维护者自建，项目级 Skill 整理版 | [skills/write-daily-report](skills/write-daily-report/) |
| interview-experience-organizer | 将明确授权的面试记录整理为 Q&A、改进点、参考回答与追问预测。发布版已去身份化并加入首次使用隐私 gate。 | 仓库维护者自建，全局 Skill 的隐私整理版 | [skills/interview-experience-organizer](skills/interview-experience-organizer/) |
| archify | 将自然语言、Mermaid 或代码结构转为可交互的架构图、工作流、时序图、数据流与生命周期图，输出独立 HTML。 | 第三方：[tt-a1i/archify](https://github.com/tt-a1i/archify)，MIT；保留原作者及第三方素材声明 | [skills/archify](skills/archify/) |

每个目录以 `SKILL.md` 为入口；`references/`、`scripts/`、`assets/`、`agents/` 等目录仅在对应 Skill 运行需要时存在。

## 安装与使用

可按使用范围选择一种安装方式：

1. 个人全局使用：把所需的单个 Skill 目录复制到 `~/.codex/skills/`。
2. 单个项目使用：把所需目录复制到项目的 `.agents/skills/`。
3. 保持整个目录一起克隆也可以，但 Codex 实际加载的是安装位置中的各个 Skill 目录。

安装后，以 Skill 名称或其描述中的自然语言意图触发。例如：

- `使用 $github-project-brief 分析 owner/repo`
- `使用 $splendor-web-player 分析当前棋局`
- `使用 $interview-experience-organizer 整理我明确授权的这份记录`
- `使用 $archify 为这个项目生成可交互的架构图`

运行前请阅读对应 `SKILL.md`。需要脚本的 Skill 还应确认本机已有相应的 Python、浏览器控制或 Codex 任务工具。

## 面经 Skill 的隐私机制

`interview-experience-organizer` 不含真实姓名、学校、私人绝对路径、个人简历或面试文件名，也不预置个人经历和项目指标。

首次使用且 `references/candidate-profile.local.md` 不存在时，Skill 会在读取材料或生成面经前：

1. 展示隐私说明，并说明回答默认只在当前会话内使用。
2. 一次性询问称呼/别名、教育背景、目标岗位/公司、经历与职责、经确认的指标及口径、稳定表达/禁用口径、材料路径与本轮授权范围、是否愿意持久保存。
3. 要求每项得到响应，同时允许逐项回复“暂不提供”；缺失信息不会被推断。
4. 只读取用户本轮明确列出的文件或目录；扩展路径或范围必须再次授权。
5. 将“愿意保存”与“授权写入”分开：只有用户再次明确授权准确保存路径和内容后，才能创建本地画像文件。

默认画像 `references/candidate-profile.md` 只是空白 schema。可选的 `references/candidate-profile.local.md` 已由包内 `.gitignore` 排除，不应提交或分发。

## 已知限制

### bootstrap-project-agent-team

- 依赖 Codex 的项目、任务和跨任务消息能力；在不支持长期任务路由的环境中不能完成完整握手。
- 负责首次安装，不负责已安装团队的日常版本流转。
- 修改已有 `AGENTS.md`、冲突配置或 Git 状态时仍需单独授权。

### orchestrate-project-team

- 假设项目已完成团队初始化，并存在有效的本机路由注册表。
- 只编排角色边界和交付闭环，不替代产品目标确认，也不允许开发 Agent 自我验收。
- 多任务共享工作区时必须严格保持单一业务写入者。

### splendor-web-player

- 网页实现、规则变体和可见状态差异较大，每次动作前仍需重新核验页面与合法性。
- 浏览器操作依赖可用的 Playwright 或等价浏览器工具。
- `scripts/evaluate_state.py` 是启发式辅助，不替代对真实 UI、回合和规则的确认。

### github-project-brief

- 当前 Star、Issue、Release 和提交活跃度依赖网络与 GitHub 可访问性，可能受缓存或速率限制影响。
- 报告用于快速研究和架构判断，不等同于完整代码审计、安全审计或法律意见。
- 私有或不可访问仓库需要用户另行提供材料和访问授权。

### write-daily-report

- 高质量输出依赖目标日期内可追溯、且与本人有关的材料；材料不足时不能靠背景填充。
- 飞书聊天、妙记和文档记录只有在连接器可用且用户明确授权时才能读取。
- 当前规则保留原项目的知识库目录约定，迁移到其他项目时可能需要调整保存路径。

### interview-experience-organizer

- 首次使用必须完成隐私问答，因此不会在未确认范围时直接处理材料。
- 不会自动发现简历或历史记录；材料路径、目录边界和扩展范围都需要用户明确授权。
- 本地画像默认不跨设备同步；脚本只生成空白文档骨架，不负责自动填充面经内容。

### archify

- 来源版本为 `2.17.0-dev.1`，固定至上游提交 [d8e4daf2610d512821365f41b139d874b29efe81](https://github.com/tt-a1i/archify/tree/d8e4daf2610d512821365f41b139d874b29efe81/archify)，属于开发版。后续更新需要显式同步，不自动跟随上游。
- 使用上游 `scripts/stage-clean-skill.mjs` 整理独立运行包；保留渲染器、预生成校验器、schema、示例和直接依赖，排除测试、依赖锁文件和开发期生成脚本，并移除 package.json 的开发命令与开发依赖。Skill 正文与运行代码保留上游内容。
- 需要 Node.js 18 或更高版本，日常渲染无需在 Skill 内执行 npm install；真实浏览器校验还需要可用的 Chrome/Chromium。
- 上游保留可选的联网更新提醒；设置 `ARCHIFY_UPDATE_CHECK_DISABLED=1` 可关闭该检查及提醒状态写入，检查器不会自动安装更新。
- 代码遵循包内 [MIT LICENSE](skills/archify/LICENSE)，其中保留 tt-a1i 与 Cocoon AI 的版权信息；品牌图标另受 [THIRD_PARTY_NOTICES.md](skills/archify/THIRD_PARTY_NOTICES.md) 中记录的许可和商标条款约束。

## 整理规则

- 仓库顶层 `skills/` 下仅保留维护者确认收录的 Skill；自建与第三方来源在目录中分别标明，不收录未确认来源的内容。
- 每个包保留 `SKILL.md` 以及其运行所需的直接依赖；不为了统一外观改写无关功能。
- 排除 `__pycache__/`、`*.pyc`、`candidate-profile.local.md`、临时输出和私人文件；上游分发包运行必需的预生成代码与示例保留。
- 面经包同时修改其自建源 Skill 与发布副本，确保二者采用同一去身份化和隐私规则。
- 本仓库不创建统一根 `LICENSE`；各 Skill 的版权归原作者，第三方内容必须单独核验并在包内保留其许可及归属信息。
