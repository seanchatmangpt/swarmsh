# SwarmSH Authority Model

SwarmSH separates selection, construction, and actuation so that observation or generated output never acquires ambient execution authority.

## Command classes

### SELECT / observe

Read-only commands inspect identity or state:

```bash
swarmsh doctor
swarmsh receipt
swarmsh replay
swarmsh dashboard
swarmsh version
```

### CONSTRUCT

Construction produces a candidate artifact without installing it:

```bash
swarmsh cron render
swarmsh verify
```

`verify` executes local validation but does not install persistent automation or deploy services.

### DO

These commands intentionally change SwarmSH state or host scheduling state:

```bash
swarmsh register ...
swarmsh claim ...
swarmsh progress ...
swarmsh complete ...
swarmsh cron install
swarmsh cron remove
```

No read-only or construction command may silently promote itself into one of these operations.

## Cron transaction semantics

`cron-setup.sh` owns tagged SwarmSH scheduling entries. Installation performs these transitions:

1. validate `crontab` and every managed command;
2. create a timestamped backup receipt;
3. read the existing crontab;
4. remove previous `SWARMSH_8020` entries from the constructed candidate;
5. append the current managed fragment;
6. install the candidate in one `crontab` operation.

Removal follows the same backup-first path and removes only tagged entries. Unrelated user cron entries are preserved.

`render` never calls `crontab` and is the supported preview/admission path.

## Coordination state

`COORDINATION_DIR` is the explicit state boundary. Tests and automation should set it to a dedicated directory instead of relying on machine-specific paths. `lib/s2s-env.sh` resolves repository identity but preserves an explicit caller-supplied `COORDINATION_DIR`.

## Receipts and replay

`scripts/verify-core.sh` emits a JSON receipt containing:

- schema identity;
- exact Git commit SHA;
- exact Git tree SHA;
- verification status;
- timestamp and duration;
- individual check outcomes.

`scripts/replay-receipt.sh` compares both commit and tree identity to the current checkout. A passed receipt from another commit is `UNKNOWN` for the current subject, not transferable proof.

## Failure transparency

SwarmSH does not convert these conditions into success:

- a missing required binary;
- a missing managed cron command;
- invalid JSON coordination state;
- a failed lifecycle transition;
- a receipt identity mismatch;
- a core verifier failure.

Optional capabilities reported by `swarmsh doctor` may yield `PARTIAL_ALIVE`; required failures yield `BLOCKED`.
