# Copyright, licenses, and attribution

Copyright © 2026 Dylan Ang.

Original hardware design and its design documentation in this repository are licensed under **CERN-OHL-P-2.0**, as provided in [LICENSE](LICENSE). Original build scripts in each board’s `scripts/` directory are licensed under **MIT**, as provided in [LICENSES/MIT.txt](LICENSES/MIT.txt).

Source location: https://github.com/dy-ma/halloween26

The design is provided without warranty. See the applicable license for its terms. The current prototype has not been tested on hardware; see [verification status](base-controller/docs/verification.md).

## Third-party library material

The project license does not replace the licenses of imported symbols, footprints, or other third-party material, including their copies embedded by KiCad in schematic/PCB files.

- **Seeed Studio / OPL KiCad Library:** XIAO ESP32-C6 symbol and footprint originate in [Seeed's library](https://github.com/Seeed-Studio/OPL_Kicad_Library). Its [upstream license](https://github.com/Seeed-Studio/OPL_Kicad_Library/blob/master/LICENSE) is CC-BY-SA-4.0; the license text is retained in [LICENSES/CC-BY-SA-4.0.txt](LICENSES/CC-BY-SA-4.0.txt). Local adaptations retain these terms. Changes include KiCad 9 symbol compatibility/properties and moving footprint artwork from silkscreen to fabrication; pin geometry is preserved.
- **KiCad library contributors:** the LMR51420 symbol is adapted from `Regulator_Switching:LMR51430`; other standard symbols/footprints are supplied by KiCad. CC-BY-SA-4.0 with the [KiCad library exception](LICENSES/KiCad-library-exception.md). Imported library material retains its upstream terms.
- **Adam Greig, agg-kicad:** unused alternative PA footprints `B02B-PASK` and `B06B-PASK` are adapted from agg-kicad. The original [MIT notice](base-controller/libraries/LICENSE-agg-kicad.txt) is retained.
- **Documentation QR:** the vector artwork was generated using KiCad's bundled MIT-licensed `kicad_qrcode` encoder, originally by Kazuhiko Arase. Encoder source is not vendored here.

Detailed provenance, source links, and modifications are in [the library README](base-controller/libraries/README.md). Product names and trademarks remain with their respective owners.
