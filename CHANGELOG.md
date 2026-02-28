# Changelog

All notable changes to the Research Paper Factory agent system are tracked here.

## [1.0.0] — 2026-02-28

### Initial Release

**28 agents + 1 helper script** migrated from VS Code user-level configuration to version-controlled repository.

#### Conductors (User-Invokable)
- **Strategist** — Top-level research planner (Opus 4.6)
- **DE-Conductor** — Data extraction orchestrator (Opus 4.6)
- **DA-Conductor** — Data analysis orchestrator (Opus 4.6)
- **PW-Editor** — Paper writing orchestrator (Opus 4.6)
- **Rev-Strategist** — Revision orchestrator (Opus 4.6)
- **Presenter** — Marp slide deck generator (Sonnet 4.6)

#### Data Extraction Subagents
- **DE-Miner** — API/database/web data extraction (Codex 5.3)
- **DE-Refiner** — Data cleaning & transformation (Sonnet 4.6)

#### Data Analysis Subagents
- **DA-Builder** — Sample construction via DuckDB/pandas (Codex 5.3)
- **DA-Executor** — Regressions & publication tables (Sonnet 4.6)

#### Paper Writing Subagents
- **PW-Drafter** — Academic prose drafting (Opus 4.5)
- **PW-Bibliographer** — Citation & bibliography management (Gemini 2.5 Pro)
- **PW-Compiler** — LaTeX compilation & diagnostics (Codex-Mini 5.1)
- **PW-Typesetter** — LaTeX formatting & cross-references (Sonnet 4.6)
- **PW-Submission** — Journal submission preparation (Gemini 3 Flash)

#### Revision Subagents
- **Rev-Respondent** — Point-by-point referee responses (Opus 4.5)
- **Rev-Auditor** — Revision consistency verification (Sonnet 4.6)
- **Rev-Liaison** — Cross-reference lookup (Haiku 4.5)

#### Shared Services
- **SS-Scout** — Rapid data reconnaissance (Haiku 4.5)
- **SS-Analyst** — Deep research & feasibility (Gemini 2.5 Pro)
- **SS-Debugger** — Error diagnosis (Codex 5.3)
- **SS-Imager** — AI image generation (Sonnet 4.6 + gpt-image-1)
- **SS-Janitor** — Repository hygiene (Haiku 4.5)
- **SS-Reviewer** — Code audit & quality (Sonnet 4.6)
- **SS-Scribe** — Documentation maintenance (Gemini 3 Flash)
- **SS-Sentinel** — Data validation (Sonnet 4.6)
- **SS-Vizmaker** — Publication-quality figures (Sonnet 4.6)

#### Helper Scripts
- **ss_imager.py** — OpenAI gpt-image-1 integration script

### Infrastructure
- Added `Workflow-Manager` meta-agent for self-management
- Added `scripts/deploy.ps1`, `scripts/pull.ps1`, `scripts/sync-status.ps1`
- Added GitHub Actions workflow for change tracking and validation
- Added `config/mcp.json.reference` for MCP server documentation
