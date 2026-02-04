# install-npm-packages

Install npm packages defined in the script.

## Usage

```bash
scripts/install-npm-packages.sh
```

## What it does

1. Checks that `npm` is available.
2. Installs each package from the inline list using `npm install -g`.
3. Upgrades all global packages.
4. Cleans the npm cache.

To add or remove packages, edit the `packages` array in `scripts/install-npm-packages.sh`.
