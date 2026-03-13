{
  "permissions": {
    "allow": [
      "Bash(wc:*)",
      "Bash(az account show:*)",
      "Bash(az containerapp show:*)",
      "Bash(az containerapp list:*)",
      "Bash(az containerapp revision show:*)",
      "Bash(az monitor log-analytics query:*)",
      "Bash(CI=true pnpm install:*)",
      "Bash(gh secret set:*)",
      "Bash(gh secret delete:*)",
      "Bash(gh secret list:*)",
      "Bash(az ad sp list:*)"
    ]
  },
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "command -v dippy >/dev/null 2>&1 && dippy || true"
          }
        ]
      }
    ],
    "PreToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "input=$(cat); file=$(echo \"$input\" | jq -r '.file_path // \"\"' 2>/dev/null); case \"$file\" in */.env|*/.env.local|*/.env.production|*/.env.test|*/.env.development) echo \"BLOCKED: Direct edits to .env files are restricted. Update .env.example instead.\"; exit 2;; esac"
          }
        ]
      },
      {
        "matcher": "Bash|mcp__git__git_commit",
        "hooks": [
          {
            "type": "command",
            "command": "bash __HOME__/.claude/pre-commit-gate.sh"
          }
        ]
      }
    ]
  },
  "statusLine": {
    "type": "command",
    "command": "bash __HOME__/.claude/statusline-command.sh"
  },
  "enabledPlugins": {
    "github@claude-plugins-official": true,
    "code-review@claude-plugins-official": true,
    "superpowers@claude-plugins-official": true,
    "frontend-design@claude-plugins-official": true,
    "typescript-lsp@claude-plugins-official": true,
    "playwright@claude-plugins-official": true,
    "commit-commands@claude-plugins-official": false,
    "claude-md-management@claude-plugins-official": true,
    "feature-dev@claude-plugins-official": true,
    "greptile@claude-plugins-official": true,
    "claude-code-setup@claude-plugins-official": true,
    "huggingface-skills@claude-plugins-official": true,
    "plugin-dev@claude-plugins-official": true,
    "security-guidance@claude-plugins-official": true,
    "git-workflow@sai-claude-plugins": true
  },
  "extraKnownMarketplaces": {
    "sai-claude-plugins": {
      "source": {
        "source": "git",
        "url": "https://github.com/sai-manoj-kumar/sai-claude-plugin-marketplace.git"
      },
      "autoUpdate": true
    }
  },
  "effortLevel": "medium",
  "voiceEnabled": true,
  "mcpServers": {
    "context7": {
      "type": "stdio",
      "command": "npx",
      "args": [
        "-y",
        "@upstash/context7-mcp"
      ]
    },
    "github": {
      "type": "stdio",
      "command": "sh",
      "args": [
        "-c",
        "GITHUB_PERSONAL_ACCESS_TOKEN=$(gh auth token) npx -y @modelcontextprotocol/server-github"
      ]
    }
  }
}
