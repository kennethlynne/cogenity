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
curl -fsSL https://cogenity.sh/install.sh | sh
cogenity enroll claude dev@customer-a.ai
cogenity --claude --account dev@customer-a.ai
```

Repeat `cogenity enroll` for each account you want to keep separate. You can
also run `cogenity` and select **Add account**.

To install with Homebrew instead:

```sh
brew install kennethlynne/tap/cogenity
```

Or with mise:

```sh
mise use -g github:kennethlynne/cogenity@latest
```

### Platform support

- **macOS:** 13 or newer on arm64 or x86-64.
- **Linux:** Experimental on arm64 or x86-64. Requires glibc, `libstdc++`, and
  `libgcc`.

Linux requires kernel 3.10 or newer; kernel 5.6 or newer is recommended. Linux
x86-64 processors require SSE4.2 (Intel Nehalem, AMD Bulldozer, or newer).

The installer checks the release checksum and writes
`~/.local/bin/cogenity`. Set `COGENITY_INSTALL_DIR` to change the destination.
When that directory is not on `PATH`, the installer adds it to your zsh or bash
startup file; set `COGENITY_NO_MODIFY_PATH=1` to leave the file unchanged.
To print only errors, pipe the script to `sh -s -- -q` instead of `sh`; use `-h` to list the options.
Cogenity needs no separate Bun installation.

Cogenity checks for a new release once a day without delaying a launch. It
only shows a notice. Run `cogenity update` when you are ready. A Homebrew
update moves Cogenity to `~/.local/bin` and removes the formula only after
checking the replacement and the shell PATH. A healthy mise copy can
still win PATH and stays unchanged. Mise continues to own its installs.
Standalone installs use the verified release
installer. A failed check waits one day before it retries. Run
`cogenity doctor` to see the saved failure. Set `COGENITY_UPDATE_CHECK=0` to
disable update checks.

Cogenity keeps profiles under `~/.config/cogenity`. On macOS, Claude Code uses
the system Keychain. On Linux, credentials stay inside each profile directory.

## Cogenity Pro

Three provider accounts are free in total across Claude Code and Codex, and
they need no Cogenity account. Cogenity Pro is required when you add a fourth.

```sh
cogenity login      # Sign in to your Cogenity account in the browser
cogenity upgrade    # Subscribe, or confirm you already have Pro
cogenity dashboard  # Open your dashboard in the browser
cogenity billing    # Manage your subscription in the browser
cogenity logout     # Sign this machine out
```

`cogenity login` shows a code and a URL, opens the page, and waits for you to
confirm it there. `cogenity upgrade` reports an existing subscription and
exits; otherwise it opens your dashboard at
[app.cogenity.sh](https://app.cogenity.sh), where you subscribe, and waits for
your payment. Ctrl-C
stops either wait and changes nothing, so you can run the command again.

`cogenity dashboard` opens your dashboard. After you subscribe,
`cogenity billing` opens the Creem page where you manage your subscription;
this machine must be signed in.

Your subscription belongs to your account, not to one machine, so you can sign
in on as many machines as you like. The dashboard at
[app.cogenity.sh](https://app.cogenity.sh) lists every machine you signed in
from and signs one out for you; `cogenity logout` signs out the machine you run
it on. A machine that loses access locks its extra accounts again at the next
check.

### What Cogenity stores

- `~/.config/cogenity/account.json` holds your Cogenity user ID, the address
  you signed in with, and the current signed entitlement. The file is readable
  only by your user and holds no credential. An older `pro.json` from a release
  before accounts existed is ignored and can be deleted.
- Your refresh credential lives in the macOS Keychain, in an item named
  `Cogenity-account-…`; on other systems it is a `.credentials.json` file
  readable only by your user. `cogenity logout` removes it.
- The Cogenity Worker stores your email, plan, paid-through date, signed-in
  machines, and Creem customer, checkout, subscription and transaction IDs in
  Cloudflare SQLite. It stores keyed digests of your credentials, not the raw
  secrets.
- Creem stores the customer, payment and subscription records. The Worker reads
  signed Creem webhooks, then uses its own records during normal Cogenity
  launches.
- `~/.config/cogenity/telemetry.json` holds a separate random machine ID and
  your telemetry choice. It is not your Cogenity account ID. Run
  `cogenity telemetry off` to turn reporting off.
- `~/.config/cogenity/update.json` holds release check times, release versions,
  notice times, and a safe error category. It contains no account or telemetry
  ID. The hidden update refresh disables telemetry.

Cogenity never sends Claude Code or Codex credentials to the Worker, and no
sign-in token from the identity provider ever reaches the CLI. The Worker
contacts Creem only to open a checkout or subscription management. It does not
contact Creem for each launch.

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
