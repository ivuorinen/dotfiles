/**
 * Almost Maximize
 * Almost maximizes the window to the screen, leaving a small margin.
 *
 * @author Ville Viklund <https://github.com/ville6000>
 *
 * @param {Object} windows - All windows in the current space.
 * @param {Object} screenFrame - The frame of the current screen.
 * @return {Object} - The frames for the windows in the current space.
 */
function layout() {
  return {
    name: 'Almost Maximize',
    getFrameAssignments: (windows, screenFrame) => {
      const width = screenFrame.width * 0.95
      const height = screenFrame.height * 0.95
      const x = (screenFrame.width - width) / 2
      const y = (screenFrame.height - height) / 2
      const windowFrames = {}

      windows.forEach((window) => {
        windowFrames[window.id] = {
          Y: screenFrame.y + y,
          x: screenFrame.x + x,
          width,
          height,
        }
      })

      return windowFrames
    },
  }
}

module.exports = layout()
