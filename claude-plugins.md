# Claude Plugins

## [The Unofficial and Awesome Home Assistant MCP Server](https://github.com/homeassistant-ai/ha-mcp)

A comprehensive Model Context Protocol (MCP) server that enables AI assistants to interact with Home Assistant. Using natural language, control smart home devices, query states, execute services and manage your automations.

## [Connect Home Assistant to AI – Set Up an MCP Server for Claude, ChatGPT & Gemini](https://raspberry.tips/en/smart-home/home-assistant-mcp-server-ai-setup)

The MCP server (Model Context Protocol) is an interface that lets AIs like Claude, ChatGPT, or Gemini talk directly to your Home Assistant. Instead of writing YAML yourself, you give the AI access to entities, automations, and dashboards – it handles the code. Runs as a free app/add-on on Home Assistant OS, community project (homeassistant-ai/ha-mcp).

An MCP server changes that fundamentally. You connect Home Assistant directly to an AI of your choice – Claude, ChatGPT, or Gemini – and simply describe in plain language what you need: “Build me a sensor that shows today’s rainfall” or “Fix the automation in the kids’ room, the lights aren’t dimming correctly anymore.” The AI finds the right entities itself, writes the code, and sets it up in Home Assistant.

## [UV - A Faster, All-in-One Package Manager to Replace Pip and Venv ](https://www.youtube.com/watch?v=AMdG7IjgSPM)

In this video, we'll be learning about UV, a new and fast Python package manager from Astral, the makers of Ruff. We'll see how UV aims to simplify your Python workflow by acting as an extremely fast, all-in-one replacement for tools like pip, venv, virtualenv, pip-tools, and pipx. We will cover how to install UV, initialize projects, add and manage dependencies using pyproject.toml and lock files, automatically handle virtual environments, run scripts, and even install and manage global Python tools.

## [Model Context Protocol servers](https://github.com/modelcontextprotocol/servers)

This repository is a collection of reference implementations for the Model Context Protocol (MCP), as well as references to community-built servers and additional resources.

The servers in this repository showcase the versatility and extensibility of MCP, demonstrating how it can be used to give Large Language Models (LLMs) secure, controlled access to tools and data sources. Typically, each MCP server is implemented with an MCP SDK:

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

## [10 Best Claude Code Plugins in 2026](https://www.ayautomate.com/blog/best-claude-code-plugins)

The best Claude Code plugins in 2026 are Context7 for live version-specific docs, Frontend Design for UI that looks shipped, Superpowers for structured TDD and sub-agent workflows, Chrome DevTools MCP for real-browser debugging, and Anthropic's LSP pack for accurate code intelligence. Round out the stack with the GitHub, Playwright, Semgrep, Linear, and Vercel plugins and you cover repo workflows, E2E tests, security scanning, backlog sync, and deploys.

Claude Code changed the way teams ship software in 2025. By 2026, the question is no longer whether to use it. It is which plugins to bolt on so your agent stops guessing and starts shipping.

The hard part is separating the plugins that meaningfully change the loop from the ones that just add commands to your terminal. Most plugins do not survive a week of real use. A few become non-negotiable because they reduce hallucinations, anchor Claude to live data, or replace whole categories of manual review. This is the difference between a curiosity install and a plugin that earns a permanent slot in your team's ~/.claude config.

This guide compares the 10 best Claude Code plugins in 2026. Real features, honest pricing where it is publicly known, pros and cons, and a framework to pick the right stack for your codebase.

### Free Plugins Overview

#### Context7: Best for up-to-date library documentation injected into prompts.

Context7 is the plugin most experienced Claude Code users install first. It is an MCP-backed plugin that pulls version-specific documentation straight from source repositories and injects it into the model's context window. Instead of Claude guessing the current React 19 or Next.js 16 API based on training data, it reads the actual docs at the moment you ask. As of June 2026, Anthropic's public directory reports roughly 348,000 installs.

For teams shipping against fast-moving libraries (Next.js, Tailwind, LangChain, the Vercel AI SDK, Supabase), Context7 cuts an entire class of hallucinations. The tradeoff is latency: **every doc lookup adds tokens and a network round-trip**. Eliminates the most common category of Claude hallucination.

