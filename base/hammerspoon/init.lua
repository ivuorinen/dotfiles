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

-- Meh (F18/Caps Lock) key bindings for window management
-- These provide quick access to common window operations

-- Helper function to get focused window
local function W()
  return hs.window.focusedWindow()
end

-- Paste from clipboard with Meh + v
f18:bind({}, 'v', function()
  hs.eventtap.keyStrokes(hs.pasteboard.getContents())
end)

-- Window positioning: thirds (U/I/O)
f18:bind({}, 'u', function()
  local w = W()
  if w then
    w:moveToUnit({ x = 0, y = 0, w = 1 / 3, h = 1 }, 0)
  end
end)
f18:bind({}, 'i', function()
  local w = W()
  if w then
    w:moveToUnit({ x = 1 / 3, y = 0, w = 1 / 3, h = 1 }, 0)
  end
end)
f18:bind({}, 'o', function()
  local w = W()
  if w then
    w:moveToUnit({ x = 2 / 3, y = 0, w = 1 / 3, h = 1 }, 0)
  end
end)

-- Window positioning: 2/3 width from left, full height (Y)
f18:bind({}, 'y', function()
  local w = W()
  if w then
    w:moveToUnit({ x = 0, y = 0, w = 2 / 3, h = 1 }, 0)
  end
end)
f18:bind({}, 'p', function()
  local w = W()
  if w then
    w:moveToUnit({ x = 2 / 3, y = 0, w = 2 / 3, h = 1 }, 0)
  end
end)

-- Window positioning: halves (Left/Right arrows)
f18:bind({}, 'left', function()
  local w = W()
  if w then
    w:moveToUnit(hs.layout.left50, 0)
  end
end)
f18:bind({}, 'right', function()
  local w = W()
  if w then
    w:moveToUnit(hs.layout.right50, 0)
  end
end)

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

f18:bind({}, 'h', function()
  local windows = getWindowCycleList()
  if #windows <= 1 then
    return
  end

  -- Cycle backward
  windowCycleIndex = windowCycleIndex - 1
  if windowCycleIndex < 1 then
    windowCycleIndex = #windows
  end

  windows[windowCycleIndex]:focus()
end)

f18:bind({}, 'l', function()
  local windows = getWindowCycleList()
  if #windows <= 1 then
    return
  end

  -- Cycle forward
  windowCycleIndex = windowCycleIndex + 1
  if windowCycleIndex > #windows then
    windowCycleIndex = 1
  end

  windows[windowCycleIndex]:focus()
end)

-- Window sizing: maximize (Up/j) and center (Down/k)
f18:bind({}, 'up', function()
  local w = W()
  if w then
    w:maximize(0)
  end
end)
f18:bind({}, 'j', function()
  local w = W()
  if w then
    w:maximize(0)
  end
end)
f18:bind({}, 'down', function()
  local w = W()
  if not w then
    return
  end
  local f = w:frame()
  local sf = w:screen():frame()
  if f.w < sf.w * 0.95 then
    w:maximize(0)
  else
    local ww, hh = math.floor(sf.w * 0.5), math.floor(sf.h * 0.9)
    local xx = sf.x + math.floor((sf.w - ww) / 2)
    local yy = sf.y + math.floor((sf.h - hh) / 2)
    w:setFrame({ x = xx, y = yy, w = ww, h = hh }, 0)
  end
end)
f18:bind({}, 'k', function()
  local w = W()
  if w then
    local sf = w:screen():frame()
    local ww, hh = math.floor(sf.w * 0.9), math.floor(sf.h * 0.9)
    local xx = sf.x + math.floor((sf.w - ww) / 2)
    local yy = sf.y + math.floor((sf.h - hh) / 2)
    w:setFrame({ x = xx, y = yy, w = ww, h = hh }, 0)
  end
end)

-- Move to next/previous screen (. and ,)
f18:bind({}, '.', function()
  local w = W()
  if w then
    local s = w:screen()
    local ns = s:toEast() or s:toWest()
    if ns then
      w:moveToScreen(ns, true, true, 0)
    end
  end
end)
f18:bind({}, ',', function()
  local w = W()
  if w then
    local s = w:screen()
    local ps = s:toWest() or s:toEast()
    if ps then
      w:moveToScreen(ps, true, true, 0)
    end
  end
end)
