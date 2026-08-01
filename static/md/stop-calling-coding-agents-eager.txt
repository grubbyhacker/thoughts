---
title: Stop Calling Coding Agents Eager Interns
author: Roger Fleig
date: 2026-04-28
canonical: https://rogerfleig.substack.com/p/stop-calling-coding-agents-eager
source: Substack
license: http://fleig.us/license/
---

The popular framing of coding agents as eager interns gets them almost exactly backward. The agents I worked with were often the opposite of eager — cautious to the point of inaction unless they had a clear license to proceed. Under the right constraints, what they displayed looked much more like engineering judgment than eagerness: caution around broad changes, sensitivity to sequencing, a willingness to stop when the scope ran out. The intern framing tells you to teach. What I needed to do was define the lane, then stop standing in it.

I only figured this out because I spent a while being annoyed by it first.

I built a small agent simulator on the Roblox platform earlier this month — 107 Luau files by the end — and in the rush of getting something working I skipped the code health infrastructure: no formatter, no linter, no typechecker. A mistake I knew I was making and made anyway. Late in the project, with the core system working, I went back to fix it.

I asked my coding agent to set up formatting, style linting, and static type checking, then enforce them across the existing codebase. The agent installed the tooling, wired it into the build, and reported done.

Almost nothing had changed.

I pushed harder. It did a little more — a handful of files, `--!strict` added at the top, type errors resolved. Then it stopped. I pushed again. Same result. Iteration after iteration I kept escalating the request and kept getting back careful incrementals, one file at a time, every single one clean and correct and frustratingly small.

Here's what one of those commits looked like:

```text
--- a/src/mechanics/CrestDipBuilder.luau
+++ b/src/mechanics/CrestDipBuilder.luau
@@ -1,3 +1,5 @@
+--!strict
+
 -- CrestDipBuilder.luau
...
-local CrestDipBuilder = {}
+type CrestDipBuilderModule = {
+    build: (state: SectorState, entryFrame: CFrame, exitFrame: CFrame) -> (),
+}
...
-function CrestDipBuilder.build(state: SectorState, entryFrame: CFrame, _exitFrame: CFrame)
+local function build(state: SectorState, entryFrame: CFrame, _exitFrame: CFrame): ()
     local p = state.params
-    assert(p.height_or_depth, "CrestDipBuilder: missing height_or_depth")
+    local height = assert(p.height_or_depth, "CrestDipBuilder: missing height_or_depth")
```

Precise. Complete. One file. Then stop.

I had assumed the agent was simply being timid. While writing this post I went looking for why, and found something I hadn't known was there. The project's AGENTS.md — a contract file that coding agents read at the start of each session — contained this line: *"Do not perform bulk* `--!strict` *upgrades as part of routine hygiene; ratchet strictness module-by-module with explicit scope."* I hadn't written it directly. One of the earlier coding agents had added it during a handoff compaction pass, promoting a lesson from a previous session into a standing rule. I hadn't noticed it was there. The agent demurring on my requests wasn't defiance or timidity — it was following guidance it had written for itself, because it had already learned that bulk strict upgrades on a working codebase are the kind of thing that breaks things quietly.

Worth noting: AGENTS.md is soft guidance, not enforcement. Agents can and do trade it off against local objectives when pushed hard enough — I've written about that elsewhere. But in this case it held, which made the conservatism invisible to me until I went looking for it.

My reaction at the time was still frustration. I had approved this work a dozen times over in spirit. Why was the agent making me re-approve each file?

Eventually I stopped pushing and tried something different — a mode I came to think of as a first-class collaboration tool: *"don't design or implement, just chat with me."* The explanation that came back was the clearest writing I got from any agent all week.

It laid out the three distinct goals hiding inside "turn on type safety everywhere." First: make the analyzer understand the Roblox platform at all — without the right engine type definitions, the typechecker would flag `Vector3` and `CFrame` (built-in Roblox 3D types, not anything in my code) as unknown identifiers, producing noise rather than signal. Second: make every file pass the checker cleanly — no errors, but still in the default permissive mode where many type problems are simply not checked. Third: make every file declare itself `--!strict`, opting into the full type discipline. The first goal had only just finished. Doing the second and third before the first was done would have produced "strict" files whose strictness was illusory — every file flagged clean, with real type errors hidden behind a wall of tool noise.

Then the metaphor that stuck:

> *The repo is a workshop. Phase 31 put the lights on. Now you can actually see the clutter. The clutter was already there. Turning on the lights did not create it.*

What I had been reading as refusal was sequencing. Mass-flipping files before the analyzer was ready would have produced meaningless results — and the agent, apparently, had already worked that out.

The "eager intern" framing makes sense as a description of first contact with these tools. They generate text confidently, they need correction, they can overstep. That pattern feels intern-like, and the management model it suggests — corrective feedback, expectation-setting, teaching — feels reasonable.

And to be clear: overreach is real. Agents can make sweeping unreviewed changes, operate outside the operator's intent, or cause serious damage when the hard constraints aren't there — no guardrails, no sandboxing, no limits on what the agent can actually touch. That's a real failure mode and it deserves serious attention.

What I'm describing is different — and I think it only becomes visible once the hard constraints are actually in place. With the harness set up properly, the tests running, the scope defined, the rollback available, what I kept running into wasn't overreach. It was the opposite. The agent knew where the edge was and was treating it as a hard stop rather than a suggestion. An intern overshoots because they don't yet know where the line is. What I saw looked more like a senior engineer who understood the line clearly and wasn't going to cross it without being explicitly told to.

That reframe changes the workflow problem. If the agent has the judgment but not the green light, the answer isn't more correction or more prompt engineering. It's a clearer scope — a phase plan, an explicit policy, a state file that says what's in bounds this run and what requires a human decision. Not to enable recklessness, but to give a capable and cautious collaborator the structure it needs to actually do the work.

I eventually ran the full migration as a campaign: a small orchestrator that invoked the agent file-by-file against a state file with explicit budgets and escalation rules. The campaign carried the project from 27 strict-typed files to 90 across five unattended runs: one escalation, sixty-three clean commits, and no broad rewrite. The agent didn't need me in the room for most of it. It needed me to have been clear about the rules before it started.

That's not a story about giving an agent more power. It's a story about giving a careful agent a well-defined lane.

*This comes from building [Autotrack](https://github.com/grubbyhacker/autotrack), a Roblox agent simulator. The longer version — including how the campaign mode orchestrator works in detail — is [in this essay](https://fleig.us/writing/autotrack/). I write about agentic infrastructure on [Substack](https://rogerfleig.substack.com).*
