# Claude Plugins

## [10 Best Claude Code Plugins in 2026](https://www.ayautomate.com/blog/best-claude-code-plugins)

Claude Code changed the way teams ship software in 2025. By 2026, the question is no longer whether to use it. It is which plugins to bolt on so your agent stops guessing and starts shipping. The hard part is separating the plugins that meaningfully change the loop from the ones that just add commands to your terminal. Most plugins do not survive a week of real use. A few become non-negotiable because they reduce hallucinations, anchor Claude to live data, or replace whole categories of manual review. This is the difference between a curiosity install and a plugin that earns a permanent slot in your team's ~/.claude config.

### Context7: Best for up-to-date library documentation injected into prompts.

Context7 is the plugin most experienced Claude Code users install first. It is an MCP-backed plugin that pulls version-specific documentation straight from source repositories and injects it into the model's context window. Instead of Claude guessing the current React 19 or Next.js 16 API based on training data, it reads the actual docs at the moment you ask. As of June 2026, Anthropic's public directory reports roughly 348,000 installs.

For teams shipping against fast-moving libraries (Next.js, Tailwind, LangChain, the Vercel AI SDK, Supabase), Context7 cuts an entire class of hallucinations. The tradeoff is latency: **every doc lookup adds tokens and a network round-trip**. Eliminates the most common category of Claude hallucination.

- install: claude mcp add context7 -- npx -y @upstash/context7-mcp

### Frontend Design: Best for shipping UI that does not look like a 2023 Bootstrap template.

Frontend Design is Anthropic's own plugin and the most-installed plugin in the official directory at roughly 277,000 installs by mid-2026. It exists because raw Claude Code produces functional but generic UI. Frontend Design wires the agent into design tokens, screenshots, layout reasoning, and a curated set of UI patterns so the components it ships actually look intentional.

For agencies and product teams that care about visual polish, this plugin is the difference between Claude generating a wireframe and Claude generating something a designer would not immediately rewrite. It pairs naturally with Chrome DevTools MCP for verifying the rendered output.

### Superpowers: Best for structured workflows: TDD, brainstorming, sub-agent driven dev.

Superpowers reframes Claude Code from a single agent to a small dev team. It ships a curated set of workflows (brainstorming, sub-agent driven development, systematic debugging, red/green TDD, code review) plus tooling to author and test your own skills. With 752,000+ installs, it is one of the most popular community plugins in the marketplace.

The value of Superpowers is structural. It nudges the agent into patterns that produce better code: write the test first, run the test, fix the failure, review the diff. If your team has tried Claude Code and felt like the agent rushes to a solution, Superpowers is the corrective. Battle-tested by a large community. Forces good habits: test first, review before merge.

### Chrome DevTools MCP: Best for live frontend debugging through the real browser.

Chrome DevTools MCP gives Claude direct access to a running browser via the Chrome DevTools Protocol. The agent can read network requests, inspect console errors, dump the DOM, run scripts in the page context, and screenshot what the user actually sees. For frontend bugs that only reproduce in the browser, this plugin is the difference between Claude guessing and Claude debugging.

It pairs with **Frontend Design** to close the loop: Frontend Design helps ship UI, Chrome DevTools verifies it works. This is the recommended stack for any team shipping web frontends with Claude Code.

### Anthropic Language Servers (LSP pack): Best for accurate code navigation and diagnostics across 12+ languages.

The official LSP pack bundles 12 language servers into Claude Code: TypeScript, Python, Go, Rust, C/C++, Java, C#, Kotlin, PHP, Lua, and Swift. With LSPs active, Claude gets the same code intelligence your IDE has: real types, real symbol resolution, real diagnostics. This is the foundation plugin: **install it before anything else if you work in a typed language**. Maintained by Anthropic, not a community fork.

The Composio team and most of the early adopters in the Anthropic dev community recommend starting any Claude Code setup with the LSP plugins for your stack. The improvement in agent accuracy on typed codebases is immediate and obvious.

### GitHub Plugin: Best for PR review, issue triage, and repo context inside Claude.

The GitHub plugin connects Claude Code to your repositories, pull requests, issues, and Actions. The agent can read PR diffs, leave reviews, triage issues, search across repos, and run workflows. For any team using GitHub as the source of truth, which is most teams, this plugin removes the need to copy-paste between terminal and browser. It is the **most common second-install** after the LSP pack, and Anthropic actively maintains it as a partner plugin. Maintained by GitHub as an Anthropic partner.

- install: claude mcp add --transport http github https://api.githubcopilot.com/mcp

Authenticate with OAuth on first use, or pass a fine-grained personal access token as a header with -H "Authorization: Bearer ghp\_...". Generate a fine-grained personal access token with repo, read:org, and workflow scopes for most workflows.

Scope the token to the repos and permissions Claude Code actually needs, and for team projects use a service account so the agent’s actions are auditable separately from your own. The server supports read-only mode and toolset selection, which is the easiest way to keep its large tool list from crowding the agent.

The older @modelcontextprotocol/server-github npm package is deprecated in favor of this official server.

### Playwright Plugin: Best for end-to-end test authoring and execution by the agent.

