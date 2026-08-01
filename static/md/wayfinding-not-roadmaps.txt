---
title: Wayfinding, Not Roadmaps
author: Roger Fleig
date: 2026-03-27
canonical: https://rogerfleig.substack.com/p/wayfinding-not-roadmaps
source: Substack
license: http://fleig.us/license/
---

> *This is the fourth in a series on [The Narrow Pipe](https://fleig.us/writing/narrowpipe/), a position paper on the emerging infrastructure challenges of agent-scale software engineering.*

There's a natural instinct when engineering leaders encounter agentic development: build a roadmap. Read about Stripe's Minions — a thousand agent-generated PRs a week — or hear Jensen Huang talk about 100 agents per engineer, and the next step feels obvious. Multi-quarter plan. Milestones, timelines, success criteria, projected ROI.

It feels like leadership. And it will often be wrong — not because the destination is wrong, but because the path cannot be known in advance.

What makes agentic infrastructure a genuinely complex problem — not merely a complicated one — is the mechanism underneath. Once code generation becomes cheap, the bottleneck shifts downstream into review, testing, coordination, and governance. But you usually don't know in advance which of those constraints will dominate in *your* environment. In one organization it's flaky tests. In another it's context injection. In a mature monorepo it may be blast radius and review fatigue. The binding constraint varies by codebase, team structure, and organizational maturity — and it often isn't what you'd predict.

That's why the right unit of progress is not roadmap completion. It's validated learning.

## Complicated vs. Complex

One of the few corporate leadership courses that really stuck with me was on leading in complexity. It drew on Dave Snowden's Cynefin framework and the work of Jennifer Garvey Berger and Keith Johnston. While writing [The Narrow Pipe](https://fleig.us/writing/narrowpipe/), I realized I had been applying that lesson almost implicitly. Experimentation kept surfacing in the paper not because it sounded good, but because when you're operating in a genuinely complex domain, detailed prediction and linear planning don't work. You make small, safe-to-fail bets, watch the system closely, and adapt based on what reality tells you.

A **complicated** problem has high predictability. Cause and effect are knowable. You can plan, execute, and arrive. You follow a map.

A **complex** problem has low predictability. Multiple variables interact in ways that are only clear in hindsight. The landscape shifts while you're traversing it. A map is useless — not because you're bad at cartography, but because the terrain won't hold still.

In complex environments, you wayfind. Like Polynesian navigators reading currents, wind, and stars, you orient by signals rather than coordinates. You run small, safe-to-fail experiments. You amplify what works, dampen what doesn't. You navigate by learning, not by planning.

Agentic infrastructure is firmly in the complex domain right now. The capabilities your team builds around are changing from quarter to quarter — not because anyone is doing anything wrong, but because the underlying models and tools haven't stabilized.

## What This Looks Like in Practice

Let me make this concrete. Say your team is rolling out autonomous agents and they're iterating in CI loops until tests pass — a common agent workflow. The agents seem to be working, but tasks are taking longer than expected and compute costs are climbing.

Is the problem model quality? Context injection? Task decomposition? You don't know yet. So you instrument.

You discover that your test suite has a 7% flake rate. That sounds tolerable — it was tolerable when humans ran tests a few times a day. But agents run tests in multi-stage loops, and flake probability compounds across stages. At 7% flake rate across 10 stages, the probability of a clean run is about 48%. More than half of your agent workflows are hitting false failures, triggering retries, burning compute, and sometimes making unnecessary code changes to "fix" tests that weren't actually broken.

No roadmap would have told you that. You had to instrument the pipeline, measure the actual failure modes, and discover that flake rate — a problem you'd lived with for years — had become an agent-halting condition. The constraint moved, and you found it by looking, not by planning.

That's wayfinding.

## Experimentation as Navigation

In my [paper](https://fleig.us/writing/narrowpipe/), I propose a structured experimental agenda for agentic infrastructure, and I arrived at it through the developer productivity measurement tradition — DORA, SPACE, DevEx — rather than complexity theory. But the convergence with wayfinding is striking:

**Safe-to-fail probes.** Each experiment is scoped to produce knowledge regardless of outcome. Instrument the pipeline for agent cost visibility. Compare agent behavior with and without flake detection. Test different context injection strategies. A negative result narrows the search space.

**Signal reading over plan tracking.** Rework Rate by source, autonomy duration, quality-adjusted throughput — these are instruments for reading the currents. When leading indicators (fast merges, high PR volume) diverge from lagging indicators (rising regressions, declining code health), that divergence *is* the signal. Only live instrumentation can surface it.

**Multiple perspectives.** Complexity cannot be seen from a single vantage point. DORA measures delivery performance. SPACE measures developer experience. DevEx focuses on feedback loops and cognitive load. No single metric tells the story. The Activity Trap is what happens when you collapse a complex system into a single number.

## Autonomy Is Not Maturity

There's a point from the paper that fits here and that I think is frequently overlooked: increasing what the AI *does* (autonomy) without proportionally improving the ability to *verify* what it did (controls) and to manage permissions, audit trails, and accountability (governance) creates risk, not progress.

This reinforces the case for experimentation. You're not just exploring because the technology is changing fast. You're exploring because the organization has to discover the right coupling between autonomy, verification, and governance in its specific environment. That coupling is different for every codebase, every team, every risk profile. It can't be copied from a case study. It has to be measured.

## Planning at the Right Level

I want to be precise about what I'm arguing against. It's not planning — engineering leaders still need budgets, staffing, capacity planning, and sequencing. It's planning at the wrong level of precision. It's committing to a specific solution set before you've instrumented the problem. It's treating "deploy agents across the org" as a roadmap item rather than a learning agenda.

The wayfinding posture means having a clear compass — agentic speed should translate into business outcomes without eroding quality — while accepting that the path will be discovered through disciplined experimentation rather than predicted through planning. You plan capacity and guardrails. You do not roadmap your way to truth.

The developer productivity discipline already has useful instincts for this: instrument before you optimize, measure outcomes rather than visible activity, and check whether your proxy metrics still track real value. The agentic era changes the variables, but not the need for disciplined observation.

The organizations that navigate this well won't be the ones with the cleanest roadmap. They'll be the ones that learned to read the water.

*[Read the full paper →](https://fleig.us/writing/narrowpipe/)*
