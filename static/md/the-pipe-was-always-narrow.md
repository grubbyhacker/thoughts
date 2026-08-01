---
title: The Pipe Was Always Narrow
author: Roger Fleig
date: 2026-04-03
canonical: https://rogerfleig.substack.com/p/the-pipe-was-always-narrow
source: Substack
license: http://fleig.us/license/
---

Around 2018, my team at Google built a system called Sensenmann that automatically deleted dead code at scale. It tracked binary usage across production and corporate desktops, and if a binary hadn't been seen for months, the system generated a changelist to remove it root and twig. Phil Norman, one of my engineers, [wrote about it](https://testing.googleblog.com/2023/04/sensenmann-code-deletion-at-scale.html). It submitted over a thousand deletion changelists a week and eventually deleted nearly 5% of all C++ at Google.

The technical system worked beautifully. The human system broke.

Developers started pushing back — and not because the deletions were wrong. They pushed back because even a correct, trivially simple change has a real cost when you're the one being asked to approve it. You have to build enough context to be confident you won't regret it later. You might be new to the project and not feel qualified to make that call. You might be heads-down shipping something for a launch and simply not have the bandwidth — no matter how correct the change is. Sometimes people just said no because they didn't have the attention to think it through.

We ended up building something more sophisticated than a throttle. Teams could configure how many robot-authored changes they received and when. If an owner said "not now," the system snoozed for a quarter and tried again — maybe the next owner would be ready to let it go.

That was before anyone had heard of an LLM. The changes were trivially simple deletions — no judgment required, correctness guaranteed. And it still broke the pipe.

> *This is the fifth in a series on [The Narrow Pipe](https://rogerfleig.substack.com/p/the-narrow-pipe), and it's about where the constraint bites hardest: not code quality, but the human capacity to absorb change.*

## The Same Mechanism, Larger Scale

Fast forward to early 2026, and the same dynamic is visible across major open-source projects.

GitHub's Ashley Wolf calls it the ["Eternal September of open source"](https://github.blog/open-source/maintainers/welcome-to-the-eternal-september-of-open-source-heres-what-we-plan-to-do-for-maintainers/): the cost to create has dropped, but the cost to review has not. The Augment Code data is the starkest version of this: across enterprise repositories, PR volume surged 98% and review time climbed 91% in step. All that extra generation velocity landed directly on reviewers.

Projects started closing the door. curl ended its bug bounty after a flood of AI-generated slop reports — and it was removing the incentive, not improving the tooling, that dried up the tsunami. LLVM's policy explicitly calls unreviewed LLM output ["extractive"](https://llvm.org/docs/AIToolPolicy.html): it shifts effort from the implementor to the reviewer.

The mechanism is not specific to open source. OSS got hit first because it has no access controls and volunteer reviewers with no "hire more" option. But I've watched the same thing play out inside an enterprise.

At Crusoe, my team had a rollout plan to terraform our GitLab instance across roughly 400 repositories. Before we could execute it, someone sent an AI-generated merge request covering the whole scope — unreadable, without a spec, just a prompt. To evaluate it, a reviewer would have had to reconstruct the entire context from scratch. That's validation burden: it doesn't appear in the PR count, and it doesn't go away just because the code might be correct.

The second incident was subtler. Someone used an AI coding tool over a weekend to add a cache key I was deliberately holding back until after a larger refactor. The change looked plausible. Another engineer — one who wasn't close to the full problem — approved it. Two messy weeks followed. The code wasn't obviously wrong. The reviewer just didn't have the context to know what they were actually approving, or what responsibility they were taking on.

The Terraform MR might have been fine. The deletion CLs were provably correct. Responsibility can't be parallelized as cheaply as code generation can.

## Engineering the Pipe

If the bottleneck is structural, the response has to be structural. All the approaches that have worked start from the same premise: reviewer attention is a finite resource. Engineer around it.

**Narrow the scope of what you automate on the review side.** Around the same time as Sensenmann, my team — in collaboration with a research group at Google Brain — built a system called AutoCommenter to handle a class of review tasks called "tips": published preferences from the style guide, the low-hanging fruit of readability review. The training data came from the readability reviewers themselves — their own comments became the examples the model learned from, and then the system took over that specific class of work. It reached tens of thousands of developers daily. Manushree Vijayvergiya and my team [published the results](https://research.google/pubs/ai-assisted-assessment-of-coding-practices-in-industrial-code-review) at AIware '24.

It worked because the scope was narrow: style-guide compliance, not architectural judgment. The same pattern is re-emerging as verifier agents and defensive AI. Reviewer-side AI becomes much less reliable when it tries to replace the judgment that makes human review expensive in the first place.

**Build backpressure deliberately.** You get one chance to waste a developer's time — after that, they stop paying attention. If you don't build backpressure into the system, humans create their own: by rejecting everything, or by rubber-stamping it. Sensenmann's queueing system gave teams control over their own intake rate. curl learned the same lesson in 2026: removing the bounty incentive did more to reduce the flood than any tooling change. Design the queue, or the queue designs itself — badly.

**Shift validation before the review.** Stripe's Minions system runs local lint and selective test execution from over three million tests before anything reaches a human, with a hard cap of two CI rounds. By the time a PR reaches a person, most of the correctness validation has already happened. The review becomes a judgment call about design alignment — not a forensic investigation.

**Match review depth to risk.** Reviewing everything at equal depth means reviewing nothing well. AutoCommenter freed readability reviewers for the harder judgment calls by handling the mechanical ones. Graduated autonomy applies the same principle explicitly: route low-risk changes through lighter review, and preserve human attention for the changes that genuinely need it.

Sensenmann's deletion CLs were about as simple as a code change can be. Correct. Reviewable in seconds. They still broke the pipe — because correctness doesn't reduce the cost of building enough context to feel confident taking responsibility for something. LLMs didn't create that constraint. They widened the upstream side of it. Today's AI-authored changes are larger in scope and arrive with more confidence. The reconstruction cost scales with them.

Addy Osmani asks what I think is [the right question](https://medium.com/@addyosmani/comprehension-debt-the-hidden-cost-of-ai-generated-code-285a25dac57e): how much of what we're shipping do we actually understand? The pipe was always narrow. We just used to push less through it.

[Read the full paper →](https://rogerfleig.substack.com/p/the-narrow-pipe)
