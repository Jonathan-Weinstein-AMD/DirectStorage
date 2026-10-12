#!/usr/bin/env python3
"""Rewrite `UAV[COORD_EXPR]` as `DEREF(UAV, (COORD_EXPR))` in zstdgpu_shaders.h, in-place.

A UAV is a `[A-Za-z0-9_.]+` string that either:
  - starts with `srt.inout`, or
  - is a `Name` whose most recent `ZSTDGPU_*_BUFFER*(...) Name` declaration is a RW one.
"""

import os
import re
import sys

DECL_RE = re.compile(r'\bZSTDGPU_(RW|RO)_\w*BUFFER\w*\s*\([^()]*\)\s*([A-Za-z_]\w*)')
INDEX_RE = re.compile(r'(?<![\w.])([A-Za-z_][\w.]*)\[')


def find_closing_bracket(text, open_pos):
    depth = 0
    for i in range(open_pos, len(text)):
        if text[i] == '[':
            depth += 1
        elif text[i] == ']':
            depth -= 1
            if depth == 0:
                return i
    raise ValueError('unbalanced [ at offset %d' % open_pos)


class Rewriter:
    def __init__(self):
        self.is_uav_by_name = {}
        self.count = 0

    def is_uav(self, name):
        return name.startswith('srt.inout') or self.is_uav_by_name.get(name, False)

    def rewrite(self, text):
        out = []
        pos = 0
        while pos < len(text):
            decl = DECL_RE.search(text, pos)
            index = INDEX_RE.search(text, pos)
            if decl is None and index is None:
                break
            if index is None or (decl is not None and decl.start() <= index.start()):
                self.is_uav_by_name[decl.group(2)] = decl.group(1) == 'RW'
                out.append(text[pos:decl.end()])
                pos = decl.end()
                continue

            name = index.group(1)
            open_pos = index.end() - 1
            if not self.is_uav(name):
                out.append(text[pos:index.end()])
                pos = index.end()
                continue

            close_pos = find_closing_bracket(text, open_pos)
            coord = self.rewrite(text[open_pos + 1:close_pos])
            out.append(text[pos:index.start()])
            out.append('DEREF(%s, (%s))' % (name, coord))
            self.count += 1
            pos = close_pos + 1
        out.append(text[pos:])
        return ''.join(out)


def main():
    path = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'zstdgpu_shaders.h')
    with open(path, 'r', newline='') as f:
        src = f.read()

    rewriter = Rewriter()
    dst = rewriter.rewrite(src)

    with open(path, 'w', newline='') as f:
        f.write(dst)

    print('%s: %d replacements' % (path, rewriter.count))
    return 0


if __name__ == '__main__':
    sys.exit(main())
