# Cron Setup for Auto-Documentation

## Installation

Add this line to your crontab (run `crontab -e`):

```bash
# Generate documentation daily at 2 AM
0 2 * * * /Users/sac/dev/swarmsh/worktrees/auto-docs/docs/auto_generated/auto_doc_cron.sh
```

## Alternative: Use existing cron-setup.sh

```bash
# Add to cron-setup.sh
echo "0 2 * * * /Users/sac/dev/swarmsh/worktrees/auto-docs/auto_doc_generator.sh" >> cron_schedule.txt
./cron-setup.sh install
```

## Monitoring

Check logs at: `docs/logs/auto_doc_cron.log`

## Manual execution

```bash
./auto_doc_generator.sh
```

