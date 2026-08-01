---
title: The Narrow Pipe
author: Roger Fleig
date: 2026-03-25
canonical: https://rogerfleig.substack.com/p/the-narrow-pipe
source: Substack
license: http://fleig.us/license/
---

I published a position paper today called *[The Narrow Pipe](https://fleig.us/writing/narrowpipe/)* — it's long, opinionated, and covers a lot of ground. This post is the short version of the thesis, and the first in a series that unpacks the key ideas.

Here's the core observation: the cost of producing code is falling fast. But the downstream infrastructure that reviews, builds, tests, integrates, and deploys that code? It was designed for human-speed throughput.

This is the Theory of Constraints applied to software engineering. For decades, the constraint was producing code. Now that agents are dissolving that constraint, the bottleneck doesn't disappear — it shifts downstream, and every existing limitation in the pipeline becomes the new critical path.

## The Agent Loop

To reason about this concretely, it helps to define two loops:

The **micro-loop** is the agent's internal cycle: reason, act, observe, repeat. Each iteration burns tokens, time, and potentially infrastructure — a test run, a build, a search query. Every problem in agentic infrastructure either inflates or deflates this loop count. A flaky test that sends the agent chasing a phantom failure? That's wasted micro-loops. Poor context injection that omits a key dependency? More wasted micro-loops.

The **macro-loop** is the roundtrip between agent and human — a review comment, an escalation, a course correction. This is where human judgment enters the system. The key metric here is *autonomy duration*: how far an agent can progress through meaningful work before it needs a human. Longer autonomy duration means fewer macro-loops and less human bottleneck. But longer autonomy without guardrails means compounding errors.

The Narrow Pipe, restated: agents squeeze the pipeline from both directions simultaneously. The micro-loop hammers shared infrastructure at 10–100x the rate it was designed for. The macro-loop stays human-speed but now faces a volume of agent-produced work that no review process was built to absorb.

## The Autonomy Spectrum

Dan Shapiro mapped the progression of AI-assisted development onto five levels — modeled on the NHTSA's driving automation levels. The analogy is intentional: each level shifts who is driving.

- **Level 1 — Autocomplete.** AI suggests completions. Human is driving.

- **Level 2 — Pair programming.** Developer and AI collaborate. This is where most "AI-native" teams operate today. Critically, every level from here on *feels* like the ceiling. It is not.

- **Level 3 — Code review.** AI writes the code; the developer reviews it. The developer's job shifts from senior engineer to engineering manager. This is where the Narrow Pipe thesis bites hardest.

- **Level 4 — Spec-driven.** Engineers write specifications. Agents write code. Other agents test it. Hours later, humans check the results. The job shifts from *how* to *what*.

- **Level 5 — The Dark Factory.** Specs go in, software comes out.

My paper focuses on building the infrastructure for Levels 3 and 4 to work reliably at scale — particularly in mature monorepos, where the structural challenges make every level transition harder.

## Why "More Code" Isn't the Goal

There's a subtler risk beyond throughput. Without deliberate reinforcement, the pipeline doesn't merely constrict the flow of agent-generated code — it allows institutional quality to leak out over time. Review rigor erodes under volume pressure. Agent output becomes the context for future agents. Patterns simplify. Critical details — the kind that only accumulate through years of profiling against real workloads — quietly disappear.

The goal is not "more code." It's ensuring that agentic speed translates into business outcomes without eroding the architectural stability that makes a codebase maintainable over years.

## What's in the Full Paper

*[The Narrow Pipe](https://fleig.us/writing/narrowpipe/)* maps eight interdependent problem areas (runtime isolation, agent identity, graduated autonomy, coordination, context injection, institutional knowledge, test reliability, and blast radius awareness), proposes a measurement framework adapted from DORA, SPACE, and DevEx, and lays out an experimental agenda for making progress with evidence rather than intuition.

It also includes a detailed case study of Stripe's Minions system — the most concrete public example of enterprise-scale agentic development — and a cautionary case study of an LLM-generated SQLite reimplementation that compiled, passed its tests, and was 20,000x slower on a basic operation.

The infrastructure that governs code quality must be rebuilt for a world where the volume of changes exceeds what human judgment alone can govern. The paper is my attempt to map that problem space rigorously.

More posts in this series coming soon — next up: why your agent productivity metrics are probably lying to you.

*[Read the full paper →](https://fleig.us/writing/narrowpipe/)*
