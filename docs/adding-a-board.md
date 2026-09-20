# Adding a board

Give each board a descriptive top-level directory, alongside `base-controller/` and `babys-first/`. It belongs to this Git repository; do not create a nested `.git` directory.

A small board may need only a README and its KiCad files. As it grows, use this structure:

```text
board-name/
├── README.md
├── CHANGELOG.md
├── board-name.kicad_pro
├── board-name.kicad_sch
├── board-name.kicad_pcb
├── fp-lib-table              If custom footprints are used
├── sym-lib-table             If custom symbols are used
├── libraries/                Board-local library files and provenance
├── docs/                     Architecture, parts, verification, release notes
│   └── history/              Earlier design notes, clearly marked as historical
├── previews/                 Selected images useful in documentation
└── scripts/                  Optional helpers specific to this board
```

The board README should explain its purpose, current readiness, required KiCad version, how to open it, and where its design and verification notes are. Keep sourcing/parts lists, pinouts, electrical decisions, and mechanical details under that board's `docs/` rather than at repository root.

Use `${KIPRJMOD}` paths for project-local libraries. Keep custom libraries with their board initially; promote a library to a shared location only when boards actually reuse it. Record imported material and its license in the library documentation and repository `NOTICE.md`.

Keep generated output under the repository's ignored `build/<board-name>/` directory. Backups, editor lock files, caches, local settings, and credentials should stay out of Git. Check `git status` before committing imported projects, especially projects created outside this repository.

Finally, add the board to the project table in the [root README](../README.md). Releases use the [shared naming convention](releases.md), but each board has its own verification and manufacturing requirements.
