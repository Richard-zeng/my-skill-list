# 项目团队消息协议 v1

## 事实来源

- 用户批准的目标和验收标准优先级最高。
- 任务消息历史是事件日志；`.codex/team/registry.local.json` 只保存路由，不保存业务状态。
- 总控、管理、调研、开发、验收分别拥有团队拓扑、版本范围、事实证据、实现、判定权，任何角色不得越权替代另一角色。

## 消息信封

跨任务消息先给一句人类可读摘要，再附一个 JSON 代码块。所有字段必须存在；没有内容时使用空数组。

```json
{
  "protocol": "project-team/v1",
  "message_id": "V-20260816-example:manager:20260816T120000Z",
  "work_item": "V-20260816-example",
  "from": "manager",
  "to": ["developer"],
  "type": "IMPLEMENT_REQUEST",
  "iteration": 1,
  "summary": "实现一句话摘要",
  "scope": ["本轮必须完成的内容"],
  "non_goals": ["本轮明确不做的内容"],
  "acceptance_criteria": ["可观察、可判定的标准"],
  "changes": [],
  "evidence": [],
  "blocking_issues": [],
  "next_action": "developer 实现并请求 verifier 验收"
}
```

使用 `<work_item>:<sender>:<UTC 时间>` 生成 `message_id`；重试可追加短序号。接收方发现重复 ID 时只确认，不重复执行。

## 消息类型

| 类型 | 发送方 → 接收方 | 必需内容 |
| --- | --- | --- |
| `TEAM_INIT` | 编排者 → 任一角色 | 完整名册、角色路由、协议路径 |
| `TEAM_UPDATE` | 总控 → 任一角色 | 完整名册、角色变更、协议路径 |
| `TEAM_READY` | 任一新增角色 → 总控或管理 | 自身角色、可访问项目、无越权写入声明 |
| `TEAM_CHANGED` | 总控 → 管理和用户侧编排者 | 变更后的名册、握手证据、剩余风险 |
| `WORKFLOW_START` | 用户侧编排者 → 管理 | 用户原话、约束、已授权范围 |
| `RESEARCH_REQUEST` | 管理或总控 → 调研 | 问题、范围、时间边界、决策用途 |
| `RESEARCH_RESULT` | 调研 → 请求方 | 结论、来源、反例、置信度、未知项 |
| `IMPLEMENT_REQUEST` | 管理 → 开发 | scope、non_goals、acceptance_criteria |
| `IMPLEMENT_DONE` | 开发 → 管理 | changes、测试 evidence、剩余风险 |
| `VERIFY_REQUEST` | 开发 → 验收 | acceptance_criteria、changes、开发证据 |
| `VERIFY_RESULT` | 验收 → 管理和开发 | `PASS` 或 `FAIL`、逐条证据、复现信息 |
| `FIX_REQUEST` | 管理或验收 → 开发 | 失败标准、期望、实际、复现步骤 |
| `FIX_DONE` | 开发 → 管理和验收 | 针对失败项的改动和新证据 |
| `VERSION_DONE` | 管理 → 用户侧编排者 | PASS 证据、范围核对、剩余风险 |
| `BLOCKED` | 任一角色 → 管理 | 阻塞事实、已尝试动作、需要的用户决策 |

`VERIFY_RESULT` 的 summary 以 `PASS:` 或 `FAIL:` 开头，不使用模糊状态。

## 状态机

```text
APPROVED -> IMPLEMENTING -> VERIFYING -> VERIFIED -> DONE
                         \-> CHANGES_REQUESTED -> IMPLEMENTING
                         \-> BLOCKED -> USER_DECISION
```

- 管理创建并维护 work_item，其他角色不得另起 ID 规避失败历史。
- 每次返修递增 iteration；同一标准连续失败三轮后停止并升级给用户。
- PASS 必须逐条覆盖验收标准；缺少验证能力时只能 BLOCKED 或 FAIL。
- 管理只能在 PASS 后发送 VERSION_DONE。

## 本机注册表

```json
{
  "schema_version": 1,
  "project": "<project-name>",
  "project_id": "<project-id>",
  "workspace": "<absolute-path>",
  "updated_at": "<ISO-8601 UTC>",
  "agents": {
    "controller": {"title": "<project> · 总控 Agent", "thread_id": "<id>", "host_id": "<id>"},
    "manager": {"title": "<project> · 管理 Agent", "thread_id": "<id>", "host_id": "<id>"},
    "researcher": {"title": "<project> · 调研 Agent", "thread_id": "<id>", "host_id": "<id>"},
    "developer": {"title": "<project> · 开发 Agent", "thread_id": "<id>", "host_id": "<id>"},
    "verifier": {"title": "<project> · 验收 Agent", "thread_id": "<id>", "host_id": "<id>"}
  }
}
```

若注册表与任务列表冲突，以实际任务 ID 和项目路径为准；获得写入授权后再修复注册表，不按相似标题猜测。

## 升级条件

遇到以下任一情况，停止自动流转并向用户给出事实和所需决策：验收标准矛盾、连续三轮失败、多个写入者、未授权文档写入、外部不可逆操作、测试环境无法建立且无等价验证路径。