#### Frontend Design: Best for shipping UI that does not look like a 2023 Bootstrap template.

Frontend Design is Anthropic's own plugin and the most-installed plugin in the official directory at roughly 277,000 installs by mid-2026. It exists because raw Claude Code produces functional but generic UI. Frontend Design wires the agent into design tokens, screenshots, layout reasoning, and a curated set of UI patterns so the components it ships actually look intentional.

For agencies and product teams that care about visual polish, this plugin is the difference between Claude generating a wireframe and Claude generating something a designer would not immediately rewrite. It pairs naturally with Chrome DevTools MCP for verifying the rendered output.

#### Superpowers: Best for structured workflows: TDD, brainstorming, sub-agent driven dev.

Superpowers reframes Claude Code from a single agent to a small dev team. It ships a curated set of workflows (brainstorming, sub-agent driven development, systematic debugging, red/green TDD, code review) plus tooling to author and test your own skills. With 752,000+ installs, it is one of the most popular community plugins in the marketplace.

The value of Superpowers is structural. It nudges the agent into patterns that produce better code: write the test first, run the test, fix the failure, review the diff. If your team has tried Claude Code and felt like the agent rushes to a solution, Superpowers is the corrective. Battle-tested by a large community. Forces good habits: test first, review before merge.

#### Chrome DevTools MCP: Best for live frontend debugging through the real browser.

Chrome DevTools MCP gives Claude direct access to a running browser via the Chrome DevTools Protocol. The agent can read network requests, inspect console errors, dump the DOM, run scripts in the page context, and screenshot what the user actually sees. For frontend bugs that only reproduce in the browser, this plugin is the difference between Claude guessing and Claude debugging.

It pairs with Frontend Design to close the loop: Frontend Design helps ship UI, Chrome DevTools verifies it works. This is the recommended stack for any team shipping web frontends with Claude Code.

#### Anthropic Language Servers (LSP pack): Best for accurate code navigation and diagnostics across 12+ languages.

The official LSP pack bundles 12 language servers into Claude Code: TypeScript, Python, Go, Rust, C/C++, Java, C#, Kotlin, PHP, Lua, and Swift. With LSPs active, Claude gets the same code intelligence your IDE has: real types, real symbol resolution, real diagnostics. This is the foundation plugin: install it before anything else if you work in a typed language. Maintained by Anthropic, not a community fork.

The Composio team and most of the early adopters in the Anthropic dev community recommend starting any Claude Code setup with the LSP plugins for your stack. The improvement in agent accuracy on typed codebases is immediate and obvious.

#### GitHub Plugin: Best for PR review, issue triage, and repo context inside Claude.

The GitHub plugin connects Claude Code to your repositories, pull requests, issues, and Actions. The agent can read PR diffs, leave reviews, triage issues, search across repos, and run workflows. For any team using GitHub as the source of truth, which is most teams, this plugin removes the need to copy-paste between terminal and browser.

It is the most common second-install after the LSP pack, and Anthropic actively maintains it as a partner plugin. Maintained by GitHub as an Anthropic partner.

#### Playwright Plugin: Best for end-to-end test authoring and execution by the agent.

The Playwright plugin lets Claude Code author, run, and debug end-to-end tests against your app. Combined with **Chrome DevTools MCP** and **Frontend Design**, it closes the loop on UI changes: Claude builds, screenshots, verifies, then writes a regression test before the diff is committed.

Generates Playwright tests from natural language specs. Playwright is also one of the few plugins where the ROI is easy to measure: test coverage written by the agent that would have been deferred or skipped manually.

## Why Claude Hallucinates

A hallucination in Claude occurs when the AI generates false, fabricated, or misleading information and presents it with total confidence. This happens because the model predicts statistical text patterns rather than pulling from a verified database, often misfiring when it recognizes a name or topic but lacks actual facts.

Research by Anthropic shows that hallucinations happen when Claude recognizes a name or entity, which incorrectly suppresses its default "I don't know" mechanism.

Common Signs of Hallucinations are invented academic citations, fake URLs, or non-existent research papers.

To Prevent and Reduce Hallucinations, give explicit permission in your prompt or system instructions: "You are allowed to say 'I don’t know' if you are unsure". Ask for chain-of-thought logic before it provides a final conclusion.
