"""Lossless JPEG entropy optimization for web and native release assets.

Requires libjpeg-turbo-progs (jpegtran). No resizing, requantization,
metadata removal, path changes or optional online dependencies at runtime.
"""
import subprocess
from pathlib import Path

saved = 0
count = 0
for path in sorted(Path('assets/images').rglob('*.jpg')):
    original = path.stat().st_size
    optimized = subprocess.check_output([
        'jpegtran', '-copy', 'all', '-optimize', '-progressive', str(path),
    ])
    if len(optimized) < original:
        path.write_bytes(optimized)
        saved += original - len(optimized)
        count += 1
print(f'Losslessly optimized {count} JPEGs; saved {saved:,} bytes')
