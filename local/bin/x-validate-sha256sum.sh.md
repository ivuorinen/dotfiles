# x-validate-sha256sum.sh

This script contains a helper for sha256 validating your downloads

## Usage

```bash
x-validate-sha256sum.sh file sha256sum
```

The script computes the SHA256 hash of `file` and compares it to the
expected value. It exits non-zero if the sums differ.

<!-- vim: set ft=markdown spell spelllang=en_us cc=80 : -->
