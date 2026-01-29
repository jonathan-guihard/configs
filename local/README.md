# Local Configuration Directory

This directory is for machine-specific configurations that should not be committed to the repository.

## Usage

Create `.zsh` files in this directory to override or extend the public configurations. All files in this directory are automatically loaded by `zshrc`.

### Examples

**`configs/local/custom.zsh`**
```zsh
# Machine-specific configuration
export PATH="/opt/custom/bin:$PATH"
export CUSTOM_VAR="value"
alias local-alias='echo "Local machine alias"'

# Company VPN
alias vpn-connect='sudo openconnect vpn.company.com'
```

**`configs/local/work.zsh`**
```zsh
# Work-specific settings (different from enterprise configs)
export JIRA_URL="https://company.atlassian.net"
alias jira='open $JIRA_URL'
```

**`configs/local/experiments.zsh`**
```zsh
# Temporary experiments
source /tmp/test-plugin.zsh
```

## Notes

- Files are loaded last in the configuration chain
- Can override both public and private configurations
- Ideal for settings that are too specific for the main configs
