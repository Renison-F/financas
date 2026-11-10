"""Reads the log of integration_test/tools/ocr_dump_test.dart and writes one JSON per photo into
test/fixtures/labels/. Usage: python tool/ocr_fixtures.py <log file>"""
import base64
import collections
import io
import json
import os
import re
import sys

chunks = collections.OrderedDict()
for line in io.open(sys.argv[1], encoding='utf-8', errors='replace'):
    m = re.search(r'OCRJSON\|([^|]+)\|([A-Za-z0-9+/=]+)', line)
    if m:
        chunks.setdefault(m.group(1), []).append(m.group(2))

os.makedirs('test/fixtures/labels', exist_ok=True)
for name, parts in chunks.items():
    data = json.loads(base64.b64decode(''.join(parts)).decode('utf-8'))
    out = os.path.join('test/fixtures/labels', re.sub(r'\.jpe?g$', '', name, flags=re.I) + '.json')
    with io.open(out, 'w', encoding='utf-8', newline='\n') as f:
        json.dump(data, f, ensure_ascii=False, indent=1)
        f.write('\n')
    print(out, len(data['lines']), 'linhas')
