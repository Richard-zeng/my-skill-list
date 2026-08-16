---
name: github-project-brief
description: Research public GitHub repositories and produce structured Chinese "项目速读报告" for open-source project evaluation. Use when the user provides a GitHub repo URL or owner/repo name and asks to analyze, summarize, evaluate, compare, assess feasibility, inspect README/issues/releases/commits/license/code structure, or decide whether a project is worth studying, forking, turning into an AI skill/agent, or integrating into a workflow.
---

# GitHub Project Brief

## Goal

Generate a concise but evidence-grounded Chinese report that helps the user decide in 5-10 minutes whether a GitHub project is worth further study, fork, integration, or conversion into an AI skill/agent tool.

## Research Workflow

1. Normalize the repository identifier.
   - Accept full GitHub URLs, `owner/repo`, or pasted repository names.
   - If the repo is ambiguous or inaccessible, ask for the exact URL or request README, directory tree, package/build files, main source files, issues/releases snippets, and license.

2. Gather current public evidence.
   - Because GitHub metadata changes often, browse or call GitHub APIs for current repo metadata, stars/forks, license, latest push/update, releases, issues, pull requests, and recent commits.
   - Inspect README and docs.
   - Inspect code structure via repository tree or shallow clone when useful.
   - Prefer primary sources: GitHub repo pages, raw files, GitHub API, official docs linked from the repo.
   - Include source links in the final answer when web access was used.

3. Look beyond README claims.
   - Verify whether install/build files exist.
   - Check whether examples, tests, CI, releases, docs, and license are present.
   - Compare README promises against code structure and release history.
   - Mark unsupported conclusions as `推断`.

4. Analyze as an AI product researcher and architecture advisor.
   - Explain the user problem, replacement/enhancement of existing workflows, likely user personas, and adoption friction.
   - Identify core abstractions, data flow, external dependencies, privacy/security/cost risks, and maintenance signals.
   - Explicitly assess value for AI skills, agents, MCP tools, plugins, RAG, prompt engineering, and workflow automation.

## Evidence Checklist

Try to verify:

- Repository name, URL, owner/organization.
- Primary language and notable frameworks.
- License.
- Stars, forks, open issues, PRs, releases, latest commit/push/update date.
- README positioning, install path, examples, screenshots/demo assets.
- Directory structure, build/package files, tests, CI/config files.
- Main implementation modules and external services/API/model/database dependencies.
- Roadmap, issues, release notes, commit messages, and maintainer/community activity.

If a field cannot be confirmed, write `未找到`; do not invent.

## Output Structure

Use this exact top-level structure unless the user asks otherwise:

```markdown
# 项目速读报告

## 1. 一句话总结

## 2. 项目基本信息

## 3. 它解决了什么问题

## 4. 核心功能

## 5. 典型使用场景

## 6. 快速上手路径

## 7. 技术架构解读

## 8. 对 AI Skill / Agent 的价值

## 9. 优点

## 10. 局限和风险

## 11. 与类似项目的区别

## 12. 我是否值得继续研究

## 13. 延伸思考
```

## Section Guidance

Keep the report scannable and non-hype. Prefer concrete bullets over generic praise.

### 1. 一句话总结

State what the project is, what problem it solves, and who it is for in one sentence.

### 2. 项目基本信息

Include:

- 项目名称
- GitHub 地址
- 作者/组织
- 主要编程语言
- License
- Star / Fork 数量
- 最近更新时间
- 项目当前活跃度判断

Clarify when counts may differ due to cache/API timing.

### 3. 它解决了什么问题

Explain:

- Core pain point.
- What existing workflow it replaces or enhances.
- What users usually do without it.

### 4. 核心功能

Summarize capabilities in your own words. Do not merely translate the README.

### 5. 典型使用场景

List 3-6 realistic scenarios, such as:

- Individual developer/user.
- AI Agent or workflow automation.
- Team/company use.
- Secondary development/fork potential.

### 6. 快速上手路径

Give the shortest path:

1. Files/docs to read first.
2. Installation.
3. Minimal demo/run path.
4. First thing to try.

Call out likely installation/build friction.

### 7. 技术架构解读

Explain:

- Major modules.
- Approximate data flow/call chain.
- External APIs/models/databases/cloud services.
- Key abstractions.

Use non-specialist language where possible.

### 8. 对 AI Skill / Agent 的价值

Analyze:

- Whether it can become an AI skill, agent tool, MCP tool, plugin, or automation component.
- Which AI workflows it can join.
- Lessons for prompt engineering, RAG, agents, MCP, plugins, and automation.
- What an AI tool builder should learn from it.

### 9. 优点

List 3-7 specific strengths grounded in evidence.

### 10. 局限和风险

Be candid about:

- Maturity.
- Documentation completeness.
- Community activity.
- Maintenance risk.
- Security, privacy, cost, dependency risks.
- Whether it appears to be a demo rather than production-ready.

### 11. 与类似项目的区别

If clear competitors exist, compare briefly. If not, describe possible competitor categories instead of fabricating project names.

### 12. 我是否值得继续研究

Include:

- 推荐指数：1-5 分
- 适合人群
- 不适合人群
- Study time recommendation: 5 分钟 / 30 分钟 / 半天
- Most worthwhile deep-dive point

### 13. 延伸思考

Provide 5 probing questions to decide whether to learn, fork, adapt, turn into an AI skill, or integrate it.

## Quality Rules

- Do not write empty praise.
- Do not only restate the README.
- Mark uncertain analysis with `推断`.
- Use concrete dates for activity and release recency.
- When current data matters, browse or use GitHub APIs.
- Include key source links when webpages were accessed.
- Keep the final answer structured enough for a 5-10 minute decision.
