# Shared release conventions

Releases are prepared manually. This repository has no GitHub Actions release workflow.

## Keep sources in Git; attach generated files to releases

Commit editable design files, local libraries, documentation, and selected previews. Generate Gerbers, drills, BOMs, placement files, and check reports into the ignored `build/<board-name>/` directory. Attach the intended outputs to a [GitHub Release](https://github.com/dy-ma/halloween26/releases) after reviewing them.

A typical board release includes:

- A bare-PCB Gerber/drill ZIP.
- A review package with a schematic PDF, checks, tool version, and source commit.
- Assembly BOM/placement files only when prepared and reviewed for the chosen assembler.
- Checksums, if supplied by the board's export helper.

GitHub also provides source archives for the tagged commit.

## Version each board independently

Use tags that name the board, such as `base-controller-v0.1.0`. Another board can have its own version and release schedule without incrementing the base controller's version.

Create the release from the exact commit used to export its files. Describe the board's physical revision, fabrication choices, checks, hardware-testing status, and known limitations. Use a pre-release for an untested prototype. If manufacturing data changes, create a new tag/release rather than replacing previously ordered files silently.

A tag captures the entire repository, while its name and attachments identify the board being released.

## Board-specific procedures

- [Base controller: verification](../base-controller/docs/verification.md) and [export/release instructions](../base-controller/docs/releases.md).
- [Baby's first PCB](../babys-first/README.md) is a practice board with no planned manufacturing release.

Each new board should document its own checks and export procedure. The base controller's helper is specific to that design and does not automatically package other boards.
