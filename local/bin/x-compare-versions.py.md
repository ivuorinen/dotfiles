# x-compare-versions.py

Compare version strings using Python's packaging library.

## Usage

```bash
echo "1.2.3 >= 1.0.0" | x-compare-versions.py
```

The script reads comparison expressions from standard input and exits
with status 0 if all comparisons are true.

<!-- vim: set ft=markdown spell spelllang=en_us cc=80 : -->
