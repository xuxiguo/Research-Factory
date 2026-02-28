# Research Paper Factory — Agent Workflow System

A multi-agent orchestration system for academic research, built as VS Code Copilot custom agents. The factory manages the full lifecycle from data extraction → analysis → paper writing → revision → presentation.

## Quick Start

```
@Workflow-Manager deploy        # Install agents from this repo → VS Code user-level
@Workflow-Manager status        # Check sync status between repo and VS Code
@Strategist                     # Start planning a new research project
```

## Architecture

### Department Map

```
                        ┌─────────────────┐
                        │   Strategist    │  ← Top-level research planner
                        │  (user-invokable)│
                        └────────┬────────┘
                                 │
            ┌────────────┬───────┴───────┬─────────────┐
            ▼            ▼               ▼             ▼
   ┌─────────────┐ ┌──────────┐  ┌──────────┐  ┌────────────┐
   │DE-Conductor │ │DA-Conduct│  │PW-Editor │  │Rev-Strat.  │
   │  (Extract)  │ │ (Analyze)│  │ (Write)  │  │ (Revise)   │
   └──────┬──────┘ └────┬─────┘  └────┬─────┘  └─────┬──────┘
          │              │             │              │
    ┌─────┴─────┐  ┌─────┴────┐  ┌────┴──────┐  ┌────┴──────┐
    │DE-Miner   │  │DA-Builder│  │PW-Drafter │  │Rev-Respond│
    │DE-Refiner │  │DA-Executor│ │PW-Biblio  │  │Rev-Auditor│
    └───────────┘  └──────────┘  │PW-Compiler│  │Rev-Liaison│
                                 │PW-Typeset │  └───────────┘
                                 │PW-Submit  │
                                 └───────────┘

        ┌──────────────────────────────────────┐
        │  Shared Services (SS-*) — all depts  │
        │  Scout · Analyst · Debugger · Imager │
        │  Janitor · Reviewer · Scribe         │
        │  Sentinel · Vizmaker                 │
        └──────────────────────────────────────┘

        ┌──────────────────────────────────────┐
        │         Presenter                    │
        │  Marp slide deck generator           │
        └──────────────────────────────────────┘

        ┌──────────────────────────────────────┐
        │      Workflow-Manager                │
        │  Meta-agent: updates agent configs   │
        └──────────────────────────────────────┘
```

### Agent Inventory (28 + 1 meta-agent)

| Agent | Type | Model | Dept | Role |
|-------|------|-------|------|------|
| **Strategist** | Conductor | Opus 4.6 | Strategy | Research design & cross-dept planning |
| **DE-Conductor** | Conductor | Opus 4.6 | Data Extraction | Extraction lifecycle orchestration |
| **DE-Miner** | Subagent | Codex 5.3 | Data Extraction | API/database/web data pulling |
| **DE-Refiner** | Subagent | Sonnet 4.6 | Data Extraction | Data cleaning & transformation |
| **DA-Conductor** | Conductor | Opus 4.6 | Data Analysis | Analysis lifecycle orchestration |
| **DA-Builder** | Subagent | Codex 5.3 | Data Analysis | Sample construction (DuckDB/pandas) |
| **DA-Executor** | Subagent | Sonnet 4.6 | Data Analysis | Regressions & publication tables |
| **PW-Editor** | Conductor | Opus 4.6 | Paper Writing | Writing lifecycle orchestration |
| **PW-Drafter** | Subagent | Opus 4.5 | Paper Writing | Academic prose drafting |
| **PW-Bibliographer** | Subagent | Gemini 2.5 Pro | Paper Writing | Citation & bibliography management |
| **PW-Compiler** | Subagent | Codex-Mini 5.1 | Paper Writing | LaTeX compilation & error diagnosis |
| **PW-Typesetter** | Subagent | Sonnet 4.6 | Paper Writing | LaTeX formatting & cross-references |
| **PW-Submission** | Subagent | Gemini 3 Flash | Paper Writing | Journal submission prep |
| **Rev-Strategist** | Conductor | Opus 4.6 | Revision | Revision strategy & consistency |
| **Rev-Respondent** | Subagent | Opus 4.5 | Revision | Point-by-point referee responses |
| **Rev-Auditor** | Subagent | Sonnet 4.6 | Revision | Revision consistency verification |
| **Rev-Liaison** | Subagent | Haiku 4.5 | Revision | Cross-reference lookup |
| **Presenter** | Conductor | Sonnet 4.6 | Presentation | Marp slide deck generation |
| **SS-Scout** | Shared | Haiku 4.5 | Shared Services | Rapid file/data reconnaissance |
| **SS-Analyst** | Shared | Gemini 2.5 Pro | Shared Services | Deep research & feasibility |
| **SS-Debugger** | Shared | Codex 5.3 | Shared Services | Error diagnosis across environments |
| **SS-Imager** | Shared | Sonnet 4.6 | Shared Services | AI image generation (gpt-image-1) |
| **SS-Janitor** | Shared | Haiku 4.5 | Shared Services | Repository hygiene & cleanup |
| **SS-Reviewer** | Shared | Sonnet 4.6 | Shared Services | Code audit & quality review |
| **SS-Scribe** | Shared | Gemini 3 Flash | Shared Services | Documentation & data dictionaries |
| **SS-Scout** | Shared | Haiku 4.5 | Shared Services | Fast read-only data exploration |
| **SS-Sentinel** | Shared | Sonnet 4.6 | Shared Services | Data validation & quality checks |
| **SS-Vizmaker** | Shared | Sonnet 4.6 | Shared Services | Publication-quality figures |
| **Workflow-Manager** | Meta | Opus 4.6 | Meta | Agent config management & sync |

