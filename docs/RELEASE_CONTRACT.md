# SwarmSH Release Contract

SwarmSH is release-qualified only when the exact candidate commit passes the repository's deterministic core verifier and the resulting receipt replays against the same commit/tree identity.

## Standing vocabulary

- `UNKNOWN` — no current execution evidence for the admitted subject.
- `PARTIAL_ALIVE` — required core is available, but optional operational capabilities are absent or unverified.
- `ALIVE` — required verification executed successfully against the exact admitted commit and its receipt replays against the same Git tree.
- `BLOCKED` — required tool, file, authority, or environment capability is unavailable.
- `BUILD_BROKEN` — verification executed and failed.
- `UNSUPPORTED` — the requested environment or surface is outside the declared contract.

These states are evidence labels, not marketing labels. Historical reports, README badges, workflow definitions, or the existence of a script do not establish `ALIVE` by themselves.

## Core subject

The release-qualified core consists of:

1. `swarmsh` — public command boundary.
2. `coordination_helper.sh` — coordination lifecycle implementation.
3. `real_agent_coordinator.sh` — compatibility route into the coordinator.
4. `lib/s2s-env.sh` — portable environment identity contract.
5. `cron-setup.sh` — explicit/reversible cron construction and actuation.
6. `test-essential.sh` — isolated lifecycle/telemetry integration acceptance.
7. `scripts/preflight.sh` — read-only environment diagnosis.
8. `scripts/verify-core.sh` — deterministic release verifier.
9. `scripts/replay-receipt.sh` — exact-subject receipt replay.

Specialized surfaces such as Ollama Pro have independent workflows and do not substitute for core verification.

## Required release path

```text
source commit
  -> preflight
  -> bash syntax
  -> environment contract
  -> read-only CLI routes
  -> cron construction
  -> source hygiene
  -> essential lifecycle execution
  -> no-source-mutation check
  -> verification receipt
  -> receipt replay against HEAD + HEAD^{tree}
```

The canonical command is:

```bash
bash scripts/verify-core.sh
bash scripts/replay-receipt.sh
```

or through the public boundary:

```bash
bash swarmsh verify
bash swarmsh replay
```

## Actuation fence

Verification is not allowed to install cron jobs, start persistent daemons, modify external services, or claim deployment success. `cron render` is construction only. `cron install` and `cron remove` are explicit state-changing operations.

Coordination commands are similarly explicit: `claim`, `register`, `progress`, and `complete` modify coordination state. `doctor`, `verify`, `receipt`, `replay`, `version`, and `cron render` are read-only with respect to persistent external automation.

## Runtime-state isolation

Tests must set `COORDINATION_DIR` to an isolated directory. They must not append telemetry to tracked repository fixtures. Verification receipts are written under `.swarmsh-test-results/`, which is ignored as runtime evidence rather than treated as source.

## CI contract

`.github/workflows/core-validation.yml` executes the core verifier on Linux and macOS and uploads `.swarmsh-test-results/` as the run receipt. A workflow file existing in the repository is not evidence of success; only a completed run against the exact candidate head qualifies that head.

## Falsifiers

Release standing falls from `ALIVE` when any of these becomes true:

- the receipt `subject_sha` or `tree_sha` differs from the checked-out candidate;
- a required verifier check fails;
- a required runtime dependency is absent;
- test execution mutates tracked source;
- the public CLI routes to a missing implementation;
- cron construction references a missing managed command;
- core CI fails on a supported OS.

A new commit also invalidates the previous exact-head crown until verification is replayed for the new identity.
