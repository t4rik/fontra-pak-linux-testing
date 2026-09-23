# from-source flatpak - status

Has now actually been run through `flatpak-builder` in CI (`.github/workflows/flatpak-from-source-build.yml`),
not just resolved on paper. First real run failed with a genuine, specific error - fixed below,
not yet re-verified.

## Resolved

- **PyQt6**: `flatpak_pip_generator` refuses PyQt requirements outright and points at
  [`com.riverbankcomputing.PyQt.BaseApp`](https://github.com/flathub/com.riverbankcomputing.PyQt.BaseApp),
  Flathub's standard base for PyQt apps. Branch `6.7` matches fontra-pak's `PyQt6==6.7.1` pin.
  Using it as `base`/`base-version` means Qt itself comes from the BaseApp, built against
  `org.kde.Platform`, not from a bundled-Qt wheel.
- **The four git dependencies** (`fontra`, `fontra-compile`, `fontra-rcjk`, `fontra-glyphs`) are
  each their own `type: git` module now, `pip3 install --no-build-isolation --no-deps`. `fontra`
  pins to tag `2026.9.0`; the other three have no tags upstream at all, so they're pinned to
  their HEAD commit as of 2026-09-22 instead - re-check `git ls-remote` before relying on this.
- **Every transitive PyPI dependency** (`cattrs`, `fonttools`, `watchfiles`, `pyyaml`,
  `ufomerge`, `skia-pathops`, `pillow`, `ufo2ft`, `fontmake`, `fontc`, `cffsubr`, `glyphsLib`,
  plus `aiohttp`/`psutil`/`certifi` from fontra-pak's own requirements.txt) resolved to prebuilt
  manylinux wheels via `flatpak_pip_generator`, including the compiled ones (`skia-pathops`,
  `fontc`, `lxml`) - no from-source builds needed for any of them. Pinned with real sha256 hashes
  in `shared-modules-pip-deps.json` (15 modules, generated, not hand-written).
- **fontra-pak itself has no `pyproject.toml`** - `FontraPakMain.py` is run directly, PyInstaller
  is what turns it into the official binary. So the `fontrapak` module doesn't `pip install`
  fontra-pak; it copies `FontraPakMain.py` into `/app/lib/fontrapak/` and writes a `/app/bin/fontrapak`
  launcher script that execs it with `python3`.

## Still open

1. **Second CI build attempt failed too, now fixed, not yet re-verified.** First attempt failed
   on `python3-fonttools` (PEP 639 license metadata, see above) - fixed by adding
   `python3-setuptools` as the first module. That fix's own build then failed differently:
   `pip install --prefix=${FLATPAK_DEST}` still saw the SDK's existing system `setuptools` (at
   `/usr/lib/python3.11/site-packages`, read-only in the SDK image) and tried to uninstall it
   first - `OSError: [Errno 30] Read-only file system`. Added `--ignore-installed` to the
   `python3-setuptools` module (tells pip to just install into `--prefix` without checking/
   uninstalling what it sees elsewhere on `sys.path`), and defensively to the four git modules
   too, since they hit the same install pattern. Not yet re-run to confirm.
2. **`org.kde.Sdk`/`org.kde.Platform` 6.7 and `com.riverbankcomputing.PyQt.BaseApp` 6.7 are
   flagged end-of-life** in the CI build log ("Branch 6.7 of the PyQt base application is no
   longer supported. Please use 6.8 instead."). Building against an EOL runtime isn't a
   correctness problem today, but it means this manifest is already behind - worth bumping
   `runtime-version`/`base-version` to `6.8` once 6.7 is confirmed working, rather than
   compounding two changes into one debugging session.
3. **`com.riverbankcomputing.PyQt.BaseApp` pulls in `io.qt.qtwebengine.BaseApp`** (confirmed by
   reading the BaseApp's own manifest) - meaning this build includes a full Chromium-based
   QtWebEngine even though fontra-pak's own `FontraPakMain.py` never imports
   `PyQt6.QtWebEngineWidgets`. That's dead weight (bundle size, build time) fontra-pak doesn't
   need. No plain-PyQt6-without-WebEngine BaseApp currently exists on Flathub as an alternative;
   worth deciding whether that's worth pursuing upstream or just accepted as the cost of using
   the standard BaseApp.
4. **Runtime behavior still unverified** - once the build itself succeeds, does
   `FontraPakMain.py` actually launch and behave the same as the tarball-repackaging path for
   the #268/#271 findings in `test-matrix.md`? No reason to expect different behavior, but
   unconfirmed.
5. **`--filesystem=host` in `finish-args`** is broad (copied over from the tarball-repackaging
   manifest). Worth narrowing once there's a working build to test permissions against.
6. **No decision yet on whether this replaces the tarball-repackaging approach upstream uses.**
   Even once it builds and works, it's a heavier manifest with more moving parts to maintain,
   and now carries an unwanted QtWebEngine dependency the simple approach doesn't. Worth it only
   if it demonstrably fixes something the simple approach can't.
