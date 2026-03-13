#!/bin/bash
# Claude Code PreToolUse hook — blocks git commits if lint or tests fail.
# Receives tool input JSON via stdin.

input=$(cat)

tool_name=$(echo "$input" | jq -r '.tool_name // ""')
command=$(echo "$input" | jq -r '.tool_input.command // ""')
repo_path=$(echo "$input" | jq -r '.tool_input.repo_path // ""')

# Only act on git commit operations
if [[ "$tool_name" == "Bash" ]]; then
    if [[ "$command" != *"git commit"* ]]; then
        exit 0
    fi
elif [[ "$tool_name" == "mcp__git__git_commit" ]]; then
    : # always run checks
else
    exit 0
fi

# Resolve working directory
if [[ -n "$repo_path" && -d "$repo_path" ]]; then
    cd "$repo_path"
fi

git_root=$(git rev-parse --show-toplevel 2>/dev/null)
if [[ -z "$git_root" ]]; then
    exit 0  # not in a git repo, allow
fi
cd "$git_root"

run_checks() {
    local pkg="$1"  # package manager: pnpm | npm | yarn

    # Lint
    if jq -e '.scripts.lint' package.json > /dev/null 2>&1; then
        echo "--- Pre-commit: running lint ---"
        "$pkg" lint 2>&1
        if [[ $? -ne 0 ]]; then
            echo ""
            echo "BLOCKED: Lint failed. Fix errors before committing."
            exit 2
        fi
    fi

    # Type-check (common in TS projects)
    if jq -e '.scripts["type-check"]' package.json > /dev/null 2>&1; then
        echo "--- Pre-commit: running type-check ---"
        "$pkg" type-check 2>&1
        if [[ $? -ne 0 ]]; then
            echo ""
            echo "BLOCKED: Type-check failed. Fix errors before committing."
            exit 2
        fi
    fi

    # Tests
    if jq -e '.scripts.test' package.json > /dev/null 2>&1; then
        echo "--- Pre-commit: running tests ---"
        CI=true "$pkg" test 2>&1
        if [[ $? -ne 0 ]]; then
            echo ""
            echo "BLOCKED: Tests failed. Fix failures before committing."
            exit 2
        fi
    fi
}

# Node / JS projects
if [[ -f "package.json" ]]; then
    if [[ -f "pnpm-lock.yaml" ]]; then
        # pnpm project — explicit commands
        if jq -e '.scripts.lint' package.json > /dev/null 2>&1; then
            echo "--- Pre-commit: running pnpm lint ---"
            pnpm lint 2>&1 || { echo "BLOCKED: Lint failed. Fix errors before committing."; exit 2; }
        fi
        if jq -e '.scripts["type-check"]' package.json > /dev/null 2>&1; then
            echo "--- Pre-commit: running pnpm type-check ---"
            pnpm type-check 2>&1 || { echo "BLOCKED: Type-check failed. Fix errors before committing."; exit 2; }
        fi
        if jq -e '.scripts.test' package.json > /dev/null 2>&1; then
            echo "--- Pre-commit: running pnpm test ---"
            CI=true pnpm test 2>&1 || { echo "BLOCKED: Tests failed. Fix failures before committing."; exit 2; }
        fi
    elif [[ -f "yarn.lock" ]]; then
        run_checks yarn
    else
        run_checks npm
    fi

# Python projects
elif [[ -f "pyproject.toml" ]] || [[ -f "setup.py" ]]; then
    if command -v ruff > /dev/null 2>&1; then
        echo "--- Pre-commit: running ruff lint ---"
        ruff check . 2>&1 || { echo "BLOCKED: Ruff lint failed."; exit 2; }
    fi
    if command -v pytest > /dev/null 2>&1 && [[ -d "tests" || -d "test" ]]; then
        echo "--- Pre-commit: running pytest ---"
        pytest 2>&1 || { echo "BLOCKED: Tests failed."; exit 2; }
    fi

# Makefile fallback
elif [[ -f "Makefile" ]]; then
    if make -n lint > /dev/null 2>&1; then
        echo "--- Pre-commit: running make lint ---"
        make lint 2>&1 || { echo "BLOCKED: Lint failed."; exit 2; }
    fi
    if make -n test > /dev/null 2>&1; then
        echo "--- Pre-commit: running make test ---"
        make test 2>&1 || { echo "BLOCKED: Tests failed."; exit 2; }
    fi
fi

echo "--- Pre-commit checks passed ---"
exit 0
