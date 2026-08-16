<!-- BEGIN codex-multi-agent-team -->
## 多 Agent 协作

- 使用项目 Skill `orchestrate-project-team` 编排长期团队。
- 总控 Agent 只负责团队拓扑、角色边界、任务注册与生命周期。
- 管理 Agent 只负责版本目标、范围、验收标准与最终收口。
- 调研 Agent 只负责一手资料检索、方案比较和可追溯证据。
- 开发 Agent 只根据已批准的契约实现和修复，不自我验收。
- 验收 Agent 独立检查实际结果，不修改业务实现。
- 同一时刻只允许一个 Agent 写业务文件；读操作和验证可以并行。
- 任务消息历史是审计日志；`.codex/team/registry.local.json` 只保存本机路由。
- 写入或修改文档、改变团队拓扑、部署、发布、删除或其他不可逆动作前，必须取得用户明确同意。

只有验收标准有证据、相关测试已运行、验收 Agent 给出 `PASS` 且管理 Agent 完成范围核对后，才能宣布版本完成。
<!-- END codex-multi-agent-team -->
