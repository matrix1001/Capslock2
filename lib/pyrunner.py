import os
import sys
import io
import contextlib

if len(sys.argv) < 2:
    print("Usage: pyrunner.py <output_file>")
    sys.exit(1)

output_file = sys.argv[1]
if os.path.exists(output_file):
    os.remove(output_file)

code = sys.stdin.read()

buf = io.StringIO()
error = None
with contextlib.redirect_stdout(buf):
    try:
        exec(code)
    except Exception as e:
        import traceback
        error = traceback.format_exc()

print_content = buf.getvalue()
if error:
    print_content += "\n--- Exception ---\n" + error

with open(output_file, 'w', encoding='utf-8') as f:
    f.write(print_content)
