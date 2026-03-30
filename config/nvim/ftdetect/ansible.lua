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
    ['ansible%.cfg'] = 'yaml.ansible',
  },
}
