# from-source flatpak — status

Not building yet. Main blockers, in the order they'll actually bite:

1. **PyQt6 as a flatpak module.** PyQt6 wheels bundle their own Qt6 build, which flatpak-builder
   doesn't want (it wants to link against the runtime's Qt). Either:
   - accept the bundled-Qt wheel via `flatpak-pip-generator` and don't switch the runtime
     (keeps `org.freedesktop.Platform`), or
   - patch/rebuild PyQt6 against the SDK's own Qt6 (`org.kde.Sdk`) for a "proper" from-source
     build — more correct, much more work.
   Haven't decided which; the manifest currently assumes the second without having tried it.

2. **Four git dependencies** (`fontra`, `fontra-compile`, `fontra-rcjk`, `fontra-glyphs`) each
   need their own pinned `type: git` module with a `tag` or `commit`, not `branch: main`.

3. **`flatpak-pip-generator` output** for the remaining PyPI deps (`aiohttp`, `psutil`,
   `certifi`, `setuptools`) isn't generated yet — needs to be run and the resulting JSON added
   as a module.

4. Once it builds, compare against the current tarball-repackaging manifest for: binary size,
   build time, and whether the SIGSEGV/#268 and titlebar/#271 behavior differs at all (shouldn't,
   in theory, since the environment is Flatpak's runtime either way — but worth confirming rather
   than assuming).

If this doesn't end up being worth the added build complexity over the tarball-repackaging
approach upstream already uses, that's a valid outcome too — the point of testing it is to find
out, not to force it in.
