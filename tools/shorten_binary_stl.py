#!/usr/bin/env python3
"""Shorten a binary STL along Y while preserving both end features."""

from __future__ import annotations

import argparse
import math
import struct
from pathlib import Path


TRIANGLE = struct.Struct("<12fH")


def remap_y(y: float, start: float, end: float, amount: float) -> float:
    if y <= start:
        return y
    if y >= end:
        return y - amount
    scale = (end - start - amount) / (end - start)
    return start + (y - start) * scale


def normal(a: tuple[float, float, float], b: tuple[float, float, float], c: tuple[float, float, float]) -> tuple[float, float, float]:
    ux, uy, uz = (b[i] - a[i] for i in range(3))
    vx, vy, vz = (c[i] - a[i] for i in range(3))
    nx, ny, nz = uy * vz - uz * vy, uz * vx - ux * vz, ux * vy - uy * vx
    length = math.sqrt(nx * nx + ny * ny + nz * nz)
    return (0.0, 0.0, 0.0) if length == 0 else (nx / length, ny / length, nz / length)


def shorten(source: Path, destination: Path, amount: float, start: float, end: float) -> None:
    data = source.read_bytes()
    if len(data) < 84:
        raise ValueError("File is too short to be a binary STL")
    count = struct.unpack_from("<I", data, 80)[0]
    if len(data) != 84 + count * TRIANGLE.size:
        raise ValueError("Input is not a supported binary STL")

    header = b"Standard flared holder shortened 10 mm; board and antenna ends preserved"
    output = bytearray(header[:80].ljust(80, b"\0"))
    output.extend(struct.pack("<I", count))

    for index in range(count):
        values = TRIANGLE.unpack_from(data, 84 + index * TRIANGLE.size)
        vertices = []
        for offset in (3, 6, 9):
            x, y, z = values[offset : offset + 3]
            vertices.append((x, remap_y(y, start, end, amount), z))
        nx, ny, nz = normal(*vertices)
        flattened = tuple(component for vertex in vertices for component in vertex)
        output.extend(TRIANGLE.pack(nx, ny, nz, *flattened, values[-1]))

    destination.parent.mkdir(parents=True, exist_ok=True)
    destination.write_bytes(output)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("source", type=Path)
    parser.add_argument("destination", type=Path)
    parser.add_argument("--amount", type=float, default=10.0)
    parser.add_argument("--start", type=float, default=22.25)
    parser.add_argument("--end", type=float, default=67.0)
    args = parser.parse_args()
    if not 0 < args.amount < args.end - args.start:
        parser.error("amount must be positive and smaller than the remapped span")
    shorten(args.source, args.destination, args.amount, args.start, args.end)


if __name__ == "__main__":
    main()
