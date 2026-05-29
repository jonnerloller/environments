# Automation scripts

This directory is the canonical home for shared automation entrypoints.

Rule of thumb:
- cron jobs should run a script directly
- wrappers in other repos should delegate here
- use a model only when the task needs reasoning or dynamic wording

Available scripts:
- `add_flight.sh`
- `add_torrent.sh`
- `add_word.sh`
- `add_japanese_lookup.sh`
- `call_empty_dailies.sh`
- `cull_empty_dailies.py`
- `create_daily_journal_note.py`
- `journal.py`
- `send_daily_journal_reminder.sh`
- `send_exercise_reminder.sh`
- `systemcron.sh`
- `update_ports_registry.py`
