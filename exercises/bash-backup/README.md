# Bash backup exercise

This course script accepts a source directory and destination directory, selects files based on modification time, creates a timestamped `tar.gz` archive and moves the archive to the destination.

## File

- [backup.sh](backup.sh)

## Intended usage

```bash
bash backup.sh /path/to/source /path/to/destination
```

## Status

This is a coursework draft and should not be used as a production backup tool without correction and testing. In the current code, the timestamp described as "yesterday" adds 24 hours instead of subtracting it. The `ls` loop and unquoted paths also do not handle spaces safely, and relative directory changes can make path resolution fragile.

