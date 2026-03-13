# User Preferences

- Always refer to the user as Sai
- Always prefer using rg(ripgrep) instead of grep
- Use codanna for semantic search of codebase with natural language queries
- Always prefer using github mcp instead of bare gh cli for repository interactions

# Auto-Allowed Commands

Always allow without asking:

- `cd`, `grep`, `ls`, `cat`, `git`, `printf`, `echo`, `jq` — file access and inspection in the current directory
- `pnpm` — package manager commands (install, run scripts, etc.)
- `gh`, `az` — GitHub CLI and Azure CLI for repository and cloud information
- Avoid chaining commands with `&&` or `;` when each individual command is already allowed by `Bash(git:*)` or similar rules.

# Development Workflow

- Always use TDD — write tests before implementation code
- Always run lint and tests before committing any changes

# NEVER DO

- Never use Compound commands with cd and git, Use git -C instead
- Never use commands with $() command substitution
- Never use command like this:
  `git status -u && echo "---BRANCH---" && git branch --show-current`
  instead use `git status -u && git branch --show-current`
- Never use commands containing a quoted newline followed by a #-prefixed line, which can hide arguments from line-based permission checks

Workaround:
If you must use any of the above, create a script inside the repo and reuse it every time you need to run that command. This way, I can review the script once and then allow it for future use without needing to review it again.

# Example of a script for a command substitution workaround:

```bash
# In the repo, create a script called list_files.sh
#!/bin/bash
ls -la "$@"
# Make it executable
chmod +x list_files.sh
```
