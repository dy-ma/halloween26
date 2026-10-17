# Halloween 2026

Hardware, software, and build notes for our Halloween 2026 props. This repository holds multiple boards and projects; each has its own directory, README, and design status.

## Projects

| Project | Purpose | Status |
|---|---|---|
| [Base controller](base-controller/README.md) | ESP32-C6 controller for the tractor mechanism, with external stepper-driver control, limit inputs, and onboard power conversion | Initial PCB design complete; verification in progress; not hardware-tested |
| [Baby's first PCB](babys-first/README.md) | Small LED board used to learn KiCad | Practice project; not intended for manufacture |
| [FX audio](fx/README.md) | Rust library providing play-a-file-on-a-device, plus a thin CLI for PipeWire and Bluetooth testing | Initial programmable primitive |
| [Cue firmware](firmware/README.md) | Shared cue messages and non-blocking ESP-NOW transport for button nodes and the Pi serial gateway | Initial refactor; hardware verification pending |

Additional boards can be added alongside these when ready. See [adding a board](docs/adding-a-board.md) for the directory convention.

## Repository layout

```text
halloween26/
├── README.md                 Project index
├── docs/                     Shared repository and release conventions
├── base-controller/
│   ├── README.md             Board overview and status
│   ├── CHANGELOG.md          Board revision notes
│   ├── *.kicad_*             Editable KiCad design
│   ├── docs/                 Architecture, parts, checks, and design history
│   ├── libraries/            Board-specific symbols and footprints
│   ├── previews/             Selected design images
│   └── scripts/              Board-specific build helpers
├── babys-first/              KiCad practice board
├── LICENSE                   Original hardware/design-documentation license
├── LICENSES/                 Additional license texts
└── NOTICE.md                 Attribution and third-party terms
```

Board-specific decisions and instructions belong with that board. The root `docs/` folder is for guidance shared across projects. Open a board's README for its KiCad version, pinouts, build commands, and verification status.

## Releases

Editable sources live in Git. Gerbers, drill files, and other generated manufacturing files are attached manually to [GitHub Releases](https://github.com/dy-ma/halloween26/releases), using board-specific tags such as `base-controller-v0.1.0`. There are no automatic release workflows.

See [the shared release conventions](docs/releases.md) and each board's release instructions. A design being present here does not mean it is ready to manufacture; check that project's status first.

## License

Original hardware and design documentation: [CERN-OHL-P-2.0](LICENSE). Original scripts: [MIT](LICENSES/MIT.txt). Imported libraries retain their upstream terms; see [NOTICE.md](NOTICE.md).
