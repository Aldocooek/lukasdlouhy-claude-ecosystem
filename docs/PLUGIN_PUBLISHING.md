# Plugin Publishing Guide

This ecosystem is packaged and distributed as an installable Claude Code plugin. This guide explains how the plugin system works, how to install, and how to release new versions.

## How the Plugin Marketplace Works

Claude Code supports plugin discovery and installation via:

1. **GitHub releases** — users install from a repository with a `plugin.json` manifest
2. **Plugin sources in settings.json** — teams can add custom plugin registries
3. **Direct tarball installation** — offline distribution

When users run `claude plugin install <repo-url>`, the tool:
- Fetches the latest release tarball matching `.claude-plugin/plugin.json`
- Extracts skills, agents, commands, hooks, and rules
- Wires them into `~/.claude/` with symlinks or copies
- Prompts for hook registration in `settings.json`

## Installing This Plugin

### From GitHub

```bash
claude plugin install https://github.com/lukasdlouhy/claude-ecosystem-setup
```

This downloads the latest versioned release and installs into `~/.claude/`.

### From settings.json

Add to `~/.claude/settings.json`:

```json
{
  "plugins": {
    "sources": [
      {
        "type": "github",
        "repo": "lukasdlouhy/claude-ecosystem-setup",
        "version": "latest"
      }
    ]
  }
}
```

Then run:

```bash
claude plugin install
```

### Offline / Tarball

Download the tarball from [releases](https://github.com/lukasdlouhy/claude-ecosystem-setup/releases):

```bash
tar -xzf lukasdlouhy-video-marketing-pack-1.0.0.tar.gz -C ~/.claude/
# Wire hooks manually in ~/.claude/settings.json
```

## Releasing New Versions

### 1. Update plugin.json

Edit `.claude-plugin/plugin.json` with new version:

```json
{
  "version": "1.1.0",
  "description": "..."
}
```

### 2. Update CHANGELOG.md

Add section for new version:

```markdown
## [1.1.0] - 2026-05-10

### Added
- New feature

### Fixed
- Bug fix
```

### 3. Build the plugin

```bash
bash scripts/build-plugin.sh
```

Outputs: `dist/lukasdlouhy-video-marketing-pack-1.1.0.tar.gz` with SHA256.

### 4. Tag and publish

```bash
git add .claude-plugin/plugin.json CHANGELOG.md
git commit -m "Release v1.1.0"
git tag v1.1.0
git push origin main v1.1.0
```

### 5. Create GitHub release

```bash
bash scripts/publish-plugin.sh --force
```

This:
- Creates GitHub release with tag `v1.1.0`
- Attaches tarball
- Generates release notes from CHANGELOG.md
- Posts install instructions

Users can now install:

```bash
claude plugin install https://github.com/lukasdlouhy/claude-ecosystem-setup
```

## Semantic Versioning

Follow [semver](https://semver.org/):

- **MAJOR** (1.0.0 → 2.0.0): Breaking changes to skill APIs, agent interfaces, or rule semantics
- **MINOR** (1.0.0 → 1.1.0): New skills, agents, hooks, or features (backward-compatible)
- **PATCH** (1.0.0 → 1.0.1): Bug fixes, documentation updates, no new features

Example:
- Changing GSAP easing skill output format → MAJOR
- Adding new CRO skill → MINOR
- Fixing typo in docs → PATCH

## Manifest Structure

The `plugin.json` manifest declares what's installed:

```json
{
  "name": "lukasdlouhy-video-marketing-pack",
  "version": "1.0.0",
  "skills": ["hyperframes-cli", "gsap-timeline-master", ...],
  "agents": ["researcher-haiku-delegate", ...],
  "commands": ["swarm", "video-brief", ...],
  "hooks": ["pre-push-leak-scan", ...],
  "rules": ["cost-discipline", ...]
}
```

When new skills or hooks are added, update the lists and bump the version.

## Distribution Patterns

### Pattern 1: Public GitHub Release

- Maintainer pushes tags to GitHub
- Users install via `claude plugin install <repo>`
- CI/CD creates release automatically

### Pattern 2: Team Private Registry

- Team hosts custom plugin registry (HTTP server with JSON index)
- Add to team `settings.json`:
  ```json
  {
    "plugins": {
      "sources": [
        {
          "type": "http",
          "url": "https://internal.company.com/plugin-registry.json"
        }
      ]
    }
  }
  ```

### Pattern 3: Manual Distribution

- Download tarball from release
- Distribute via email, Slack, or internal docs
- Users extract to `~/.claude/` manually

## Troubleshooting

### Plugin installation fails

Check:
```bash
# Validate plugin.json syntax
jq . .claude-plugin/plugin.json

# Verify tarball contents
tar -tzf dist/*.tar.gz | head -20

# Check GitHub release exists
gh release view v1.0.0
```

### Skills not loaded after install

Wire hooks in `~/.claude/settings.json`. Plugin install should prompt you; if not, add manually:

```json
{
  "plugins": {
    "installed": [
      {
        "name": "lukasdlouhy-video-marketing-pack",
        "version": "1.0.0",
        "enabled": true
      }
    ]
  }
}
```

### Need to uninstall

```bash
claude plugin uninstall lukasdlouhy-video-marketing-pack
```

Or manually remove from `~/.claude/` and delete from `settings.json`.

## Peer Cherry-Picking

Don't want the whole plugin? Extract pieces:

```bash
# Download release
wget https://github.com/lukasdlouhy/claude-ecosystem-setup/releases/download/v1.0.0/lukasdlouhy-video-marketing-pack-1.0.0.tar.gz

# Extract only GSAP skills
tar -xzf *.tar.gz 'skills/gsap-*' -C ~/.claude/

# Or view repo and copy individual files
git clone https://github.com/lukasdlouhy/claude-ecosystem-setup
cp lukasdlouhy-claude-ecosystem/rules/cost-discipline.md ~/.claude/rules/
```

See [COLLABORATION.md](../COLLABORATION.md) for the full peer protocol.

---

Questions? Open an issue or see [README.md](../README.md).

Last updated: 2026-04-26
