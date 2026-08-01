---
title: The $250,000 Vanity Metric
author: Roger Fleig
date: 2026-03-25
canonical: https://rogerfleig.substack.com/p/the-250000-vanity-metric
source: Substack
license: http://fleig.us/license/
---

*This is the second in a series on [The Narrow Pipe](https://fleig.us/writing/narrowpipe/), a position paper on the emerging infrastructure challenges of agent-scale software engineering.*

Last week at GTC 2026, Jensen Huang laid out his [vision for token budgets as engineer compensation](https://fortune.com/2026/03/17/jensen-huang-ai-infrastructure-buildout-1-trillion-dollars/) — half a base salary, on top of pay, so engineers can be "amplified 10x." Then on the All-In Podcast, he made it vivid: if a \$500,000 engineer only spent \$5,000 on AI tokens in a year, *"I will go ape."* His benchmark? At least \$250,000 in annual token consumption. When asked if Nvidia is spending \$2 billion a year on tokens for its engineering team, he answered: *"We're trying to."*

This landed the same week as a New York Times piece that introduced the term "tokenmaxxing" — a status competition among engineers to consume the most AI tokens. Internal leaderboards tracking token consumption. Managers factoring raw AI usage into performance reviews. Individual engineers burning billions of tokens per week running swarms of parallel agents around the clock.

Jensen is the CEO of the company that sells the compute. Of course he wants engineers burning through a quarter million dollars in tokens. But when that framing trickles down into how engineering organizations evaluate productivity, it becomes something more dangerous than a sales pitch. It becomes a measurement system. And it's measuring the wrong thing.

## The Activity Trap

The most important measurement anti-pattern in agentic development has a name: the Activity Trap. It means measuring activity instead of outcomes — counting what's easy to count rather than what actually matters. Jensen's \$250K benchmark is the Activity Trap in its purest and most expensive form: it measures *input* — resources burned — not *output*, and certainly not *outcomes*.

Agents make this trap catastrophically worse because they can generate enormous volumes of activity. An agent that opens twenty PRs in a day looks productive by activity metrics. If fifteen require multiple review rounds, three introduce regressions, and two get reverted — the net outcome may be negative. Activity metrics for agents aren't just uninformative. They are actively misleading, because they create incentives to optimize for volume over value.

Lines of code generated. PR counts. Token consumption. Prompt counts. These aren't productivity metrics. They're *input* metrics. They tell you nothing about whether the output is correct, maintainable, or even used.

## The 40-Point Perception Gap

Here's what makes this genuinely dangerous: developers can't tell either.

A 2025 randomized controlled trial by METR (Model Evaluation & Threat Research) produced the most rigorous empirical test of AI-assisted development productivity to date. Sixteen experienced open-source developers completed 246 real tasks on their own repositories — mature codebases averaging over a million lines that the developers had worked on for an average of five years. Tasks were randomly assigned to allow or disallow AI tools.

The result: developers using AI tools were **19% slower** at completing tasks. Not faster. Slower.

But here's the finding that should keep you up at night: before the study, developers predicted AI would make them 24% faster. *After* the study — after experiencing the actual slowdown — they still estimated they had been 20% faster. That's a 40+ percentage point gap between perceived and actual productivity.

They weren't just wrong about the magnitude. They were wrong about the *direction*.

## Why It Happened

METR's analysis identified causes that map directly to the infrastructure problems I describe in the full paper:

**Context familiarity penalty.** Developers who knew their codebases most deeply were slowed down *most*. The more an expert knows that the AI doesn't have access to, the more time they spend correcting confident mistakes. This is the institutional knowledge problem — the gap between what lives in a developer's head and what the agent can see.

**Quality standards as friction.** Code that is "functionally correct" but fails implicit quality standards requires substantial human cleanup. This is the rework problem.

**Attention fragmentation.** AI tools introduced micro-interruption patterns that disrupted flow state. The tool that was supposed to reduce cognitive load increased it.

## What to Measure Instead

The established measurement frameworks — DORA, SPACE, DevEx — provide the scaffolding, but each needs adaptation for agents. Here's the thinking tool I use:

> **Net agent value ≈ throughput gain − review burden − CI/compute cost − regression/rework cost − coordination overhead**

This isn't a formula to compute precisely. It's a frame that makes the cost structure visible and prevents the common mistake of measuring only the numerator while ignoring the denominator.

A few metrics that actually matter:

**Rework Rate** (DORA's fifth metric, benchmarked 2025) — the ratio of deployments that are unplanned responses to production incidents. Track it by source: agent vs. human, by agent type, by code area. If agent-generated code drives up rework rate, the speed gain is illusory.

**Autonomy Duration** — how far an agent progresses through meaningful work before requiring human intervention. The primary measure of macro-loop efficiency.

**Quality-adjusted throughput** — throughput weighted by change failure rate, rework rate, and code health. An agent that produces five low-quality PRs requiring multiple review rounds is less valuable than one that produces two clean PRs that merge on first review.

**Marginal value decay** — as agent count increases, does each additional agent produce proportional value? Or do coordination costs, CI contention, and review bottlenecks produce diminishing returns? Plot value per agent against agent count and look for the inflection point.

## Metrics That Actively Mislead

"Compiles and passes tests" is just as dangerous as lines-of-code. In the full paper, I include a case study of an LLM-generated reimplementation of SQLite — 576,000 lines of Rust. It compiled. It passed its tests. A basic primary key lookup on 100 rows took 1,815 milliseconds. The same operation in SQLite takes 0.09 milliseconds. It was **20,171x slower** — because it was missing a single physical storage optimization that someone profiled against a real workload decades ago.

That code would have scored perfectly on every activity metric and every "does it work" gate. Only outcome-level measurement — a performance benchmark — revealed the gap.

## The Unsolved Problem

There's one critical dimension that no current framework measures well: ownership attribution. Who understands a given piece of code well enough to debug and maintain it? In a world where agents produce code and humans review it under volume pressure, the assumption that "the reviewer owns it" becomes increasingly fragile.

If no human wrote the code and the reviewer only skimmed it, who actually understands the system well enough to debug it when it breaks at 3 AM?

This is an open problem. But the first step is acknowledging that the metrics most organizations are using today — the ones that feel like measurement — aren't measuring what matters.

Without instrumented, outcome-based measurement, organizations will deploy agents, feel faster, and never discover they are slower — until rework rate and regression data make the cost undeniable.

The full paper goes deeper on the measurement framework — adapted versions of DORA, SPACE, and DevEx for agentic workflows, and a detailed experimental agenda for testing what actually works.

*[Read the full paper →](https://fleig.us/writing/narrowpipe/)*
