# crossr

One keyboard and mouse across a Windows PC and a MacBook, over the LAN. Video is
untouched — each machine keeps driving its own monitor. Switching is instant because the
devices never disconnect; only input routing changes.

Free. Windows 11 and macOS 13+ (Apple Silicon).

**[⬇ Download the latest release](https://github.com/MotionComplex/crossr-releases/releases/latest)**

This repository holds the installers and the macOS install script — nothing else.

---

## Install

Install on **both** machines.

### macOS

```bash
curl -fsSL https://raw.githubusercontent.com/MotionComplex/crossr-releases/main/install.sh | bash
```

Downloads the newest release, installs it to `/Applications`, and launches it. Run the
same line again later to update.

The script exists because crossr is not notarised by Apple. A `.dmg` downloaded through a
browser carries `com.apple.quarantine`; macOS 15 then refuses to open the app, and the old
right-click → **Open** bypass is gone. Files fetched with `curl` are never quarantined, so
this does not work *around* Gatekeeper — it never trips it. Same app, same signature, no
dialog.

If you would rather not pipe a script to `bash`, download `crossr-<version>.dmg` from the
[latest release](https://github.com/MotionComplex/crossr-releases/releases/latest) and drag
it to Applications. That route *is* quarantined: the first open is refused, and you allow it
under System Settings → Privacy & Security → **Open Anyway**.

### Windows

Download `crossr-<version>-setup.exe` from the
[latest release](https://github.com/MotionComplex/crossr-releases/releases/latest) and run it.

Per-user install, no admin prompt, and self-contained — the machine needs no .NET
installed. It is unsigned, so SmartScreen shows *Windows protected your PC* → **More info**
→ **Run anyway**.

---

## First run

crossr is a tray / menu-bar utility. There is no main window; a setup screen opens on first
launch, and afterwards lives behind **Setup…** in the tray or menu-bar menu.

Every prerequisite is a live row on that screen — polled, not assumed — so nothing fails
silently.

**On macOS**, two permissions are required, both deep-linked from their rows:

| | why |
|---|---|
| **Accessibility** | to forward and swallow keystrokes |
| **Input Monitoring** | to see key presses at all — the one people miss |

macOS also asks once for **Local Network** access. Allow it, or crossr cannot find the
other machine. macOS does not apply a new grant to an already-running process, so if a row
stays amber after you have granted it, crossr will offer to restart itself. Take the offer.

**On Windows**, the setup screen checks the inbound firewall rule and offers a button that
fixes it. Watch the **mouse capture** row too: keyboard and mouse forwarding come from two
different Windows mechanisms, so one can work while the other never fires. Move the mouse —
if that row stays red, only the keyboard will forward.

---

## Pairing

Both machines on the same subnet, crossr running on each. They find each other over mDNS —
there is no address to type anywhere in the app.

One machine shows a **six-digit code**. Type it on the other. Once.

After that the peer is remembered by public key, and every later connection is automatic.

---

## Using it

| | |
|---|---|
| Switch machines | **Ctrl + Alt + Shift + K** |
| Or | double-tap the cursor at the bezel the other machine sits on, within 250 ms |
| Keep input here | **Ctrl + Alt + Shift + L** — pins input locally, for fullscreen games that fight for the cursor |
| Which side the peer is on | tray / menu-bar menu → **Peer is on the left / right** |

The switch hotkey is deliberately not `Ctrl+Alt+<arrow>`: Intel's graphics driver claims
that one globally and swallows it silently.

Keys travel as physical key positions, not characters — so each machine applies its own
keyboard layout. On the Mac, Command and Option are swapped by default, because a PC
keyboard puts Alt and Win where macOS wants Command and Option. Turn it off in
`settings.json` if you are using an Apple keyboard.

---

## What it will not do

- **Nothing works before the OS is up.** No BIOS, no boot picker, no lock screen, no UAC
  prompt, no FileVault unlock. Your monitor's own KVM button stays the fallback.
- **Elevated Windows windows** — UAC dialogs and some installers — do not receive
  forwarded input.
- **Both machines must be on the same subnet.**
- No clipboard sync and no file transfer yet. Input only.
- Neither installer is signed, hence the warnings above.

---

## Settings, state, and uninstalling

crossr keeps three files — the key pair, the paired-peer list, and `settings.json`:

| | |
|---|---|
| Windows | `%APPDATA%\crossr` |
| macOS | `~/Library/Application Support/crossr` |

Deleting that directory resets the app to first-run, including forgetting paired peers.

It starts at login by default, on both platforms. To uninstall: Windows,
Settings → Apps → **crossr**; macOS, drag `/Applications/crossr.app` to the trash. Both
leave the state directory alone on purpose — an uninstall/reinstall cycle should not
silently force you to re-pair.

---

## Defaults

| | |
|---|---|
| Port | 28451 (TCP), announced as `_crossr._tcp` over mDNS |
| Transport | TLS 1.3, peers pinned by public key after pairing |
| Edge crossing | double-tap within 250 ms; suppressed within 8 px of a screen corner |
| Cmd/Option swap on the Mac | on |
| Launch at login | on |
