# x-ssh-audit

POSIX-compliant SSH security auditing and management script for analyzing and
hardening SSH configurations across multiple hosts.

## Features

- **Security Auditing**: Analyze SSH configurations for security issues
- **Multi-Host Support**: Audit multiple servers from a single host list
- **Smart Authentication**: Automatic SSH key detection with intelligent fallback
- **Comprehensive Checks**: Password auth, root login, key auth, empty passwords,
  X11 forwarding
- **System Analysis**: Automated updates detection, pending reboot status
- **Auto-Remediation**: Optional automatic security hardening
- **Detailed Reporting**: CSV reports and comprehensive logs
- **POSIX Compliant**: Works with sh, dash, bash, ksh, zsh

## Usage

```bash
x-ssh-audit <host_list_file> [auto-remediate:yes|no]
```

### Host List File Format

```text
hostname:username[:ssh_key]
```

- `hostname` – The host to connect to (FQDN or IP address)
- `username` – SSH username for authentication
- `ssh_key` – (Optional) Path to SSH private key file

### SSH Key Authentication Priority

The script automatically tries authentication methods in this order:

1. **Specific key** (if provided in host file)
2. **Auto-detected default keys** (`~/.ssh/id_ed25519`, `id_rsa`, `id_ecdsa`,
    `id_dsa`)
3. **SSH agent or system default authentication**

This means you can mix hosts with and without specific keys, and the script will
intelligently try all available authentication methods.

## Host List Examples

```bash
# Simple format without specific SSH keys
server1.example.com:admin
192.168.1.10:root

# With specific SSH keys
production.example.com:deploy:~/.ssh/production_key
staging.example.com:staging-user:~/.ssh/staging_key
database.example.com:dbadmin:/home/user/.ssh/db_server_key

# Cloud instances with specific keys
aws-instance.compute.amazonaws.com:ec2-user:~/.ssh/aws-keypair.pem
gcp-instance.compute.google.com:ubuntu:~/.ssh/gcp-instance-key

# Mixed authentication (specific keys + fallback)
cluster-node-01.example.com:cluster-admin:~/.ssh/cluster_key
cluster-node-02.example.com:cluster-admin
cluster-node-03.example.com:cluster-admin
```

## Usage Examples

```bash
# Basic audit
x-ssh-audit hosts.txt

# Audit with automatic remediation
x-ssh-audit hosts.txt yes

# Review results
cat ./ssh-audit/20251017_143022/report.csv
tail ./ssh-audit/20251017_143022/log.log
```

## Output Structure

All output is organized in a timestamped directory:

```text
./ssh-audit/
└── 20251017_143022/
    ├── backup/          # SSH config backups from remote hosts
    ├── tmp/             # Temporary state files (auto-cleaned)
    ├── log.log          # Detailed audit log with timestamps
    └── report.csv       # Summary report with all findings
```

## Security Checks

- **Password Authentication**: Warns if password auth is enabled
- **Root Login**: Warns if root login is not disabled
- **Empty Passwords**: Error if empty passwords are permitted
- **X11 Forwarding**: Warns if X11 forwarding is enabled
- **Public Key Authentication**: Verifies key-based auth is available
- **SSH Protocol**: Checks protocol version
- **Automated Updates**: Detects if automatic updates are configured
- **Pending Reboots**: Checks if system requires reboot

## Auto-Remediation

When enabled, the script will:

1. Create backups of SSH configurations
2. Disable password authentication
3. Ensure key-based authentication is required
4. Disable root login
5. Set conservative SSH connection limits
6. Reload SSH daemon with new configuration
7. Generate updated report with remediation status

## Configuration

Fallback usernames (tried if primary user fails):

```bash
FALLBACK_USERS="root ubuntu ivuorinen"
```

Default SSH keys (automatically detected):

```bash
~/.ssh/id_ed25519
~/.ssh/id_rsa
~/.ssh/id_ecdsa
~/.ssh/id_dsa
```

SSH connection parameters:

```bash
SSH_TIMEOUT=10
SSH_RETRIES=3
```

## Requirements

- POSIX-compliant shell (sh, dash, bash, ksh, zsh)
- SSH client with key-based authentication
- `sudo` access on remote hosts for configuration changes
- Standard Unix utilities: `cut`, `grep`, `sed`, `awk`, `wc`

## Exit Codes

- `0` – Audit completed successfully
- `1` – Error occurred (check log file for details)

## CSV Report Columns

- **Timestamp**: When the host was audited
- **Hostname**: The target host
- **Username**: Connected username
- **SSH Status**: Connection status (audited, connection_failed)
- **Password Auth**: Password authentication status (yes/no)
- **Key Auth**: Public key authentication status (yes/no)
- **Root Login**: Root login permission status
- **Auto Updates**: Automated updates status
- **Reboot Required**: Pending reboot status (yes/no)
- **Security Issues**: Number of security issues found
- **Remediation**: Remediation status (none, success, failed)

## Supported Distributions

- **Debian/Ubuntu**: unattended-upgrades detection
- **RHEL/CentOS/Rocky/AlmaLinux/Fedora**: dnf-automatic and yum-cron detection
- **Other**: Basic SSH security checks

## Tips

1. **Test First**: Run without auto-remediation first to review findings
2. **Backup Keys**: Ensure you have backup SSH keys before hardening
3. **Staged Rollout**: Test on non-critical hosts first
4. **Review Logs**: Check log files for detailed information
5. **Preserve Access**: Script ensures key-based auth works before disabling
    passwords

## Version

Version: 2.0-POSIX
Date: 2025-10-17
License: MIT
Author: Ismo Vuorinen <https://github.com/ivuorinen>

<!-- vim: set ft=markdown spell spelllang=en_us cc=80 : -->
