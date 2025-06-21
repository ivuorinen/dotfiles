# x-thumbgen

Generate thumbnails using ImageMagick (magick) with MIME type filtering.

## Usage

```bash
x-thumbgen [options] source_directory
```

Options:

- `-o DIR` – output directory (default: same as source)
- `-s STR` – suffix for thumbnails
- `-h` – show help

Environment variables like `THUMB_BACKGROUND` control the image
dimensions.

### Example

```bash
THUMB_BACKGROUND=black x-thumbgen -o ~/thumbs ~/images
```

<!-- vim: set ft=markdown spell spelllang=en_us cc=80 : -->
