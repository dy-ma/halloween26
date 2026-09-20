#!/usr/bin/env python3
# SPDX-License-Identifier: MIT
"""Refill a build copy using KiCad's Python interpreter, never the source board."""
import sys
import pcbnew

board = pcbnew.LoadBoard(sys.argv[1])
nets = {item.m_Uuid.AsString(): item.GetNetname() for item in board.GetTracks()}
pcbnew.ZONE_FILLER(board).Fill(board.Zones())
for item in board.GetTracks():
    if item.GetNetname() != nets[item.m_Uuid.AsString()]:
        raise RuntimeError("Zone fill changed a track/via net: " + item.m_Uuid.AsString())
pcbnew.SaveBoard(sys.argv[1], board)
