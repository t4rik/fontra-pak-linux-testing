# debian/ — repackaged-binary .deb

This wraps the official `FontraPak-Ubuntu.tgz` PyInstaller build the same way the flatpak and
snap packagings do, rather than building from source. That means:

- It inherits whatever glibc floor the upstream Ubuntu build has (currently being raised to 2.39
  in fontra/fontra-pak#276 — see `debian/control`'s `libc6 (>= 2.39)` dependency).
- It is **not** suitable for submission to Debian proper, which requires building against
  system-provided libraries rather than vendoring a PyInstaller bundle. Treat this as a local/PPA-
  style package for testing, not a path to the official Debian archive.

## Build

```sh
dpkg-buildpackage -us -uc -b
```

Pass a specific release instead of `latest`:

```sh
DEB_VERSION_UPSTREAM=2026.9.0 dpkg-buildpackage -us -uc -b
```

## TODO

- [ ] Add a `.desktop` file and icon (see `fontra-pak`'s own `icon/` and `xyz.fontra.FontraPak.desktop`
  in the flatpak repo for reference) so it shows up in the app launcher.
- [ ] Add `postinst`/`prerm` if any desktop-database update is needed.
- [ ] Decide whether to track `latest` automatically (like the flatpak/snap CI do) or pin releases
  manually.
