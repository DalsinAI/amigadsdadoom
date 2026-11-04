#!/usr/bin/env python3
# Prints rdatawad's arguments for dsda-doom.wad, read from upstream's own
# prboom2/data/CMakeLists.txt (its set() lists and WAD_CMDLINE), so the
# Amiga build makes the same resource WAD as CMake does without CMake.
#   python3 amiga/wadargs.py prboom2/data/CMakeLists.txt
import re
import shlex
import sys

text = open(sys.argv[1]).read()
text = re.sub(r'#[^\n]*', '', text)
var = {}


def expand(words):
    out = []
    for w in words:
        m = re.fullmatch(r'\$\{(\w+)\}', w)
        if m:
            out.extend(var.get(m.group(1), []))
        else:
            out.append(w)
    return out


for name, body in re.findall(r'set\(\s*(\w+)\s+(.*?)\)', text, re.S):
    var[name] = expand(shlex.split(body))

print(' '.join(shlex.quote(w) for w in var['WAD_CMDLINE']))
