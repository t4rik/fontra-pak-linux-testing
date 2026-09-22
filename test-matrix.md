# Test matrix

Manual results. The CI smoke test (`.github/workflows/smoke-test.yml`) covers "does it launch
without crashing"; titlebar/decoration behavior still needs eyes on a real desktop session, so
that column stays manual for now.

| Distro       | Binary built on | Forced XCB | Crashes (#268) | Titlebar shown (#271) | Notes |
|--------------|------------------|------------|-----------------|------------------------|-------|
| Debian 13    | ubuntu-22.04     | yes        | yes (SIGSEGV)   | —                       | libxkbcommon/glibc mismatch |
| Fedora 44    | ubuntu-22.04     | yes        | yes (SIGSEGV)   | —                       | same |
| Ubuntu 24.04 | ubuntu-22.04     | yes        | yes (SIGSEGV)   | —                       | same |
| Debian 13    | ubuntu-24.04     | yes        | no              | yes                     | clean run |
| Fedora 44    | ubuntu-24.04     | yes        | no              | yes                     | clean run |
| Ubuntu 24.04 | ubuntu-24.04     | yes        | no              | yes                     | clean run |
| Debian 13    | ubuntu-22.04     | no (native Wayland) | n/a    | no                      | no window controls at all |
| Fedora 44    | ubuntu-22.04     | no (native Wayland) | n/a    | no                      | same |
| Debian 13    | ubuntu-24.04     | no (native Wayland) | n/a    | partial (move/close, not Adwaita-styled) | |
| Fedora 44    | ubuntu-24.04     | no (native Wayland) | n/a    | partial (move/close, not Adwaita-styled) | |

Rows above reflect the testing that backs fontra/fontra-pak#276 and fontra/fontra-pak#271.
Add new rows below as more combinations get tested (e.g. flatpak build once
`flatpak-from-source/` actually builds, or `debian/` package once it's usable).

## To test next

- [ ] `debian/` package: install and launch on a real Debian 13 / Ubuntu 24.04 desktop
- [ ] flatpak from source, once `flatpak-from-source/NOTES.md` blockers are cleared
- [ ] Fedora 44 native Wayland titlebar behavior with `QT_WAYLAND_DECORATION=adwaita` set
  manually, as one of the proposed fixes in fontra/fontra-pak#271
