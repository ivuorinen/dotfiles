# gh-set-profile

Auto-apply a git profile based on the current repository's path.

## Usage

```
gh-set-profile
```

No arguments. Run from inside a git repository (or any subdirectory of one).

## Behaviour

| Condition                           | Result                 |
|-------------------------------------|------------------------|
| Not inside a git repo               | exits 0, no output     |
| Inside a repo with no matching path | exits 0, no output     |
| `~/Code/ivuorinen/**`               | applies `home` profile |
| `~/Code/masf-fi/**`                 | applies `masf` profile |
| `~/Code/s/**`                       | applies `work` profile |

Profile switching is delegated to `git profile use <name>`
([dotzero/git-profile](https://github.com/dotzero/git-profile)).

## Integration

Add to shell init or call from a cd-hook to auto-switch profiles
when entering project directories. Complements `x-gitprofile`, which
writes mise `enter` hooks for the same purpose.
