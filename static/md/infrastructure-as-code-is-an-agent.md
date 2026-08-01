---
title: Infrastructure as Code Is an Agent Interface
author: Roger Fleig
date: 2026-07-15
canonical: https://rogerfleig.substack.com/p/infrastructure-as-code-is-an-agent
source: Substack
license: http://fleig.us/license/
---


I have reached the point more than once where I would rather stick a needle in my eye than use the Cloudflare UI again.

Cloudflare has an enormous configuration surface. DNS, tunnels, routes, access policy, service tokens, and edge behavior all meet in one place. The underlying networking is complex in its own right.

I would ask a coding agent how to configure something, and it would confidently tell me to click a button that was not there. Cloudflare's support bot did the same thing. Sometimes the instructions were stale. Sometimes the option was available only to enterprise customers. Sometimes the API and UI expressed the same idea differently. In every case, the advice was precise and unusable on the screen in front of me.

A human interface carries navigation, visual hierarchy, progressive disclosure, style, and product taste. Those things can help a person explore a service. Once the design decision has been made and the remaining job is to enable a route or change a policy, they become clutter between intent and execution. The UI also changes with account tier, permissions, and feature rollout, so there is no single screen for an agent to know.

I moved as much of Cloudflare as I could into infrastructure as code (IaC) deliberately. IaC does not make the underlying networking simpler. It removes the presentation layer and reduces the operation to declared state plus a programmatic contract I can test and trust. My agents can inspect the declared state, propose a change, test it, and bring the result back for review.

## From gestures to a state transition

With Terraform, the agent can inspect the existing declaration, propose a change as a diff, run a plan, and revise the proposal when reality disagrees. The provider performs the mechanical transition.

The agent and I should focus on which route or policy ought to exist, not on reconstructing a visual procedure. ClickOps kept me in the loop at the least valuable point: manually enacting a decision we had already made.

A *plan* and *apply*, Terraform's preview and execution steps, compress an infrastructure transition into bounded tool calls instead of requiring a reasoning model to narrate and remember every step. But the larger gain is ownership. The agent can carry the work to a reviewable state instead of stopping at the edge of my browser.

While bringing Cloudflare under Terraform, a live plan returned an error for two settings that were unavailable on my plan. We removed them and documented the exception. The provider was not perfect, but it was testable. A missing button had produced an argument. A failed plan produced evidence. That is the better way to disagree with reality: run the plan and let the control plane answer.

This is why infrastructure as code is an agent interface. It turns infrastructure into the kind of object a coding agent already knows how to work with: inspectable state, a proposed change, and structured feedback. IaC is not the entire operating stack; deployment automation, secret tooling, credentials, and CI carry other parts of the work. Its particular contribution is to make intended infrastructure state reviewable and executable.

The declarations survive the conversation, too. The next agent can recover the declared state and read the history of how it changed. The infrastructure becomes shared system memory.

## Bigger levers

