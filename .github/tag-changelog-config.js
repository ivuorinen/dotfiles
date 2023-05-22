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

  excludeTypes: ['other'],

  renderTypeSection: function (label, commits) {
    let text = `\n## ${ label }\n`

    commits.forEach((commit) => {
      text += `- ${ commit.subject }\n`
    })

    return text
  },

  renderChangelog: function (release, changes) {
    const now = new Date()
    return `# ${ release } - ${ now.toISOString().substring(0, 10) }\n` + changes + '\n\n'
  },
}
