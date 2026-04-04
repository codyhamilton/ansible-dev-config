# Aliases for running AI agents inside a devcontainer for the current repo.
# Usage: cd into any repo with a devcontainer, then run dc-claude or dc-codex.
alias dc-claude='devcontainer up --workspace-folder "$PWD" && devcontainer exec --workspace-folder "$PWD" claude --dangerously-skip-permissions --chrome'
alias dc-codex='devcontainer up --workspace-folder "$PWD" && devcontainer exec --workspace-folder "$PWD" codex --dangerously-bypass-approvals-and-sandbox'
