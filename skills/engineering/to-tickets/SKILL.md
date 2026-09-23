---
name: to-tickets
description: Break a plan, spec, or the current conversation into a set of tracer-bullet tickets, each declaring its blocking edges, published to the configured tracker (edges as text in one file per ticket locally, or native blocking links on a real tracker).
disable-model-invocation: true
---

# To Tickets

Break a plan, spec, or conversation into a set of **tickets**: tracer-bullet vertical slices, each declaring the tickets that **block** it.

The issue tracker and triage label vocabulary should have been provided to you. If not, tell the user to run `/setup-matt-pocock-skills`.

## Process

### 1. Gather context

Work from whatever is already in the conversation context. If the user passes a reference (a spec path, an issue number or URL) as an argument, fetch it and read its full body and comments. Carry originating **source** locators forward; each ticket cites only the locators it covers.

### 2. Explore the codebase (optional)

If you have not already explored the codebase, do so to understand the current state of the code. Read the applicable repository instructions (`AGENTS.md`, `CLAUDE.md`, or their referenced rules), domain glossary or context documents, and ADRs for the area being ticketed. Write tickets in the repository's vocabulary (external systems keep their own names). If the source conflicts with a rule or ADR and doesn't authorize the change, stop and send the conflict back to the source spec.

Look for opportunities to prefactor the code to make the implementation easier. "Make the change easy, then make the easy change."

### 3. Draft vertical slices

Break the work into **tracer bullet** tickets.

<vertical-slice-rules>

- Each slice cuts a narrow but COMPLETE path through every layer (schema, API, UI, tests): vertical, NOT a horizontal slice of one layer
- A completed slice is demoable or verifiable on its own
- Each slice is sized to fit in a single fresh context window
- Any prefactoring should be done first

</vertical-slice-rules>

Give each ticket its **blocking edges**: the other tickets that must complete before it can start. A ticket with no blockers can start immediately.

Before presenting the breakdown, allocate the requirements:

- Carry the source spec's acceptance-criterion IDs (assign stable ones if it has none). Each source criterion has exactly one **owning ticket**.
- Give every ticket its own `AC1`, `AC2`, … criteria: one observable outcome each, with the test seam and the evidence that proves it.
- A criterion that can't pass until another ticket lands needs a real blocking edge, or belongs to that ticket instead.
- Rollout, live verification and cleanup that later tickets own are named as deferrals, not implied.

For each ticket, publish a **Scope boundary** with `Owns` and `Defers`. Review treats work a sibling ticket owns as a non-blocking note.

**Wide refactors are the exception to vertical slicing.** A **wide refactor** is one mechanical change (rename a column, retype a shared symbol) whose **blast radius** fans across the whole codebase, so a single edit breaks thousands of call sites at once and no vertical slice can land green. Don't force it into a tracer bullet; sequence it as **expand–contract**. First expand: add the new form beside the old so nothing breaks. Then migrate the call sites over in batches sized by blast radius (per package, per directory), each batch its own ticket blocked by the expand, keeping CI green batch to batch because the old form still exists. Finally contract: delete the old form once no caller remains, in a ticket blocked by every migrate batch. When even the batches can't stay green alone, keep the sequence but let them share an integration branch that all block a final integrate-and-verify ticket; green is promised only there.

### 4. Quiz the user

Present the proposed breakdown as a numbered list. For each ticket, show:

- **Title**: short descriptive name
- **Blocked by**: which other tickets (if any) must complete first
- **What it delivers**: the end-to-end behaviour this ticket makes work
- **Source**: document and locators this ticket covers
- **Owns / defers**: source criteria owned here and named work left to sibling tickets
- **Acceptance evidence**: ticket-local criterion IDs and their production-facing test seams

Ask the user:

- Does the granularity feel right? (too coarse / too fine)
- Are the blocking edges correct: does each ticket only depend on tickets that genuinely gate it?
- Should any tickets be merged or split further?

Iterate until the user approves the breakdown.

### 5. Publish the tickets to the configured tracker

Before publishing, reread the whole set once. Every source criterion must have exactly one owner, every edge must be real, and no two criteria may contradict each other. Fix anything that fails.

Publish the approved tickets. **How** depends on the tracker `/setup-matt-pocock-skills` configured; the tickets are the same either way, only the shape of the blocking edges changes:

- **Local files** → write one file per ticket under `.scratch/<feature-slug>/issues/<NN>-<slug>.md`, numbered from `01` in dependency order (blockers first). Each file's "Blocked by" lists the numbers/titles it depends on. Use the per-ticket file template below: one ticket per file, never a single combined file.
- **A real issue tracker (GitHub, Linear, …)** → publish one issue per ticket in dependency order (blockers first) so each ticket's blocking edges can reference real identifiers. Use the platform's native blocking / sub-issue relationship where it has one; otherwise set each ticket's "Blocked by" to the blocking issues. Apply the `ready-for-agent` triage label unless instructed otherwise; the tickets are agent-grabbable by construction.

Work the **frontier**: any ticket whose blockers are all done. For a purely linear chain that means top to bottom.

Do NOT close or modify any parent issue.

<local-ticket-template>

# <NN>: <Ticket title>

**What to build:** the end-to-end behaviour this ticket makes work, from the user's perspective, not a layer-by-layer implementation list.

**Source:** originating document(s) and locators this ticket covers.

**Scope boundary:**

- **Owns:** source acceptance-criterion IDs or exact locators completed by this ticket.
- **Defers:** named behavior owned by another ticket, or "None."

**Blocked by:** the numbers/titles of the tickets that gate this one, or "None (can start immediately)".

**Status:** ready-for-agent

- [ ] **AC1:** When ..., the public boundary ... and the observable result is .... Evidence: named test seam and passing result.
- [ ] **AC2:** If ..., the boundary visibly .... Evidence: named negative-path seam and passing result.

</local-ticket-template>

<issue-template>

## Parent

A reference to the parent issue on the tracker (if the source was an existing issue, otherwise omit this section).

## Source

Originating document(s) and locators this ticket covers.

## What to build

The end-to-end behaviour this ticket makes work, from the user's perspective, not layer-by-layer implementation.

## Scope boundary

- **Owns:** source acceptance-criterion IDs or exact locators completed by this ticket.
- **Defers:** behavior owned by named sibling issues, or "None."

## Acceptance criteria

- [ ] **AC1:** When ..., the public boundary ... and the observable result is .... Evidence: named test seam and passing result.
- [ ] **AC2:** If ..., the boundary visibly .... Evidence: named negative-path seam and passing result.

## Blocked by

- A reference to each blocking ticket, or "None (can start immediately)".

</issue-template>

In either form, name implementation in prose rather than code paths or snippets: they go stale fast. Cite originating **source** documents and locators. Exception: if a prototype produced a snippet that encodes a decision more precisely than prose can (state machine, reducer, schema, type shape), inline it and note briefly that it came from a prototype. Trim to the decision-rich parts, not a working demo, just the important bits.
