# Interesting folders

## XDG

XDG is a set of specifications that provide a standard for the organization
of user-specific files and directories. It is based on the _XDG Base Directory Specification_.

### XDG_BIN_HOME (`$HOME/.local/bin`)

`$XDG_BIN_HOME` defines directory that contains local binaries.

User-specific executable files may be stored in `$HOME/.local/bin`.
Distributions should ensure this directory shows up in the UNIX `$PATH`
environment variable, at an appropriate place.

### XDG_DATA_HOME (`$HOME/.local/share`)

`$XDG_DATA_HOME` defines the base directory relative to which
user-specific _data files_ should be stored.

If `$XDG_DATA_HOME` is either not set or empty,
a default equal to `$HOME/.local/share` should be used.

### XDG_CONFIG_HOME (`$HOME/.config`)

`$XDG_CONFIG_HOME` defines the base directory relative to which
user-specific _configuration files_ should be stored.

If `$XDG_CONFIG_HOME` is either not set or empty,
a default equal to `$HOME/.config` should be used.

### XDG_STATE_HOME (`$HOME/.local/state`)

`$XDG_STATE_HOME` defines the base directory relative to which
user-specific _state files_ should be stored.

If `$XDG_STATE_HOME` is either not set or empty,
a default equal to `$HOME/.local/state` should be used.

The `$XDG_STATE_HOME` contains _state data_ that should
_persist between (application) restarts_, but that is not important or
portable enough to the user that it should be stored in `$XDG_DATA_HOME`.

- It may contain:
  - actions history (logs, history, recently used files, …)
  - current state of the application that can be reused
    on a restart (view, layout, open files, undo history, …)

### XDG_DATA_DIRS

`$XDG_DATA_DIRS` defines the preference-ordered set of base directories
to search for data files in addition to the `$XDG_DATA_HOME` base directory.
The directories in `$XDG_DATA_DIRS` should be separated with a colon ':'.
