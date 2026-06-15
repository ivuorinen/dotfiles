-- Detect yaml.ansible filetype by directory path conventions.
-- ansible-language-server uses this compound type to activate.
vim.filetype.add {
  pattern = {
    ['.*/playbooks?/.*%.ya?ml'] = 'yaml.ansible',
    ['.*/roles/.*/.*%.ya?ml'] = 'yaml.ansible',
    ['.*/handlers/.*%.ya?ml'] = 'yaml.ansible',
    ['.*/tasks/.*%.ya?ml'] = 'yaml.ansible',
    ['.*/group_vars/.*%.ya?ml'] = 'yaml.ansible',
    ['.*/host_vars/.*%.ya?ml'] = 'yaml.ansible',
    ['playbook.*%.ya?ml'] = 'yaml.ansible',
    ['site%.ya?ml'] = 'yaml.ansible',
    ['ansible%.cfg'] = 'dosini',
  },
}
