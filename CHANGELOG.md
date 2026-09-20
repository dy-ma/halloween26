# Changelog

## Unreleased — base controller Rev A

- Initial ESP32-C6 motion-controller schematic and two-layer PCB routing.
- 24 V input/pass-through, TPS26600 logic-branch protection, and LMR51420 5 V converter.
- External STEP/DIR/ENA interface, two contact-limit inputs, user button, spare GPIO, and test pads.
- Mounting holes, USB power-selection shunt, operating-reference silkscreen, and documentation QR.
- Portable project libraries, manual release process, local check/export helper, and licensing notices.

- U3 thermal-via footprint updated to 0.30 mm holes / 0.60 mm pads; ERC, DRC, and schematic/PCB parity now pass.

No manufacturing release or hardware validation yet. The [verification checklist](docs/verification.md), including thermal-pad assembly review, remains open.