I have written before about [coding agents dismissing more capable designs](https://rogerfleig.substack.com/p/the-work-that-was-never-mine) because they overestimate development cost. Infrastructure as code removes another reason for them to think small: the design no longer stops where the application code ends.

When a design calls for a new tunnel (the guarded path that lets outside traffic reach a private service) but the only reliable control surface is Cloudflare's account-specific UI, I have to leave the shared engineering workflow and implement that part manually. When the tunnel is code, the agent can carry our agreed design across the same boundary, run a plan, and bring the result back for review. The declaration, provider configuration, permissions, and checks remain behind for later work. That change does more than solve one problem; it makes the next infrastructure change easier to land.

Building bigger does not primarily mean more servers or more lines of code. It puts bigger levers inside the agent's reach.

I saw this while building Signal Plane, a system that turns GitHub events into durable work for my agent infrastructure. Terraform declared external resources, Ansible handled deployment, Doppler handled secrets, and purpose-built checks proved the result. Codex could pursue one goal across all of them.

The first milestone was ingress. The agent built the webhook receiver and declared a dedicated Cloudflare tunnel with Terraform. A real GitHub event passed through the tunnel and reached the receiver, whose log effectively said: *I see you.* The route that event traveled existed entirely because the agent had declared it; I never opened Cloudflare to build the ingress.

The next milestone extended that path through a dispatcher to an agent. Signal Plane kept active work in a local durable ledger so it could survive downstream outages. A dedicated object-storage bucket provided encrypted off-site backups and a restore path. Because we already used object storage for Terraform state, the recovery bucket was a small declarative addition.

Terraform stopped because its token could not manage buckets. I used the Cloudflare UI once to grant that authority, and the agent resumed the repeatable work the grant allowed.

I gave Codex a concrete goal: keep working until it could prove the completed path or come back to me with a concrete reason it could not. Once the permission changed, it finished the recovery path, deployed the remaining changes, and proved the extended path: a real labeled GitHub issue produced exactly one dispatched job for an agent. The closing stretch ran as a single orchestrator turn of just over a hundred minutes, covering backups, deployment, and verification across repositories and, most notably, cloud infrastructure while I was away from the mechanical loop.

The first milestone proved an event could be seen. The second proved an event could become work. An agent's sprint ends at the first boundary it cannot operate, and in this build the only such boundary was the one I chose to keep. Nothing about Codex itself had changed. More of the system was now within its reach.

## Put the human where authority changes

My role is to decide where an agent's authority begins and ends. Once that boundary is set, the agent can act inside that authority.

The bucket permission was one example. The work paused for the part that belonged to me: deciding whether the infrastructure identity should have that authority. One click granted a reusable capability. The alternative is delegation running in reverse: the agent reasons about what should exist while I work the console as its hands, creating each bucket on its behalf. Grant the authority once, and every operation inside it belongs to the agent. That was exactly where I wanted the friction.

GitHub Apps make the division even clearer.

I use GitHub Apps as authority boundaries for GitHub-oriented agents. The identity system underneath them, the brokered tokens and narrow grants, is one I described in [If You Give an Agent a Token...](https://fleig.us/writing/if-you-give-an-agent-a-token/); this article is about what those identities can operate. A review agent does not need the same permissions as an implementation agent. A service that reads releases does not need permission to write repository contents. The App's permissions set the ceiling, its installation selects the repositories, and runtime policy can narrow the authority further.

GitHub does not make the whole App lifecycle available through Terraform. App creation and installation still require an authenticated person in the UI. Permission increases require approval. Those actions create or expand authority, so human confirmation belongs there.

When I created the Apps, the agent prepared their definitions, checked the permissions, and configured the secret destinations. It paused while I confirmed creation, reauthenticated, and selected the repositories. Afterward, it sent the generated credentials directly to Doppler and prepared the infrastructure changes for review.

I do not need to download a PEM, paste a secret into chat, or transcribe an installation ID. The agent walks the ceremony right up to the moments that require my identity and judgment, pauses, and resumes immediately after them.

Automation did not eliminate the trust ceremony. It removed everything from the ceremony that was not actually about trust.

The same removal changes the economics of least privilege. When every narrow identity costs a pile of manual setup and credential handling, the pressure is to reuse one broadly capable credential. Once the mechanics are automated, each role can hold its own identity: one for review, one for reading releases, one for implementation. The system operates more infrastructure while each agent holds less authority.

## The interface needs rules

Putting bigger levers inside an agent's reach makes executable rules more important. This is where infrastructure as code connects to something I have written about before: [architectural linting](https://rogerfleig.substack.com/p/the-case-for-architectural-linting). It puts important structural rules into the codebase as deterministic checks. When an agent crosses one of those boundaries, it gets immediate feedback and can correct itself before I have to catch the mistake in review.

In my infrastructure repository, the ordinary pull-request path runs separate lint, secret, and infrastructure checks. One validator encodes a rule I care about deeply by rejecting common ways secret values can enter Terraform state. When it finds a violation, CI fails the proposed change and gives the agent a concrete error to correct.

A prompt tells the agent the rule. The validator makes that rule a condition of merging.

There are two kinds of agents in this article, and they live under different rules. The agents the system dispatches, the ones the GitHub Apps and runtime policy govern, run inside the tightest boundaries I have. The coding agents that build the system run on my development machine with far more freedom.

The gates in this repository guard the builders' proposal path, not the apply. Nothing forces a change through a pull request; a builder holding the operator credentials can apply straight from a local working tree, and mine often do. That is my choice, not a property of the design, and the risk is real. But the broadly privileged builders are constructing the governed system that ends the arrangement: narrow identities, brokered credentials, and the sandboxes their successors will run inside. It is the oldest pattern in toolmaking. A machine built by hand inherits the accuracy of the hand, and its first job is to build a machine that exceeds it. What infrastructure as code provides is not enforcement by itself. It provides the review, memory, and repeatability boundary, and the places to put real gates as I narrow authority. ClickOps performed through my already-authenticated browser has no comparable path toward principled automation.

## Tools agents can operate

Cloudflare and Doppler, the service that manages my secrets, both have broad, busy interfaces designed for human operators. Once I have decided what the configuration should be, clicking through either one is mostly paperwork. Their well-developed Terraform providers move that work into the same code-driven workflow as the rest of my infrastructure. I chose Doppler in part because it fit this way of working.

Before Doppler, I tried to store a PEM file in Ansible Vault as a multiline YAML value. I had to preserve exactly the right line breaks and indentation inside another serialization format. I got it wrong, which was stupid but predictable, and then handed the problem to an agent. The agent eventually arranged the text correctly.

That was still the wrong answer.

Neither a person nor a reasoning model should be carefully fitting a private key into YAML. A tool should accept the file, store it correctly, and report whether it succeeded. Agent accessibility does not mean pushing every operation through the model's reasoning. It means giving the agent a reliable tool and making the mechanical execution boring.

Every success in this article traces back to a control surface an agent could operate. Every capability that lives only in a browser is a break in an otherwise agent-carried system.

That surface does not have to be Terraform. A complete API or a reliable command-line tool can give an agent everything it needs. Terraform's declarative model is simply a high standard for what a control surface can offer: desired state, previewable changes, drift detection, and repeatable execution.

Better computer use does not close this gap. An agent that can operate a browser can now perform ClickOps instead of talking me through it, but that is the most expensive execution model I can imagine: frontier reasoning spent watching a screen, one click at a time, to accomplish what a command-line tool does in a single bounded call. And the click sequence remains a far worse artifact than a declaration: no proposal to review before the change is real, weaker authority boundaries than a scoped token, and nothing the next agent can reuse. It automates the gestures without changing the unit of work.

Going forward, I will require that every tool in my infrastructure stack give an agent a way to operate it on my behalf. A human approval is fine; requiring a human to carry out the mechanics is not.

That requires stable programmatic access, a way to limit the agent's authority, feedback it can act on, and evidence that the operation succeeded. Once the decision has been made, I should not have to reenact it by hand.

I began by trying to avoid the Cloudflare UI. What I actually wanted was a system I could delegate without giving up judgment or control. Infrastructure as code supplied the missing interface: the agent could propose and deliver the change, executable checks could constrain it, and I kept the decisions that required me.

The internet does not need a chatbot bolted onto every service. It needs the services we already use to expose a surface agents can operate.

Infrastructure as code was already a better way to operate systems. With coding agents, it becomes something else as well: the form that lets an agent hold more of the system at once, carry a decision farther, and leave the result open to human judgment before it becomes real.

*Technical note: The system described here uses OpenTofu. I use "Terraform" in the article as the familiar name for this family of tools.*
