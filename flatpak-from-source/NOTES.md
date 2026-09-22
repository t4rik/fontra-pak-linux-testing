# from-source flatpak - status

Manifest now builds a real dependency graph, not a skeleton. Not yet run through an actual
`flatpak-builder` (needs a real flatpak/OSTree environment this sandbox doesn't have) - so
"resolves cleanly on paper" is confirmed, "actually builds and launches" is not.

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

1. **Never actually run through `flatpak-builder`.** The dependency graph resolving is necessary
   but not sufficient - build-time errors (missing system headers for a compiled wheel's
   fallback path, a `pip3 install --no-deps` picking up an incompatible version some other
   module already installed, etc.) won't show up until it's tried for real.
2. **Runtime behavior unverified.** Once it does build: does `FontraPakMain.py` actually launch
   correctly using `org.kde.Platform`'s Qt via the BaseApp, versus the bundled-Qt PyQt6 wheel the
   official Ubuntu tarball uses? Same question for the #268/#271 findings in `test-matrix.md` -
   no reason to expect different behavior since Flatpak's runtime isolation is the same either
   way, but "no reason to expect" isn't "confirmed."
3. **`--filesystem=host` in `finish-args`** is broad (copied over from the tarball-repackaging
   manifest). Worth narrowing once there's a working build to test permissions against - Fontra
   Pak needs to open/save font files from arbitrary locations, so some host access is probably
   unavoidable, but "the whole host filesystem" may be more than necessary.
4. **No decision yet on whether this replaces the tarball-repackaging approach upstream uses.**
   Even if it builds and works, it's a heavier manifest with more moving parts (six modules deep
   vs. one archive download) to maintain. Worth it only if it demonstrably fixes something the
   simple approach can't - test side-by-side once both are running.
