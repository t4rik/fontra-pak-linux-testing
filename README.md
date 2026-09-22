# fontra-pak-linux-testing

Cross-distro packaging and compatibility testing for [Fontra Pak](https://github.com/fontra/fontra-pak),
separate from the official [`t4rik/fontra-pak`](https://github.com/t4rik/fontra-pak) and
[`t4rik/fontra-flatpak`](https://github.com/t4rik/fontra-flatpak) forks so exploratory work here
doesn't clutter those PR-staging branches.

## What's here

- **`debian/`** — starter `.deb` packaging that repackages the official `FontraPak-Ubuntu.tgz`
  release binary (same approach the flatpak and snap packagings use), rather than a from-scratch
  Debian source package. Good enough for local install/testing; not policy-compliant for
  submission to Debian proper (that would require building against system-provided PyQt6, not a
  PyInstaller bundle).
- **`flatpak-from-source/`** — a manifest skeleton for building Fontra Pak from source inside the
  Flatpak sandbox, instead of downloading the prebuilt tarball like upstream's
  `xyz.fontra.FontraPak.yml` does. Unfinished on purpose — see the TODOs in the manifest.
- **`.github/workflows/`** — a test matrix that smoke-tests the current release tarball across
  Debian 13, Fedora 44, and Ubuntu 24.04 containers headlessly (via `xvfb`), so distro-compat
  claims (glibc floor, titlebar behavior) are reproducible instead of anecdotal.
- **`test-matrix.md`** — running log of manual test results per distro/release, referenced from
  fontra-pak issues/PRs (e.g. fontra/fontra-pak#276, fontra/fontra-pak#271, fontra/fontra-pak#268).

## Why a from-source flatpak build

Upstream's flatpak just repackages the prebuilt Ubuntu tarball. That's simple and already works,
but it means the flatpak inherits whatever the PyInstaller/Ubuntu build produces (including any
future glibc/toolchain quirks). Building from source inside the Flatpak sandbox would decouple
the flatpak from the Ubuntu build entirely. This is exploratory — not proposed as a replacement
for upstream's manifest unless it turns out to be worth it.

## Status

Early scaffold. Nothing here is upstreamed yet. Findings that prove out get ported as normal
feature branches into the real forks and PR'd upstream from there.
