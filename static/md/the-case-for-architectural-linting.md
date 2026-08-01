---
title: The Case for Architectural Linting
author: Roger Fleig
date: 2026-04-14
canonical: https://rogerfleig.substack.com/p/the-case-for-architectural-linting
source: Substack
license: http://fleig.us/license/
---

Every senior engineer knows this dynamic, even if they've never named it.

A new developer joins the team. Their first few PRs are fine — the code compiles, the tests pass — but something is off. They reach for raw SQL instead of the query wrapper. They have the API handler call the data layer directly, bypassing the service layer. They add a new HTTP client instead of using the instrumented one the team spent three months building. None of this breaks anything. All of it violates how the system is supposed to fit together.

So a senior engineer leaves a review comment. And another. And another. The new developer adjusts. Over weeks and months, they absorb the unwritten rules — not because anyone handed them a document, but because someone took the time to correct them, and they internalized the corrections. Eventually they stop needing the comments. They start leaving the comments themselves.

This is the apprenticeship model of architectural knowledge, and it's the hidden load-bearing structure of code review. We talk about review as a quality gate — catching bugs, verifying correctness. But its second function is at least as important: transmitting the implicit rules of how a codebase fits together, one review comment at a time, until the new contributor stops being new.

The economics of this system make sense when the contributors learn. The cost is front-loaded; the payoff compounds. A senior engineer invests heavily in a junior engineer's first fifty PRs and then recoups that investment over the next five hundred. The apprenticeship model is expensive, but it's an investment with returns.

Agents break this model at the root.

Code review used to do two jobs: validate changes and transmit architectural judgment. Agents do not remove the need for the first, but they break the second. If that judgment still matters — and it does — it has to move out of reviewer memory and into enforceable checks.

