# Cogenity for Claude Code and Codex

Cogenity by Kenneth Lynne is a vendor-neutral multi-account manager for Claude
Code and Codex. It keeps each account's settings and credentials separate,
then starts the provider with the account you choose.

## Usage

Run `cogenity` without flags to open the provider and account picker.

```sh
cogenity             # Pick or add an account
cogenity --codex     # Pick a Codex account
cogenity status      # Check account capacity
cogenity update      # Install a new Cogenity release
cogenity --yolo      # Use unsafe permission mode
```

After enrollment, replace these emails with your own:

```sh
# Customer A: start Claude Code with the customer account
cogenity --claude --account dev@customer-a.ai

# Private: start Claude Code with your private account
cogenity --claude --account me@personal.ai
```

Each command opens Claude Code as usual with the selected local profile.
Cogenity does not proxy or modify the Claude Code session.

Provider permission checks stay on by default. To turn them off, run
`cogenity --yolo` or set `YOLO=1`. Cogenity passes Claude Code
`--dangerously-skip-permissions` or Codex `--yolo`.

## Getting started

Install Claude Code 2.1.144 or newer, Codex, or both. Then install Cogenity and
enroll your accounts. Replace the example emails with your real login
addresses.

```sh
brew install kennethlynne/tap/cogenity
cogenity login claude dev@customer-a.ai
cogenity --claude --account dev@customer-a.ai
```

Repeat `cogenity login` for each account you want to keep separate.

With mise, replace the Homebrew install command with:

```sh
mise use -g github:kennethlynne/cogenity@latest
```

You can also run `cogenity` and select **Add account**. On Linux, or without
Homebrew, use the installer:

```sh
curl --proto '=https' --tlsv1.2 -fsSL https://raw.githubusercontent.com/kennethlynne/cogenity/main/install.sh | sh
```

### Platform support

- **macOS:** 13 or newer on arm64 or x86-64.
- **Linux:** Experimental on arm64 or x86-64. Requires glibc, `libstdc++`, and
  `libgcc`.

Linux requires kernel 3.10 or newer; kernel 5.6 or newer is recommended. Linux
x86-64 processors require SSE4.2 (Intel Nehalem, AMD Bulldozer, or newer).

The installer checks the release checksum and writes
`~/.local/bin/cogenity`. Set `COGENITY_INSTALL_DIR` to change the destination.
Local account and launch commands do not need a separate Bun installation.

Cogenity checks for a new release once a day without delaying a launch. It
only shows a notice. Run `cogenity update` when you are ready. Homebrew and
mise remain the install owner. Standalone installs use the verified release
installer. A failed check waits one day before it retries. Run
`cogenity doctor` to see the saved failure. Set `COGENITY_UPDATE_CHECK=0` to
disable update checks.

Cogenity keeps profiles under `~/.config/cogenity`. On macOS, Claude Code uses
the system Keychain. On Linux, credentials stay inside each profile directory.

AgentBox choices appear only outside an AgentBox, in a repository with
`agentbox.yaml` and Bun on `PATH`. AgentBox flows also require `git`.

## Cogenity Pro

Three accounts are free in total across Claude Code and Codex. Cogenity Pro is
required when you add a fourth account.

```sh
cogenity upgrade             # Buy Pro in the browser
cogenity activate <license>  # Reconnect an existing license
cogenity billing             # Open subscription management
```

Cogenity keeps the same Pro installation when its config remains on disk. If
you reinstall without that config or move to another machine, run
`cogenity activate <license>` with the license key from your Creem receipt or
customer portal, or run `cogenity activate` alone and enter it at the hidden
prompt. Neither path saves the license key, but the argument form leaves it in
your shell history. Do not run `cogenity upgrade` to recover an old purchase
because it starts a new checkout.

### What Cogenity stores

- `~/.config/cogenity/pro.json` holds a random installation ID and secret
  credential, pending pairing or activation capabilities, and the current
  signed entitlement cache. The file is readable only by your user.
- The Cogenity Worker stores pairing and installation records; Creem customer,
  checkout, product, subscription, license, and transaction IDs; event IDs;
  payment amount and currency; and subscription lifecycle state in Cloudflare
  SQLite. It stores keyed digests of installation credentials, polling
  capabilities, and license keys, not the raw secrets.
- Creem stores the customer, payment, subscription, and license records. The
  Worker reads signed Creem webhooks, then uses its own ledger during normal
  Cogenity launches.
- `~/.config/cogenity/telemetry.json` holds a separate random machine ID and
  your telemetry choice. It is not the Pro installation ID. Run
  `cogenity telemetry off` to turn reporting off.
- `~/.config/cogenity/update.json` holds release check times, release versions,
  notice times, and a safe error category. It contains no account or telemetry
  ID. The hidden update refresh disables telemetry.

Cogenity never sends Claude Code or Codex credentials to the Worker. The Worker
contacts Creem only to create a checkout, activate an entered license, or open
subscription management. It does not contact Creem for each launch.

This repository contains the installer and release executables, not Cogenity's
TypeScript source or development history. Compiled executables can still be
inspected.

Cogenity is made by Kenneth Lynne. It is not affiliated with, endorsed by, or
supported by Anthropic or OpenAI. You are responsible for complying with
provider terms, controlling account access, and paying usage charges. You are
also responsible for actions taken in unsafe mode.
The software is provided as-is, without warranty. Copyright Kenneth Lynne AS.
All rights reserved. Kenneth Lynne AS permits users to download and run this
installer and the official Cogenity executables. It grants no additional right
to modify or redistribute the Cogenity code. Third-party components remain
under their own licenses. Each executable embeds Bun under Bun's own license.

See [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md) for bundled software terms.
