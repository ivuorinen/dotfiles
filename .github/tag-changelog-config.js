module.exports = {
  types: [
    { types: ['feat', 'feature', 'Feat'], label: '🎉 New Features' },
    { types: ['fix', 'bugfix', 'Fix'], label: '🐛 Bugfixes' },
    { types: ['improvements', 'enhancement'], label: '🔨 Improvements' },
    { types: ['perf'], label: '🏎️ Performance Improvements' },
    { types: ['build', 'ci'], label: '🏗️ Build System' },
    { types: ['refactor'], label: '🪚 Refactors' },
    { types: ['doc', 'docs'], label: '📚 Documentation Changes' },
    { types: ['test', 'tests'], label: '🔍 Tests' },
    { types: ['style', 'codestyle'], label: '💅 Code Style Changes' },
    { types: ['chore', 'Chore'], label: '🧹 Chores' },
    { types: ['other', 'Other'], label: 'Other Changes' },
  ],

  excludeTypes: [],

  renderTypeSection: function (label, commits) {
    let text = `\n## ${label}\n\n`

    commits.forEach(commit => {
      const scope = commit.scope ? `**${commit.scope}:** ` : ''
      text += `- ${scope}${commit.subject}\n`
    })

    return text
  },

  renderChangelog: function (release, changes) {
    const now = new Date()
    const d = now.toISOString().substring(0, 10)
    const header = `# ${release} - ${d}\n`
    return header + changes + '\n\n'
  },
}