The Playwright plugin lets Claude Code author, run, and debug end-to-end tests against your app. Combined with **Chrome DevTools MCP** and **Frontend Design**, it closes the loop on UI changes: Claude builds, screenshots, verifies, then writes a regression test before the diff is committed. Generates Playwright tests from natural language specs. Playwright is also one of the few plugins where the ROI is easy to measure: test coverage written by the agent that would have been deferred or skipped manually.

Microsoft maintains the official Playwright MCP server. ExecuteAutomation ships a popular community alternative, @executeautomation/playwright-mcp-server, if you prefer screenshot-based flows.

- install: claude mcp add playwright -- npx @playwright/mcp@latest

## [Best MCP Servers for Claude Code in 2026 (Ranked and Tested)](https://nimbalyst.com/blog/best-claude-code-mcp-servers/)

The best MCP servers for Claude Code in 2026, ranked and tested: GitHub, Context7, Playwright, Postgres, Exa, and the essential picks, with install commands and the context-cost tradeoffs of running many at once. A practical rule: three to six servers for most developers. Add one per project when a real need shows up, and remove any server the agent never calls. Start with GitHub plus one or two project-specific servers, then add Context7 if you frequently work across unfamiliar stacks.

Further details from this article were added to the above list, please see the respective plugin. A day-one setup to install and tune later:

- claude mcp add --transport http github https://api.githubcopilot.com/mcp
- claude mcp add context7 -- npx -y @upstash/context7-mcp
- claude mcp add --transport sse linear https://mcp.linear.app/sse

**A short tool list matters more than people expect.** The model has to consider every tool on every turn. A bloated tool list slows the agent down and increases the chance it picks the wrong tool. Add Slack if your team lives there. Add Postgres, Sentry, Playwright, or a search server when the project demands them. **Resist installing servers you do not have a clear use for.** Each one expands the agent’s tool list, and a **bloated tool list hurts the agent’s decision quality**.

### Linear MCP server

For teams that live in Linear, this turns Claude Code into a participant in the planning system. It reads tickets, updates status, leaves comments, and creates new issues. Linear ships an official hosted MCP server, so you authenticate in the browser on first connect.

- install: claude mcp add --transport sse linear https://mcp.linear.app/sse

## [Linear – The system for product development](https://linear.app/)

A new species of product tool. Purpose-built for modern teams with AI workflows at its core, Linear sets a new standard for planning and building products.

- Plan and navigate from idea to launch. Align your team with product initiatives, strategic roadmaps, and clear, up-to-date PRDs.
- Build and deploy AI agents that work alongside your team. Work on complex tasks together or delegate entire issues end-to-end.
- Understand code changes at a glance with structural diffs for human and agent output. Review, discuss, and merge — all within Linear.
- Take the guesswork out of product development with project updates, analytics, and dashboards that surface what needs your attention.

## [Claude Code MCP Setup: A Practical 2026 Guide](https://nimbalyst.com/blog/claude-code-mcp-setup/)

How to configure MCP servers for Claude Code in 2026. Add GitHub, Slack, Linear, Playwright, and database servers, debug auth, and avoid common pitfalls. Claude Code MCP is a standard for letting Claude Code call external tools. Each MCP server exposes one or more tools. Claude Code discovers them at startup and includes them in the tool list it can use during a session.

### Where do I configure MCP servers?

In ~/.claude/settings.json (user level) or .claude/settings.json in a project (project level). Project settings override user settings.

### What MCP servers should I install first?

GitHub for issues and PRs, then the systems your project already depends on: Linear or Jira for ticketing, Slack for team comms, Postgres or Sentry for backend work, Playwright for UI verification. Claude Code already has built-in file tools, so a separate filesystem server is usually optional.

### How do I debug MCP issues?

Run claude mcp list to see registered servers, claude mcp test <name> to verify a single server, and tail the Claude Code logs for stderr output from the server process.

### Configuration file layout

Claude Code reads MCP configuration from two places:

- User scope: ~/.claude/settings.json. Servers configured here are available to every Claude Code session you run.

- Project scope: .claude/settings.json in the project root. Servers configured here are available only when you run Claude Code inside that project. Project scope overrides user scope, which is useful when one repo needs a different set of tools.

For most servers, user level is the right scope. GitHub, Slack, Linear, and your filesystem are stable across projects.

For database servers, monitoring servers, and project-specific APIs, project level is cleaner. Each repo gets only the tools it actually needs, and Claude Code’s tool list stays short.

### Are MCP servers safe?

MCP servers run as subprocesses on your machine with the credentials you give them. Treat them like any other CLI tool. Only install servers from trusted sources. Use scoped tokens with the minimum permissions the server needs. For database servers, prefer read-only roles unless you explicitly want write access.

### Why is my MCP server not showing up in Claude Code?

Three usual causes. First, the JSON in settings.json has a syntax error. Run it through jq. Second, the command does not resolve. Use absolute paths for binaries. Third, the server itself is failing on startup. Run it manually in a terminal to see stderr.

## [Claude Code Skills: A Practical 2026 Guide ](https://nimbalyst.com/blog/claude-code-skills-guide/)

