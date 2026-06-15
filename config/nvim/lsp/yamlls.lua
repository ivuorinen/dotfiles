-- Schemastore URL builder. compose-spec lives outside schemastore and
-- stays as its own local (the URL also exceeds the 90-char inline limit).
local function ss(name) return 'https://json.schemastore.org/' .. name .. '.json' end
local SCHEMA_COMPOSE = 'https://raw.githubusercontent.com/compose-spec/'
  .. 'compose-spec/master/schema/compose-spec.json'

return {
  settings = {
    -- redhat.telemetry is read top-level by yaml-language-server
    redhat = { telemetry = { enabled = false } },
    yaml = {
      schemaStore = {
        enable = true,
        url = 'https://www.schemastore.org/api/json/catalog.json',
      },
      schemas = {
        [ss 'github-workflow'] = {
          '.github/workflows/*.yml',
          '.github/workflows/*.yaml',
        },
        [ss 'github-action'] = {
          '.github/action.yml',
          '.github/action.yaml',
        },
        [SCHEMA_COMPOSE] = {
          'docker-compose*.yml',
          'docker-compose*.yaml',
          'compose*.yml',
          'compose*.yaml',
        },
        [ss 'pre-commit-config'] = '.pre-commit-config.y*ml',
        [ss 'yamllint'] = {
          '.yamllint',
          '.yamllint.yml',
          '.yamllint.yaml',
        },
      },
    },
  },
}
