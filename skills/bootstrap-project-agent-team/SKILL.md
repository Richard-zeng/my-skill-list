---
name: bootstrap-project-agent-team
description: 在新建或现有 Codex 项目中安装并初始化可审计的多 Agent 协作模式，包括总控、管理、调研、开发、独立验收角色，项目级运行 Skill、结构化消息协议、长期任务创建、真实 ID 注册和启动握手。用户要求项目启动、搭建 Agent 团队、复制本项目协作模式、安装五角色工作流或为新仓库建立多 Agent 基线时使用。不要用于单次临时并行任务或仅查询已有团队状态。
---

# 启动项目 Agent 团队

把启动与运行分开：本 Skill 安装静态控制层并创建长期任务；安装完成后，把版本协作交给项目级 `$orchestrate-project-team`。

## 选择团队规模

- 默认使用 `core`：管理、开发、验收。适合目标明确、无需长期调研或频繁调整角色的项目。
- 用户明确要求复制本项目模式、长期团队、独立调研或动态角色管理时使用 `full`：总控、管理、调研、开发、验收。
- 只有真实并行、上下文隔离或独立判定收益大于协调成本时才增加其他角色。

静态模板始终安装五份角色配置；团队规模只决定创建哪些长期任务。

## 启动流程

### 1. 只读盘点

1. 确认目标项目绝对路径、项目名称、是否为 Git 仓库及是否已有 `AGENTS.md`、`.codex/`、`.agents/skills/`。
2. 列出已有任务，按项目路径和规范标题查重：`<项目名> · <角色> Agent`。
3. 不把源项目的任务 ID、注册表或业务状态复制到目标项目。
4. 用户只要求说明或规划时停在这里，不写文件、不创建任务。

### 2. 规划静态安装

运行：

```text
python <本 Skill 路径>/scripts/install_team_template.py --project <目标项目绝对路径>
```

读取 JSON 计划：

- `create`：可安全创建；
- `identical`：已安装且内容一致；
- `conflict`：目标已存在但不同，禁止自动覆盖。

若存在 `conflict`，展示具体文件与差异范围，等待用户决定合并或放弃。不要使用覆盖参数，也不要删除现有文件。

### 3. 获得写入授权

- 用户明确说“在这个项目启动/安装 Agent 团队”时，视为只授权计划中列出的静态团队文件和所选长期任务。
- 修改已有 `AGENTS.md`、替换冲突文件、初始化 Git、部署、发布或删除任务仍需单独授权。
- 写入前复述目标项目、团队规模和将创建的文件/任务数量。

### 4. 安装静态控制层

无冲突且授权明确后运行：

```text
python <本 Skill 路径>/scripts/install_team_template.py --project <目标项目绝对路径> --apply
```

然后：

1. 从 `assets/project-agents-section.md` 读取协作约束。
2. 目标没有 `AGENTS.md` 时，用补丁创建；已有文件时展示带 `BEGIN/END codex-multi-agent-team` 标记的最小合并差异并再次确认。
3. 用补丁确保 `.gitignore` 含 `.codex/team/registry.local.json`；保留其他规则。
4. 不创建带空 ID 的注册表。注册表必须等长期任务创建成功后一次性写入。

### 5. 创建长期任务

1. 只有用户明确要求启动团队时才创建任务；先查重，恰好一个则复用，多个则请用户选择。
2. 不指定模型或推理强度，沿用用户默认设置。
3. 非 Git 项目使用当前保存项目的 local 环境。Git 项目先说明共享工作区与独立 worktree 的差异；本模式要求共享代码状态和单写入者，只有用户确认后才使用 local。
4. 为所选角色创建规范标题任务，并发送初始化消息，要求读取：
   - `.codex/agents/<role>.toml`
   - `.agents/skills/orchestrate-project-team/SKILL.md`
   - `.agents/skills/orchestrate-project-team/references/protocol.md`
   - 根目录 `AGENTS.md`
5. 初始化轮禁止业务工作和文件写入，只允许回报 `ROLE_READY`。

### 6. 注册与握手

1. 将真实 `thread_id`、`host_id`、标题和项目路径写入 `.codex/team/registry.local.json`。不得写入模板或可提交文件。
2. `core`：开发和验收向管理发送 `TEAM_READY`，管理汇总 `TEAM_HANDSHAKE PASS/FAIL`。
3. `full`：调研向总控发送 `TEAM_READY`；总控核对五角色后向管理、开发、验收广播 `TEAM_UPDATE`，再回报 `TEAM_EXPANSION PASS/FAIL`。
4. 使用 `wait_threads` 等待状态变化，不高频轮询完整任务历史。
5. 任一角色、标题、项目路径或 ID 不唯一时停止，不启动业务。

### 7. 验证与交接

完成前验证：

- 项目级 Skill 通过 `quick_validate.py`；
- 所有 TOML、YAML、JSON 可解析；
- 注册表角色集合与所选规模一致；
- 所有长期任务绑定目标项目且处于 `idle`；
- 握手消息有明确 PASS 和证据；
- 没有运行中的临时 subagent。

最后告诉用户：项目已安装哪些文件、创建哪些任务、如何调用 `$orchestrate-project-team` 启动首个版本。

## 失败与收口

- 文件冲突：不写入，列出冲突并请求决定。
- 部分任务创建成功：保留已创建任务，报告 ID；未经授权不归档或删除。
- 初始化或握手失败：停止业务流转，修复后重试同一 work_item。
- 临时验证 subagent 完成或失败后，收集结果并关闭；长期任务保持 `idle`，不作为临时 subagent 关闭。
