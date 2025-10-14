import os
import sys
import io
import contextlib

if len(sys.argv) < 3:
    print("Usage: pyrunner.py <output_file> <code>")
    sys.exit(1)

output_file = sys.argv[1]
if os.path.exists(output_file):
    os.remove(output_file)
code = sys.argv[2]
# 反转义
code = bytes(code, "utf-8").decode("unicode_escape")

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