Claude Code skills explained: what they are, how to write one, the best built-in skills, and how skills differ from MCP servers and subagents.

- Skills are instructions, MCP servers are tools. A skill tells the agent what to do. An MCP server gives it new things it can do.
- Skills live in ~/.claude/skills/<name>/ for user scope or .claude/skills/<name>/ inside a project for project scope.

## [The Unofficial and Awesome Home Assistant MCP Server](https://github.com/homeassistant-ai/ha-mcp)

A comprehensive Model Context Protocol (MCP) server that enables AI assistants to interact with Home Assistant. Using natural language, control smart home devices, query states, execute services and manage your automations.

## [Connect Home Assistant to AI – Set Up an MCP Server for Claude, ChatGPT & Gemini](https://raspberry.tips/en/smart-home/home-assistant-mcp-server-ai-setup)

The MCP server (Model Context Protocol) is an interface that lets AIs like Claude, ChatGPT, or Gemini talk directly to your Home Assistant. Instead of writing YAML yourself, you give the AI access to entities, automations, and dashboards – it handles the code. Runs as a free app/add-on on Home Assistant OS, community project (homeassistant-ai/ha-mcp).

An MCP server changes that fundamentally. You connect Home Assistant directly to an AI of your choice – Claude, ChatGPT, or Gemini – and simply describe in plain language what you need: “Build me a sensor that shows today’s rainfall” or “Fix the automation in the kids’ room, the lights aren’t dimming correctly anymore.” The AI finds the right entities itself, writes the code, and sets it up in Home Assistant.

## [Model Context Protocol servers](https://github.com/modelcontextprotocol/servers)

This repository is a collection of reference implementations for the Model Context Protocol (MCP), as well as references to community-built servers and additional resources. The servers in this repository showcase the versatility and extensibility of MCP, demonstrating how it can be used to give Large Language Models (LLMs) secure, controlled access to tools and data sources. Typically, each MCP server is implemented with an MCP SDK:

- C# MCP SDK
- Go MCP SDK
- Java MCP SDK
- Kotlin MCP SDK
- PHP MCP SDK
- Python MCP SDK
- Ruby MCP SDK
- Rust MCP SDK
- Swift MCP SDK
- TypeScript MCP SDK

The servers in this repository are intended as reference implementations to demonstrate MCP features and SDK usage. They are meant to serve as educational examples for developers building their own MCP servers, not as production-ready solutions. Developers should evaluate their own security requirements and implement appropriate safeguards based on their specific threat model and use case.

## [UV - A Faster, All-in-One Package Manager to Replace Pip and Venv ](https://www.youtube.com/watch?v=AMdG7IjgSPM)

UV is a new and fast Python package manager from Astral, the makers of Ruff. UV aims to simplify your Python workflow by acting as an extremely fast, all-in-one replacement for tools like pip, venv, virtualenv, pip-tools, and pipx. The video covers how to install UV, initialize projects, add and manage dependencies using pyproject.toml and lock files, automatically handle virtual environments, run scripts, and even install and manage global Python tools.

## Why Claude Hallucinates

A hallucination in Claude occurs when the AI generates false, fabricated, or misleading information and presents it with total confidence. This happens because the model predicts statistical text patterns rather than pulling from a verified database, often misfiring when it recognizes a name or topic but lacks actual facts. Research by Anthropic shows that hallucinations happen when Claude recognizes a name or entity, which incorrectly suppresses its default "I don't know" mechanism. Common Signs of Hallucinations are invented academic citations, fake URLs, or non-existent research papers.

To Prevent and Reduce Hallucinations, give explicit permission in your prompt or system instructions: "You are allowed to say 'I don’t know' if you are unsure". Ask for chain-of-thought logic before it provides a final conclusion.

## Database choices

For a Raspberry Pi (RPI) Linux environment, SQLite is best for low-power, single-user, or read-heavy local apps because it needs no server. PostgreSQL or MySQL/MariaDB are better if you need multi-user web apps. MongoDB is heavy and generally a poor fit for low-memory Pi boards.

Be careful with permissions. Give Claude Code a read-only database role unless you explicitly want it to mutate.

### Quick Comparison

- SQLite: Best for tiny resource footprints, local scripts, logging, and single-user software.
- MySQL / MariaDB: Best if you run a standard web stack (like WordPress) and need moderate multi-user support.
- PostgreSQL: Best for advanced data types, complex queries, or robust relational needs, provided your Pi has enough RAM (like a Pi 4 or 5).
- MongoDB: Worst choice due to high RAM usage and heavy disk I/O, unless you use a lightweight file-based mock.

### Key Factors on Raspberry Pi

- Memory (RAM) Limits: SQLite runs inside your app process with almost zero idle overhead. Postgres and MySQL run background daemon processes that consume tens or hundreds of megabytes of RAM constantly. MongoDB demands even more memory to run efficiently.
- Concurrency: SQLite handles many simultaneous readers fine, but locks the whole file during writes. If you have heavy concurrent writing from multiple services, MariaDB or PostgreSQL handle row-level locking much better.
