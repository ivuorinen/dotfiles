-- ╭─────────────────────────────────────────────────────────╮
-- │                 Hammerspoon config file                 │
-- ╰─────────────────────────────────────────────────────────╯
-- init.lua — Pure Hammerspoon window controls
-- Converted from skhdrc logic; expanded with per‑display grids,
-- app rules with groups, wrap‑around focus, cross‑display moves,
-- and overlay/notification toggles.
-- Author: Ismo Vuorinen (ivuorinen)

--------------------------------------------------
-- Caps Lock as Meh key (Shift+Control+Alt)
--------------------------------------------------
-- Prerequisites:
-- 1. Go to System Settings → Keyboard → Keyboard Shortcuts → Modifier Keys
-- 2. Set Caps Lock to "No Action" (you mentioned you already did this)
-- 3. Install Karabiner-Elements: brew install --cask karabiner-elements
-- 4. Open Karabiner-Elements, go to "Simple Modifications"
-- 5. Add: caps_lock → f18
--
-- Then you can use F18 as your Meh key in Hammerspoon!

-- F18 is now the new meh key, or something like that.
--
--  Misc binds:
--    F18 + v =   write clipboard contents (skips paste protection)
--
--  Window size & position:
--    F18 + u       = 1/3
--    F18 + i       = 2/3
--    F18 + o       = 3/3
--    F18 + y       = 2/3 from left
--    F18 + p       = 2/3 from right
--    F18 + left    = 1/2 from left
--    F18 + right   = 1/2 from right
--    F18 + j/up    = maximize
--    F18 + k/down  = center to window (dynamic sizing)
--
--  Cycling through windows:
--    F18 + h         = cycle backwards
--    F18 + l         = cycle forwards
--
--  Moving to screens:
--    F18 + . (dot)   = move window to next screen (order: toEast or toWest)
--    F18 + , (comma) = move window to prev screen (order: toWest or toEast)
--
local f18 = hs.hotkey.modal.new()

-- Capture F18 key press/release
hs.hotkey.bind({}, 'F18', function()
  f18:enter()
end, function()
  f18:exit()
end)

-- Keycodes resolved from the CURRENT keyboard layout. Binding by keycode (a
-- number) instead of a character string keeps every key in use visible in one
-- place, and each entry is the physical key that types that character on this
-- layout. `hs.keycodes.map` returns nil for a character the layout cannot
-- produce, so the loop below warns about any bind that would silently never
-- fire.
local KEY = {}
for name, char in pairs {
  v = 'v',
  u = 'u',
  i = 'i',
  o = 'o',
  y = 'y',
  p = 'p',
  h = 'h',
  j = 'j',
  k = 'k',
  l = 'l',
  left = 'left',
  right = 'right',
  up = 'up',
  down = 'down',
  dot = '.',
  comma = ',',
} do
  KEY[name] = hs.keycodes.map[char]
  if KEY[name] == nil then
    print(
      ('hammerspoon: KEY.%s (%q) did not resolve on the current layout'):format(
        name,
        char
      )
    )
  end
end

-- Meh (F18/Caps Lock) key bindings for window management
-- These provide quick access to common window operations

-- Bind a Meh key to an action that needs the focused window. The "is anything
-- focused?" guard lives here once instead of in every handler; fn receives the
-- window and only runs when one exists.
local function bind(key, fn)
  f18:bind({}, key, function()
    local w = hs.window.focusedWindow()
    if w then
      fn(w)
    end
  end)
end

-- Place the focused window into a unit-rect region: x/y/w/h are fractions
-- (0..1) of the screen, so { 0, 0, 1/3, 1 } is the full-height left third.
local function place(key, x, y, w, h)
  bind(key, function(win)
    win:moveToUnit({ x = x, y = y, w = w, h = h }, 0)
  end)
end

-- Center the focused window at wFrac x hFrac of its screen's usable frame.
local function centerOnScreen(win, wFrac, hFrac)
  local sf = win:screen():frame()
  local ww, hh = math.floor(sf.w * wFrac), math.floor(sf.h * hFrac)
  win:setFrame({
    x = sf.x + math.floor((sf.w - ww) / 2),
    y = sf.y + math.floor((sf.h - hh) / 2),
    w = ww,
    h = hh,
  }, 0)
end

-- Paste clipboard contents as keystrokes (skips paste protection). No window
-- needed, so this one is bound directly rather than through bind().
f18:bind({}, KEY.v, function()
  hs.eventtap.keyStrokes(hs.pasteboard.getContents())
end)

-- Window positioning (fractions of the screen):
place(KEY.u, 0, 0, 1 / 3, 1) -- left third
place(KEY.i, 1 / 3, 0, 1 / 3, 1) -- center third
place(KEY.o, 2 / 3, 0, 1 / 3, 1) -- right third
place(KEY.y, 0, 0, 2 / 3, 1) -- left two-thirds
place(KEY.p, 1 / 3, 0, 2 / 3, 1) -- right two-thirds
place(KEY.left, 0, 0, 0.5, 1) -- left half
place(KEY.right, 0.5, 0, 0.5, 1) -- right half

-- Cycle through all windows (H/L)
-- We need to maintain state to properly cycle through all windows
local windowCycleIndex = 1
local windowCycleList = {}
local lastCycleTime = 0

local function getWindowCycleList()
  local currentTime = hs.timer.secondsSinceEpoch()
  -- Reset if more than 2 seconds have passed since last cycle
  if currentTime - lastCycleTime > 2 then
    windowCycleIndex = 1
    windowCycleList = hs.window.orderedWindows()
  end
  lastCycleTime = currentTime
  return windowCycleList
end

-- step is +1 (forward, L) or -1 (backward, H); the modulo keeps the index in
-- 1..#windows and wraps at either end (Lua's % returns a non-negative result).
local function cycleWindows(key, step)
  f18:bind({}, key, function()
    local windows = getWindowCycleList()
    if #windows <= 1 then
      return
    end
    windowCycleIndex = (windowCycleIndex - 1 + step) % #windows + 1
    windows[windowCycleIndex]:focus()
  end)
end
cycleWindows(KEY.h, -1)
cycleWindows(KEY.l, 1)

-- Maximize (Up / j)
bind(KEY.up, function(w)
  w:maximize(0)
end)
bind(KEY.j, function(w)
  w:maximize(0)
end)

-- Toggle maximize <-> centered half (Down): maximize unless already near-full,
-- otherwise shrink to a centered 50% x 90% window.
bind(KEY.down, function(w)
  if w:frame().w < w:screen():frame().w * 0.95 then
    w:maximize(0)
  else
    centerOnScreen(w, 0.5, 0.9)
  end
end)

-- Center at 90% x 90% (k)
bind(KEY.k, function(w)
  centerOnScreen(w, 0.9, 0.9)
end)

-- Move the focused window to the adjacent screen, wrapping when only two exist.
bind(KEY.dot, function(w) -- next screen (east, else west)
  local ns = w:screen():toEast() or w:screen():toWest()
  if ns then
    w:moveToScreen(ns, true, true, 0)
  end
end)
bind(KEY.comma, function(w) -- previous screen (west, else east)
  local ps = w:screen():toWest() or w:screen():toEast()
  if ps then
    w:moveToScreen(ps, true, true, 0)
  end
end)
