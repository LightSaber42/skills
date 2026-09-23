---
name: to-spec
description: "Turn the current conversation into a spec and publish it to the project issue tracker: no interview, just synthesis of what you've already discussed."
disable-model-invocation: true
---

This skill takes the current conversation context and codebase understanding and produces a spec. Do NOT interview the user; just synthesize what you already know.

The issue tracker and triage label vocabulary should have been provided to you. If not, tell the user to run `/setup-matt-pocock-skills`.

## Process

1. Explore the repo to understand the current state of the codebase, if you haven't already. Read the applicable repository instructions (`AGENTS.md`, `CLAUDE.md`, or their referenced rules), domain glossary or context documents, and ADRs for the area being specified. Write the spec in the repository's vocabulary (external systems keep their own names). If a decision conflicts with a rule or ADR, record the change only when the conversation decided it; otherwise stop and report the conflict.

2. Sketch out the seams at which you're going to test the feature. Existing seams should be preferred to new ones. Use the highest seam possible. If new seams are needed, propose them at the highest point you can. The fewer seams across the codebase, the better - the ideal number is one.

Check with the user that these seams match their expectations.

3. Write the **acceptance criteria** first. They are the completion contract that implementation and review are judged against:

   - Give each a stable ID (`AC1`, `AC2`, ...) and one observable, falsifiable outcome: the trigger, the public boundary, the expected result, and the failure behavior where it matters.
   - Name the test seam and the evidence that proves it.
   - Every requested behavior lands in a criterion or in Out of Scope. Rollout and follow-up milestones go in Out of Scope as deferred, so the implementation isn't silently responsible for them.

4. Write the spec using the template below. Reread it once against the glossary, the ADRs and its own sections, and resolve every contradiction before publishing. Publish it to the project issue tracker with the `ready-for-agent` triage label (no further triage needed).

<spec-template>

## Problem Statement

The problem that the user is facing, from the user's perspective.

## Source

Originating documents (path or URL, with section locators), or "this conversation".

## Solution

The solution to the problem, from the user's perspective.

## User Stories

A LONG, numbered list of user stories. Each user story should be in the format of:

1. As an <actor>, I want a <feature>, so that <benefit>

<user-story-example>
1. As a mobile bank customer, I want to see balance on my accounts, so that I can make better informed decisions about my spending
</user-story-example>

This list of user stories should be extremely extensive and cover all aspects of the feature.

## Acceptance Criteria

The completion contract, with stable IDs.

| ID | Observable criterion | Test seam and passing evidence |
| --- | --- | --- |
| AC1 | When ..., the public boundary ...; if ..., it visibly ... | Existing production-facing seam; observable result |

## Implementation Decisions

A list of implementation decisions that were made. This can include:

- The modules that will be built/modified
- The interfaces of those modules that will be modified
- Technical clarifications from the developer
- Architectural decisions
- Schema changes
- API contracts
- Specific interactions

Name modules, interfaces, and contracts in prose. Code paths and snippets go stale; omit them.

Exception: if a prototype produced a snippet that encodes a decision more precisely than prose can (state machine, reducer, schema, type shape), inline it within the relevant decision and note briefly that it came from a prototype. Trim to the decision-rich parts, not a working demo, just the important bits.

## Testing Decisions

A list of testing decisions that were made. Include:

- A description of what makes a good test (only test external behavior, not implementation details)
- Which modules will be tested
- Prior art for the tests (i.e. similar types of tests in the codebase)

Cite the acceptance-criterion IDs each test decision covers.

## Out of Scope

A description of the things that are out of scope for this spec, including deferred rollout or follow-up milestones (name their owner when known).

## Further Notes

Any further notes about the feature.

</spec-template>
