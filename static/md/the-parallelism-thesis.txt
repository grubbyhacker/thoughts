---
title: The Parallelism Thesis
author: Roger Fleig
date: 2026-03-26
canonical: https://rogerfleig.substack.com/p/the-parallelism-thesis
source: Substack
license: http://fleig.us/license/
---

*This is the third in a series on [The Narrow Pipe](https://fleig.us/writing/narrowpipe/), a position paper on the emerging infrastructure challenges of agent-scale software engineering.*

I keep having the same conversation with engineering leaders about agentic development, and it keeps stalling in the same place. They see AI coding tools as a way to make individual developers faster. That's true, but it's the smallest version of what's happening.

The real unlock isn't speed. It's concurrency.

Here's the simplest framework I've found for explaining where we are and where this is going. It maps roughly to the autonomy spectrum I described in [my first post](https://rogerfleig.substack.com/p/the-narrow-pipe) — but where that framework asks *who is driving*, this one asks *how many lanes are open*.

## Tier 1: Co-pilot

You write code. The AI helps. It autocompletes, generates functions from comments, pairs with you on hard problems. Copilot, Cursor, and Claude Code in attended mode live here.

The gains are real. For certain tasks — boilerplate, test generation, unfamiliar APIs — it's meaningfully faster. But the throughput ceiling is *you*. Every line of output still flows through your hands. You're one developer, maybe 2–3x more productive on good days, on the right tasks.

It's a faster single thread.

This is where the vast majority of developers are today. And it feels like the ceiling, because the speed improvement is tangible and immediate.

It is not the ceiling.

## Tier 2: Manager of Agents

The role flips. You stop writing code and start defining tasks, decomposing work, and reviewing what comes back. The AI writes; you review. You've shifted from senior engineer to engineering manager.

But here's the part most people miss, and it's the whole game: **the moment you make that shift, there's no reason to manage just one agent.**

At Tier 1, you and the AI share a single thread of execution. You're in the loop for every decision. The AI is fast, but you're the bottleneck — you can only attend to one task at a time.

At Tier 2, you can have five, eight, ten agents running concurrently on different tasks. Each one is in its own inner loop — reasoning, writing code, running tests, iterating — with very little need to surface for human input. You're not copiloting anymore. You're reviewing completed work as it arrives, while other agents continue making progress in the background.

This is the difference between a 2–3x speedup and a fundamentally different throughput curve. One fast agent on one task is incremental. Eight agents on eight tasks simultaneously is multiplicative — and you haven't gotten faster at any individual task. You've gotten parallel.

### The Tier 1 Trap

Tier 1 feels productive because the feedback loop is tight. You ask, the AI responds, you iterate together. It's interactive and satisfying. The gains show up immediately.

Tier 2 requires a different posture. You have to get comfortable with agents running autonomously — making decisions you haven't reviewed yet, taking approaches you might not have chosen. The feedback loop is longer. The control is looser. For many experienced engineers, that loss of direct control feels like a step backward, even when the output volume is dramatically higher.

I think this is the real barrier. It's not technical. It's psychological. The engineers who are best at their craft — the ones with the deepest instincts about code quality, architecture, and taste — are exactly the ones who find it hardest to let go of the keyboard. The skill that made them great (deep attention to every line) is the skill that prevents them from accessing the parallelism that makes Tier 2 transformative.

This is also, incidentally, what the METR study found: developers with the *deepest* familiarity with their codebases experienced the *largest* slowdowns when using AI tools in attended mode. The more you know, the more you correct — and if you're correcting one agent in real time, you're back to a single thread.

### The Infrastructure Gap

There's a second barrier, and this one *is* technical. Running one agent is easy. Running many agents concurrently starts surfacing problems that don't exist at Tier 1: agents stepping on each other's work, CI queues backing up, merge conflicts from parallel changes, review backlogs that exceed what any human can meaningfully process.

The downstream pipeline — builds, tests, review, integration — was designed for human-speed code production. When you multiply the input by 8x, those systems become the bottleneck. This is the [narrow pipe problem](https://fleig.us/writing/narrowpipe/): the constraint was once producing code. Now it's everything *after* producing code.

The uncomfortable implication: the parallelism that makes Tier 2 valuable is the same parallelism that breaks the pipeline. You can't have one without solving the other.

### The ROI Math

The economic case for Tier 2 over Tier 1 is straightforward once you see it:

**Tier 1 ROI** = (speed gain on individual tasks) × (one task at a time)

**Tier 2 ROI** = (agent task completion rate) × (number of concurrent agents) − (review cost + coordination overhead + infrastructure cost)

Tier 1 is a linear improvement. Tier 2 is a scaling function. Even if each individual agent is somewhat less effective than you would be doing the task yourself — and in many cases it will be — the aggregate output across many parallel agents can far exceed what a single developer can produce, at any speed.

The catch is the subtracted terms. Review cost grows with agent count. Coordination overhead grows nonlinearly. Infrastructure cost is real. If your downstream systems can't absorb the volume, the gains evaporate. But these are engineering problems with known solution patterns — not fundamental limits.

## Tier 3: Spec-Driven Development

You define *what* to build and the acceptance criteria. Agents handle the *how* end-to-end. Hours later, you check results against specs and tests. The human role is product thinking and verification, not implementation.

This is operational today for certain classes of work — greenfield features with clear specs, well-bounded refactors, tasks where acceptance criteria can be fully automated. StrongDM's "Attractor" system operates here: specifications go in as markdown, agents write the code, other agents test it against holdout scenarios the coding agents never saw.

It's premature for most work on mature, complex codebases where institutional knowledge and implicit invariants make fully autonomous operation risky. But it's where the trajectory points — and the infrastructure you build for Tier 2 (agent identity, coordination, blast radius awareness, test reliability, context injection) is what makes Tier 3 possible when the models and the guardrails are ready.

## The Investment Case

This framing clarifies where infrastructure investment pays off.

You don't need agent identity, coordination systems, or blast radius awareness for one co-pilot. You don't even need most of it for one autonomous agent. But you absolutely need it the moment you're running ten agents concurrently on a shared codebase. The infrastructure investment is what converts the *theoretical* parallelism of Tier 2 into *realized* throughput.

Organizations that stay at Tier 1 will see steady, incremental productivity gains. Organizations that make the jump to Tier 2 — and build the infrastructure to support it — access a different curve entirely.

The ceiling isn't how fast one agent can code. It's how many agents you can run in parallel before the downstream systems break. Raise that ceiling, and you change the economics of the entire engineering organization.

*[Read the full paper →](https://fleig.us/writing/narrowpipe/)*