> This is the sixth in a series on [The Narrow Pipe](https://rogerfleig.substack.com/p/the-narrow-pipe). The last post was about review as a bottleneck — machine-speed generation meeting human-speed validation. This one is about review's second job: transmitting architectural intent. And what you build when agents make that transmission mechanism obsolete.

## **Why Agents Break the Economics**

A coding agent doesn't accumulate architectural judgment across sessions. It doesn't feel the friction of a review comment and adjust its priors for next time. In the way that matters here, every agent PR is a first PR: the feedback may fix this change, but it rarely compounds into lasting architectural judgment. You can reject the change, explain the violation, and the agent will fix it. But the next session, on a different task, it will reach for the raw SQL again.

You are not front-loading cost for a future payoff. You are paying the full cost of architectural review on every change, forever, with no compounding return on that investment. The economics that justified using review as an enforcement mechanism simply do not apply.

This matters more than it sounds like it should, because the apprenticeship model wasn't just one way of transmitting architectural knowledge — in most codebases, it was the primary one. Written architectural rules are rare. The rules live in the heads of senior engineers and get transmitted through review. When the mechanism that transmits them stops working, those rules don't get transmitted at all.

The only way the rules survive is if someone encodes them explicitly.

## **Why "Tests Pass" Stops Being Reassuring**

CI as we know it answers a narrow question: does this code compile, and do the existing tests pass? That was a reasonable floor for quality when every change was written by someone who had absorbed months or years of architectural context. It is not a reasonable floor when changes are generated at machine speed by tools that have no model of how the system fits together.

Tests validate behavior you encoded. Architecture often lives in behavior you never encoded.

The gap between "tests pass" and "this code is correct" shows up clearly in the data. [Veracode's longitudinal analysis](https://www.veracode.com/blog/spring-2026-genai-code-security/) of AI-generated code finds that syntax correctness now exceeds 95% — code that compiles and runs — but security pass rates have plateaued at roughly 55%. The gap persists because the feedback loop rewards "works," not "safe." Tests can show the code works without showing that it is safe. The invariant isn't encoded in the feedback loop, so the agent never learns to respect it. The same dynamic often applies to architectural constraints not captured in your test suite.

Without enforcement, agent-generated code doesn't fail dramatically. It drifts. An agent violates an unwritten convention. The code passes CI. A reviewer approves it under volume pressure. The violation becomes part of the codebase. Future agents retrieve the violated pattern as context. The violation becomes the new normal. At human scale, that gap was filled by the apprenticeship model. At agent scale, it's not filled by anything — unless you build something to fill it.

## **What Architectural Linting Actually Means**

The response to this problem has a name, even if it's not yet universal: architectural linting. Not style linting — formatting and naming conventions are already solved. Not static analysis — null checks and type errors are already solved. Not security scanning, though that's closer. Architectural linting is a new category of deterministic checks that encode *structural invariants* — the rules about how a codebase fits together that currently live only in senior engineers' heads.

Concrete examples make this tangible. Dependency direction rules: "the API layer never imports from the data layer." Module boundary enforcement: "this service owns these tables and no other service queries them directly." Pattern compliance: "all database access goes through this wrapper, not raw SQL" or "all HTTP clients use the telemetry-instrumented client, not the standard library." Deprecated path detection: "this API looks available but has 200 services depending on its side effects — don't add a 201st." Change scope constraints: "modifications to shared utilities require explicit blast radius acknowledgment." Some are architectural in the classic sense; others are engineering invariants experienced teams learn the hard way and should stop relying on memory to enforce.

A word on what architectural linting is not. Repo-local guidance files — AGENTS.md, CLAUDE.md, Cursor rules files — are useful for prevention. But they are guidance, not enforcement. An agent can forget them, ignore them, or trade them off against a local objective. Architectural linting is different: a hard check that can reject a change for architectural reasons, regardless of whether the agent meant well. The distinction matters because guidance can be forgotten, ignored, or traded off — a hard check cannot.

These are not hypothetical. [CyberAgent's engineering blog](https://developers.cyberagent.co.jp/blog/archives/59647/) describes encoding Clean Architecture layer dependency rules in YAML configuration and integrating the checks into CI — and they explicitly call it an "architectural linter." Tools like [ArchUnit](https://www.archunit.org/) for Java and [Dependency Cruiser](https://github.com/sverweij/dependency-cruiser) for JavaScript and TypeScript already exist for enforcing layering rules programmatically.

Once architectural rules are machine-readable, they don't have to live only at CI. Some agent frameworks now support enforcement points inside the loop itself — hooks that intercept tool calls or block session completion until architectural checks pass.

There is a second design choice here: not just whether a rule is enforced, but how visible its enforcement is to the agent. If the agent can inspect the test, policy, or check logic, that implementation becomes part of the optimization surface. Sometimes that is useful. Other times, it pushes the agent to optimize for the check rather than the rule. For those constraints, the safer pattern is to enforce the invariant behind an interface the agent can use but not reverse-engineer. Spotify describes a similar design in its [Honk post](https://engineering.atspotify.com/2025/12/feedback-loops-background-coding-agents-part-3): verifiers are exposed as an interface the agent can call, while their internal logic stays hidden. The same pattern can matter for architectural enforcement.

Architectural linting also directly addresses the narrow pipe. The review bottleneck exists because human review can't scale to agent-generated volume. Architectural linting doesn't replace review — but it means review can focus on judgment calls rather than catching invariant violations that a machine could have caught. The reviewer's job shifts from "does this code respect our architecture?" to "is this the right thing to build?" That's a higher-leverage question, and it's the question that actually requires human judgment.

## **How to Start Monday**

Here is one I learned the hard way: never do calendar math by hand. At Microsoft, SQL Server 2005 would not restart after a certain date because an engineer evaluated a certificate with hand-rolled date logic. I remember staying up all night as the day began in Asia, then Europe, validating the hotfix and waiting to see how much damage would unfold. Years later I saw a similar class of mistake again at Google. Enough times, at enough companies, that it became a personal invariant: never do calendar math by hand. The code compiles. The types check. You can still miss it in review and CI. It is still the wrong code. And for years, I felt the frustration of not having a reliable way to enforce that rule across a codebase.

Every senior reviewer has a few rules like that — rules written in scar tissue rather than design docs. Those are exactly the rules that should stop living only in memory and start living in enforcement.

Most organizations already have their first invariants. They just haven't recognized them as such. Every outage that traced back to someone bypassing the wrapper, every regression caused by a layering violation, every incident that led a senior engineer to leave the same review comment for the tenth time: those are your invariants, already discovered and already painful. Don't ask your senior engineers which architectural rules matter. Ask them which review comments they leave because something actually broke. The answers will be higher-signal, and they'll come faster — because outages have a way of making implicit knowledge suddenly very explicit.

Pick two or three. Choose the simplest framework that can enforce them in CI. Run it for a month. What you learn — what's harder to specify than you expected, what turns out not to matter, how agents respond to the guardrail — is worth more than any amount of upfront planning.

But two or three is a starting point, not the program. The goal is a growing body of enforced architectural knowledge — one that expands every time a senior engineer hits the same review comment again and decides to convert their frustration into a check. That loop is worth understanding: the reviewer who encodes an invariant is not doing extra work. They are buying back their own time. Every rule that moves into the linter is a violation they will never have to catch manually again — from a human, and especially not from an agent generating changes at volume. The reward for contributing to the system is a lighter review queue and higher-quality code before it ever reaches them.

The organizations that will run agents well at scale are the ones that gave their senior engineers a place to turn repeated architectural pain into enforcement.

[Read the full paper →](https://fleig.us/writing/narrowpipe/)