### User-Invokable Agents (7)

These agents can be called directly by typing `@AgentName` in VS Code Copilot chat:

1. **@Strategist** — Start here for new projects. Plans hypotheses and coordinates departments.
2. **@DE-Conductor** — Orchestrates data extraction from APIs, databases, and files.
3. **@DA-Conductor** — Orchestrates data analysis: sample construction → regressions → tables.
4. **@PW-Editor** — Orchestrates paper writing from outline to submission-ready manuscript.
5. **@Rev-Strategist** — Manages referee responses and revision strategy.
6. **@Presenter** — Generates Marp-formatted presentation decks.
7. **@Workflow-Manager** — Meta-agent to update/sync agent configurations.

## Repository Structure

```
Research-Factory/
├── README.md                          # This file
├── agents/                            # All agent definitions (source of truth)
│   ├── Strategist.agent.md
│   ├── DA-Conductor.agent.md
│   ├── DA-Builder-subagent.agent.md
│   ├── DA-Executor-subagent.agent.md
│   ├── DE-Conductor.agent.md
│   ├── DE-Miner-subagent.agent.md
│   ├── DE-Refiner-subagent.agent.md
│   ├── PW-Editor.agent.md
│   ├── PW-Drafter-subagent.agent.md
│   ├── PW-Bibliographer-subagent.agent.md
│   ├── PW-Compiler-subagent.agent.md
│   ├── PW-Typesetter-subagent.agent.md
│   ├── PW-Submission-subagent.agent.md
│   ├── Rev-Strategist.agent.md
│   ├── Rev-Respondent-subagent.agent.md
│   ├── Rev-Auditor-subagent.agent.md
│   ├── Rev-Liaison-subagent.agent.md
│   ├── Presenter.agent.md
│   ├── SS-Scout-subagent.agent.md
│   ├── SS-Analyst-subagent.agent.md
│   ├── SS-Debugger-subagent.agent.md
│   ├── SS-Imager-subagent.agent.md
│   ├── SS-Janitor-subagent.agent.md
│   ├── SS-Reviewer-subagent.agent.md
│   ├── SS-Scribe-subagent.agent.md
│   ├── SS-Sentinel-subagent.agent.md
│   ├── SS-Vizmaker-subagent.agent.md
│   ├── Workflow-Manager.agent.md      # Meta-agent for self-management
│   └── ss_imager.py                   # Image generation helper script
├── config/
│   └── mcp.json.reference             # MCP server configuration reference
├── scripts/
│   ├── deploy.ps1                     # Deploy agents from repo → VS Code
│   ├── pull.ps1                       # Pull agents from VS Code → repo
│   └── sync-status.ps1               # Check sync status
├── CHANGELOG.md                       # Version history of agent changes
└── .github/
    └── workflows/
        └── track-changes.yml          # GitHub Actions for change tracking
```

## Workflow Manager Usage

The `@Workflow-Manager` agent is the meta-agent that manages this system. You can invoke it from **any** VS Code project.

### Commands

| Command | What it does |
|---------|-------------|
| `@Workflow-Manager deploy` | Copy agents from this repo → VS Code user-level prompts |
| `@Workflow-Manager pull` | Copy agents from VS Code → this repo (after manual edits) |
| `@Workflow-Manager status` | Show which agents differ between repo and VS Code |
| `@Workflow-Manager update <agent> <changes>` | Edit an agent, sync to VS Code, commit & push |
| `@Workflow-Manager add <name> <spec>` | Create a new agent, deploy, commit & push |
| `@Workflow-Manager remove <name>` | Remove an agent from both locations |
| `@Workflow-Manager changelog` | Show recent changes |

### Example: Update an Agent

```
@Workflow-Manager update SS-Scout Add support for .arrow and .feather file discovery
```

This will:
1. Edit `agents/SS-Scout-subagent.agent.md` in the repo
2. Copy the updated file to `%APPDATA%\Code\User\prompts\`
3. Git commit with descriptive message
4. Git push to remote

## Manual Scripts

If you prefer running scripts directly:

```powershell
# Deploy all agents from repo to VS Code
.\scripts\deploy.ps1

# Pull current VS Code agents back to repo
.\scripts\pull.ps1

# Check what's different
.\scripts\sync-status.ps1
```

## MCP Servers

The factory uses these MCP servers (configured at user level in `mcp.json`):

| Server | Purpose |
|--------|---------|
| `context7` | Up-to-date library documentation |
| `chrome-devtools-mcp` | Browser automation & screenshots |
| `microsoft/markitdown` | Document conversion to markdown |
| `stata-mcp` | Stata session management |
| `mcp-obsidian` | Obsidian vault access |

## Version History

See [CHANGELOG.md](CHANGELOG.md) for detailed change history.

## Forking & Experimentation

To try experimental agent changes without affecting the main workflow:

```bash
# Create a feature branch
git checkout -b experiment/new-agent-model

# Make changes to agents/
# Test with: .\scripts\deploy.ps1
# When happy: merge back to main
git checkout main
git merge experiment/new-agent-model
```

This gives you full version history and easy rollback.
