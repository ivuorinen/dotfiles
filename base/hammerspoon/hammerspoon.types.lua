---@meta
--- Hammerspoon EmmyLua Type Definitions
--- Auto-generated from official documentation
--- https://www.hammerspoon.org/docs/


-- ------------------------------------------------------------
-- hs
-- ------------------------------------------------------------

---@class hs
hs = {}

--- A string containing Hammerspoon's configuration directory. Typically
--- ~/.hammerspoon/
---@type string
hs.configdir = nil

--- A string containing the full path to the
--- docs.json
--- file inside Hammerspoon's app bundle. This contains the full Hammerspoon API documentation and can be accessed in
--- the Console using
--- help("someAPI")
--- . It can also be loaded and processed by the
--- hs.doc
--- extension
---@type string
hs.docstrings_json_file = nil

--- A table containing read-only information about the Hammerspoon application instance currently running.
---@type table
hs.processInfo = nil

--- An optional function that will be called when the Accessibility State is changed.
---@type function|nil
hs.accessibilityStateCallback = nil

--- Gathers tab completion options for the Console window
---@type any
hs.completionsForInputString(completionWord) -> table of strings = nil

--- An optional function that will be called when the Hammerspoon Dock Icon is clicked while the app is running
---@type function|nil
hs.dockIconClickCallback = nil

--- An optional function that will be called when a files are dragged to the Hammerspoon Dock Icon or sent via the
--- Services menu
---@type function|nil
hs.fileDroppedToDockIconCallback = nil

--- An optional function that will be called when the Lua environment is being destroyed (either because Hammerspoon is
--- exiting or reloading its config)
---@type function|nil
hs.shutdownCallback = nil

--- An optional function that will be called when text is dragged to the Hammerspoon Dock Icon or sent via the Services
--- menu
---@type function|nil
hs.textDroppedToDockIconCallback = nil

--- Checks the Accessibility Permissions for Hammerspoon, and optionally allows you to prompt for permissions.
---
--- Note: Since this check is done automatically when Hammerspoon loads, it is probably of limited use except for
--- skipping things that are known to fail when Accessibility is not enabled.  Evettaps which try to capture keyUp and
--- keyDown events, for example, will fail until Accessibility is enabled and the Hammerspoon application is relaunched.
---@param shouldPrompt boolean|nil
---@return isEnabled
function hs.accessibilityState(shouldPrompt) end

--- Set or display whether or not external Hammerspoon AppleScript commands are allowed.
---
--- Note: AppleScript access is disallowed by default.
--- However due to the way AppleScript support works, Hammerspoon will always allow AppleScript commands that are part
--- of the "Standard Suite", such as name , quit , version , etc. However, Hammerspoon will only allow commands from
--- the "Hammerspoon Suite" if hs.allowAppleScript() is set to true .
--- Open /Applications/Utilities/Script Editor.app
--- Click File > Open Dictionary...
--- Select Hammerspoon from the list of Applications
--- This will now open a Dictionary containing all of the available Hammerspoon AppleScript commands.
--- Note that strings within the Lua code you pass from AppleScript can be delimited by [[ and ]] rather than normal
--- quotes
--- Example: tell application "Hammerspoon" execute lua code "hs.alert([[Hello from AppleScript]])" end tell ```
---@param state boolean
---@return boolean
function hs.allowAppleScript(state) end

--- Set or display the "Launch on Login" status for Hammerspoon.
---@param state boolean
---@return boolean
function hs.autoLaunch(state) end

--- Gets and optionally sets the Hammerspoon option to automatically check for updates.
---
--- Note: If you are running a non-release or locally compiled version of Hammerspoon then the results of this function
--- are unspecified.
---@param setting boolean|nil
---@return boolean
function hs.automaticallyCheckForUpdates(setting) end

--- Checks the Camera Permissions for Hammerspoon, and optionally allows you to prompt for permissions.
---
--- Note: Will always return true on macOS 10.13 or earlier.
---@param shouldPrompt boolean|nil
---@return boolean
function hs.cameraState(shouldPrompt) end

--- Returns a boolean indicating whether or not the Sparkle framework is available to check for Hammerspoon updates.
---
--- Note: The Sparkle framework is included in all regular releases of Hammerspoon but not included if you are running
--- a non-release or locally compiled version of Hammerspoon, so this function can be used as a simple test to
--- determine whether or not you are running a formal release Hammerspoon or not.
---@return boolean
function hs.canCheckForUpdates() end

--- Check for an update now, and if one is available, prompt the user to continue the update process.
---
--- Note: If you are running a non-release or locally compiled version of Hammerspoon then the results of this function
--- are unspecified.
---@param silent boolean|nil
---@return none
function hs.checkForUpdates(silent) end

--- Returns a copy of the incoming string that can be displayed in the Hammerspoon console.  Invalid UTF8 sequences are
--- converted to the Unicode Replacement Character and NULL (0x00) is converted to the Unicode Empty Set character.
---
--- Note: This function is applied automatically to all output which appears in the Hammerspoon console, but not to the
--- output provided by the hs command line tool.
--- This function does not modify the original string - to actually replace it, assign the result of this function to
--- the original string.
--- This function is a more specifically targeted version of the hs.utf8.fixUTF8(...) function.
---@param inString string
---@return outString
function hs.cleanUTF8forConsole(inString) end

--- Closes the Hammerspoon Console window
---@return any
function hs.closeConsole() end

--- Closes the Hammerspoon Preferences window
---@return any
function hs.closePreferences() end

--- Set or display whether or not the Hammerspoon console is always on top when visible.
---@param state boolean
---@return boolean
function hs.consoleOnTop(state) end

--- Yield coroutine to allow the Hammerspoon application to process other scheduled events and schedule a resume in the
--- event application queue.
---
--- Note: this function will return an error if invoked outside of a coroutine.
--- unlike coroutine.yield , this function does not allow the passing of (new) information to or from the coroutine
--- while it is running; this function is to allow long running tasks to yield time to the Hammerspoon application so
--- other timers and scheduled events can occur without requiring the programmer to add code for an explicit resume.
--- this function is added to the lua coroutine library as coroutine.applicationYield as an alternative name.
---@param delay hs.math.minFloat|nil
---@return any
function hs.coroutineApplicationYield(delay) end

--- Set or display whether or not the Hammerspoon dock icon is visible.
---
--- Note: This function is a wrapper to functions found in the hs.dockicon module, but is provided here to provide an
--- interface consistent with other selectable preference items.
---@param state boolean
---@return boolean
function hs.dockIcon(state) end

--- Runs a shell command, optionally loading the users shell environment first, and returns stdout as a string,
--- followed by the same result codes as
--- os.execute
--- would return.
---
--- Note: Setting with_user_env to true does incur noticeable overhead, so it should only be used if necessary (to set
--- the path or other environment variables).
--- Because this function returns the stdout as it's first return value, it is not quite a drop-in replacement for
--- os.execute .  In most cases, it is probable that stdout will be the empty string when status is nil, but this is
--- not guaranteed, so this trade off of shifting os.execute's results was deemed acceptable.
--- This particular function is most useful when you're more interested in the command's output then a simple check for
--- completion and result codes.  If you only require the result codes or verification of command completion, then
--- os.execute will be slightly more efficient.
--- If you need to execute commands that have spaces in their paths, use a form like: hs.execute [["/Some/Path
--- To/An/Executable" "--first-arg" "second-arg"]]
---@param command string
---@param with_user_env? boolean|nil
---@return output
---@return status
---@return type
---@return rc
function hs.execute(command, with_user_env) end

--- Makes Hammerspoon the foreground app.
---@return any
function hs.focus() end

--- Fetches the Lua metatable for objects produced by an extension
---@param name string
---@return table|nil
function hs.getObjectMetatable(name) end

--- Prints the documentation for some part of Hammerspoon's API and Lua 5.3.  This function is actually sourced from
--- hs.doc.help.
---
--- Note: This function is mainly for runtime API help while using Hammerspoon's Console
--- help("identifier") -- quotes are required, e.g. help("hs.reload")
--- help.identifier.path -- no quotes are required, e.g. help.hs.reload
--- the identifier lua._man provides the table of contents for the Lua 5.3 manual.  You can pull up a specific section
--- of the lua manual by including the chapter (and subsection) like this: lua._man._3_4_8 .
--- the identifier lua._C will provide information specifically about the Lua C API for use when developing modules
--- which require external libraries.
---@param identifier string
---@return any
function hs.help(identifier) end

--- Display's Hammerspoon API documentation in a webview browser.
---
--- Note: hs.hsdocs.identifier.path -- no quotes are required, e.g. hs.hsdocs.hs.reload
--- See hs.doc.hsdocs for more information about the available settings for the documentation browser.
--- This function provides documentation for Hammerspoon modules, functions, and methods similar to the Hammerspoon
--- Dash docset, but does not require any additional software.
--- This currently only provides documentation for the built in Hammerspoon modules, functions, and methods.  The Lua
--- documentation and third-party modules are not presently supported, but may be added in a future release.
---@param identifier hs.reload|nil
---@return any
function hs.hsdocs(identifier) end

--- Loads a Spoon
---
--- Note: Spoons are a way of distributing self-contained units of Lua functionality, for Hammerspoon. For more
--- information, see https://github.com/Hammerspoon/hammerspoon/blob/master/SPOONS.md
--- This function will load the Spoon and call its :init() method if it has one. If you do not wish this to happen, or
--- wish to use a Spoon that somehow doesn't fit with the behaviours of this function, you can also simply
--- require('name') to load the Spoon
--- If the Spoon has a :start() method you are responsible for calling it before using the functionality of the Spoon.
--- If the Spoon provides documentation, it will be loaded by made available in hs.docs
--- To learn how to distribute your own code as a Spoon, see https://github.com/Hammerspoon/hammerspoon/blob/master/SPOONS.md
---@param name string
---@param global? boolean|nil
---@return Spoon
function hs.loadSpoon(name, global) end

--- Set or display whether or not the Hammerspoon menu icon is visible.
---@param state boolean
---@return boolean
function hs.menuIcon(state) end

--- Checks the Microphone Permissions for Hammerspoon, and optionally allows you to prompt for permissions.
---
--- Note: Will always return true on macOS 10.13 or earlier.
---@param shouldPrompt boolean|nil
---@return boolean
function hs.microphoneState(shouldPrompt) end

--- Opens a file as if it were opened with /usr/bin/open
---@param filePath string
---@return boolean
function hs.open(filePath) end

--- Displays the OS X About panel for Hammerspoon; implicitly focuses Hammerspoon.
---@return any
function hs.openAbout() end

--- Opens the Hammerspoon Console window and optionally focuses it.
---@param bringToFront boolean
---@return any
function hs.openConsole(bringToFront) end

--- Set or display whether or not the Console window will open when the Hammerspoon dock icon is clicked
---
--- Note: This only refers to dock icon clicks while Hammerspoon is already running. The console window is not opened
--- by launching the app
---@param state boolean|nil
---@return boolean
function hs.openConsoleOnDockClick(state) end

--- Displays the Hammerspoon Preferences panel; implicitly focuses Hammerspoon.
---@return any
function hs.openPreferences() end

--- Set or display whether or not the Preferences panel should display in dark mode.
---@param state boolean
---@return boolean
function hs.preferencesDarkMode(state) end

--- Prints formatted strings to the Console
---
--- Note: This is a simple wrapper around the Lua code print(string.format(...)) .
---@param format string
---@param ... any
---@return any
function hs.printf(format, ...) end

--- The original Lua print() function
---
--- Note: Hammerspoon overrides Lua's print() function, but this is a reference we retain to is, should you need it for
--- any reason
---@param aString string
---@return any
function hs.rawprint(aString) end

--- Quits and relaunches Hammerspoon.
---@return any
function hs.relaunch() end

--- Reloads your init-file in a fresh Lua environment.
---@return any
function hs.reload() end

--- Checks the Screen Recording Permissions for Hammerspoon, and optionally allows you to prompt for permissions.
---
--- Note: If you trigger the prompt and the user denies it, you cannot bring up the prompt again - the user must
--- manually enable it in System Preferences.
---@param shouldPrompt boolean|nil
---@return isEnabled
function hs.screenRecordingState(shouldPrompt) end

--- Shows an error to the user, using Hammerspoon's Console
---
--- Note: This function is called whenever an (uncaught) error occurs or is thrown (via error() )
--- The default implementation shows a notification, opens the Console, and prints the error message and stacktrace
--- You can override this function if you wish to route errors differently (e.g. for remote systems)
---@param err string
---@return any
function hs.showError(err) end

--- Toggles the visibility of the console
---
--- Note: If the console is not currently open, it will be opened. If it is open and not the focused window, it will be
--- brought forward and focused.
--- If the console is focused, it will be closed.
---@return any
function hs.toggleConsole() end

--- Gets the version & build number of an available update
---
--- Note: This is not a live check, it is a cached result of whatever the previous update check found. By default
--- Hammerspoon checks for updates every few hours, but you can also add your own timer to check for updates more
--- frequently with hs.checkForUpdates()
---@return string|boolean
---@return string
function hs.updateAvailable() end

--- Get or set the "Upload Crash Data" preference for Hammerspoon
---
--- Note: If at all possible, please do allow Hammerspoon to upload crash reports to us, it helps a great deal in
--- keeping Hammerspoon stable
--- Our Privacy Policy can be found here: https://www.hammerspoon.org/privacy.html
---@param state boolean|nil
---@return boolean
function hs.uploadCrashData(state) end

-- ------------------------------------------------------------
-- hs.alert
-- ------------------------------------------------------------

---@class hs.alert
hs.alert = {}

--- A table defining the default visual style for the alerts generated by this module.
---@type table
hs.alert.defaultStyle[] = nil

--- Closes all alerts currently open on the screen
---@param seconds hs.alert.defaultStyle|nil
---@return any
function hs.alert.closeAll(seconds) end

--- Closes the alert with the specified identifier
---
--- Note: Use this function to close an alert which is indefinite or close an alert with a long duration early.
---@param uuid string
---@param seconds hs.alert.defaultStyle|nil
---@return any
function hs.alert.closeSpecific(uuid, seconds) end

--- Shows a message in large words briefly in the middle of the screen; does tostring() on its argument for convenience.
---
--- Note: For convenience, you can call this function as hs.alert(...)
--- This function effectively calls hs.alert.showWithImage(msg, nil, ...) . As such, all the same rules apply regarding
--- argument processing
---@param str string
---@param style hs.alert.defaultStyle|hs.styledtext|nil
---@param screen hs.screen|hs.screen.mainScreen|nil
---@param seconds number
---@return uuid
function hs.alert.show(str, style, screen, seconds) end

--- Shows an image and a message in large words briefly in the middle of the screen; does tostring() on its argument
--- for convenience.
---
--- Note: if the argument is a table and style has not previously been set, then the table is assigned to style
--- if the argument is a userdata and screen has not previously been set, then the userdata is assigned to screen
--- if duration has not been set, then it is assigned the value of the argument
--- if all of these conditions fail for a given argument, then an error is returned
--- The reason for this logic is to support the creation of persistent alerts as was previously handled by the module:
--- If you specify a non-number value for seconds you will need to store the string identifier returned by this
--- function so that you can close it manually with hs.alert.closeSpecific when the alert should be removed.
--- Any style element which is not specified in the style argument table will use the value currently defined in the
--- hs.alert.defaultStyle table.
---@param str string
---@param image any
---@param style hs.alert.defaultStyle|hs.styledtext|nil
---@param screen hs.screen|hs.window|hs.screen.mainScreen|nil
---@param seconds number
---@return uuid
function hs.alert.showWithImage(str, image, style, screen, seconds) end

-- ------------------------------------------------------------
-- hs.appfinder
-- ------------------------------------------------------------

---@class hs.appfinder
hs.appfinder = {}

--- Finds an application by its name (e.g. "Safari")
---@param name string
---@return app|nil
function hs.appfinder.appFromName(name) end

--- Finds an application by its window title (e.g. "Activity Monitor (All Processes)")
---@param title string
---@return app|nil
function hs.appfinder.appFromWindowTitle(title) end

--- Finds an application by Lua pattern in its window title (e.g."Inbox %(%d+ messages.*)")
---
--- Note: For more about Lua patterns, see http://lua-users.org/wiki/PatternsTutorial and
--- http://www.lua.org/manual/5.2/manual.html#6.4.1
---@param pattern string
---@return app|nil
function hs.appfinder.appFromWindowTitlePattern(pattern) end

--- Finds a window by its title (e.g. "Activity Monitor (All Processes)")
---@param title string
---@return win|nil
function hs.appfinder.windowFromWindowTitle(title) end

--- Finds a window by Lua pattern in its title (e.g."Inbox %(%d+ messages.*)")
---
--- Note: For more about Lua patterns, see http://lua-users.org/wiki/PatternsTutorial and
--- http://www.lua.org/manual/5.2/manual.html#6.4.1
---@param pattern string
---@return app|nil
function hs.appfinder.windowFromWindowTitlePattern(pattern) end

-- ------------------------------------------------------------
-- hs.application
-- ------------------------------------------------------------

---@class hs.application
hs.application = {}

---@class application
local application = {}

--- A table containing UTF8 representations of the defined key glyphs used in Menus for keyboard shortcuts which are
--- presented pictorially rather than as text (arrow keys, return key, etc.)
---@type table
hs.application.menuGlyphs = nil

--- Returns the running app for the given pid, if it exists.
---@param pid number
---@return hs.application|nil
function hs.application.applicationForPID(pid) end

--- Returns any running apps that have the given bundleID.
---@param bundleID string
---@return list of hs.application objects
function hs.application.applicationsForBundleID(bundleID) end

--- Returns the bundle ID of the default application for a given UTI
---@param uti string
---@return string|nil
function hs.application.defaultAppForUTI(uti) end

--- Get or set whether Spotlight should be used to find alternate names for applications.
---
--- Note: This setting is persistent across reloading and restarting Hammerspoon.
--- If this was set to true and you set it to true again, it will purge the alternate name map and rebuild it from
--- scratch.
--- You can disable Spotlight alternate name mapping by setting this value to false or nil. If you set this to false,
--- then the notifications indicating that more results might be possible if Spotlight is enabled will be suppressed.
---@param state hs.application.find|nil
---@return boolean
function hs.application.enableSpotlightForNameSearches(state) end

--- Returns the application object for the frontmost (active) application.  This is the application which currently
--- receives input events.
---@return hs.application
function hs.application.frontmostApplication() end

--- Gets the metadata of an application from its bundle identifier
---@param bundleID string
---@return table|nil
function hs.application.infoForBundleID(bundleID) end

--- Gets the metadata of an application from its path on disk
---@param bundlePath string
---@return table|nil
function hs.application.infoForBundlePath(bundlePath) end

--- Launches the app with the given name, or activates it if it's already running
---
--- Note: The name parameter should match the name of the application on disk, e.g. "IntelliJ IDEA", rather than
--- "IntelliJ"
---@param name string
---@return boolean
function hs.application.launchOrFocus(name) end

--- Launches the app with the given bundle ID, or activates it if it's already running
---
--- Note: Bundle identifiers typically take the form of com.company.ApplicationName
---@param bundleID string
---@return boolean
function hs.application.launchOrFocusByBundleID(bundleID) end

--- Gets a list of all the localizations contained in the bundle.
---@param bundleID string
---@return table|nil
function hs.application.localizationsForBundleID(bundleID) end

--- Gets a list of all the localizations contained in the bundle.
---@param bundlePath string
---@return table|nil
function hs.application.localizationsForBundlePath(bundlePath) end

--- Gets the name of an application from its bundle identifier
---@param bundleID string
---@return string|nil
function hs.application.nameForBundleID(bundleID) end

--- Gets the filesystem path of an application from its bundle identifier
---@param bundleID string
---@return string|nil
function hs.application.pathForBundleID(bundleID) end

--- Gets an ordered list of preferred localizations contained in a bundle
---@param bundleID string
---@return table|nil
function hs.application.preferredLocalizationsForBundleID(bundleID) end

--- Gets an ordered list of preferred localizations contained in a bundle
---@param bundlePath string
---@return table|nil
function hs.application.preferredLocalizationsForBundlePath(bundlePath) end

--- Returns all running apps.
---@return list of hs.application objects
function hs.application.runningApplications() end

--- Finds running applications
---
--- Note: If multiple results are found, this function will return multiple values. See
--- https://www.lua.org/pil/5.1.html for more information on how to work with this
--- for convenience you can call this as hs.application(hint)
--- use this function when you don't know the exact name of an application you're interested in, i.e.
--- from the console: hs.application'term' --> hs.application: iTerm2 (0x61000025fb88) hs.application: Terminal
--- (0x618000447588) .
--- But be careful when using it in your init.lua : terminal=hs.application'term' will assign either "Terminal" or
--- "iTerm2" arbitrarily (or even,
--- if neither are running, any other app with a window that happens to have "term" in its title); to make sure you get
--- the right app in your scripts,
--- use hs.application.get with the exact name: terminal=hs.application.get'Terminal' --> "Terminal" app, or nil if
--- it's not running
--- Usage:
--- -- by pid
--- hs.application(42):name() --> Finder
--- -- by bundle id
--- hs.application'com.apple.Safari':name() --> Safari
--- -- by name
--- hs.application'chrome':name() --> Google Chrome
--- -- by window title
--- hs.application'bash':name() --> Terminal
---@param hint hs.application|hs.window
---@param exact boolean
---@param stringLiteral boolean
---@return hs.application
function hs.application.find(hint, exact, stringLiteral) end

--- Gets a running application
---
--- Note: see also hs.application.find
---@param hint hs.application
---@return hs.application
function hs.application.get(hint) end

--- Launches an application, or activates it if it's already running
---
--- Note: the wait parameter will block all Hammerspoon activity in order to return the application object
--- "synchronously"; only use it if you
--- a) have no time-critical event processing happening elsewhere in your init.lua and b) need to act on the
--- application object, or on
--- its window(s), right away
--- when launching a "windowless" app (background daemon, menulet, etc.) make sure to omit waitForFirstWindow
---@param app string
---@param wait? number|nil
---@param waitForFirstWindow? any
---@return hs.application
function hs.application.open(app, wait, waitForFirstWindow) end

--- Tries to activate the app (make its key window focused) and returns whether it succeeded; if allWindows is true,
--- all windows of the application are brought forward as well.
---@param allWindows any
---@return boolean
function application:activate(allWindows) end

--- Returns all open windows owned by the given app.
---
--- Note: if Displays have separate Spaces is on (in System Preferences>Mission Control) the current Space is defined
--- as the union of all currently visible Spaces
--- minimized windows and hidden windows (i.e. belonging to hidden apps, e.g. via cmd-h) are always considered
--- to be in the current Space
---@return list of hs.window objects
function application:allWindows() end

--- Returns the bundle identifier of the app.
---@return string
function application:bundleID() end

--- Searches the application for a menu item
---
--- Note: This can only search for menu items that don't have children - i.e. you can't search for the name of a submenu
---@param menuItem table
---@param isRegex? boolean|nil
---@return table|nil
function application:findMenuItem(menuItem, isRegex) end

--- Finds windows from this application
---@param titlePattern string
---@return hs.window
function application:findWindow(titlePattern) end

--- Returns the currently focused window of the application, or nil
---@return hs.window|nil
function application:focusedWindow() end

--- Gets the menu structure of the application
---
--- Note: In some applications, this can take a little while to complete, because quite a large number of round trips
--- are required to the source application, to get the information. When this method is invoked without a callback
--- function, Hammerspoon will block while creating the menu structure table.  When invoked with a callback function,
--- the menu structure is built in a background thread.
--- The table is nested with the same structure as the menus of the application. Each item has several keys containing
--- information about the menu item. Not all keys will appear for all items. The possible keys are:
--- AXTitle - A string containing the text of the menu item (entries which have no title are menu separators)
--- AXEnabled - A boolean, 1 if the menu item is clickable, 0 if not
--- AXRole - A string containing the role of the menu item - this will be either AXMenuBarItem for a top level menu, or
--- AXMenuItem for an item in a menu
--- AXMenuItemMarkChar - A string containing the "mark" character for a menu item. This is for toggleable menu items
--- and will usually be an empty string or a Unicode tick character (✓)
--- AXMenuItemCmdModifiers - A table containing string representations of the keyboard modifiers for the menu item's
--- keyboard shortcut, or nil if no modifiers are present
--- AXMenuItemCmdChar - A string containing the key for the menu item's keyboard shortcut, or an empty string if no
--- shortcut is present
--- AXMenuItemCmdGlyph - An integer, corresponding to one of the defined glyphs in hs.application.menuGlyphs if the
--- keyboard shortcut is a special character usually represented by a pictorial representation (think arrow keys,
--- return, etc), or an empty string if no glyph is used in presenting the keyboard shortcut.
--- Using hs.inspect() on these tables, while useful for exploration, can be extremely slow, taking several minutes to
--- correctly render very complex menus
---@param fn function|nil
---@return table|nil|hs.application
function application:getMenuItems(fn) end

--- Gets a specific window from this application
---@param title hs.window
---@return hs.window
function application:getWindow(title) end

--- Hides the app (and all its windows).
---@return boolean
function application:hide() end

--- Returns whether the app is the frontmost (i.e. is the currently active application)
---@return boolean
function application:isFrontmost() end

--- Returns whether the app is currently hidden.
---@return boolean
function application:isHidden() end

--- Checks if the application is still running
---
--- Note: If an application is terminated and re-launched, this method will still return false, as hs.application
--- objects are tied to a specific instance of an application (i.e. its PID)
---@return boolean
function application:isRunning() end

--- Tries to terminate the app gracefully.
---@return any
function application:kill() end

--- Tries to terminate the app forcefully.
---@return any
function application:kill9() end

--- Identify the application's GUI state
---@return number
function application:kind() end

--- Returns the main window of the given app, or nil.
---@return hs.window|nil
function application:mainWindow() end

--- Alias for
--- hs.application:title()
---@return any
function application:name() end

--- Returns the filesystem path of the app.
---@return string
function application:path() end

--- Returns the app's process identifier.
---@return number
function application:pid() end

--- Selects a menu item (i.e. simulates clicking on the menu item)
---
--- Note: Depending on the type of menu item involved, this will either activate or tick/untick the menu item
---@param menuitem hs.application
---@param isRegex? boolean|nil
---@return boolean|nil
function application:selectMenuItem(menuitem, isRegex) end

--- Sets the app to the frontmost (i.e. currently active) application
---@param allWindows boolean|nil
---@return boolean
function application:setFrontmost(allWindows) end

--- Returns the localized name of the app (in UTF8).
---@return string
function application:title() end

--- Unhides the app (and all its windows) if it's hidden.
---@return boolean
function application:unhide() end

--- Returns only the app's windows that are visible.
---@return win[]
function application:visibleWindows() end

-- ------------------------------------------------------------
-- hs.application.watcher
-- ------------------------------------------------------------

---@class hs.application.watcher
hs.application.watcher = {}

---@class watcher
local watcher = {}

---@class hs.application.watcher.watcher
---@field activated any An application has been activated (i.e
---@field deactivated any An application has been deactivated (i.e
---@field hidden any An application has been hidden
---@field launched any An application has been launched
---@field launching any An application is in the process of being launched

--- An application has been activated (i.e. given keyboard/mouse focus)
---@type any
hs.application.watcher.activated = nil

--- An application has been deactivated (i.e. lost keyboard/mouse focus)
---@type any
hs.application.watcher.deactivated = nil

--- An application has been hidden
---@type any
hs.application.watcher.hidden = nil

--- An application has been launched
---@type any
hs.application.watcher.launched = nil

--- An application is in the process of being launched
---@type any
hs.application.watcher.launching = nil

--- An application has been terminated
---@type any
hs.application.watcher.terminated = nil

--- An application has been unhidden
---@type any
hs.application.watcher.unhidden = nil

--- Creates an application event watcher
---
--- Note: If the function is called with an event type of hs.application.watcher.terminated then the application name
--- parameter will be nil and the hs.application parameter, will only be useful for getting the UNIX process ID (i.e.
--- the PID) of the application
---@param fn function
---@return watcher
function hs.application.watcher.new(fn) end

--- Starts the application watcher
---@return hs.application.watcher
function watcher:start() end

--- Stops the application watcher
---@return hs.application.watcher
function watcher:stop() end

-- ------------------------------------------------------------
-- hs.audiodevice
-- ------------------------------------------------------------

---@class hs.audiodevice
hs.audiodevice = {}

---@class audiodevice
local audiodevice = {}

--- Returns a list of all connected devices
---@return hs.audiodevice[]
function hs.audiodevice.allDevices() end

--- Returns a list of all connected input devices.
---@return audio[]
function hs.audiodevice.allInputDevices() end

--- Returns a list of all connected output devices
---@return hs.audiodevice[]
function hs.audiodevice.allOutputDevices() end

--- Fetch various metadata about the current default audio devices
---@param input any
---@return table
function hs.audiodevice.current(input) end

--- Get the currently selected sound effect device
---@return audio|nil
function hs.audiodevice.defaultEffectDevice() end

--- Get the currently selected audio input device
---@return audio|nil
function hs.audiodevice.defaultInputDevice() end

--- Get the currently selected audio output device
---@return audio|nil
function hs.audiodevice.defaultOutputDevice() end

--- Find an audio device by name
---@param name string
---@return device|nil
function hs.audiodevice.findDeviceByName(name) end

--- Find an audio device by UID
---@param uid string
---@return device|nil
function hs.audiodevice.findDeviceByUID(uid) end

--- Find an audio input device by name
---@param name string
---@return device|nil
function hs.audiodevice.findInputByName(name) end

--- Find an audio input device by UID
---@param uid string
---@return device|nil
function hs.audiodevice.findInputByUID(uid) end

--- Find an audio output device by name
---@param name string
---@return device|nil
function hs.audiodevice.findOutputByName(name) end

--- Find an audio output device by UID
---@param uid string
---@return device|nil
function hs.audiodevice.findOutputByUID(uid) end

--- Gets all of the input data sources of an audio device
---@return hs.audiodevice.dataSource[]|nil
function audiodevice:allInputDataSources() end

--- Gets all of the output data sources of an audio device
---@return hs.audiodevice.dataSource[]|nil
function audiodevice:allOutputDataSources() end

--- Get the current left/right balance of this audio device
---
--- Note: The return value will be a floating point number
--- This method will inspect the device to determine if it is an input or output device, and return the appropriate
--- volume. For devices that are both input and output devices, see :inputVolume() and :outputVolume()
---@return number|nil
function audiodevice:balance() end

--- Gets the current input data source of an audio device
---
--- Note: Before calling this method, you should check the result of hs.audiodevice:supportsInputDataSources()
---@return hs.audiodevice.dataSource|nil
function audiodevice:currentInputDataSource() end

--- Gets the current output data source of an audio device
---
--- Note: Before calling this method, you should check the result of hs.audiodevice:supportsOutputDataSources()
---@return hs.audiodevice.dataSource|nil
function audiodevice:currentOutputDataSource() end

--- Get the Input mutedness state of the audio device
---@return boolean|nil
function audiodevice:inputMuted() end

--- Get the current input volume of this audio device
---
--- Note: The return value will be a floating point number
---@return number|nil
function audiodevice:inputVolume() end

--- Check if the audio device is in use
---@return boolean|nil
function audiodevice:inUse() end

--- Determines if an audio device is an input device
---@return boolean
function audiodevice:isInputDevice() end

--- Determines if an audio device is an output device
---@return boolean
function audiodevice:isOutputDevice() end

--- Determines whether an audio jack (e.g. headphones) is connected to an audio device
---@return boolean|nil
function audiodevice:jackConnected() end

--- Get the mutedness state of the audio device
---
--- Note: If a device is capable of both input and output, this method will prefer the output. See :inputMuted() and
--- :outputMuted() for specific variants.
---@return boolean|nil
function audiodevice:muted() end

--- Get the name of the audio device
---@return string|nil
function audiodevice:name() end

--- Get the Output mutedness state of the audio device
---@return boolean|nil
function audiodevice:outputMuted() end

--- Get the current output volume of this audio device
---
--- Note: The return value will be a floating point number
---@return number|nil
function audiodevice:outputVolume() end

--- Set the balance of this audio device
---
--- Note: This method will inspect the device to determine if it is an input or output device, and set the appropriate
--- volume. For devices that are both input and output devices, see :setInputVolume() and :setOutputVolume()
---@param level number
---@return boolean
function audiodevice:setBalance(level) end

--- Selects this device as the audio output device for system sound effects
---@return boolean
function audiodevice:setDefaultEffectDevice() end

--- Selects this device as the system's audio input device
---@return boolean
function audiodevice:setDefaultInputDevice() end

--- Selects this device as the system's audio output device
---@return boolean
function audiodevice:setDefaultOutputDevice() end

--- Set the mutedness state of the Input of the audio device
---@param state boolean
---@return boolean
function audiodevice:setInputMuted(state) end

--- Set the input volume of this audio device
---
--- Note: The volume level is a floating point number. Depending on your audio hardware, it may not be possible to
--- increase volume in single digit increments
---@param level number
---@return boolean
function audiodevice:setInputVolume(level) end

--- Set the mutedness state of the audio device
---
--- Note: If a device is capable of both input and output, this method will prefer the output. See :setInputMuted() and
--- :setOutputMuted() for specific variants.
---@param state boolean
---@return boolean
function audiodevice:setMuted(state) end

--- Set the mutedness state of the Output of the audio device
---@param state boolean
---@return boolean
function audiodevice:setOutputMuted(state) end

--- Set the output volume of this audio device
---
--- Note: The volume level is a floating point number. Depending on your audio hardware, it may not be possible to
--- increase volume in single digit increments
---@param level number
---@return boolean
function audiodevice:setOutputVolume(level) end

--- Set the volume of this audio device
---
--- Note: The volume level is a floating point number. Depending on your audio hardware, it may not be possible to
--- increase volume in single digit increments.
--- This method will inspect the device to determine if it is an input or output device, and set the appropriate
--- volume. For devices that are both input and output devices, see :setInputVolume() and :setOutputVolume()
---@param level number
---@return boolean
function audiodevice:setVolume(level) end

--- Determines whether an audio device supports input data sources
---@return boolean
function audiodevice:supportsInputDataSources() end

--- Determines whether an audio device supports output data sources
---@return boolean
function audiodevice:supportsOutputDataSources() end

--- Gets the hardware transport type of an audio device
---@return string
function audiodevice:transportType() end

--- Get the unique identifier of the audio device
---@return string|nil
function audiodevice:uid() end

--- Get the current volume of this audio device
---
--- Note: The return value will be a floating point number
--- This method will inspect the device to determine if it is an input or output device, and return the appropriate
--- volume. For devices that are both input and output devices, see :inputVolume() and :outputVolume()
---@return number|nil
function audiodevice:volume() end

--- Sets or removes a callback function for an audio device watcher
---
--- Note: You will receive many events to your callback, so filtering on the name/scope/element arguments is vital. For
--- example, on a stereo device, it is not uncommon to receive a volm event for each audio channel when the volume
--- changes, or multiple mute events for channels. Dragging a volume slider in the system Sound preferences will
--- produce a large number of volm events. Plugging/unplugging headphones may trigger volm events in addition to jack
--- ones, etc.
--- If you need to use the hs.audiodevice object in your callback, use hs.audiodevice.findDeviceByUID() to obtain it
--- fro the first callback argument
---@param fn function
---@return hs.audiodevice
function audiodevice:watcherCallback(fn) end

--- Gets the status of the
--- hs.audiodevice
--- object watcher
---@return boolean
function audiodevice:watcherIsRunning() end

--- Starts the watcher on an
--- hs.audiodevice
--- object
---@return hs.audiodevice|nil
function audiodevice:watcherStart() end

--- Stops the watcher on an
--- hs.audiodevice
--- object
---@return hs.audiodevice
function audiodevice:watcherStop() end

-- ------------------------------------------------------------
-- hs.audiodevice.datasource
-- ------------------------------------------------------------

---@class hs.audiodevice.datasource
hs.audiodevice.datasource = {}

---@class datasource
local datasource = {}

--- Gets the name of an audio device datasource
---@return string
function datasource:name() end

--- Sets the audio device datasource as the default
---@return hs.audiodevice.datasource
function datasource:setDefault() end

-- ------------------------------------------------------------
-- hs.audiodevice.watcher
-- ------------------------------------------------------------

---@class hs.audiodevice.watcher
hs.audiodevice.watcher = {}

--- Gets the status of the audio device watcher
---@return boolean
function hs.audiodevice.watcher.isRunning() end

--- Sets the callback function for the audio device watcher
---
--- Note: This watcher will call the callback when various audio device related events occur (e.g. an audio device
--- appears/disappears, a system default audio device setting changes, etc)
--- To watch for changes within an audio device, see hs.audiodevice:newWatcher()
--- The callback function argument is a string which may be one of the following strings, but might also be a different
--- string entirely:
--- dIn  - Default audio input device setting changed (Note that there is a space character after dIn , because these
--- values always have to be four characters long)
--- dOut - Default audio output device setting changed
--- sOut - Default system audio output setting changed (i.e. the device that system sound effects use. This may also be
--- triggered by dOut, depending on the user's settings)
--- dev# - An audio device appeared or disappeared
--- The callback will be called for each individual audio device event received from the OS, so you may receive
--- multiple events for a single physical action (e.g. unplugging the default audio device will cause dOut and dev#
--- events, and possibly sOut too)
--- Passing nil will cause the watcher to stop if it is already running
---@param fn function|nil
---@return any
function hs.audiodevice.watcher.setCallback(fn) end

--- Starts the audio device watcher
---@return any
function hs.audiodevice.watcher.start() end

--- Stops the audio device watcher
---@return hs.audiodevice.watcher
function hs.audiodevice.watcher.stop() end

-- ------------------------------------------------------------
-- hs.axuielement
-- ------------------------------------------------------------

---@class hs.axuielement
hs.axuielement = {}

---@class axuielement
local axuielement = {}

---@class hs.axuielement.axuielement
---@field actions[] any A table of common accessibility object action names, provided for reference.
---@field attributes[] any A table of common accessibility object attribute names which may be used with...
---@field orientations[] any A table of orientation types which may be used with hs.axuielement:elementSearch or hs.axuielement:matchesCriteria as...
---@field parameterizedAttributes[] any A table of common accessibility object parameterized attribute names, provided for reference.
---@field roles[] any A table of common accessibility object roles which may be used with hs.axuielement:elementSearch or...

--- A table of common accessibility object action names, provided for reference.
---@type table
hs.axuielement.actions[] = nil

--- A table of common accessibility object attribute names which may be used with
--- hs.axuielement:elementSearch
--- or
--- hs.axuielement:matchesCriteria
--- as keys in the match criteria argument.
---@type table
hs.axuielement.attributes[] = nil

--- A table of orientation types which may be used with
--- hs.axuielement:elementSearch
--- or
--- hs.axuielement:matchesCriteria
--- as attribute values for "AXOrientation" in the match criteria argument.
---@type table
hs.axuielement.orientations[] = nil

--- A table of common accessibility object parameterized attribute names, provided for reference.
---@type table
hs.axuielement.parameterizedAttributes[] = nil

--- A table of common accessibility object roles which may be used with
--- hs.axuielement:elementSearch
--- or
--- hs.axuielement:matchesCriteria
--- as attribute values for "AXRole" in the match criteria argument.
---@type table
hs.axuielement.roles[] = nil

--- A table of ruler marker types which may be used with
--- hs.axuielement:elementSearch
--- or
--- hs.axuielement:matchesCriteria
--- as attribute values for "AXMarkerType" in the match criteria argument.
---@type table
hs.axuielement.rulerMarkers[] = nil

--- A table of sort direction types which may be used with
--- hs.axuielement:elementSearch
--- or
--- hs.axuielement:matchesCriteria
--- as attribute values for "AXSortDirection" in the match criteria argument.
---@type table
hs.axuielement.sortDirections[] = nil

--- A table of common accessibility object subroles which may be used with
--- hs.axuielement:elementSearch
--- or
--- hs.axuielement:matchesCriteria
--- as attribute values for "AXSubrole" in the match criteria argument.
---@type table
hs.axuielement.subroles[] = nil

--- A table of measurement unit types which may be used with
--- hs.axuielement:elementSearch
--- or
--- hs.axuielement:matchesCriteria
--- as attribute values for attributes which specify measurement unit types (e.g. "AXUnits", "AXHorizontalUnits", and
--- "AXVerticalUnits") in the match criteria argument.
---@type table
hs.axuielement.units[] = nil

--- Returns a function for use with
--- hs.axuielement:elementSearch
--- that uses
--- hs.axuielement:matchesCriteria
--- with the specified criteria.
---@param criteria hs.axuielement
---@return function
function hs.axuielement.searchCriteriaFunction(criteria) end

--- Returns the top-level accessibility object for the application specified by the
--- hs.application
--- object.
---
--- Note: if applicationObject is a string or number, only the first item found with hs.application.find will be used
--- by this function to create an axuielementObject.
---@param applicationObject hs.application|hs.application.find
---@return hs.axuielement
function hs.axuielement.applicationElement(applicationObject) end

--- Returns the top-level accessibility object for the application with the specified process ID.
---@param pid string
---@return hs.axuielement
function hs.axuielement.applicationElementForPID(pid) end

--- Returns the accessibility object at the specified position on the screen. The top-left corner of the primary screen
--- is 0, 0.
---
--- Note: See also hs.axuielement:elementAtPosition -- this function is a shortcut for
--- hs.axuielement.systemWideElement():elementAtPosition(...) .
--- This function does hit-testing based on window z-order (that is, layering). If one window is on top of another
--- window, the returned accessibility object comes from whichever window is topmost at the specified location.
---@param x table
---@param y | pointTable any
---@return hs.axuielement
function hs.axuielement.systemElementAtPosition(x, y | pointTable) end

--- Returns an accessibility object that provides access to system attributes.
---@return hs.axuielement
function hs.axuielement.systemWideElement() end

--- Returns the accessibility object for the window specified by the
--- hs.window
--- object.
---
--- Note: if windowObject is a string or number, only the first item found with hs.window.find will be used by this
--- function to create an axuielementObject.
---@param windowObject hs.window|hs.window.find
---@return hs.axuielement
function hs.axuielement.windowElement(windowObject) end

--- Returns a localized description of the specified accessibility object's action.
---
--- Note: The action descriptions are provided by the target application; as such their accuracy and usefulness rely on
--- the target application's developers.
---@param action hs.axuielement
---@return string|nil
---@return any
function axuielement:actionDescription(action) end

--- Returns a list of all the actions the specified accessibility object can perform.
---
--- Note: Common action names can be found in the hs.axuielement.actions table; however, this method will list only
--- those names which are supported by this object, and is not limited to just those in the referenced table.
---@return table|nil
---@return any
function axuielement:actionNames() end

--- Returns a table containing key-value pairs for all attributes of the accessibility object.
---
--- Note: if includeErrors is not specified or is false, then attributes which exist for the element, but currently
--- have no value assigned, will not appear in the table. This is because Lua treats a nil value for a table's
--- key-value pair as an instruction to remove the key from the table, if it currently exists.
--- _code = -25212
--- error = "Requested value does not exist"
---@param includeErrors boolean|nil
---@return table|nil
---@return any
function axuielement:allAttributeValues(includeErrors) end

--- Query the accessibility object for all child accessibility objects and their descendants
---
--- Note: This method is syntactic sugar for hs.axuielement:elementSearch(callback, { [includeParents = withParents] })
--- . Please refer to hs.axuielement:elementSearch for details about the returned object and callback arguments.
---@param callback function
---@param withParents boolean|nil
---@return elementSearchObject
function axuielement:allDescendantElements(callback, withParents) end

--- If the element refers to an application, return an
--- hs.application
--- object for the element.
---
--- Note: An element is considered an application by this method if it has an AXRole of AXApplication and has a process
--- identifier (pid).
---@return hs.application|nil
function axuielement:asHSApplication() end

--- If the element refers to a window, return an
--- hs.window
--- object for the element.
---
--- Note: An element is considered a window by this method if it has an AXRole of AXWindow.
---@return hs.window|nil
function axuielement:asHSWindow() end

--- Returns a list of all the attributes supported by the specified accessibility object.
---
--- Note: Common attribute names can be found in the hs.axuielement.attributes tables; however, this method will list
--- only those names which are supported by this object, and is not limited to just those in the referenced table.
---@return table|nil
---@return any
function axuielement:attributeNames() end

--- Returns the value of an accessibility object's attribute.
---@param attribute hs.axuielement
---@return nil
---@return any
function axuielement:attributeValue(attribute) end

--- Returns the count of the array of an accessibility object's attribute value.
---@param attribute hs.axuielement
---@return number|nil
---@return any
function axuielement:attributeValueCount(attribute) end

--- Captures all of the available information for the accessibility object and its descendants and returns it in a
--- table for inspection.
---
--- Note: The format of the results table passed to the callback for this method is primarily for debugging and
--- exploratory purposes and may not be arranged for easy programatic evaluation.
--- This method is syntactic sugar for hs.axuielement:elementSearch(callback, { objectOnly = false, asTree = true,
--- [depth = depth], [includeParents = withParents] }) . Please refer to hs.axuielement:elementSearch for details about
--- the returned object and callback arguments.
---@param callback function
---@param depth number|nil
---@param withParents boolean
---@return elementSearchObject
function axuielement:buildTree(callback, depth, withParents) end

--- Returns a table containing only those immediate children of the element that perform the specified role.
---
--- Note: only the immediate children of the object are searched.
---@param role string
---@return table
function axuielement:childrenWithRole(role) end

--- Return a duplicate userdata reference to the Accessibility object.
---@return hs.axuielement
function axuielement:copy() end

--- Returns the accessibility object at the specified position on the screen. The top-left corner of the primary screen
--- is 0, 0.
---
--- Note: This method can only be called on an axuielementObject that represents an application or the system-wide
--- element (see hs.axuielement.systemWideElement ).
--- This function does hit-testing based on window z-order (that is, layering). If one window is on top of another
--- window, the returned accessibility object comes from whichever window is topmost at the specified location.
--- If this method is called on an axuielementObject representing an application, the search is restricted to the
--- application.
--- If this method is called on an axuielementObject representing the system-wide element, the search is not restricted
--- to any particular application.  See hs.axuielement.systemElementAtPosition .
---@param x table
---@param y | pointTable any
---@return hs.axuielement|nil
---@return any
function axuielement:elementAtPosition(x, y | pointTable) end

--- Search for and generate a table of the accessibility elements for the attributes and descendants of this object
--- based on the specified criteria.
---
--- Note: This method utilizes coroutines to keep Hammerspoon responsive, but may be slow to complete if includeParents
--- is true, if you do not specify depth , or if you start from an element that has a lot of descendants (e.g. the
--- application element for a web browser). This is dependent entirely upon how many active accessibility elements the
--- target application defines and where you begin your search and cannot reliably be determined up front, so you may
--- need to experiment to find the best balance for your specific requirements.
--- The search performed is a breadth-first search, so in general earlier elements in the results table will be
--- "closer" in the Accessibility hierarchy to the starting point than later elements.
--- The exception to this is when asTree is true and objectsOnly is false and the search criteria is nil -- see
--- hs.axuielement:buildTree . In this case, the results passed to the callback will be equal to elementSearchObject[1]
--- .
--- If objectsOnly is specified as false, it may take some time after cancel is invoked for the mapping of element
--- attribute tables to the descendant elements in the results set -- this is a by product of the need to iterate
--- through the results to match up all of the instances of each element to it's attribute table.
--- hs.axuielement:allDescendantElements is syntactic sugar for hs.axuielement:elementSearch(callback, {
--- [includeParents = withParents] })
--- hs.axuielement:buildTree is syntactic sugar for hs.axuielement:elementSearch(callback, { objectOnly = false, asTree
--- = true, [depth = depth], [includeParents = withParents] })
---@param callback function
---@param criteria hs.axuielement.searchCriteriaFunction|hs.axuielement|nil
---@param namedModifiers any
---@return elementSearchObject
function axuielement:elementSearch(callback, criteria, namedModifiers) end

--- Returns whether the specified accessibility object's attribute can be modified.
---@param attribute hs.axuielement
---@return boolean|nil
---@return any
function axuielement:isAttributeSettable(attribute) end

--- Returns whether the specified accessibility object is still valid.
---
--- Note: an accessibilityObject can become invalid for a variety of reasons, including but not limited to the element
--- referred to no longer being available (e.g. an element referring to a window or one of its descendants that has
--- been closed) or the application terminating.
---@return boolean|nil
---@return any
function axuielement:isValid() end

--- Returns true if the axuielementObject matches the specified criteria or false if it does not.
---
--- Note: a single string, specifying the value the element's AXRole attribute must equal for a positive match
--- an array table of strings specifying a list of possible values the element's AXRole attribute can equal for a
--- positive match
--- attribute -- a string, or table of strings, specifying attributes that the element must support.
--- action -- a string, or table of strings, specifying actions that the element must be able to perform.
--- parameterizedAttribute -- a string, or table of strings, specifying parametrized attributes that the element must
--- support.
--- only those keys which are specified within the value are checked for equality (or pattern matching). Values which
--- are present in the attribute's value but are not specified in the comparison value are ignored (i.e. the previous
--- example of y = 22 would only check the y component of an AXFrame attribute -- the x , h , and w values would be
--- ignored).
--- For value components which are numeric, e.g. 22 in the previous example, the default comparison is equality. You
--- may change this with the comparison key described below in the optional keys.
--- For possible keys when trying to match a color, see the documentation for hs.drawing.color .
--- For possible keys when trying to match a URL, use url = <string> and/or filePath = <string> . The string for the
--- specified table key will be compared in accordance with the pattern optional key described below.
--- Order of the elements provided in the comparison value does not matter -- this only tests for existence within the
--- attributes value.
--- The test is for inclusion only -- the attribute's value may contain other elements as well, but must contain those
--- specified within the comparison value.
--- nilValue -- a boolean, specifying that the attributes must not have an assigned value (true) or may be assigned any
--- value except nil (false). If the value key is specified, this key is ignored. Note that this applies to all of the
--- attributes specified with the attribute key.
--- pattern -- a boolean, default false, specifying whether string matches for attribute values should be evaluated
--- with string.match (true) or as exact matches (false). See the Lua manual, section 6.4.1 ( help.lua._man._6_4_1 in
--- the Hammerspoon console). If the value key is not set, than this key is ignored.
--- invert -- a boolean, default false, specifying inverted logic for the criteria result --- if this is true and the
--- criteria matches, evaluate criteria as false; otherwise evaluate as true.
--- comparison -- a string, default "==", specifying the comparison to be used when comparing numeric values. Possible
--- comparison strings are: "==" for equality, "<" for less than, "<=" for less than or equal to, ">" for greater than,
--- ">=" for greater than or equal to, or "~=" for not equal to.
--- an array table of one or more key-value tables as described immediately above; the element must be a positive match
--- for all of the individual criteria tables specified (logical AND).
--- This method is used by hs.axuielement.searchCriteriaFunction to create criteria functions compatible with
--- hs.axuielement:elementSearch .
---@param criteria any
---@return boolean
function axuielement:matchesCriteria(criteria) end

--- Returns a list of all the parameterized attributes supported by the specified accessibility object.
---@return table|nil
---@return any
function axuielement:parameterizedAttributeNames() end

--- Returns the value of an accessibility object's parameterized attribute.
---
--- Note: The specific parameter required for a each parameterized attribute is different and is often application
--- specific thus requiring some experimentation. Notes regarding identified parameter types and thoughts on some still
--- being investigated will be provided in the Hammerspoon Wiki, hopefully shortly after this module becomes part of a
--- Hammerspoon release.
---@param attribute hs.axuielement
---@param parameter any
---@return nil
---@return any
function axuielement:parameterizedAttributeValue(attribute, parameter) end

--- Returns a table of axuielements tracing this object through its parent objects to the root for this element, most
--- likely an application object or the system wide object.
---
--- Note: this object will always exist as the last element in the table (e.g. at table[#table] ) with its most
--- immediate parent at #table - 1 , etc. until the rootmost object for this element is reached at index position 1.
--- an axuielement object representing an application or the system wide object is its own rootmost object and will
--- return a table containing only itself (i.e. #table will equal 1)
---@return table
function axuielement:path() end

--- Requests that the specified accessibility object perform the specified action.
---
--- Note: The return value only suggests success or failure, but is not a guarantee.  The receiving application may
--- have internal logic which prevents the action from occurring at this time for some reason, even though this method
--- returns success (the axuielementObject).  Contrawise, the requested action may trigger a requirement for a response
--- from the user and thus appear to time out, causing this method to return false or nil.
---@param action hs.axuielement
---@return axuielement|boolean|nil
---@return any
function axuielement:performAction(action) end

--- Returns the process ID associated with the specified accessibility object.
---@return number|nil
---@return any
function axuielement:pid() end

--- Sets the accessibility object's attribute to the specified value.
---@param attribute hs.axuielement
---@param value any
---@return hs.axuielement|nil
---@return any
function axuielement:setAttributeValue(attribute, value) end

--- Sets the timeout value used accessibility queries performed from this element.
---
--- Note: To change the global timeout affecting all queries on elements which do not have a specific timeout set, use
--- this method on the systemwide element (see hs.axuielement.systemWideElement .
--- Changing the timeout value for an axuielement object only changes the value for that specific element -- other
--- axuieleement objects that may refer to the identical accessibility item are not affected.
--- Setting the value to 0.0 resets the timeout -- if applied to the systemWideElement , the global default will be
--- reset to its default value; if applied to another axuielement object, the timeout will be reset to the current
--- global value as applied to the systemWideElement.
---@param value number
---@return hs.axuielement|nil
---@return any
function axuielement:setTimeout(value) end

-- ------------------------------------------------------------
-- hs.axuielement.axtextmarker
-- ------------------------------------------------------------

---@class hs.axuielement.axtextmarker
hs.axuielement.axtextmarker = {}

---@class axtextmarker
local axtextmarker = {}

--- Returns a table of the AXTextMarker and AXTextMarkerRange functions that have been discovered and are used within
--- this module.
---
--- Note: the functions are defined within the HIServices framework which is part of the ApplicationServices framework,
--- so it is expected that the necessary functions will always be available; however, if you ever receive an error
--- message from a function or method within this submodule of the form "CF function AX... undefined", please see the
--- submodule heading documentation for a description of the information, including that which this function provides,
--- that should be included in any error report you submit.
--- This is for debugging purposes and is not expected to be used often.
---@return table
function hs.axuielement.axtextmarker._functionCheck() end

--- Returns a string containing the opaque binary data contained within the axTextMarkerObject
---
--- Note: the string will likely contain invalid UTF8 code sequences or unprintable ascii values; to see the data in
--- decimal or hexadecimal form you can use:
--- string.byte(hs.axuielement.axtextmarker:bytes(), 1, hs.axuielement.axtextmarker:length())
--- -- or
--- hs.utf8.hexDump(hs.axuielement.axtextmarker:bytes())
--- As the data is application specific, it is unlikely that you will use this method often; it is included primarily
--- for testing and debugging purposes.
---@return string|nil
---@return errorString
function axtextmarker:bytes() end

--- Returns the ending marker for an axTextMarkerRangeObject
---@return hs.axuielement.axtextmarker|nil
---@return errorString
function axtextmarker:endMarker() end

--- Returns an integer specifying the number of bytes in the data portion of the axTextMarkerObject.
---
--- Note: As the data is application specific, it is unlikely that you will use this method often; it is included
--- primarily for testing and debugging purposes.
---@return number|nil
---@return errorString
function axtextmarker:length() end

--- Returns the starting marker for an axTextMarkerRangeObject
---@return hs.axuielement.axtextmarker|nil
---@return errorString
function axtextmarker:startMarker() end

--- Creates a new AXTextMarker object from the string of binary data provided
---
--- Note: This function is included primarily for testing and debugging purposes -- in general you will probably never
--- use this constructor; AXTextMarker objects appear to be mostly application dependant and have no meaning external
--- to the application from which it was created.
---@param string string
---@return hs.axuielement.axtextmarker|nil
---@return errorString
function hs.axuielement.axtextmarker.newMarker(string) end

--- Creates a new AXTextMarkerRange object from the start and end markers provided
---
--- Note: this constructor can be used to create a range from axTextMarkerObjects obtained from an application to
--- specify a new range for a parameterized attribute. As a simple example (it is hoped that more will be added to the
--- Hammerspoon wiki shortly): s = hs . axuielement . applicationElement ( hs . application ( "Safari" )) -- for a
--- window displaying the DuckDuckGo main search page, this gets the -- primary display area. Other pages may vary and
--- you should build your -- object as necessary for your target. c = s ( "AXMainWindow" )( "AXSections" )[ 1 ].
--- SectionObject [ 1 ][ 1 ] start = c ( "AXStartTextMarker" ) -- get the text marker for the start of this element
--- ending = c ( "AXNextLineEndTextMarkerForTextMarker" , start ) -- get the next end of line marker print ( c (
--- "AXStringForTextMarkerRange" , hs . axuielement . axtextmarker . newRange ( start , ending ))) -- outputs "Privacy,
--- simplified." to the Hammerspoon console```
--- The specific attributes and parameterized attributes supported by a given application differ and can be discovered
--- with the hs.axuielement:getAttributeNames and hs.axuielement:getParameterizedAttributeNames methods.
---@param startMarker any
---@param endMarker any
---@return hs.axuielement.axtextmarker|nil
---@return errorString
function hs.axuielement.axtextmarker.newRange(startMarker, endMarker) end

-- ------------------------------------------------------------
-- hs.axuielement.observer
-- ------------------------------------------------------------

---@class hs.axuielement.observer
hs.axuielement.observer = {}

---@class observer
local observer = {}

--- A table of common accessibility object notification names, provided for reference.
---@type table
hs.axuielement.observer.notifications[] = nil

--- Creates a new observer object for the application with the specified process ID.
---
--- Note: If you already have the hs.application object for an application, you can get its process ID with
--- hs.application:pid()
--- If you already have an hs.axuielement from the application you wish to observe (it doesn't have to be the
--- application axuielement object, just one belonging to the application), you can get the process ID with
--- hs.axuielement:pid() .
---@param pid string
---@return hs.axuielement.observer
function hs.axuielement.observer.new(pid) end

--- Registers the specified notification for the specified accessibility element with the observer.
---
--- Note: multiple notifications for the same accessibility element can be registered by invoking this method multiple
--- times with the same element but different notification strings.
--- if the specified element and notification string are already registered, this method does nothing.
--- the notification string is application dependent and can be any string that the application developers choose; some
--- common ones are found in hs.axuielement.observer.notifications , but the list is not exhaustive nor is an
--- application or element required to provide them.
---@param element hs.axuielement
---@param notification string
---@return hs.axuielement.observer
function observer:addWatcher(element, notification) end

--- Get or set the callback for the observer.
---
--- Note: the observerObject itself
--- the hs.axuielement object for the accessibility element which generated the notification
--- a string specifying the specific notification which was received
--- a table containing key-value pairs with more information about the notification, if the element and notification
--- type provide it. Commonly this will be an empty table indicating that no additional detail was provided.
---@param fn function
---@return hs.axuielement.observer|fn|nil
function observer:callback(fn) end

--- Returns true or false indicating whether the observer is currently watching for notifications and generating
--- callbacks.
---@return boolean
function observer:isRunning() end

--- Unregisters the specified notification for the specified accessibility element from the observer.
---
--- Note: if the specified element and notification string are not currently registered with the observer, this method
--- does nothing.
---@param element hs.axuielement
---@param notification string
---@return hs.axuielement.observer
function observer:removeWatcher(element, notification) end

--- Start observing the application and trigger callbacks for the elements and notifications assigned.
---
--- Note: This method does nothing if the observer is already running
---@return hs.axuielement.observer
function observer:start() end

--- Stop observing the application; no further callbacks will be generated.
---
--- Note: This method does nothing if the observer is not currently running
---@return hs.axuielement.observer
function observer:stop() end

--- Returns a table of the notifications currently registered with the observer.
---
--- Note: If an element is specified, then the table returned will contain a list of strings specifying the specific
--- notifications that the observer is watching that element for.
--- If no argument is specified, then the table will contain key-value pairs in which each key will be an
--- hs.axuielement that is being observed and the corresponding value will be a table containing a list of strings
--- specifying the specific notifications that the observer is watching for from that element.
---@param element hs.axuielement|nil
---@return table
function observer:watching(element) end

-- ------------------------------------------------------------
-- hs.base64
-- ------------------------------------------------------------

---@class hs.base64
hs.base64 = {}

--- Decodes a given base64 string
---@param str string
---@return val
function hs.base64.decode(str) end

--- Encodes a given string to base64
---@param val string
---@param width? number
---@return str
function hs.base64.encode(val, width) end

-- ------------------------------------------------------------
-- hs.battery
-- ------------------------------------------------------------

---@class hs.battery
hs.battery = {}

--- Returns a table containing all of the details concerning the Mac's powersource(s).
---
--- Note: hs.battery._adapterDetails()
--- hs.battery._powerSources()
--- hs.battery._appleSmartBattery()
--- hs.battery._iopmBatteryInfo()
--- You can view this report by typing hs.inspect(hs.battery._report()) (or a subset of it by using one of the above
--- listed functions instead) -- it will primarily be of interest when debugging or extending this module and generally
--- not necessary to use.
---@return table
function hs.battery._report() end

--- Returns the serial number of the attached power supply, if present
---@return number|string
function hs.battery.adapterSerialNumber() end

--- Returns the amount of current flowing through the battery, in mAh
---@return number
function hs.battery.amperage() end

--- Returns the serial number of the battery, if present
---@return string
function hs.battery.batterySerialNumber() end

--- Returns the type of battery present, or nil if there is no battery
---@return string
function hs.battery.batteryType() end

--- Returns the current capacity of the battery in mAh
---
--- Note: This is the measure of how charged the battery is, vs the value of hs.battery.maxCapacity()
---@return number
function hs.battery.capacity() end

--- Returns the number of discharge cycles of the battery
---
--- Note: One cycle is a full discharge of the battery, followed by a full charge. This may also be an aggregate of
--- many smaller discharge-then-charge cycles (e.g. 10 iterations of discharging the battery from 100% to 90% and then
--- charging back to 100% each time, is considered to be one cycle)
---@return number
function hs.battery.cycles() end

--- Returns the design capacity of the battery in mAh.
---@return number
function hs.battery.designCapacity() end

--- Get all available battery information
---
--- Note: If you require multiple pieces of information about a battery, this function may be more efficient than
--- calling several other functions separately
---@return table
function hs.battery.getAll() end

--- Returns the health status of the battery.
---@return string
function hs.battery.health() end

--- Returns the health condition status of the battery.
---@return string|nil
function hs.battery.healthCondition() end

--- Returns the charged state of the battery
---@return boolean
function hs.battery.isCharged() end

--- Returns the charging state of the battery
---@return boolean
function hs.battery.isCharging() end

--- Returns true if battery is finishing its charge
---@return boolean|string
function hs.battery.isFinishingCharge() end

--- Returns the maximum capacity of the battery in mAh
---
--- Note: This may exceed the value of hs.battery.designCapacity() due to small variations in the production chemistry
--- vs the design
---@return number
function hs.battery.maxCapacity() end

--- Returns the name of the battery
---@return string
function hs.battery.name() end

--- Returns information about non-PSU batteries (e.g. Bluetooth accessories)
---@return table
function hs.battery.otherBatteryInfo() end

--- Returns the current percentage of battery charge
---@return number
function hs.battery.percentage() end

--- Returns the current source providing power
---@return string
function hs.battery.powerSource() end

--- Returns current power source type
---@return string
function hs.battery.powerSourceType() end

--- Returns information about Bluetooth devices using Apple Private APIs
---
--- Note: This function uses private Apple APIs - that means it can break without notice on any macOS version update.
--- Please report breakage to us!
--- This function will return information for all connected Bluetooth devices, but much of it will be meaningless for
--- most devices
--- vendorID - Numerical identifier for the vendor of the device (Apple's ID is 76)
--- productID - Numerical identifier for the device
--- address - The Bluetooth address of the device
--- isApple - A string containing "YES" or "NO", depending on whether or not this is an Apple/Beats product, or a third
--- party product
--- name - A human readable string containing the name of the device
--- batteryPercentSingle - For some devices this will contain the percentage of the battery (e.g. Beats headphones)
--- batteryPercentCombined - We do not currently understand what this field represents, please report if you find a
--- non-zero value here
--- batteryPercentCase - Battery percentage of AirPods cases (note that this will often read 0 - the AirPod case sleeps
--- aggressively)
--- batteryPercentLeft - Battery percentage of the left AirPod if it is out of the case
--- batteryPercentRight - Battery percentage of the right AirPod if it is out of the case
--- buttonMode - We do not currently understand what this field represents, please report if you find a value other
--- than 1
--- micMode - For AirPods this corresponds to the microphone option in the device's Bluetooth options
--- leftDoubleTap - For AirPods this corresponds to the left double tap action in the device's Bluetooth options
--- rightDoubleTap - For AirPods this corresponds to the right double tap action in the device's Bluetooth options
--- primaryBud - For AirPods this is either "left" or "right" depending on which bud is currently considered the
--- primary device
--- primaryInEar - For AirPods this is "YES" or "NO" depending on whether or not the primary bud is currently in an ear
--- secondaryInEar - For AirPods this is "YES" or "NO" depending on whether or not the secondary bud is currently in an
--- ear
--- isInEarDetectionSupported - Whether or not this device can detect when it is currently in an ear
--- isEnhancedDoubleTapSupported - Whether or not this device supports double tapping
--- isANCSupported - We believe this likely indicates whether or not this device supports Active Noise Cancelling (e.g.
--- Beats Solo)
--- Please report any crashes from this function - it's likely that there are Bluetooth devices we haven't tested which
--- may return weird data
--- Many/Most/All non-Apple party products will likely return zeros for all of the battery related fields here, as will
--- Apple HID devices. It seems that these private APIs mostly exist to support Apple/Beats headphones.
---@return table
function hs.battery.privateBluetoothBatteryInfo() end

--- Returns the battery life remaining, in minutes
---@return number
function hs.battery.timeRemaining() end

--- Returns the time remaining for the battery to be fully charged, in minutes
---@return number
function hs.battery.timeToFullCharge() end

--- Returns the current voltage of the battery in mV
---@return number
function hs.battery.voltage() end

--- Returns a string specifying the current battery warning state.
---
--- Note: "none" - indicates that the system is not in a low battery situation, or is currently attached to an AC power
--- source.
--- "low"  - the system is in a low battery situation and can provide no more than 20 minutes of runtime. Note that
--- this is a guess only; 20 minutes cannot be guaranteed and will be greatly influenced by what the computer is doing
--- at the time, how many applications are running, screen brightness, etc.
--- "critical" - the system is in a very low battery situation and can provide no more than 10 minutes of runtime. Note
--- that this is a guess only; 10 minutes cannot be guaranteed and will be greatly influenced by what the computer is
--- doing at the time, how many applications are running, screen brightness, etc.
---@return string
function hs.battery.warningLevel() end

--- Returns the power entering or leaving the battery, in W
---@return number
function hs.battery.watts() end

-- ------------------------------------------------------------
-- hs.battery.watcher
-- ------------------------------------------------------------

---@class hs.battery.watcher
hs.battery.watcher = {}

---@class watcher
local watcher = {}

--- Creates a battery watcher
---
--- Note: Because the callback function accepts no arguments, tracking of state of changing battery attributes is the
--- responsibility of the user (see https://github.com/Hammerspoon/hammerspoon/issues/166 for discussion)
---@param fn function
---@return watcher
function hs.battery.watcher.new(fn) end

--- Starts the battery watcher
---@return self
function watcher:start() end

--- Stops the battery watcher
---@return self
function watcher:stop() end

-- ------------------------------------------------------------
-- hs.bonjour
-- ------------------------------------------------------------

---@class hs.bonjour
hs.bonjour = {}

---@class bonjour
local bonjour = {}

--- Polls a host for the service types it is advertising via multicast DNS.
---
--- Note: this function may not work for all clients implementing multicast DNS; it has been successfully tested with
--- macOS and Linux targets running the Avahi Daemon service, but has generally returned an error when used with
--- minimalist implementations found in common IOT devices and embedded electronics.
---@param target string
---@param callback function
---@return none
function hs.bonjour.machineServices(target, callback) end

--- Returns a list of service types being advertised on your local network.
---
--- Note: This function is a convenience wrapper to hs.bonjour:findServices which collects the results from multiple
--- callbacks made to findServices and returns them all at once to the callback function provided as an argument to
--- this function.
--- This is a best guess made by the macOS which may not always be accurate if your local network is particularly slow
--- or if there are machines on your network which are slow to respond.
--- See hs.bonjour:findServices for more details if you need to create your own query which can persist for longer
--- periods of time or require termination logic that ignores the macOS's best guess.
---@param callback function
---@param timeout function|nil
---@return none
function hs.bonjour.networkServices(callback, timeout) end

--- Creates a new network service browser that finds published services on a network using multicast DNS.
---@return hs.bonjour
function hs.bonjour.new() end

--- Return a list of zero-conf and bonjour domains visible to the users computer.
---
--- Note: This method returns domains which are visible to your machine; however, your machine may or may not be able
--- to access or publish records within the returned domains. See hs.bonjour:findRegistrationDomains
--- For most non-corporate network users, it is likely that the callback will only be invoked once for the local
--- domain. This is normal. Corporate networks or networks including Linux machines using additional domains defined
--- with Avahi may see additional domains as well, though most Avahi installations now use only 'local' by default
--- unless specifically configured to do otherwise.
--- Generally macOS is fairly accurate in this regard concerning domain searches, so to reduce the impact on system
--- resources, it is recommended that you use hs.bonjour:stop when this parameter is false
---@param callback function
---@return hs.bonjour
function bonjour:findBrowsableDomains(callback) end

--- Return a list of zero-conf and bonjour domains this computer can register services in.
---
--- Note: This is the preferred method for accessing domains as it guarantees that the host machine can connect to
--- services in the returned domains. Access to domains outside this list may be more limited. See also
--- hs.bonjour:findBrowsableDomains
--- For most non-corporate network users, it is likely that the callback will only be invoked once for the local
--- domain. This is normal. Corporate networks or networks including Linux machines using additional domains defined
--- with Avahi may see additional domains as well, though most Avahi installations now use only 'local' by default
--- unless specifically configured to do otherwise.
--- Generally macOS is fairly accurate in this regard concerning domain searches, so to reduce the impact on system
--- resources, it is recommended that you use hs.bonjour:stop when this parameter is false
---@param callback function
---@return hs.bonjour
function bonjour:findRegistrationDomains(callback) end

--- Find advertised services of the type specified.
---
--- Note: macOS will indicate when it believes there are no more advertisements of the type specified by type in domain
--- by marking the last argument to your callback function as false. This is a best guess and may not always be
--- accurate if your network is slow or some servers on your network are particularly slow to respond.
--- In addition, if you leave the browser running this method, you will get future updates when services are removed
--- because of server shutdowns or added because of new servers being booted up.
--- Leaving the browser running does consume some system resources though, so you will have to determine, based upon
--- your specific requirements, if this is a concern for your specific task or not. To terminate the browser when you
--- have retrieved all of the information you require, you can use the hs.bonjour:stop method.
--- this special type is used by the shortcut function hs.bonjour.networkServices for this specific purpose.
--- In theory, with additional software, you may be able to publish services on your machine for Wide-Area Service
--- discovery using this domain with hs.bonjour.service.new but the local dns server requirements and security
--- implications of doing so are beyond the scope of this documentation. You should refer to http://www.dns-sd.org and
--- your local DNS Server administrator or provider for more details.
---@param type string
---@param domain string|nil
---@param callback function
---@return hs.bonjour
function bonjour:findServices(type, domain, callback) end

--- Get or set whether to also browse over peer-to-peer Bluetooth and Wi-Fi, if available.
---
--- Note: This property must be set before initiating a search to have an effect.
---@param value boolean|nil
---@return hs.bonjour
function bonjour:includesPeerToPeer(value) end

--- Stops a currently running search or resolution for the browser object
---
--- Note: This method should be invoked when you have identified the services or hosts you require to reduce the
--- consumption of system resources.
--- Invoking this method on an already idle browser will do nothing
--- In general, when your callback function for hs.bonjour:findBrowsableDomains , hs.bonjour:findRegistrationDomains ,
--- or hs.bonjour:findServices receives false for the moreExpected parameter, you should invoke this method on the
--- browserObject unless there are specific reasons not to. Possible reasons you might want to extend the life of the
--- browserObject are documented within each method.
---@return hs.bonjour
function bonjour:stop() end

-- ------------------------------------------------------------
-- hs.bonjour.service
-- ------------------------------------------------------------

---@class hs.bonjour.service
hs.bonjour.service = {}

---@class service
local service = {}

--- A list of common service types which can used for discovery through this module.
---@type common[]
hs.bonjour.serviceTypes = nil

--- Returns a new serviceObject for advertising a service provided by your computer.
---
--- Note: If the name specified is not unique on the network for the service type specified, then a number will be
--- appended to the end of the name. This behavior cannot be overridden and can only be detected by checking
--- hs.bonjour.service:name after hs.bonjour.service:publish is invoked to see if the name has been changed from what
--- you originally assigned.
--- The service will not be advertised until hs.bonjour.service:publish is invoked on the serviceObject returned.
--- If you do not specify the domain parameter, your default domain, usually "local" will be used.
---@param name string
---@param service string
---@param port any
---@param domain string|nil
---@return hs.bonjour.service
function hs.bonjour.service.new(name, service, port, domain) end

--- Returns a new serviceObject for a remote machine (i.e. not the users computer) on your network offering the
--- specified service.
---
--- Note: In general you should not need to use this constructor, as they will be created automatically for you in the
--- callbacks to hs.bonjour:findServices .
--- This method can be used, however, when you already know that a specific service should exist on the network and you
--- wish to resolve its current IP addresses or text records.
--- Resolution of the service ip address, hostname, port, and current text records will not occur until
--- hs.bonjour.service:publish is invoked on the serviceObject returned.
--- The macOS API specifies that an empty domain string (i.e. specifying the domain parameter as "" or leaving it off
--- completely) should result in using the default domain for the computer; in my experience this results in an error
--- when attempting to resolve the serviceObject's ip addresses if I don't specify "local" explicitly. In general this
--- shouldn't be an issue if you limit your use of remote serviceObjects to those returned by hs.bonjour:findServices
--- as the domain of discovery will be included in the object for you automatically. If you do try to create these
--- objects independently yourself, be aware that attempting to use the "default domain" rather than specifying it
--- explicitly will probably not work as expected.
---@param name string
---@param service string
---@param domain string|nil
---@return hs.bonjour.service
function hs.bonjour.service.remote(name, service, domain) end

--- Returns a table listing the addresses for the service represented by the serviceObject
---
--- Note: for remote serviceObjects, the table will be empty if this method is invoked before
--- hs.bonjour.service:resolve .
--- for local (published) serviceObjects, this table will always be empty.
---@return table
function service:addresses() end

--- Returns the domain the service represented by the serviceObject belongs to.
---
--- Note: for remote serviceObjects, this domain will be the domain the service was discovered in.
--- for local (published) serviceObjects, this domain will be the domain the service is published in; if you did not
--- specify a domain with hs.bonjour.service.new then this will be an empty string until hs.bonjour.service:publish is
--- invoked.
---@return string
function service:domain() end

--- Returns the hostname of the machine the service represented by the serviceObject belongs to.
---
--- Note: for remote serviceObjects, this will be nil if this method is invoked before hs.bonjour.service:resolve .
--- for local (published) serviceObjects, this method will always return nil.
---@return string
function service:hostname() end

--- Get or set whether the service represented by the service object should be published or resolved over peer-to-peer
--- Bluetooth and Wi-Fi, if available.
---
--- Note: if you are changing the value of this property, you must call this method before invoking
--- [hs.bonjour.service:publish](#publish] or hs.bonjour.service:resolve , or after stopping publishing or resolving
--- with hs.bonjour.service:stop .
--- for remote serviceObjects, this flag determines if resolution and text record monitoring should occur over
--- peer-to-peer network interfaces.
--- for local (published) serviceObjects, this flag determines if advertising should occur over peer-to-peer network
--- interfaces.
---@param value boolean|nil
---@return boolean|hs.bonjour.service
function service:includesPeerToPeer(value) end

--- Monitor the service for changes to its associated text records.
---
--- Note: When monitoring is active, hs.bonjour.service:txtRecord will return the most recent text records observed. If
--- this is the only method by which you check the text records, but you wish to ensure you have the most recent
--- values, you should invoke this method without specifying a callback.
--- When hs.bonjour.service:resolve is invoked, the text records at the time of resolution are captured for retrieval
--- with hs.bonjour.service:txtRecord . Subsequent changes to the text records will not be reflected by
--- hs.bonjour.service:txtRecord unless this method has been invoked (with or without a callback function) and is
--- currently active.
--- You can monitor for text changes on local serviceObjects that were created by hs.bonjour.service.new and that you
--- are publishing. This can be used to invoke a callback when one portion of your code makes changes to the text
--- records you are publishing and you need another portion of your code to be aware of this change.
---@param callback function
---@return hs.bonjour.service
function service:monitor(callback) end

--- Returns the name of the service represented by the serviceObject.
---@return string
function service:name() end

--- Returns the port the service represented by the serviceObject is available on.
---
--- Note: for remote serviceObjects, this will be -1 if this method is invoked before hs.bonjour.service:resolve .
--- for local (published) serviceObjects, this method will always return the number specified when the serviceObject
--- was created with the hs.bonjour.service.new constructor.
---@return number
function service:port() end

--- Begin advertising the specified local service.
---
--- Note: this method should only be called on serviceObjects which were created with hs.bonjour.service.new .
---@param allowRename boolean|nil
---@param callback function
---@return hs.bonjour.service
function service:publish(allowRename, callback) end

--- Resolve the address and details for a discovered service.
---
--- Note: this method should only be called on serviceObjects which were returned by an hs.bonjour browserObject or
--- created with hs.bonjour.service.remote .
--- For a remote service, this method must be called in order to retrieve the addresses , the port , the hostname , and
--- any the associated text records for the service.
--- To reduce the usage of system resources, you should generally specify a timeout value or make sure to invoke
--- hs.bonjour.service:stop after you have verified that you have received the details you require.
---@param timeout number|nil
---@param callback function
---@return hs.bonjour.service
function service:resolve(timeout, callback) end

--- Stop advertising or resolving the service specified by the serviceObject
---
--- Note: this method will stop the advertising of a service which has been published with hs.bonjour.service:publish
--- or is being resolved with hs.bonjour.service:resolve .
--- To reduce the usage of system resources, you should make sure to use this method when resolving a remote service if
--- you did not specify a timeout for hs.bonjour.service:resolve or specified a timeout of 0.0 once you have verified
--- that you have the details you need.
---@return hs.bonjour.service
function service:stop() end

--- Stop monitoring a service for changes to its text records.
---
--- Note: This method will stop updating hs.bonjour.service:txtRecord and invoking the callback, if any, assigned with
--- hs.bonjour.service:monitor .
---@return hs.bonjour.service
function service:stopMonitoring() end

--- Get or set the text records associated with the serviceObject.
---
--- Note: for remote serviceObjects, this method will return nil if invoked before hs.bonjour.service:resolve
--- setting the text record for a service replaces the existing records for the serviceObject. If the serviceObject is
--- remote, this change is only visible on the local machine. For a service you are advertising, this change will be
--- advertised to other machines.
--- Text records are usually used to provide additional information concerning the service and their purpose and
--- meanings are service dependant; for example, when advertising an _http._tcp. service, you can specify a specific
--- path on the server by specifying a table of text records containing the "path" key.
---@param records table|nil
---@return table|hs.bonjour.service|boolean
function service:txtRecord(records) end

--- Returns the type of service represented by the serviceObject.
---@return string
function service:type() end

-- ------------------------------------------------------------
-- hs.brightness
-- ------------------------------------------------------------

---@class hs.brightness
hs.brightness = {}

--- Gets the current ambient brightness
---
--- Note: Even though external Apple displays include an ambient light sensor, their data is typically not available,
--- so this function will likely only be useful to MacBook users
--- On Silicon based macs, this function uses a method similar to that used by corebrightnessdiag to retrieve the
--- aggregate lux as reported to sysdiagnose .
--- On Intel based macs, the raw sensor data is converted to lux via an algorithm used by Mozilla Firefox and is not
--- guaranteed to give an accurate lux value.
---@return number
function hs.brightness.ambient() end

--- Returns the current brightness of the display
---@return number
function hs.brightness.get() end

--- Sets the display brightness
---@param brightness number
---@return boolean
function hs.brightness.set(brightness) end

-- ------------------------------------------------------------
-- hs.caffeinate
-- ------------------------------------------------------------

---@class hs.caffeinate
hs.caffeinate = {}

--- Fetches information about processes which are currently asserting display/power sleep restrictions
---@return table
function hs.caffeinate.currentAssertions() end

--- Informs the OS that the user performed some activity
---
--- Note: This is intended to simulate user activity, for example to prevent displays from sleeping, or to wake them up
--- It is not mandatory to re-use assertion IDs if you are calling this function multiple times, but it is recommended
--- that you do so if the calls are related
---@param id number
---@return number
function hs.caffeinate.declareUserActivity(id) end

--- Show the Fast User Switch screen (ie a login screen without logging out first)
---@return any
function hs.caffeinate.fastUserSwitch() end

--- Queries whether a particular sleep type is being prevented
---@param sleepType string
---@return boolean|nil
function hs.caffeinate.get(sleepType) end

--- Locks the displays
---
--- Note: This function uses private Apple APIs and could therefore stop working in any given release of macOS without
--- warning.
---@return any
function hs.caffeinate.lockScreen() end

--- Request the system log out the current user
---@return any
function hs.caffeinate.logOut() end

--- Request the system reboot
---@return any
function hs.caffeinate.restartSystem() end

--- Fetches information from the display server about the current session
---
--- Note: The keys in this dictionary will vary based on the current state of the system (e.g. local vs VNC login,
--- screen locked vs unlocked).
---@return table|nil
function hs.caffeinate.sessionProperties() end

--- Configures the sleep prevention settings
---
--- Note: These calls are not guaranteed to prevent the system sleep behaviours described above. The OS may override
--- them if it feels it must (e.g. if your CPU temperature becomes dangerously high).
--- The acAndBattery argument only applies to the system sleep type.
--- You can toggle the acAndBattery state by calling hs.caffeinate.set() again and altering the acAndBattery value.
--- The acAndBattery option does not appear to work anymore - it is based on private API that is not allowed in macOS
--- 10.15 when running with the Hardened Runtime (which Hammerspoon now uses).
---@param sleepType any
---@param aValue boolean
---@param acAndBattery boolean
---@return any
function hs.caffeinate.set(sleepType, aValue, acAndBattery) end

--- Request the system log out and power down
---@return any
function hs.caffeinate.shutdownSystem() end

--- Request the system start the screensaver (which may lock the screen if the OS is configured to do so)
---@return any
function hs.caffeinate.startScreensaver() end

--- Requests the system to sleep immediately
---@return any
function hs.caffeinate.systemSleep() end

--- Toggles the current state of the specified type of sleep
---
--- Note: If systemIdle is toggled to on, it will apply to AC only
---@param sleepType string
---@return boolean|nil
function hs.caffeinate.toggle(sleepType) end

-- ------------------------------------------------------------
-- hs.caffeinate.watcher
-- ------------------------------------------------------------

---@class hs.caffeinate.watcher
hs.caffeinate.watcher = {}

---@class watcher
local watcher = {}

---@class hs.caffeinate.watcher.watcher
---@field screensaverDidStart any The screensaver started
---@field screensaverDidStop any The screensaver stopped
---@field screensaverWillStop any The screensaver is about to stop
---@field screensDidLock any The screen was locked
---@field screensDidSleep any The displays have gone to sleep

--- The screensaver started
---@type any
hs.caffeinate.watcher.screensaverDidStart = nil

--- The screensaver stopped
---@type any
hs.caffeinate.watcher.screensaverDidStop = nil

--- The screensaver is about to stop
---@type any
hs.caffeinate.watcher.screensaverWillStop = nil

--- The screen was locked
---@type any
hs.caffeinate.watcher.screensDidLock = nil

--- The displays have gone to sleep
---@type any
hs.caffeinate.watcher.screensDidSleep = nil

--- The screen was unlocked
---@type any
hs.caffeinate.watcher.screensDidUnlock = nil

--- The displays have woken from sleep
---@type any
hs.caffeinate.watcher.screensDidWake = nil

--- The session became active, due to fast user switching
---@type any
hs.caffeinate.watcher.sessionDidBecomeActive = nil

--- The session is no longer active, due to fast user switching
---@type any
hs.caffeinate.watcher.sessionDidResignActive = nil

--- The system woke from sleep
---@type any
hs.caffeinate.watcher.systemDidWake = nil

--- The user requested a logout or shutdown
---@type any
hs.caffeinate.watcher.systemWillPowerOff = nil

--- The system is preparing to sleep
---@type any
hs.caffeinate.watcher.systemWillSleep = nil

--- Creates a watcher object for system and display sleep/wake/power events
---@param fn function
---@return watcher
function hs.caffeinate.watcher.new(fn) end

--- Starts the sleep/wake watcher
---@return hs.caffeinate.watcher
function watcher:start() end

--- Stops the sleep/wake watcher
---@return hs.caffeinate.watcher
function watcher:stop() end

-- ------------------------------------------------------------
-- hs.camera
-- ------------------------------------------------------------

---@class hs.camera
hs.camera = {}

---@class camera
local camera = {}

--- Get all the cameras known to the system
---@return table
function hs.camera.allCameras() end

--- Checks if the camera devices watcher is running
---@return Boolean
function hs.camera.isWatcherRunning() end

--- Sets/clears the callback function for the camera devices watcher
---
--- Note: The callback will be called when a camera is added or removed from the system
--- To watch for changes within a single camera device, see hs.camera:newWatcher()
--- The callback function arguments are:
--- An hs.camera device object for the affected device
--- A string, either "Added" or "Removed" depending on whether the device was added or removed from the system
--- For "Removed" events, most methods on the hs.camera device object will not function correctly anymore and the
--- device object passed to the callback is likely to be useless. It is recommended you re-check hs.camera.allCameras()
--- and keep records of the cameras you care about
--- Passing nil will cause the watcher to stop if it is running
---@param fn function|nil
---@return any
function hs.camera.setWatcherCallback(fn) end

--- Starts the camera devices watcher
---@return any
function hs.camera.startWatcher() end

--- Stops the camera devices watcher
---@return any
function hs.camera.stopWatcher() end

--- Get the raw connection ID of the camera
---@return String
function camera:connectionID() end

--- Get the usage status of the camera
---@return Boolean
function camera:isInUse() end

--- Checks if the property watcher on a camera object is running
---@return boolean
function camera:isPropertyWatcherRunning() end

--- Get the name of the camera
---@return String
function camera:name() end

--- Sets or clears a callback for when the properties of an hs.camera object change
---@param fn function
---@return hs.camera
function camera:setPropertyWatcherCallback(fn) end

--- Starts the property watcher on a camera
---@return hs.camera
function camera:startPropertyWatcher() end

--- Stops the property watcher on a camera
---@return hs.camera
function camera:stopPropertyWatcher() end

--- Get the UID of the camera
---
--- Note: The UID is not guaranteed to be stable across reboots
---@return String
function camera:uid() end

-- ------------------------------------------------------------
-- hs.canvas
-- ------------------------------------------------------------

---@class hs.canvas
---@field attributes any Canvas Element Attributes
---@field object[index] any An array-like method for accessing the attributes for the canvas element at the specified index
---@field percentages any Canvas attributes which specify the location and size of canvas elements can be specified with an absolute position or...
hs.canvas = {}

---@class canvas
---@field object[index] any An array-like method for accessing the attributes for the canvas element at the specified index
---@field percentages any Canvas attributes which specify the location and size of canvas elements can be specified with an absolute position or...
local canvas = {}

--- A table containing the possible compositing rules for elements within the canvas.
---@type table
hs.canvas.compositeTypes[] = nil

--- Array of window behavior labels for determining how a canvas or drawing object is handled in Spaces and Exposé
---@type hs.window[]
hs.canvas.windowBehaviors[] = nil

--- A table of predefined window levels usable with
--- hs.canvas:level
---@type table
hs.canvas.windowLevels = nil

--- Returns a table containing the default font, size, color, and paragraphStyle used by
--- hs.canvas
--- for text drawing objects.
---
--- Note: This method is intended to be used in conjunction with hs.styledtext to create styledtext objects that are
--- based on, or a slight variation of, the defaults used by hs.canvas .
---@return table
function hs.canvas.defaultTextStyle() end

--- Returns the list of attributes and their specifications that are recognized for canvas elements by this module.
---
--- Note: This is primarily for debugging purposes and may be removed in the future.
---@return table
function hs.canvas.elementSpec() end

--- Provides specification information for the recognized attributes, or the specific attribute specified.
---@param attribute string|nil
---@return string
function hs.canvas.help(attribute) end

--- Get or set whether or not canvas objects use a custom accessibility subrole for the containing system window.
---
--- Note: Under some conditions, it has been observed that Hammerspoon's hs.window.filter module will misidentify
--- Canvas and Drawing objects as windows of the Hammerspoon application that it should consider when evaluating its
--- filters. To eliminate this, hs.canvas objects (and previously hs.drawing objects, which are now deprecated and pass
--- through to hs.canvas ) were given a nonstandard accessibility subrole to prevent them from being included. This has
--- caused some issues with third party tools, like Yabai, which also use the accessibility subroles for determining
--- what actions it may take with Hammerspoon windows.
--- By passing false to this function, all canvas objects will revert to specifying the standard subrole for the
--- containing windows by default and should work as expected with third party tools. Note that this may cause issues
--- or slowdowns if you are also using hs.window.filter ; a more permanent solution is being considered.
--- If you need to control the subrole of canvas objects more specifically, or only for some canvas objects, see
--- hs.canvas:_accessibilitySubrole .
---@deprecated
---@param state boolean
---@return boolean
function hs.canvas.useCustomAccessibilitySubrole(state) end

--- Create a new canvas object at the specified coordinates
---
--- Note: The size of the canvas defines the visible area of the canvas -- any portion of a canvas element which
--- extends past the canvas's edges will be clipped.
--- a rect-table is a table with key-value pairs specifying the top-left coordinate on the screen for the canvas (keys
--- x and y ) and the size (keys h and w ) of the canvas. The table may be crafted by any method which includes these
--- keys, including the use of an hs.geometry object.
---@param rect table
---@return hs.canvas
function hs.canvas.new(rect) end

--- Get or set the accessibility subrole returned by
--- hs.canvas
--- objects.
---
--- Note: Most people will probably not need to use this method; See hs.canvas.useCustomAccessibilitySubrole for a
--- discussion as to why this method may be of use when Hammerspoon is being controlled through the accessibility
--- framework by other applications.
--- If a non empty string is specified as the argument to this method, the string will be returned whenever the canvas
--- object's containing window is queried for its accessibility subrole.
--- If an explicit nil (the default) is specified for this method, the string returned when the canvas object's
--- accessibility is queried will be the default macOS subrole for the canvas's window with the string ".Hammerspoon`
--- appended to it.
--- If the empty string is specified (e.g. "" ), then the default macOS subrole for the canvas's window will be
--- returned.
--- If an explicit nil (the default) is specified for this method, then the default macOS subrole for the canvas's
--- window will be returned.
--- If the empty string is specified (e.g. "" ), the string returned when the canvas object's accessibility is queried
--- will be the default macOS subrole for the canvas's window with the string ".Hammerspoon` appended to it.
---@param subrole string|nil
---@return hs.canvas
function canvas:_accessibilitySubrole(subrole) end

--- Get or set the alpha level of the window containing the canvasObject.
---@param alpha number|nil
---@return hs.canvas
function canvas:alpha(alpha) end

--- Appends the elements specified to the canvas.
---
--- Note: You can also specify multiple elements in a table as an array, where each index in the table contains an
--- element table, and use the array as a single argument to this method if this style works better in your code.
---@param element... any
---@return hs.canvas
function canvas:appendElements(element...) end

--- Assigns a new element to the canvas at the specified index.
---
--- Note: When the index specified is the canvas element count + 1, the behavior of this method is the same as
--- hs.canvas:insertElement ; i.e. it adds the new element to the end of the currently defined element list.
---@param elementTable table
---@param index number|nil
---@return hs.canvas
function canvas:assignElement(elementTable, index) end

--- Get or set the window behavior settings for the canvas object using labels defined in
--- hs.canvas.windowBehaviors
--- .
---@param behavior any
---@return hs.canvas
function canvas:behavior(behavior) end

--- Get or set the window behavior settings for the canvas object using labels defined in
--- hs.canvas.windowBehaviors
--- .
---@param behaviorTable table|nil
---@return hs.canvas
function canvas:behaviorAsLabels(behaviorTable) end

--- Places the canvas object on top of normal windows
---
--- Note: As of macOS Sierra and later, if you want a hs.canvas object to appear above full-screen windows you must
--- hide the Hammerspoon Dock icon first using: hs.dockicon.hide()
---@param aboveEverything any
---@return hs.canvas
function canvas:bringToFront(aboveEverything) end

--- Get or set the element default specified by keyName.
---
--- Note: Not all keys will apply to all element types.
--- Currently set and built-in defaults may be retrieved in a table with hs.canvas:canvasDefaults .
---@param keyName string
---@param newValue any
---@return hs.canvas
function canvas:canvasDefaultFor(keyName, newValue) end

--- Returns a list of the key names for the attributes set for the canvas defaults.
---@param module boolean|nil
---@return table
function canvas:canvasDefaultKeys(module) end

--- Get a table of the default key-value pairs which apply to the canvas.
---
--- Note: Not all keys will apply to all element types.
--- To change the defaults for the canvas, use hs.canvas:canvasDefaultFor .
---@param module table|nil
---@return table
function canvas:canvasDefaults(module) end

--- Returns an array containing the elements defined for this canvas.  Each array entry will be a table containing the
--- key-value pairs which have been set for that canvas element.
---@return table
function canvas:canvasElements() end

--- Get or set whether or not regions of the canvas which are not otherwise covered by an element with mouse tracking
--- enabled should generate a callback for mouse events.
---
--- Note: Each value that you wish to set must be provided in the order given above, but you may specify a position as
--- nil to indicate that whatever it's current state, no change should be applied.  For example, to activate a callback
--- for entering and exiting the canvas without changing the current callback status for up or down button clicks, you
--- could use: hs.canvas:canvasMouseTracking(nil, nil, true) .
--- Use hs.canvas:mouseCallback to set the callback function.  The identifier field in the callback's argument list
--- will be " canvas ", but otherwise identical to those specified in hs.canvas:mouseCallback .
---@param down function|nil
---@param up function|nil
---@param enterExit function|nil
---@param move function|nil
---@return hs.canvas|current values
function canvas:canvasMouseEvents(down, up, enterExit, move) end

--- Get or set whether or not clicking on a canvas with a click callback defined should bring all of Hammerspoon's open
--- windows to the front.
---
--- Note: Setting this to false changes a canvas object's AXsubrole value and may affect the results of filters used
--- with hs.window.filter , depending upon how they are defined.
---@param flag function|nil
---@return hs.canvas
function canvas:clickActivating(flag) end

--- Creates a copy of the canvas.
---
--- Note: The new canvas will not have a callback function assigned, even if the original canvas does.
--- The new canvas will not initially be visible, even if the original is.
--- The new canvas is an independent entity -- any subsequent changes to either canvas will not be reflected in the
--- other canvas.
--- This method allows you to display a canvas in multiple places or use it as a canvas element multiple times.
---@return hs.canvas
function canvas:copy() end

--- Destroys the canvas object, optionally fading it out first (if currently visible).
---
--- Note: This method is automatically called during garbage collection, notably during a Hammerspoon termination or
--- reload, with a fade time of 0.
---@param fadeOutTime number|nil
---@return none
function canvas:delete(fadeOutTime) end

--- Sets or remove a callback for accepting dragging and dropping items onto the canvas.
---
--- Note: pasteboard - the name of the pasteboard that contains the items being dragged
--- sequence - an integer that uniquely identifies the dragging session.
--- mouse - a point table containing the location of the mouse pointer within the canvas corresponding to when the
--- callback occurred.
--- operation - a table containing string descriptions of the type of dragging the source application supports.
--- Potentially useful for determining if your callback function should accept the dragged item or not.
--- "enter"   - the user has dragged an item into the canvas.  When your callback receives this message, you can
--- optionally return false to indicate that you do not wish to accept the item being dragged.
--- "exit"    - the user has moved the item out of the canvas; if the previous "enter" callback returned false, this
--- message will also occur when the user finally releases the items being dragged.
--- "receive" - indicates that the user has released the dragged object while it is still within the canvas frame.
--- When your callback receives this message, you can optionally return false to indicate to the sending application
--- that you do not want to accept the dragged item -- this may affect the animations provided by the sending
--- application.
--- You can use the sequence number in the details table to match up an "enter" with an "exit" or "receive" message.
--- You should capture the details you require from the drag-and-drop operation during the callback for "receive" by
--- using the pasteboard field of the details table and the hs.pasteboard module.  Because of the nature of "promised
--- items", it is not guaranteed that the items will still be on the pasteboard after your callback completes handling
--- this message.
--- A canvas object can only accept drag-and-drop items when its window level is at hs.canvas.windowLevels.dragging or
--- lower.
--- a canvas object can only accept drag-and-drop items when it accepts mouse events.  You must define a
--- hs.canvas:mouseCallback function, even if it is only a placeholder, e.g. hs.canvas:mouseCallback(function() end)
---@param fn function
---@return hs.canvas
function canvas:draggingCallback(fn) end

--- Get or set the attribute
--- key
--- for the canvas element at the specified index.
---@param index number
---@param key string
---@param value any
---@return hs.canvas
function canvas:elementAttribute(index, key, value) end

--- Returns the smallest rectangle which can fully contain the canvas element at the specified index.
---
--- Note: For many elements, this will be the same as the element frame.  For items without a frame (e.g. segments ,
--- circle , etc.) this will be the smallest rectangle which can fully contain the canvas element as specified by it's
--- attributes.
---@param index number
---@return rectTable
function canvas:elementBounds(index) end

--- Returns the number of elements currently defined for the canvas object.
---@return number
function canvas:elementCount() end

--- Returns a list of the key names for the attributes set for the canvas element at the specified index.
---
--- Note: Any attribute which has been explicitly set for the element will be included in the key list (even if it is
--- ignored for the element type).  If the optional flag is set to true, the additional attribute names added to the
--- list will only include those which are relevant to the element type.
---@param index number
---@param optional boolean|nil
---@return table
function canvas:elementKeys(index, optional) end

--- Get or set the frame of the canvasObject.
---
--- Note: a rect-table is a table with key-value pairs specifying the new top-left coordinate on the screen of the
--- canvas (keys x and y ) and the new size (keys h and w ).  The table may be crafted by any method which includes
--- these keys, including the use of an hs.geometry object.
--- elements in the canvas that have the absolutePosition attribute set to false will be moved so that their relative
--- position within the canvas remains the same with respect to the new size.
--- elements in the canvas that have the absoluteSize attribute set to false will be resized so that their relative
--- size with respect to the canvas remains the same with respect to the new size.
---@param rect table|nil
---@return hs.canvas
function canvas:frame(rect) end

--- Hides the canvas object
---@param fadeOutTime number|nil
---@return hs.canvas
function canvas:hide(fadeOutTime) end

--- Returns an image of the canvas contents as an
--- hs.image
--- object.
---
--- Note: The canvas does not have to be visible in order for an image to be generated from it.
---@return hs.image
function canvas:imageFromCanvas() end

--- Insert a new element into the canvas at the specified index.
---
--- Note: see also hs.canvas:assignElement .
---@param elementTable table
---@param index number|nil
---@return hs.canvas
function canvas:insertElement(elementTable, index) end

--- Returns whether or not the canvas is currently occluded (hidden by other windows, off screen, etc).
---
--- Note: If any part of the canvas is visible (even if that portion of the canvas does not contain any canvas
--- elements), then the canvas is not considered occluded.
--- a canvas which is completely covered by one or more opaque windows is considered occluded; however, if the windows
--- covering the canvas are not opaque, then the canvas is not occluded.
--- a canvas that is currently hidden or with a height of 0 or a width of 0 is considered occluded.
--- See also hs.canvas:isShowing .
---@return boolean
function canvas:isOccluded() end

--- Returns whether or not the canvas is currently being shown.
---
--- Note: This method only determines whether or not the canvas is being shown or is hidden -- it does not indicate
--- whether or not the canvas is currently off screen or is occluded by other objects.
--- See also hs.canvas:isOccluded .
---@return boolean
function canvas:isShowing() end

--- Returns whether or not the canvas is currently showing and is (at least partially) visible on screen.
---
--- Note: This is syntactic sugar for not hs.canvas:isOccluded() .
--- See hs.canvas:isOccluded for more details.
---@return boolean
function canvas:isVisible() end

--- Sets the window level more precisely than sendToBack and bringToFront.
---@param level hs.canvas.windowLevels|nil
---@return hs.canvas
function canvas:level(level) end

--- Returns a table specifying the size of the rectangle which can fully render the text with the specified style so
--- that is will be completely visible.
---
--- Note: Multi-line text (separated by a newline or return) is supported.  The height will be for the multiple lines
--- and the width returned will be for the longest line.
---@param index hs.styledtext|nil
---@param text string
---@return table
function canvas:minimumTextSize(index, text) end

--- Sets a callback for mouse events with respect to the canvas
---
--- Note: The callback function should expect 5 arguments: the canvas object itself, a message specifying the type of
--- mouse event, the canvas element id (or index position in the canvas if the id attribute is not set for the
--- element), the x position of the mouse when the event was triggered within the rendered portion of the canvas
--- element, and the y position of the mouse when the event was triggered within the rendered portion of the canvas
--- element.
--- See also hs.canvas:canvasMouseEvents for tracking mouse events in regions of the canvas not covered by an element
--- with mouse tracking enabled.
--- trackMouseDown - indicates that a callback should be invoked when a mouse button is clicked down on the canvas
--- element.  The message will be "mouseDown".
--- trackMouseUp - indicates that a callback should be invoked when a mouse button has been released over the canvas
--- element.  The message will be "mouseUp".
--- trackMouseEnterExit - indicates that a callback should be invoked when the mouse pointer enters or exits the
--- canvas element.  The message will be "mouseEnter" or "mouseExit".
--- trackMouseMove - indicates that a callback should be invoked when the mouse pointer moves within the canvas
--- element.  The message will be "mouseMove".
--- The callback mechanism uses reverse z-indexing to determine which element will receive the callback -- the topmost
--- element of the canvas which has enabled callbacks for the specified message will be invoked.
--- No distinction is made between the left, right, or other mouse buttons. If you need to determine which specific
--- button was pressed, use hs.eventtap.checkMouseButtons() within your callback to check.
--- The hit point detection occurs by comparing the mouse pointer location to the rendered content of each individual
--- canvas object... if an object which obscures a lower object does not have mouse tracking enabled, the lower object
--- will still receive the event if it does have tracking enabled.
--- Clipping regions which remove content from the visible area of a rendered object are ignored for the purposes of
--- element hit-detection.
---@param mouseCallbackFn function
---@return hs.canvas
function canvas:mouseCallback(mouseCallbackFn) end

--- Moves canvas object above canvas2, or all canvas objects in the same presentation level, if canvas2 is not given.
---
--- Note: If the canvas object and canvas2 are not at the same presentation level, this method will move the canvas
--- object as close to the desired relationship as possible without changing the canvas object's presentation level.
--- See hs.canvas.level .
---@param canvas2 boolean
---@return hs.canvas
function canvas:orderAbove(canvas2) end

--- Moves canvas object below canvas2, or all canvas objects in the same presentation level, if canvas2 is not given.
---
--- Note: If the canvas object and canvas2 are not at the same presentation level, this method will move the canvas
--- object as close to the desired relationship as possible without changing the canvas object's presentation level.
--- See hs.canvas.level .
---@param canvas2 boolean
---@return hs.canvas
function canvas:orderBelow(canvas2) end

--- Insert a new element into the canvas at the specified index.
---@param index number|nil
---@return hs.canvas
function canvas:removeElement(index) end

--- Replaces all of the elements in the canvas with the elements specified.  Shortens or lengthens the canvas element
--- count if necessary to accomodate the new canvas elements.
---
--- Note: You can also specify multiple elements in a table as an array, where each index in the table contains an
--- element table, and use the array as a single argument to this method if this style works better in your code.
---@param element... any
---@return hs.canvas
function canvas:replaceElements(element...) end

--- Rotates an element about the point specified, or the elements center if no point is specified.
---
--- Note: a point-table is a table with key-value pairs specifying a coordinate in the canvas (keys x and y ). The
--- table may be crafted by any method which includes these keys, including the use of an hs.geometry object.
--- The center of the object is determined by getting the element's bounds with hs.canvas:elementBounds .
--- If the third argument is a boolean value, the point argument is assumed to be the element's center and the boolean
--- value is used as the append argument.
--- This method uses hs.canvas.matrix to generate the rotation transformation and provides a wrapper for
--- hs.canvas.matrix.translate(x, y):rotate(angle):translate(-x, -y) which is then assigned or appended to the
--- element's existing transformation attribute.
---@param index number
---@param angle any
---@param point table|nil
---@param append boolean
---@return hs.canvas
function canvas:rotateElement(index, angle, point, append) end

--- Places the canvas object behind normal windows, between the desktop wallpaper and desktop icons
---@return hs.canvas
function canvas:sendToBack() end

--- Displays the canvas object
---
--- Note: if the canvas is in use as an element in another canvas, this method will result in an error.
---@param fadeInTime number|nil
---@return hs.canvas
function canvas:show(fadeInTime) end

--- Get or set the size of a canvas object
---
--- Note: a size-table is a table with key-value pairs specifying the size (keys h and w ) the canvas should be resized
--- to. The table may be crafted by any method which includes these keys, including the use of an hs.geometry object.
--- elements in the canvas that have the absolutePosition attribute set to false will be moved so that their relative
--- position within the canvas remains the same with respect to the new size.
--- elements in the canvas that have the absoluteSize attribute set to false will be resized so that their relative
--- size with respect to the canvas remains the same with respect to the new size.
---@param size table|nil
---@return hs.canvas
function canvas:size(size) end

--- Get or set the top-left coordinate of the canvas object
---
--- Note: a point-table is a table with key-value pairs specifying the new top-left coordinate on the screen of the
--- canvas (keys x and y ). The table may be crafted by any method which includes these keys, including the use of an
--- hs.geometry object.
---@param point table|nil
---@return hs.canvas
function canvas:topLeft(point) end

--- Get or set the matrix transformation which is applied to every element in the canvas before being individually
--- processed and added to the canvas.
---
--- Note: An example use for this method would be to change the canvas's origin point { x = 0, y = 0 } from the lower
--- left corner of the canvas to somewhere else, like the middle of the canvas.
---@param matrix hs.canvas.matrix|nil
---@return hs.canvas
function canvas:transformation(matrix) end

--- Get or set whether or not the canvas object should be rendered by the view or by Core Animation.
---
--- Note: This method can help smooth the display of small text objects on non-Retina monitors.
---@param flag boolean|nil
---@return hs.canvas
function canvas:wantsLayer(flag) end

-- ------------------------------------------------------------
-- hs.canvas.matrix
-- ------------------------------------------------------------

---@class hs.canvas.matrix
hs.canvas.matrix = {}

---@class matrix
local matrix = {}

--- Specifies the identity matrix.  Resets all existing transformations when applied as a method to an existing
--- matrixObject.
---
--- Note: The identity matrix can be thought of as "apply no transformations at all" or "render as specified".
--- Mathematically this is represented as:
--- [ 1,  0,  0 ]
--- [ 0,  1,  0 ]
--- [ 0,  0,  1 ]
---@return matrixObject
function hs.canvas.matrix.identity() end

--- Appends the specified matrix transformations to the matrix and returns the new matrix.  This method cannot be used
--- as a constructor.
---
--- Note: Mathematically this method multiples the original matrix by the new one and returns the result of the
--- multiplication.
--- You can use this method to "stack" additional transformations on top of existing transformations, without having to
--- know what the existing transformations in effect for the canvas element are.
---@param matrix table
---@return matrixObject
function matrix:append(matrix) end

--- Generates the mathematical inverse of the matrix.  This method cannot be used as a constructor.
---
--- Note: Inverting a matrix which represents a series of transformations has the effect of reversing or undoing the
--- original transformations.
--- This is useful when used with hs.canvas.matrix.append to undo a previously applied transformation without actually
--- replacing all of the transformations which may have been applied to a canvas element.
---@return matrixObject
function matrix:invert() end

--- Prepends the specified matrix transformations to the matrix and returns the new matrix.  This method cannot be used
--- as a constructor.
---
--- Note: Mathematically this method multiples the new matrix by the original one and returns the result of the
--- multiplication.
--- You can use this method to apply a transformation before the currently applied transformations, without having to
--- know what the existing transformations in effect for the canvas element are.
---@param matrix table
---@return matrixObject
function matrix:prepend(matrix) end

--- Applies a rotation of the specified number of degrees to the transformation matrix.  This method can be used as a
--- constructor or a method.
---
--- Note: e.g. hs.canvas.matrix.translate(x, y):rotate(angle):translate(-x, -y)
---@param angle number
---@return matrixObject
function matrix:rotate(angle) end

--- Applies a scaling transformation to the matrix.  This method can be used as a constructor or a method.
---@param xFactor any
---@param yFactor any
---@return matrixObject
function matrix:scale(xFactor, yFactor) end

--- Applies a shearing transformation to the matrix.  This method can be used as a constructor or a method.
---@param xFactor any
---@param yFactor any
---@return matrixObject
function matrix:shear(xFactor, yFactor) end

--- Applies a translation transformation to the matrix.  This method can be used as a constructor or a method.
---@param x number
---@param y number
---@return matrixObject
function matrix:translate(x, y) end

-- ------------------------------------------------------------
-- hs.chooser
-- ------------------------------------------------------------

---@class hs.chooser
hs.chooser = {}

---@class chooser
local chooser = {}

--- A global callback function used for various hs.chooser events
---@type hs.chooser
hs.chooser.globalCallback = nil

--- Creates a new chooser object
---
--- Note: As of macOS Sierra and later, if you want a hs.chooser object to appear above full-screen windows you must
--- hide the Hammerspoon Dock icon first using: hs.dockicon.hide()
---@param completionFn function
---@return hs.chooser
function hs.chooser.new(completionFn) end

--- Get or attach/detach a toolbar to/from the chooser.
---
--- Note: this method is a convenience wrapper for the hs.webview.toolbar.attachToolbar function.
--- If the toolbarObject is currently attached to another window when this method is called, it will be detached from
--- the original window and attached to the chooser.  If you wish to attach the same toolbar to multiple chooser
--- objects, see hs.webview.toolbar:copy .
---@param toolbar hs.webview.toolbar
---@return hs.chooser
function chooser:attachedToolbar(toolbar) end

--- Sets the background of the chooser between light and dark
---
--- Note: The text colors will not automatically change when you toggle the darkness of the chooser window, you should
--- also set appropriate colors with hs.chooser:fgColor() and hs.chooser:subTextColor()
---@param beDark boolean|nil
---@return hs.chooser|boolean
function chooser:bgDark(beDark) end

--- Cancels the chooser
---@return hs.chooser
function chooser:cancel() end

--- Sets the choices for a chooser
---
--- Note: The table of choices (be it provided statically, or returned by the callback) must contain at least the
--- following keys for each choice:
--- text - A string or hs.styledtext object that will be shown as the main text of the choice
--- Each choice may also optionally contain the following keys:
--- subText - A string or hs.styledtext object that will be shown underneath the main text of the choice
--- image - An hs.image image object that will be displayed next to the choice
--- valid - A boolean that defaults to true , if set to false selecting the choice will invoke the invalidCallback
--- method instead of dismissing the chooser
--- Any other keys/values in each choice table will be retained by the chooser and returned to the completion callback
--- when a choice is made. This is useful for storing UUIDs or other non-user-facing information, however, it is
--- important to note that you should not store userdata objects in the table - it is run through internal conversion
--- functions, so only basic Lua types should be stored.
--- If a function is given, it will be called once, when the chooser window is displayed. The results are then cached
--- until this method is called again, or hs.chooser:refreshChoicesCallback() is called.
--- If you're using a hs.styledtext object for text or subText choices, make sure you specify a color, otherwise your
--- text could appear transparent depending on the bgDark setting.
--- Example:
--- local
--- choices
--- =
--- {
--- {
--- [
--- "text"
--- ]
--- =
--- "First Choice"
--- ,
--- [
--- "subText"
--- ]
--- =
--- "This is the subtext of the first choice"
--- ,
--- [
--- "uuid"
--- ]
--- =
--- "0001"
--- },
--- {
--- [
--- "text"
--- ]
--- =
--- "Second Option"
--- ,
--- [
--- "subText"
--- ]
--- =
--- "I wonder what I should type here?"
--- ,
--- [
--- "uuid"
--- ]
--- =
--- "Bbbb"
--- },
--- {
--- [
--- "text"
--- ]
--- =
--- hs
--- .
--- styledtext
--- .
--- new
--- (
--- "Third Possibility"
--- ,
--- {
--- font
--- =
--- {
--- size
--- =
--- 18
--- },
--- color
--- =
--- hs
--- .
--- drawing
--- .
--- color
--- .
--- definedCollections
--- .
--- hammerspoon
--- .
--- green
--- }),
--- [
--- "subText"
--- ]
--- =
--- "What a lot of choosing there is going on here!"
--- ,
--- [
--- "uuid"
--- ]
--- =
--- "III3"
--- },
--- }
--- ```
---@param choices function|nil
---@return hs.chooser
function chooser:choices(choices) end

--- Deletes a chooser
---@return any
function chooser:delete() end

--- Gets/Sets whether the chooser should run the callback on a query when it does not match any on the list
---
--- Note: This should be used before a chooser has been displayed
---@return hs.chooser|boolean
function chooser:enableDefaultForQuery() end

--- Sets the foreground color of the chooser
---@param color hs.drawing.color|nil
---@return hs.chooser
function chooser:fgColor(color) end

--- Hides the chooser
---@return hs.chooser
function chooser:hide() end

--- Sets/clears a callback for when the chooser window is hidden
---
--- Note: This callback is called after the chooser is hidden.
--- This callback is called after hs.chooser.globalCallback.
---@param fn function|nil
---@return hs.chooser
function chooser:hideCallback(fn) end

--- Sets/clears a callback for invalid choices
---
--- Note: The callback may accept one argument, it will be a table containing whatever information you supplied for the
--- item the user chose.
--- To display a context menu, see hs.menubar , specifically the :popupMenu() method
---@param fn function|nil
---@return hs.chooser
function chooser:invalidCallback(fn) end

--- Checks if the chooser is currently displayed
---@return boolean
function chooser:isVisible() end

--- Sets/gets placeholder text that is shown in the query text field when no other text is present
---@param placeholderText string|nil
---@return hs.chooser|string
function chooser:placeholderText(placeholderText) end

--- Sets/gets the search string
---
--- Note: You can provide an explicit nil or empty string to clear the current query string.
---@param queryString string
---@return hs.chooser|string
function chooser:query(queryString) end

--- Sets/clears a callback for when the search query changes
---
--- Note: As the user is typing, the callback function will be called for every keypress. You may wish to do filtering
--- on each call, or you may wish to use a delayed hs.timer object to only react when they have finished typing.
--- The callback function should accept a single argument:
--- A string containing the new search query
---@param fn function|nil
---@return hs.chooser
function chooser:queryChangedCallback(fn) end

--- Refreshes the choices data from a callback
---
--- Note: This method will do nothing if you have not set a function with hs.chooser:choices()
---@param reload string|nil
---@return hs.chooser
function chooser:refreshChoicesCallback(reload) end

--- Sets/clears a callback for right clicking on choices
---
--- Note: The callback may accept one argument, the row the right click occurred in or 0 if there is currently no
--- selectable row where the right click occurred. To determine the location of the mouse pointer at the right click,
--- see hs.mouse .
--- To display a context menu, see hs.menubar , specifically the :popupMenu() method
---@param fn function|nil
---@return hs.chooser
function chooser:rightClickCallback(fn) end

--- Gets/Sets the number of rows that will be shown
---@param numRows number|nil
---@return hs.chooser|number
function chooser:rows(numRows) end

--- Gets/Sets whether the chooser should search in the sub-text of each item
---
--- Note: This should be used before a chooser has been displayed
---@param searchSubText boolean|nil
---@return hs.chooser|boolean
function chooser:searchSubText(searchSubText) end

--- Closes the chooser by selecting the specified row, or the currently selected row if not given
---@param row number|nil
---@return hs.chooser
function chooser:select(row) end

--- Get or set the currently selected row
---@param row number|nil
---@return number
function chooser:selectedRow(row) end

--- Returns the contents of the currently selected or specified row
---@param row number|nil
---@return table
function chooser:selectedRowContents(row) end

--- Displays the chooser
---@param topLeftPoint any
---@return hs.chooser
function chooser:show(topLeftPoint) end

--- Sets/clears a callback for when the chooser window is shown
---
--- Note: This callback is called after the chooser is shown. To execute code just before it's shown (and/or after it's
--- removed) see hs.chooser.globalCallback
---@param fn function|nil
---@return hs.chooser
function chooser:showCallback(fn) end

--- Sets the sub-text color of the chooser
---@param color hs.drawing.color|nil
---@return hs.chooser|hs.color
function chooser:subTextColor(color) end

--- Gets/Sets the width of the chooser
---
--- Note: This should be used before a chooser has been displayed
---@param percent number|nil
---@return hs.chooser|number
function chooser:width(percent) end

-- ------------------------------------------------------------
-- hs.console
-- ------------------------------------------------------------

---@class hs.console
hs.console = {}

--- Because use of this function can easily lead to a crash, useful methods from
--- hs.drawing
--- have been added to the
--- hs.console
--- module itself.  If you believe that a useful method has been overlooked, please submit an issue.
---@return hs.drawing
function hs.console.asHSDrawing() end

--- Returns an hs.window object for the console so that you can use hs.window methods on it.
---@return hs.window
function hs.console.asHSWindow() end

--- Default toolbar for the Console window
---@type any
hs.console.defaultToolbar = nil

--- Get or set the alpha level of the console window.
---@param alpha number|nil
---@return any
function hs.console.alpha(alpha) end

--- Get or set the window behavior settings for the console using labels defined in
--- hs.drawing.windowBehaviors
--- .
---
--- Note: Window behaviors determine how the console is handled by Spaces and Exposé. See hs.drawing.windowBehaviors
--- for more information.
---@param behaviorTable table|nil
---@return any
function hs.console.behaviorAsLabels(behaviorTable) end

--- Clear the Hammerspoon console output window.
---
--- Note: This is equivalent to hs.console.setConsole()
---@return nil
function hs.console.clearConsole() end

--- Get or set the color that commands displayed in the Hammerspoon console are displayed with.
---
--- Note: See the hs.drawing.color entry in the Dash documentation, or type help.hs.drawing.color in the Hammerspoon
--- console to get more information on how to specify a color.
--- Note this only affects future output -- anything already in the console will remain its current color.
---@param color hs.drawing.color|nil
---@return color
function hs.console.consoleCommandColor(color) end

--- Get or set the font used in the Hammerspoon console.
---
--- Note: See the hs.drawing.color entry in the Dash documentation, or type help.hs.drawing.color in the Hammerspoon
--- console to get more information on how to specify a color.
--- Note this only affects future output -- anything already in the console will remain its current font.
---@param font string|table|nil
---@return fontTable
function hs.console.consoleFont(font) end

--- Get or set the color that regular output displayed in the Hammerspoon console is displayed with.
---
--- Note: See the hs.drawing.color entry in the Dash documentation, or type help.hs.drawing.color in the Hammerspoon
--- console to get more information on how to specify a color.
--- Note this only affects future output -- anything already in the console will remain its current color.
---@param color hs.drawing.color|nil
---@return color
function hs.console.consolePrintColor(color) end

--- Get or set the color that function results displayed in the Hammerspoon console are displayed with.
---
--- Note: See the hs.drawing.color entry in the Dash documentation, or type help.hs.drawing.color in the Hammerspoon
--- console to get more information on how to specify a color.
--- Note this only affects future output -- anything already in the console will remain its current color.
---@param color hs.drawing.color|nil
---@return color
function hs.console.consoleResultColor(color) end

--- Set or display whether or not the Console window should display in dark mode.
---
--- Note: Enabling Dark Mode for the Console only affects the window background, and doesn't automatically change the
--- Console's Background Color, so you will need to add something similar to: if hs . console . darkMode () then hs .
--- console . outputBackgroundColor { white = 0 } hs . console . consoleCommandColor { white = 1 } hs . console . alpha
--- ( .8 ) end
--- .   ```
---@param state boolean
---@return boolean
function hs.console.darkMode(state) end

--- Get the text of the Hammerspoon console output window.
---
--- Note: If the text of the console is retrieved as a string, no color or style information in the console output is
--- retrieved - only the raw text.
---@param styled string|nil
---@return text|styledText
function hs.console.getConsole(styled) end

--- Get the Hammerspoon console command history as an array.
---@return array
function hs.console.getHistory() end

--- Get an hs.window object which represents the Hammerspoon console window
---@return hs.window
function hs.console.hswindow() end

--- Get or set the color for the background of the Hammerspoon Console's input field.
---
--- Note: See the hs.drawing.color entry in the Dash documentation, or type help.hs.drawing.color in the Hammerspoon
--- console to get more information on how to specify a color.
---@param color hs.drawing.color|nil
---@return color
function hs.console.inputBackgroundColor(color) end

--- Get or set the console window level
---
--- Note: see the notes for hs.drawing.windowLevels
---@param theLevel hs.drawing.windowLevels|nil
---@return any
function hs.console.level(theLevel) end

--- Get or set the max length of the Hammerspoon console's scrollback history.
---
--- Note: A length value of zero will allow the history to grow infinitely
--- The default console history is 100,000 characters
---@param length number|nil
---@return number
function hs.console.maxOutputHistory(length) end

--- Get or set the color for the background of the Hammerspoon Console's output view.
---
--- Note: See the hs.drawing.color entry in the Dash documentation, or type help.hs.drawing.color in the Hammerspoon
--- console to get more information on how to specify a color.
---@param color hs.drawing.color|nil
---@return color
function hs.console.outputBackgroundColor(color) end

--- A print function which recognizes
--- hs.styledtext
--- objects and renders them as such in the Hammerspoon console.
---
--- Note: This has been made as close to the Lua print command as possible.  You can replace the existing print command
--- with this by adding the following to your init.lua file:
--- print = function(...)
--- hs.rawprint(...)
--- hs.console.printStyledtext(...)
--- end
---@param ... any
---@return none
function hs.console.printStyledtext(...) end

--- Clear the Hammerspoon console output window.
---
--- Note: You can specify the console content as a string or as an hs.styledtext object in either userdata or table
--- format.
---@param styledText hs.styledtext|nil
---@return none
function hs.console.setConsole(styledText) end

--- Set the Hammerspoon console command history to the items specified in the given array.
---
--- Note: You can clear the console history by using an empty array (e.g. hs.console.setHistory({})
---@param array commands[]
---@return nil
function hs.console.setHistory(array) end

--- Determine whether or not objects copied from the console window insert or delete space around selected words to
--- preserve proper spacing and punctuation.
---
--- Note: this only applies to future copy operations from the Hammerspoon console -- anything already in the clipboard
--- is not affected.
---@param flag any
---@return boolean
function hs.console.smartInsertDeleteEnabled(flag) end

--- Get or set whether or not the "Hammerspoon Console" text appears in the Hammerspoon console titlebar.
---
--- Note: When a toolbar is attached to the Hammerspoon console (see the hs.webview.toolbar module documentation), this
--- function can be used to specify whether the Toolbar appears underneath the console window's title ("visible") or in
--- the window's title bar itself, as seen in applications like Safari ("hidden"). When the title is hidden, the
--- toolbar will only display the toolbar items as icons without labels, and ignores changes made with
--- hs.webview.toolbar:displayMode .
--- If a toolbar is attached to the console, you can achieve the same effect as this function with
--- hs.console.toolbar():inTitleBar(boolean)
---@param state boolean
---@return any
function hs.console.titleVisibility(state) end

--- Get or set the color for the background of the Hammerspoon Console's window.
---
--- Note: See the hs.drawing.color entry in the Dash documentation, or type help.hs.drawing.color in the Hammerspoon
--- console to get more information on how to specify a color.
---@param color hs.drawing.color|nil
---@return color
function hs.console.windowBackgroundColor(color) end

--- Get or set the window behavior settings for the console.
---
--- Note: Window behaviors determine how the webview object is handled by Spaces and Exposé. See
--- hs.drawing.windowBehaviors for more information.
---@param behavior number|nil
---@return any
function hs.console.behavior(behavior) end

--- Get or attach/detach a toolbar to/from the Hammerspoon console.
---
--- Note: this method is a convenience wrapper for the hs.webview.toolbar.attachToolbar function.
--- If the toolbar is currently attached to another window when this function is called, it will be detached from the
--- original window and attached to the console.
---@param toolbar hs.webview.toolbar
---@return toolbarObject
function hs.console.toolbar(toolbar) end

-- ------------------------------------------------------------
-- hs.crash
-- ------------------------------------------------------------

---@class hs.crash
hs.crash = {}

--- Attempts to reduce RAM usage of Hammerspoon
---
--- Note: This function will print some memory usage numbers (in bytes) to the Hammerspoon Console before and after
--- forcing Lua's garbage collector
---@return any
function hs.crash.attemptMemoryRelease() end

--- Causes Hammerspoon to immediately crash
---
--- Note: This is for testing purposes only, you are extremely unlikely to need this in normal Hammerspoon usage
---@return any
function hs.crash.crash() end

--- Sets a key/value pair in any Sentry crash dump generated by this Hammerspoon session
---@param key string
---@param value string
---@return any
function hs.crash.crashKV(key, value) end

--- Leaves a breadcrumb log message in any Sentry crash dump generated by this Hammerspoon session
---
--- Note: This is probably only useful to extension developers. If you are trying to track down a confusing crash, and
--- you have access to the Sentry project for Hammerspoon (or access to someone who has access!), this can be a useful
--- way to leave breadcrumbs from Lua in the crash dump
---@param logMessage string
---@return any
function hs.crash.crashLog(logMessage) end

--- Dumps the contents of Lua's CLIBS registry
---
--- Note: This is probably only useful to extension developers as a useful way of ensuring that you are loading C
--- libraries from the places you expect.
---@return table
function hs.crash.dumpCLIBS() end

--- Gets the resident size of the Hammerspoon process
---@return number|nil
function hs.crash.residentSize() end

--- Causes Hammerspoon to generate an Objective C exception
---
--- Note: Outside of a context of a Lua pcall() (or a C lua_pcall()), this will cause Hammerspoon to exit. We follow
--- the safe behaviour of terminating the app on any unhandled Objective C exception.
---@param name string
---@param message string
---@return any
function hs.crash.throwObjCException(name, message) end

-- ------------------------------------------------------------
-- hs.deezer
-- ------------------------------------------------------------

---@class hs.deezer
hs.deezer = {}

--- Returned by
--- hs.deezer.getPlaybackState()
--- to indicates deezer is paused
---@type hs.deezer.getPlaybackState
hs.deezer.state_paused = nil

--- Returned by
--- hs.deezer.getPlaybackState()
--- to indicates deezer is playing
---@type hs.deezer.getPlaybackState
hs.deezer.state_playing = nil

--- Returned by
--- hs.deezer.getPlaybackState()
--- to indicates deezer is stopped
---@type hs.deezer.getPlaybackState
hs.deezer.state_stopped = nil

--- Displays information for current track on screen
---@return any
function hs.deezer.displayCurrentTrack() end

--- Skips the playback position forwards by 5 seconds
---@return any
function hs.deezer.ff() end

--- Gets the name of the album of the current track
---@return string|nil
function hs.deezer.getCurrentAlbum() end

--- Gets the name of the artist of the current track
---@return string|nil
function hs.deezer.getCurrentArtist() end

--- Gets the name of the current track
---@return string|nil
function hs.deezer.getCurrentTrack() end

--- Gets the current playback state of deezer
---@return hs.deezer.state_stopped|hs.deezer.state_paused|hs.deezer.state_playing
function hs.deezer.getPlaybackState() end

--- Gets the playback position (in seconds) in the current song
---@return number
function hs.deezer.getPosition() end

--- Gets the deezer volume setting
---@return number
function hs.deezer.getVolume() end

--- Returns whether deezer is currently playing
---@return boolean|nil
function hs.deezer.isPlaying() end

--- Returns whether deezer is currently open. Most other functions in hs.deezer will automatically start the
--- application, so this function can be used to guard against that.
---@return boolean
function hs.deezer.isRunning() end

--- Skips to the next deezer track
---@return any
function hs.deezer.next() end

--- Pauses the current deezer track
---@return any
function hs.deezer.pause() end

--- Plays the current deezer track
---@return any
function hs.deezer.play() end

--- Toggles play/pause of current deezer track
---@return any
function hs.deezer.playpause() end

--- Skips to previous deezer track
---@return any
function hs.deezer.previous() end

--- Skips the playback position backwards by 5 seconds
---@return any
function hs.deezer.rw() end

--- Sets the playback position in the current song
---@param pos number
---@return any
function hs.deezer.setPosition(pos) end

--- Sets the deezer volume setting
---@param vol number
---@return any
function hs.deezer.setVolume(vol) end

--- Reduces the volume by 5
---@return any
function hs.deezer.volumeDown() end

--- Increases the volume by 5
---@return any
function hs.deezer.volumeUp() end

-- ------------------------------------------------------------
-- hs.dialog
-- ------------------------------------------------------------

---@class hs.dialog
hs.dialog = {}

--- Displays a simple non-blocking dialog box using
--- NSAlert
--- and a hidden
--- hs.webview
--- that's automatically destroyed when the alert is closed.
---
--- Note: The optional values must be entered in order (i.e. you can't supply style without also supplying buttonOne
--- and buttonTwo ).
--- [style] can be "warning", "informational" or "critical". If something other than these string values is given, it
--- will use "informational".
--- Example: testCallbackFn = function ( result ) print ( "Callback Result: " .. result ) end hs . dialog . alert ( 100
--- , 100 , testCallbackFn , "Message" , "Informative Text" , "Button One" , "Button Two" , "NSCriticalAlertStyle" ) hs
--- . dialog . alert ( 200 , 200 , testCallbackFn , "Message" , "Informative Text" , "Single Button" ) ```
---@param x number
---@param y number
---@param callbackFn function
---@param message string
---@param informativeText string
---@param buttonOne any
---@param buttonTwo any
---@param style any
---@return string
function hs.dialog.alert(x, y, callbackFn, message, informativeText, buttonOne, buttonTwo, style) end

--- Displays a simple dialog box using
--- NSAlert
--- that will halt Lua code processing until the alert is closed.
---
--- Note: The optional values must be entered in order (i.e. you can't supply style without also supplying buttonOne
--- and buttonTwo ).
--- [style] can be "warning", "informational" or "critical". If something other than these string values is given, it
--- will use "warning".
--- Example: hs.dialog.blockAlert("Message", "Informative Text", "Button One", "Button Two", "critical")
---@param message string
---@param informativeText string
---@param buttonOne any
---@param buttonTwo any
---@param style any
---@return string
function hs.dialog.blockAlert(message, informativeText, buttonOne, buttonTwo, style) end

--- Displays a file and/or folder selection dialog box using NSOpenPanel.
---
--- Note: The optional values must be entered in order (i.e. you can't supply allowsMultipleSelection without also
--- supplying canChooseFiles and canChooseDirectories ).
--- Example: hs.inspect(hs.dialog.chooseFileOrFolder("Please select a file:", "~/Desktop", true, false, true, {"jpeg",
--- "pdf"}, true))
---@param message string
---@param defaultPath string
---@param canChooseFiles boolean
---@param canChooseDirectories boolean
---@param allowsMultipleSelection boolean
---@param allowedFileTypes boolean
---@param resolvesAliases any
---@return string
function hs.dialog.chooseFileOrFolder(message, defaultPath, canChooseFiles, canChooseDirectories, allowsMultipleSelection, allowedFileTypes, resolvesAliases) end

--- Displays a simple text input dialog box.
---
--- Note: buttonOne defaults to "OK" if no value is supplied.
--- buttonOne will also be triggered by pressing ENTER , whereas buttonTwo will be triggered by pressing ESC .
--- Examples: hs.dialog.textPrompt("Main message.", "Please enter something:") hs.dialog.textPrompt("Main message.",
--- "Please enter something:", "Default Value", "OK") hs.dialog.textPrompt("Main message.", "Please enter something:",
--- "Default Value", "OK", "Cancel") hs.dialog.textPrompt("Main message.", "Please enter something:", "", "OK",
--- "Cancel", true)
---@param message string
---@param informativeText string
---@param defaultText string
---@param buttonOne any
---@param buttonTwo any
---@param secureField any
---@return string
---@return string
function hs.dialog.textPrompt(message, informativeText, defaultText, buttonOne, buttonTwo, secureField) end

--- Displays a simple dialog box using
--- NSAlert
--- in a
--- hs.webview
--- .
---
--- Note: This alert is will prevent the user from interacting with the hs.webview until a button is pressed on the
--- alert.
--- The optional values must be entered in order (i.e. you can't supply style without also supplying buttonOne and
--- buttonTwo ).
--- [style] can be "warning", "informational" or "critical". If something other than these string values is given, it
--- will use "informational".
--- Example: testCallbackFn = function ( result ) print ( "Callback Result: " .. result ) end testWebviewA = hs .
--- webview . newBrowser ( hs . geometry . rect ( 250 , 250 , 250 , 250 )): show () testWebviewB = hs . webview .
--- newBrowser ( hs . geometry . rect ( 450 , 450 , 450 , 450 )): show () hs . dialog . webviewAlert ( testWebviewA ,
--- testCallbackFn , "Message" , "Informative Text" , "Button One" , "Button Two" , "warning" ) hs . dialog .
--- webviewAlert ( testWebviewB , testCallbackFn , "Message" , "Informative Text" , "Single Button" ) ```
---@param webview hs.webview
---@param callbackFn function
---@param message string
---@param informativeText string
---@param buttonOne any
---@param buttonTwo any
---@param style any
---@return string
function hs.dialog.webviewAlert(webview, callbackFn, message, informativeText, buttonOne, buttonTwo, style) end

-- ------------------------------------------------------------
-- hs.dialog.color
-- ------------------------------------------------------------

---@class hs.dialog.color
hs.dialog.color = {}

--- Set or display the selected opacity.
---
--- Note: Example: hs.dialog.color.alpha(0.5)
---@param value any
---@return number
function hs.dialog.color.alpha(value) end

--- Sets or removes the callback function for the color panel.
---
--- Note: Example: hs.dialog.color.callback(function(a,b) print("COLOR CALLBACK:\nSelected Color: " .. hs.inspect(a) ..
--- "\nPanel Closed: " .. hs.inspect(b)) end)
---@param callbackFn any
---@return function|nil
function hs.dialog.color.callback(callbackFn) end

--- Set or display the currently selected color in a color wheel.
---
--- Note: Example: hs.dialog.color.color(hs.drawing.color.blue)
---@param value any
---@return table
function hs.dialog.color.color(value) end

--- Set or display whether or not the callback should be continuously updated when a user drags a color slider or
--- control.
---
--- Note: Example: hs.dialog.color.continuous(true)
---@param value any
---@return boolean
function hs.dialog.color.continuous(value) end

--- Hides the Color Panel.
---
--- Note: Example: hs.dialog.color.hide()
---@return none
function hs.dialog.color.hide() end

--- Set or display the currently selected color panel mode.
---
--- Note: Example: hs.dialog.color.mode("RGB")
---@param value any
---@return table
function hs.dialog.color.mode(value) end

--- Shows the Color Panel.
---
--- Note: Example: hs.dialog.color.show()
---@return none
function hs.dialog.color.show() end

--- Set or display whether or not the color panel should display an opacity slider.
---
--- Note: Example: hs.dialog.color.showsAlpha(true)
---@param value any
---@return boolean
function hs.dialog.color.showsAlpha(value) end

-- ------------------------------------------------------------
-- hs.distributednotifications
-- ------------------------------------------------------------

---@class hs.distributednotifications
hs.distributednotifications = {}

---@class distributednotifications
local distributednotifications = {}

--- Sends a distributed notification
---@param name string
---@param sender? string|nil
---@param userInfo? table|nil
---@return any
function hs.distributednotifications.post(name, sender, userInfo) end

--- Creates a new NSDistributedNotificationCenter watcher
---
--- Note: On Catalina and above, it is no longer possible to observe all notifications - the name parameter is
--- effectively now required. See https://mjtsai.com/blog/2019/10/04/nsdistributednotificationcenter-no-longer-supports-nil-names
---@param callback function
---@param name? string|nil
---@param object? string|nil
---@return object
function hs.distributednotifications.new(callback, name, object) end

--- Starts a NSDistributedNotificationCenter watcher
---@return object
function distributednotifications:start() end

--- Stops a NSDistributedNotificationCenter watcher
---@return object
function distributednotifications:stop() end

-- ------------------------------------------------------------
-- hs.doc
-- ------------------------------------------------------------

---@class hs.doc
hs.doc = {}

--- Prints the documentation for some part of Hammerspoon's API and Lua 5.3.  This function has also been aliased as
--- hs.help
--- and
--- help
--- as a shorthand for use within the Hammerspoon console.
---
--- Note: This function is mainly for runtime API help while using Hammerspoon's Console
--- Documentation files registered with hs.doc.registerJSONFile or hs.doc.preloadSpoonDocs that have not yet been
--- actually loaded will be loaded when this command is invoked in any of the forms described below.
--- help("prefix.path") -- quotes are required, e.g. help("hs.reload")
--- hs - provides documentation for Hammerspoon's builtin commands and modules
--- spoon - provides documentation for the Spoons installed on your system
--- lua._man - provides the table of contents for the Lua 5.3 manual.  You can pull up a specific section of the lua
--- manual by including the chapter (and subsection) like this: lua._man._3_4_8 .
--- lua._C - provides documentation specifically about the Lua C API for use when developing modules which require
--- external libraries.
--- path is one or more components, separated by a period specifying the module, submodule, function, or method you
--- wish to view documentation for.
---@param identifier string
---@return any
function hs.doc.help(identifier) end

--- Locates the JSON file corresponding to the specified third-party module or Spoon by searching package.path and
--- package.cpath.
---
--- Note: The JSON should be named 'docs.json' and located in the same directory as the lua or so file which is used
--- when the module is loaded via require .
--- The documentation for core modules is stored in the JSON file specified by the hs.docstrings_json_file variable;
--- this function is intended for use in locating the documentation file for third party modules and Spoons.
---@param module any
---@return path|boolean
---@return message
function hs.doc.locateJSONFile(module) end

--- Locates all installed Spoon documentation files and marks them for loading the next time the
--- hs.doc.help
--- function is invoked.
---@return any
function hs.doc.preloadSpoonDocs() end

--- Returns the list of registered JSON files.
---
--- Note: The table returned by this function has a metatable including a __tostring method which allows you to see the
--- list of registered files by simply typing hs.doc.registeredFiles() in the Hammerspoon Console.
--- By default, the internal core documentation and portions of the Lua 5.3 manual, located at
--- http://www.lua.org/manual/5.3/manual.html, are already registered for inclusion within this documentation object.
--- hs.doc.unregisterJSONFile(hs.docstrings_json_file) -- to unregister the Hammerspoon API docs
--- hs.doc.unregisterJSONFile((hs.docstrings_json_file:gsub("/docs.json$","/lua.json"))) -- to unregister the Lua 5.3
--- Documentation.
---@return table
function hs.doc.registeredFiles() end

--- Register a JSON file for inclusion when Hammerspoon generates internal documentation.
---
--- Note: this function just registers the documentation file; it won't actually be loaded and parsed until hs.doc.help
--- is invoked.
---@param jsonfile string
---@param isSpoon boolean|nil
---@return status
---@return message
function hs.doc.registerJSONFile(jsonfile, isSpoon) end

--- Remove a JSON file from the list of registered files.
---
--- Note: This function requires the rebuilding of the entire documentation tree for all remaining registered files, so
--- the next time help is queried with hs.doc.help , there may be a slight one-time delay.
---@param jsonfile string
---@return status
---@return message
function hs.doc.unregisterJSONFile(jsonfile) end

-- ------------------------------------------------------------
-- hs.doc.builder
-- ------------------------------------------------------------

---@class hs.doc.builder
hs.doc.builder = {}

--- Generates a documentation table for Hammerspoon modules or Spoon bundles from the source files located in the
--- path(s) provided.
---
--- Note: Because Hammerspoon and all known currently available modules are coded in Objective-C and/or Lua, only files
--- with the .m or .lua extension are examined in the provided path(s).  Please submit an issue (or pull request, if
--- you modify this submodule yourself) at https://github.com/Hammerspoon if you need this to be changed for your
--- addition.
---@param path string
---@param recurse any
---@return table
function hs.doc.builder.genComments(path, recurse) end

--- Generates a JSON string representation of the documentation source specified. This is the format expected by
--- hs.doc
--- and
--- hs.doc.hsdoc
--- and is used to provide the built in documentation for Hammerspoon.
---
--- Note: If you have installed the hs command line tool (see hs.ipc ), you can use the following to generate the
--- docs.json file that is used to provide documentation for Hammerspoon Spoon bundles: hs -c
--- "hs.doc.builder.genJSON(\"$(pwd)\")" > docs.json
--- You can also use this to generate documentation for any third-party-modules you build, but you will have to
--- register the documentation with hs.doc.registerJSONFile yourself -- it is not automatically loaded for you like it
--- is for Spoons.
---@param source hs.doc.builder.genComments
---@return string
function hs.doc.builder.genJSON(source) end

--- Generates the SQL commands required for creating the search index when creating a docset of the documentation.
---@param source hs.doc.builder.genComments
---@return string
function hs.doc.builder.genSQL(source) end

-- ------------------------------------------------------------
-- hs.doc.hsdocs
-- ------------------------------------------------------------

---@class hs.doc.hsdocs
hs.doc.hsdocs = {}

--- Get or set whether or not the Hammerspoon browser renders output in Dark mode.
---
--- Note: Inversion is applied through the use of CSS filtering, so while numeric values other than 0 (false) and 100
--- (true) are allowed, the result is generally not what is desired.
--- Changes made with this function are saved with hs.settings with the label "_documentationServer.invertDocs" and
--- will persist through a reload or restart of Hammerspoon.
---@param value any
---@return any
function hs.doc.hsdocs.browserDarkMode(value) end

--- Get or set the currently saved initial frame location for the documentation browser.
---
--- Note: If hs.doc.hsdocs.trackBrowserFrame is false or nil (the default), then you can use this function to specify
--- the initial position of the documentation browser.
--- If hs.doc.hsdocs.trackBrowserFrame is true, then this any value set with this function will be overwritten whenever
--- the browser window is moved or resized.
--- Changes made with this function are saved with hs.settings with the label "_documentationServer.browserFrame" and
--- will persist through a reload or restart of Hammerspoon.
---@param frameTable table
---@return any
function hs.doc.hsdocs.browserFrame(frameTable) end

--- Get or set whether or not
--- hs.doc.hsdocs.help
--- uses an external browser.
---
--- Note: If this value is set to true, help requests invoked by hs.doc.hsdocs.help will be invoked by your system's
--- default handler for the http scheme.
--- If this value is set to a string, the string specifies the bundle ID of an application which will be used to handle
--- the url request for the documentation.  The string should match one of the items returned by
--- hs.urlevent.getAllHandlersForScheme("http") .
--- This behavior is triggered automatically, regardless of this setting, if you are running with a version of OS X
--- prior to 10.10, since hs.webview requires OS X 10.10 or later.
--- Changes made with this function are saved with hs.settings with the label
--- "_documentationServer.forceExternalBrowser" and will persist through a reload or restart of Hammerspoon.
---@param value hs.webview|nil
---@return any
function hs.doc.hsdocs.forceExternalBrowser(value) end

--- Display the documentation for the specified Hammerspoon function, or the Table of Contents for the Hammerspoon
--- documentation in a built-in mini browser.
---@param identifier any
---@return nil
function hs.doc.hsdocs.help(identifier) end

--- Get or set the network interface that the Hammerspoon documentation web server will be served on
---
--- Note: See hs.httpserver.setInterface for a description of valid values that can be specified as the interface
--- argument to this function.
--- A change to the interface can only occur when the documentation server is not running. If the server is currently
--- active when you call this function with an argument, the server will be temporarily stopped and then restarted
--- after the interface has been changed.
--- Changes made with this function are saved with hs.settings with the label "_documentationServer.interface" and will
--- persist through a reload or restart of Hammerspoon.
---@param interface string|nil
---@return any
function hs.doc.hsdocs.interface(interface) end

--- Get or set whether or not a module's entity list is displayed as a column on the left of the rendered page.
---
--- Note: This is experimental and is disabled by default. It was inspired by a Userscript written by krasnovpro.  The
--- original can be found at https://openuserjs.org/scripts/krasnovpro/hammerspoon.org_Documentation/source.
--- Changes made with this function are saved with hs.settings with the label "_documentationServer.entitiesInSidebar"
--- and will persist through a reload or restart of Hammerspoon.
---@param value any
---@return any
function hs.doc.hsdocs.moduleEntitiesInSidebar(value) end

--- Get or set the Hammerspoon documentation server HTTP port.
---
--- Note: The default port number is 12345.
--- Changes made with this function are saved with hs.settings with the label "_documentationServer.serverPort" and
--- will persist through a reload or restart of Hammerspoon.
---@param value number|nil
---@return any
function hs.doc.hsdocs.port(value) end

--- Start the Hammerspoon internal documentation web server.
---
--- Note: This function is automatically called, if necessary, when hs.doc.hsdocs.help is invoked.
--- The documentation web server can be viewed from a web browser by visiting "http://localhost:port" where port is the
--- port the server is running on, 12345 by default -- see hs.doc.hsdocs.port .
---@return hs.doc.hsdocs
function hs.doc.hsdocs.start() end

--- Stop the Hammerspoon internal documentation web server.
---@return hs.doc.hsdocs
function hs.doc.hsdocs.stop() end

--- Get or set whether or not changes in the documentation browsers location and size persist through launches of
--- Hammerspoon.
---
--- Note: Changes made with this function are saved with hs.settings with the label
--- "_documentationServer.trackBrowserFrameChanges" and will persist through a reload or restart of Hammerspoon.
---@param value any
---@return any
function hs.doc.hsdocs.trackBrowserFrame(value) end

-- ------------------------------------------------------------
-- hs.doc.markdown
-- ------------------------------------------------------------

---@class hs.doc.markdown
hs.doc.markdown = {}

--- Converts markdown encoded text to html or plaintext.
---
--- Note: NO_INTRA_EMPHASIS -  disallow emphasis inside of words
--- LAX_SPACING       - supports spacing like in Markdown 1.0.0 (i.e. do not require an empty line between two
--- different blocks in a paragraph)
--- STRIKETHROUGH     - support strikethrough with double tildes (~)
--- TABLES            - support Markdown tables
--- FENCED_CODE       - supports fenced code blocks surround by three back-ticks (`) or three tildes (~)
--- AUTOLINK          - HTTP URL's are treated as links, even if they aren't marked as such with Markdown tags
--- The "gfm" type also includes the following extensions:
--- HARD_WRAP     - line breaks are replaced with <br> entities
--- SPACE_HEADERS - require a space between the # and the name of a header (prevents collisions with the Issues filter)
---@param markdown string
---@param type any
---@return output
function hs.doc.markdown.convert(markdown, type) end

-- ------------------------------------------------------------
-- hs.dockicon
-- ------------------------------------------------------------

---@class hs.dockicon
hs.dockicon = {}

--- Bounce Hammerspoon's dock icon
---@param indefinitely boolean
---@return any
function hs.dockicon.bounce(indefinitely) end

--- Hide Hammerspoon's dock icon
---@return any
function hs.dockicon.hide() end

--- Set Hammerspoon's dock icon badge
---@param badge string
---@return any
function hs.dockicon.setBadge(badge) end

--- Make Hammerspoon's dock icon visible
---@return any
function hs.dockicon.show() end

--- Get or set a canvas object to be displayed as the Hammerspoon dock icon
---
--- Note: If you update the canvas object by changing any of its components, it will not be reflected in the dock icon
--- until you invoke hs.dockicon.tileUpdate .
---@param canvas hs.canvas|nil
---@return hs.canvas|nil
function hs.dockicon.tileCanvas(canvas) end

--- Returns a table containing the size of the tile representing the dock icon.
---
--- Note: the size returned specifies the display size of the dock icon tile. If your canvas item is larger than this,
--- then only the top left portion corresponding to the size returned will be displayed.
---@return size table
function hs.dockicon.tileSize() end

--- Force an update of the dock icon.
---
--- Note: Changes made to a canvas object are not reflected automatically like they are when a canvas is being
--- displayed on the screen; you must invoke this method after making changes to the canvas for the updates to be
--- reflected in the dock icon.
---@return none
function hs.dockicon.tileUpdate() end

--- Determine whether Hammerspoon's dock icon is visible
---@return boolean
function hs.dockicon.visible() end

-- ------------------------------------------------------------
-- hs.drawing
-- ------------------------------------------------------------

---@class hs.drawing
hs.drawing = {}

---@class drawing
local drawing = {}

--- Array of window behavior labels for determining how an hs.drawing object is handled in Spaces and Exposé
---@type hs.drawing
hs.drawing.windowBehaviors[] = nil

--- A table of predefined window levels usable with
--- hs.drawing:setLevel(...)
---@type table
hs.drawing.windowLevels = nil

--- Returns a table containing the default font, size, color, and paragraphStyle used by
--- hs.drawing
--- for text drawing objects.
---
--- Note: This method returns the default font, size, color, and paragraphStyle used by hs.drawing for text objects.
--- If you modify a drawing object's defaults with hs.drawing:setColor , hs.drawing:setTextFont , or
--- hs.drawing:setTextSize , the changes will not be reflected by this function.
---@return table
function hs.drawing.defaultTextStyle() end

--- Tells the OS X window server to pause updating the physical displays for a short while.
---
--- Note: This method can be used to allow multiple changes which are being made to the users display appear as if they
--- all occur simultaneously by holding off on updating the screen on the regular schedule.
--- This method should always be balanced with a call to hs.drawing.enableScreenUpdates when your updates have been
--- completed.  Failure to do so will be logged in the system logs.
--- The window server will only allow you to pause updates for up to 1 second.  This prevents a rogue or hung process
--- from locking the systems display completely.  Updates will be resumed when hs.drawing.enableScreenUpdates is
--- encountered or after 1 second, whichever comes first.
--- The underlying OS function for disabling screen updates is deprecated.
---@deprecated
function hs.drawing.disableScreenUpdates() end

--- Tells the OS X window server to resume updating the physical displays after a previous pause.
---
--- Note: In conjunction with hs.drawing.disableScreenUpdates , this method can be used to allow multiple changes which
--- are being made to the users display appear as if they all occur simultaneously by holding off on updating the
--- screen on the regular schedule.
--- The window server will only allow you to pause updates for up to 1 second.  This prevents a rogue or hung process
--- from locking the systems display completely.  Updates will be resumed when this function is encountered  or after 1
--- second, whichever comes first.
--- The underlying OS function for enabling screen updates is deprecated.
---@deprecated
function hs.drawing.enableScreenUpdates() end

--- Get the size of the rectangle necessary to fully render the text with the specified style so that is will be
--- completely visible.
---
--- Note: This function assumes the default values specified for any key which is not included in the provided
--- textStyle.
--- The size returned is an approximation and may return a width that is off by about 4 points.  Use the returned size
--- as a minimum starting point. Sometimes using the "clip" or "truncateMiddle" lineBreak modes or "justified"
--- alignment will fit, but its safest to add in your own buffer if you have the space in your layout.
--- Multi-line text (separated by a newline or return) is supported.  The height will be for the multiple lines and the
--- width returned will be for the longest line.
--- The following simplified style format is supported for use with hs.drawing:setText and hs.drawing.setTextStyle .
--- theText   - the text which is to be displayed.
--- font      - the name of the font to use (default: the system font)
--- size      - the font point size to use (default: 27.0)
--- color     - ignored, but accepted for compatibility with hs.drawing:setTextStyle()
--- "left"      - the text is visually left aligned.
--- "right"     - the text is visually right aligned.
--- "center"    - the text is visually center aligned.
--- "justified" - the text is justified
--- "natural"   - (default) the natural alignment of the text’s script
--- "wordWrap"       - (default) wrap at word boundaries, unless the word itself doesn’t fit on a single line
--- "charWrap"       - wrap before the first character that doesn’t fit
--- "clip"           - do not draw past the edge of the drawing object frame
--- "truncateHead"   - the line is displayed so that the end fits in the frame and the missing text at the beginning of
--- the line is indicated by an ellipsis
--- "truncateTail"   - the line is displayed so that the beginning fits in the frame and the missing text at the end of
--- the line is indicated by an ellipsis
--- "truncateMiddle" - the line is displayed so that the beginning and end fit in the frame and the missing text in the
--- middle is indicated by an ellipsis
---@param styledTextObject or theText string
---@param textStyle hs.drawing|nil
---@return sizeTable|nil
function hs.drawing.getTextDrawingSize(styledTextObject or theText, textStyle) end

--- Creates a new image object with the icon of a given app
---@param sizeRect table
---@param bundleID string
---@return hs.drawing|nil
function hs.drawing.appImage(sizeRect, bundleID) end

--- Creates a new arc object
---
--- Note: This constructor is actually a wrapper for the hs.drawing.ellipticalArc constructor.
---@param centerPoint table
---@param radius any
---@param startAngle any
---@param endAngle any
---@return hs.drawing|nil
function hs.drawing.arc(centerPoint, radius, startAngle, endAngle) end

--- Creates a new circle object
---@param sizeRect table
---@return hs.drawing|nil
function hs.drawing.circle(sizeRect) end

--- Creates a new elliptical arc object
---@param sizeRect table
---@param startAngle any
---@param endAngle any
---@return hs.drawing|nil
function hs.drawing.ellipticalArc(sizeRect, startAngle, endAngle) end

--- Creates a new image object
---
--- Note: To use the ASCII diagram image support, see http://cocoamine.net/blog/2015/03/20/replacing-photoshop-with-nsstring/ and be sure to preface your ASCII diagram with the special string ASCII:
---@param sizeRect table
---@param imageData any
---@return hs.drawing|nil
function hs.drawing.image(sizeRect, imageData) end

--- Creates a new line object
---@param originPoint table
---@param endPoint table
---@return hs.drawing|nil
function hs.drawing.line(originPoint, endPoint) end

--- Creates a new rectangle object
---@param sizeRect table
---@return hs.drawing|nil
function hs.drawing.rectangle(sizeRect) end

--- Creates a new text object
---@param sizeRect table
---@param message string
---@return hs.drawing|nil
function hs.drawing.text(sizeRect, message) end

--- Get the alpha level of the window containing the hs.drawing object.
---@return number
function drawing:alpha() end

--- Returns the current behavior of the hs.drawing object with respect to Spaces and Exposé for the object.
---@return number
function drawing:behavior() end

--- Returns a table of the labels for the current behaviors of the object.
---@return table
function drawing:behaviorAsLabels() end

--- Places the drawing object on top of normal windows
---
--- Note: As of macOS Sierra and later, if you want a hs.drawing object to appear above full-screen windows you must
--- hide the Hammerspoon Dock icon first using: hs.dockicon.hide()
---@param aboveEverything boolean|nil
---@return hs.drawing
function drawing:bringToFront(aboveEverything) end

--- Get or set whether or not clicking on a drawing with a click callback defined should bring all of Hammerspoon's
--- open windows to the front.
---
--- Note: Setting this to false changes a drawing object's AXsubrole value and may affect the results of filters
--- defined for hs.window.filter, depending upon how they are defined.
---@param false any
---@return hs.drawing
function drawing:clickCallbackActivating(false) end

--- Set the screen area in which the drawing contents are visible.
---
--- Note: This method can be used to specify the area of the display where this drawing should be visible.  If any
--- portion of the drawing extends beyond this rectangle, the image is clipped so that only the portion within this
--- rectangle is visible.
--- The rectangle defined by this method is independent of the drawing's actual frame -- if you move the drawing with
--- hs.drawing:setFrame or hs.drawing:setTopLeft , this rectangle retains its current value.
--- This method does not work for image objects at present.
---@param rect any
---@return hs.drawing
function drawing:clippingRectangle(rect) end

--- Destroys the drawing object
---
--- Note: This method immediately destroys the drawing object. If you want it to fade out, use :hide() first, with some
--- suitable time, and hs.timer.doAfter() to schedule the :delete() call
---@return any
function drawing:delete() end

--- Gets the frame of a drawingObject in absolute coordinates
---@return hs.geometry
function drawing:frame() end

--- Gets the text of a drawing object as an
--- hs.styledtext
--- object
---
--- Note: This method should only be used on text drawing objects
---@return hs.styledtext
function drawing:getStyledText() end

--- Hides the drawing object
---@param fadeOutTime any
---@return hs.drawing
function drawing:hide(fadeOutTime) end

--- Get or set the alignment of an image that doesn't fully fill the drawing objects frame.
---@param type any
---@return hs.drawing
function drawing:imageAlignment(type) end

--- Get or set whether or not an animated GIF image should cycle through its animation.
---@param flag any
---@return hs.drawing
function drawing:imageAnimates(flag) end

--- Get or set what type of frame should be around the drawing frame of the image.
---
--- Note: Apple considers the photo, groove, and button style frames "stylistically obsolete" and if a frame is
--- required, recommend that you use the bezel style or draw your own to more closely match the OS look and feel.
---@param type any
---@return hs.drawing
function drawing:imageFrame(type) end

--- Get or set how an image is scaled within the frame of a drawing object containing an image.
---@param type any
---@return hs.drawing
function drawing:imageScaling(type) end

--- Moves drawing object above drawing object2, or all drawing objects in the same presentation level, if object2 is
--- not provided.
---@param object2 any
---@return object
function drawing:orderAbove(object2) end

--- Moves drawing object below drawing object2, or all drawing objects in the same presentation level, if object2 is
--- not provided.
---@param object2 any
---@return object1
function drawing:orderBelow(object2) end

--- Rotates an image clockwise around its center
---
--- Note: This method works by rotating the image view within its drawing window.  This means that an image which
--- completely fills its viewing area will most likely be cropped in some places.  Best results are achieved with
--- images that have clear space around their edges or with hs.drawing.imageScaling set to "none".
---@param angle any
---@return hs.drawing
function drawing:rotateImage(angle) end

--- Places the drawing object behind normal windows, between the desktop wallpaper and desktop icons
---@return hs.drawing
function drawing:sendToBack() end

--- Sets the alpha level of the window containing the hs.drawing object.
---@param level any
---@return object
function drawing:setAlpha(level) end

--- Changes the starting and ending angles for an arc drawing object
---
--- Note: This method should only be used on arc drawing objects
---@param startAngle any
---@param endAngle any
---@return hs.drawing
function drawing:setArcAngles(startAngle, endAngle) end

--- Sets the window behaviors represented by the number provided for the window containing the hs.drawing object.
---@param behavior any
---@return object
function drawing:setBehavior(behavior) end

--- Sets the window behaviors based upon the labels specified in the table provided.
---@param table any
---@return object
function drawing:setBehaviorByLabels(table) end

--- Sets a callback for mouseUp and mouseDown click events
---
--- Note: No distinction is made between the left, right, or other mouse buttons -- they all invoke the same up or down
--- function.  If you need to determine which specific button was pressed, use hs.eventtap.checkMouseButtons() within
--- your callback to check.
---@param mouseUpFn function
---@param mouseDownFn function
---@return hs.drawing
function drawing:setClickCallback(mouseUpFn, mouseDownFn) end

--- Sets whether or not to fill a drawing object
---
--- Note: This method should only be used on line, rectangle, circle, or arc drawing objects
---@param doFill boolean
---@return hs.drawing
function drawing:setFill(doFill) end

--- Sets the fill color of a drawing object
---
--- Note: This method should only be used on rectangle, circle, or arc drawing objects
--- Calling this method will remove any gradient fill colors previously set with hs.drawing:setFillGradient()
---@param color hs.drawing.color
---@return hs.drawing
function drawing:setFillColor(color) end

--- Sets the fill gradient of a drawing object
---
--- Note: This method should only be used on rectangle, circle, or arc drawing objects
--- Calling this method will remove any fill color previously set with hs.drawing:setFillColor()
---@param startColor any
---@param endColor any
---@param angle number
---@return hs.drawing
function drawing:setFillGradient(startColor, endColor, angle) end

--- Sets the frame of the drawingObject in absolute coordinates
---@param rect table
---@return hs.drawing
function drawing:setFrame(rect) end

--- Sets the image of a drawing object
---@param image hs.image
---@return hs.drawing
function drawing:setImage(image) end

--- Sets the image of a drawing object from an ASCII representation
---
--- Note: To use the ASCII diagram image support, see http://cocoamine.net/blog/2015/03/20/replacing-photoshop-with-nsstring
---@param ascii string
---@return hs.drawing
function drawing:setImageASCII(ascii) end

--- Sets the image path of a drawing object
---
--- Note: This method should only be used on an image drawing object
--- Paths relative to the PWD of Hammerspoon (typically ~/.hammerspoon/) will work, but paths relative to the UNIX
--- homedir character, ~ will not
--- Animated GIFs are supported. They're not super friendly on your CPU, but they work
---@param imagePath string
---@return hs.drawing
function drawing:setImageFromPath(imagePath) end

--- Sets the window level more precisely than sendToBack and bringToFront.
---
--- Note: see the notes for hs.drawing.windowLevels
--- These levels may be unable to explicitly place drawing objects around full-screen macOS windows
---@param theLevel hs.drawing.windowLevels
---@return hs.drawing
function drawing:setLevel(theLevel) end

--- Sets the radii of the corners of a rectangle drawing object
---
--- Note: This method should only be used on rectangle drawing objects
--- If either radius value is greater than half the width/height (as appropriate) of the rectangle, the value will be
--- clamped at half the width/height
--- If either (or both) radius values are 0, the rectangle will be drawn without rounded corners
---@param xradius number
---@param yradius number
---@return hs.drawing
function drawing:setRoundedRectRadii(xradius, yradius) end

--- Resizes a drawing object
---
--- Note: If this is called on an hs.drawing.text object, only its window will be resized. If you also want to change
--- the font size, use :setTextSize()
---@param size table
---@return hs.drawing
function drawing:setSize(size) end

--- Sets whether or not to stroke a drawing object
---
--- Note: This method should only be used on line, rectangle, circle, or arc drawing objects
---@param doStroke boolean
---@return hs.drawing
function drawing:setStroke(doStroke) end

--- Sets the stroke color of a drawing object
---
--- Note: This method should only be used on line, rectangle, circle, or arc drawing objects
---@param color hs.drawing.color
---@return hs.drawing
function drawing:setStrokeColor(color) end

--- Sets the stroke width of a drawing object
---
--- Note: This method should only be used on line, rectangle, circle, or arc drawing objects
---@param width number
---@return hs.drawing
function drawing:setStrokeWidth(width) end

--- Sets the text of a drawing object from an
--- hs.styledtext
--- object
---
--- Note: This method should only be used on text drawing objects
---@param message hs.styledtext
---@return hs.drawing
function drawing:setStyledText(message) end

--- Sets the text of a drawing object
---
--- Note: This method should only be used on text drawing objects
--- If the text of the drawing object is emptied (i.e. "") then style changes may be lost.  Use a placeholder such as a
--- space (" ") or hide the object if style changes need to be saved but the text should disappear for a while.
---@param message string
---@return hs.drawing
function drawing:setText(message) end

--- Sets the default text color for a drawing object
---
--- Note: This method should only be called on text drawing objects
--- This method changes the font color for portions of an hs.drawing text object which do not have a specific font set
--- in their attributes list (see hs.styledtext for more details).
---@param color hs.drawing.color
---@return hs.drawing
function drawing:setTextColor(color) end

--- Sets the default font for a drawing object
---
--- Note: This method should only be used on text drawing objects
--- This method changes the font for portions of an hs.drawing text object which do not have a specific font set in
--- their attributes list (see hs.styledtext for more details).
---@param fontname string
---@return hs.drawing
function drawing:setTextFont(fontname) end

--- Sets the default text size for a drawing object
---
--- Note: This method should only be used on text drawing objects
--- This method changes the font size for portions of an hs.drawing text object which do not have a specific font set
--- in their attributes list (see hs.styledtext for more details).
---@param size number
---@return hs.drawing
function drawing:setTextSize(size) end

--- Sets some simple style parameters for the entire text of a drawing object.  For more control over style including
--- having multiple styles within a single text object, use
--- hs.styledtext
--- and
--- hs.drawing:setStyledText
--- instead.
---
--- Note: This method should only be used on text drawing objects
--- If the text of the drawing object is currently empty (i.e. "") then style changes may be lost.  Use a placeholder
--- such as a space (" ") or hide the object if style changes need to be saved but the text should disappear for a
--- while.
--- Only the keys specified are changed.  To reset an object to all of its defaults, call this method with an explicit
--- nil as its only parameter (e.g. hs.drawing:setTextStyle(nil)
--- The font, font size, and font color can also be set by their individual specific methods as well; this method is
--- provided so that style components can be stored and applied collectively, as well as used by
--- hs.drawing.getTextDrawingSize() to determine the proper rectangle size for a textual drawing object.
---@param textStyle any
---@return hs.drawing
function drawing:setTextStyle(textStyle) end

--- Moves the drawingObject to a given point
---@param point table
---@return hs.drawing
function drawing:setTopLeft(point) end

--- Displays the drawing object
---@param fadeInTime number|nil
---@return hs.drawing
function drawing:show(fadeInTime) end

-- ------------------------------------------------------------
-- hs.drawing.color
-- ------------------------------------------------------------

---@class hs.drawing.color
hs.drawing.color = {}

--- This table contains this list of defined color collections provided by the
--- hs.drawing.color
--- module.  Collections differ from the system color lists in that you can modify the color values their members
--- contain by modifying the table at
--- hs.drawing.color.<collection>.<color>
--- and future references to that color will reflect the new changes, thus allowing you to customize the palettes for
--- your installation.
---@type table
hs.drawing.color.definedCollections = nil

--- A collection of colors representing the ANSI Terminal color sequences.  The color definitions are based upon code
--- found at https://github.com/balthamos/geektool-3 in the /NerdTool/classes/ANSIEscapeHelper.m file.
---@type any
hs.drawing.color.ansiTerminalColors = nil

--- This table contains a collection of various useful pre-defined colors:
---@type table
hs.drawing.color.hammerspoon = nil

--- A collection of colors representing the X11 color names as defined at
--- https://en.wikipedia.org/wiki/Web_colors#X11_color_names (names in lowercase)
---@type any
hs.drawing.color.x11 = nil

--- Returns a table containing the HSB representation of the specified color.
---
--- Note: See also hs.drawing.color.asRGB
---@param color table
---@return table|string
function hs.drawing.color.asHSB(color) end

--- Returns a table containing the RGB representation of the specified color.
---
--- Note: See also hs.drawing.color.asHSB
---@param color table
---@return table|string
function hs.drawing.color.asRGB(color) end

--- Returns a table containing the colors for the specified system color list or hs.drawing.color collection.
---
--- Note: Where possible, each color node is provided as its RGB color representation.  Where this is not possible, the
--- color node contains the keys list and name which identify the indicated color.  This means that you can use the
--- following wherever a color parameter is expected: hs.drawing.color.colorsFor(list)["color-name"]
--- This function provides a tostring metatable method which allows listing the defined colors in the list in the
--- Hammerspoon console with: hs.drawing.colorsFor(list)
--- See also hs.drawing.color.lists
---@param list table
---@return table
function hs.drawing.color.colorsFor(list) end

--- Returns a table containing the system color lists and hs.drawing.color collections with their defined colors.
---
--- Note: Where possible, each color node is provided as its RGB color representation.  Where this is not possible, the
--- color node contains the keys list and name which identify the indicated color.  This means that you can use the
--- following wherever a color parameter is expected: hs.drawing.color.lists()["list-name"]["color-name"]
--- This function provides a tostring metatable method which allows listing the defined color lists in the Hammerspoon
--- console with: hs.drawing.color.lists()
--- See also hs.drawing.color.colorsFor
---@return table
function hs.drawing.color.lists() end

-- ------------------------------------------------------------
-- hs.eventtap
-- ------------------------------------------------------------

---@class hs.eventtap
hs.eventtap = {}

---@class eventtap
local eventtap = {}

--- Returns a table containing the current key modifiers being pressed or in effect
--- at this instant
--- for the keyboard most recently used.
---
--- Note: This is an instantaneous poll of the current keyboard modifiers for the most recently used keyboard, not a
--- callback.  This is useful primarily in conjunction with other modules, such as hs.menubar , when a callback is
--- already in progress or waiting for an event callback is not practical or possible.
--- the numeric value returned is useful if you need to detect device dependent flags or flags which we normally ignore
--- because they are not present (or are accessible another way) on most keyboards.
---@param raw boolean|nil
---@return table
function hs.eventtap.checkKeyboardModifiers(raw) end

--- Returns a table containing the current mouse buttons being pressed
--- at this instant
--- .
---
--- Note: This is an instantaneous poll of the current mouse buttons, not a callback.  This is useful primarily in
--- conjunction with other modules, such as hs.menubar , when a callback is already in progress or waiting for an event
--- callback is not practical or possible.
---@return table
function hs.eventtap.checkMouseButtons() end

--- Returns the system-wide setting for the delay between two clicks, to register a double click event
---@return number
function hs.eventtap.doubleClickInterval() end

--- Checks if macOS is preventing keyboard events from being sent to event taps
---
--- Note: If secure input is enabled, Hammerspoon is not able to intercept keyboard events
--- Secure input is enabled generally only in situations where an password field is focused in a web browser, system
--- dialog or terminal
---@return boolean
function hs.eventtap.isSecureInputEnabled() end

--- Returns the system-wide setting for the delay before keyboard repeat events begin
---@return number
function hs.eventtap.keyRepeatDelay() end

--- Returns the system-wide setting for the interval between repeated keyboard events
---@return number
function hs.eventtap.keyRepeatInterval() end

--- Generates and emits a single keystroke event pair for the supplied keyboard modifiers and character
---
--- Note: This function is ideal for sending single keystrokes with a modifier applied (e.g. sending ⌘-v to paste, with
--- hs.eventtap.keyStroke({"cmd"}, "v") ). If you want to emit multiple keystrokes for typing strings of text, see
--- hs.eventtap.keyStrokes()
--- Note that invoking this function with a table (empty or otherwise) for the modifiers argument will force the
--- release of any modifier keys which have been explicitly created by hs.eventtap.event.newKeyEvent and posted that
--- are still in the "down" state. An explicit nil for this argument will not (i.e. the keystroke will inherit any
--- currently "down" modifiers)
---@param modifiers table
---@param character string
---@param delay? number
---@param application? hs.application|nil
---@return any
function hs.eventtap.keyStroke(modifiers, character, delay, application) end

--- Generates and emits keystroke events for the supplied text
---
--- Note: If you want to send a single keystroke with keyboard modifiers (e.g. sending ⌘-v to paste), see
--- hs.eventtap.keyStroke()
---@param text string
---@param application? hs.application|nil
---@return any
function hs.eventtap.keyStrokes(text, application) end

--- Generates a left mouse click event at the specified point
---
--- Note: This is a wrapper around hs.eventtap.event.newMouseEvent that sends leftmousedown and leftmouseup events)
---@param point table
---@param delay? number
---@return any
function hs.eventtap.leftClick(point, delay) end

--- Generates a middle mouse click event at the specified point
---
--- Note: This function is just a wrapper which calls hs.eventtap.otherClick(point, delay, 2) and is included solely
--- for backwards compatibility.
---@param point table
---@param delay? number
---@return any
function hs.eventtap.middleClick(point, delay) end

--- Generates an "other" mouse click event at the specified point
---
--- Note: This is a wrapper around hs.eventtap.event.newMouseEvent that sends otherMouseDown and otherMouseUp events)
--- macOS recognizes up to 32 distinct mouse buttons, though few mouse devices have more than 3.  The left mouse button
--- corresponds to button number 0 and the right mouse button corresponds to 1;  distinct events are used for these
--- mouse buttons, so you should use hs.eventtap.leftClick and hs.eventtap.rightClick respectively.  All other mouse
--- buttons are coalesced into the otherMouse events and are distinguished by specifying the specific button with the
--- mouseEventButtonNumber property, which this function does for you.
--- The specific purpose of mouse buttons greater than 2 varies by hardware and application (typically they are not
--- present on a mouse and have no effect in an application)
---@param point table
---@param delay? number
---@param button? number|nil
---@return any
function hs.eventtap.otherClick(point, delay, button) end

--- Generates a right mouse click event at the specified point
---
--- Note: This is a wrapper around hs.eventtap.event.newMouseEvent that sends rightmousedown and rightmouseup events)
---@param point table
---@param delay? number
---@return any
function hs.eventtap.rightClick(point, delay) end

--- Generates and emits a scroll wheel event
---@param offsets table
---@param modifiers any
---@param unit string|nil
---@return event
function hs.eventtap.scrollWheel(offsets, modifiers, unit) end

--- Create a new event tap object
---
--- Note: If you specify the argument types as the special table {"all"[, events to ignore]}, then all events (except
--- those you optionally list after the "all" string) will trigger a callback, even events which are not defined in the
--- Quartz Event Reference .
---@param types table
---@param fn function|nil
---@return eventtap
function hs.eventtap.new(types, fn) end

--- Determine whether or not an event tap object is enabled.
---@return boolean
function eventtap:isEnabled() end

--- Starts an event tap
---@return any
function eventtap:start() end

--- Stops an event tap
---@return any
function eventtap:stop() end

-- ------------------------------------------------------------
-- hs.eventtap.event
-- ------------------------------------------------------------

---@class hs.eventtap.event
hs.eventtap.event = {}

---@class event
local event = {}

--- A table containing property types for use with
--- hs.eventtap.event:getProperty()
--- and
--- hs.eventtap.event:setProperty()
--- .  The table supports forward (label to number) and reverse (number to label) lookups to increase its flexibility.
---@type table
hs.eventtap.event.properties -> table = nil

--- A table containing key-value pairs describing the raw modifier flags which can be manipulated with
--- hs.eventtap.event:rawFlags
--- .
---@type table
hs.eventtap.event.rawFlagMasks[] = nil

--- A table containing event types to be used with
--- hs.eventtap.new(...)
--- and returned by
--- hs.eventtap.event:type()
--- .  The table supports forward (label to number) and reverse (number to label) lookups to increase its flexibility.
---@type table
hs.eventtap.event.types -> table = nil

--- Generates a table containing the keydown and keyup events to generate the keystroke with the specified modifiers.
---
--- Note: The modifiers table must contain the full name of the modifiers you wish used for the keystroke as defined in
--- hs.keycodes.map -- the Unicode equivalents are not supported by this function.
--- The returned table will always contain an even number of events -- the first half will be the keyDown events and
--- the second half will be the keyUp events.
--- The events have not been posted; the table can be used without change as the return value for a callback to a
--- watcher defined with hs.eventtap.new .
---@param modifiers table
---@param character string
---@return table
function hs.eventtap.event.newKeyEventSequence(modifiers, character) end

--- Duplicates an
--- hs.eventtap.event
--- event for further modification or injection
---@return event
function event:copy() end

--- Creates a blank event.  You will need to set its type with
--- hs.eventtap.event:setType
---
--- Note: this is an empty event that you should set a type for and whatever other properties may be appropriate before
--- posting.
---@return event
function hs.eventtap.event.newEvent() end

--- Creates an event from the data encoded in the string provided.
---@param data string
---@return event
function hs.eventtap.event.newEventFromData(data) end

--- Creates an gesture event.
---
--- Note: Valid gestureType values are:
--- beginMagnify - Starts a magnification event with an optional magnification value as a number (defaults to 0). The
--- exact unit of measurement is unknown.
--- endMagnify - Starts a magnification event with an optional magnification value as a number (defaults to 0.1). The
--- exact unit of measurement is unknown.
--- beginRotate - Starts a rotation event with an rotation value in degrees (i.e. a value of 45 turns it 45 degrees
--- left - defaults to 0).
--- endRotate - Starts a rotation event with an rotation value in degrees (i.e. a value of 45 turns it 45 degrees left
--- - defaults to 45).
--- beginSwipeLeft - Begin a swipe left.
--- endSwipeLeft - End a swipe left.
--- beginSwipeRight - Begin a swipe right.
--- endSwipeRight - End a swipe right.
--- beginSwipeUp - Begin a swipe up.
--- endSwipeUp - End a swipe up.
--- beginSwipeDown - Begin a swipe down.
--- endSwipeDown - End a swipe down.
---@param gestureType string
---@param gestureValue? any
---@return event
function hs.eventtap.event.newGesture(gestureType, gestureValue) end

--- Creates a keyboard event
---
--- Note: The original version of this constructor utilized a shortcut which merged flagsChanged and keyUp / keyDown
--- events into one.  This approach is still supported for backwards compatibility and because it does work in most
--- cases.
--- According to Apple Documentation, the proper way to perform a keypress with modifiers is through multiple key
--- events; for example to generate 'Å', you should do the following:
--- hs
--- .
--- eventtap
--- .
--- event
--- .
--- newKeyEvent
--- (
--- hs
--- .
--- keycodes
--- .
--- map
--- .
--- shift
--- ,
--- true
--- ):
--- post
--- ()
--- hs
--- .
--- eventtap
--- .
--- event
--- .
--- newKeyEvent
--- (
--- hs
--- .
--- keycodes
--- .
--- map
--- .
--- alt
--- ,
--- true
--- ):
--- post
--- ()
--- hs
--- .
--- eventtap
--- .
--- event
--- .
--- newKeyEvent
--- (
--- "a"
--- ,
--- true
--- ):
--- post
--- ()
--- hs
--- .
--- eventtap
--- .
--- event
--- .
--- newKeyEvent
--- (
--- "a"
--- ,
--- false
--- ):
--- post
--- ()
--- hs
--- .
--- eventtap
--- .
--- event
--- .
--- newKeyEvent
--- (
--- hs
--- .
--- keycodes
--- .
--- map
--- .
--- alt
--- ,
--- false
--- ):
--- post
--- ()
--- hs
--- .
--- eventtap
--- .
--- event
--- .
--- newKeyEvent
--- (
--- hs
--- .
--- keycodes
--- .
--- map
--- .
--- shift
--- ,
--- false
--- ):
--- post
--- ()
--- The shortcut method is still supported, though if you run into odd behavior or need to generate flagsChanged events
--- without a corresponding keyUp or keyDown , please check out the syntax demonstrated above.
--- hs
--- .
--- eventtap
--- .
--- event
--- .
--- newKeyEvent
--- ({
--- "shift"
--- ,
--- "alt"
--- },
--- "a"
--- ,
--- true
--- ):
--- post
--- ()
--- hs
--- .
--- eventtap
--- .
--- event
--- .
--- newKeyEvent
--- ({
--- "shift"
--- ,
--- "alt"
--- },
--- "a"
--- ,
--- false
--- ):
--- post
--- ()
--- The shortcut approach is still limited to generating only the left version of modifiers.
---@param mods any
---@param key string
---@param isdown boolean
---@return event
function hs.eventtap.event.newKeyEvent(mods, key, isdown) end

--- Creates a new mouse event
---@param eventtype hs.eventtap.event.types
---@param point hs.geometry
---@param modifiers? any
---@return event
function hs.eventtap.event.newMouseEvent(eventtype, point, modifiers) end

--- Creates a scroll wheel event
---@param offsets table
---@param mods any
---@param unit string|nil
---@return event
function hs.eventtap.event.newScrollEvent(offsets, mods, unit) end

--- Creates a keyboard event for special keys (e.g. media playback)
---
--- Note: To set modifiers on a system key event (e.g. cmd/ctrl/etc), see the hs.eventtap.event:setFlags() method
--- The event names are case sensitive
---@param key string
---@param isdown boolean
---@return event
function hs.eventtap.event.newSystemKeyEvent(key, isdown) end

--- Returns a string containing binary data representing the event.  This can be used to record events for later use.
---
--- Note: You can recreate the event for later posting with hs.eventtap.event.newEventFromData
---@return string
function event:asData() end

--- Gets the state of a mouse button in the event
---
--- Note: This method should only be called on mouse events
---@param button number
---@return boolean
function event:getButtonState(button) end

--- Returns the Unicode character, if any, represented by a keyDown or keyUp event.
---
--- Note: This method should only be used on keyboard events
--- If clean is true, all modifiers except for Shift are stripped from the character before converting to the Unicode
--- character represented by the keypress.
--- If the keypress does not correspond to a valid Unicode character, an empty string is returned (e.g. if clean is
--- false, then Opt-E will return an empty string, while Opt-Shift-E will return an accent mark).
---@param clean any
---@return string|nil
function event:getCharacters(clean) end

--- Gets the keyboard modifiers of an event
---@return table
function event:getFlags() end

--- Gets the raw keycode for the event
---
--- Note: This method should only be used on keyboard events
---@return keycode
function event:getKeyCode() end

--- Gets a property of the event
---
--- Note: The properties are CGEventField values, as documented at https://developer.apple.com/library/mac/documentation/Carbon/Reference/QuartzEventServicesRef/index.html#//apple_ref/c/tdef/CGEventField
---@param prop hs.eventtap.event.properties
---@return number
function event:getProperty(prop) end

--- Returns raw data about the event
---
--- Note: Most of the data in CGEventData is already available through other methods, but is presented here without any
--- cleanup or parsing.
--- This method is expected to be used mostly for testing and expanding the range of possibilities available with the
--- hs.eventtap module.  If you find that you are regularly using specific data from this method for common or
--- re-usable purposes, consider submitting a request for adding a more targeted method to hs.eventtap or
--- hs.eventtap.event -- it will likely be more efficient and faster for common tasks, something eventtaps need to be
--- to minimize affecting system responsiveness.
---@return table
function event:getRawEventData() end

--- Returns a table containing more information about some touch related events.
---@return table|nil
function event:getTouchDetails() end

--- Returns a table of details containing information about touches on the trackpad associated with this event if the
--- event is of the type
--- hs.eventtap.event.types.gesture
--- .
---
--- Note: device - a string containing a unique identifier for the device on which the touch occurred. At present we do
--- not have a way to match the identifier to a specific touch device, but if multiple such devices are attached to the
--- computer, this value will differ between them.
--- deviceSize - a size table containing keys h and w for the height and width of the touch device in points (72 PPI
--- resolution).
--- force - a number representing a measure of the force of the touch when the device is a forcetouch trackpad. This
--- will be 0.0 for non-forcetouch trackpads and the touchbar.
--- identity - a string specifying a unique identifier for the touch guaranteed to be unique for the life of the touch.
--- This identifier may be used to track the movement of a specific touch (e.g. finger) as it moves through successive
--- callbacks.
--- phase - a string specifying the current phase the touch is considered to be in. The possible values are: "began",
--- "moved", "stationary", "ended", or "cancelled".
--- resting - Resting touches occur when a user simply rests their thumb on the trackpad device. Requires that the
--- foreground window has views accepting resting touches.
--- timestamp - a number representing the time the touch was detected. This number corresponds to seconds since the
--- last system boot, not including time the computer has been asleep. Comparable to hs.timer.absoluteTime() /
--- 1000000000 .
--- touching - a boolean specifying whether or not the touch phase is "began", "moved", or "stationary" (i.e. is not
--- "ended" or "cancelled").
--- type - a string specifying the type of touch. A "direct" touch will indicate a touchbar, while a trackpad will
--- report "indirect".
--- The following fields will be present when the touch is from a touchpad ( type == "indirect")`
--- normalizedPosition - a point table specifying the x and y coordinates of the touch, each normalized to be a value
--- between 0.0 and 1.0. { x = 0, y = 0 } is the lower left corner of the touch device.
--- previousNormalizedPosition - a point table specifying the x and y coordinates of the previous position for this
--- specific touch (as linked by identity ) normalized to values between 0.0 and 1.0.
--- The following fields will be present when the touch is from the touchbar ( type == "direct")`
--- location - a point table specifying the x and y coordinates of the touch location within the touchbar.
--- previousLocation - a point table specifying the x and y coordinates of the previous location for this specific
--- touch (as linked by identity ) within the touchbar.
---@return table|nil
function event:getTouches() end

--- Gets the type of the event
---
--- Note: some newer events are grouped into a more generic event for watching purposes and the specific event type is
--- determined by examining the event through the Cocoa API. The primary example of this is for gestures on a trackpad
--- or touches of the touchbar, as all of these are grouped under the hs.eventtap.event.types.gesture event. For
--- example: myTap = hs . eventtap . new ( { hs . eventtap . event . types . gesture }, function ( e ) local
--- gestureType = e : getType ( true ) if gestureType == hs . eventtap . types . directTouch then -- they touched the
--- touch bar elseif gestureType == hs . eventtap . types . gesture then -- they are touching the trackpad, but it's
--- not for a gesture elseif gestureType == hs . eventtap . types . magnify then -- they're preforming a magnify
--- gesture -- etc -- see hs.eventtap.event.types for more endif end
---@param nsSpecificType any
---@return number
function event:getType(nsSpecificType) end

--- Gets the single unicode character of an event
---@return string
function event:getUnicodeString() end

--- Get or set the current mouse pointer location as defined for the event.
---
--- Note: the use or effect of this method is undefined if the event is not a mouse type event.
---@param pointTable table|nil
---@return event|table
function event:location(pointTable) end

--- Posts the event to the OS - i.e. emits the keyboard/mouse input defined by the event
---@param app hs.application|nil
---@return hs.eventtap.event
function event:post(app) end

--- Experimental method to get or set the modifier flags for an event directly.
---
--- Note: This method is experimental and may undergo changes or even removal in the future
--- See hs.eventtap.event.rawFlagMasks for more information
---@param flags hs.eventtap.event.rawFlagMasks|nil
---@return event|number
function event:rawFlags(flags) end

--- Sets the keyboard modifiers of an event
---@param table any
---@return event
function event:setFlags(table) end

--- Sets the raw keycode for the event
---
--- Note: This method should only be used on keyboard events
---@param keycode number
---@return hs.eventtap.event
function event:setKeyCode(keycode) end

--- Sets a property of the event
---
--- Note: The properties are CGEventField values, as documented at https://developer.apple.com/library/mac/documentation/Carbon/Reference/QuartzEventServicesRef/index.html#//apple_ref/c/tdef/CGEventField
---@param prop hs.eventtap.event.properties
---@param value number
---@return hs.eventtap.event
function event:setProperty(prop, value) end

--- Set the type for this event.
---@param type hs.eventtap.event.types
---@return event
function event:setType(type) end

--- Sets a unicode string as the output of the event
---
--- Note: Calling this method will reset any flags previously set on the event (because they don't make any sense, and
--- you should not try to set flags again)
--- This is likely to only work with short unicode strings that resolve to a single character
---@param string string
---@return hs.eventtap.event
function event:setUnicodeString(string) end

--- Returns the special key and its state if the event is a NSSystemDefined event of subtype AUX_CONTROL_BUTTONS
--- (special-key pressed)
---
--- Note: CAPS_LOCK seems to sometimes generate 0 or 2 key release events (down == false), especially on builtin laptop
--- keyboards, so it is probably safest (more reliable) to look for cases where down == true only.
--- If the key field contains "undefined", you can use the number in keyCode to look it up in
--- /System/Library/Frameworks/IOKit.framework/Headers/hidsystem/ev_keymap.h .  If you believe the numeric value is
--- part of a new system update or was otherwise mistakenly left out, please submit the label (it will defined in the
--- header file as NX_KEYTYPE_something ) and number to the Hammerspoon maintainers at
--- https://github.com/Hammerspoon/hammerspoon with a request for inclusion in the next Hammerspoon update.
---@return table
function event:systemKey() end

--- Get or set the timestamp of the event.
---
--- Note: Synthesized events have a timestamp of 0 by default.
--- The timestamp, if specified, is expressed as an integer representing the number of nanoseconds since the system was
--- last booted.  See hs.timer.absoluteTime .
--- This field appears to be informational only and is not required when crafting your own events with this module.
---@param absolutetime number|nil
---@return event|number
function event:timestamp(absolutetime) end

-- ------------------------------------------------------------
-- hs.expose
-- ------------------------------------------------------------

---@class hs.expose
hs.expose = {}

---@class expose
local expose = {}

--- Allows customization of the expose behaviour and user interface
---@type any
hs.expose.ui = nil

--- Creates a new hs.expose instance; it can use a windowfilter to determine which windows to show
---
--- Note: by default expose will show invisible windows and (unlike the OSX expose) windows from other spaces; use
--- hs.expose.ui or the uiPrefs parameter to change these behaviours.
---@param windowfilter any
---@param uiPrefs? hs.expose.ui|nil
---@param logname? hs.logger|nil
---@param loglevel? hs.logger|nil
---@return hs.expose
function hs.expose.new(windowfilter, uiPrefs, logname, loglevel) end

--- Hides the expose, if visible, and exits the modal mode
---
--- Note: Call this function if you need to make sure the modal is exited without waiting for the user to press esc
---@return any
function expose:hide() end

--- Shows an expose-like screen with modal keyboard hints for switching to, closing or minimizing/unminimizing windows.
---
--- Note: passing true for activeApplication will simply hide hints/thumbnails for applications other
--- than the active one, without recalculating the hints layout; conversely, setting onlyActiveApplication=true for an
--- expose instance's ui will calculate an optimal layout for the current active application's windows
--- Completing a hint will exit the expose and focus the selected window.
--- Pressing esc will exit the expose and with no action taken.
--- If shift is being held when a hint is completed (the background will be red), the selected
--- window will be closed. If it's the last window of an application, the application will be closed.
--- If alt is being held when a hint is completed (the background will be blue), the selected
--- window will be minimized (if visible) or unminimized/unhidden (if minimized or hidden).
---@param activeApplication any
---@return any
function expose:show(activeApplication) end

--- Toggles the expose - see
--- hs.expose:show()
--- and
--- hs.expose:hide()
---
--- Note: passing true for activeApplication will simply hide hints/thumbnails for applications other than the active
--- one, without recalculating the hints layout; conversely, setting onlyActiveApplication=true for an expose
--- instance's ui will calculate an optimal layout for the current active application's windows
--- Completing a hint will exit the expose and focus the selected window.
--- Pressing esc will exit the expose and with no action taken.
--- If shift is being held when a hint is completed (the background will be red), the selected window will be closed.
--- If it's the last window of an application, the application will be closed.
--- If alt is being held when a hint is completed (the background will be blue), the selected  window will be minimized
--- (if visible) or unminimized/unhidden (if minimized or hidden).
---@param activeApplication any
---@return any
function expose:toggleShow(activeApplication) end

-- ------------------------------------------------------------
-- hs.fnutils
-- ------------------------------------------------------------

---@class hs.fnutils
hs.fnutils = {}

--- Join two tables together
---
--- Note: table2 cannot be a sparse table, see http://www.luafaq.org/gotchas.html#T6.4
---@param table1 table
---@param table2 table
---@return table
function hs.fnutils.concat(table1, table2) end

--- Determine if a table contains a given object
---@param table table
---@param element table
---@return boolean
function hs.fnutils.contains(table, element) end

--- Copy a table using
--- pairs()
---@param table table
---@return table
function hs.fnutils.copy(table) end

--- Execute a function across a table (in arbitrary order), and discard the results
---@param table table
---@param fn function
---@return any
function hs.fnutils.each(table, fn) end

--- Returns true if the application of fn on every entry in table is true.
---@param table table
---@param fn function|nil
---@return boolean
function hs.fnutils.every(table, fn) end

--- Filter a table by running a predicate function on its elements (in arbitrary order)
---
--- Note: If table is a pure array table (list-like) without "holes", use hs.fnutils.ifilter() if you need guaranteed
--- in-order
--- processing and for better performance.
---@param table table
---@param fn function
---@return table
function hs.fnutils.filter(table, fn) end

--- Execute a function across a table and return the first element where that function returns true
---@param table table
---@param fn function
---@return element
function hs.fnutils.find(table, fn) end

--- Execute a function across a list-like table in order, and discard the results
---@param list table
---@param fn function
---@return any
function hs.fnutils.ieach(list, fn) end

--- Filter a list-like table by running a predicate function on its elements in order
---
--- Note: If list has "holes", all elements after the first hole will be lost, as the table is iterated over with
--- ipairs ;
--- use hs.fnutils.map() if your table has holes
---@param list table
---@param fn function
---@return list
function hs.fnutils.ifilter(list, fn) end

--- Execute a function across a list-like table in order, and collect the results
---
--- Note: If list has "holes", all elements after the first hole will be lost, as the table is iterated over with
--- ipairs ;
--- use hs.fnutils.map() if your table has holes
---@param list table
---@param fn function
---@return list
function hs.fnutils.imap(list, fn) end

--- Determine the location in a table of a given object
---@param table table
---@param element table
---@return number|nil
function hs.fnutils.indexOf(table, element) end

--- Execute a function across a table (in arbitrary order) and collect the results
---
--- Note: If table is a pure array table (list-like) without "holes", use hs.fnutils.imap() if you need guaranteed
--- in-order
--- processing and for better performance.
---@param table table
---@param fn function
---@return table
function hs.fnutils.map(table, fn) end

--- Execute, across a table, a function that outputs tables, and concatenate all of those tables together
---@param table table
---@param fn function
---@return table
function hs.fnutils.mapCat(table, fn) end

--- Reduce a table to a single element, using a function
---
--- Note: table cannot be a sparse table, see http://www.luafaq.org/gotchas.html#T6.4
--- The first iteration of the reducer will call fn with the first and second elements of the table. The second
--- iteration will call fn with the result of the first iteration, and the third element. This repeats until there is
--- only one element left
---@param table table
---@param fn function
---@param initial? table
---@return table
function hs.fnutils.reduce(table, fn, initial) end

--- Returns true if the application of fn on entries in table are true for at least one of the members.
---@param table table
---@param fn function|nil
---@return boolean
function hs.fnutils.some(table, fn) end

--- Convert string to an array of strings, breaking at the specified separator.
---
--- Note: Similar to "split" in Perl or "string.split" in Python.
--- Optional parameters nMax and bPlain are identified by their type -- if parameter 3 or 4 is a number or nil, it will
--- be considered a value for nMax ; if parameter 3 or 4 is a boolean value, it will be considered a value for bPlain .
--- Lua patterns are more flexible for pattern matching, but can also be slower if the split point is simple. See
--- §6.4.1 of the Lua_Reference_Manual at http://www.lua.org/manual/5.3/manual.html#6.4.1 for more information on Lua
--- patterns.
---@param sString string
---@param sSeparator any
---@param nMax? string|nil
---@param bPlain? boolean|nil
---@return { array }
function hs.fnutils.split(sString, sSeparator, nMax, bPlain) end

--- Creates a function that repeatedly iterates a table
---
--- Note: table cannot be a sparse table, see http://www.luafaq.org/gotchas.html#T6.4
--- An example usage: f = cycle ({ 4 , 5 , 6 }) { f (), f (), f (), f (), f (), f (), f ()} == { 4 , 5 , 6 , 4 , 5 , 6
--- , 4 }
---@param table table
---@return fn
function hs.fnutils.cycle(table) end

--- Returns a new function which takes the provided arguments and pre-applies them as the initial arguments to the
--- provided function.  When the new function is later invoked with additional arguments, they are appended to the end
--- of the initial list given and the complete list of arguments is finally passed into the provided function and its
--- result returned.
---
--- Note: This is best understood with an example which you can test in the Hammerspoon console: Create the function a
--- which has it's initial arguments set to 1,2,3 :
--- a = hs.fnutils.partial(function(...) return table.pack(...) end, 1, 2, 3) Now some examples of using the new
--- function, a(...) :
--- hs.inspect(a("a","b","c")) will return: { 1, 2, 3, "a", "b", "c", n = 6 }
--- hs.inspect(a(4,5,6,7))     will return: { 1, 2, 3, 4, 5, 6, 7, n = 7 }
--- hs.inspect(a(1))           will return: { 1, 2, 3, 1, n = 4 }
---@param fn function
---@param ... any
---@return fn'
function hs.fnutils.partial(fn, ...) end

--- Creates a function that will collect the result of a series of functions into a table
---@param ... any
---@return fn
function hs.fnutils.sequence(...) end

--- Iterator for retrieving elements from a table of key-value pairs in the order of the keys.
---
--- Note: Similar to Perl's sort(keys %hash)
--- for i,v in hs.fnutils.sortByKeys(t[, f]) do ... end
--- e.g. function(m,n) return not (m < n) end would result in reverse alphabetic order.
--- See Programming_In_Lua,_3rd_ed , page 52 for a more complete discussion.
--- function(m,n) if type(m) ~= type(n) then return tostring(m) < tostring(n) else return m < n end
---@param table table
---@param function any
---@return function
function hs.fnutils.sortByKeys(table, function) end

--- Iterator for retrieving elements from a table of key-value pairs in the order of the values.
---
--- Note: Similar to Perl's sort { $hash{$a} <=> $hash{$b} } keys %hash
--- for i,v in hs.fnutils.sortByKeyValues(t[, f]) do ... end
--- e.g. function(m,n) return not (m < n) end would result in reverse alphabetic order.
--- See Programming_In_Lua,_3rd_ed , page 52 for a more complete discussion.
--- function(m,n) if type(m) ~= type(n) then return tostring(m) < tostring(n) else return m < n end
---@param table table
---@param function any
---@return function
function hs.fnutils.sortByKeyValues(table, function) end

-- ------------------------------------------------------------
-- hs.fs
-- ------------------------------------------------------------

---@class hs.fs
hs.fs = {}

--- A table containing the default list of patterns to ignore when using the
--- hs.fs.fileListForPath
--- .
---@type table
hs.fs.defaultPathListExcludes -> table = nil

--- Gets the attributes of a file
---
--- Note: This function uses stat() internally thus if the given filepath is a symbolic link, it is followed (if it
--- points to another link the chain is followed recursively) and the information is about the file it refers to. To
--- obtain information about the link itself, see function hs.fs.symlinkAttributes()
---@param filepath string
---@param aName? string
---@return table|string|nil
---@return error
function hs.fs.attributes(filepath, aName) end

--- Changes the current working directory to the given path.
---@param path string
---@return boolean|nil
---@return error
function hs.fs.chdir(path) end

--- Gets the current working directory
---@return string|nil
---@return error
function hs.fs.currentDir() end

--- Creates an iterator for walking a filesystem path
---
--- Note: Unlike most functions in this module, hs.fs.dir will throw a Lua error if the supplied path cannot be
--- iterated.
--- The simplest way to use this function is with a for loop. When used in this manner, the for loop itself will take
--- care of closing the directory stream for us, even if we break out of the loop early. for file in
--- hs.fs.dir("/Users/Guest/Documents") do
--- print(file)
--- end
--- It is also possible to use the dir_obj directly if you wish: local iterFn, dirObj =
--- hs.fs.dir("/Users/Guest/Documents")
--- local file = dirObj:next() -- get the first file in the directory
--- while (file) do
--- print(file)
--- file = dirObj:next() -- get the next file in the directory
--- end
--- dirObj:close() -- necessary to make sure that the directory stream is closed
---@param path string
---@return iter_fn
---@return dir_obj
---@return nil
---@return dir_obj
function hs.fs.dir(path) end

--- Returns the display name of the file or directory at a specified path.
---@param filepath string
---@return string
function hs.fs.displayName(filepath) end

--- Returns a table containing the paths to all of the files located at the specified path.
---
--- Note: note that this function only checks to see if the regular expression returns a match for each filename found
--- (not the path, just the filename component of the path). Any captures are ignored.
---@param path string
---@param options any
---@return table
---@return fileCount
---@return dirCount
function hs.fs.fileListForPath(path, options) end

--- Returns the Uniform Type Identifier for the file location specified.
---@param path string
---@return string|nil
function hs.fs.fileUTI(path) end

--- Returns the fileUTI's equivalent form in an alternate type specification format.
---@param fileUTI any
---@param type any
---@return string
function hs.fs.fileUTIalternate(fileUTI, type) end

--- Get the Finder comments for the file or directory at the specified path
---
--- Note: This function uses hs.osascript to access the file comments through AppleScript
---@param path string
---@return string
function hs.fs.getFinderComments(path) end

--- Creates a link
---@param old string
---@param new string
---@param symlink? boolean|nil
---@return boolean|nil
---@return error
function hs.fs.link(old, new, symlink) end

--- Locks a file, or part of it
---@param filehandle any
---@param mode string
---@param start? number|nil
---@param length? number|nil
---@return boolean|nil
---@return error
function hs.fs.lock(filehandle, mode, start, length) end

--- Locks a directory
---
--- Note: This is not a low level OS feature, the lock is actually a file created in the path, called lockfile.lfs , so
--- the directory must be writable for this function to succeed
--- The returned lock object can be freed with lock:free()
--- If the lock already exists and is not stale, the error string returned will be "File exists"
---@param path string
---@param seconds_stale number|nil
---@return lock|nil
---@return error
function hs.fs.lockDir(path, seconds_stale) end

--- Creates a new directory
---@param dirname string
---@return boolean|nil
---@return error
function hs.fs.mkdir(dirname) end

--- Gets the file path from a binary encoded bookmark.
---
--- Note: A bookmark provides a persistent reference to a file-system resource.
--- When you resolve a bookmark, you obtain a URL to the resource’s current location.
--- A bookmark’s association with a file-system resource (typically a file or folder)
--- usually continues to work if the user moves or renames the resource, or if the
--- user relaunches your app or restarts the system.
--- No volumes are mounted during the resolution of the bookmark data.
---@param data any
---@return string|nil
---@return string
function hs.fs.pathFromBookmark(data) end

--- Gets the absolute path of a given path
---@param filepath string
---@return string
function hs.fs.pathToAbsolute(filepath) end

--- Returns the path as binary encoded bookmark data.
---@param path string
---@return string|nil
function hs.fs.pathToBookmark(path) end

--- Removes an existing directory
---@param dirname string
---@return boolean|nil
---@return error
function hs.fs.rmdir(dirname) end

--- Set the Finder comments for the file or directory at the specified path to the comment specified
---
--- Note: This function uses hs.osascript to access the file comments through AppleScript
---@param path string
---@param comment string
---@return boolean
function hs.fs.setFinderComments(path, comment) end

--- Gets the attributes of a symbolic link
---
--- Note: The return values for this function are identical to those provided by hs.fs.attributes() with the following
--- addition: the attribute name "target" is added and specifies a string containing the absolute path that the symlink
--- points to.
---@param filepath string
---@param aname? string
---@return table|string|nil
---@return error
function hs.fs.symlinkAttributes(filepath, aname) end

--- Adds one or more tags to the Finder tags of a file
---@param filepath string
---@param tags table
---@return any
function hs.fs.tagsAdd(filepath, tags) end

--- Gets the Finder tags of a file
---@param filepath string
---@return table|nil
function hs.fs.tagsGet(filepath) end

--- Removes Finder tags from a file
---@param filepath string
---@param tags table
---@return any
function hs.fs.tagsRemove(filepath, tags) end

--- Sets the Finder tags of a file, removing any that are already set
---@param filepath string
---@param tags table
---@return any
function hs.fs.tagsSet(filepath, tags) end

--- Returns the path of the temporary directory for the current user.
---@return string
function hs.fs.temporaryDirectory() end

--- Updates the access and modification times of a file
---@param filepath string
---@param atime? number|nil
---@param mtime? number|nil
---@return boolean|nil
---@return error
function hs.fs.touch(filepath, atime, mtime) end

--- Unlocks a file or a part of it.
---@param filehandle any
---@param start? number|nil
---@param length? number|nil
---@return boolean|nil
---@return error
function hs.fs.unlock(filehandle, start, length) end

--- Returns the encoded URL from a path.
---@param path string
---@return string|nil
function hs.fs.urlFromPath(path) end

-- ------------------------------------------------------------
-- hs.fs.volume
-- ------------------------------------------------------------

---@class hs.fs.volume
hs.fs.volume = {}

---@class volume
local volume = {}

---@class hs.fs.volume.volume
---@field didMount any A volume was mounted
---@field didRename any A volume changed either its name or mountpoint (or more likely, both)
---@field didUnmount any A volume was unmounted
---@field willUnmount any A volume is about to be unmounted

--- A volume was mounted
---@type any
hs.fs.volume.didMount = nil

--- A volume changed either its name or mountpoint (or more likely, both)
---@type any
hs.fs.volume.didRename = nil

--- A volume was unmounted
---@type any
hs.fs.volume.didUnmount = nil

--- A volume is about to be unmounted
---@type any
hs.fs.volume.willUnmount = nil

--- Returns a table of information about disk volumes attached to the system
---
--- Note: This is an alias for hs.host.volumeInformation()
--- The possible keys in the table are:
--- NSURLVolumeTotalCapacityKey - Size of the volume in bytes
--- NSURLVolumeAvailableCapacityKey - Available space on the volume in bytes
--- NSURLVolumeIsAutomountedKey - Boolean indicating if the volume was automounted
--- NSURLVolumeIsBrowsableKey - Boolean indicating if the volume can be browsed
--- NSURLVolumeIsEjectableKey - Boolean indicating if the volume should be ejected before its media is removed
--- NSURLVolumeIsInternalKey - Boolean indicating if the volume is an internal drive or an external drive
--- NSURLVolumeIsLocalKey - Boolean indicating if the volume is a local or remote drive
--- NSURLVolumeIsReadOnlyKey - Boolean indicating if the volume is read only
--- NSURLVolumeIsRemovableKey - Boolean indicating if the volume's media can be physically ejected from the drive (e.g.
--- a DVD)
--- NSURLVolumeMaximumFileSizeKey - Maximum file size the volume can support, in bytes
--- NSURLVolumeUUIDStringKey - The UUID of volume's filesystem
--- NSURLVolumeURLForRemountingKey - For remote volumes, the network URL of the volume
--- NSURLVolumeLocalizedNameKey - Localized version of the volume's name
--- NSURLVolumeNameKey - The volume's name
--- NSURLVolumeLocalizedFormatDescriptionKey - Localized description of the volume
--- Not all keys will be present for all volumes
--- The meanings of NSURLVolumeIsEjectableKey and NSURLVolumeIsRemovableKey are not generally useful for determining if
--- a drive is removable in the modern sense (e.g. a USB drive) as much of this terminology dates back to when USB
--- didn't exist and removable drives were things like Floppy/DVD drives. If you're trying to determine if a drive is
--- not fixed into the computer, you may need to use a combination of these keys, but which exact combination you
--- should use, is not consistent across macOS versions.
---@param showHidden boolean|nil
---@return table
function hs.fs.volume.allVolumes(showHidden) end

--- Unmounts and ejects a volume
---@param path string
---@return boolean
---@return string
function hs.fs.volume.eject(path) end

--- Creates a watcher object for volume events
---@param fn function
---@return watcher
function hs.fs.volume.new(fn) end

--- Starts the volume watcher
---@return hs.fs.volume
function volume:start() end

--- Stops the volume watcher
---@return hs.fs.volume
function volume:stop() end

-- ------------------------------------------------------------
-- hs.fs.xattr
-- ------------------------------------------------------------

---@class hs.fs.xattr
hs.fs.xattr = {}

--- Set the extended attribute to the value provided for the path specified.
---
--- Note: See also hs.fs.xattr.getHumanReadable .
---@param path string
---@param attribute string
---@param options table|nil
---@param position number|nil
---@return string|boolean|nil
function hs.fs.xattr.get(path, attribute, options, position) end

--- A wrapper to
--- hs.fs.xattr.get
--- which returns non UTF-8 data as a hexadecimal dump provided by
--- hs.utf8.hexDump
--- .
---
--- Note: This is provided for testing and debugging purposes; in general you probably want hs.fs.xattr.get once you
--- know how to properly understand the data returned for the attribute.
--- This is similar to the long format option in the command line xattr command.
---@param path string
---@param attribute string
---@param options table|nil
---@param position number|nil
---@return string|boolean|nil
function hs.fs.xattr.getHumanReadable(path, attribute, options, position) end

--- Returns a list of the extended attributes currently defined for the specified file or directory
---@param path string
---@param options table|nil
---@return table
function hs.fs.xattr.list(path, options) end

--- Removes the specified extended attribute from the file or directory at the path specified.
---@param path string
---@param attribute string
---@param options table|nil
---@return boolean
function hs.fs.xattr.remove(path, attribute, options) end

--- Set the extended attribute to the value provided for the path specified.
---@param path string
---@param attribute string
---@param value string
---@param options table|nil
---@param position number|nil
---@return boolean
function hs.fs.xattr.set(path, attribute, value, options, position) end

-- ------------------------------------------------------------
-- hs.geometry
-- ------------------------------------------------------------

---@class hs.geometry
---@field area number A number representing the area of this rect or size; changing it will scale the rect/size - see hs.geometry:scale()
---@field aspect number A number representing the aspect ratio of this rect or size; changing it will reshape the rect/size, keeping its area...
---@field bottomright any Alias for x2y2
---@field center any A point representing the geometric center of this rect or the midpoint of this vector2; changing it will move the...
---@field h any The height of this rect or size; changing it will keep the rect's x,y corner constant
---@field length number A number representing the length of the diagonal of this rect, or the length of this vector2; changing it will scale...
---@field string hs.geometry The "X,Y/WxH" string for this hs.geometry object ( reduced precision ); useful e.g
---@field table hs.geometry The {x=X,y=Y,w=W,h=H} table for this hs.geometry object; useful e.g
---@field topleft any Alias for xy
---@field w any The width of this rect or size; changing it will keep the rect's x,y corner constant
---@field wh hs.geometry The size component for this hs.geometry object; setting this to a new size will keep the rect's x,y corner constant
---@field x any The x coordinate for this point or rect's corner; changing it will move the rect but keep the same width and height
---@field x1 any Alias for x
---@field x2 any The x coordinate for the second corner of this rect; changing it will affect the rect's width
---@field x2y2 hs.geometry The point denoting the other corner of this hs.geometry object; setting this to a new point will change the rect's...
---@field xy hs.geometry The point component for this hs.geometry object; setting this to a new point will move the rect but keep the same width...
---@field y any The y coordinate for this point or rect's corner; changing it will move the rect but keep the same width and height
---@field y1 any Alias for y
---@field y2 any The y coordinate for the second corner of this rect; changing it will affect the rect's height
hs.geometry = {}

---@class geometry
---@field area number A number representing the area of this rect or size; changing it will scale the rect/size - see hs.geometry:scale()
---@field length number A number representing the length of the diagonal of this rect, or the length of this vector2; changing it will scale...
---@field string hs.geometry The "X,Y/WxH" string for this hs.geometry object ( reduced precision ); useful e.g
---@field table hs.geometry The {x=X,y=Y,w=W,h=H} table for this hs.geometry object; useful e.g
---@field wh hs.geometry The size component for this hs.geometry object; setting this to a new size will keep the rect's x,y corner constant
---@field x2y2 hs.geometry The point denoting the other corner of this hs.geometry object; setting this to a new point will change the rect's...
---@field xy hs.geometry The point component for this hs.geometry object; setting this to a new point will move the rect but keep the same width...
local geometry = {}

--- Creates a copy of an hs.geometry object
---@param geom hs.geometry
---@return hs.geometry
function hs.geometry.copy(geom) end

--- Creates a new hs.geometry object
---@param ... any
---@return hs.geometry
function hs.geometry.new(...) end

--- Convenience function for creating a point object
---@param x number
---@param y number
---@return hs.geometry point
function hs.geometry.point(x, y) end

--- Convenience function for creating a rect-table
---@param x number
---@param y number
---@param w number
---@param h number
---@return hs.geometry rect
function hs.geometry.rect(x, y, w, h) end

--- Convenience function for creating a size object
---@param w number
---@param h number
---@return hs.geometry size
function hs.geometry.size(w, h) end

--- Returns the angle between the positive x axis and this vector2
---@return number
function geometry:angle() end

--- Returns the angle between the positive x axis and the vector connecting this point or rect's center to another
--- point or rect's center
---@param point hs.geometry
---@return number
function geometry:angleTo(point) end

--- Finds the distance between this point or rect's center and another point or rect's center
---@param point hs.geometry
---@return number
function geometry:distance(point) end

--- Checks if two geometry objects are equal
---@param other hs.geometry
---@return boolean
function geometry:equals(other) end

--- Ensure this rect is fully inside
--- bounds
--- , by scaling it down if it's larger (preserving its aspect ratio) and moving it if necessary
---@param bounds hs.geometry
---@return hs.geometry
function geometry:fit(bounds) end

--- Truncates all coordinates in this object to integers
---@return hs.geometry
function geometry:floor() end

--- Converts a unit rect within a given frame into a rect
---@param frame hs.geometry
---@return hs.geometry rect
function geometry:fromUnitRect(frame) end

--- Checks if this hs.geometry object lies fully inside a given rect
---@param rect hs.geometry
---@return boolean
function geometry:inside(rect) end

--- Returns the intersection rect between this rect and another rect
---
--- Note: If the two rects don't intersect, the result rect will be a "projection" of the second rect onto this rect's
--- closest edge or corner along the x or y axis; the w and/or h fields in the result rect will be 0.
---@param rect hs.geometry
---@return hs.geometry rect
function geometry:intersect(rect) end

--- Moves this point/rect
---@param point hs.geometry
---@return hs.geometry
function geometry:move(point) end

--- Normalizes this vector2
---@return point
function geometry:normalize() end

--- Rotates a point around another point N times
---@param aroundpoint hs.geometry
---@param ntimes number
---@return hs.geometry point
function geometry:rotateCCW(aroundpoint, ntimes) end

--- Scales this vector2/size, or this rect
--- keeping its center constant
---@param size hs.geometry
---@return hs.geometry
function geometry:scale(size) end

--- Converts a rect into its unit rect within a given frame
---
--- Note: The resulting unit rect is always clipped within frame 's bounds (via hs.geometry:intersect() ); if frame
--- does not encompass this rect no error will be thrown , but the resulting unit rect won't be a direct match with
--- this rect
--- (i.e. calling :fromUnitRect(frame) on it will return a different rect)
---@param frame hs.geometry
---@return hs.geometry unit rect
function geometry:toUnitRect(frame) end

--- Returns the type of an hs.geometry object
---@return string
function geometry:type() end

--- Returns the smallest rect that encloses both this rect and another rect
---@param rect hs.geometry
---@return hs.geometry rect
function geometry:union(rect) end

--- Returns the vector2 from this point or rect's center to another point or rect's center
---@param point hs.geometry
---@return point
function geometry:vector(point) end

-- ------------------------------------------------------------
-- hs.grid
-- ------------------------------------------------------------

---@class hs.grid
hs.grid = {}

--- A bidimensional array (table of tables of strings) holding the keyboard hints (as per
--- hs.keycodes.map
--- ) to be used for the interactive resizing interface.
---@type hs.keycodes.map
hs.grid.HINTS = nil

--- Allows customization of the modal resizing grid user interface
---@type any
hs.grid.ui = nil

--- Calls a user specified function to adjust a window's cell
---@param fn function
---@param window hs.window
---@return hs.grid
function hs.grid.adjustWindow(fn, window) end

--- Gets the cell describing a window
---@param win any
---@return cell
function hs.grid.get(win) end

--- Gets the
--- hs.geometry
--- rect for a cell on a particular screen
---@param cell hs.geometry
---@param screen hs.screen|hs.screen.find
---@return hs.geometry
function hs.grid.getCell(cell, screen) end

--- Gets the defined grid size for a given screen or screen resolution
---
--- Note: if a grid was not set for the specified screen or geometry, the default grid will be returned
--- Usage:
--- local mygrid = hs.grid.getGrid('1920x1080') -- gets the defined grid for all screens with a 1920x1080 resolution
--- local defgrid=hs.grid.getGrid() defgrid.w=defgrid.w+2 -- increases the number of columns in the default grid by 2
---@param screen hs.screen|hs.screen.find|nil
---@return hs.geometry size
function hs.grid.getGrid(screen) end

--- Gets the defined grid frame for a given screen or screen resolution.
---@param screen hs.screen|hs.screen.find
---@return hs.geometry rect
function hs.grid.getGridFrame(screen) end

--- Hides the grid, if visible, and exits the modal resizing mode.
---
--- Note: Call this function if you need to make sure the modal is exited without waiting for the user to press esc .
--- If an exit callback was provided when invoking the modal interface, calling .hide() will call it
---@return any
function hs.grid.hide() end

--- Moves and resizes a window to fill the entire grid
---@param window hs.window
---@return hs.grid
function hs.grid.maximizeWindow(window) end

--- Moves a window one grid cell down the screen, or onto the adjacent screen's grid when necessary
---@param window hs.window
---@return hs.grid
function hs.grid.pushWindowDown(window) end

--- Moves a window one grid cell to the left, or onto the adjacent screen's grid when necessary
---@param window hs.window
---@return hs.grid
function hs.grid.pushWindowLeft(window) end

--- Moves a window one cell to the right, or onto the adjacent screen's grid when necessary
---@param window hs.window
---@return hs.grid
function hs.grid.pushWindowRight(window) end

--- Moves a window one grid cell up the screen, or onto the adjacent screen's grid when necessary
---@param window hs.window
---@return hs.grid
function hs.grid.pushWindowUp(window) end

--- Resizes a window so its bottom edge moves one grid cell higher
---@param window hs.window
---@return hs.grid
function hs.grid.resizeWindowShorter(window) end

--- Resizes a window so its bottom edge moves one grid cell lower
---
--- Note: if the window hits the bottom edge of the screen and is asked to become taller, its top edge will shift
--- further up
---@param window hs.window
---@return hs.grid
function hs.grid.resizeWindowTaller(window) end

--- Resizes a window to be one cell thinner
---@param window hs.window
---@return hs.grid
function hs.grid.resizeWindowThinner(window) end

--- Resizes a window to be one cell wider
---
--- Note: if the window hits the right edge of the screen and is asked to become wider, its left edge will shift
--- further left
---@param window hs.window
---@return hs.grid
function hs.grid.resizeWindowWider(window) end

--- Sets the cell for a window on a particular screen
---@param win hs.window
---@param cell hs.geometry
---@param screen hs.screen|hs.screen.find|nil
---@return hs.grid
function hs.grid.set(win, cell, screen) end

--- Sets the grid size for a given screen or screen resolution
---@param grid hs.geometry
---@param screen hs.screen|hs.screen.find|nil
---@param frame hs.geometry|nil
---@return hs.grid
function hs.grid.setGrid(grid, screen, frame) end

--- Sets the margins between windows
---@param margins hs.geometry
---@return hs.grid
function hs.grid.setMargins(margins) end

--- Shows the grid and starts the modal interactive resizing process for the focused or frontmost window.
---
--- Note: In most cases this function should be invoked via hs.hotkey.bind with some keyboard shortcut.
--- In the modal interface, press the arrow keys to jump to adjacent screens; spacebar to maximize/unmaximize; esc to
--- quit without any effect
--- Pressing tab or shift-tab in the modal interface will cycle to the next or previous window; if multipleWindows is
--- false or omitted, the first press will just enable the multiple windows behaviour
--- The keyboard hints assume a QWERTY layout; if you use a different layout, change hs.grid.HINTS accordingly
--- If grid dimensions are greater than 10x10 then you may have to change hs.grid.HINTS depending on your
--- requirements. See note in HINTS .
---@param exitedCallback function|nil
---@param multipleWindows? any
---@return any
function hs.grid.show(exitedCallback, multipleWindows) end

--- Snaps a window into alignment with the nearest grid lines
---@param win hs.window
---@return hs.grid
function hs.grid.snap(win) end

--- Toggles the grid and modal resizing mode - see
--- hs.grid.show()
--- and
--- hs.grid.hide()
---@param exitedCallback function|nil
---@param multipleWindows? any
---@return any
function hs.grid.toggleShow(exitedCallback, multipleWindows) end

-- ------------------------------------------------------------
-- hs.hash
-- ------------------------------------------------------------

---@class hs.hash
hs.hash = {}

---@class hash
local hash = {}

--- Calculates a binary MD5 hash
---
--- Note: this function is provided for backwards compatibility with a previous version of this module and is
--- functionally equivalent to: hs.hash.new("MD5"):append(data):finish():value(true)
---@param data any
---@return data
function hs.hash.bMD5(data) end

--- Calculates a binary SHA1 hash
---
--- Note: this function is provided for backwards compatibility with a previous version of this module and is
--- functionally equivalent to: hs.hash.new("SHA1"):append(data):finish():value(true)
---@param data any
---@return data
function hs.hash.bSHA1(data) end

--- Calculates a binary SHA256 hash
---
--- Note: this function is provided for backwards compatibility with a previous version of this module and is
--- functionally equivalent to: hs.hash.new("SHA256"):append(data):finish():value(true)
---@param data any
---@return data
function hs.hash.bSHA256(data) end

--- Calculates a binary SHA512 hash
---
--- Note: this function is provided for backwards compatibility with a previous version of this module and is
--- functionally equivalent to: hs.hash.new("SHA512"):append(data):finish():value(true)
---@param data any
---@return data
function hs.hash.bSHA512(data) end

--- Calculates an HMAC using a key and an MD5 hash
---
--- Note: this function is provided for backwards compatibility with a previous version of this module and is
--- functionally equivalent to: hs.hash.new("hmacMD5", key):append(data):finish():value()
---@param key string
---@param data any
---@return string
function hs.hash.hmacMD5(key, data) end

--- Calculates an HMAC using a key and a SHA1 hash
---
--- Note: this function is provided for backwards compatibility with a previous version of this module and is
--- functionally equivalent to: hs.hash.new("hmacSHA1", key):append(data):finish():value()
---@param key string
---@param data any
---@return string
function hs.hash.hmacSHA1(key, data) end

--- Calculates an HMAC using a key and a SHA256 hash
---
--- Note: this function is provided for backwards compatibility with a previous version of this module and is
--- functionally equivalent to: hs.hash.new("hmacSHA256", key):append(data):finish():value()
---@param key string
---@param data any
---@return string
function hs.hash.hmacSHA256(key, data) end

--- Calculates an HMAC using a key and a SHA512 hash
---
--- Note: this function is provided for backwards compatibility with a previous version of this module and is
--- functionally equivalent to: hs.hash.new("hmacSHA512", key):append(data):finish():value()
---@param key string
---@param data any
---@return string
function hs.hash.hmacSHA512(key, data) end

--- Calculates an MD5 hash
---
--- Note: this function is provided for backwards compatibility with a previous version of this module and is
--- functionally equivalent to: hs.hash.new("MD5"):append(data):finish():value()
---@param data any
---@return string
function hs.hash.MD5(data) end

--- Calculates an SHA1 hash
---
--- Note: this function is provided for backwards compatibility with a previous version of this module and is
--- functionally equivalent to: hs.hash.new("SHA1"):append(data):finish():value()
---@param data any
---@return string
function hs.hash.SHA1(data) end

--- Calculates an SHA256 hash
---
--- Note: this function is provided for backwards compatibility with a previous version of this module and is
--- functionally equivalent to: hs.hash.new("SHA256"):append(data):finish():value()
---@param data any
---@return string
function hs.hash.SHA256(data) end

--- Calculates an SHA512 hash
---
--- Note: this function is provided for backwards compatibility with a previous version of this module and is
--- functionally equivalent to: hs.hash.new("SHA512"):append(data):finish():value()
---@param data any
---@return string
function hs.hash.SHA512(data) end

--- A tale containing the names of the hashing algorithms supported by this module.
---@type any
hs.hash.types = nil

--- Converts a string containing a binary hash value to its equivalent hexadecimal digits.
---
--- Note: this is a convenience function for use when you already have a binary hash value that you wish to convert to
--- its hexadecimal equivalent -- the value is not actually validated as the actual hash value for anything specific.
---@param input string
---@return string
function hs.hash.convertBinaryHashToHex(input) end

--- Converts a string containing a hash value as a string of hexadecimal digits into its binary equivalent.
---
--- Note: this is a convenience function for use when you already have a hash value that you wish to convert to its
--- binary equivalent. Beyond checking that the input string contains only hexadecimal digits and is an even length,
--- the value is not actually validated as the actual hash value for anything specific.
---@param input string
---@return string
function hs.hash.convertHexHashToBinary(input) end

--- Calculates the specified hash value for the file at the given path.
---
--- Note: this is a convenience function that performs the equivalent of hs.new.hash(hash,
--- [secret]):appendFile(path):finish():value() .
---@param hash hs.hash.types
---@param secret any
---@param path string
---@return string
function hs.hash.forFile(hash, secret, path) end

--- Creates a new context for the specified hash function.
---@param hash string
---@param secret any
---@return hashObject
function hs.hash.new(hash, secret) end

--- Adds the provided data to the input of the hash function currently in progress for the hashObject.
---@param data string
---@return hashObject|nil
---@return error
function hash:append(data) end

--- Adds the contents of the file at the specified path to the input of the hash function currently in progress for the
--- hashObject.
---@param path string
---@return hashObject|nil
---@return error
function hash:appendFile(path) end

--- Finalizes the hash and computes the resulting value.
---
--- Note: a hash that has been finished can no longer have data appended to it.
---@return hashObject
function hash:finish() end

--- Returns the name of the hash type the object refers to
---@return string
function hash:type() end

--- Returns the value of a completed hash, or nil if it is still in progress.
---@param binary number
---@return string|nil
function hash:value(binary) end

-- ------------------------------------------------------------
-- hs.hid
-- ------------------------------------------------------------

---@class hs.hid
hs.hid = {}

--- Checks the state of the caps lock via HID
---@return boolean
function hs.hid.capslock.get() end

--- Assigns capslock to the desired state
---@param state boolean
---@return boolean
function hs.hid.capslock.set(state) end

--- Toggles the state of caps lock via HID
---@return boolean
function hs.hid.capslock.toggle() end

-- ------------------------------------------------------------
-- hs.hid.led
-- ------------------------------------------------------------

---@class hs.hid.led
hs.hid.led = {}

--- Assigns HID LED to the desired state
---
--- Note: This function controls the LED state only, to modify capslock state, use hs.hid.capslock.set
---@param name string
---@param state boolean
---@return boolean
function hs.hid.led.set(name, state) end

-- ------------------------------------------------------------
-- hs.hints
-- ------------------------------------------------------------

---@class hs.hints
hs.hints = {}

--- A fully specified family-face name, preferably the PostScript name, such as Helvetica-BoldOblique or Times-Roman.
--- (The Font Book app displays PostScript names of fonts in the Font Info panel.)
---@type any
hs.hints.fontName = nil

--- The size of font that should be used. A value of 0.0 will use the default size.
---@type any
hs.hints.fontSize = nil

--- This controls the set of characters that will be used for window hints. They must be characters found in
--- hs.keycodes.map
---@type hs.keycodes.map
hs.hints.hintChars = nil

--- Opacity of the application icon. Default is 0.95.
---@type any
hs.hints.iconAlpha = nil

--- If there are less than or equal to this many windows on screen their titles will be shown in the hints.
---@type any
hs.hints.showTitleThresh = nil

--- If this is set to "vimperator", every window hint starts with the first character
---@type any
hs.hints.style = nil

--- If the title is longer than maxSize, the string is truncated, -1 to disable, valid value is >= 6
---@type string
hs.hints.titleMaxSize = nil

--- Displays a keyboard hint for switching focus to each window
---
--- Note: If there are more windows open than there are characters available in hs.hints.hintChars, multiple characters
--- will be used
--- If hints.style is set to "vimperator", every window hint is prefixed with the first character of the parent
--- application's name
--- To display hints only for the currently focused application, try something like:
--- hs.hints.windowHints(hs.window.focusedWindow():application():allWindows())
---@param windows hs.window|nil
---@param callback hs.window|nil
---@param allowNonStandard boolean|nil
---@return any
function hs.hints.windowHints(windows, callback, allowNonStandard) end

-- ------------------------------------------------------------
-- hs.host
-- ------------------------------------------------------------

---@class hs.host
hs.host = {}

--- Gets a list of network addresses for the current machine
---
--- Note: The results will include IPv4 and IPv6 addresses
---@return table
function hs.host.addresses() end

--- Query CPU usage statistics for a given time interval using
--- hs.host.cpuUsageTicks
--- and return the results as percentages.
---
--- Note: If no callback function is provided, Hammerspoon will block (i.e. no other Hammerspoon activity can occur)
--- during execution of this function for period microseconds (1 second = 1,000,000 microseconds).  The default period
--- is 1/10 of a second. If period is too small, it is possible that some of the CPU statistics may result in nan
--- (not-a-number).
--- For reference, the top command has a default period between samples of 1 second.
--- The subtables for each core and overall have a __tostring() metamethod which allows listing it's contents in the
--- Hammerspoon console by typing hs.host.cpuUsage()[#] where # is the core you are interested in or the string
--- "overall".
---@param period any
---@param callback function|nil
---@return table
function hs.host.cpuUsage(period, callback) end

--- Returns a table containing the current cpu usage information for the system in
--- ticks
--- since the most recent system boot.
---
--- Note: CPU mode ticks are updated during system interrupts and are incremented based upon the mode the CPU is in at
--- the time of the interrupt. By its nature, this is always going to be approximate, and a single call to this
--- function will return the current tick values since the system was last rebooted.
--- To generate a snapshot of the system's usage "at this moment", you must take two samples and calculate the
--- difference between them.  The hs.host.cpuUsage function is a wrapper which does this for you and returns the cpu
--- usage statistics as a percentage of the total number of ticks which occurred during the sample period you specify
--- when invoking hs.host.cpuUsage .
--- Historically on Unix based systems, the nice cpu state represents processes for which the execution priority has
--- been reduced to allow other higher priority processes access to more system resources.  The source code for the
--- version of the XNU Kernel currently provided by Apple (for macOS 10.12.3) shows this value as returned by the
--- host_processor_info as hardcoded to 0.  For completeness, this value is included in the statistics returned by this
--- function, but unless Apple makes a change in the future, it is not expected to provide any useful information.
--- Adapted primarily from code found at http://stackoverflow.com/questions/6785069/get-cpu-percent-usage
---@return table
function hs.host.cpuUsageTicks() end

--- Returns a newly generated global unique identifier as a string
---
--- Note: See also hs.host.uuid
--- The global unique identifier for a process includes the host name, process ID, and a time stamp, which ensures that
--- the ID is unique for the network. This property generates a new string each time it is invoked, and it uses a
--- counter to guarantee that strings are unique.
--- This is often used as a file or directory name in conjunction with hs.host.temporaryDirectory() when creating
--- temporary files.
---@return string
function hs.host.globallyUniqueString() end

--- Returns the model and VRAM size for the installed GPUs.
---
--- Note: If your GPU reports -1.0 as the memory size, please submit an issue to the Hammerspoon github repository and
--- include any information that you can which may be relevant, such as: Macintosh model, macOS version, is the GPU
--- built in or a third party expansion card, the GPU model and VRAM as best you can determine (see the System
--- Information application in the Utilities folder and look at the Graphics/Display section) and anything else that
--- you think might be important.
---@return table
function hs.host.gpuVRAM() end

--- Returns the number of seconds the computer has been idle.
---
--- Note: Idle time is defined as no mouse move nor keyboard entry, etc. and is determined by querying the HID (Human
--- Interface Device) subsystem.
--- This code is directly inspired by code found at http://www.xs-labs.com/en/archives/articles/iokit-idle-time
---@return seconds
function hs.host.idleTime() end

--- Returns the OS X interface style for the current user.
---
--- Note: As of OS X 10.10.4, other than the default style, only "Dark" is recognized as a valid style.
---@return string
function hs.host.interfaceStyle() end

--- Gets the name of the current machine, as displayed in the Finder sidebar
---@return string
function hs.host.localizedName() end

--- Gets a list of network names for the current machine
---
--- Note: This function should be used sparingly, as it may involve blocking network access to resolve hostnames
---@return table
function hs.host.names() end

--- The operating system version as a table containing the major, minor, and patch numbers.
---
--- Note: for OS X versions prior to 10.10, the version number is approximately determined by evaluating the
--- AppKitVersionNumber.  For these operating systems, the approximate key is defined and set to true, as the exact
--- patch level cannot be definitively determined.
--- for OS X Versions starting at 10.10 and going forward, an exact value for the version number can be determined with
--- NSProcessingInfo's operatingSystemVersion selector and the exact key is defined and set to true if this method is
--- used.
---@return table
function hs.host.operatingSystemVersion() end

--- The operating system version as a human readable string.
---
--- Note: According to the OS X Developer documentation, "The operating system version string is human readable,
--- localized, and is appropriate for displaying to the user. This string is not appropriate for parsing."
---@return string
function hs.host.operatingSystemVersionString() end

--- The current thermal state of the computer, as a human readable string
---@return string
function hs.host.thermalState() end

--- Returns a newly generated UUID as a string
---
--- Note: See also hs.host.globallyUniqueString
--- UUIDs (Universally Unique Identifiers), also known as GUIDs (Globally Unique Identifiers) or IIDs (Interface
--- Identifiers), are 128-bit values. UUIDs created by NSUUID conform to RFC 4122 version 4 and are created with random
--- bytes.
---@return string
function hs.host.uuid() end

--- Returns a table containing virtual memory statistics for the current machine, as well as the page size (in bytes)
--- and physical memory size (in bytes).
---
--- Note: The table returned has a __tostring() metamethod which allows listing it's contents in the Hammerspoon
--- console by typing hs.host.vmStats() .
--- Except for the addition of cacheHits, cacheLookups, pageSize and memSize, the results for this function should be
--- identical to the OS X command vm_stat .
--- Adapted primarily from the source code to Apple's vm_stat command located at
--- http://www.opensource.apple.com/source/system_cmds/system_cmds-643.1.1/vm_stat.tproj/vm_stat.c
---@return table
function hs.host.vmStat() end

--- Returns a table of information about disk volumes attached to the system
---
--- Note: The possible keys in the table are:
--- NSURLVolumeTotalCapacityKey - Size of the volume in bytes
--- NSURLVolumeAvailableCapacityKey - Available space on the volume in bytes
--- NSURLVolumeIsAutomountedKey - Boolean indicating if the volume was automounted
--- NSURLVolumeIsBrowsableKey - Boolean indicating if the volume can be browsed
--- NSURLVolumeIsEjectableKey - Boolean indicating if the volume should be ejected before its media is removed
--- NSURLVolumeIsInternalKey - Boolean indicating if the volume is an internal drive or an external drive
--- NSURLVolumeIsLocalKey - Boolean indicating if the volume is a local or remote drive
--- NSURLVolumeIsReadOnlyKey - Boolean indicating if the volume is read only
--- NSURLVolumeIsRemovableKey - Boolean indicating if the volume's media can be physically ejected from the drive (e.g.
--- a DVD)
--- NSURLVolumeMaximumFileSizeKey - Maximum file size the volume can support, in bytes
--- NSURLVolumeUUIDStringKey - The UUID of volume's filesystem
--- NSURLVolumeURLForRemountingKey - For remote volumes, the network URL of the volume
--- NSURLVolumeLocalizedNameKey - Localized version of the volume's name
--- NSURLVolumeNameKey - The volume's name
--- NSURLVolumeLocalizedFormatDescriptionKey - Localized description of the volume
--- Not all keys will be present for all volumes
--- The meanings of NSURLVolumeIsEjectableKey and NSURLVolumeIsRemovableKey are not generally useful for determining if
--- a drive is removable in the modern sense (e.g. a USB drive) as much of this terminology dates back to when USB
--- didn't exist and removable drives were things like Floppy/DVD drives. If you're trying to determine if a drive is
--- not fixed into the computer, you may need to use a combination of these keys, but which exact combination you
--- should use, is not consistent across macOS versions.
---@param showHidden boolean|nil
---@return table
function hs.host.volumeInformation(showHidden) end

-- ------------------------------------------------------------
-- hs.host.locale
-- ------------------------------------------------------------

---@class hs.host.locale
hs.host.locale = {}

--- Returns an array table containing the identifiers for the locales available on the system.
---
--- Note: these values can be used with hs.host.locale.details to get details for a specific locale.
---@return table
function hs.host.locale.availableLocales() end

--- Returns an string specifying the user's currently selected locale identifier.
---
--- Note: this value can be used with hs.host.locale.details to get details for the returned locale.
---@return string
function hs.host.locale.current() end

--- Returns a table containing information about the current or specified locale.
---
--- Note: If you specify a locale identifier as an argument, it should be based on one of the strings returned by
--- hs.host.locale.availableLocales . Use of an arbitrary string may produce unreliable or inconsistent results.
--- temperatureUnit - http://stackoverflow.com/a/41263725
--- timeFormatIs24Hour - http://stackoverflow.com/a/1972487
--- If you are able to identify additional locale or regional settings that are not provided by this function and have
--- a source which describes a reliable method to retrieve this information, please submit an issue at
--- https://github.com/Hammerspoon/hammerspoon with the details.
---@param identifier string|nil
---@return table
function hs.host.locale.details(identifier) end

--- Returns the localized string for a specific language code.
---
--- Note: The localeCode and optional baseLocaleCode must be one of the strings returned by
--- hs.host.locale.availableLocales .
---@param localeCode string
---@param baseLocaleCode? string|nil
---@return string|nil
---@return string|nil
function hs.host.locale.localizedString(localeCode, baseLocaleCode) end

--- Returns the user's language preference order as an array of strings.
---@return table
function hs.host.locale.preferredLanguages() end

--- Registers a function to be invoked when anything in the user's locale settings change
---
--- Note: The callback function will not receive any arguments and should return none.  You can retrieve the new locale
--- settings with hs.host.locale.localeInformation and check its keys to determine if the change is of interest.
--- Any change made within the Language and Region settings panel will trigger this callback, even changes which are
--- not reflected in the locale information provided by hs.host.locale.localeInformation .
---@param function any
---@return uuidString
function hs.host.locale.registerCallback(function) end

--- Unregister a callback function when you no longer care about changes to the user's locale
---@param uuidString hs.host.locale.registerCallback
---@return boolean
function hs.host.locale.unregisterCallback(uuidString) end

-- ------------------------------------------------------------
-- hs.hotkey
-- ------------------------------------------------------------

---@class hs.hotkey
hs.hotkey = {}

---@class hotkey
local hotkey = {}

--- Duration of the alert shown when a hotkey created with a
--- message
--- parameter is triggered, in seconds. Default is 1.
---@type any
hs.hotkey.alertDuration = nil

--- Determines whether the hotkey combination can be assigned a callback through Hammerspoon.
---
--- Note: The most common reason a hotkey combination cannot be given an assignment by Hammerspoon is because it is in
--- use by the Mac operating system -- see the Shortcuts tab of Keyboard in the System Preferences application or
--- hs.hotkey.systemAssigned .
---@param mods any
---@param key string
---@return boolean
function hs.hotkey.assignable(mods, key) end

--- Deletes all previously set callbacks for a given keyboard combination
---@param mods any
---@param key string
---@return any
function hs.hotkey.deleteAll(mods, key) end

--- Disables all previously set callbacks for a given keyboard combination
---@param mods any
---@param key string
---@return any
function hs.hotkey.disableAll(mods, key) end

--- Returns a list of all currently active hotkeys
---@return table
function hs.hotkey.getHotkeys() end

--- Creates (and enables) a hotkey that shows all currently active hotkeys (i.e. enabled and not "shadowed" in the
--- current context) while pressed
---@param mods any
---@param key string
---@return hs.hotkey
function hs.hotkey.showHotkeys(mods, key) end

--- Examine whether a potential hotkey is in use by the macOS system such as the Screen Capture, Universal Access, and
--- Keyboard Navigation keys.
---
--- Note: this is provided for informational purposes and does not provide a reliable test as to whether or not
--- Hammerspoon can use the combination to create a custom hotkey -- some combinations which return a table can be
--- over-ridden by Hammerspoon while others cannot.  See also hs.hotkey.assignable .
---@param mods any
---@param key string
---@return table|boolean
function hs.hotkey.systemAssigned(mods, key) end

--- Creates a new hotkey and enables it immediately
---
--- Note: This function is just a wrapper that performs hs.hotkey.new(...):enable()
--- You can create multiple hs.hotkey objects for the same keyboard combination, but only one can be active
--- at any given time - see hs.hotkey:enable()
--- If message is the empty string "" , the alert will just show the triggered keyboard combination
--- If you don't want any alert, you must actually omit the message parameter; a nil in 3rd position
--- will be interpreted as a missing pressedfn
--- You must pass at least one of pressedfn , releasedfn or repeatfn ; to delete a hotkey, use hs.hotkey:delete()
---@param mods any
---@param key string
---@param message hs.alert|nil
---@param pressedfn function|nil
---@param releasedfn function|nil
---@param repeatfn function|nil
---@return hs.hotkey
function hs.hotkey.bind(mods, key, message, pressedfn, releasedfn, repeatfn) end

--- Creates a hotkey and enables it immediately
---
--- Note: This function is just a wrapper that performs hs.hotkey.bind(keyspec[1], keyspec[2], ...)
---@param keyspec any
---@param ... any
---@return hs.hotkey
function hs.hotkey.bindSpec(keyspec, ...) end

--- Creates a new hotkey
---
--- Note: You can create multiple hs.hotkey objects for the same keyboard combination, but only one can be active
--- at any given time - see hs.hotkey:enable()
--- If message is the empty string "" , the alert will just show the triggered keyboard combination
--- If you don't want any alert, you must actually omit the message parameter; a nil in 3rd position
--- will be interpreted as a missing pressedfn
--- You must pass at least one of pressedfn , releasedfn or repeatfn ; to delete a hotkey, use hs.hotkey:delete()
---@param mods any
---@param key string
---@param message hs.alert|nil
---@param pressedfn function|nil
---@param releasedfn function|nil
---@param repeatfn function|nil
---@return hs.hotkey
function hs.hotkey.new(mods, key, message, pressedfn, releasedfn, repeatfn) end

--- Disables and deletes a hotkey object
---@return any
function hotkey:delete() end

--- Disables a hotkey object
---@return hs.hotkey
function hotkey:disable() end

--- Enables a hotkey object
---
--- Note: When you enable a hotkey that uses the same keyboard combination as another previously-enabled hotkey, the old
--- one will stop working as it's being "shadowed" by the new one. As soon as the new hotkey is disabled or deleted
--- the old one will trigger again.
---@return hs.hotkey|nil
function hotkey:enable() end

--- Gets the log level of the hotkey logger instance
---@return number
function hs.hotkey.getLogLevel() end

--- Sets the log level of the hotkey logger instance
---@param loglevel number
---@return any
function hs.hotkey.setLogLevel(loglevel) end

-- ------------------------------------------------------------
-- hs.hotkey.modal
-- ------------------------------------------------------------

---@class hs.hotkey.modal
hs.hotkey.modal = {}

---@class modal
local modal = {}

--- Creates a new modal state, optionally with a global keyboard combination to trigger it
---
--- Note: If key is nil, no global hotkey will be registered (all other parameters will be ignored)
---@param mods any
---@param key string
---@param message string|nil
---@return hs.hotkey.modal
function hs.hotkey.modal.new(mods, key, message) end

--- Creates a hotkey that is enabled/disabled as the modal is entered/exited
---@param mods any
---@param key string
---@param message string|nil
---@param pressedfn function|nil
---@param releasedfn function|nil
---@param repeatfn function|nil
---@return hs.hotkey.modal
function modal:bind(mods, key, message, pressedfn, releasedfn, repeatfn) end

--- Deletes a modal hotkey object without calling :exited()
---@return any
function modal:delete() end

--- Enters a modal state
---
--- Note: This method will enable all of the hotkeys defined in the modal state via hs.hotkey.modal:bind() ,
--- and disable the hotkey that entered the modal state (if one was defined)
--- If the modal state was created with a keyboard combination, this method will be called automatically
---@return hs.hotkey.modal
function modal:enter() end

--- Optional callback for when a modal is entered
---
--- Note: This is a preexisting function that you should override if you need to use it; the default implementation
--- does nothing.
---@return any
function modal:entered() end

--- Exits a modal state
---
--- Note: This method will disable all of the hotkeys defined in the modal state, and enable the hotkey for entering
--- the modal state (if one was defined)
---@return hs.hotkey.modal
function modal:exit() end

--- Optional callback for when a modal is exited
---
--- Note: This is a preexisting function that you should override if you need to use it; the default implementation
--- does nothing.
---@return any
function modal:exited() end

-- ------------------------------------------------------------
-- hs.http
-- ------------------------------------------------------------

---@class hs.http
hs.http = {}

--- A collection of common HTML Entities (&whatever;) and their UTF8 equivalents.  To retrieve the UTF8 sequence for a
--- given entity, reference the table as
--- hs.http.htmlEntities["&key;"]
--- where
--- key
--- is the text of the entity's name or a numeric reference like
--- #number
--- .
---@type hs.http.htmlEntities
hs.http.htmlEntities[] = nil

--- Sends an HTTP GET request asynchronously
---
--- Note: If authentication is required in order to download the request, the required credentials must be specified as
--- part of the URL (e.g. "http://user:password@host.com/"). If authentication fails, or credentials are missing, the
--- connection will attempt to continue without credentials.
--- If the request fails, the callback function's first parameter will be negative and the second parameter will
--- contain an error message. The third parameter will be nil
---@param url string
---@param headers table|nil
---@param callback function
---@return any
function hs.http.asyncGet(url, headers, callback) end

--- Sends an HTTP POST request asynchronously
---
--- Note: If authentication is required in order to download the request, the required credentials must be specified as
--- part of the URL (e.g. "http://user:password@host.com/"). If authentication fails, or credentials are missing, the
--- connection will attempt to continue without credentials.
--- If the request fails, the callback function's first parameter will be negative and the second parameter will
--- contain an error message. The third parameter will be nil
---@param url string
---@param data string|nil
---@param headers table|nil
---@param callback function
---@return any
function hs.http.asyncPost(url, data, headers, callback) end

--- Sends an HTTP PUT request asynchronously
---
--- Note: If authentication is required in order to download the request, the required credentials must be specified as
--- part of the URL (e.g. "http://user:password@host.com/"). If authentication fails, or credentials are missing, the
--- connection will attempt to continue without credentials.
--- If the request fails, the callback function's first parameter will be negative and the second parameter will
--- contain an error message. The third parameter will be nil
---@param url string
---@param data string|nil
---@param headers table|nil
---@param callback function
---@return any
function hs.http.asyncPut(url, data, headers, callback) end

--- Convert all recognized HTML Entities in the
--- inString
--- to appropriate UTF8 byte sequences and returns the converted text.
---
--- Note: Recognized HTML Entities are those registered in hs.http.htmlEntities or numeric entity sequences: &#n; where
--- n can be any integer number.
--- This function is especially useful as a post-filter to data retrieved by the hs.http.get and hs.http.asyncGet
--- functions.
---@param inString string
---@return outString
function hs.http.convertHtmlEntities(inString) end

--- Creates an HTTP request and executes it asynchronously
---
--- Note: If authentication is required in order to download the request, the required credentials must be specified as
--- part of the URL (e.g. "http://user:password@host.com/"). If authentication fails, or credentials are missing, the
--- connection will attempt to continue without credentials.
--- If the Content-Type response header begins text/ then the response body return value is a UTF8 string. Any other
--- content type passes the response body, unaltered, as a stream of bytes.
--- If enableRedirect is set to true, response body will be empty string. Http body will be dropped even though
--- response has the body. This seems the limitation of 'connection:willSendRequest:redirectResponse' method.
---@param url string
---@param method string
---@param data string|nil
---@param headers table
---@param callback function
---@param cachePolicy|enableRedirect any
---@return any
function hs.http.doAsyncRequest(url, method, data, headers, callback, cachePolicy|enableRedirect) end

--- Creates an HTTP request and executes it synchronously
---
--- Note: If authentication is required in order to download the request, the required credentials must be specified as
--- part of the URL (e.g. "http://user:password@host.com/"). If authentication fails, or credentials are missing, the
--- connection will attempt to continue without credentials.
--- This function is synchronous and will therefore block all Lua execution until it completes. You are encouraged to
--- use the asynchronous functions.
--- If you attempt to connect to a local Hammerspoon server created with hs.httpserver , then Hammerspoon will block
--- until the connection times out (60 seconds), return a failed result due to the timeout, and then the hs.httpserver
--- callback function will be invoked (so any side effects of the function will occur, but it's results will be lost).
--- Use hs.http.doAsyncRequest to avoid this.
--- If the Content-Type response header begins text/ then the response body return value is a UTF8 string. Any other
--- content type passes the response body, unaltered, as a stream of bytes.
---@param url string
---@param method string
---@param data any
---@param headers string[]|nil
---@param cachePolicy string|nil
---@return int
---@return string
---@return table
function hs.http.doRequest(url, method, data, headers, cachePolicy) end

--- Returns a copy of the provided string in which characters that are not valid within an HTTP query key or value are
--- escaped with their %## equivalent.
---
--- Note: The intent of this function is to provide a valid key or a valid value for a query string, not to validate
--- the entire query string.  For this reason, ?, =, +, and & are included in the converted characters.
---@param string string
---@return string
function hs.http.encodeForQuery(string) end

--- Sends an HTTP GET request to a URL
---
--- Note: If authentication is required in order to download the request, the required credentials must be specified as
--- part of the URL (e.g. "http://user:password@host.com/"). If authentication fails, or credentials are missing, the
--- connection will attempt to continue without credentials.
--- This function is synchronous and will therefore block all other Lua execution while the request is in progress, you
--- are encouraged to use the asynchronous functions
--- If you attempt to connect to a local Hammerspoon server created with hs.httpserver , then Hammerspoon will block
--- until the connection times out (60 seconds), return a failed result due to the timeout, and then the hs.httpserver
--- callback function will be invoked (so any side effects of the function will occur, but it's results will be lost).
--- Use hs.http.asyncGet to avoid this.
---@param url string
---@param headers table|nil
---@return int
---@return string
---@return table
function hs.http.get(url, headers) end

--- Sends an HTTP POST request to a URL
---
--- Note: If authentication is required in order to download the request, the required credentials must be specified as
--- part of the URL (e.g. "http://user:password@host.com/"). If authentication fails, or credentials are missing, the
--- connection will attempt to continue without credentials.
--- This function is synchronous and will therefore block all other Lua execution while the request is in progress, you
--- are encouraged to use the asynchronous functions
--- If you attempt to connect to a local Hammerspoon server created with hs.httpserver , then Hammerspoon will block
--- until the connection times out (60 seconds), return a failed result due to the timeout, and then the hs.httpserver
--- callback function will be invoked (so any side effects of the function will occur, but it's results will be lost).
--- Use hs.http.asyncPost to avoid this.
---@param url string
---@param data string|nil
---@param headers table|nil
---@return int
---@return string
---@return table
function hs.http.post(url, data, headers) end

--- Sends an HTTP PUT request to a URL
---
--- Note: If authentication is required in order to download the request, the required credentials must be specified as
--- part of the URL (e.g. "http://user:password@host.com/"). If authentication fails, or credentials are missing, the
--- connection will attempt to continue without credentials.
--- This function is synchronous and will therefore block all other Lua execution while the request is in progress, you
--- are encouraged to use the asynchronous functions
--- If you attempt to connect to a local Hammerspoon server created with hs.httpserver , then Hammerspoon will block
--- until the connection times out (60 seconds), return a failed result due to the timeout, and then the hs.httpserver
--- callback function will be invoked (so any side effects of the function will occur, but it's results will be lost).
--- Use hs.http.asyncPost to avoid this.
---@param url string
---@param data string|nil
---@param headers table|nil
---@return int
---@return string
---@return table
function hs.http.put(url, data, headers) end

--- Registers an HTML Entity with the specified Unicode codepoint which can later referenced in your code as
--- hs.http.htmlEntity[entity]
--- for convenience and readability.
---
--- Note: If an entity label was previously registered, this will overwrite the previous value with a new one.
--- The return value is merely syntactic sugar and you do not need to save it locally; it can be safely ignored --
--- future access to the pre-converted entity should be retrieved as hs.http.htmlEntities[entity] in your code.  It
--- looks good when invoked from the console, though ☺.
---@param entity number
---@param codepoint any
---@return string
function hs.http.registerEntity(entity, codepoint) end

--- Returns a table of keys containing the individual components of the provided url.
---
--- Note: This function assumes that the URL conforms to RFC 1808.  If the URL is malformed or does not conform to
--- RFC1808, then many of these fields may be missing.
--- A contrived example for the url http://user:password@host.site.com:80/path/to%20a/../file.txt;parameter?query1=1&query2=a%28#fragment : hs.inspect(hs.http.urlParts("http://user:password@host.site.com:80/path/to%20a/../file.txt;parameter?query1=1&query2=a%28#fragment")) {
--- absoluteString = "http://user:password@host.site.com:80/path/to%20a/../file.txt;parameter?query1=1&query2=a%28#fragment",
--- absoluteURL = "http://user:password@host.site.com:80/path/to%20a/../file.txt;parameter?query1=1&query2=a%28#fragment",
--- fileSystemRepresentation = "/path/to a/../file.txt",
--- fragment = "fragment",
--- host = "host.site.com",
--- isFileURL = false,
--- lastPathComponent = "file.txt",
--- parameterString = "parameter",
--- password = "password",
--- path = "/path/to a/../file.txt",
--- pathComponents = { "/", "path", "to a", "..", "file.txt" },
--- pathExtension = "txt",
--- port = 80,
--- query = "query1=1&query2=a%28",
--- queryItems = { {
--- query1 = "1"
--- }, {
--- query2 = "a("
--- } },
--- relativePath = "/path/to a/../file.txt",
--- relativeString = "http://user:password@host.site.com:80/path/to%20a/../file.txt;parameter?query1=1&query2=a%28#fragment",
--- resourceSpecifier = "//user:password@host.site.com:80/path/to%20a/../file.txt;parameter?query1=1&query2=a%28#fragment",
--- scheme = "http",
--- standardizedURL = "http://user:password@host.site.com:80/path/file.txt;parameter?query1=1&query2=a%28#fragment",
--- user = "user"
--- }
--- a missing key (e.g. '=value') will be represented as { "" = value }
--- a missing value (e.g. 'key=') will be represented as { key = "" }
--- a missing value with no = (e.g. 'key') will be represented as { key }
--- a missing key and value (e.g. '=') will be represented as { "" = "" }
--- an empty query item (e.g. a query ending in '&' or a query containing && between two other query items) will be
--- represented as { "" }
--- relative URLs are not possible to express properly so baseURL will always be nil and relativePath and
--- relativeString will always match path and absoluteString.
--- These limitations may change in a future update if the need for a more fully compliant URL treatment is determined
--- to be necessary.
---@param url string
---@return table
function hs.http.urlParts(url) end

-- ------------------------------------------------------------
-- hs.httpserver
-- ------------------------------------------------------------

---@class hs.httpserver
hs.httpserver = {}

---@class httpserver
local httpserver = {}

--- Creates a new HTTP or HTTPS server
---
--- Note: By default, the server will start on a random TCP port and advertise itself with Bonjour. You can check the
--- port with hs.httpserver:getPort()
--- By default, the server will listen on all network interfaces. You can override this with
--- hs.httpserver:setInterface() before starting the server
--- Currently, in HTTPS mode, the server will use a self-signed certificate, which most browsers will warn about. If
--- you want/need to be able to use hs.httpserver with a certificate signed by a trusted Certificate Authority, please
--- file an bug on Hammerspoon requesting support for this.
---@param ssl boolean|nil
---@param bonjour any
---@return object
function hs.httpserver.new(ssl, bonjour) end

--- Gets the network interface the server is configured to listen on
---@return string|nil
function httpserver:getInterface() end

--- Gets the Bonjour name the server is configured to advertise itself as
---
--- Note: This is not the hostname of the server, just its name in Bonjour service lists (e.g. Safari's Bonjour
--- bookmarks menu)
---@return string
function httpserver:getName() end

--- Gets the TCP port the server is configured to listen on
---@return number
function httpserver:getPort() end

--- Get or set the maximum allowed body size for an incoming HTTP request.
---
--- Note: Because the Hammerspoon http server processes incoming requests completely in memory, this method puts a
--- limit on the maximum size for a POST or PUT request.
---@param size number|nil
---@return object|current-
function httpserver:maxBodySize(size) end

--- Sends a message to the websocket client
---@param message string
---@return object
function httpserver:send(message) end

--- Sets the request handling callback for an HTTP server object
---
--- Note: The callback will be passed four arguments:
--- A string containing the type of request (i.e. GET / POST / DELETE /etc)
--- A string containing the path element of the request (e.g. /index.html )
--- A table containing the request headers
--- A string containing the raw contents of the request body, or the empty string if no body is included in the request.
--- The callback must return three values:
--- A string containing the body of the response
--- An integer containing the response code (e.g. 200 for a successful request)
--- A table containing additional HTTP headers to set (or an empty table, {} , if no extra headers are required)
--- A POST request, often used by HTML forms, will store the contents of the form in the body of the request.
---@param callback function|nil
---@return object
function httpserver:setCallback(callback) end

--- Sets the network interface the server is configured to listen on
---
--- Note: As well as real interface names (e.g. en0 ) the following values are valid:
--- An IP address of one of your interfaces
--- localhost
--- loopback
--- nil (which means all interfaces, and is the default)
---@param interface string
---@return object
function httpserver:setInterface(interface) end

--- Sets the Bonjour name the server should advertise itself as
---
--- Note: This is not the hostname of the server, just its name in Bonjour service lists (e.g. Safari's Bonjour
--- bookmarks menu)
---@param name string
---@return object
function httpserver:setName(name) end

--- Sets a password for an HTTP server object
---
--- Note: It is not currently possible to set multiple passwords for different users, or passwords only on specific
--- paths
---@param password any
---@return object
function httpserver:setPassword(password) end

--- Sets the TCP port the server is configured to listen on
---@param port number
---@return object
function httpserver:setPort(port) end

--- Starts an HTTP server object
---@return object
function httpserver:start() end

--- Stops an HTTP server object
---@return object
function httpserver:stop() end

--- Enables a websocket endpoint on the HTTP server
---
--- Note: The callback is passed one string parameter containing the received message
--- The callback must return a string containing the response message
--- Given a path '/mysock' and a port of 8000, the websocket URL is as follows:
--- ws://localhost:8000/mysock
--- wss://localhost:8000/mysock (if SSL enabled)
---@param path string
---@param callback function
---@return object
function httpserver:websocket(path, callback) end

-- ------------------------------------------------------------
-- hs.httpserver.hsminweb
-- ------------------------------------------------------------

---@class hs.httpserver.hsminweb
hs.httpserver.hsminweb = {}

---@class hsminweb
local hsminweb = {}

--- A format string, usable with
--- os.date
--- , which will display a date in the format expected for HTTP communications as described in RFC 822, updated by RFC
--- 1123.
---@type string
hs.httpserver.hsminweb.dateFormatString = nil

--- HTTP Response Status Codes
---@type any
hs.httpserver.hsminweb.statusCodes = nil

--- Accessed as
--- self._accessLog
--- .  If query logging is enabled for the web server, an Apache style common log entry will be appended to this string
--- for each request.  See
--- hs.httpserver.hsminweb:queryLogging
--- .
---@type hs.httpserver.hsminweb
hs.httpserver.hsminweb._accessLog = nil

--- Accessed as
--- self._errorHandlers[errorCode]
--- .  A table whose keyed entries specify the function to generate the error response page for an HTTP error.
---@type function
hs.httpserver.hsminweb._errorHandlers = nil

--- Accessed as
--- self._serverAdmin
--- .  A string containing the administrator for the web server.  Defaults to the currently logged in user's short form
--- username and the computer's localized name as returned by
--- hs.host.localizedName()
--- (e.g. "user@computer").
---@type hs.host.localizedName
hs.httpserver.hsminweb._serverAdmin = nil

--- Accessed as
--- self._supportMethods[method]
--- .  A table whose keyed entries specify whether or not a specified HTTP method is supported by this server.
---@type any
hs.httpserver.hsminweb._supportMethods = nil

--- The
--- hs.logger
--- instance for the
--- hs.httpserver.hsminweb
--- module. See the documentation for
--- hs.logger
--- for more information.
---@type hs.logger|hs.httpserver.hsminweb
hs.httpserver.hsminweb.log = nil

--- Returns the current or specified time in the format expected for HTTP communications as described in RFC 822,
--- updated by RFC 1123.
---@param date number|nil
---@return string
function hs.httpserver.hsminweb.formattedDate(date) end

--- Parse the specified URL into its constituent parts.
---
--- Note: To simplify the logic used by this module to determine if a request for a directory is properly terminated
--- with a "/", the path components returned by this function do not remove this character from the component, if
--- present.
--- Some extraneous or duplicate keys have been removed.
--- This function is patterned after RFC 3986 while hs.http.urlParts uses OS X API functions which are patterned after
--- RFC 1808. RFC 3986 obsoletes 1808.  The primary distinction that affects this module is in regards to parameters
--- for path components in the URI -- RFC 3986 disallows them in schema based URI's (like the URL's that are used for
--- web based traffic).
---@param url string
---@return table
function hs.httpserver.hsminweb.urlParts(url) end

--- Create a new hsminweb table object representing a Hammerspoon Web Server.
---
--- Note: a web server's document root is the directory which contains the documents or files to be served by the web
--- server.
--- while an hs.minweb object is actually represented by a Lua table, it has been assigned a meta-table which allows
--- methods to be called directly on it like a user-data object.  For most purposes, you should think of this table as
--- the module's userdata.
---@param documentRoot string|nil
---@return hsminwebTable
function hs.httpserver.hsminweb.new(documentRoot) end

--- Get or set the access-list table for the hsminweb web server
---
--- Note: The access-list feature works by comparing the request headers against a list of tests which either accept or
--- reject the request.  If no access list is set (i.e. it is assigned a value of nil ), then all requests are served.
--- If a table is passed into this method, then any request which is not explicitly accepted by one of the tests
--- provided is rejected (i.e. there is an implicit "reject" at the end of the list).
--- The access-list table is a list of tests which are evaluated in order.  The first test which matches a given
--- request determines whether or not the request is accepted or rejected.
--- header     - a string value matching the name of a header.  While the header name must match exactly, the
--- comparison is case-insensitive (i.e. "X-Remote-addr" and "x-remote-addr" will both match the actual header name
--- used, which is "X-Remote-Addr").
--- value      - a string value specifying the value to compare the header key's value to.
--- isPattern  - a boolean indicating whether or not the header key's value should be compared to value as a pattern
--- match (true) -- see Lua documentation 6.4.1, help.lua._man._6_4_1 in the console, or as an exact match (false)
--- isAccepted - a boolean indicating whether or not a match should be accepted (true) or rejected (false)
--- A special entry of the form { '*', '*', '*', true } accepts all further requests and can be used as the final entry
--- if you wish for the access list to function as a list of requests to reject, but to accept any requests which do
--- not match a previous test.
--- A special entry of the form { '*', '*', '*', false } rejects all further requests and can be used as the final
--- entry if you wish for the access list to function as a list of requests to accept, but to reject any requests which
--- do not match a previous test.  This is the implicit "default" final test if a table is assigned with the
--- access-list method and does not actually need to be specified, but is included for completeness.
--- Note that any entry after an entry in which the first two parameters are equal to '*' will never actually be used.
--- The tests are performed in order; if you wich to allow one IP address in a range, but reject all others, you should
--- list the accepted IP addresses first. For example: {
--- { 'X-Remote-Addr', '192.168.1.100',  false, true },  -- accept requests from 192.168.1.100
--- { 'X-Remote-Addr', '^192%.168%.1%.', true,  false }, -- reject all others from the 192.168.1 subnet
--- { '*',             '*',              '*',   true }   -- accept all other requests
--- }
--- Most of the headers available are provided by the requesting web browser, so the exact headers available will vary.
--- You can find some information about common HTTP request headers at: https://en.wikipedia.org/wiki/List_of_HTTP_header_fields.
--- X-Remote-Addr - the remote IPv4 or IPv6 address of the machine making the request,
--- X-Remote-Port - the TCP port of the remote machine where the request originated.
--- X-Server-Addr - the server IPv4 or IPv6 address that the web server received the request from.  For machines with
--- multiple interfaces, this will allow you to determine which interface the request was received on.
--- X-Server-Port - the TCP port of the web server that received the request.
---@param table table|nil
---@return hsminwebTable|current-
function hsminweb:accessList(table) end

--- Get or set the whether or not a directory index is returned when the requested URL specifies a directory and no
--- file matching an entry in the directory indexes table is found.
---
--- Note: if this value is false, then an attempt to retrieve a URL specifying a directory that does not contain a
--- default file as identified by one of the entries in the hs.httpserver.hsminweb:directoryIndex list will result in a
--- "403.2" error.
---@param flag any
---@return hsminwebTable|current-
function hsminweb:allowDirectory(flag) end

--- Get or set the whether or not the web server should advertise itself via Bonjour when it is running.
---
--- Note: this flag can only be changed when the server is not running (i.e. the hs.httpserver.hsminweb:start method
--- has not yet been called, or the hs.httpserver.hsminweb:stop method is called first.)
---@param flag any
---@return hsminwebTable|current-
function hsminweb:bonjour(flag) end

--- Get or set the whether or not CGI file execution is enabled.
---@param flag any
---@return hsminwebTable|current-
function hsminweb:cgiEnabled(flag) end

--- Get or set the file extensions which identify files which should be executed as CGI scripts to provide the results
--- to an HTTP request.
---
--- Note: this list is ignored if hs.httpserver.hsminweb:cgiEnabled is not also set to true.
---@param table file[]|nil
---@return hsminwebTable|current-
function hsminweb:cgiExtensions(table) end

--- Get or set the file names to look for when the requested URL specifies a directory.
---
--- Note: Files listed in this table are checked in order, so the first matched is served.  If no file match occurs,
--- then the server will return a generated list of the files in the directory, or a "403.2" error, depending upon the
--- value controlled by hs.httpserver.hsminweb:allowDirectory .
---@param table file[]|nil
---@return hsminwebTable|current-
function hsminweb:directoryIndex(table) end

--- Get or set the whether or not DNS lookups are performed.
---
--- Note: DNS lookups can be time consuming or even block Hammerspoon for a short time, so they are disabled by default.
--- Currently DNS lookups are (optionally) performed for CGI scripts, but may be added for other purposes in the future
--- (logging, etc.).
---@param flag any
---@return hsminwebTable|current-
function hsminweb:dnsLookup(flag) end

--- Get or set the document root for the web server.
---@param path string|nil
---@return hsminwebTable|current-
function hsminweb:documentRoot(path) end

--- Get or set the network interface that the hsminweb web server will listen on
---
--- Note: See hs.httpserver.setInterface for a description of valid values that can be specified as the interface
--- argument to this method.
--- the interface can only be specified before the hsminweb web server has been started.  If you wish to change the
--- listening interface for a running web server, you must stop it with hs.httpserver.hsminweb:stop before invoking
--- this method and then restart it with hs.httpserver.hsminweb:start .
---@param interface string|nil
---@return hsminwebTable|current-
function hsminweb:interface(interface) end

--- Get or set the extension of files which contain Lua code which should be executed within Hammerspoon to provide the
--- results to an HTTP request.
---
--- Note: This extension is checked after the extensions given to hs.httpserver.hsminweb:cgiExtensions ; this means
--- that if the same extension set by this method is also in the CGI extensions list, then the file will be interpreted
--- as a CGI script and ignore this setting.
---@param string string|nil
---@return hsminwebTable|current-
function hsminweb:luaTemplateExtension(string) end

--- Get or set the maximum body size for an HTTP request
---
--- Note: Because the Hammerspoon http server processes incoming requests completely in memory, this method puts a
--- limit on the maximum size for a POST or PUT request.
--- If the request body exceeds this size, hs.httpserver will respond with a status code of 405 for the method before
--- this module ever receives the request.
---@param size number|nil
---@return hsminwebTable|current-
function hsminweb:maxBodySize(size) end

--- Get or set the name the web server uses in Bonjour advertisement when the web server is running.
---@param name string|nil
---@return hsminwebTable|current-
function hsminweb:name(name) end

--- Set a password for the hsminweb web server, or return a boolean indicating whether or not a password is currently
--- set for the web server.
---
--- Note: the password, if set, is server wide and causes the server to use the Basic authentication scheme with an
--- empty string for the username.
--- this module is an extension to the Hammerspoon core module hs.httpserver , so it has the same limitations regarding
--- server passwords. See the documentation for hs.httpserver.setPassword ( help.hs.httpserver.setPassword in the
--- Hammerspoon console).
---@param password any
---@return hsminwebTable|boolean
function hsminweb:password(password) end

--- Get or set the name the port the web server listens on
---
--- Note: due to security restrictions enforced by OS X, the port must be a number greater than 1023
---@param port number|nil
---@return hsminwebTable|current-
function hsminweb:port(port) end

--- Get or set the whether or not requests to this web server are logged.
---
--- Note: If logging is enabled, an Apache common style log entry is appended to self._accesslog for each request made
--- to the web server.
--- Error messages during content generation are always logged to the Hammerspoon console via the hs.logger instance
--- saved to hs.httpserver.hsminweb.log .
---@param flag any
---@return hsminwebTable|current-
function hsminweb:queryLogging(flag) end

--- Get or set the timeout for a CGI script
---
--- Note: With the current functionality available in hs.httpserver , any script which is expected to return content
--- for an HTTP request must run in a blocking manner -- this means that no other Hammerspoon activity can be occurring
--- while the script is executing.  This parameter lets you set the maximum amount of time such a script can hold
--- things up before being terminated.
--- An alternative implementation of at least some of the methods available in hs.httpserver is being considered which
--- may make it possible to use hs.task for these scripts, which would alleviate this blocking behavior.  However, even
--- if this is addressed, a timeout for scripts is still desirable so that a client making a request doesn't sit around
--- waiting forever if a script is malformed.
---@param integer number|nil
---@return hsminwebTable|current-
function hsminweb:scriptTimeout(integer) end

--- Get or set the whether or not the web server utilizes SSL for HTTP request and response communications.
---
--- Note: this flag can only be changed when the server is not running (i.e. the hs.httpserver.hsminweb:start method
--- has not yet been called, or the hs.httpserver.hsminweb:stop method is called first.)
--- this module is an extension to the Hammerspoon core module hs.httpserver , so it has the same considerations
--- regarding SSL. See the documentation for hs.httpserver.new ( help.hs.httpserver.new in the Hammerspoon console).
---@param flag any
---@return hsminwebTable|current-
function hsminweb:ssl(flag) end

--- Start serving pages for the hsminweb web server.
---@return hsminwebTable
function hsminweb:start() end

--- Stop serving pages for the hsminweb web server.
---
--- Note: this method is called automatically during garbage collection.
---@return hsminwebTable
function hsminweb:stop() end

-- ------------------------------------------------------------
-- hs.httpserver.hsminweb.cgilua
-- ------------------------------------------------------------

---@class hs.httpserver.hsminweb.cgilua
hs.httpserver.hsminweb.cgilua = {}

--- The file name of the running script. Obtained from cgilua.script_path.
---@type any
hs.httpserver.hsminweb.cgilua.script_file = nil

--- The system path of the running script. Equivalent to the CGI environment variable SCRIPT_FILENAME.
---@type any
hs.httpserver.hsminweb.cgilua.script_path = nil

--- The directory of the running script. Obtained from cgilua.script_path.
---@type any
hs.httpserver.hsminweb.cgilua.script_pdir = nil

--- If PATH_INFO represents a directory (i.e. ends with "/"), then this is equal to
--- cgilua.script_vpath
--- .  Otherwise, this contains the directory portion of
--- cgilua.script_vpath
--- .
---@type any
hs.httpserver.hsminweb.cgilua.script_vdir = nil

--- Equivalent to the CGI environment variable PATH_INFO or "/", if no PATH_INFO is set.
---@type any
hs.httpserver.hsminweb.cgilua.script_vpath = nil

--- The directory used by
--- cgilua.tmpfile
---@type any
hs.httpserver.hsminweb.cgilua.tmp_path = nil

--- The name of the script as requested in the URL. Equivalent to the CGI environment variable SCRIPT_NAME.
---@type any
hs.httpserver.hsminweb.cgilua.urlpath = nil

--- Sets the HTTP response type for the content being generated to maintype/subtype.
---
--- Note: This sets the Content-Type header field for the HTTP response being generated.  This will override any
--- previous setting, including the default of "text/html".
---@param maintype any
---@param subtype any
---@return none
function hs.httpserver.hsminweb.cgilua.contentheader(maintype, subtype) end

--- Executes a lua file (given by filepath) if it exists.
---
--- Note: This function only interprets the file if it exists; if the file does not exist, it returns an error to the
--- calling code (not the web client)
--- During the processing of a web request, the local directory is temporarily changed to match the local directory of
--- the path of the file being served, as determined by the URL of the request.  This is usually different than the
--- Hammerspoon default directory which corresponds to the directory which contains the init.lua file for Hammerspoon.
---@param filename string
---@return results
function hs.httpserver.hsminweb.cgilua.doif(filename) end

--- Executes a lua file (given by filepath).
---
--- Note: If the file does not exist, an Internal Server error is returned to the client and an error is logged to the
--- Hammerspoon console.
--- During the processing of a web request, the local directory is temporarily changed to match the local directory of
--- the path of the file being served, as determined by the URL of the request.  This is usually different than the
--- Hammerspoon default directory which corresponds to the directory which contains the init.lua file for Hammerspoon.
---@param filename string
---@return results
function hs.httpserver.hsminweb.cgilua.doscript(filename) end

--- Sends the message to the
--- hs.httpserver.hsminweb
--- log, tagged as an error.
---
--- Note: Available within a lua template file as cgilua.errorlog
--- By default, messages logged with this method will appear in the Hammerspoon console and are available in the
--- hs.logger history.
---@param msg any
---@return nil
function hs.httpserver.hsminweb.cgilua.errorlog(msg) end

--- Sets the HTTP response header
--- key
--- to
--- value
---
--- Note: You should not use this function to set the value for the "Content-Type" key; instead use
--- cgilua.contentheader or cgilua.htmlheader .
---@param key string
---@param value string
---@return none
function hs.httpserver.hsminweb.cgilua.header(key, value) end

--- Sets the HTTP response type to "text/html"
---
--- Note: This sets the Content-Type header field for the HTTP response being generated to "text/html".  This is the
--- default value, so generally you should not need to call this function unless you have previously changed it with
--- the cgilua.contentheader function.
---@return none
function hs.httpserver.hsminweb.cgilua.htmlheader() end

--- Returns an absolute URL for the given URI by prepending the path with the scheme, hostname, and port of this web
--- server.
---
--- Note: If you wish to append query items to the path or expand a relative path into it's full path, see
--- cgilua.mkurlpath .
---@param uri string
---@return string
function hs.httpserver.hsminweb.cgilua.mkabsoluteurl(uri) end

--- Creates a full document URI from a partial URI, including query arguments if present.
---
--- Note: This function is intended to be used in conjunction with cgilua.mkabsoluteurl to generate a full URL.  If the
--- uri provided does not begin with a "/", then the current directory path is prepended to the uri and any query
--- arguments are appended.
--- e.g. cgilua.mkabsoluteurl(cgiurl.mkurlpath("file.lp", { key = value, ... })) will return a full URL specifying the
--- file file.lp in the current directory with the specified key-value pairs as query arguments.
---@param uri string
---@param args table|nil
---@return string
function hs.httpserver.hsminweb.cgilua.mkurlpath(uri, args) end

--- Appends the given arguments to the response body.
---
--- Note: Available within a lua template file as cgilua.print
--- This function works like the lua builtin print command in that it converts all its arguments to strings, separates
--- them with tabs ( \t ), and ends the line with a newline ( \n ) before appending them to the current response body.
---@param ... any
---@return nil
function hs.httpserver.hsminweb.cgilua.print(...) end

--- Appends the given arguments to the response body.
---
--- Note: Available within a lua template file as cgilua.put
--- This function works by flattening tables and converting all values except for nil and false to their string
--- representation and then appending them in order to the response body. Unlike cgilua.print , it does not separate
--- values with a tab character or terminate the line with a newline character.
---@param ... any
---@return nil
function hs.httpserver.hsminweb.cgilua.put(...) end

--- Sends the headers to force a redirection to the given URL adding the parameters in table args to the new URL.
---
--- Note: This function should generally be followed by a return in your lua template page as no additional processing
--- or output should occur when a request is to be redirected.
---@param url string
---@param args table|nil
---@return none
function hs.httpserver.hsminweb.cgilua.redirect(url, args) end

--- Returns a string with the value of the CGI environment variable corresponding to varname.
---
--- Note: "AUTH_TYPE"         - If the server supports user authentication, and the script is protected, this is the
--- protocol-specific authentication method used to validate the user.
--- "CONTENT_LENGTH"    - The length of the content itself as given by the client.
--- "CONTENT_TYPE"      - For queries which have attached information, such as HTTP POST and PUT, this is the content
--- type of the data.
--- "DOCUMENT_ROOT"     - the real directory on the server that corresponds to a DOCUMENT_URI of "/".  This is the
--- first directory which contains files or sub-directories which are served by the web server.
--- "DOCUMENT_URI"      - the path portion of the HTTP URL requested
--- "GATEWAY_INTERFACE" - The revision of the CGI specification to which this server complies. Format: CGI/revision
--- "PATH_INFO"         - The extra path information, as given by the client. In other words, scripts can be accessed
--- by their virtual pathname, followed by extra information at the end of this path. The extra information is sent as
--- PATH_INFO. This information should be decoded by the server if it comes from a URL before it is passed to the CGI
--- script.
--- "PATH_TRANSLATED"   - The server provides a translated version of PATH_INFO, which takes the path and does any
--- virtual-to-physical mapping to it.
--- "QUERY_STRING"      - The information which follows the "?" in the URL which referenced this script. This is the
--- query information. It should not be decoded in any fashion. This variable should always be set when there is query
--- information, regardless of command line decoding.
--- "REMOTE_ADDR"       - The IP address of the remote host making the request.
--- "REMOTE_HOST"       - The hostname making the request. If the server does not have this information, it should set
--- REMOTE_ADDR and leave this unset.
--- "REMOTE_IDENT"      - If the HTTP server supports RFC 931 identification, then this variable will be set to the
--- remote user name retrieved from the server. Usage of this variable should be limited to logging only.
--- "REMOTE_USER"       - If the server supports user authentication, and the script is protected, this is the username
--- they have authenticated as.
--- "REQUEST_METHOD"    - The method with which the request was made. For HTTP, this is "GET", "HEAD", "POST", etc.
--- "REQUEST_TIME"      - the time the server received the request represented as the number of seconds since 00:00:00
--- UTC on 1 January 1970.  Usable with os.date to provide the date and time in whatever format you require.
--- "REQUEST_URI"       - the DOCUMENT_URI with any query string present in the request appended.  Usually this
--- corresponds to the URL without the scheme or host information.
--- "SCRIPT_FILENAME"   - the actual path to the script being executed.
--- "SCRIPT_NAME"       - A virtual path to the script being executed, used for self-referencing URLs.
--- "SERVER_NAME"       - The server's hostname, DNS alias, or IP address as it would appear in self-referencing URLs.
--- "SERVER_PORT"       - The port number to which the request was sent.
--- "SERVER_PROTOCOL"   - The name and revision of the information protocol this request came in with. Format:
--- protocol/revision
--- "SERVER_SOFTWARE"   - The name and version of the web server software answering the request (and running the
--- gateway). Format: name/version
--- HTTP_ACCEPT, HTTP_ACCEPT_ENCODING, HTTP_ACCEPT_LANGUAGE, HTTP_CACHE_CONTROL, HTTP_CONNECTION, HTTP_DNT, HTTP_HOST,
--- HTTP_USER_AGENT
--- HTTP_X_REMOTE_ADDR, HTTP_X_REMOTE_PORT, HTTP_X_SERVER_ADDR, HTTP_X_SERVER_PORT
--- A list of common request headers and their definitions can be found at
--- https://en.wikipedia.org/wiki/List_of_HTTP_header_fields
---@param varname string
---@return string
function hs.httpserver.hsminweb.cgilua.servervariable(varname) end

--- Returns two strings with the "first directory" and the "remaining path" of the given path string splitted on the
--- first separator ("/" or "").
---@param path string
---@return path component
---@return path remainder
function hs.httpserver.hsminweb.cgilua.splitfirst(path) end

--- Returns two strings with the "directory path" and "file" parts of the given path string splitted on the last
--- separator ("/" or "").
---
--- Note: This function used to be called cgilua.splitpath and still can be accessed by this name for compatibility
--- reasons. cgilua.splitpath may be deprecated in future versions.
---@deprecated
---@param path string
---@return directory
---@return file
function hs.httpserver.hsminweb.cgilua.splitonlast(path) end

--- Returns the file handle to a temporary file for writing, or nil and an error message if the file could not be
--- created for any reason.
---
--- Note: The file is automatically deleted when the HTTP request has been completed, so if you need for the data to
--- persist, make sure to io.flush or io.close the file handle yourself and copy the file to a more permanent location.
---@param dir any
---@param namefunction function|nil
---@return file
---@return err
function hs.httpserver.hsminweb.cgilua.tmpfile(dir, namefunction) end

--- Returns a temporary file name used by
--- cgilua.tmpfile
--- .
---
--- Note: This function uses hs.host.globallyUniqueString to generate a unique file name.
---@return string
function hs.httpserver.hsminweb.cgilua.tmpname() end

-- ------------------------------------------------------------
-- hs.httpserver.hsminweb.cgilua.lp
-- ------------------------------------------------------------

---@class hs.httpserver.hsminweb.cgilua.lp
hs.httpserver.hsminweb.cgilua.lp = {}

--- Converts the specified Lua template source into a Lua function.
---
--- Note: The source provided is first compared to a stored cache of previously translated templates and will re-use an
--- existing translation if the template has been seen before.  If the source is unique, cgilua.lp.translate is called
--- on the template source.
--- This function is used internally by cgilua.lp.include , and probably won't be useful unless you want to translate a
--- dynamically generated template -- which has security implications, depending upon what inputs you use to generate
--- this template, because the resulting Lua code will execute within your Hammerspoon environment.  Be very careful
--- about your inputs if you choose to ignore this warning.
---@param source string
---@param name function
---@param env table|nil
---@return function
function hs.httpserver.hsminweb.cgilua.lp.compile(source, name, env) end

--- Includes the template specified by the
--- file
--- parameter.
---
--- Note: This function is called by the web server to process the template specified by the requested URL.  Subsequent
--- invocations of this function can be used to include common or re-used code from other template files and will be
--- included in-line where the cgilua.lp.include function is invoked in the originating template.
--- During the processing of a web request, the local directory is temporarily changed to match the local directory of
--- the path of the file being served, as determined by the URL of the request.  This is usually different than the
--- Hammerspoon default directory which corresponds to the directory which contains the init.lua file for Hammerspoon.
--- the __index metamethod points to the _G environment variable in the Hammerspoon Lua instance; this means that any
--- global variable in the Hammerspoon environment is available to the lua code in a template file.
--- the __newindex metamethod points to a function which creates new "global" variables in the template files
--- environment; this means that if a template includes another template file, and that second template file creates a
--- "global" variable, that new variable will be available in the environment of the calling template, but will not be
--- shared with the Hammerspoon global variable space;  "global" variables created in this manner will be released when
--- the HTTP request is completed.
--- print is overridden so that its output is streamed into the response body to be returned when the web request
--- completes.  It follows the traditional pattern of the print builtin function: multiple arguments are separated by a
--- tab character, the output is terminated with a new-line character, non-string arguments are converted to strings
--- via the tostring builtin function.
--- write is defined as an alternative to print and differs in the following ways from the print function described
--- above:  no intermediate tabs or newline are included in the output streamed to the response body.
--- cgilua is defined as a table containing all of the functions included in this support sub-module.
--- CGIVariables - a table containing key-value pairs of the same data available through the cgilua.servervariable
--- function.
--- id           - a string, generated via hs.host.globallyUniqueString , unique to this specific HTTP request.
--- log          - a table/object representing the hs.httpserver.hsminweb instance of hs.logger .  This can be used to
--- log messages to the Hammerspoon console as described in the documentation for hs.logger .
--- this table also contains a table with the key "_".  This table contains functions and data used internally, and is
--- described more fully in a supporting document (TBD).  It is targeted primarily at custom error functions designed
--- for use with hs.httpserver.hsminweb and should not generally be necessary for Lua template files.
--- method  - the method of the HTTP request, most commonly "GET" or "POST"
--- path    - the path portion of the requested URL.
--- body    - a string containing the response body.  As the lua template outputs content, this string is appended to.
--- code    - an integer representing the currently expected response code for the HTTP request.
--- headers - a table containing key-value pairs of the currently defined response headers
--- _tmpfiles    - used internally to track temporary files used in the completion of this HTTP request; do not modify
--- directly.
---@param file string
---@param env table|nil
---@return none
function hs.httpserver.hsminweb.cgilua.lp.include(file, env) end

--- Converts the specified Lua template source into Lua code executable within the Hammerspoon environment.
---
--- Note: This function is used internally by cgilua.lp.include , and probably won't be useful unless you want to
--- translate a dynamically generated template -- which has security implications, depending upon what inputs you use
--- to generate this template, because the resulting Lua code will execute within your Hammerspoon environment.  Be
--- very careful about your inputs if you choose to ignore this warning.
--- To ensure that the translated code has access to the cgilua support functions, pass _ENV as the environment
--- argument to the load lua builtin; otherwise any output generated by the resulting function will be sent to the
--- Hammerspoon console and not included in the HTTP response sent back to the client.
---@param source string
---@return luaCode
function hs.httpserver.hsminweb.cgilua.lp.translate(source) end

-- ------------------------------------------------------------
-- hs.httpserver.hsminweb.cgilua.urlcode
-- ------------------------------------------------------------

---@class hs.httpserver.hsminweb.cgilua.urlcode
hs.httpserver.hsminweb.cgilua.urlcode = {}

--- Encodes the table of key-value pairs as a query string suitable for inclusion in a URL.
---
--- Note: the string will be of the form: "key1=value1&key2=value2..." where all of the keys and values are properly
--- escaped using cgilua.urlcode.escape .  If you are crafting a URL by hand, the result of this function should be
--- appended to the end of the URL after a "?" character to specify where the query string begins.
---@param table table
---@return string
function hs.httpserver.hsminweb.cgilua.urlcode.encodetable(table) end

--- URL encodes the provided string, making it safe as a component within a URL.
---
--- Note: this function assumes that the provided string is a single component and URL encodes all non-alphanumeric
--- characters.  Do not use this function to generate a URL query string -- use cgilua.urlcode.encodetable .
---@param string string
---@return string
function hs.httpserver.hsminweb.cgilua.urlcode.escape(string) end

--- Inserts the specified key and value into the table of key-value pairs.
---
--- Note: If the key already exists in the table, its value is converted to a table (if it isn't already) and the new
--- value is added to the end of the array of values for the key.
--- This function is used internally by cgilua.urlcode.parsequery or can be used to prepare a table of key-value pairs
--- for cgilua.urlcode.encodetable .
---@param table table
---@param key string
---@param value any
---@return none
function hs.httpserver.hsminweb.cgilua.urlcode.insertfield(table, key, value) end

--- Parse the query string and store the key-value pairs in the provided table.
---
--- Note: The specification allows for the same key to be assigned multiple values in an encoded string, but does not
--- specify the behavior; by convention, web servers assign these multiple values to the same key in an array (table).
--- This function follows that convention.  This is most commonly used by forms which allow selecting multiple options
--- via check boxes or in a selection list.
--- This function uses cgilua.urlcode.insertfield to build the key-value table.
---@param query number
---@param table table
---@return none
function hs.httpserver.hsminweb.cgilua.urlcode.parsequery(query, table) end

--- Removes any URL encoding in the provided string.
---@param string string
---@return string
function hs.httpserver.hsminweb.cgilua.urlcode.unescape(string) end

-- ------------------------------------------------------------
-- hs.image
-- ------------------------------------------------------------

---@class hs.image
hs.image = {}

---@class image
local image = {}

--- Table of arrays containing the names of additional internal system images which may also be available for use with
--- hs.drawing.image
--- and
--- hs.image.imageFromName
--- .
---@type table
hs.image.additionalImageNames[] = nil

--- Table containing the names of internal system images for use with hs.drawing.image
---@type table
hs.image.systemImageNames[] = nil

--- Gets the EXIF metadata information from an image file.
---@param path string
---@return table|nil
function hs.image.getExifFromPath(path) end

--- Creates an
--- hs.image
--- object for the file or files specified
---@param file files[]
---@return object
function hs.image.iconForFile(file) end

--- Creates an
--- hs.image
--- object of the icon for the specified file type.
---@param fileType any
---@return object
function hs.image.iconForFileType(fileType) end

--- Creates an
--- hs.image
--- object using the icon from an App
---@param bundleID string
---@return object
function hs.image.imageFromAppBundle(bundleID) end

--- Creates an image from an ASCII representation with the specified context.
---
--- Note: To use the ASCII diagram image support, see https://github.com/cparnot/ASCIImage and
--- http://cocoamine.net/blog/2015/03/20/replacing-photoshop-with-nsstring
--- The default for lineWidth, when antialiasing is off, is defined within the ASCIImage library. Geometrically it
--- represents one half of the hypotenuse of the unit right-triangle and is a more accurate representation of a "real"
--- point size when dealing with arbitrary angles and lines than 1.0 would be.
---@param ascii string
---@param context? string
---@return object
function hs.image.imageFromASCII(ascii, context) end

--- Creates an
--- hs.image
--- object from a video file or the album artwork of an audio file or directory
---
--- Note: If a thumbnail can be generated for a video file, it is returned as an hs.image object, otherwise the
--- filetype icon
--- For audio files, this function first determines the containing directory (if not already a directory)
--- It checks if any of the following common filenames for album art are present:
--- cover.jpg
--- front.jpg
--- art.jpg
--- album.jpg
--- folder.jpg
--- If one of the common album art filenames is found, it is returned as an hs.image object
--- This is faster than extracting image metadata and allows for obtaining artwork associated with file formats such as
--- .flac/.ogg
--- If no common album art filenames are found, it attempts to extract image metadata from the file. This works for
--- .mp3/.m4a files
--- If embedded image metadata is found, it is returned as an hs.image object, otherwise the filetype icon
---@param file string
---@return object
function hs.image.imageFromMediaFile(file) end

--- Returns the hs.image object for the specified name, if it exists.
---
--- Note: Some predefined labels corresponding to OS X System default images can be found in hs.image.systemImageNames .
--- an image whose name was explicitly set with the setName method since the last full restart of Hammerspoon
--- Hammerspoon's main application bundle
--- the Application Kit framework (this is where most of the images listed in hs.image.systemImageNames are located)
--- Image names can be assigned by the image creator or by calling the hs.image:setName method on an hs.image object.
---@param string string
---@return object
function hs.image.imageFromName(string) end

--- Loads an image file
---@param path string
---@return object
function hs.image.imageFromPath(path) end

--- Creates an
--- hs.image
--- object from the contents of the specified URL.
---
--- Note: If a callback function is supplied, this function will return nil immediately and the image will be fetched
--- asynchronously
---@param url string
---@param callbackFn? function|nil
---@return object
function hs.image.imageFromURL(url, callbackFn) end

--- Creates a new bitmap representation of the image and returns it as a new hs.image object
---
--- Note: a bitmap representation of an image is rendered at the specific size specified (or inherited) when it is
--- generated -- if you later scale it to a different size, the bitmap will be scaled as larger or smaller pixels
--- rather than smoothly.
--- this method may be useful when preparing images for other devices (e.g. hs.streamdeck ).
---@param size table|nil
---@param gray number
---@return imageObject
function image:bitmapRepresentation(size, gray) end

--- Reads the color of the pixel at the specified location.
---@param point hs.geometry.point
---@return table
function image:colorAt(point) end

--- Returns a copy of the image
---@return imageObject
function image:copy() end

--- Returns a copy of the portion of the image specified by the rectangle specified.
---@param rectangle table
---@return object
function image:croppedCopy(rectangle) end

--- Returns a bitmap representation of the image as a base64 encoded URL string
---
--- Note: You can convert the string back into an image object with hs.image.imageFromURL , e.g.
--- hs.image.imageFromURL(string)
---@param scale boolean|nil
---@param type any
---@return string
function image:encodeAsURLString(scale, type) end

--- Get or set the name of the image represented by the hs.image object.
---
--- Note: see also hs.image:setName for a variant that returns a boolean instead.
---@param name hs.image|nil
---@return imageObject|string
function image:name(name) end

--- Save the hs.image object as an image of type
--- filetype
--- to the specified filename.
---
--- Note: Saves image at the size in points (or pixels, if scale is true) as reported by hs.image:size() for the image
--- object
---@param filename string
---@param scale boolean|nil
---@param filetype any
---@return boolean
function image:saveToFile(filename, scale, filetype) end

--- Assigns the name assigned to the hs.image object.
---
--- Note: This method is included for backwards compatibility and is considered deprecated.  It is equivalent to
--- hs.image:name(name) and true or false .
---@deprecated
---@param Name hs.image
---@return boolean
function image:setName(Name) end

--- Returns a copy of the image resized to the height and width specified in the size table.
---
--- Note: This method is included for backwards compatibility and is considered deprecated.  It is equivalent to
--- hs.image:copy():size(size, [absolute]) .
---@deprecated
---@param size table
---@param absolute? any
---@return object
function image:setSize(size, absolute) end

--- Get or set the size of the image represented by the hs.image object.
---
--- Note: See also hs.image:setSize for creating a copy of the image at a new size.
---@param size table|nil
---@param absolute any
---@return imageObject|size
function image:size(size, absolute) end

--- Get or set whether the image is considered a template image.
---
--- Note: Template images consist of black and clear colors (and an alpha channel). Template images are not intended to
--- be used as standalone images and are usually mixed with other content to create the desired final appearance.
--- Images with this flag set to true usually appear lighter than they would with this flag set to false.
---@param state boolean
---@return imageObject|boolean
function image:template(state) end

--- Converts an image to an ASCII representation of the image in the form of a string.
---@param width number
---@param height number
---@return string
function image:toASCII(width, height) end

-- ------------------------------------------------------------
-- hs.inspect
-- ------------------------------------------------------------

---@class hs.inspect
hs.inspect = {}

--- Gets a human readable version of the supplied Lua variable
---
--- Note: For convenience, you can call this function as hs.inspect(variable)
--- To view the output in Hammerspoon's Console, use print(hs.inspect(variable))
--- For more information on the options, and some examples, see the upstream docs
---@param variable any
---@param options? any
---@return string
function hs.inspect.inspect(variable, options) end

-- ------------------------------------------------------------
-- hs.ipc
-- ------------------------------------------------------------

---@class hs.ipc
hs.ipc = {}

---@class ipc
local ipc = {}

--- See
--- hs.ipc.cliColors
--- .
---@return table
function hs.ipc.cliGetColors() end

--- See
--- hs.ipc.cliColors
--- .
---@return any
function hs.ipc.cliResetColors() end

--- See
--- hs.ipc.cliColors
--- .
---@param table any
---@return table
function hs.ipc.cliSetColors(table) end

--- Get or set the terminal escape codes used to produce colorized output in the
--- hs
--- command line tool
---
--- Note: For a brief intro into terminal colors, you can visit a web site like this one
--- http://jafrog.com/2013/11/23/colors-in-terminal.html
--- Lua doesn't support octal escapes in it's strings, so use \x1b or \27 to indicate the escape character e.g.
--- ipc.cliSetColors{ initial = "", input = "\27[33m", output = "\27[38;5;11m" }
--- Changes made with this function are saved with hs.settings with the following labels and will persist through a
--- reload or restart of Hammerspoon: "ipc.cli.color_initial", "ipc.cli.color_input", "ipc.cli.color_output", and
--- "ipc.cli.color_error"
---@param colors any
---@return table
function hs.ipc.cliColors(colors) end

--- Installs the
--- hs
--- command line tool
---
--- Note: If this function fails, it is likely that you have some old/broken symlinks. You can use
--- hs.ipc.cliUninstall() to forcibly tidy them up
--- You may need to pre-create /usr/local/bin and /usr/local/share/man/man1 in a terminal using sudo, and adjust
--- permissions so your login user can write to them
---@param path string|nil
---@param silent? any
---@return boolean
function hs.ipc.cliInstall(path, silent) end

--- Get or set whether or not the command line tool saves a history of the commands you type.
---
--- Note: If this is enabled, your history is saved in hs.configDir .. ".cli.history" , which is usually
--- "~/.hammerspoon/.cli.history".
--- If you have multiple invocations of the command line tool running at the same time, only the history of the last
--- one cleanly exited is saved; this is a limitation of the readline wrapper Apple has provided for libedit and at
--- present no workaround is known.
--- Changes made with this function are saved with hs.settings with the label "ipc.cli.saveHistory" and will persist
--- through a reload or restart of Hammerspoon.
---@param state boolean
---@return boolean
function hs.ipc.cliSaveHistory(state) end

--- Get or set whether the maximum number of commands saved when command line tool history saving is enabled.
---
--- Note: When hs.ipc.cliSaveHistory is enabled, your history is saved in hs.configDir .. ".cli.history" , which is
--- usually "~/.hammerspoon/.cli.history".
--- If you have multiple invocations of the command line tool running at the same time, only the history of the last
--- one cleanly exited is saved; this is a limitation of the readline wrapper Apple has provided for libedit and at
--- present no workaround is known.
--- Changes made with this function are saved with hs.settings with the label "ipc.cli.historyLimit" and will persist
--- through a reload or restart of Hammerspoon.
---@param size hs.ipc.cliSaveHistory|nil
---@return number
function hs.ipc.cliSaveHistorySize(size) end

--- Gets the status of the
--- hs
--- command line tool
---@param path string|nil
---@param silent? any
---@return boolean
function hs.ipc.cliStatus(path, silent) end

--- Uninstalls the
--- hs
--- command line tool
---
--- Note: This function used to be very conservative and refuse to remove symlinks it wasn't sure about, but now it
--- will unconditionally remove whatever it finds at path/bin/hs and path/share/man/man1/hs.1 . This is more likely to
--- be useful in situations where this command is actually needed (please open an Issue on GitHub if you disagree!)
---@param path string|nil
---@param silent? any
---@return boolean
function hs.ipc.cliUninstall(path, silent) end

--- Create a new local ipcObject for receiving and responding to messages from a remote port
---
--- Note: a remote port can send messages at any time to a local port; a local port can only respond to messages from a
--- remote port
---@param name string
---@param fn function
---@return ipcObject
function hs.ipc.localPort(name, fn) end

--- Create a new remote ipcObject for sending messages asynchronously to a local port
---
--- Note: a remote port can send messages at any time to a local port; a local port can only respond to messages from a
--- remote port
---@param name string
---@return ipcObject
function hs.ipc.remotePort(name) end

--- Deletes the ipcObject, stopping it as well if necessary
function ipc:delete() end

--- Returns whether or not the ipcObject represents a remote or local port
---
--- Note: a remote port can send messages at any time to a local port; a local port can only respond to messages from a
--- remote port
---@return boolean
function ipc:isRemote() end

--- Returns whether or not the ipcObject port is still valid or not
---@return boolean
function ipc:isValid() end

--- Returns the name the ipcObject uses for its port when active
---@return string
function ipc:name() end

--- Sends a message from a remote port to a local port
---@param data string
---@param msgID number
---@param waitTimeout number|nil
---@param oneWay number
---@return status
---@return response
function ipc:sendMessage(data, msgID, waitTimeout, oneWay) end

-- ------------------------------------------------------------
-- hs.itunes
-- ------------------------------------------------------------

---@class hs.itunes
hs.itunes = {}

--- Returned by
--- hs.itunes.getPlaybackState()
--- to indicates iTunes is paused
---@type hs.itunes.getPlaybackState
hs.itunes.state_paused = nil

--- Returned by
--- hs.itunes.getPlaybackState()
--- to indicates iTunes is playing
---@type hs.itunes.getPlaybackState
hs.itunes.state_playing = nil

--- Returned by
--- hs.itunes.getPlaybackState()
--- to indicates iTunes is stopped
---@type hs.itunes.getPlaybackState
hs.itunes.state_stopped = nil

--- Displays information for current track on screen
---@return any
function hs.itunes.displayCurrentTrack() end

--- Skips the current playback forwards by 5 seconds
---@return any
function hs.itunes.ff() end

--- Gets the name of the current Album
---@return string|nil
function hs.itunes.getCurrentAlbum() end

--- Gets the name of the current Artist
---@return string|nil
function hs.itunes.getCurrentArtist() end

--- Gets the name of the current track
---@return string|nil
function hs.itunes.getCurrentTrack() end

--- Gets the duration (in seconds) of the current song
---@return number
function hs.itunes.getDuration() end

--- Gets the current playback state of iTunes
---@return hs.itunes.state_stopped|hs.itunes.state_paused|hs.itunes.state_playing
function hs.itunes.getPlaybackState() end

--- Gets the playback position (in seconds) of the current song
---@return number
function hs.itunes.getPosition() end

--- Gets the current iTunes volume setting
---@return number
function hs.itunes.getVolume() end

--- Returns whether iTunes is currently playing
---@return boolean|nil
function hs.itunes.isPlaying() end

--- Returns whether iTunes is currently open. Most other functions in hs.itunes will automatically start the
--- application, so this function can be used to guard against that.
---@return boolean
function hs.itunes.isRunning() end

--- Skips to the next itunes track
---@return any
function hs.itunes.next() end

--- Pauses the current iTunes track
---@return any
function hs.itunes.pause() end

--- Plays the current iTunes track
---@return any
function hs.itunes.play() end

--- Toggles play/pause of current iTunes track
---@return any
function hs.itunes.playpause() end

--- Skips to previous itunes track
---@return any
function hs.itunes.previous() end

--- Skips the current playback backwards by 5 seconds
---@return any
function hs.itunes.rw() end

--- Sets the playback position of the current song
---@param pos number
---@return any
function hs.itunes.setPosition(pos) end

--- Sets the iTunes playback volume
---@param vol number
---@return any
function hs.itunes.setVolume(vol) end

--- Decreases the iTunes playback volume by 5
---@return any
function hs.itunes.volumeDown() end

--- Increases the iTunes playback volume by 5
---@return any
function hs.itunes.volumeUp() end

-- ------------------------------------------------------------
-- hs.json
-- ------------------------------------------------------------

---@class hs.json
hs.json = {}

--- Decodes JSON into a table
---
--- Note: This is useful for retrieving some of the more complex lua table structures as a persistent setting (see
--- hs.settings )
---@param jsonString string
---@return table
function hs.json.decode(jsonString) end

--- Encodes a table as JSON
---
--- Note: This is useful for storing some of the more complex lua table structures as a persistent setting (see
--- hs.settings )
---@param val table
---@param prettyprint? boolean|nil
---@return string
function hs.json.encode(val, prettyprint) end

--- Decodes JSON file into a table.
---@param path string
---@return table|nil
function hs.json.read(path) end

--- Encodes a table as JSON to a file
---@param data table
---@param path string
---@param prettyprint boolean|nil
---@param replace boolean|nil
---@return boolean
function hs.json.write(data, path, prettyprint, replace) end

-- ------------------------------------------------------------
-- hs.keycodes
-- ------------------------------------------------------------

---@class hs.keycodes
hs.keycodes = {}

--- A mapping from string representation of a key to its keycode, and vice versa.
---@type string
hs.keycodes.map = nil

--- Gets the name of the current keyboard layout
---@return string
function hs.keycodes.currentLayout() end

--- Gets the icon of the current keyboard layout
---@return hs.image
function hs.keycodes.currentLayoutIcon() end

--- Get current input method
---@return string
function hs.keycodes.currentMethod() end

--- Get or set the source id for the keyboard input source
---@param sourceID string|nil
---@return string|boolean
function hs.keycodes.currentSourceID(sourceID) end

--- Gets an hs.image object for a given keyboard layout or input method
---
--- Note: Not all layouts/methods have icons, so you should assume this will return nil at some point
---@param sourceName string
---@return hs.image
function hs.keycodes.iconForLayoutOrMethod(sourceName) end

--- Sets the function to be called when your input source (i.e. qwerty, dvorak, colemac) changes.
---
--- Note: This may be helpful for rebinding your hotkeys to appropriate keys in the new layout
--- Setting this will un-set functions previously registered by this function.
---@param fn function
---@return any
function hs.keycodes.inputSourceChanged(fn) end

--- Gets all of the enabled keyboard layouts that the keyboard input source can be switched to
---
--- Note: Only those layouts which can be explicitly switched to will be included in the table.  Keyboard layouts which
--- are part of input methods are not included.  See hs.keycodes.methods .
---@param sourceID boolean|nil
---@return table
function hs.keycodes.layouts(sourceID) end

--- Gets all of the enabled input methods that the keyboard input source can be switched to
---
--- Note: Keyboard layouts which are not part of an input method are not included in this table.  See
--- hs.keycodes.layouts .
---@param sourceID boolean|nil
---@return table
function hs.keycodes.methods(sourceID) end

--- Changes the system keyboard layout
---@param layoutName string
---@return boolean
function hs.keycodes.setLayout(layoutName) end

--- Changes the system input method
---@param methodName string
---@return boolean
function hs.keycodes.setMethod(methodName) end

-- ------------------------------------------------------------
-- hs.layout
-- ------------------------------------------------------------

---@class hs.layout
hs.layout = {}

---@class hs.layout.layout
---@field left25 any A unit rect which will make a window occupy the left 25% of a screen
---@field left30 any A unit rect which will make a window occupy the left 30% of a screen
---@field left50 any A unit rect which will make a window occupy the left 50% of a screen
---@field left70 any A unit rect which will make a window occupy the left 70% of a screen
---@field left75 any A unit rect which will make a window occupy the left 75% of a screen

--- A unit rect which will make a window occupy the left 25% of a screen
---@type any
hs.layout.left25 = nil

--- A unit rect which will make a window occupy the left 30% of a screen
---@type any
hs.layout.left30 = nil

--- A unit rect which will make a window occupy the left 50% of a screen
---@type any
hs.layout.left50 = nil

--- A unit rect which will make a window occupy the left 70% of a screen
---@type any
hs.layout.left70 = nil

--- A unit rect which will make a window occupy the left 75% of a screen
---@type any
hs.layout.left75 = nil

--- A unit rect which will make a window occupy all of a screen
---@type any
hs.layout.maximized = nil

--- A unit rect which will make a window occupy the right 25% of a screen
---@type any
hs.layout.right25 = nil

--- A unit rect which will make a window occupy the right 30% of a screen
---@type any
hs.layout.right30 = nil

--- A unit rect which will make a window occupy the right 50% of a screen
---@type any
hs.layout.right50 = nil

--- A unit rect which will make a window occupy the right 70% of a screen
---@type any
hs.layout.right70 = nil

--- A unit rect which will make a window occupy the right 75% of a screen
---@type any
hs.layout.right75 = nil

--- Applies a layout to applications/windows
---
--- Note: If the application name argument is nil, window titles will be matched regardless of which app they belong to
--- If the window title argument is nil, all windows of the specified application will be matched
--- If the window title argument is a function, the function will be called with the application name argument (which
--- may be nil), and should return a table of hs.window objects (even if there is only one window it must be in a table)
--- You can specify both application name and window title if you want to match only one window of a particular
--- application
--- If you specify neither application name or window title, no windows will be matched :)
--- Monitor name is a string, as found in hs.screen:name() or hs.screen:getUUID() . You can also pass an hs.screen
--- object, or a function that returns an hs.screen object. If you pass nil, the first screen will be selected
--- Unit rect will be passed to hs.window.moveToUnit()
--- Frame rect will be passed to hs.window.setFrame() (including menubar and dock)
--- Full-frame rect will be passed to hs.window.setFrame() (ignoring menubar and dock)
--- If either the x or y components of frame/full-frame rect are negative, they will be applied as offsets against the
--- opposite edge of the screen (e.g. If x is -100 then the left edge of the window will be 100 pixels from the right
--- edge of the screen)
--- Only one of the rect arguments will apply to any matched windows. If you specify more than one, the first will win
--- An example usage: layout1 = { { "Mail" , nil , "Color LCD" , hs . layout . maximized , nil , nil }, { "Safari" ,
--- nil , "Thunderbolt Display" , hs . layout . maximized , nil , nil }, { "iTunes" , "iTunes" , "Color LCD" , hs .
--- layout . maximized , nil , nil }, { "iTunes" , "MiniPlayer" , "Color LCD" , nil , nil , hs . geometry . rect ( 0 ,
--- - 48 , 400 , 48 )}, } ```
--- An example of a function that works well as a windowTitleComparator is the Lua built-in string.match , which uses
--- Lua Patterns to match strings
---@param table any
---@param windowTitleComparator? any
---@return any
function hs.layout.apply(table, windowTitleComparator) end

-- ------------------------------------------------------------
-- hs.location
-- ------------------------------------------------------------

---@class hs.location
hs.location = {}

---@class location
local location = {}

--- Returns a string describing the authorization status of Hammerspoon's use of Location Services.
---
--- Note: The first time you use a function which requires Location Services, you will be prompted to grant Hammerspoon
--- access. If you wish to change this permission after the initial prompt, you may do so from the Location Services
--- section of the Security & Privacy section in the System Preferences application.
---@return string
function hs.location.authorizationStatus() end

--- Measures the distance between two points of latitude and longitude
---
--- Note: This function does not require Location Services to be enabled for Hammerspoon.
---@param from table
---@param to table
---@return meters
function hs.location.distance(from, to) end

--- Returns a number giving the current daylight savings time offset
---
--- Note: This value is derived from the currently configured system timezone, it does not use Location Services
---@return number
function hs.location.dstOffset() end

--- Returns a table representing the current location
---
--- Note: This function activates Location Services for Hammerspoon, so the first time you call this, you may be
--- prompted to authorise Hammerspoon to use Location Services.
--- Internally, the Location Services cache is updated whenever additional WiFi networks are detected or lost (not
--- necessarily joined). When update tracking is enabled with the hs.location.start function, calculations based upon
--- the RSSI of all currently seen networks are preformed more often to provide a more precise fix, but it's still
--- based on the WiFi networks near you.
---@return locationTable|nil
function hs.location.get() end

--- Registers a callback function to be called when the system location is updated
---@param tag string
---@param fn function
---@param distance? function|nil
---@return any
function hs.location.register(tag, fn, distance) end

--- Gets the state of OS X Location Services
---@return boolean
function hs.location.servicesEnabled() end

--- Begins location tracking using OS X's Location Services so that registered callback functions can be invoked as the
--- computer location changes.
---
--- Note: This function activates Location Services for Hammerspoon, so the first time you call this, you may be
--- prompted to authorise Hammerspoon to use Location Services.
---@return boolean
function hs.location.start() end

--- Stops location tracking.  Registered callback functions will cease to receive notification of location changes.
---@return any
function hs.location.stop() end

--- Returns the time of official sunrise for the supplied location
---
--- Note: You can turn the return value into a more useful structure, with os.date("*t", returnvalue)
--- For compatibility with the locationTable object returned by hs.location.get , this function can also be invoked as
--- hs.location.sunrise(locationTable, offset[, date]) .
---@param latitude number
---@param longitude number
---@param offset number
---@param date? table|nil
---@return number|string
function hs.location.sunrise(latitude, longitude, offset, date) end

--- Returns the time of official sunset for the supplied location
---
--- Note: You can turn the return value into a more useful structure, with os.date("*t", returnvalue)
--- For compatibility with the locationTable object returned by hs.location.get , this function can also be invoked as
--- hs.location.sunset(locationTable, offset[, date]) .
---@param latitude number
---@param longitude number
---@param offset number
---@param date? table|nil
---@return number|string
function hs.location.sunset(latitude, longitude, offset, date) end

--- Unregisters a callback
---@param tag string
---@return any
function hs.location.unregister(tag) end

--- Create a new location object which can receive callbacks independent of other Hammerspoon use of Location Services.
---
--- Note: The locationObject created will receive callbacks independent of all other locationObjects and the legacy
--- callback functions created with hs.location.register .  It can also receive callbacks for region changes which are
--- not available through the legacy callback mechanism.
---@return locationObject
function hs.location.new() end

--- Adds a region to be monitored by Location Services
---
--- Note: This method activates Location Services for Hammerspoon, so the first time you call this, you may be prompted
--- to authorise Hammerspoon to use Location Services.
--- If the identifier key is not provided, a new UUID string is generated and used as the identifier.
--- If the identifier key matches an already monitored region, this region will replace the existing one.
---@param regionTable table
---@return locationObject|nil
function location:addMonitoredRegion(regionTable) end

--- Sets or removes the callback function for this locationObject
---@param fn function
---@return locationObject
function location:callback(fn) end

--- Returns the string identifier for the current region
---
--- Note: This method activates Location Services for Hammerspoon, so the first time you call this, you may be prompted
--- to authorise Hammerspoon to use Location Services.
---@return identifier|nil
function location:currentRegion() end

--- Enable callbacks for location changes/refinements for this locationObject
---
--- Note: This function activates Location Services for Hammerspoon, so the first time you call this, you may be
--- prompted to authorise Hammerspoon to use Location Services.
---@param locationTable any
---@return distance|nil
function location:distanceFrom(locationTable) end

--- Returns the current location
---
--- Note: This function activates Location Services for Hammerspoon, so the first time you call this, you may be
--- prompted to authorise Hammerspoon to use Location Services.
--- Internally, the Location Services cache is updated whenever additional WiFi networks are detected or lost (not
--- necessarily joined). When update tracking is enabled with the hs.location.start function, calculations based upon
--- the RSSI of all currently seen networks are preformed more often to provide a more precise fix, but it's still
--- based on the WiFi networks near you.
---@return locationTable|nil
function location:location() end

--- Returns a table containing the regionTables for the regions currently being monitored for this locationObject
---
--- Note: This method activates Location Services for Hammerspoon, so the first time you call this, you may be prompted
--- to authorise Hammerspoon to use Location Services.
---@return table|nil
function location:monitoredRegions() end

--- Removes a monitored region from Location Services
---
--- Note: This method activates Location Services for Hammerspoon, so the first time you call this, you may be prompted
--- to authorise Hammerspoon to use Location Services.
--- If the identifier key is not provided, a new UUID string is generated and used as the identifier.
--- If the identifier key matches an already monitored region, this region will replace the existing one.
---@param identifier string
---@return locationObject|boolean|nil
function location:removeMonitoredRegion(identifier) end

--- Enable callbacks for location changes/refinements for this locationObject
---
--- Note: This function activates Location Services for Hammerspoon, so the first time you call this, you may be
--- prompted to authorise Hammerspoon to use Location Services.
---@return locationObject
function location:startTracking() end

--- Disable callbacks for location changes/refinements for this locationObject
---@return locationObject
function location:stopTracking() end

-- ------------------------------------------------------------
-- hs.location.geocoder
-- ------------------------------------------------------------

---@class hs.location.geocoder
hs.location.geocoder = {}

---@class geocoder
local geocoder = {}

--- Look up geocoding information for the specified address.
---
--- Note: This constructor requires internet access and the callback will be invoked with an error message if the
--- internet is not currently accessible.
--- This constructor does not require Location Services to be enabled for Hammerspoon.
---@param address string
---@param fn function
---@return geocoderObject
function hs.location.geocoder.lookupAddress(address, fn) end

--- Look up geocoding information for the specified address.
---
--- Note: This constructor requires internet access and the callback will be invoked with an error message if the
--- internet is not currently accessible.
--- This constructor does not require Location Services to be enabled for Hammerspoon.
--- While a partial address can be given, the more information you provide, the more likely the results will be useful.
--- The regionTable only determines sort order if multiple entries are returned, it does not constrain the search.
---@param address string
---@param regionTable hs.location|nil
---@param fn function
---@return geocoderObject
function hs.location.geocoder.lookupAddressNear(address, regionTable, fn) end

--- Look up geocoding information for the specified location.
---
--- Note: This constructor requires internet access and the callback will be invoked with an error message if the
--- internet is not currently accessible.
--- This constructor does not require Location Services to be enabled for Hammerspoon.
---@param locationTable hs.location
---@param fn function
---@return geocoderObject
function hs.location.geocoder.lookupLocation(locationTable, fn) end

--- Cancels the pending or in progress geocoding request.
---
--- Note: This method has no effect if the geocoding process has already completed.
---@return nil
function geocoder:cancel() end

--- Returns a boolean indicating whether or not the geocoding process is still active.
---@return boolean
function geocoder:geocoding() end

-- ------------------------------------------------------------
-- hs.logger
-- ------------------------------------------------------------

---@class hs.logger
---@field level number The log level of the logger instance, as a number between 0 and 5
hs.logger = {}

--- Default log level for new logger instances.
---@type any
hs.logger.defaultLogLevel = nil

--- Returns the global log history
---@return list of log entries
function hs.logger.history() end

--- Sets or gets the global log history size
---
--- Note: if you change history size (other than from 0) after creating any logger instances, things will likely break
---@param size number|nil
---@return number
function hs.logger.historySize(size) end

--- Creates a new logger instance
---
--- Note: the logger instance created by this method is not a regular object, but a plain table with "static" functions;
--- therefore, do not use the colon syntax for so-called "methods" in this module (as in mylogger.setLogLevel(3) );
--- you must instead use the regular dot syntax: mylogger.setLogLevel(3)
--- Example:
--- local
--- log
--- =
--- hs
--- .
--- logger
--- .
--- new
--- (
--- 'mymodule'
--- ,
--- 'debug'
--- )
--- log
--- .
--- i
--- (
--- 'Initializing'
--- )
--- -- will print "[mymodule] Initializing" to the console```
---@param id string
---@param loglevel hs.logger.defaultLogLevel|nil
---@return logger
function hs.logger.new(id, loglevel) end

--- Prints the global log history to the console
---@param entries number|nil
---@param level? hs.logger.setLogLevel|nil
---@param filter? function
---@param caseSensitive? any
---@return any
function hs.logger.printHistory(entries, level, filter, caseSensitive) end

--- Sets the log level for all logger instances (including objects' loggers)
---@param lvl any
---@return any
function hs.logger.setGlobalLogLevel(lvl) end

--- Sets the log level for all currently loaded modules
---
--- Note: This function only affects module -level loggers, object instances with their own loggers (e.g.
--- windowfilters) won't be affected;
--- you can use hs.logger.setGlobalLogLevel() for those
---@param lvl any
---@return any
function hs.logger.setModulesLogLevel(lvl) end

--- Logs debug info to the console
---@param ... any
---@return any
function hs.logger.d(...) end

--- Logs formatted debug info to the console
---@param fmt string
---@param ... any
---@return any
function hs.logger.df(fmt, ...) end

--- Logs an error to the console
---@param ... any
---@return any
function hs.logger.e(...) end

--- Logs a formatted error to the console
---@param fmt string
---@param ... any
---@return any
function hs.logger.ef(fmt, ...) end

--- Logs formatted info to the console
---@param fmt string
---@param ... any
---@return any
function hs.logger.f(fmt, ...) end

--- Gets the log level of the logger instance
---@return number
function hs.logger.getLogLevel() end

--- Logs info to the console
---@param ... any
---@return any
function hs.logger.i(...) end

--- Sets the log level of the logger instance
---@param loglevel number
---@return any
function hs.logger.setLogLevel(loglevel) end

--- Logs verbose info to the console
---@param ... any
---@return any
function hs.logger.v(...) end

--- Logs formatted verbose info to the console
---@param fmt string
---@param ... any
---@return any
function hs.logger.vf(fmt, ...) end

--- Logs a warning to the console
---@param ... any
---@return any
function hs.logger.w(...) end

--- Logs a formatted warning to the console
---@param fmt string
---@param ... any
---@return any
function hs.logger.wf(fmt, ...) end

-- ------------------------------------------------------------
-- hs.math
-- ------------------------------------------------------------

---@class hs.math
hs.math = {}

--- Smallest positive floating point number representable in Hammerspoon
---@type table
hs.math.minFloat = nil

--- Returns whether or not the value is a finite number
---
--- Note: This function returns true if the value is a number and both hs.math.isNaN and hs.math.isInfinite return
--- false.
---@param value any
---@return boolean
function hs.math.isFinite(value) end

--- Returns whether or not the value is the mathematical equivalent of either positive or negative "Infinity"
---
--- Note: This function specifically checks if the value is equivalent to positive or negative infinity --- it does not
--- do type checking. If value is not a numeric value (e.g. a string), it cannot be equivalent to positive or negative
--- infinity and will return false.
--- Because lua treats any value other than nil and false as true , the return value of this function can be safely
--- used in conditionals when you don't care about the sign of the infinite value.
---@param value any
---@return 1
---@return -1
---@return boolean
function hs.math.isInfinite(value) end

--- Returns whether or not the value is the mathematical equivalent of "Not-A-Number"
---
--- Note: Mathematical NaN represents an impossible value, usually the result of a calculation, yet is still considered
--- within the domain of mathematics. The most common case is the result of n / 0 as division by 0 is considered
--- undefined or "impossible".
--- This function specifically checks if the value is NaN --- it does not do type checking. If value is not a numeric
--- value (e.g. a string), it cannot be equivalent to NaN and this function will return false.
---@param value any
---@return boolean
function hs.math.isNaN(value) end

--- Returns a random floating point number between 0 and 1
---@return number
function hs.math.randomFloat() end

--- Returns a random integer between the start and end parameters
---@param start number
---@param end number
---@return number
function hs.math.randomFromRange(start, end) end

-- ------------------------------------------------------------
-- hs.menubar
-- ------------------------------------------------------------

---@class hs.menubar
hs.menubar = {}

---@class menubar
local menubar = {}

--- Pre-defined list of image positions for a menubar item
---@type image[]
hs.menubar.imagePositions[] = nil

--- Creates a new menu bar item object and optionally add it to the system menubar
---
--- Note: You should call hs.menubar:setTitle() or hs.menubar:setIcon() after creating the object, otherwise it will be
--- invisible
--- Calling this method with inMenuBar equal to false is equivalent to calling hs.menubar.new():removeFromMenuBar().
--- A hidden menubaritem can be added to the system menubar by calling hs.menubar:returnToMenuBar() or used as a pop-up
--- menu by calling hs.menubar:popupMenu().
---@param inMenuBar any
---@param autosaveName string
---@return hs.menubar|nil
function hs.menubar.new(inMenuBar, autosaveName) end

--- Get or set the autosave name of the menubar. By defining an autosave name, macOS can restore the menubar position
--- after reloads.
---@param name string|nil
---@return hs.menubar|current-
function menubar:autosaveName(name) end

--- Removes the menubar item from the menubar and destroys it
---@return any
function menubar:delete() end

--- Returns the menubar item frame
---
--- Note: This will return a frame even if no icon or title is set
---@return hs.geometry rect
function menubar:frame() end

--- Returns the current icon of the menubar item object.
---@return hs.image
function menubar:icon() end

--- Get or set the position of a menubar image relative to its text title
---@param position hs.menubar.imagePositions
---@return hs.menubar|current-
function menubar:imagePosition(position) end

--- Returns a boolean indicating whether or not the specified menu is currently in the OS X menubar.
---@return boolean
function menubar:isInMenuBar() end

--- Display a menubaritem as a pop up menu at the specified screen point.
---
--- Note: Items which trigger hs.menubar:setClickCallback() will invoke the callback function, but we cannot control
--- the positioning of any visual elements the function may create -- calling this method on such an object is the
--- equivalent of invoking its callback function directly.
--- This method is blocking. Hammerspoon will be unable to respond to any other activity while the pop-up menu is being
--- displayed.
--- darkMode uses an undocumented macOS API call, so may break in a future release.
---@param point any
---@param darkMode? any
---@return hs.menubar
function menubar:popupMenu(point, darkMode) end

--- Removes a menu from the system menu bar.  The item can still be used as a pop-up menu, unless you also delete it.
---@return hs.menubar
function menubar:removeFromMenuBar() end

--- Returns a previously removed menu back to the system menu bar.
---@return hs.menubar
function menubar:returnToMenuBar() end

--- Registers a function to be called when the menubar item is clicked
---
--- Note: If a menu has been attached to the menubar item, this callback will never be called
--- Has no affect on the display of a pop-up menu, but changes will be be in effect if hs.menubar:returnToMenuBar() is
--- called on the menubaritem.
---@param fn function
---@return hs.menubar
function menubar:setClickCallback(fn) end

--- Sets the image of a menubar item object. The image will be displayed in the system menubar
---
--- Note: This method used to return true on success -- this has been changed to return the menubaritem on success to
--- facilitate method chaining.  Since Lua treats any value which is not nil or false as "true", this should only
--- affect code where the return value was actually being compared to true, e.g. if result == true then... rather than
--- the (unaffected) if result then... .
--- If you set a title as well as an icon, they will both be displayed next to each other
--- Has no affect on the display of a pop-up menu, but changes will be be in effect if hs.menubar:returnToMenuBar() is
--- called on the menubaritem.
--- Icons should be small, transparent images that roughly match the size of normal menubar icons, otherwise they will
--- look very strange. Note that if you're using an hs.image image object as the icon, you can force it to be resized
--- with hs.image:setSize({w=16,h=16})
--- Retina scaling is supported if the image is either scalable (e.g. a PDF produced by Adobe Illustrator) or contain
--- multiple sizes (e.g. a TIFF with small and large images). Images will not automatically do the right thing if you
--- have a @2x version present
--- Icons are by default specified as "templates", which allows them to automatically support OS X 10.10's Dark Mode,
--- but this also means they cannot be complicated, colour images.
--- For examples of images that work well, see Hammerspoon.app/Contents/Resources/statusicon.tiff (for a retina-capable
--- multi-image TIFF icon) or https://github.com/jigish/slate/blob/master/Slate/status.pdf (for a scalable vector PDF
--- icon)
--- For guidelines on the sizing of images, see http://alastairs-place.net/blog/2013/07/23/nsstatusitem-what-size-should-your-icon-be/
---@param imageData any
---@param template? boolean|nil
---@return hs.menubar|nil
function menubar:setIcon(imageData, template) end

--- Attaches a dropdown menu to the menubar item
---
--- Note: If you are using the callback function, you should take care not to take too long to generate the menu, as
--- you will block the process and the OS may decide to remove the menubar item
---@param menuTable any
---@return hs.menubar
function menubar:setMenu(menuTable) end

--- Sets the title of a menubar item object. The title will be displayed in the system menubar
---
--- Note: If you set an icon as well as a title, they will both be displayed next to each other
--- Has no affect on the display of a pop-up menu, but changes will be be in effect if hs.menubar:returnToMenuBar() is
--- called on the menubaritem.
---@param title string|nil
---@return hs.menubar
function menubar:setTitle(title) end

--- Sets the tooltip text on a menubar item
---
--- Note: Has no affect on the display of a pop-up menu, but changes will be be in effect if
--- hs.menubar:returnToMenuBar() is called on the menubaritem.
---@param tooltip string
---@return hs.menubar
function menubar:setTooltip(tooltip) end

--- Get or set the size for state images when the menu is displayed.
---
--- Note: An image is used rather than a checkmark or dash only when you set them with the onStateImage , offStateImage
--- , or mixedStateImage keys.  If you are not using these keys, then this method will have no visible effect on the
--- menu's rendering.  See hs.menubar:setMenu for more information.
--- If you are setting the menu contents with a static table, you should invoke this method before invoking
--- hs.menubar:setMenu , as changes will only go into effect when the table is next converted to a menu structure.
---@param size number
---@return hs.image
function menubar:stateImageSize(size) end

--- Returns the current title of the menubar item object.
---@param styled boolean|nil
---@return string|styledtextObject
function menubar:title(styled) end

-- ------------------------------------------------------------
-- hs.messages
-- ------------------------------------------------------------

---@class hs.messages
hs.messages = {}

--- Sends an iMessage
---@param targetAddress string
---@param message string
---@return any
function hs.messages.iMessage(targetAddress, message) end

--- Sends an SMS using SMS Relay
---@param targetNumber string
---@param message string
---@return any
function hs.messages.SMS(targetNumber, message) end

-- ------------------------------------------------------------
-- hs.midi
-- ------------------------------------------------------------

---@class hs.midi
hs.midi = {}

---@class midi
local midi = {}

--- A table containing the numeric value for the possible flags returned by the
--- commandType
--- parameter of the callback function.
---@type table
hs.midi.commandTypes[] = nil

--- A callback that's triggered when a physical or virtual MIDI device is added or removed from the system.
---
--- Note: devices - A table containing the names of any physically connected MIDI devices as strings.
--- virtualDevices - A table containing the names of any virtual MIDI devices as strings.
--- Example Usage: hs . midi . deviceCallback ( function ( devices , virtualDevices ) print ( hs . inspect ( devices ))
--- print ( hs . inspect ( virtualDevices )) end ) ```
---@param callbackFn function
---@return none
function hs.midi.deviceCallback(callbackFn) end

--- Returns a table of currently connected physical MIDI devices.
---@return table
function hs.midi.devices() end

--- Returns a table of currently available Virtual MIDI sources. This includes devices, such as Native Instruments
--- controllers which present as virtual endpoints rather than physical devices.
---@return table
function hs.midi.virtualSources() end

--- Creates a new
--- hs.midi
--- object.
---
--- Note: Example Usage: hs.midi.new(hs.midi.devices()[1])
---@param deviceName string
---@return hs.midi|nil
function hs.midi.new(deviceName) end

--- Creates a new
--- hs.midi
--- object.
---
--- Note: Example Usage: hs.midi.newVirtualSource(hs.midi.virtualSources()[1])
---@param virtualSource string
---@return hs.midi|nil
function hs.midi.newVirtualSource(virtualSource) end

--- Sets or removes a callback function for the
--- hs.midi
--- object.
---
--- Note: Most MIDI keyboards produce a noteOn when you press a key, then noteOff when you release. However, some MIDI
--- keyboards will return a noteOn with 0 velocity instead of noteOff , so you will receive two noteOn commands for
--- every key press/release.
--- object - The hs.midi object.
--- deviceName - The device name as a string.
--- commandType - Type of MIDI message as defined as a string. See hs.midi.commandTypes[] for a list of possibilities.
--- description - Description of the event as a string. This is only really useful for debugging.
--- metadata - A table of data for the MIDI command (see below).
--- note                - The note number for the command. Must be between 0 and 127.
--- velocity            - The velocity for the command. Must be between 0 and 127.
--- channel             - The channel for the command. Must be a number between 15.
--- timestamp           - The timestamp for the command as a string.
--- data                - Raw MIDI Data as Hex String.
--- isVirtual           - true if Virtual MIDI Source otherwise false .
--- note                - The note number for the command. Must be between 0 and 127.
--- velocity            - The velocity for the command. Must be between 0 and 127.
--- channel             - The channel for the command. Must be a number between 15.
--- timestamp           - The timestamp for the command as a string.
--- data                - Raw MIDI Data as Hex String.
--- isVirtual           - true if Virtual MIDI Source otherwise false .
--- note                - The note number for the command. Must be between 0 and 127.
--- pressure            - Key pressure of the polyphonic key pressure message. In the range 0-127.
--- channel             - The channel for the command. Must be a number between 15.
--- timestamp           - The timestamp for the command as a string.
--- data                - Raw MIDI Data as Hex String.
--- isVirtual           - true if Virtual MIDI Source otherwise false .
--- controllerNumber    - The MIDI control number for the command.
--- controllerValue     - The controllerValue of the command. Only the lower 7-bits of this are used.
--- channel             - The channel for the command. Must be a number between 15.
--- timestamp           - The timestamp for the command as a string.
--- data                - Raw MIDI Data as Hex String.
--- fourteenBitValue    - The 14-bit value of the command.
--- fourteenBitCommand  - true if the command contains 14-bit value data otherwise, false .
--- isVirtual           - true if Virtual MIDI Source otherwise false .
--- programNumber       - The program (aka patch) number. From 0-127.
--- channel             - The channel for the command. Must be a number between 15.
--- timestamp           - The timestamp for the command as a string.
--- data                - Raw MIDI Data as Hex String.
--- isVirtual           - true if Virtual MIDI Source otherwise false .
--- pressure            - Key pressure of the channel pressure message. In the range 0-127.
--- channel             - The channel for the command. Must be a number between 15.
--- timestamp           - The timestamp for the command as a string.
--- data                - Raw MIDI Data as Hex String.
--- isVirtual           - true if Virtual MIDI Source otherwise false .
--- pitchChange         -  A 14-bit value indicating the pitch bend. Center is 0x2000 (8192). Valid range is from
--- 0-16383.
--- channel             - The channel for the command. Must be a number between 15.
--- timestamp           - The timestamp for the command as a string.
--- data                - Raw MIDI Data as Hex String.
--- isVirtual           - true if Virtual MIDI Source otherwise false .
--- dataByte1           - Data Byte 1 as integer.
--- dataByte2           - Data Byte 2 as integer.
--- timestamp           - The timestamp for the command as a string.
--- data                - Raw MIDI Data as Hex String.
--- isVirtual           - true if Virtual MIDI Source otherwise false .
--- manufacturerID      - The manufacturer ID for the command. This is used by devices to determine if the message is
--- one they support.
--- sysexChannel        - The channel of the message. Only valid for universal exclusive messages, will always be 0 for
--- non-universal messages.
--- sysexData           - The system exclusive data for the message. For universal messages subID's are included in
--- sysexData, for non-universal messages, any device specific information (such as modelID, versionID or whatever
--- manufactures decide to include) will be included in sysexData.
--- timestamp           - The timestamp for the command as a string.
--- data                - Raw MIDI Data as Hex String.
--- isVirtual           - true if Virtual MIDI Source otherwise false .
--- dataByte1           - Data Byte 1 as integer.
--- dataByte2           - Data Byte 2 as integer.
--- timestamp           - The timestamp for the command as a string.
--- data                - Raw MIDI Data as Hex String.
--- isVirtual           - true if Virtual MIDI Source otherwise false .
--- dataByte1           - Data Byte 1 as integer.
--- dataByte2           - Data Byte 2 as integer.
--- timestamp           - The timestamp for the command as a string.
--- data                - Raw MIDI Data as Hex String.
--- isVirtual           - true if Virtual MIDI Source otherwise false .
--- dataByte1           - Data Byte 1 as integer.
--- dataByte2           - Data Byte 2 as integer.
--- timestamp           - The timestamp for the command as a string.
--- data                - Raw MIDI Data as Hex String.
--- isVirtual           - true if Virtual MIDI Source otherwise false .
--- dataByte1           - Data Byte 1 as integer.
--- dataByte2           - Data Byte 2 as integer.
--- timestamp           - The timestamp for the command as a string.
--- data                - Raw MIDI Data as Hex String.
--- isVirtual           - true if Virtual MIDI Source otherwise false .
--- dataByte1           - Data Byte 1 as integer.
--- dataByte2           - Data Byte 2 as integer.
--- timestamp           - The timestamp for the command as a string.
--- data                - Raw MIDI Data as Hex String.
--- isVirtual           - true if Virtual MIDI Source otherwise false .
--- dataByte1           - Data Byte 1 as integer.
--- dataByte2           - Data Byte 2 as integer.
--- timestamp           - The timestamp for the command as a string.
--- data                - Raw MIDI Data as Hex String.
--- isVirtual           - true if Virtual MIDI Source otherwise false .
--- dataByte1           - Data Byte 1 as integer.
--- dataByte2           - Data Byte 2 as integer.
--- timestamp           - The timestamp for the command as a string.
--- data                - Raw MIDI Data as Hex String.
--- isVirtual           - true if Virtual MIDI Source otherwise false .
--- dataByte1           - Data Byte 1 as integer.
--- dataByte2           - Data Byte 2 as integer.
--- timestamp           - The timestamp for the command as a string.
--- data                - Raw MIDI Data as Hex String.
--- isVirtual           - true if Virtual MIDI Source otherwise false .
--- dataByte1           - Data Byte 1 as integer.
--- dataByte2           - Data Byte 2 as integer.
--- timestamp           - The timestamp for the command as a string.
--- data                - Raw MIDI Data as Hex String.
--- isVirtual           - true if Virtual MIDI Source otherwise false .
--- Example Usage: midiDevice = hs . midi . new ( hs . midi . devices ()[ 3 ]) midiDevice : callback ( function (
--- object , deviceName , commandType , description , metadata ) print ( "object: " .. tostring ( object )) print (
--- "deviceName: " .. deviceName ) print ( "commandType: " .. commandType ) print ( "description: " .. description )
--- print ( "metadata: " .. hs . inspect ( metadata )) end ) ```
---@param callbackFn function
---@return hs.midi
function midi:callback(callbackFn) end

--- Returns the display name of a
--- hs.midi
--- object.
---@return string
function midi:displayName() end

--- Sends an Identity Request message to the
--- hs.midi
--- device. You can use
--- hs.midi:callback()
--- to receive the
--- systemExclusive
--- response.
---
--- Note: Example Usage:
--- midiDevice
--- =
--- hs
--- .
--- midi
--- .
--- new
--- (
--- hs
--- .
--- midi
--- .
--- devices
--- ()[
--- 3
--- ])
--- midiDevice
--- :
--- callback
--- (
--- function
--- (
--- object
--- ,
--- deviceName
--- ,
--- commandType
--- ,
--- description
--- ,
--- metadata
--- )
--- print
--- (
--- "object: "
--- ..
--- tostring
--- (
--- object
--- ))
--- print
--- (
--- "deviceName: "
--- ..
--- deviceName
--- )
--- print
--- (
--- "commandType: "
--- ..
--- commandType
--- )
--- print
--- (
--- "description: "
--- ..
--- description
--- )
--- print
--- (
--- "metadata: "
--- ..
--- hs
--- .
--- inspect
--- (
--- metadata
--- ))
--- end
--- )
--- midiDevice
--- :
--- identityRequest
--- ()
--- ```
---@return none
function midi:identityRequest() end

--- Returns the online status of a
--- hs.midi
--- object.
---@return boolean
function midi:isOnline() end

--- Returns
--- true
--- if an
--- hs.midi
--- object is virtual, otherwise
--- false
--- .
---@return boolean
function midi:isVirtual() end

--- Returns the manufacturer name of a
--- hs.midi
--- object.
---@return string
function midi:manufacturer() end

--- Returns the model name of a
--- hs.midi
--- object.
---@return string
function midi:model() end

--- Returns the name of a
--- hs.midi
--- object.
---@return string
function midi:name() end

--- Sends a command to the
--- hs.midi
--- object.
---
--- Note: note                - The note number for the command. Must be between 0 and 127. Defaults to 0.
--- velocity            - The velocity for the command. Must be between 0 and 127. Defaults to 0.
--- channel             - The channel for the command. Must be a number between 0 and 16. Defaults to 0, which sends
--- the command to All Channels.
--- note                - The note number for the command. Must be between 0 and 127. Defaults to 0.
--- velocity            - The velocity for the command. Must be between 0 and 127. Defaults to 0.
--- channel             - The channel for the command. Must be a number between 0 and 16. Defaults to 0, which sends
--- the command to All Channels.
--- note                - The note number for the command. Must be between 0 and 127. Defaults to 0.
--- pressure            - Key pressure of the polyphonic key pressure message. In the range 0-127. Defaults to 0.
--- channel             - The channel for the command. Must be a number between 0 and 16. Defaults to 0, which sends
--- the command to All Channels.
--- controllerNumber    - The MIDI control number for the command. Defaults to 0.
--- controllerValue     - The controllerValue of the command. Only the lower 7-bits of this are used. Defaults to 0.
--- channel             - The channel for the command. Must be a number between 0 and 16. Defaults to 0, which sends
--- the command to All Channels.
--- fourteenBitValue    - The 14-bit value of the command. Must be between 0 and 16383. Defaults to 0.
--- fourteenBitCommand must be true .
--- fourteenBitCommand  - true if the command contains 14-bit value data otherwise, false . controllerValue will be
--- ignored if this is set to true .
--- programNumber       - The program (aka patch) number. From 0-127. Defaults to 0.
--- channel             - The channel for the command. Must be a number between 0 and 16. Defaults to 0, which sends
--- the command to All Channels.
--- pressure            - Key pressure of the channel pressure message. In the range 0-127. Defaults to 0.
--- channel             - The channel for the command. Must be a number between 0 and 16. Defaults to 0, which sends
--- the command to All Channels.
--- pitchChange         -  A 14-bit value indicating the pitch bend. Center is 0x2000 (8192). Valid range is from
--- 0-16383. Defaults to 0.
--- channel             - The channel for the command. Must be a number between 0 and 16. Defaults to 0, which sends
--- the command to All Channels.
--- Example Usage: midiDevice = hs . midi . new ( hs . midi . devices ()[ 1 ]) midiDevice : sendCommand ( "noteOn" , {
--- [ "note" ] = 72 , [ "velocity" ] = 50 , [ "channel" ] = 0 , }) hs . timer . usleep ( 500000 ) midiDevice :
--- sendCommand ( "noteOn" , { [ "note" ] = 74 , [ "velocity" ] = 50 , [ "channel" ] = 0 , }) hs . timer . usleep (
--- 500000 ) midiDevice : sendCommand ( "noteOn" , { [ "note" ] = 76 , [ "velocity" ] = 50 , [ "channel" ] = 0 , })
--- midiDevice : sendCommand ( "pitchWheelChange" , { [ "pitchChange" ] = 1000 , [ "channel" ] = 0 , }) hs . timer .
--- usleep ( 100000 ) midiDevice : sendCommand ( "pitchWheelChange" , { [ "pitchChange" ] = 2000 , [ "channel" ] = 0 ,
--- }) hs . timer . usleep ( 100000 ) midiDevice : sendCommand ( "pitchWheelChange" , { [ "pitchChange" ] = 3000 , [
--- "channel" ] = 0 , }) ```
---@param commandType hs.midi.commandTypes
---@param metadata table
---@return boolean
function midi:sendCommand(commandType, metadata) end

--- Sends a System Exclusive Command to the
--- hs.midi
--- object.
---
--- Note: Example Usage: midiDevice : sendSysex ( "f07e7f06 01f7" ) ```
---@param command string
---@return none
function midi:sendSysex(command) end

--- Set or display whether or not the MIDI device should synthesize audio on your computer.
---@param value any
---@return boolean
function midi:synthesize(value) end

-- ------------------------------------------------------------
-- hs.milight
-- ------------------------------------------------------------

---@class hs.milight
hs.milight = {}

---@class milight
local milight = {}

--- Specifies the maximum brightness value that can be used. Defaults to 25
---@type any
hs.milight.maxBrightness = nil

--- Specifies the minimum brightness value that can be used. Defaults to 0
---@type any
hs.milight.minBrightness = nil

--- Creates a new bridge object, which will be connected to the supplied IP address and port
---
--- Note: You can not use 255.255.255.255 as the IP address, to do so requires elevated privileges for the Hammerspoon
--- process
---@param ip string
---@param port? number|nil
---@return bridge
function hs.milight.new(ip, port) end

--- Deletes an
--- hs.milight
--- object
---@return any
function milight:delete() end

--- Cycles through the disco modes
---@return boolean
function milight:disco() end

--- Sends a command to the bridge
---
--- Note: This is a low level command, you typically should use a specific method for the operation you want to perform
---@param cmd hs.milight.cmd
---@param value? any
---@return boolean
function milight:send(cmd, value) end

--- Sets brightness for the specified zone
---@param zone number
---@param value number
---@return number
function milight:zoneBrightness(zone, value) end

--- Sets RGB color for the specified zone
---
--- Note: The color value is not a normal RGB colour, but rather a lookup in an internal table in the light hardware.
--- While any number between 0 and 255 is valid, there are some useful values worth knowing:
--- 00 - Violet
--- 16 - Royal Blue
--- 32 - Baby Blue
--- 48 - Aqua
--- 64 - Mint Green
--- 80 - Seafoam Green
--- 96 - Green
--- 112 - Lime Green
--- 128 - Yellow
--- 144 - Yellowy Orange
--- 160 - Orange
--- 176 - Red
--- 194 - Pink
--- 210 - Fuchsia
--- 226 - Lilac
--- 240 - Lavender
---@param zone number
---@param value number
---@return boolean
function milight:zoneColor(zone, value) end

--- Turns off the specified zone
---@param zone number
---@return boolean
function milight:zoneOff(zone) end

--- Turns on the specified zone
---@param zone number
---@return boolean
function milight:zoneOn(zone) end

--- Sets the specified zone to white
---@param zone number
---@return boolean
function milight:zoneWhite(zone) end

-- ------------------------------------------------------------
-- hs.mjomatic
-- ------------------------------------------------------------

---@class hs.mjomatic
hs.mjomatic = {}

--- Applies a configuration to the currently open windows
---
--- Note: An example use:
--- mjomatic
--- .
--- go
--- ({
--- "CCCCCCCCCCCCCiiiiiiiiiii      # <-- The windowgram, it defines the shapes and positions of windows"
--- ,
--- "CCCCCCCCCCCCCiiiiiiiiiii"
--- ,
--- "SSSSSSSSSSSSSiiiiiiiiiii"
--- ,
--- "SSSSSSSSSSSSSYYYYYYYYYYY"
--- ,
--- "SSSSSSSSSSSSSYYYYYYYYYYY"
--- ,
--- ""
--- ,
--- "C Google Chrome            # <-- window C has application():title() 'Google Chrome'"
--- ,
--- "i iTerm"
--- ,
--- "Y YoruFukurou"
--- ,
--- "S Sublime Text 2"
--- })
---@param cfg table
---@return any
function hs.mjomatic.go(cfg) end

-- ------------------------------------------------------------
-- hs.mouse
-- ------------------------------------------------------------

---@class hs.mouse
hs.mouse = {}

--- Get or set the absolute co-ordinates of the mouse pointer
---
--- Note: If no parameters are supplied, the current position will be returned. If a point table parameter is supplied,
--- the mouse pointer position will be set and the new co-ordinates returned
---@param point any
---@return point
function hs.mouse.absolutePosition(point) end

--- Gets the total number of mice connected to your system.
---
--- Note: This function leverages code from ManyMouse .
--- This function considers any mouse labelled as "Apple Internal Keyboard / Trackpad" to be an internal mouse.
---@param includeInternal boolean
---@return number
function hs.mouse.count(includeInternal) end

--- Gets the identifier of the current mouse cursor type.
---
--- Note: Possible values include: arrowCursor, contextualMenuCursor, closedHandCursor, crosshairCursor,
--- disappearingItemCursor, dragCopyCursor, dragLinkCursor, IBeamCursor, operationNotAllowedCursor, pointingHandCursor,
--- resizeDownCursor, resizeLeftCursor, resizeLeftRightCursor, resizeRightCursor, resizeUpCursor, resizeUpDownCursor,
--- IBeamCursorForVerticalLayout or unknown if the cursor type cannot be determined.
--- This function can also return daVinciResolveHorizontalArrows, when hovering over mouse-draggable text-boxes in
--- DaVinci Resolve. This is determined using the "hotspot" value of the cursor.
---@return string
function hs.mouse.currentCursorType() end

--- Returns a table containing the current mouse buttons being pressed
--- at this instant
--- .
---
--- Note: This function is a wrapper to hs.eventtap.checkMouseButtons
--- This is an instantaneous poll of the current mouse buttons, not a callback.
---@return table
function hs.mouse.getButtons() end

--- Gets the screen the mouse pointer is on
---@return screen|nil
function hs.mouse.getCurrentScreen() end

--- Gets the co-ordinates of the mouse pointer, relative to the screen it is on
---
--- Note: The co-ordinates returned by this function are relative to the top left pixel of the screen the mouse is on
--- (see hs.mouse.getAbsolutePosition if you need the location in the full desktop space)
---@return point|nil
function hs.mouse.getRelativePosition() end

--- Gets the names of any mice connected to the system.
---
--- Note: This function leverages code from ManyMouse .
---@return table
function hs.mouse.names() end

--- Gets the system-wide direction of scrolling
---@return string
function hs.mouse.scrollDirection() end

--- Sets the co-ordinates of the mouse pointer, relative to a screen
---@param point table
---@param screen? hs.screen|nil
---@return any
function hs.mouse.setRelativePosition(point, screen) end

--- Gets/Sets the current system mouse tracking speed setting
---
--- Note: This is represented in the System Preferences as the "Tracking speed" setting for mice
--- 0.0, 0.125, 0.5, 0.6875, 0.875, 1.0, 1.5, 2.0, 2.5, 3.0
--- Note that changes to this value will not be noticed immediately by macOS
---@param speed number|nil
---@return number
function hs.mouse.trackingSpeed(speed) end

-- ------------------------------------------------------------
-- hs.network
-- ------------------------------------------------------------

---@class hs.network
hs.network = {}

--- Returns a list of the IPv4 and IPv6 addresses for the specified interfaces, or all interfaces if no arguments are
--- given.
---
--- Note: The order of the IP addresses returned is undefined.
--- If no arguments are provided, then this function returns the same results as hs.host.addresses , but does not block.
---@param interface_list table
---@return table
function hs.network.addresses(interface_list) end

--- Returns details about the specified interface or the primary interface if no interface is specified.
---
--- Note: When determining the primary interface, the favorIPv6 flag only determines interface search order.  If you
--- specify true for this flag, but no primary IPv6 interface exists (i.e. your DHCP server only provides an IPv4
--- address an IPv6 is limited to local only traffic), then the primary IPv4 interface will be used instead.
---@param interface | favorIPv6 any
---@return table
function hs.network.interfaceDetails(interface | favorIPv6) end

--- Returns the user defined name for the specified interface or the primary interface if no interface is specified.
---
--- Note: Only interfaces which show up in the System Preferences Network panel will have a user defined name.
--- When determining the primary interface, the favorIPv6 flag only determines interface search order.  If you specify
--- true for this flag, but no primary IPv6 interface exists (i.e. your DHCP server only provides an IPv4 address an
--- IPv6 is limited to local only traffic), then the primary IPv4 interface will be used instead.
---@param interface | favorIPv6 any
---@return string
function hs.network.interfaceName(interface | favorIPv6) end

--- Returns a list of interfaces currently active for the system.
---
--- Note: The names of the interfaces returned by this function correspond to the interface's BSD name, not the user
--- defined name that shows up in the System Preferences's Network panel.
--- This function returns all interfaces, even ones used by the system that are not directly manageable by the user.
---@return table
function hs.network.interfaces() end

--- Returns the names of the primary IPv4 and IPv6 interfaces.
---
--- Note: The IPv4 and IPv6 interface names are often, but not always, the same.
---@return ipv4Interface
---@return ipv6Interface
function hs.network.primaryInterfaces() end

-- ------------------------------------------------------------
-- hs.network.configuration
-- ------------------------------------------------------------

---@class hs.network.configuration
hs.network.configuration = {}

---@class configuration
local configuration = {}

--- Opens a session to the dynamic store maintained by the System Configuration server.
---@return storeObject
function hs.network.configuration.open() end

--- Returns the name of the computer as specified in the Sharing Preferences, and its string encoding
---
--- Note: You can also retrieve this information as key-value pairs with hs.network.configuration:contents("Setup:/System")
---@return name
---@return encoding
function configuration:computerName() end

--- Returns the name of the user currently logged into the system, including the users id and primary group id
---
--- Note: You can also retrieve this information as key-value pairs with hs.network.configuration:contents("State:/Users/ConsoleUser")
---@return name
---@return uid
---@return gid
function configuration:consoleUser() end

--- Return the contents of the store for the specified keys or keys matching the specified pattern(s)
---
--- Note: if no parameters are provided, then all key-value pairs in the dynamic store are returned.
---@param keys string
---@param pattern boolean
---@return table
function configuration:contents(keys, pattern) end

--- Return the DHCP information for the specified service or the primary service if no parameter is specified.
---
--- Note: a list of possible Service ID's can be retrieved with hs.network.configuration:contents("Setup:/Network/Global/IPv4")
--- generates an error if the service ID is invalid or was not assigned an IP address via DHCP.
---@param serviceID string|nil
---@return table
function configuration:dhcpInfo(serviceID) end

--- Returns the current local host name for the computer
---
--- Note: You can also retrieve this information as key-value pairs with hs.network.configuration:contents("Setup:/System")
---@return name
function configuration:hostname() end

--- Return the keys in the dynamic store which match the specified pattern
---@param keypattern string
---@return table
function configuration:keys(keypattern) end

--- Returns the current location identifier
---
--- Note: You can also retrieve this information as key-value pairs with hs.network.configuration:contents("Setup:")
--- If you have different locations defined in the Network preferences panel, this can be used to determine the
--- currently active location.
---@return location
function configuration:location() end

--- Returns all configured locations
---@return table
function configuration:locations() end

--- Specify the key(s) or key pattern(s) to monitor for changes.
---
--- Note: if no parameters are provided, then all key-value pairs in the dynamic store are monitored for changes.
---@param keys string
---@param pattern boolean
---@return storeObject
function configuration:monitorKeys(keys, pattern) end

--- Returns information about the currently active proxies, if any
---
--- Note: You can also retrieve this information as key-value pairs with hs.network.configuration:contents("State:/Network/Global/Proxies")
---@return table
function configuration:proxies() end

--- Set or remove the callback function for a store object
---
--- Note: The callback function will be invoked each time a monitored key changes value and the callback function
--- should accept two parameters: the storeObject itself, and an array of the keys which contain values that have
--- changed.
--- This method just sets the callback function.  You specify which keys to watch with
--- hs.network.configuration:monitorKeys and start or stop the watcher with hs.network.configuration:start or
--- hs.network.configuration:stop
---@param function any
---@return storeObject
function configuration:setCallback(function) end

--- Switches to a new location
---@param location string
---@return boolean
function configuration:setLocation(location) end

--- Starts watching the store object for changes to the monitored keys and invokes the callback function (if any) when
--- a change occurs.
---
--- Note: The callback function should be specified with hs.network.configuration:setCallback and the keys to monitor
--- should be specified with hs.network.configuration:monitorKeys .
---@return storeObject
function configuration:start() end

--- Stops watching the store object for changes.
---@return storeObject
function configuration:stop() end

-- ------------------------------------------------------------
-- hs.network.host
-- ------------------------------------------------------------

---@class hs.network.host
hs.network.host = {}

---@class host
local host = {}

--- Get IP addresses for the hostname specified.
---
--- Note: If no callback function is provided, the resolution occurs in a blocking manner which may be noticeable when
--- network access is slow or erratic.
--- If a callback function is provided, this function acts as a constructor, returning a host object and the callback
--- function will be invoked when resolution is complete.  The callback function should take two parameters: the string
--- "addresses", indicating that an address resolution occurred, and a table containing the IP addresses identified.
--- Generates an error if network access is currently disabled or the hostname is invalid.
---@param name string
---@param fn? function|nil
---@return table|hostObject
function hs.network.host.addressesForHostname(name, fn) end

--- Get hostnames for the IP address specified.
---
--- Note: If no callback function is provided, the resolution occurs in a blocking manner which may be noticeable when
--- network access is slow or erratic.
--- If a callback function is provided, this function acts as a constructor, returning a host object and the callback
--- function will be invoked when resolution is complete.  The callback function should take two parameters: the string
--- "names", indicating that hostname resolution occurred, and a table containing the hostnames identified.
--- Generates an error if network access is currently disabled or the IP address is invalid.
---@param address string
---@param fn? function|nil
---@return table|hostObject
function hs.network.host.hostnamesForAddress(address, fn) end

--- Get the reachability status for the IP address specified.
---
--- Note: If no callback function is provided, the resolution occurs in a blocking manner which may be noticeable when
--- network access is slow or erratic.
--- If a callback function is provided, this function acts as a constructor, returning a host object and the callback
--- function will be invoked when resolution is complete.  The callback function should take two parameters: the string
--- "reachability", indicating that reachability was determined, and the numeric representation of the address
--- reachability status.
--- Generates an error if network access is currently disabled or the IP address is invalid.
--- The numeric representation is made up from a combination of the flags defined in hs.network.reachability.flags .
--- Performs the same reachability test as hs.network.reachability.forAddress .
---@param address string
---@param fn? function|nil
---@return number|hostObject
function hs.network.host.reachabilityForAddress(address, fn) end

--- Get the reachability status for the IP address specified.
---
--- Note: If no callback function is provided, the resolution occurs in a blocking manner which may be noticeable when
--- network access is slow or erratic.
--- If a callback function is provided, this function acts as a constructor, returning a host object and the callback
--- function will be invoked when resolution is complete.  The callback function should take two parameters: the string
--- "reachability", indicating that reachability was determined, and the numeric representation of the hostname
--- reachability status.
--- Generates an error if network access is currently disabled or the IP address is invalid.
--- The numeric representation is made up from a combination of the flags defined in hs.network.reachability.flags .
--- Performs the same reachability test as hs.network.reachability.forHostName .
---@param name number
---@param fn? function|nil
---@return number|hostObject
function hs.network.host.reachabilityForHostname(name, fn) end

--- Cancels an in-progress asynchronous host resolution.
---
--- Note: This method has no effect if the resolution has already completed.
---@return hostObject
function host:cancel() end

--- Returns whether or not resolution is still in progress for an asynchronous query.
---@return boolean
function host:isRunning() end

-- ------------------------------------------------------------
-- hs.network.ping
-- ------------------------------------------------------------

---@class hs.network.ping
hs.network.ping = {}

---@class ping
local ping = {}

--- Test server availability by pinging it with ICMP Echo Requests.
---
--- Note: For convenience, you can call this constructor as hs.network.ping(server, ...)
--- the full ping process will take at most count * interval + timeout seconds from didStart to didFinish .
--- the default callback function, if fn is not specified, prints the results of each echo reply as they are received
--- to the Hammerspoon console and a summary once completed. The output should be familiar to anyone who has used ping
--- from the command line.
--- object - the ping object the callback is for
--- message - the message to the callback, in this case "didStart"
--- object - the ping object the callback is for
--- message - the message to the callback, in this case "didFail"
--- error - a string containing the error message that has occurred
--- object - the ping object the callback is for
--- message - the message to the callback, in this case "sendPacketFailed"
--- sequenceNumber - the sequence number of the ICMP packet which has failed to send
--- error - a string containing the error message that has occurred
--- object - the ping object the callback is for
--- message - the message to the callback, in this case "receivedPacket"
--- sequenceNumber - the sequence number of the ICMP packet received
--- object - the ping object the callback is for
--- message - the message to the callback, in this case "didFinish"
---@param server string
---@param count number|nil
---@param interval number|nil
---@param timeout number|nil
---@param class any
---@param fn function
---@return pingObject
function hs.network.ping.ping(server, count, interval, timeout, class, fn) end

--- Returns a string containing the resolved IPv4 or IPv6 address this pingObject is sending echo requests to.
---@return string
function ping:address() end

--- Cancels an in progress ping process, terminating it immediately
---
--- Note: the didFinish message will be sent to the callback function as its final message.
---@return none
function ping:cancel() end

--- Get or set the number of ICMP Echo Requests that will be sent by the ping process
---@param count number|nil
---@return number|pingObject|nil
function ping:count(count) end

--- Returns whether or not the ping process is currently paused.
---@return boolean
function ping:isPaused() end

--- Returns whether or not the ping process is currently active.
---
--- Note: This method will return false only if the ping process has finished sending all echo requests or if it has
--- been cancelled with hs.network.ping:cancel .  To determine if the process is currently sending out echo requests,
--- see hs.network.ping:isPaused .
---@return boolean
function ping:isRunning() end

--- Returns a table containing information about the ICMP Echo packets sent by this pingObject.
---
--- Note: Sequence numbers start at 0 while Lua array tables are indexed starting at 1. If you do not specify a
--- sequenceNumber to this method, index 1 of the array table returned will contain a table describing the ICMP Echo
--- packet with sequence number 0, index 2 will describe the ICMP Echo packet with sequence number 1, etc.
--- sent - a number specifying the time at which the echo request for this packet was sent. This number is the number
--- of seconds since January 1, 1970 at midnight, GMT, and is a floating point number, so you should use math.floor on
--- this number before using it as an argument to Lua's os.date function.
--- recv - a number specifying the time at which the echo reply for this packet was received. This number is the number
--- of seconds since January 1, 1970 at midnight, GMT, and is a floating point number, so you should use math.floor on
--- this number before using it as an argument to Lua's os.date function.
--- checksum - The ICMP packet checksum used to ensure data integrity.
--- code - ICMP Control Message Code. Should always be 0.
--- identifier - The ICMP Identifier generated internally for matching request and reply packets.
--- payload - A string containing the ICMP payload for this packet. This has been constructed to cause the ICMP packet
--- to be exactly 64 bytes to match the convention for ICMP Echo Requests.
--- sequenceNumber - The ICMP Sequence Number for this packet.
--- type - ICMP Control Message Type. For ICMPv4, this will be 0 if a reply has been received or 8 no reply has been
--- received yet. For ICMPv6, this will be 129 if a reply has been received or 128 if no reply has been received yet.
--- _raw - A string containing the ICMP packet as raw data.
---@param sequenceNumber number|nil
---@return table
function ping:packets(sequenceNumber) end

--- Pause an in progress ping process.
---@return pingObject|nil
function ping:pause() end

--- Resume an in progress ping process, if it has been paused.
---@return pingObject|nil
function ping:resume() end

--- Returns the number of ICMP Echo Requests which have been sent.
---@return number
function ping:sent() end

--- Returns the hostname or ip address string given to the
--- hs.network.ping.ping
--- constructor.
---@return string
function ping:server() end

--- Set or remove the callback function for the pingObject.
---
--- Note: Because the ping process begins immediately upon creation with the hs.network.ping.ping constructor, it is
--- preferable to assign the callback with the constructor itself.
--- This method is provided as a means of changing the callback based on other events (a change in the current network
--- or location, perhaps.)
--- If you truly wish to create a pingObject with no callback, you will need to do something like
--- hs.network.ping.ping(...):setCallback(function() end) .
---@param fn function|nil
---@return pingObject
function ping:setCallback(fn) end

--- Returns a string containing summary information about the ping process.
---
--- Note: The summary string will look similar to the following:
--- --- hostname ping statistics
--- 5 packets transmitted, 5 packets received, 0.0 packet loss
--- round-trip min/avg/max = 2.282/4.133/4.926 ms
--- The number of packets received will match the number that has currently been sent, not necessarily the value
--- returned by hs.network.ping:count .
---@return string
function ping:summary() end

-- ------------------------------------------------------------
-- hs.network.ping.echoRequest
-- ------------------------------------------------------------

---@class hs.network.ping.echoRequest
hs.network.ping.echoRequest = {}

---@class echoRequest
local echoRequest = {}

--- Creates a new ICMP Echo Request object for the server specified.
---
--- Note: This constructor returns a lower-level object than the hs.network.ping.ping constructor and is more difficult
--- to use. It is recommended that you use this constructor only if hs.network.ping.ping is not sufficient for your
--- needs.
--- For convenience, you can call this constructor as hs.network.ping.echoRequest(server)
---@param server string
---@return echoRequestObject
function hs.network.ping.echoRequest.echoRequest(server) end

--- Get or set the address family the echoRequestObject should communicate with.
---
--- Note: Setting this value to "IPv6" or "IPv4" will cause the echoRequestObject to attempt to resolve the server's
--- name into an IPv6 address or an IPv4 address and communicate via ICMPv6 or ICMP(v4) when the
--- hs.network.ping.echoRequest:start method is invoked.  A callback with the message "didFail" will occur if the
--- server could not be resolved to an address in the specified family.
--- If this value is set to "any", then the first address which is discovered for the server's name will determine
--- whether ICMPv6 or ICMP(v4) is used, based upon the family of the address.
--- Setting a value with this method will have no immediate effect on an echoRequestObject which has already been
--- started with hs.network.ping.echoRequest:start . You must first stop and then restart the object for any change to
--- have an effect.
---@param family string|nil
---@return echoRequestObject
function echorequest:acceptAddressFamily(family) end

--- Returns a string representation for the server's IP address, or a boolean if address resolution has not completed
--- yet.
---@return string|boolean|nil
function echorequest:hostAddress() end

--- Returns the host address family currently in use by this echoRequestObject.
---@return string
function echorequest:hostAddressFamily() end

--- Returns the name of the target host as provided to the echoRequestObject's constructor
---@return string
function echorequest:hostName() end

--- Returns the identifier number for the echoRequestObject.
---
--- Note: ICMP Echo Replies which include this identifier will generate a "receivedPacket" message to the object
--- callback, while replies which include a different identifier will generate a "receivedUnexpectedPacket" message.
---@return number
function echorequest:identifier() end

--- Returns a boolean indicating whether or not this echoRequestObject is currently listening for ICMP Echo Replies.
---@return boolean
function echorequest:isRunning() end

--- The sequence number that will be used for the next ICMP packet sent by this object.
---
--- Note: ICMP Echo Replies which are expected by this object should always be less than this number, with the caveat
--- that this number is a 16-bit integer which will wrap around to 0 after sending a packet with the sequence number
--- 65535.
--- Per the comments in Apple's SimplePing.m file: Why 120?  Well, if we send one ping per second, 120 is 2 minutes,
--- which is the standard "max time a packet can bounce around the Internet" value.
---@return number
function echorequest:nextSequenceNumber() end

--- Get or set whether or not the callback should receive all unexpected packets or only those which carry our
--- identifier.
---
--- Note: By default, a valid packet (i.e. with a valid checksum) which does not contain our identifier is ignored
--- since it was not intended for our receiver.  Only corrupt or packets with our identifier but that were otherwise
--- unexpected will generate a "receivedUnexpectedPacket" callback message.
--- This method optionally allows the echoRequestObject to receive all incoming packets, even ones which are expected
--- by another process or echoRequestObject.
--- If you wish to examine ICMPv6 router advertisement and neighbor discovery packets, you should set this property to
--- true. Note that this module does not provide the necessary tools to decode these packets at present, so you will
--- have to decode them yourself if you wish to examine their contents.
---@param state function|nil
---@return boolean|echoRequestObject
function echorequest:seeAllUnexpectedPackets(state) end

--- Sends a single ICMP Echo Request packet.
---
--- Note: By convention, unless you are trying to test for specific network fragmentation or congestion problems, ICMP
--- Echo Requests are generally 64 bytes in length (this includes the 8 byte header, giving 56 bytes of payload data).
--- If you do not specify a payload, a default payload which will result in a packet size of 64 bytes is constructed.
---@param payload string|nil
---@return echoRequestObject|boolean|nil
function echorequest:sendPayload(payload) end

--- Set or remove the object callback function
---
--- Note: object - the echoRequestObject itself
--- message - the message to the callback, in this case "didStart"
--- address - a string representation of the IPv4 or IPv6 address of the server specified to the constructor.
--- object - the echoRequestObject itself
--- message - the message to the callback, in this case "didFail"
--- error - a string describing the error that occurred.
--- When this message is received, you do not need to call hs.network.ping.echoRequest:stop -- the object will already
--- have been stopped.
--- object - the echoRequestObject itself
--- message - the message to the callback, in this case "sendPacket"
--- icmp - an ICMP packet table representing the packet which has been sent as described in the header of this module's
--- documentation.
--- seq - the sequence number for this packet. Sequence numbers always start at 0 and increase by 1 every time the
--- hs.network.ping.echoRequest:sendPayload method is called.
--- object - the echoRequestObject itself
--- message - the message to the callback, in this case "sendPacketFailed"
--- icmp - an ICMP packet table representing the packet which was to be sent.
--- seq - the sequence number for this packet.
--- error - a string describing the error that occurred.
--- Unlike "didFail", the echoRequestObject is not stopped when this message occurs; you can try to send another
--- payload if you wish without restarting the object first.
--- object - the echoRequestObject itself
--- message - the message to the callback, in this case "receivedPacket"
--- icmp - an ICMP packet table representing the packet received.
--- seq - the sequence number for this packet.
--- object - the echoRequestObject itself
--- message - the message to the callback, in this case "receivedUnexpectedPacket"
--- icmp - an ICMP packet table representing the packet received.
--- the ICMP packet is corrupt or truncated and cannot be parsed
--- the ICMP Identifier does not match ours and the sequence number is not one we have sent
--- the ICMP type does not match an ICMP Echo Reply
--- When using IPv6, this is especially common because IPv6 uses ICMP for network management functions like Router
--- Advertisement and Neighbor Discovery.
--- In general, it is reasonably safe to ignore these messages, unless you are having problems receiving anything else,
--- in which case it could indicate problems on your network that need addressing.
---@param fn function|nil
---@return echoRequestObject
function echorequest:setCallback(fn) end

--- Start the echoRequestObject by resolving the server's address and start listening for ICMP Echo Reply packets.
---@return echoRequestObject
function echorequest:start() end

--- Stop listening for ICMP Echo Reply packets with this object.
---@return echoRequestObject
function echorequest:stop() end

-- ------------------------------------------------------------
-- hs.network.reachability
-- ------------------------------------------------------------

---@class hs.network.reachability
hs.network.reachability = {}

---@class reachability
local reachability = {}

--- A table containing the numeric value for the possible flags returned by the
--- hs.network.reachability:status
--- method or in the
--- flags
--- parameter of the callback function.
---@type table
hs.network.reachability.flags[] = nil

--- Returns a reachability object for the specified network address.
---
--- Note: this object will reflect reachability status for any interface available on the computer.  To check for
--- reachability from a specific interface, use hs.network.reachability.forAddressPair .
---@param address string
---@return reachabilityObject
function hs.network.reachability.forAddress(address) end

--- Returns a reachability object for the specified network address from the specified localAddress.
---
--- Note: this object will reflect reachability status for a specific interface on the computer.  To check for
--- reachability from any interface, use hs.network.reachability.forAddress .
--- this constructor can be used to test for a specific local network.
---@param localAddress string
---@param remoteAddress string
---@return reachabilityObject
function hs.network.reachability.forAddressPair(localAddress, remoteAddress) end

--- Returns a reachability object for the specified host.
---
--- Note: this object will reflect reachability status for any interface available on the computer.
--- this constructor relies on the hostname being resolvable, possibly through DNS, Bonjour, locally defined, etc.
---@param hostName string
---@return reachabilityObject
function hs.network.reachability.forHostName(hostName) end

--- Creates a reachability object for testing internet access
---
--- Note: This is equivalent to hs.network.reachability.forAddress("0.0.0.0")
--- This constructor assumes that a default route for IPv4 traffic is sufficient to determine internet access.  If you
--- are on an IPv6 only network which does not also provide IPv4 route mapping, you should probably use something along
--- the lines of hs.network.reachability.forAddress("::") instead.
---@return reachabilityObject
function hs.network.reachability.internet() end

--- Creates a reachability object for testing IPv4 link local networking
---
--- Note: This is equivalent to hs.network.reachability.forAddress("169.254.0.0")
--- hs.network.reachability.linklocal():status() & hs.network.reachability.flags.isDirect
--- If the internet is reachable, then this network will also be reachable by default -- use the isDirect flag to
--- ensure that the route is local.
---@return reachabilityObject
function hs.network.reachability.linkLocal() end

--- Set or remove the callback function for a reachability object
---
--- Note: The callback function will be invoked each time the status for the given reachability object changes.  The
--- callback function should expect 2 arguments, the reachability object itself and a numeric representation of the
--- reachability flags, and should not return anything.
--- This method just sets the callback function.  You can start or stop the watcher with hs.network.reachability:start
--- or hs.network.reachability:stop
---@param function any
---@return reachabilityObject
function reachability:setCallback(function) end

--- Starts watching the reachability object for changes and invokes the callback function (if any) when a change occurs.
---
--- Note: The callback function should be specified with hs.network.reachability:setCallback .
---@return reachabilityObject
function reachability:start() end

--- Returns the reachability status for the object
---
--- Note: The numeric representation is made up from a combination of the flags defined in
--- hs.network.reachability.flags .
---@return number
function reachability:status() end

--- Returns a string representation of the reachability status for the object
---
--- Note: This is included primarily for debugging, but may be more useful when you just want a quick look at the
--- reachability status for display or testing.
--- 't'|'-' indicates if the destination is reachable through a transient connection
--- 'R'|'-' indicates if the destination is reachable
--- 'c'|'-' indicates that a connection of some sort is required for the destination to be reachable
--- 'C'|'-' indicates if the destination requires a connection which will be initiated when traffic to the destination
--- is present
--- 'i'|'-' indicates if the destination requires a connection which will require user activity to initiate
--- 'D'|'-' indicates if the destination requires a connection which will be initiated on demand through the
--- CFSocketStream interface
--- 'l'|'-' indicates if the destination is actually a local address
--- 'd'|'-' indicates if the destination is directly connected
---@return string
function reachability:statusString() end

--- Stops watching the reachability object for changes.
---@return reachabilityObject
function reachability:stop() end

-- ------------------------------------------------------------
-- hs.noises
-- ------------------------------------------------------------

---@class hs.noises
hs.noises = {}

---@class noises
local noises = {}

--- Creates a new listener for mouth noise recognition
---@param fn function
---@return listener
function hs.noises.new(fn) end

--- Starts listening to the microphone and passing the audio to the recognizer.
---@return self
function noises:start() end

--- Stops the listener from recording and analyzing microphone input.
---@return self
function noises:stop() end

-- ------------------------------------------------------------
-- hs.notify
-- ------------------------------------------------------------

---@class hs.notify
hs.notify = {}

---@class notify
local notify = {}

--- Convenience array of the possible activation types for a notification, and their reverse for reference.
---@type the[]
hs.notify.activationTypes[] = nil

--- The string representation of the default notification sound. Use
--- hs.notify:soundName()
--- or set the
--- soundName
--- attribute in
--- hs:notify.new()
--- , to this constant, if you want to use the default sound
---@type string
hs.notify.defaultNotificationSound = nil

--- A table containing the registered callback functions and their tags.
---@type table
hs.notify.registry[] = nil

--- A value indicating whether or not a missing notification function tag should cause a warning.  Defaults to
--- true
--- .
---@type any
hs.notify.warnAboutMissingFunctionTag = nil

--- Returns a table containing notifications which have been delivered.
---
--- Note: Only notifications which have been presented but not cleared, either by the user clicking on the
--- hs.notify:otherButtonTitle or through auto-withdrawal (see hs.notify:autoWithdraw for more details), will be in the
--- array returned.
--- You can use this function along with hs.notify:getFunctionTag to re=register necessary callback functions with
--- hs.notify.register when Hammerspoon is restarted.
--- Since notifications which the user has closed (or cancelled) do not trigger a callback, you can check this table
--- with a timer to see if the user has cleared a notification, e.g.
--- myNotification
--- =
--- hs
--- .
--- notify
--- .
--- new
--- ():
--- send
--- ()
--- clearCheck
--- =
--- hs
--- .
--- timer
--- .
--- doEvery
--- (
--- 10
--- ,
--- function
--- ()
--- if
--- not
--- hs
--- .
--- fnutils
--- .
--- contains
--- (
--- hs
--- .
--- notify
--- .
--- deliveredNotifications
--- (),
--- myNotification
--- )
--- then
--- if
--- myNotification
--- :
--- activationType
--- ()
--- ==
--- hs
--- .
--- notify
--- .
--- activationTypes
--- .
--- none
--- then
--- print
--- (
--- "You dismissed me!"
--- )
--- else
--- print
--- (
--- "A regular action occurred, so callback (if any) was invoked"
--- )
--- end
--- clearCheck
--- :
--- stop
--- ()
--- -- either way, no need to keep polling
--- clearCheck
--- =
--- nil
--- end
--- end
--- )
---@return table
function hs.notify.deliveredNotifications() end

--- Registers a function callback with the specified tag for a notification. The callback function will be invoked when
--- the user clicks on or interacts with a notification.
---
--- Note: If a function is already registered with the specified tag, it is replaced by with the new one.
---@param tag string
---@param fn function
---@return id
function hs.notify.register(tag, fn) end

--- Returns a table containing notifications which are scheduled but have not yet been delivered.
---
--- Note: Once a notification has been delivered, it is moved to hs.notify.deliveredNotifications or removed, depending
--- upon the users action.
--- You can use this function along with hs.notify:getFunctionTag to re=register necessary callback functions with
--- hs.notify.register when Hammerspoon is restarted.
---@return table
function hs.notify.scheduledNotifications() end

--- Unregisters a function callback so that it is no longer available as a callback when notifications corresponding to
--- the specified entry are interacted with.
---@param id|tag any
---@return any
function hs.notify.unregister(id|tag) end

--- Unregisters all functions registered as callbacks.
---
--- Note: This does not remove the notifications from the User Notification Center, it just removes their callback
--- function for when the user interacts with them. To remove all notifications, see hs.notify.withdrawAll and
--- hs.notify.withdrawAllScheduled
---@return any
function hs.notify.unregisterall() end

--- Withdraw all delivered notifications from Hammerspoon
---
--- Note: This will withdraw all notifications for Hammerspoon, including those not sent by this module or that linger
--- from a previous load of Hammerspoon.
---@return any
function hs.notify.withdrawAll() end

--- Withdraw all scheduled notifications from Hammerspoon
---@return any
function hs.notify.withdrawAllScheduled() end

--- Creates a new notification object
---
--- Note: A function-tag is a string key which corresponds to a function stored in the hs.notify.registry table with
--- the hs.notify.register() function.
--- If a notification does not have a title attribute set, OS X will not display it, so by default it will be set to
--- "Notification". You can use the title key in the attributes table, or call hs.notify:title() before displaying the
--- notification to change this.
---@param fn function|nil
---@param attributes any
---@return notification
function hs.notify.new(fn, attributes) end

--- Shorthand constructor to create and show simple notifications
---
--- Note: All three textual parameters are required, though they can be empty strings
--- This function is really a shorthand for hs.notify.new(...):send()
--- Notifications created using this function will inherit the default withdrawAfter value, which is 5 seconds. To
--- produce persistent notifications you should use hs.notify.new() with a withdrawAfter attribute of 0.
---@param title string
---@param subTitle string
---@param information any
---@param tag? function
---@return notification
function hs.notify.show(title, subTitle, information, tag) end

--- Get or set the label of a notification's action button
---
--- Note: The affects of this method only apply if the user has set Hammerspoon notifications to Alert in the
--- Notification Center pane of System Preferences
--- This value is ignored if hs.notify:hasReplyButton is true.
---@param buttonTitle string|nil
---@return notificationObject|current-setting
function notify:actionButtonTitle(buttonTitle) end

--- Returns how the notification was activated by the user.
---@return number
function notify:activationType() end

--- Returns the date and time when a notification was delivered
---
--- Note: You can turn epoch times into a human readable string or a table of date elements with the os.date() function.
---@return number
function notify:actualDeliveryDate() end

--- Get or set additional actions which will be displayed for an alert type notification when the user clicks and holds
--- down the action button of the alert.
---
--- Note: The additional items will be listed in a pop-up menu when the user clicks and holds down the mouse button in
--- the action button of the alert.
--- If the user selects one of the additional actions, hs.notify:activationType will equal
--- hs.notify.activationTypes.additionalActionClicked
--- See also hs.notify:additionalActivationAction
---@param actionsTable any
---@return notificationObject|table
function notify:additionalActions(actionsTable) end

--- Return the additional action that the user selected from an alert type notification that has additional actions
--- available.
---
--- Note: If the user selects one of the additional actions, hs.notify:activationType will equal
--- hs.notify.activationTypes.additionalActionClicked
--- See also hs.notify:additionalActions
---@return string|nil
function notify:additionalActivationAction() end

--- Get or set whether a notification should be presented even if this overrides Notification Center's decision process.
---
--- Note: This does not affect the return value of hs.notify:presented() -- that will still reflect the decision of the
--- Notification Center
--- Examples of why the users Notification Center would choose not to display a notification would be if Hammerspoon is
--- the currently focussed application, being attached to a projector, or the user having set Do Not Disturb.
--- if the notification was not created by this module, this method will return nil
---@param alwaysPresent any
---@return notificationObject|current-setting
function notify:alwaysPresent(alwaysPresent) end

--- Get or set whether an alert notification should always show an alternate action menu.
---
--- Note: This method has no effect unless the user has set Hammerspoon notifications to Alert in the Notification
--- Center pane of System Preferences.
--- hs.notify:additionalActions must also be used for this method to have any effect.
--- WARNING: This method uses a private API. It could break at any time. Please file an issue if it does.
---@param state boolean|nil
---@return notificationObject|boolean
function notify:alwaysShowAdditionalActions(state) end

--- Get or set whether a notification should automatically withdraw once activated
---
--- Note: This method has no effect if the user has set Hammerspoon notifications to Alert in the Notification Center
--- pane of System Preferences: clicking on either the action or other button will clear the notification automatically.
--- If a notification which was created before your last reload (or restart) of Hammerspoon and is clicked upon before
--- hs.notify has been loaded into memory, this setting will not be honored because the initial application delegate is
--- not aware of this option and is set to automatically withdraw all notifications which are acted upon.
--- if the notification was not created by this module, this method will return nil
---@param shouldWithdraw boolean|nil
---@return notificationObject|current-setting
function notify:autoWithdraw(shouldWithdraw) end

--- Get or set a notification's content image.
---
--- Note: See hs.image for details on how to specify or define an image
--- This method is only supported in OS X 10.9 or greater. A warning will be displayed in the console and the method
--- will be treated as a no-op if used on an unsupported system.
---@param image hs.image|nil
---@return notificationObject|current-setting
function notify:contentImage(image) end

--- Returns whether the notification has been delivered to the Notification Center
---@return boolean
function notify:delivered() end

--- Return the name of the function tag the notification will call when activated.
---
--- Note: This tag should correspond to a function in hs.notify.registry and can be used to either add a replacement
--- with hs.notify.register(...) or remove it with hs.notify.unregister(...)
--- if the notification was not created by this module, this method will return nil
---@return functiontag
function notify:getFunctionTag() end

--- Get or set the presence of an action button in a notification
---
--- Note: The affects of this method only apply if the user has set Hammerspoon notifications to Alert in the
--- Notification Center pane of System Preferences
---@param hasButton boolean|nil
---@return notificationObject|current-setting
function notify:hasActionButton(hasButton) end

--- Get or set whether an alert notification has a "Reply" button for additional user input.
---
--- Note: This method has no effect unless the user has set Hammerspoon notifications to Alert in the Notification
--- Center pane of System Preferences.
--- hs.notify:hasActionButton must also be true or the "Reply" button will not be displayed.
--- If this is set to true, the action button will be "Reply" even if you have set another one with
--- hs.notify:actionButtonTitle .
---@param state boolean|nil
---@return notificationObject|boolean
function notify:hasReplyButton(state) end

--- Get or set the informative text of a notification
---@param informativeText string|nil
---@return notificationObject|current-setting
function notify:informativeText(informativeText) end

--- Get or set the label of a notification's other button
---
--- Note: The affects of this method only apply if the user has set Hammerspoon notifications to Alert in the
--- Notification Center pane of System Preferences
--- Due to OSX limitations, it is NOT possible to get a callback for this button.
---@param buttonTitle string|nil
---@return notificationObject|current-setting
function notify:otherButtonTitle(buttonTitle) end

--- Returns whether the users Notification Center decided to display the notification
---
--- Note: Examples of why the users Notification Center would choose not to display a notification would be if
--- Hammerspoon is the currently focussed application, being attached to a projector, or the user having set Do Not
--- Disturb.
---@return boolean
function notify:presented() end

--- Get the users input from an alert type notification with a reply button.
---
--- Note: hs.notify:activationType will equal hs.notify.activationTypes.replied if the user clicked on the Reply button
--- and then clicks on Send.
--- See also hs.notify:hasReplyButton
---@return string|nil
function notify:response() end

--- Set a placeholder string for alert type notifications with a reply button.
---
--- Note: In macOS 10.13, this text appears so light that it is almost unreadable; so far no workaround has been found.
--- See also hs.notify:hasReplyButton
---@param string string|nil
---@return notificationObject|string
function notify:responsePlaceholder(string) end

--- Schedules a notification for delivery in the future.
---
--- Note: See also hs.notify:send()
--- hs.settings.dateFormat specifies a lua format string which can be used with os.date() to properly present the date
--- and time as a string for use with this method.
---@param date any
---@return notificationObject
function notify:schedule(date) end

--- Delivers the notification immediately to the users Notification Center.
---
--- Note: See also hs.notify:schedule()
--- If a notification has been modified, then this will resend it.
--- You can invoke this multiple times if you wish to repeat the same notification.
---@return notificationObject
function notify:send() end

--- Set a notification's identification image (replace the Hammerspoon icon with a custom image)
---
--- Note: See hs.image for details on how to specify or define an image
--- WARNING : This method uses a private API. It could break at any time. Please file an issue if it does
---@param image hs.image
---@param withBorder? boolean|nil
---@return notificationObject
function notify:setIdImage(image, withBorder) end

--- Get or set the sound for a notification
---
--- Note: Sounds will first be matched against the names of system sounds. If no matches can be found, they will then
--- be searched for in the following paths, in order:
--- ~/Library/Sounds
--- /Library/Sounds
--- /Network/Sounds
--- /System/Library/Sounds
---@param soundName string|nil
---@return notificationObject|current-setting
function notify:soundName(soundName) end

--- Get or set the subtitle of a notification
---@param subtitleText string|nil
---@return notificationObject|current-setting
function notify:subTitle(subtitleText) end

--- Get or set the title of a notification
---@param titleText string|nil
---@return notificationObject|current-setting
function notify:title(titleText) end

--- Withdraws a delivered notification from the Notification Center.
---@return notificationObject
function notify:withdraw() end

--- Get or set the number of seconds after which to automatically withdraw a notification
---
--- Note: While this setting applies to both Banner and Alert styles of notifications, it is functionally meaningless
--- for Banner styles
--- A value of 0 will disable auto-withdrawal
--- if the notification was not created by this module, this method will return nil
---@param seconds number|nil
---@return notificationObject|number
function notify:withdrawAfter(seconds) end

-- ------------------------------------------------------------
-- hs.osascript
-- ------------------------------------------------------------

---@class hs.osascript
hs.osascript = {}

--- Runs osascript code
---@param source any
---@param language string
---@return boolean
---@return object
---@return descriptor
function hs.osascript._osascript(source, language) end

--- Runs AppleScript code
---
--- Note: Use hs.osascript._osascript(source, "AppleScript") if you always want the result as a string, even when a
--- failure occurs
---@param source string
---@return boolean
---@return object
---@return descriptor
function hs.osascript.applescript(source) end

--- Runs AppleScript code from a source file.
---
--- Note: This function uses hs.osascript.applescript for execution.
--- Use hs.osascript._osascript(source, "AppleScript") if you always want the result as a string, even when a failure
--- occurs. However, this function can only take a string, and not a file name.
---@param fileName string
---@return boolean
---@return object
---@return descriptor
function hs.osascript.applescriptFromFile(fileName) end

--- Runs JavaScript code
---
--- Note: Use hs.osascript._osascript(source, "JavaScript") if you always want the result as a string, even when a
--- failure occurs
---@param source string
---@return boolean
---@return object
---@return descriptor
function hs.osascript.javascript(source) end

--- Runs JavaScript code from a source file.
---
--- Note: This function uses hs.osascript.javascript for execution.
--- Use hs.osascript._osascript(source, "JavaScript") if you always want the result as a string, even when a failure
--- occurs. However, this function can only take a string, and not a file name.
---@param fileName string
---@return boolean
---@return object
---@return descriptor
function hs.osascript.javascriptFromFile(fileName) end

-- ------------------------------------------------------------
-- hs.pasteboard
-- ------------------------------------------------------------

---@class hs.pasteboard
hs.pasteboard = {}

--- An array whose elements are a table containing the content types for each element on the clipboard.
---@param name string
---@return table
function hs.pasteboard.allContentTypes(name) end

--- Invokes callback when the specified pasteboard has changed or the timeout is reached.
---
--- Note: This function can be used to capture the results of a copy operation issued programmatically with
--- hs.application:selectMenuItem or hs.eventtap.keyStroke without resorting to creating your own timers:
--- hs.eventtap.keyStroke({"cmd"}, "c", 0) -- or whatever method you want to trigger the copy
--- hs.pasteboard.callbackWhenChanged(5, function(state)
--- if state then
--- local contents = hs.pasteboard.getContents()
--- -- do what you want with contents
--- else
--- error("copy timeout") -- or whatever fallback you want when it times out
--- end
--- end)
---@param name string
---@param timeout number|nil
---@param callback function
function hs.pasteboard.callbackWhenChanged(name, timeout, callback) end

--- Gets the number of times the pasteboard owner has changed
---
--- Note: This is useful for seeing if the pasteboard has been updated by another process
---@param name string|nil
---@return number
function hs.pasteboard.changeCount(name) end

--- Clear the contents of the pasteboard
---@param name string|nil
---@return any
function hs.pasteboard.clearContents(name) end

--- Return the UTI strings of the data types for the first pasteboard item on the specified pasteboard.
---@param name string|nil
---@return table
function hs.pasteboard.contentTypes(name) end

--- Deletes a custom pasteboard
---
--- Note: You can not delete the system pasteboard, this function should only be called on custom pasteboards you have
--- created
---@param name string
---@return any
function hs.pasteboard.deletePasteboard(name) end

--- Gets the contents of the pasteboard
---@param name string|nil
---@return string|nil
function hs.pasteboard.getContents(name) end

--- Return the pasteboard type identifier strings for the specified pasteboard.
---@param name string|nil
---@return table
function hs.pasteboard.pasteboardTypes(name) end

--- Returns all values in the first item on the pasteboard in a table that maps a UTI value to the raw data of the item
---@param name string
---@return table
function hs.pasteboard.readAllData(name) end

--- Returns the first item on the pasteboard with the specified UTI. The data on the pasteboard must be encoded as a
--- keyed archive object conforming to NSKeyedArchiver.
---
--- Note: NSKeyedArchiver specifies an architecture-independent format that is often used in OS X applications to store
--- and transmit objects between applications and when storing data to a file. It works by recording information about
--- the object types and key-value pairs which make up the objects being stored.
--- Only objects which have conversion functions built into Hammerspoon can be converted. A string representation
--- describing unrecognized types wil be returned. If you find a common data type that you believe may be of interest
--- to Hammerspoon users, feel free to contribute a conversion function or make a request in the Hammerspoon Google
--- group or GitHub site.
--- Some applications may define their own classes which can be archived.  Hammerspoon will be unable to recognize
--- these types if the application does not make the object type available in one of its frameworks.  You may be able
--- to load the necessary framework with package.loadlib("/Applications/appname.app/Contents/Frameworks/frameworkname.framework/frameworkname", "*") before retrieving the data, but a full representation of the data in Hammerspoon is probably not possible without support from the Application's developers.
---@param name string
---@param uti string
---@return any
function hs.pasteboard.readArchiverDataForUTI(name, uti) end

--- Returns one or more
--- hs.drawing.color
--- tables from the clipboard, or nil if no compatible objects are present.
---@param name string
---@param all any
---@return hs.drawing.color table|array of hs.drawing.color tables
function hs.pasteboard.readColor(name, all) end

--- Returns the first item on the pasteboard with the specified UTI as raw data
---
--- Note: The UTI's of the items on the pasteboard can be determined with the hs.pasteboard.allContentTypes and
--- hs.pasteboard.contentTypes functions.
---@param name string
---@param uti string
---@return string
function hs.pasteboard.readDataForUTI(name, uti) end

--- Returns one or more
--- hs.image
--- objects from the clipboard, or nil if no compatible objects are present.
---@param name string
---@param all any
---@return hs.image|array of hs.image objects
function hs.pasteboard.readImage(name, all) end

--- Returns the first item on the pasteboard with the specified UTI as a property list item
---
--- Note: The UTI's of the items on the pasteboard can be determined with the hs.pasteboard.allContentTypes and
--- hs.pasteboard.contentTypes functions.
--- Property lists consist only of certain types of data: tables, strings, numbers, dates, binary data, and Boolean
--- values.
---@param name string
---@param uti string
---@return any
function hs.pasteboard.readPListForUTI(name, uti) end

--- Returns one or more
--- hs.sound
--- objects from the clipboard, or nil if no compatible objects are present.
---@param name string
---@param all any
---@return hs.sound|array of hs.sound objects
function hs.pasteboard.readSound(name, all) end

--- Returns one or more strings from the clipboard, or nil if no compatible objects are present.
---
--- Note: almost all string and styledText objects are internally convertible and will be available with this method as
--- well as hs.pasteboard.readStyledText . If the item is actually an hs.styledtext object, the string will be just the
--- text of the object.
---@param name string
---@param all any
---@return string|array of strings
function hs.pasteboard.readString(name, all) end

--- Returns one or more
--- hs.styledtext
--- objects from the clipboard, or nil if no compatible objects are present.
---
--- Note: almost all string and styledText objects are internally convertible and will be available with this method as
--- well as hs.pasteboard.readString . If the item on the clipboard is actually just a string, the hs.styledtext object
--- representation will have no attributes set
---@param name string
---@param all any
---@return hs.styledtext|array of hs.styledtext objects
function hs.pasteboard.readStyledText(name, all) end

--- Returns one or more strings representing file or resource urls from the clipboard, or nil if no compatible objects
--- are present.
---@param name string
---@param all any
---@return string|array of strings representing file|resource urls
function hs.pasteboard.readURL(name, all) end

--- Sets the contents of the pasteboard
---@param contents string
---@param name? string|nil
---@return boolean
function hs.pasteboard.setContents(contents, name) end

--- Returns a table indicating what content types are available on the pasteboard.
---
--- Note: if the item on the clipboard is actually just a string, the hs.styledtext object representation will have no
--- attributes set
--- if the item is actually an hs.styledtext object, the string representation will be the text without any attributes.
---@param name string
---@return table
function hs.pasteboard.typesAvailable(name) end

--- Returns the name of a new pasteboard with a name that is guaranteed to be unique with respect to other pasteboards
--- on the computer.
---
--- Note: to properly manage system resources, you should release the created pasteboard with
--- hs.pasteboard.deletePasteboard when you are certain that it is no longer necessary.
---@return string
function hs.pasteboard.uniquePasteboard() end

--- Stores in the pasteboard a given table of UTI to data mapping all at once
---@param name string
---@param table any
---@return boolean
function hs.pasteboard.writeAllData(name, table) end

--- Sets the pasteboard to the contents of the data and assigns its type to the specified UTI. The data will be encoded
--- as an archive conforming to NSKeyedArchiver.
---
--- Note: NSKeyedArchiver specifies an architecture-independent format that is often used in OS X applications to store
--- and transmit objects between applications and when storing data to a file. It works by recording information about
--- the object types and key-value pairs which make up the objects being stored.
--- Only objects which have conversion functions built into Hammerspoon can be converted.
--- A full list of NSObjects supported directly by Hammerspoon is planned in a future Wiki article.
---@param name string
---@param uti string
---@param data table
---@param add any
---@return boolean
function hs.pasteboard.writeArchiverDataForUTI(name, uti, data, add) end

--- Sets the pasteboard to the contents of the data and assigns its type to the specified UTI.
---
--- Note: The UTI's of the items on the pasteboard can be determined with the hs.pasteboard.allContentTypes and
--- hs.pasteboard.contentTypes functions.
---@param name string
---@param uti string
---@param data string
---@param add any
---@return boolean
function hs.pasteboard.writeDataForUTI(name, uti, data, add) end

--- Sets the pasteboard contents to the object or objects specified.
---
--- Note: Most applications can only receive the first item on the clipboard.  Multiple items on a clipboard are most
--- often used for intra-application communication where the sender and receiver are specifically written with multiple
--- objects in mind.
---@param object any
---@param name string
---@return boolean
function hs.pasteboard.writeObjects(object, name) end

--- Sets the pasteboard to the contents of the data and assigns its type to the specified UTI.
---
--- Note: The UTI's of the items on the pasteboard can be determined with the hs.pasteboard.allContentTypes and
--- hs.pasteboard.contentTypes functions.
--- Property lists consist only of certain types of data: tables, strings, numbers, dates, binary data, and Boolean
--- values.
---@param name string
---@param uti string
---@param data any
---@param add any
---@return boolean
function hs.pasteboard.writePListForUTI(name, uti, data, add) end

-- ------------------------------------------------------------
-- hs.pasteboard.watcher
-- ------------------------------------------------------------

---@class hs.pasteboard.watcher
hs.pasteboard.watcher = {}

---@class watcher
local watcher = {}

--- Gets or sets the polling interval (i.e. the frequency the pasteboard watcher checks the pasteboard).
---
--- Note: This only affects new watchers, not existing/running ones.
--- The default value is 0.25.
---@param value number|nil
---@return number
function hs.pasteboard.watcher.interval(value) end

--- Creates and starts a new
--- hs.pasteboard.watcher
--- object for watching for Pasteboard changes.
---
--- Note: Internally this extension uses a single NSTimer to check for changes to the pasteboard count every half a
--- second.
--- Example usage:
--- generalPBWatcher
--- =
--- hs
--- .
--- pasteboard
--- .
--- watcher
--- .
--- new
--- (
--- function
--- (
--- v
--- )
--- print
--- (
--- string.format
--- (
--- "General Pasteboard Contents: %s"
--- ,
--- v
--- ))
--- end
--- )
--- specialPBWatcher
--- =
--- hs
--- .
--- pasteboard
--- .
--- watcher
--- .
--- new
--- (
--- function
--- (
--- v
--- )
--- print
--- (
--- string.format
--- (
--- "Special Pasteboard Contents: %s"
--- ,
--- v
--- ))
--- end
--- ,
--- "special"
--- )
--- hs
--- .
--- pasteboard
--- .
--- writeObjects
--- (
--- "This is on the general pasteboard."
--- )
--- hs
--- .
--- pasteboard
--- .
--- writeObjects
--- (
--- "This is on the special pasteboard."
--- ,
--- "special"
--- )
--- ```
---@param callbackFn any
---@param name? string|nil
---@return pasteboardWatcher
function hs.pasteboard.watcher.new(callbackFn, name) end

--- Returns a boolean indicating whether or not the Pasteboard Watcher is currently running.
---@return boolean
function watcher:running() end

--- Starts an
--- hs.pasteboard.watcher
--- object
---@return timer
function watcher:start() end

--- Stops an
--- hs.pasteboard.watcher
--- object
---@return timer
function watcher:stop() end

-- ------------------------------------------------------------
-- hs.pathwatcher
-- ------------------------------------------------------------

---@class hs.pathwatcher
hs.pathwatcher = {}

---@class pathwatcher
local pathwatcher = {}

--- Creates a new path watcher object
---
--- Note: For more information about the event flags, see the official documentation
---@param path string
---@param fn function
---@return watcher
function hs.pathwatcher.new(path, fn) end

--- Starts a path watcher
---@return hs.pathwatcher
function pathwatcher:start() end

--- Stops a path watcher
---@return any
function pathwatcher:stop() end

-- ------------------------------------------------------------
-- hs.plist
-- ------------------------------------------------------------

---@class hs.plist
hs.plist = {}

--- Loads a Property List file
---@param filepath string
---@return table
function hs.plist.read(filepath) end

--- Interprets a property list file within a string into a table.
---@param value string
---@param binary boolean|nil
---@return table|nil
function hs.plist.readString(value, binary) end

--- Writes a Property List file
---
--- Note: Only simple types can be converted to plist items:
--- Strings
--- Numbers
--- Booleans
--- Tables
--- You should be careful when reading a plist, modifying and writing it - Hammerspoon may not be able to preserve all
--- of the datatypes via Lua
---@param filepath string
---@param data table
---@param binary? boolean|nil
---@return boolean
function hs.plist.write(filepath, data, binary) end

--- Interprets a property list file within a string into a table.
---@param data table
---@param binary boolean|nil
---@return string|nil
function hs.plist.writeString(data, binary) end

-- ------------------------------------------------------------
-- hs.razer
-- ------------------------------------------------------------

---@class hs.razer
hs.razer = {}

---@class razer
local razer = {}

--- Sets/clears a callback for reacting to device discovery events
---@param fn function
---@return none
function hs.razer.discoveryCallback(fn) end

--- Gets an hs.razer object for the specified device
---@param num number
---@return razerObject|nil
function hs.razer.getDevice(num) end

--- Initialises the Razer driver and sets a discovery callback.
---
--- Note: This function must be called before any other parts of this module are used
---@param fn function
---@return any
function hs.razer.init(fn) end

--- Gets the number of Razer devices connected
---@return number
function hs.razer.numDevices() end

--- Runs some basic unit tests when a Razer Tartarus V2 is connected.
---
--- Note: Because hs.razer relies on a physical device to
--- be connected for testing, this method exists so that
--- Hammerspoon developers can test the extension outside
--- of the usual GitHub tests. It can also be used for
--- user troubleshooting.
---@return none
function hs.razer.unitTests() end

--- Changes the keyboard backlights to the breath mode.
---
--- Note: If neither color nor secondaryColor is provided, then random colors will be used.
---@param color any
---@param secondaryColor any
---@return razerObject
---@return boolean
---@return string|nil
function razer:backlightsBreathing(color, secondaryColor) end

--- Changes the keyboard backlights to custom colours.
---
--- Note: The order is top to bottom, left to right. You can use nil for any buttons you don't want to light up.
--- Example usage: ```lua
--- hs.razer.new(0):backlightsCustom({hs.drawing.color.red, nil, hs.drawing.color.green, hs.drawing.color.blue})
---@param colors table
---@return razerObject
---@return boolean
---@return string|nil
function razer:backlightsCustom(colors) end

--- Turns all the keyboard backlights off.
---@return razerObject
---@return boolean
---@return string|nil
function razer:backlightsOff() end

--- Changes the keyboard backlights to the reactive mode.
---@param speed number
---@param color hs.drawing.color
---@return razerObject
---@return boolean
---@return string|nil
function razer:backlightsReactive(speed, color) end

--- Changes the keyboard backlights to the spectrum mode.
---@return razerObject
---@return boolean
---@return string|nil
function razer:backlightsSpectrum() end

--- Changes the keyboard backlights to the Starlight mode.
---
--- Note: If neither color nor secondaryColor is provided, then random colors will be used.
---@param speed number
---@param color any
---@param secondaryColor any
---@return razerObject
---@return boolean
---@return string|nil
function razer:backlightsStarlight(speed, color, secondaryColor) end

--- Changes the keyboard backlights to a single static color.
---@param color hs.drawing.color
---@return razerObject
---@return boolean
---@return string|nil
function razer:backlightsStatic(color) end

--- Changes the keyboard backlights to the wave mode.
---@param speed number
---@param direction string
---@return razerObject
---@return boolean
---@return string|nil
function razer:backlightsWave(speed, direction) end

--- Gets or sets the blue status light.
---@param value any
---@return razerObject
---@return boolean|nil
---@return string|nil
function razer:blueStatusLight(value) end

--- Gets or sets the brightness of a Razer keyboard.
---@param value number
---@return razerObject
---@return number|nil
---@return string|nil
function razer:brightness(value) end

--- Sets or removes a callback function for the
--- hs.razer
--- object.
---
--- Note: razerObject - The serial port object that triggered the callback.
--- buttonName - The name of the button as a string.
--- buttonAction - A string containing "pressed", "released", "up" or "down".
---@param callbackFn function
---@return razerObject
function razer:callback(callbackFn) end

--- Allows you to remap the default Keyboard Layout on a Razer device so that the buttons no longer trigger their
--- factory default actions, or restore the default keyboard layout.
---
--- Note: This feature currently only works on the Razer Tartarus V2.
---@param enabled boolean
---@return boolean
function razer:defaultKeyboardLayout(enabled) end

--- Gets or sets the green status light.
---@param value any
---@return razerObject
---@return boolean|nil
---@return string|nil
function razer:greenStatusLight(value) end

--- Returns the human readable device name of the Razer device.
---@return string
function razer:name() end

--- Gets or sets the orange status light.
---@param value any
---@return razerObject
---@return boolean|nil
---@return string|nil
function razer:orangeStatusLight(value) end

-- ------------------------------------------------------------
-- hs.redshift
-- ------------------------------------------------------------

---@class hs.redshift
hs.redshift = {}

--- A table holding the gamma values for given color temperatures; each key must be a color temperature number in K
--- (useful values are between
---@type table
hs.redshift.COLORRAMP = nil

--- Subscribes a callback to be notified when the color inversion status changes
---
--- Note: You can use this to dynamically adjust the UI colors in your modules or configuration, if appropriate.
---@param id hs.redshift.invertUnsubscribe|nil
---@param fn function
---@return any
function hs.redshift.invertSubscribe(id, fn) end

--- Unsubscribes a previously subscribed color inversion change callback
---@param id string
---@return any
function hs.redshift.invertUnsubscribe(id) end

--- Checks if the colors are currently inverted
---@return string|boolean
function hs.redshift.isInverted() end

--- Sets or clears a request for color inversion
---
--- Note: you can use this function e.g. to automatically invert colors if the ambient light sensor reading drops below
--- a certain threshold ( hs.brightness.DDCauto() can optionally do exactly that)
--- if the user's configuration doesn't explicitly start the redshift module, calling this will have no effect
---@param id string
---@param v boolean|nil
---@return any
function hs.redshift.requestInvert(id, v) end

--- Sets the schedule and (re)starts the module
---@param colorTemp number
---@param nightStart string
---@param nightEnd string
---@param transition? hs.timer.seconds|nil
---@param invertAtNight? boolean|nil
---@param windowfilterDisable? hs.window.filter|nil
---@param dayColorTemp? number|nil
---@return any
function hs.redshift.start(colorTemp, nightStart, nightEnd, transition, invertAtNight, windowfilterDisable, dayColorTemp) end

--- Stops the module and disables color adjustment and color inversion
---@return any
function hs.redshift.stop() end

--- Sets or clears the user override for color temperature adjustment.
---
--- Note: This function should be bound to a hotkey, e.g.: hs.hotkey.bind('ctrl-cmd','-','Redshift',hs.redshift.toggle)
---@param v any
---@return any
function hs.redshift.toggle(v) end

--- Sets or clears the user override for color inversion.
---
--- Note: This function should be bound to a hotkey, e.g.: hs.hotkey.bind('ctrl-cmd','=','Invert',hs.redshift.toggleInvert)
---@param v any
---@return any
function hs.redshift.toggleInvert(v) end

-- ------------------------------------------------------------
-- hs.screen
-- ------------------------------------------------------------

---@class hs.screen
hs.screen = {}

---@class screen
local screen = {}

--- If set to
--- true
--- , the methods
--- hs.screen:toEast()
--- ,
--- :toNorth()
--- etc. will disregard screens that lie perpendicularly to the desired axis
---@type hs.screen
hs.screen.strictScreenInDirection = nil

--- Gets the current state of the screen-related accessibility settings
---@return table
function hs.screen.accessibilitySettings() end

--- Finds screens
---
--- Note: for convenience you call this as hs.screen(hint)
--- Example:
--- hs
--- .
--- screen
--- (
--- 724562417
--- )
--- --> Color LCD - by id
--- hs
--- .
--- screen
--- 'Dell'
--- --> DELL U2414M - by name
--- hs
--- .
--- screen
--- 'Built%-in'
--- --> Built-in Retina Display, note the % to escape the hyphen repetition character
--- hs
--- .
--- screen
--- '0,0'
--- --> PHL BDM4065 - by position, same as hs.screen.primaryScreen()
--- hs
--- .
--- screen
--- {
--- x
--- =-
--- 1
--- ,
--- y
--- =
--- 0
--- }
--- --> DELL U2414M - by position, screen to the immediate left of the primary screen
--- hs
--- .
--- screen
--- '3840x2160'
--- --> PHL BDM4065 - by screen resolution
--- hs
--- .
--- screen
--- '-500,240 700x1300'
--- --> DELL U2414M, by arbitrary rect
---@param hint any
---@return hs.screen
function hs.screen.find(hint) end

--- Restore the gamma settings to defaults
---
--- Note: This returns all displays to the gamma tables specified by the user's selected ColorSync display profiles
---@return any
function hs.screen.restoreGamma() end

--- Returns a list of all connected and enabled screens, along with their "position" relative to the primary screen
---
--- Note: grid-like arrangements of same-sized screens should behave consistently; but there's no guarantee of a
--- consistent result for more "exotic" screen arrangements
---@return table
function hs.screen.screenPositions() end

--- Returns all the screens
---@return hs.screen[]
function hs.screen.allScreens() end

--- Returns the 'main' screen, i.e. the one containing the currently focused window
---@return screen
function hs.screen.mainScreen() end

--- Gets the primary screen
---@return screen
function hs.screen.primaryScreen() end

--- Transforms from the absolute coordinate space used by OSX/Hammerspoon to the screen's local coordinate space, where
--- 0,0
--- is at the screen's top left corner
---@param geom hs.geometry
---@return hs.geometry
function screen:absoluteToLocal(geom) end

--- Returns a table containing the screen modes supported by the screen. A screen mode is a combination of resolution,
--- scaling factor and colour depth
---
--- Note: Prior to 0.9.83, only 32-bit colour modes would be returned, but now all colour depths are returned. This has
--- necessitated changing the naming of the modes in the returned table.
--- "points" are not necessarily the same as pixels, because they take the scale factor into account (e.g.
--- "1440x900@2x" is a 2880x1800 screen resolution, with a scaling factor of 2, i.e. with HiDPI pixel-doubled rendering
--- enabled), however, they are far more useful to work with than native pixel modes, when a Retina screen is involved.
--- For non-retina screens, points and pixels are equivalent.
---@return table
function screen:availableModes() end

--- Returns a table describing the current screen mode
---@return table
function screen:currentMode() end

--- Gets/Sets the desktop background image for a screen
---
--- Note: If the user has set a folder of pictures to be alternated as the desktop background, the path to that folder
--- will be returned.
---@param imageURL string
---@return hs.screen
function screen:desktopImageURL(imageURL) end

--- Returns the screen frame, without the dock or menu.
---@return hs.geometry rect
function screen:frame() end

--- Returns the absolute rect of a given unit rect within this screen
---
--- Note: this method is just a convenience wrapper for hs.geometry.fromUnitRect(unitrect,this_screen:frame())
---@param unitrect hs.geometry
---@return hs.geometry rect
function screen:fromUnitRect(unitrect) end

--- Returns the screen frame, including the dock and menu.
---@return hs.geometry rect
function screen:fullFrame() end

--- Gets the screen's brightness
---@return number|nil
function screen:getBrightness() end

--- Gets the screen's ForceToGray setting
---@return boolean
function hs.screen.getForceToGray() end

--- Gets the current whitepoint and blackpoint of the screen
---@return whitepoint
---@return blackpoint|nil
function screen:getGamma() end

--- Gets a table of information about an
--- hs.screen
--- object
---@return table|nil
function screen:getInfo() end

--- Gets the screen's InvertedPolarity setting
---@return boolean
function hs.screen.getInvertedPolarity() end

--- Gets the UUID of an
--- hs.screen
--- object
---@return string
function screen:getUUID() end

--- Returns a screen's unique ID
---@return number
function screen:id() end

--- Transforms from the screen's local coordinate space, where
--- 0,0
--- is at the screen's top left corner, to the absolute coordinate space used by OSX/Hammerspoon
---@param geom hs.geometry
---@return hs.geometry
function screen:localToAbsolute(geom) end

--- Make this screen mirror another
---@param aScreen hs.screen
---@param permanent? any
---@return boolean
function screen:mirrorOf(aScreen, permanent) end

--- Stops this screen mirroring another
---@param permanent any
---@return boolean
function screen:mirrorStop(permanent) end

--- Returns the preferred name for the screen set by the manufacturer
---@return string|nil
function screen:name() end

--- Gets the screen 'after' this one (in arbitrary order); this method wraps around to the first screen.
---@return screen
function screen:next() end

--- Return a given screen's position relative to the primary screen - see 'hs.screen.screenPositions()'
---@return x
---@return y
function screen:position() end

--- Gets the screen 'before' this one (in arbitrary order); this method wraps around to the last screen.
---@return screen
function screen:previous() end

--- Gets/Sets the rotation of a screen
---@param degrees any
---@return boolean|rotation angle
function screen:rotate(degrees) end

--- Sets the screen's brightness
---@param brightness number
---@return hs.screen
function screen:setBrightness(brightness) end

--- Sets the screen's ForceToGray mode
---@param ForceToGray boolean
function hs.screen.setForceToGray(ForceToGray) end

--- Sets the current white point and black point of the screen
---
--- Note: If the whitepoint and blackpoint specified, are very similar, it will be impossible to read the screen. You
--- should exercise caution, and may wish to bind a hotkey to hs.screen.restoreGamma() when experimenting
---@param whitepoint any
---@param blackpoint any
---@return boolean
function screen:setGamma(whitepoint, blackpoint) end

--- Sets the screen's InvertedPolarity mode
---@param InvertedPolarity boolean
function hs.screen.setInvertedPolarity(InvertedPolarity) end

--- Sets the screen to a new mode
---
--- Note: The available widths/heights/scales can be seen in the output of hs.screen:availableModes() , however, it
--- should be noted that the CoreGraphics subsystem seems to list more modes for a given screen than it is actually
--- prepared to set, so you may find that seemingly valid modes still return false. It is not currently understood why
--- this is so!
---@param width number
---@param height number
---@param scale number
---@param frequency number
---@param depth number
---@return boolean
function screen:setMode(width, height, scale, frequency, depth) end

--- Sets the origin of a screen in the global display coordinate space. The origin of the main or primary display is
--- (0,0). The new origin is placed as close as possible to the requested location, without overlapping or leaving a
--- gap between displays. If you use this function to change the origin of a mirrored display, the display may be
--- removed from the mirroring set.
---@param x number
---@param y number
---@return boolean
function screen:setOrigin(x, y) end

--- Sets the screen to be the primary display (i.e. contain the menubar and dock)
---@return boolean
function screen:setPrimary() end

--- Saves an image of the screen to a JPG file
---@param filePath string
---@param screenRect? hs.geometry|nil
---@return any
function screen:shotAsJPG(filePath, screenRect) end

--- Saves an image of the screen to a PNG file
---@param filePath string
---@param screenRect? hs.geometry|nil
---@return any
function screen:shotAsPNG(filePath, screenRect) end

--- Captures an image of the screen
---@param rect table|nil
---@return object
function screen:snapshot(rect) end

--- Gets the first screen to the east of this one, ordered by proximity to its center or a specified point.
---@param from hs.geometry.rect|hs.geometry.point
---@param strict hs.screen.strictScreenInDirection
---@return hs.screen
function screen:toEast(from, strict) end

--- Gets the first screen to the north of this one, ordered by proximity to its center or a specified point.
---@param from hs.geometry.rect|hs.geometry.point
---@param strict hs.screen.strictScreenInDirection
---@return hs.screen
function screen:toNorth(from, strict) end

--- Gets the first screen to the south of this one, ordered by proximity to its center or a specified point.
---@param from hs.geometry.rect|hs.geometry.point
---@param strict hs.screen.strictScreenInDirection
---@return hs.screen
function screen:toSouth(from, strict) end

--- Returns the unit rect of a given rect, relative to this screen
---
--- Note: this method is just a convenience wrapper for hs.geometry.toUnitRect(rect,this_screen:frame())
---@param rect hs.geometry
---@return hs.geometry unitrect
function screen:toUnitRect(rect) end

--- Gets the first screen to the west of this one, ordered by proximity to its center or a specified point.
---@param from hs.geometry.rect|hs.geometry.point
---@param strict hs.screen.strictScreenInDirection
---@return hs.screen
function screen:toWest(from, strict) end

-- ------------------------------------------------------------
-- hs.screen.watcher
-- ------------------------------------------------------------

---@class hs.screen.watcher
hs.screen.watcher = {}

---@class watcher
local watcher = {}

--- Creates a new screen-watcher.
---
--- Note: A screen layout change usually involves a change that is made from the Displays Preferences Panel or when a
--- monitor is attached or removed. It can also be caused by a change in the Dock size or presence.
---@param fn function
---@return watcher
function hs.screen.watcher.new(fn) end

--- Creates a new screen-watcher that is also called when the active screen changes.
---
--- Note: nil was chosen instead of false for the argument type when this type of change occurs to more closely match
--- the previous behavior of having no argument passed to the callback function.
--- Detecting a change in the active display relies on watching for the NSWorkspaceActiveDisplayDidChangeNotification
--- message which is not documented by Apple.  While this message has been around at least since OS X 10.9, because it
--- is undocumented, we cannot be positive that Apple won't remove it in a future OS X update.  Because this watcher
--- works by listening for posted messages, should Apple remove this notification, your callback function will no
--- longer receive messages about this change -- it won't crash or change behavior in any other way.  This
--- documentation will be updated if this status changes.
--- Plugging in or unplugging a monitor can cause both a screen layout callback and an active screen change callback.
---@param fn function
---@return watcher
function hs.screen.watcher.newWithActiveScreen(fn) end

--- Starts the screen watcher, making it so fn is called each time the screen arrangement changes
---@return watcher
function watcher:start() end

--- Stops the screen watcher's fn from getting called until started again
---@return watcher
function watcher:stop() end

-- ------------------------------------------------------------
-- hs.serial
-- ------------------------------------------------------------

---@class hs.serial
hs.serial = {}

---@class serial
local serial = {}

--- Returns a table of currently connected serial ports details, organised by port name.
---@return table
function hs.serial.availablePortDetails() end

--- Returns a table of currently connected serial ports names.
---@return table
function hs.serial.availablePortNames() end

--- Returns a table of currently connected serial ports paths.
---@return table
function hs.serial.availablePortPaths() end

--- A callback that's triggered when a serial port is added or removed from the system.
---
--- Note: devices - A table containing the names of any serial ports connected as strings.
---@param callbackFn function|nil
---@return none
function hs.serial.deviceCallback(callbackFn) end

--- Creates a new
--- hs.serial
--- object using the port name.
---
--- Note: A valid port name can be found by checking hs.serial.availablePortNames() .
---@param portName string
---@return serialPortObject
function hs.serial.newFromName(portName) end

--- Creates a new
--- hs.serial
--- object using a path.
---
--- Note: A valid port name can be found by checking hs.serial.availablePortPaths() .
---@param path string
---@return serialPortObject
function hs.serial.newFromPath(path) end

--- Gets or sets the baud rate for the serial port.
---
--- Note: This function supports the following standard baud rates as numbers: 300, 1200, 2400, 4800, 9600, 14400,
--- 19200, 28800, 38400, 57600, 115200, 230400.
--- If no baud rate is supplied, it defaults to 115200.
---@param value number|nil
---@param allowNonStandardBaudRates boolean
---@return number|serialPortObject
function serial:baudRate(value, allowNonStandardBaudRates) end

--- Sets or removes a callback function for the
--- hs.serial
--- object.
---
--- Note: serialPortObject - The serial port object that triggered the callback.
--- callbackType - A string containing "opened", "closed", "received", "removed" or "error".
--- message - If the callbackType is "received", then this will be the data received as a string. If the callbackType
--- is "error", this will be the error message as a string.
--- hexadecimalString - If the callbackType is "received", then this will be the data received as a hexadecimal string.
---@param callbackFn function
---@return serialPortObject
function serial:callback(callbackFn) end

--- Closes the serial port.
---@return serialPortObject
function serial:close() end

--- Gets or sets the number of data bits for the serial port.
---@param value number|nil
---@return number|serialPortObject
function serial:dataBits(value) end

--- Gets or sets the state of the serial port's DTR (Data Terminal Ready) pin.
---
--- Note: The default value is false .
--- Setting this to true is most likely required for Arduino devices prior to opening the serial port.
---@param value boolean|nil
---@return boolean|serialPortObject
function serial:dtr(value) end

--- Gets whether or not a serial port is open.
---@return boolean
function serial:isOpen() end

--- Returns the name of a
--- hs.serial
--- object.
---@return string
function serial:name() end

--- Opens the serial port.
---@return serialPortObject|nil
function serial:open() end

--- Gets or sets the parity for the serial port.
---@param value string|nil
---@return string|serialPortObject
function serial:parity(value) end

--- Returns the path of a
--- hs.serial
--- object.
---@return string
function serial:path() end

--- Gets or sets the state of the serial port's RTS (Request to Send) pin.
---
--- Note: The default value is false .
--- Setting this to true is most likely required for Arduino devices prior to opening the serial port.
---@param value boolean|nil
---@return boolean|serialPortObject
function serial:rts(value) end

--- Sends data via a serial port.
---@param value string
---@return none
function serial:sendData(value) end

--- Gets or sets whether the port should echo received data.
---
--- Note: The default value is false .
---@param value boolean|nil
---@return boolean|serialPortObject
function serial:shouldEchoReceivedData(value) end

--- Gets or sets the number of stop bits for the serial port.
---
--- Note: The default value is 1.
---@param value any
---@return number|serialPortObject
function serial:stopBits(value) end

--- Gets or sets whether the port should use DTR/DSR Flow Control.
---
--- Note: The default value is false .
---@param value boolean|nil
---@return boolean|serialPortObject
function serial:usesDTRDSRFlowControl(value) end

--- Gets or sets whether the port should use RTS/CTS Flow Control.
---
--- Note: The default value is false .
---@param value boolean|nil
---@return boolean|serialPortObject
function serial:usesRTSCTSFlowControl(value) end

-- ------------------------------------------------------------
-- hs.settings
-- ------------------------------------------------------------

---@class hs.settings
hs.settings = {}

--- A string representing the ID of the bundle Hammerspoon's settings are stored in . You can use this with the command
--- line tool
--- defaults
--- or other tools which allow access to the
--- User Defaults
--- of applications, to access these outside of Hammerspoon
---@type string
hs.settings.bundleID = nil

--- A string representing the expected format of date and time when presenting the date and time as a string to
--- hs.setDate()
--- .  e.g.
--- os.date(hs.settings.dateFormat)
---@type string
hs.settings.dateFormat = nil

--- Deletes a setting
---@param key string
---@return boolean
function hs.settings.clear(key) end

--- Loads a setting
---
--- Note: This function can load all of the datatypes supported by hs.settings.set() , hs.settings.setData() and
--- hs.settings.setDate()
---@param key string
---@return string|boolean|number|nil|table
function hs.settings.get(key) end

--- Gets all of the previously stored setting names
---
--- Note: Use ipairs(hs.settings.getKeys()) to iterate over all available settings
--- Use hs.settings.getKeys()["someKey"] to test for the existence of a particular key
---@return table
function hs.settings.getKeys() end

--- Saves a setting with common datatypes
---
--- Note: If no val parameter is provided, it is assumed to be nil
--- This function cannot set dates or raw data types, see hs.settings.setDate() and hs.settings.setData()
--- Assigning a nil value is equivalent to clearing the value with hs.settings.clear
---@param key string
---@param val? any
---@return any
function hs.settings.set(key, val) end

--- Saves a setting with raw binary data
---@param key string
---@param val any
---@return any
function hs.settings.setData(key, val) end

--- Saves a setting with a date
---
--- Note: See hs.settings.dateFormat for a convenient representation of the RFC3339 format, to use with other time/date
--- related functions
---@param key string
---@param val number
---@return any
function hs.settings.setDate(key, val) end

--- Get or set a watcher to invoke a callback when the specified settings key changes
---
--- Note: the identifier is required so that multiple callbacks for the same key can be registered by separate modules;
--- it's value doesn't affect what is being watched but does need to be unique between multiple watchers of the same
--- key.
--- Does not work with keys that include a period (.) in the key name because KVO uses dot notation to specify a
--- sequence of properties.  If you know of a way to escape periods so that they are watchable as NSUSerDefault key
--- names, please file an issue and share!
---@param identifier function
---@param key string
---@param fn function
---@return identifier
function hs.settings.watchKey(identifier, key, fn) end

-- ------------------------------------------------------------
-- hs.sharing
-- ------------------------------------------------------------

---@class hs.sharing
hs.sharing = {}

---@class sharing
local sharing = {}

--- A table containing the predefined sharing service labels defined by Apple.
---@type table
hs.sharing.builtinSharingServices[] = nil

--- Returns a table representing a file URL for the path specified.
---
--- Note: this function is a wrapper to hs.sharing.URL which sets the second argument to true for you.
--- see hs.sharing.URL for more information about the table format returned by this function.
---@param path string
---@return table
function hs.sharing.fileURL(path) end

--- Returns a table containing the sharing service identifiers which can share the items specified.
---
--- Note: this function is intended to be used to determine the identifiers for sharing services available on your
--- computer and that may not be included in the hs.sharing.builtinSharingServices table.
---@param items items[]
---@return identifiersTable
function hs.sharing.shareTypesFor(items) end

--- Returns a table representing the URL specified.
---
--- Note: If the URL is specified as a table, it is expected to contain a url key with a string value specifying a
--- proper schema and resource locator.
--- Because macOS requires URLs to be represented as a specific object type which has no exact equivalent in Lua,
--- Hammerspoon uses a table with specific keys to allow proper identification of a URL when included as an argument or
--- result type.  Use this function or the hs.sharing.fileURL wrapper function when specifying a URL to ensure that the
--- proper keys are defined.
--- url           - a string containing the URL with a proper schema and resource locator
--- filePath      = a string specifying the actual path to the file in case the url is a file reference URL.  Note that
--- setting this field with this method will be silently ignored; the field is automatically inserted if appropriate
--- when returning an NSURL object to lua.
--- __luaSkinType - a string specifying the macOS type this table represents when converted into an Objective-C type
---@param URL string
---@param fileURL string
---@return table
function hs.sharing.URL(URL, fileURL) end

--- Creates a new sharing object of the type specified by the identifier provided.
---@param type string
---@return sharingObject
function hs.sharing.newShare(type) end

--- The account name used by the sharing service when posting on Twitter or Sina Weibo.
---
--- Note: According to the Apple API documentation, only the Twitter and Sina Weibo sharing services will set this
--- property, but this has not been fully tested.
---@return string|nil
function sharing:accountName() end

--- Returns an alternate image, if one exists, representing the sharing service provided by this sharing object.
---@return hs.image|nil
function sharing:alternateImage() end

--- If the sharing service provides an array of the attachments included when the data was posted, this method will
--- return an array of file URL tables of the attachments.
---
--- Note: not all sharing services will set a value for this property.
---@return table|nil
function sharing:attachments() end

--- Set or clear the callback for the sharingObject.
---
--- Note: the sharingObject itself
--- "didFail"   - an error occurred while attempting to share the items
--- "didShare"  - the sharing service has finished sharing the items
--- "willShare" - the sharing service is about to start sharing the items; occurs before sharing actually begins
--- an array (table) containing the items being shared; if the message is "didFail" or "didShare", the items may be in
--- a different order or converted to a different internal type to facilitate sharing.
--- if the message is "didFail", the fourth argument will be a localized description of the error that occurred.
---@param fn function|nil
---@return sharingObject
function sharing:callback(fn) end

--- Returns a boolean specifying whether or not all of the items specified can be shared with the sharing service
--- represented by the sharingObject.
---@param items items[]
---@return boolean
function sharing:canShareItems(items) end

--- Returns an image, if one exists, representing the sharing service provided by this sharing object.
---@return hs.image|nil
function sharing:image() end

--- If the sharing service provides the message body that was posted when sharing has completed, this method will
--- return the message body as a string.
---
--- Note: not all sharing services will set a value for this property.
---@return string|nil
function sharing:messageBody() end

--- If the sharing service provides a permanent link to the post when sharing has completed, this method will return
--- the corresponding URL.
---
--- Note: not all sharing services will set a value for this property.
---@return URL table|nil
function sharing:permanentLink() end

--- Get or set the subject to be used when the sharing service performs its sharing method.
---
--- Note: not all sharing services will make use of the value set by this method.
--- the individual recipients should be specified as strings in the format expected by the sharing service; e.g. for
--- items being shared in an email, the recipients should be email address, etc.
---@param recipients recipient[]|nil
---@return sharingObject
function sharing:recipients(recipients) end

--- The service identifier for the sharing service represented by the sharingObject.
---
--- Note: this string will match the identifier used to create the sharing service object with hs.sharing.newShare
---@return string
function sharing:serviceName() end

--- Shares the items specified with the sharing service represented by the sharingObject.
---
--- Note: You can check to see if all of your items can be shared with the hs.sharing:canShareItems method.
---@param items items[]
---@return sharingObject
function sharing:shareItems(items) end

--- Get or set the subject to be used when the sharing service performs its sharing method.
---
--- Note: not all sharing services will make use of the value set by this method.
---@param subject string|nil
---@return sharingObject
function sharing:subject(subject) end

--- The title for the sharing service represented by the sharingObject.
---
--- Note: this string differs from the identifier used to create the sharing service object with hs.sharing.newShare
--- and is intended to provide a more friendly label for the service if you need to list or refer to it elsewhere.
---@return string
function sharing:title() end

-- ------------------------------------------------------------
-- hs.shortcuts
-- ------------------------------------------------------------

---@class hs.shortcuts
hs.shortcuts = {}

--- Returns a list of available shortcuts
---@return []
function hs.shortcuts.list() end

--- Execute a Shortcuts shortcut by name
---@param name string
---@return any
function hs.shortcuts.run(name) end

-- ------------------------------------------------------------
-- hs.socket
-- ------------------------------------------------------------

---@class hs.socket
hs.socket = {}

---@class socket
local socket = {}

--- Timeout for the socket operations, in seconds.
---@type any
hs.socket.timeout = nil

--- Parses a binary socket address structure into a readable table.
---
--- Note: Some address family definitions from <sys/socket.h> :
--- address family | number | description
--- :--- | :--- | :
--- AF_UNSPEC | 0 | unspecified
--- AF_UNIX | 1 | local to host (pipes)
--- AF_LOCAL | AF_UNIX | backward compatibility
--- AF_INET | 2 | internetwork: UDP, TCP, etc.
--- AF_NS | 6 | XEROX NS protocols
--- AF_CCITT | 10 | CCITT protocols, X.25 etc
--- AF_APPLETALK | 16 | Apple Talk
--- AF_ROUTE | 17 | Internal Routing Protocol
--- AF_LINK | 18 | Link layer interface
--- AF_INET6 | 30 | IPv6
---@param sockaddr hs.socket.udp
---@return table|nil
function hs.socket.parseAddress(sockaddr) end

--- Creates an unconnected asynchronous TCP socket object.
---@param fn function|nil
---@return hs.socket
function hs.socket.new(fn) end

--- Creates a TCP socket, and binds it to either a port or path (Unix domain socket) for listening.
---@param port | path string
---@param fn? function|nil
---@return hs.socket
function hs.socket.server(port | path, fn) end

--- Connects an unconnected socket.
---
--- Note: Either a host/port pair OR a Unix domain socket path must be supplied. If no port is passed, the first
--- parameter is assumed to be a path to the socket file.
---@param host string
---@param port | path string
---@param fn? function|nil
---@return self|nil
function socket:connect(host, port | path, fn) end

--- Returns the connection status of the socket.
---
--- Note: If the socket is bound for listening, this method returns true if there is at least one connection.
---@return boolean
function socket:connected() end

--- Returns the number of connections to the socket.
---
--- Note: This method returns at most 1 for default (non-listening) sockets.
---@return number
function socket:connections() end

--- Disconnects the socket, freeing it for reuse.
---
--- Note: If called on a listening socket with multiple connections, each client is disconnected.
---@return self
function socket:disconnect() end

--- Returns information about the socket.
---@return table
function socket:info() end

--- Binds an unconnected socket to either a port or path (Unix domain socket) for listening.
---@param port|path string
---@return self|nil
function socket:listen(port|path) end

--- Read data from the socket.
---
--- Note: Results are passed to the socket's callback function , which must be set to use this method.
--- If called on a listening socket with multiple connections, data is read from each of them.
---@param delimiter any
---@param tag? function|nil
---@return self|nil
function socket:read(delimiter, tag) end

--- Alias for
--- hs.socket:read
---@param delimiter any
---@param tag? any
---@return self
function socket:receive(delimiter, tag) end

--- Alias for
--- hs.socket:write
---@param message string
---@param tag? any
---@return self
function socket:send(message, tag) end

--- Sets the read callback for the socket.
---
--- Note: A callback must be set in order to read data from the socket.
---@param fn function
---@return self
function socket:setCallback(fn) end

--- Sets the timeout for the socket operations.
---
--- Note: If the timeout value is negative, the operations will not use a timeout, which is the default.
---@param timeout number
---@return self
function socket:setTimeout(timeout) end

--- Secures the socket with TLS.
---
--- Note: The socket will disconnect immediately if TLS negotiation fails.
--- IMPORTANT SECURITY NOTE : The default settings will check to make sure the remote party's certificate is signed by
--- a trusted 3rd party certificate agency (e.g. verisign) and that the certificate is not expired.  However it will
--- not verify the name on the certificate unless you give it a name to verify against via peerName .  The security
--- implications of this are important to understand.  Imagine you are attempting to create a secure connection to
--- MySecureServer.com, but your socket gets directed to MaliciousServer.com because of a hacked DNS server.  If you
--- simply use the default settings, and MaliciousServer.com has a valid certificate, the default settings will not
--- detect any problems since the certificate is valid.  To properly secure your connection in this particular scenario
--- you should set peerName to "MySecureServer.com".
---@param verify boolean|nil
---@param peerName? string|nil
---@return self
function socket:startTLS(verify, peerName) end

--- Write data to the socket.
---
--- Note: If called on a listening socket with multiple connections, data is broadcast to all connected sockets.
---@param message string
---@param tag? number|nil
---@param fn? function|nil
---@return self
function socket:write(message, tag, fn) end

-- ------------------------------------------------------------
-- hs.socket.udp
-- ------------------------------------------------------------

---@class hs.socket.udp
hs.socket.udp = {}

---@class udp
local udp = {}

--- Timeout for the socket operations, in seconds.
---@type any
hs.socket.udp.timeout = nil

--- Alias for
--- hs.socket.parseAddress
---@param sockaddr any
---@return table|nil
function hs.socket.udp.parseAddress(sockaddr) end

--- Creates an unconnected asynchronous UDP socket object.
---@param fn function|nil
---@return hs.socket.udp
function hs.socket.udp.new(fn) end

--- Creates a UDP socket, and binds it to a port for listening.
---@param port number
---@param fn? function|nil
---@return hs.socket.udp
function hs.socket.udp.server(port, fn) end

--- Enables broadcasting on the underlying socket.
---
--- Note: By default, the underlying socket in the OS will not allow you to send broadcast messages.
--- In order to send broadcast messages, you need to enable this functionality in the socket.
--- A broadcast is a UDP message to addresses like "192.168.255.255" or "255.255.255.255" that is delivered to every
--- host on the network.
--- The reason this is generally disabled by default (by the OS) is to prevent accidental broadcast messages from
--- flooding the network.
---@param flag boolean|nil
---@return self|nil
function udp:broadcast(flag) end

--- Immediately closes the socket, freeing it for reuse. Any pending send operations are discarded.
---@return self
function udp:close() end

--- Returns the closed status of the socket.
---
--- Note: UDP sockets are typically meant to be connectionless.
--- Sending a packet anywhere, regardless of whether or not the destination receives it, opens the socket until it is
--- explicitly closed.
--- An active listening socket will not be closed, but will not be 'connected' unless the hs.socket.udp:connect method
--- has been called.
---@return boolean
function udp:closed() end

--- Connects an unconnected socket.
---
--- Note: By design, UDP is a connectionless protocol, and connecting is not needed.
--- You will only be able to send data to the connected host/port;
--- You will only be able to receive data from the connected host/port;
--- You will receive ICMP messages that come from the connected host/port, such as "connection refused".
--- The actual process of connecting a UDP socket does not result in any communication on the socket, it simply changes
--- the internal state of the socket.
--- You cannot bind a socket for listening after it has been connected.
--- You can only connect a socket once.
---@param host string
---@param port number
---@param fn? function|nil
---@return self|nil
function udp:connect(host, port, fn) end

--- Returns the connection status of the socket.
---
--- Note: UDP sockets are typically meant to be connectionless.
--- This method will only return true if the hs.socket.udp:connect method has been explicitly called.
---@return boolean
function udp:connected() end

--- Enables or disables IPv4 or IPv6 on the underlying socket. By default, both are enabled.
---
--- Note: hs.socket.udp.new(callback):enableIPv(4, false):listen(port):receive()
--- The convenience constructor hs.socket.server will automatically bind the socket and requires closing and
--- relistening to use this method.
---@param version number
---@param flag? boolean
---@return self|nil
function udp:enableIPv(version, flag) end

--- Returns information about the socket.
---@return table
function udp:info() end

--- Binds an unconnected socket to a port for listening.
---@param port number
---@return self|nil
function udp:listen(port) end

--- Suspends reading of packets from the socket.
---
--- Note: Call one of the receive methods to resume.
---@return self
function udp:pause() end

--- Sets the preferred IP version: IPv4, IPv6, or neutral (first to resolve).
---
--- Note: If a DNS lookup returns only IPv4 results, the socket will automatically use IPv4.
--- If a DNS lookup returns only IPv6 results, the socket will automatically use IPv6.
--- If a DNS lookup returns both IPv4 and IPv6 results, then the protocol used depends on the configured preference.
---@param version any
---@return self
function udp:preferIPv(version) end

--- Alias for
--- hs.socket.udp:receive
---@param delimiter any
---@param tag? any
---@return self
function udp:read(delimiter, tag) end

--- Alias for
--- hs.socket.udp:receiveOne
---@param delimiter any
---@param tag? any
---@return self
function udp:readOne(delimiter, tag) end

--- Reads packets from the socket as they arrive.
---
--- Note: Results are passed to the callback function , which must be set to use this method.
--- There are two modes of operation for receiving packets: one-at-a-time & continuous.
--- In one-at-a-time mode, you call receiveOne every time you are ready process an incoming UDP packet.
--- Receiving packets one-at-a-time may be better suited for implementing certain state machine code where your state
--- machine may not always be ready to process incoming packets.
--- In continuous mode, the callback is invoked immediately every time incoming udp packets are received.
--- Receiving packets continuously is better suited to real-time streaming applications.
--- You may switch back and forth between one-at-a-time mode and continuous mode.
--- If the socket is currently in one-at-a-time mode, calling this method will switch it to continuous mode.
---@param fn function|nil
---@return self|nil
function udp:receive(fn) end

--- Reads a single packet from the socket.
---
--- Note: Results are passed to the callback function , which must be set to use this method.
--- There are two modes of operation for receiving packets: one-at-a-time & continuous.
--- In one-at-a-time mode, you call receiveOne every time you are ready process an incoming UDP packet.
--- Receiving packets one-at-a-time may be better suited for implementing certain state machine code where your state
--- machine may not always be ready to process incoming packets.
--- In continuous mode, the callback is invoked immediately every time incoming udp packets are received.
--- Receiving packets continuously is better suited to real-time streaming applications.
--- You may switch back and forth between one-at-a-time mode and continuous mode.
--- If the socket is currently in continuous mode, calling this method will switch it to one-at-a-time mode
---@param fn function|nil
---@return self|nil
function udp:receiveOne(fn) end

--- Enables port reuse on the socket.
---
--- Note: By default, only one socket can be bound to a given IP address & port at a time.
--- To enable multiple processes to simultaneously bind to the same address & port, you need to enable this
--- functionality in the socket.
--- All processes that wish to use the address & port simultaneously must all enable reuse port on the socket bound to
--- that port.
--- Must be called before binding the socket.
---@param flag boolean|nil
---@return self|nil
function udp:reusePort(flag) end

--- Sends a packet to the destination address.
---
--- Note: For non-connected sockets, the remote destination is specified for each packet.
--- If the socket has been explicitly connected with connect , only the message parameter and an optional tag and/or
--- write callback can be supplied.
--- Recall that connecting is optional for a UDP socket.
--- For connected sockets, data can only be sent to the connected address.
---@param message string
---@param host? string
---@param port? number
---@param tag? number|nil
---@param fn? function|nil
---@return self
function udp:send(message, host, port, tag, fn) end

--- Sets the maximum size of the buffer that will be allocated for receive operations.
---
--- Note: The default maximum size is 9216 bytes.
--- The theoretical maximum size of any IPv4 UDP packet is UINT16_MAX = 65535 .
--- The theoretical maximum size of any IPv6 UDP packet is UINT32_MAX = 4294967295 .
--- Since the OS notifies us of the size of each received UDP packet, the actual allocated buffer size for each packet
--- is exact.
--- In practice the size of UDP packets is generally much smaller than the max. Most protocols will send and receive
--- packets of only a few bytes, or will set a limit on the size of packets to prevent fragmentation in the IP layer.
--- If you set the buffer size too small, the sockets API in the OS will silently discard any extra data.
---@param size number
---@param version? any
---@return self
function udp:setBufferSize(size, version) end

--- Sets the read callback for the socket.
---
--- Note: A callback must be set in order to read data from the socket.
---@param fn function
---@return self
function udp:setCallback(fn) end

--- Sets the timeout for the socket operations.
---
--- Note: If the timeout value is negative, the operations will not use a timeout, which is the default.
---@param timeout number
---@return self
function udp:setTimeout(timeout) end

--- Alias for
--- hs.socket.udp:send
---@param message string
---@param tag? any
---@return self
function udp:write(message, tag) end

-- ------------------------------------------------------------
-- hs.sound
-- ------------------------------------------------------------

---@class hs.sound
hs.sound = {}

---@class sound
local sound = {}

--- Gets a table of installed Audio Units Effect names.
---
--- Note: Example usage: hs.inspect(hs.audiounit.getAudioEffectNames())
---@return table
function hs.sound.getAudioEffectNames() end

--- Gets the supported sound file types
---
--- Note: This function is unlikely to be tremendously useful, as filename extensions are essentially meaningless. The
--- data returned by hs.sound.soundTypes() is far more valuable
---@return table
function hs.sound.soundFileTypes() end

--- Gets the supported UTI sound file formats
---@return table
function hs.sound.soundTypes() end

--- Gets a table of available system sounds
---
--- Note: The sounds listed by this function can be loaded using hs.sound.getByName()
---@return table
function hs.sound.systemSounds() end

--- Creates an
--- hs.sound
--- object from a file
---@param path string
---@return sound|nil
function hs.sound.getByFile(path) end

--- Creates an
--- hs.sound
--- object from a named sound
---
--- Note: Sounds can only be loaded by name if they are System Sounds (i.e. those found in ~/Library/Sounds,
--- /Library/Sounds, /Network/Library/Sounds and /System/Library/Sounds) or are sound files that have previously been
--- loaded and named
---@param name string
---@return sound|nil
function hs.sound.getByName(name) end

--- Get or set the current seek offset within an
--- hs.sound
--- object.
---@param seekTime number|nil
---@return soundObject|seconds
function sound:currentTime(seekTime) end

--- Get or set the playback device to use for an
--- hs.sound
--- object
---
--- Note: To obtain the UID of a sound device, see hs.audiodevice:uid()
---@param deviceUID hs.audiodevice|nil
---@return soundObject|UID string
function sound:device(deviceUID) end

--- Gets the length of an
--- hs.sound
--- object
---@return seconds
function sound:duration() end

--- Gets the current playback state of an
--- hs.sound
--- object
---@return boolean
function sound:isPlaying() end

--- Get or set the looping behaviour of an
--- hs.sound
--- object
---
--- Note: If you have registered a callback function for completion of a sound's playback, it will not be called when
--- the sound loops
---@param loop boolean|nil
---@return soundObject|boolean
function sound:loopSound(loop) end

--- Get or set the name of an
--- hs.sound
--- object
---
--- Note: If remove the sound name by specifying nil , the sound will automatically be set to stop when Hammerspoon is
--- reloaded.
---@param soundName string|nil
---@return soundObject|name string
function sound:name(soundName) end

--- Pauses an
--- hs.sound
--- object
---@return soundObject|boolean
function sound:pause() end

--- Plays an
--- hs.sound
--- object
---@return soundObject|boolean
function sound:play() end

--- Resumes playing a paused
--- hs.sound
--- object
---@return soundObject|boolean
function sound:resume() end

--- Set or remove the callback for receiving completion notification for the sound object.
---
--- Note: state - a boolean flag indicating if the sound completed playing.  Returns true if playback completes
--- properly, or false if a decoding error occurs or if the sound is stopped early with hs.sound:stop .
--- sound - the soundObject userdata
---@param function function
---@return soundObject
function sound:setCallback(function) end

--- Stops playing an
--- hs.sound
--- object
---@return soundObject|boolean
function sound:stop() end

--- Get or set whether a sound should be stopped when Hammerspoon reloads its configuration
---
--- Note: This method can only be used on a named hs.sound object, see hs.sound:name()
---@param stopOnReload boolean|nil
---@return soundObject|boolean
function sound:stopOnReload(stopOnReload) end

--- Get or set the playback volume of an
--- hs.sound
--- object
---@param level number
---@return soundObject|number
function sound:volume(level) end

-- ------------------------------------------------------------
-- hs.spaces
-- ------------------------------------------------------------

---@class hs.spaces
hs.spaces = {}

--- Specifies how long to delay before performing the accessibility actions for
--- hs.spaces.gotoSpace
--- and
--- hs.spaces.removeSpace
---@type hs.spaces.gotoSpace|hs.spaces.removeSpace
hs.spaces.MCwaitTime = nil

--- Returns the currently visible (active) space for the specified screen.
---@param screen hs.screen|hs.screen.mainScreen|hs.screen.primaryScreen|nil
---@return number|nil
---@return error
function hs.spaces.activeSpaceOnScreen(screen) end

--- Returns a key-value table specifying the active spaces for all screens.
---
--- Note: the table returned has its __tostring metamethod set to hs.inspect to simplify inspecting the results when
--- using the Hammerspoon Console.
---@return table|nil
---@return error
function hs.spaces.activeSpaces() end

--- Adds a new space on the specified screen
---
--- Note: This function creates a new space by opening up the Mission Control display and then programmatically
--- invoking the button to add a new space. This is unavoidable. You can  minimize, but not entirely remove, the visual
--- shift to the Mission Control display by by enabling "Reduce motion" in System Preferences -> Accessibility ->
--- Display.
--- If you intend to perform multiple actions which require the Mission Control display ((
--- hs.spaces.missionControlSpaceNames , hs.spaces.addSpaceToScreen , hs.spaces.removeSpace , or hs.spaces.gotoSpace ),
--- you can pass in false as the final argument to prevent the automatic closure of the Mission Control display -- this
--- will reduce the visual side-affects to one transition instead of many.
---@param screen hs.screen|hs.screen.mainScreen|hs.screen.primaryScreen|nil
---@param closeMC any
---@return boolean|nil
---@return errMsg
function hs.spaces.addSpaceToScreen(screen, closeMC) end

--- Returns a Kay-Value table containing the IDs of all spaces for all screens.
---
--- Note: the table returned has its __tostring metamethod set to hs.inspect to simplify inspecting the results when
--- using the Hammerspoon Console.
---@return table|nil
---@return error
function hs.spaces.allSpaces() end

--- Opens the Mission Control display
---
--- Note: Does nothing if the Mission Control display is not currently visible.
--- This function uses Accessibility features provided by the Dock to close Mission Control and is used internally when
--- performing the hs.spaces.gotoSpace , hs.spaces.addSpaceToScreen , and hs.spaces.removeSpace functions.
--- It is possible to invoke the above mentioned functions and prevent them from auto-closing Mission Control -- this
--- may be useful if you wish to perform multiple actions and want to minimize the visual side-effects. You can then
--- use this function when you are done.
function hs.spaces.closeMissionControl() end

--- Returns a table containing information about the managed display spaces
---
--- Note: the format and detail of this table is too complex and varied to describe here; suffice it to say this is the
--- workhorse for this module and a careful examination of this table may be informative, but is not required in the
--- normal course of using this module.
---@return table|nil
---@return error
function hs.spaces.data_managedDisplaySpaces() end

--- Generate a table containing the results of
--- hs.axuielement.buildTree
--- on the Mission Control Accessibility group of the Dock.
---
--- Note: Like hs.spaces.data_managedDisplaySpaces , this function is not required for general usage of this module;
--- rather it is provided for those who wish to examine the internal data that makes this module possible more closely
--- to see if there might be other information or functionality that they would like to explore.
--- Note that the hs.axuielement objects within the table returned will be invalid by the time you can examine them --
--- this is why the attributes and values will also be contained in the resulting tree.
--- Example usage: hs.spaces.data_missionControlAXUIElementData(function(results) hs.console.clearConsole() ;
--- print(hs.inspect(results)) end)
---@param callback hs.axuielement.buildTree
function hs.spaces.data_missionControlAXUIElementData(callback) end

--- Returns the space ID of the currently focused space
---
--- Note: usually the currently active screen will be returned by hs.screen.mainScreen() ; however some full screen
--- applications may have focus without updating which screen is considered "main". You can use this function, and look
--- up the screen UUID with hs.spaces.spaceDisplay to determine the "true" focused screen if required.
---@return number
function hs.spaces.focusedSpace() end

--- Change to the specified space.
---
--- Note: This function changes to a space by opening up the Mission Control display and then programmatically invoking
--- the button to activate the space. This is unavoidable. You can  minimize, but not entirely remove, the visual shift
--- to the Mission Control display by by enabling "Reduce motion" in System Preferences -> Accessibility -> Display.
--- The action of changing to a new space automatically closes the Mission Control display, so unlike (
--- hs.spaces.missionControlSpaceNames , hs.spaces.addSpaceToScreen , and hs.spaces.removeSpace , there is no flag you
--- can specify to leave Mission Control visible. When possible, you should generally invoke this function last if you
--- are performing multiple actions and want to minimize the amount of time the Mission Control display is visible and
--- reduce the visual side affects.
--- The Accessibility elements required to change to a space are not created until the Mission Control display is fully
--- visible. Because of this, there is a built in delay when invoking this function that can be adjusted by changing
--- the value of hs.spaces.MCwaitTime .
---@param spaceID number
---@return boolean|nil
---@return errMsg
function hs.spaces.gotoSpace(spaceID) end

--- Returns a table containing the space names as they appear in Mission Control associated with their space ID. This
--- is provided for informational purposes only -- all of the functions of this module use the spaceID to insure
--- accuracy.
---
--- Note: the table returned has its __tostring metamethod set to hs.inspect to simplify inspecting the results when
--- using the Hammerspoon Console.
--- This function works by opening up the Mission Control display and then grabbing the names from the Accessibility
--- elements created. This is unavoidable. You can  minimize, but not entirely remove, the visual shift to the Mission
--- Control display by by enabling "Reduce motion" in System Preferences -> Accessibility -> Display.
--- If you intend to perform multiple actions which require the Mission Control display (
--- hs.spaces.missionControlSpaceNames , hs.spaces.addSpaceToScreen , hs.spaces.removeSpace , or hs.spaces.gotoSpace ),
--- you can pass in false as the final argument to prevent the automatic closure of the Mission Control display -- this
--- will reduce the visual side-affects to one transition instead of many.
--- the desktop or application name(s) as they appear at the top of the Mission Control screen when you invoke it
--- manually (or with hs.spaces.toggleMissionControl() entered into the Hammerspoon console).
--- hs.host.operatingSystemVersionString()
--- hs.host.locale.current()
--- hs.inspect(hs.host.locale.preferredLanguages())
--- hs.inspect(hs.host.locale.details())
--- hs.spaces.screensHaveSeparateSpaces()
---@param closeMC any
---@return table|nil
---@return error
function hs.spaces.missionControlSpaceNames(closeMC) end

--- Moves the window with the specified windowID to the space specified by spaceID.
---
--- Note: a window can only be moved from a user space to another user space -- you cannot move the window of a full
--- screen (or tiled) application to another space. you also cannot move a window to the same space as a full screen
--- application unless force is set to true and even then it works for floating windows only.
---@param window hs.window
---@param spaceID number
---@param force? boolean|nil
---@return boolean|nil
---@return error
function hs.spaces.moveWindowToSpace(window, spaceID, force) end

--- Opens the Mission Control display
---
--- Note: Does nothing if the Mission Control display is already visible.
--- This function uses Accessibility features provided by the Dock to open up Mission Control and is used internally
--- when performing the hs.spaces.gotoSpace , hs.spaces.addSpaceToScreen , and hs.spaces.removeSpace functions.
--- It is unlikely you will need to invoke this by hand, and the public interface to this function may go away in the
--- future.
function hs.spaces.openMissionControl() end

--- Removes the specified space.
---
--- Note: You cannot remove a currently active space -- move to another one first with hs.spaces.gotoSpace .
--- If a screen has only one user space (i.e. not a full screen application window or tiled set), it cannot be removed.
--- This function removes a space by opening up the Mission Control display and then programmatically invoking the
--- button to remove the specified space. This is unavoidable. You can  minimize, but not entirely remove, the visual
--- shift to the Mission Control display by by enabling "Reduce motion" in System Preferences -> Accessibility ->
--- Display.
--- If you intend to perform multiple actions which require the Mission Control display ((
--- hs.spaces.missionControlSpaceNames , hs.spaces.addSpaceToScreen , hs.spaces.removeSpace , or hs.spaces.gotoSpace ),
--- you can pass in false as the final argument to prevent the automatic closure of the Mission Control display -- this
--- will reduce the visual side-affects to one transition instead of many.
--- The Accessibility elements required to change to a space are not created until the Mission Control display is fully
--- visible. Because of this, there is a built in delay when invoking this function that can be adjusted by changing
--- the value of hs.spaces.MCwaitTime .
---@param spaceID number
---@param closeMC any
---@return boolean|nil
---@return errMsg
function hs.spaces.removeSpace(spaceID, closeMC) end

--- Determine if the user has enabled the "Displays Have Separate Spaces" option within Mission Control.
---@return boolean
function hs.spaces.screensHaveSeparateSpaces() end

--- Sets the initial value for
--- hs.spaces.MCwaitTime
--- to be set to when this module first loads.
---
--- Note: this function uses the hs.settings module to store the default time in the key "hs_spaces_MCwaitTime".
---@param time hs.spaces.MCwaitTime|nil
function hs.spaces.setDefaultMCwaitTime(time) end

--- Returns the screen UUID for the screen that the specified space is on.
---
--- Note: the space does not have to be currently active (visible) to determine which screen the space belongs to.
---@param spaceID number
---@return string|nil
---@return error
function hs.spaces.spaceDisplay(spaceID) end

--- Returns a table containing the IDs of the spaces for the specified screen in their current order.
---
--- Note: the table returned has its __tostring metamethod set to hs.inspect to simplify inspecting the results when
--- using the Hammerspoon Console.
---@param screen hs.screen|hs.screen.mainScreen|hs.screen.primaryScreen|nil
---@return table|nil
---@return error
function hs.spaces.spacesForScreen(screen) end

--- Returns a string indicating whether the space is a user space or a full screen/tiled application space.
---@param spaceID number
---@return string|nil
---@return error
function hs.spaces.spaceType(spaceID) end

--- Toggles the current applications Exposé display
---
--- Note: this is the same functionality as provided by the System Preferences -> Mission Control -> Hot Corners... ->
--- Application Windows setting or the App Exposé trackpad swipe gesture (3 or 4 fingers down).
function hs.spaces.toggleAppExpose() end

--- Toggles the Launch Pad display.
---
--- Note: this is the same functionality as provided by the System Preferences -> Mission Control -> Hot Corners... ->
--- Launch Pad setting, the Launch Pad touchbar icon, or the Launch Pad trackpad swipe gesture (Pinch with thumb and
--- three fingers).
function hs.spaces.toggleLaunchPad() end

--- Toggles the Mission Control display
---
--- Note: this is the same functionality as provided by the System Preferences -> Mission Control -> Hot Corners... ->
--- Mission Control setting, the Mission Control touchbar icon, or the Mission Control trackpad swipe gesture (3 or 4
--- fingers up).
function hs.spaces.toggleMissionControl() end

--- Toggles moving all windows on/off screen to display the desktop underneath.
---
--- Note: this is the same functionality as provided by the System Preferences -> Mission Control -> Hot Corners... ->
--- Desktop setting, the Show Desktop touchbar icon, or the Show Desktop trackpad swipe gesture (Spread with thumb and
--- three fingers).
function hs.spaces.toggleShowDesktop() end

--- Returns a table containing the window IDs of
--- all
--- windows on the specified space
---
--- Note: the table returned has its __tostring metamethod set to hs.inspect to simplify inspecting the results when
--- using the Hammerspoon Console.
--- The list of windows includes all items which are considered "windows" by macOS -- this includes visual elements
--- usually considered unimportant like overlays, tooltips, graphics, off-screen windows, etc. so expect a lot of false
--- positives in the results.
--- In addition, due to the way Accessibility objects work, only those window IDs that are present on the currently
--- visible spaces will be finable with hs.window or exist within hs.window.allWindows() .
--- This function will prune Hammerspoon canvas elements from the list because we "own" these and can identify their
--- window ID's programmatically. This does not help with other applications, however.
--- as hs.window.filter is scheduled to undergo a re-write soon to (hopefully) dramatically speed it up, I am providing
--- this function as is at present for those who wish to experiment with it; however, I hope to make it more useful in
--- the coming months and the contents may change in the future (the format won't, but hopefully the useless extras
--- will disappear requiring less pruning logic on your end).
---@param spaceID number
---@return table|nil
---@return error
function hs.spaces.windowsForSpace(spaceID) end

--- Returns a table containing the space IDs for all spaces that the specified window is on.
---
--- Note: the table returned has its __tostring metamethod set to hs.inspect to simplify inspecting the results when
--- using the Hammerspoon Console.
--- If the window ID does not specify a valid window, then an empty array will be returned.
--- For example, the container windows for hs.canvas objects which have the canJoinAllSpaces behavior set will appear
--- on all spaces and the table returned by this function will contain all spaceIDs for the screen which displays the
--- canvas.
---@param window hs.window
---@return table|nil
---@return error
function hs.spaces.windowSpaces(window) end

-- ------------------------------------------------------------
-- hs.spaces.watcher
-- ------------------------------------------------------------

---@class hs.spaces.watcher
hs.spaces.watcher = {}

---@class watcher
local watcher = {}

--- Creates a new watcher for Space change events
---@param handler function
---@return watcher
function hs.spaces.watcher.new(handler) end

--- Starts the Spaces watcher
---@return any
function watcher:start() end

--- Stops the Spaces watcher
---@return any
function watcher:stop() end

-- ------------------------------------------------------------
-- hs.speech
-- ------------------------------------------------------------

---@class hs.speech
hs.speech = {}

---@class speech
local speech = {}

--- Returns a table containing a variety of properties describing and defining the specified voice.
---
--- Note: All of the names that have been encountered thus far follow this pattern for their full name:
--- com.apple.speech.synthesis.voice.*name* .  You can provide this suffix or not as you prefer when specifying a voice
--- name.
---@param voice any
---@return table
function hs.speech.attributesForVoice(voice) end

--- Returns a list of the currently installed voices for speech synthesis.
---
--- Note: All of the names that have been encountered thus far follow this pattern for their full name:
--- com.apple.speech.synthesis.voice.*name* .  This prefix is normally suppressed unless you pass in true.
---@param full any
---@return array
function hs.speech.availableVoices(full) end

--- Returns the name of the currently selected default voice for the user.  This voice is the voice selected in the
--- System Preferences for Dictation & Speech as the System Voice.
---
--- Note: All of the names that have been encountered thus far follow this pattern for their full name:
--- com.apple.speech.synthesis.voice.*name* .  This prefix is normally suppressed unless you pass in true.
---@param full any
---@return string
function hs.speech.defaultVoice(full) end

--- Returns whether or not the system is currently using a speech synthesizer in any application to generate speech.
---
--- Note: See also hs.speech:speaking .
---@return boolean
function hs.speech.isAnyApplicationSpeaking() end

--- Creates a new speech synthesizer object for use by Hammerspoon.
---
--- Note: All of the names that have been encountered thus far follow this pattern for their full name:
--- com.apple.speech.synthesis.voice.*name* .  You can provide this suffix or not as you prefer when specifying a voice
--- name.
--- You can change the voice later with the hs.speech:voice method.
---@param voice string|nil
---@return synthesizerObject
function hs.speech.new(voice) end

--- Resumes a paused speech synthesizer.
---@return synthesizerObject
function speech:continue() end

--- Returns whether or not the synthesizer is currently paused.
---
--- Note: If an error occurs retrieving this value, the details will be logged in the system logs which can be viewed
--- with the Console application.  You can also have such messages logged to the Hammerspoon console by setting the
--- module's log level to at least Information (This can be done with the following, or similar, command:
--- hs.speech.log.level = 3 .  See hs.logger for more information)
---@return boolean|nil
function speech:isPaused() end

--- Returns whether or not the synthesizer is currently speaking, either to an audio device or to a file.
---
--- Note: If an error occurs retrieving this value, the details will be logged in the system logs which can be viewed
--- with the Console application.  You can also have such messages logged to the Hammerspoon console by setting the
--- module's log level to at least Information (This can be done with the following, or similar, command:
--- hs.speech.log.level = 3 .  See hs.logger for more information)
---@return boolean|nil
function speech:isSpeaking() end

--- Gets or sets the pitch modulation for the synthesizer's voice.
---
--- Note: Pitch modulation is expressed as a floating-point value in the range of 0.000 to 127.000. These values
--- correspond to MIDI note values, where 60.000 is equal to middle C on a piano scale. The most useful speech pitches
--- fall in the range of 40.000 to 55.000. A pitch modulation value of 0.000 corresponds to a monotone in which all
--- speech is generated at the frequency corresponding to the speech pitch. Given a speech pitch value of 46.000, a
--- pitch modulation of 2.000 would mean that the widest possible range of pitches corresponding to the actual
--- frequency of generated text would be 44.000 to 48.000.
--- If an error occurs retrieving or setting this value, the details will be logged in the system logs which can be
--- viewed with the Console application.  You can also have such messages logged to the Hammerspoon console by setting
--- the module's log level to at least Information (This can be done with the following, or similar, command:
--- hs.speech.log.level = 3 .  See hs.logger for more information)
---@param modulation number|nil
---@return synthesizerObject|modulation|nil
function speech:modulation(modulation) end

--- Pauses the output of the speech synthesizer.
---@param where any
---@return synthesizerObject
function speech:pause(where) end

--- Returns the phonemes which would be spoken if the text were to be synthesized.
---
--- Note: This method only returns a phonetic representation of the text if a Macintalk voice has been selected.  The
--- more modern higher quality voices do not use a phonetic representation and an empty string will be returned if this
--- method is used.
--- You can modify the phonetic representation and feed it into hs.speech:speak if you find that the default
--- interpretation is not correct.  You will need to set the input mode to Phonetic by prefixing the text with "[[inpt
--- PHON]]".
--- The specific phonetic symbols recognized by a given voice can be queried by examining the array returned by
--- hs.speech:phoneticSymbols after setting an appropriate voice.
---@param text string
---@return string
function speech:phonemes(text) end

--- Returns an array of the phonetic symbols recognized by the synthesizer for the current voice.
---
--- Note: Symbol      - The textual representation of this phoneme when returned by hs.speech:phonemes or that you
--- should use for this sound when crafting a phonetic string yourself.
--- Opcode      - The numeric opcode passed to the callback for the "willSpeakPhoneme" message corresponding to this
--- phoneme.
--- Example     - An example word which contains the sound the phoneme represents
--- HiliteEnd   - The character position in the Example where this phoneme's sound begins
--- HiliteStart - The character position in the Example where this phoneme's sound ends
--- Only the older, MacinTalk style voices support phonetic text.  The more modern, higher quality voices are not
--- rendered phonetically and will return nil for this method.
--- If an error occurs retrieving this value, the details will be logged in the system logs which can be viewed with
--- the Console application.  You can also have such messages logged to the Hammerspoon console by setting the module's
--- log level to at least Information (This can be done with the following, or similar, command: hs.speech.log.level =
--- 3 .  See hs.logger for more information)
---@return array|nil
function speech:phoneticSymbols() end

--- Gets or sets the base pitch for the synthesizer's voice.
---
--- Note: Typical voice frequencies range from around 90 hertz for a low-pitched male voice to perhaps 300 hertz for a
--- high-pitched child’s voice. These frequencies correspond to approximate pitch values in the ranges of 30.000 to
--- 40.000 and 55.000 to 65.000, respectively.
--- If an error occurs retrieving or setting this value, the details will be logged in the system logs which can be
--- viewed with the Console application.  You can also have such messages logged to the Hammerspoon console by setting
--- the module's log level to at least Information (This can be done with the following, or similar, command:
--- hs.speech.log.level = 3 .  See hs.logger for more information)
---@param pitch number|nil
---@return synthesizerObject|pitch|nil
function speech:pitch(pitch) end

--- Gets or sets the synthesizers speaking rate (words per minute).
---
--- Note: The range of supported rates is not predefined by the Speech Synthesis framework; but the synthesizer may
--- only respond to a limited range of speech rates. Average human speech occurs at a rate of 180.0 to 220.0 words per
--- minute.
---@param rate number|nil
---@return synthesizerObject|rate
function speech:rate(rate) end

--- Reset a synthesizer back to its default state.
---
--- Note: This method will reset a synthesizer to its default state, including pitch, modulation, volume, rate, etc.
--- The changes go into effect immediately, if queried, but will not affect a synthesis in progress.
--- If an error occurs retrieving or setting this value, the details will be logged in the system logs which can be
--- viewed with the Console application.  You can also have such messages logged to the Hammerspoon console by setting
--- the module's log level to at least Information (This can be done with the following, or similar, command:
--- hs.speech.log.level = 3 .  See hs.logger for more information)
---@return synthesizerObject|nil
function speech:reset() end

--- Sets or removes a callback function for the synthesizer.
---
--- Note: provides 3 additional arguments: startIndex, endIndex, and the full text being spoken.
--- startIndex and endIndex can be used as string.sub(text, startIndex, endIndex) to get the specific word being spoken.
--- provides 1 additional argument: the opcode of the phoneme about to be spoken.
--- this callback message will only occur when using Macintalk voices; modern higher quality voices are not
--- phonetically based and will not generate this message.
--- the opcode can be tied to a specific phoneme by looking it up in the table returned by hs.speech:phoneticSymbols .
--- provides 3 additional arguments: the index in the original text where the error occurred, the text being spoken,
--- and an error message.
--- Special Note: I have never been able to trigger this callback message, even with malformed embedded command
--- sequences, so... looking for validation of the code or fixes.  File an issue if you have suggestions.
--- provides 1 additional argument: the synchronization number provided in the text.
--- A synchronization number can be embedded in text to be spoken by including [[sync #]] in the text where you wish
--- the callback to occur.  The number is limited to 32 bits and can be presented as a base 10 or base 16 number
--- (prefix with 0x).
--- provides 1 additional argument: a boolean flag indicating whether or not the synthesizer finished because synthesis
--- is complete (true) or was stopped early with hs.speech:stop (false).
---@param fn function
---@return synthesizerObject
function speech:setCallback(fn) end

--- Starts speaking the provided text through the system's current audio device.
---@param textToSpeak any
---@return synthesizerObject
function speech:speak(textToSpeak) end

--- Returns whether or not this synthesizer is currently generating speech.
---
--- Note: See also hs.speech.isAnyApplicationSpeaking .
---@return boolean
function speech:speaking() end

--- Starts speaking the provided text and saves the audio as an AIFF file.
---@param textToSpeak any
---@param destination any
---@return synthesizerObject
function speech:speakToFile(textToSpeak, destination) end

--- Stops the output of the speech synthesizer.
---@param where any
---@return synthesizerObject
function speech:stop(where) end

--- Gets or sets whether or not the synthesizer uses the speech feedback window.
---
--- Note: Special Note: I am not sure where the visual feedback actually occurs -- I have not been able to locate a
--- feedback window for synthesis in 10.11; however the method is defined and not marked deprecated, so I include it in
--- the module.  If anyone has more information, please file an issue and the documentation will be updated.
---@deprecated
---@param flag any
---@return synthesizerObject|boolean
function speech:usesFeedbackWindow(flag) end

--- Gets or sets the active voice for a synthesizer.
---
--- Note: All of the names that have been encountered thus far follow this pattern for their full name:
--- com.apple.speech.synthesis.voice.*name* .  You can provide this suffix or not as you prefer when specifying a voice
--- name.
--- The voice cannot be changed while the synthesizer is currently producing output.
--- If you change the voice while a synthesizer is paused, the current synthesis will be terminated and the voice will
--- be changed.
---@param full | voice any
---@return synthesizerObject|voice
function speech:voice(full | voice) end

--- Gets or sets the synthesizers speaking volume.
---
--- Note: Volume units lie on a scale that is linear with amplitude or voltage. A doubling of perceived loudness
--- corresponds to a doubling of the volume.
---@param volume number|nil
---@return synthesizerObject|volume
function speech:volume(volume) end

-- ------------------------------------------------------------
-- hs.speech.listener
-- ------------------------------------------------------------

---@class hs.speech.listener
hs.speech.listener = {}

---@class listener
local listener = {}

--- Creates a new speech recognizer object for use by Hammerspoon.
---
--- Note: You can change the title later with the hs.speech.listener:title method.
---@param title string
---@return recognizerObject
function hs.speech.listener.new(title) end

--- Get or set whether or not the speech recognizer should block other recognizers when it is active.
---@param flag any
---@return recognizerObject
function listener:blocksOtherRecognizers(flag) end

--- Get or set the commands this speech recognizer will listen for.
---
--- Note: The list of commands will appear in the Dictation Commands window, if it is visible, under the title of this
--- speech recognizer.  The text of each command is a possible value which may be sent as the second argument to a
--- callback function for this speech recognizer, if one is defined.
--- Setting this to an empty list does not disable the speech recognizer, but it does make it of limited use, other
--- than to provide a title in the Dictation Commands window.  To disable the recognizer, use the
--- hs.speech.listener:stop or hs.speech.listener:delete methods.
---@param commandsArray strings[]|nil
---@return recognizerObject
function listener:commands(commandsArray) end

--- Disables the speech recognizer and removes it from the possible available speech recognizers.
---
--- Note: this disables the speech recognizer and removes it from the list in the Dictation Commands window.  The
--- object is effectively destroyed, so you will need to create a new one with hs.speech.listener.new if you want to
--- bring it back.
--- if this was the only speech recognizer currently available, the Dictation Commands window and feedback display will
--- be removed from the users display.
--- this method is automatically called during a reload or restart of Hammerspoon.
---@return recognizerObject
function listener:delete() end

--- Get or set whether or not the speech recognizer is active only when the Hammerspoon application is active.
---@param flag any
---@return recognizerObject
function listener:foregroundOnly(flag) end

--- Returns a boolean value indicating whether or not the recognizer is currently enabled (started).
---@return boolean
function listener:isListening() end

--- Sets or removes a callback function for the speech recognizer.
---
--- Note: Possible string values for the command spoken are set with the hs.speech.listener:commands method.
--- Removing the callback does not disable the speech recognizer, but it does make it of limited use, other than to
--- provide a list in the Dictation Commands window.  To disable the recognizer, use the hs.speech.listener:stop or
--- hs.speech.listener:delete methods.
---@param fn function
---@return recognizerObject
function listener:setCallback(fn) end

--- Make the speech recognizer active.
---@return recognizerObject
function listener:start() end

--- Disables the speech recognizer.
---
--- Note: this only disables the speech recognizer.  To completely remove it from the list in the Dictation Commands
--- window, use hs.speech.listener:delete .
---@return recognizerObject
function listener:stop() end

--- Get or set the title for a speech recognizer.
---@param title string
---@return recognizerObject
function listener:title(title) end

-- ------------------------------------------------------------
-- hs.spoons
-- ------------------------------------------------------------

---@class hs.spoons
hs.spoons = {}

--- Map a number of hotkeys according to a definition table
---@param def table
---@param map table|nil
---@return none
function hs.spoons.bindHotkeysToSpec(def, map) end

--- Check if a given Spoon is installed.
---@param name string
---@return table|nil
function hs.spoons.isInstalled(name) end

--- Check if a given Spoon is loaded.
---@param name string
---@return boolean|nil
function hs.spoons.isLoaded(name) end

--- Return a list of installed/loaded Spoons
---@return table
function hs.spoons.list() end

--- Create a skeleton for a new Spoon
---@param name string
---@param basedir any
---@param metadata table|nil
---@param template any
---@return string|nil
function hs.spoons.newSpoon(name, basedir, metadata, template) end

--- Return full path of an object within a spoon directory, given its partial path.
---@param partial any
---@return string
function hs.spoons.resourcePath(partial) end

--- Return path of the current spoon.
---@param n any
---@return string
function hs.spoons.scriptPath(n) end

--- Declaratively load and configure a Spoon
---@param name string
---@param arg any
---@param noerror any
---@return boolean|nil
function hs.spoons.use(name, arg, noerror) end

-- ------------------------------------------------------------
-- hs.spotify
-- ------------------------------------------------------------

---@class hs.spotify
hs.spotify = {}

--- Returned by
--- hs.spotify.getPlaybackState()
--- to indicates Spotify is paused
---@type hs.spotify.getPlaybackState
hs.spotify.state_paused = nil

--- Returned by
--- hs.spotify.getPlaybackState()
--- to indicates Spotify is playing
---@type hs.spotify.getPlaybackState
hs.spotify.state_playing = nil

--- Returned by
--- hs.spotify.getPlaybackState()
--- to indicates Spotify is stopped
---@type hs.spotify.getPlaybackState
hs.spotify.state_stopped = nil

--- Displays information for current track on screen
---@return any
function hs.spotify.displayCurrentTrack() end

--- Skips the playback position forwards by 5 seconds
---@return any
function hs.spotify.ff() end

--- Gets the name of the album of the current track
---@return string|nil
function hs.spotify.getCurrentAlbum() end

--- Gets the name of the artist of the current track
---@return string|nil
function hs.spotify.getCurrentArtist() end

--- Gets the name of the current track
---@return string|nil
function hs.spotify.getCurrentTrack() end

--- Gets the artwork URL of the current track
---@return string|nil
function hs.spotify.getCurrentTrackArtworkURL() end

--- Gets the id of the current track
---@return string|nil
function hs.spotify.getCurrentTrackId() end

--- Gets the duration (in seconds) of the current song
---@return number
function hs.spotify.getDuration() end

--- Gets the current playback state of Spotify
---@return hs.spotify.state_stopped|hs.spotify.state_paused|hs.spotify.state_playing
function hs.spotify.getPlaybackState() end

--- Gets the playback position (in seconds) in the current song
---@return number
function hs.spotify.getPosition() end

--- Gets the Spotify volume setting
---@return number
function hs.spotify.getVolume() end

--- Returns whether Spotify is currently playing
---@return boolean|nil
function hs.spotify.isPlaying() end

--- Returns whether Spotify is currently open. Most other functions in hs.spotify will automatically start the
--- application, so this function can be used to guard against that.
---@return boolean
function hs.spotify.isRunning() end

--- Skips to the next Spotify track
---@return any
function hs.spotify.next() end

--- Pauses the current Spotify track
---@return any
function hs.spotify.pause() end

--- Plays the current Spotify track
---@return any
function hs.spotify.play() end

--- Toggles play/pause of current Spotify track
---@return any
function hs.spotify.playpause() end

--- Plays the Spotify track with the given id
---@param id string
---@return any
function hs.spotify.playTrack(id) end

--- Skips to previous Spotify track
---@return any
function hs.spotify.previous() end

--- Skips the playback position backwards by 5 seconds
---@return any
function hs.spotify.rw() end

--- Sets the playback position in the current song
---@param pos number
---@return any
function hs.spotify.setPosition(pos) end

--- Sets the Spotify volume setting
---@param vol number
---@return any
function hs.spotify.setVolume(vol) end

--- Reduces the volume by 5
---@return any
function hs.spotify.volumeDown() end

--- Increases the volume by 5
---@return any
function hs.spotify.volumeUp() end

-- ------------------------------------------------------------
-- hs.spotlight
-- ------------------------------------------------------------

---@class hs.spotlight
hs.spotlight = {}

---@class spotlight
local spotlight = {}

--- A list of defined attribute keys as discovered in the macOS 10.12 SDK framework headers.
---@type defined[]
hs.spotlight.commonAttributeKeys[] = nil

--- A table of key-value pairs describing predefined search scopes for Spotlight queries
---@type table
hs.spotlight.definedSearchScopes[] = nil

--- Creates a new spotlightObject to use for Spotlight searches.
---@return spotlightObject
function hs.spotlight.new() end

--- Creates a new spotlightObject that limits its searches to the current results of another spotlightObject.
---@param spotlightObject any
---@return spotlightObject
function hs.spotlight.newWithin(spotlightObject) end

--- Get or specify the specific messages that should generate a callback.
---
--- Note: Valid messages for the table are: "didFinish", "didStart", "didUpdate", and "inProgress".  See
--- hs.spotlight:setCallback for more details about the messages.
---@param messages function|nil
---@return table|spotlightObject
function spotlight:callbackMessages(messages) end

--- Returns the number of results for the spotlightObject's query
---
--- Note: Just because the result of this method is 0 does not mean that the query has not been started; the query
--- itself may not match any entries in the Spotlight database.
--- A query which ran in the past but has been subsequently stopped will retain its queries unless the parameters have
--- been changed.  The result of this method will indicate the number of results still attached to the query, even if
--- it has been previously stopped.
--- For convenience, metamethods have been added to the spotlightObject which allow you to use #spotlightObject as a
--- shortcut for spotlightObject:count() .
---@return number
function spotlight:count() end

--- Returns the grouped results for a Spotlight query.
---
--- Note: The spotlightItemObjects available with the hs.spotlight.group:resultAtIndex method are the subset of the
--- full results of the spotlightObject that match the attribute and value of the spotlightGroupObject.  The same item
--- is available through the spotlightObject and the spotlightGroupObject, though likely at different indices.
---@return table
function spotlight:groupedResults() end

--- Get or set the grouping attributes for the Spotlight query.
---
--- Note: Setting this property while a query is running stops the query and discards the current results. The receiver
--- immediately starts a new query.
--- Setting this property will increase CPU and memory usage while performing the Spotlight query.
--- This method allows you to access results grouped by the values of specific attributes.  See hs.spotlight.group for
--- more information on using and accessing grouped results.
--- Note that not all attributes can be used as a grouping attribute.  In such cases, the grouped result will contain
--- all results and an attribute value of nil.
---@param attributes items[]|nil
---@return table|spotlightObject
function spotlight:groupingAttributes(attributes) end

--- Returns a boolean specifying whether or not the query is in the active gathering phase.
---
--- Note: An inactive query will also return false for this method since an inactive query is neither gathering nor
--- waiting for updates.  To determine if a query is active or inactive, use the hs.spotlight:isRunning method.
---@return boolean
function spotlight:isGathering() end

--- Returns a boolean specifying if the query is active or inactive.
---
--- Note: An active query may be gathering query results (in the initial gathering phase) or listening for changes
--- which should cause a "didUpdate" message (after the initial gathering phase). To determine which state the query
--- may be in, use the hs.spotlight:isGathering method.
---@return boolean
function spotlight:isRunning() end

--- Specify the query string for the spotlightObject
---
--- Note: Setting this property while a query is running stops the query and discards the current results. The receiver
--- immediately starts a new query.
--- https://developer.apple.com/library/content/documentation/Carbon/Conceptual/SpotlightQuery/Concepts/QueryFormat.html
--- https://developer.apple.com/library/content/documentation/Cocoa/Conceptual/Predicates/Articles/pSyntax.html
--- If the query string does not conform to an NSPredicate query string, this method will return an error.  If the
--- query string does conform to an NSPredicate query string, this method will accept the query string, but if it does
--- not conform to the Metadata query format, which is a subset of the NSPredicate query format, the error will be
--- generated when you attempt to start the query with hs.spotlight:start . At present, starting a query is the only
--- way to fully guarantee that a query is in a valid format.
--- [[ kMDItemContentType == "com.apple.application-bundle" ]]
--- [[ kMDItemFSName like " Explore " ]]
--- [[ kMDItemFSName like "AppleScript Editor.app" or kMDItemAlternateNames like "AppleScript Editor"]]
--- Not all attributes appear to be usable in a query; see hs.spotlight.item:attributes for a possible explanation.
--- As a convenience, the __call metamethod has been setup for spotlightObject so that you can use
--- spotlightObject("query") as a shortcut for spotlightObject:queryString("query"):start .  Because this shortcut
--- includes an explicit start, this should be appended after you have set the callback function if you require a
--- callback (e.g. spotlightObject:setCallback(fn)("query") ).
---@param query number
---@return spotlightObject
function spotlight:queryString(query) end

--- Returns the spotlightItemObject at the specified index of the spotlightObject
---
--- Note: For convenience, metamethods have been added to the spotlightObject which allow you to use
--- spotlightObject[index] as a shortcut for spotlightObject:resultAtIndex(index) .
---@param index number
---@return spotlightItemObject
function spotlight:resultAtIndex(index) end

--- Get or set the search scopes allowed for the Spotlight query.
---
--- Note: Setting this property while a query is running stops the query and discards the current results. The receiver
--- immediately starts a new query.
--- if an item is a string and matches one of the values in the hs.spotlight.definedSearchScopes table, then the scope
--- for that item will be added to the valid search scopes.
--- if an item is a string and does not match one of the predefined values, it is treated as a path on the local system
--- and will undergo tilde prefix expansion befor being added to the search scopes (i.e. "~/" will be expanded to
--- "/Users/username/").
--- if an item is a table, it will be treated as a file URL table.
---@param scope items[]|nil
---@return table|spotlightObject
function spotlight:searchScopes(scope) end

--- Set or remove the callback function for the Spotlight search object.
---
--- Note: obj - the spotlightObject performing the search
--- message - the message to the callback, in this case "didStart"
--- obj - the spotlightObject performing the search
--- message - the message to the callback, in this case "inProgress"
--- kMDQueryUpdateAddedItems - an array table of spotlightItem objects that have been added to the results
--- kMDQueryUpdateChangedItems - an array table of spotlightItem objects that have changed since they were first added
--- to the results
--- kMDQueryUpdateRemovedItems - an array table of spotlightItem objects that have been removed since they were first
--- added to the results
--- obj - the spotlightObject performing the search
--- message - the message to the callback, in this case "didFinish"
--- obj - the spotlightObject performing the search
--- message - the message to the callback, in this case "didUpdate"
--- updateTable - a table containing one or more of the keys described for the updateTable argument of the "inProgress"
--- message.
--- All of the results are always available through the hs.spotlight:resultAtIndex method and metamethod shortcuts
--- described in the hs.spotlight and hs.spotlight.item documentation headers; the results provided by the "didUpdate"
--- and "inProgress" messages are just a convenience and can be used if you wish to parse partial results.
---@param fn function
---@return spotlightObject
function spotlight:setCallback(fn) end

--- Get or set the sorting preferences for the results of a Spotlight query.
---
--- Note: Setting this property while a query is running stops the query and discards the current results. The receiver
--- immediately starts a new query.
--- key - a string specifying the attribute to sort by
--- ascending - a boolean, default true, specifying whether the sort order should be ascending (true) or descending
--- (false).
--- This method attempts to specify the sorting order of the results returned by the Spotlight query.
--- Note that not all attributes can be used as an attribute in a sort descriptor.  In such cases, the sort descriptor
--- will have no affect on the order of returned items.
---@param attributes items[]|nil
---@return table|spotlightObject
function spotlight:sortDescriptors(attributes) end

--- Begin the gathering phase of a Spotlight query.
---
--- Note: If the query string set with hs.spotlight:queryString is invalid, an error message will be logged to the
--- Hammerspoon console and the query will not start.  You can test to see if the query is actually running with the
--- hs.spotlight:isRunning method.
---@return spotlightObject
function spotlight:start() end

--- Stop the Spotlight query.
---
--- Note: This method will prevent further gathering of items either during the initial gathering phase or from updates
--- which may occur after the gathering phase; however it will not discard the results already discovered.
---@return spotlightObject
function spotlight:stop() end

--- Get or set the time interval at which the spotlightObject will send "didUpdate" messages during the initial
--- gathering phase.
---@param interval number|nil
---@return number|spotlightObject
function spotlight:updateInterval(interval) end

--- Get or set the attributes for which value list summaries are produced for the Spotlight query.
---
--- Note: Setting this property while a query is running stops the query and discards the current results. The receiver
--- immediately starts a new query.
--- Setting this property will increase CPU and memory usage while performing the Spotlight query.
--- This method allows you to specify attributes for which you wish to gather summary information about.  See
--- hs.spotlight:valueLists for more information about value list summaries.
--- Note that not all attributes can be used as a value list attribute.  In such cases, the summary for the attribute
--- will specify all results and an attribute value of nil.
---@param attributes items[]|nil
---@return table|spotlightObject
function spotlight:valueListAttributes(attributes) end

--- Returns the value list summaries for the Spotlight query
---
--- Note: Value list summaries are a quick way to gather statistics about the number of results which match certain
--- criteria - they do not allow you easy access to the matching members, just information about their numbers.
---@return table
function spotlight:valueLists() end

-- ------------------------------------------------------------
-- hs.spotlight.group
-- ------------------------------------------------------------

---@class hs.spotlight.group
hs.spotlight.group = {}

---@class group
local group = {}

--- Returns the name of the attribute the spotlightGroupObject results are grouped by.
---@return string
function group:attribute() end

--- Returns the number of query results contained in the spotlightGroupObject.
---
--- Note: For convenience, metamethods have been added to the spotlightGroupObject which allow you to use
--- #spotlightGroupObject as a shortcut for spotlightGroupObject:count() .
---@return number
function group:count() end

--- Returns the spotlightItemObject at the specified index of the spotlightGroupObject
---
--- Note: For convenience, metamethods have been added to the spotlightGroupObject which allow you to use
--- spotlightGroupObject[index] as a shortcut for spotlightGroupObject:resultAtIndex(index) .
---@param index number
---@return spotlightItemObject
function group:resultAtIndex(index) end

--- Returns the subgroups of the spotlightGroupObject
---
--- Note: Subgroups are created when you supply more than one grouping attribute to hs.spotlight:groupingAttributes .
---@return table
function group:subgroups() end

--- Returns the value for the attribute the spotlightGroupObject results are grouped by.
---@return any
function group:value() end

-- ------------------------------------------------------------
-- hs.spotlight.item
-- ------------------------------------------------------------

---@class hs.spotlight.item
hs.spotlight.item = {}

---@class item
local item = {}

--- Returns a list of attributes associated with the spotlightItemObject
---
--- Note: This list of attributes is usually not a complete list of the attributes available for a given
--- spotlightItemObject. Many of the known attribute names are included in the hs.spotlight.commonAttributeKeys
--- constant array, but even this is not an exhaustive list -- an application may create and assign any key it wishes
--- to an entity for inclusion in the Spotlight metadata database.
--- A common attribute, which is not usually included in the results of this method is the "kMDItemPath" attribute
--- which specifies the local path to the file the entity represents. This is included here for reference, as it is a
--- commonly desired value that is not obviously available for almost all Spotlight entries.
--- It is believed that only those keys which are explicitly set when an item is added to the Spotlight database are
--- included in the array returned by this method. Any attribute which is calculated or restricted in a sandboxed
--- application appears to require an explicit request. This is, however, conjecture, and when in doubt you should
--- explicitly check for the attributes you require with hs.spotlight.item:valueForAttribute and not rely solely on the
--- results from this method.
---@return table
function item:attributes() end

--- Returns the value for the specified attribute of the spotlightItemObject
---
--- Note: See hs.spotlight.item:attributes for information about possible attribute names.
--- For convenience, metamethods have been added to the spotlightItemObject which allow you to use
--- spotlightItemObject.attribute as a shortcut for spotlightItemObject:valueForAttribute(attribute) .
---@param attribute string
---@return any
function item:valueForAttribute(attribute) end

-- ------------------------------------------------------------
-- hs.streamdeck
-- ------------------------------------------------------------

---@class hs.streamdeck
hs.streamdeck = {}

---@class streamdeck
local streamdeck = {}

--- Sets/clears a callback for reacting to device discovery events
---@param fn function
---@return any
function hs.streamdeck.discoveryCallback(fn) end

--- Gets an hs.streamdeck object for the specified device
---@param num number
---@return hs.streamdeck
function hs.streamdeck.getDevice(num) end

--- Initialises the Stream Deck driver and sets a discovery callback
---
--- Note: This function must be called before any other parts of this module are used
---@param fn function
---@return any
function hs.streamdeck.init(fn) end

--- Gets the number of Stream Deck devices connected
---@return number
function hs.streamdeck.numDevices() end

--- Sets/clears the button callback function for a Stream Deck device
---@param fn function
---@return hs.streamdeck
function streamdeck:buttonCallback(fn) end

--- Gets the layout of buttons a Stream Deck device has
---@return number
function streamdeck:buttonLayout() end

--- Sets/clears the knob/encoder callback function for a Stream Deck Plus.
---@param fn function
---@return hs.streamdeck
function streamdeck:encoderCallback(fn) end

--- Gets the firmware version of a Stream Deck device
---@return string
function streamdeck:firmwareVersion() end

--- Gets the width and height of the buttons in pixels
---@return table
function streamdeck:imageSize() end

--- Resets a Stream Deck device
---@return hs.streamdeck
function streamdeck:reset() end

--- Sets/clears the screen callback function for a Stream Deck Plus's touch screen (above the encoder knobs).
---@param fn function
---@return hs.streamdeck
function streamdeck:screenCallback(fn) end

--- Gets the serial number of a Stream Deck device
---@return string
function streamdeck:serialNumber() end

--- Sets the brightness of a Stream Deck device
---@param brightness number
---@return hs.streamdeck
function streamdeck:setBrightness(brightness) end

--- Sets a button on the Stream Deck device to the specified color
---@param button number
---@param color hs.drawing.color
---@return hs.streamdeck
function streamdeck:setButtonColor(button, color) end

--- Sets the image of a button on the Stream Deck device
---@param button number
---@param image hs.image
---@return hs.streamdeck
function streamdeck:setButtonImage(button, image) end

--- Sets the image of the screen on the Stream Deck device
---@param encoder number
---@param image hs.image
---@return hs.streamdeck
function streamdeck:setScreenImage(encoder, image) end

-- ------------------------------------------------------------
-- hs.styledtext
-- ------------------------------------------------------------

---@class hs.styledtext
hs.styledtext = {}

---@class styledtext
local styledtext = {}

---@class hs.styledtext.styledtext
---@field defaultFonts any A table containing the system default fonts and sizes.
---@field fontTraits -> table any A table for containing Font Trait masks for use with hs.styledtext.fontNamesWithTraits(...)
---@field lineAppliesTo any A table of values indicating how the line for underlining or strike-through are applied to the text.
---@field linePatterns any A table of patterns which apply to the line for underlining or strike-through.
---@field lineStyles any A table of styles which apply to the line for underlining or strike-through.

--- A table containing the system default fonts and sizes.
---@type table
hs.styledtext.defaultFonts = nil

--- A table for containing Font Trait masks for use with
--- hs.styledtext.fontNamesWithTraits(...)
---@type table
hs.styledtext.fontTraits -> table = nil

--- A table of values indicating how the line for underlining or strike-through are applied to the text.
---@type table
hs.styledtext.lineAppliesTo = nil

--- A table of patterns which apply to the line for underlining or strike-through.
---@type table
hs.styledtext.linePatterns = nil

--- A table of styles which apply to the line for underlining or strike-through.
---@type table
hs.styledtext.lineStyles = nil

--- Returns the font which most closely matches the given font and the trait change requested.
---@param fontTable any
---@param trait number
---@return table
function hs.styledtext.convertFont(fontTable, trait) end

--- Returns the names of all font families installed for the system.
---@return table
function hs.styledtext.fontFamilies() end

--- Get information about the font Specified in the attributes table.
---@param font any
---@return table
function hs.styledtext.fontInfo(font) end

--- Returns the names of all installed fonts for the system.
---@return table
function hs.styledtext.fontNames() end

--- Returns the names of all installed fonts for the system with the specified traits.
---
--- Note: specifying 0 or an empty table will match all fonts that are neither italic nor bold.  This would be the same
--- list as you'd get with { hs.styledtext.fontTraits.unBold, hs.styledtext.fontTraits.unItalic } as the parameter.
---@param fontTraitMask any
---@return table
function hs.styledtext.fontNamesWithTraits(fontTraitMask) end

--- Get the path of a font.
---@param font string
---@return table
function hs.styledtext.fontPath(font) end

--- Returns an array containing fonts available for the specified font family or nil if no fonts for the specified
--- family are present.
---@param familyName string
---@return table
function hs.styledtext.fontsForFamily(familyName) end

--- Loads a font from a file at the specified path.
---@param path string
---@return boolean
---@return string
function hs.styledtext.loadFont(path) end

--- Checks to see if a font is valid.
---@param font string
---@return boolean
function hs.styledtext.validFont(font) end

--- Create an
--- hs.styledtext
--- object from the string provided, converting ANSI SGR color and some font sequences into the appropriate attributes.
--- Attributes to apply to the resulting string may also be optionally provided.
---
--- Note: Because a font is required for the SGR sequences indicating Bold and Italic, the base font is determined
--- using the following logic:
--- if no attributes table is provided, the font is assumed to be the default for hs.drawing as returned by the
--- hs.drawing.defaultTextStyle function
--- if an attributes table is provided and it defines a font attribute, this font is used.
--- if an attributes table is provided, but it does not provide a font attribute, the NSAttributedString default of
--- Helvetica at 12 points is used.
--- As the most common use of this constructor is likely to be from the output of a terminal shell command, you will
--- most likely want to specify a fixed-pitch (monospace) font.  You can get a list of installed fixed-pitch fonts by
--- typing hs.styledtext.fontNamesWithTraits(hs.styledtext.fontTraits.fixedPitchFont) into the Hammerspoon console.
--- See the module description documentation ( help.hs.styledtext ) for a description of the attributes table format
--- which can be provided for the optional second argument.
--- This function was modeled after the ANSIEscapeHelper.m file at https://github.com/balthamos/geektool-3 in the
--- /NerdTool/classes directory.
---@param string string
---@param attributes hs.styledtext|nil
---@return styledText
function hs.styledtext.ansi(string, attributes) end

--- Converts the provided data into a styled text string.
---
--- Note: See also hs.styledtext.getStyledTextFromFile
---@param data string
---@param type any
---@return styledText
function hs.styledtext.getStyledTextFromData(data, type) end

--- Converts the data in the specified file into a styled text string.
---
--- Note: See also hs.styledtext.getStyledTextFromData
---@param file any
---@param type any
---@return styledText
function hs.styledtext.getStyledTextFromFile(file, type) end

--- Create an
--- hs.styledtext
--- object from the string or table representation provided.  Attributes to apply to the resulting string may also be
--- optionally provided.
---
--- Note: See hs.styledtext:asTable for a description of the table representation of an hs.styledtext object
--- See the module description documentation ( help.hs.styledtext ) for a description of the attributes table format
--- which can be provided for the optional second argument.
--- Passing an hs.styledtext object as the first parameter without specifying an attributes table is the equivalent of
--- invoking hs.styledtext:copy .
---@param string string
---@param attributes hs.styledtext|nil
---@return styledText
function hs.styledtext.new(string, attributes) end

--- Returns the table representation of the
--- hs.styledtext
--- object or its specified substring.
---
--- Note: starts and ends follow the conventions of i and j for Lua's string.sub function.
--- The attribute which contains an attachment (image) for a converted RTFD or other document is known to set the
--- unsupportedFields flag.
--- The indexes in the table returned are relative to their position in the original hs.styledtext object.  If you want
--- the table version of a substring which does not start at index position 1 that can be safely fed as a "proper"
--- table version of an hs.styledtext object into another function or constructor, the proper way to generate it is
--- `destination = object:sub(i,j):asTable().
--- See the module description documentation ( help.hs.styledtext ) for a description of the attributes table format
---@param starts hs.styledtext|nil
---@param ends hs.styledtext|nil
---@return table
function styledtext:asTable(starts, ends) end

--- Returns the internal numerical representation of the characters in the
--- hs.styledtext
--- object specified by the given indices.  Mimics the Lua
--- string.byte
--- function.
---
--- Note: starts and ends follow the conventions of i and j for Lua's string.sub function.
---@param starts hs.styledtext|nil
---@param ends hs.styledtext|nil
---@return number
---@return ..
function styledtext:byte(starts, ends) end

--- Converts the styledtext object into the data format specified.
---@param type any
---@return string
function styledtext:convert(type) end

--- Create a copy of the
--- hs.styledtext
--- object.
---@param styledText hs.styledtext
---@return styledText
function styledtext:copy(styledText) end

--- Returns the indices of the first occurrence of the specified pattern in the text of the
--- hs.styledtext
--- object.  Mimics the Lua
--- string.find
--- function.
---
--- Note: Any captures returned are returned as Lua Strings, not as hs.styledtext objects.
---@param pattern string
---@param init number|nil
---@param plain any
---@return start
---@return end
---@return ...|nil
function styledtext:find(pattern, init, plain) end

--- Returns the text of the
--- hs.styledtext
--- object as a Lua String
---
--- Note: starts and ends follow the conventions of i and j for Lua's string.sub function.
---@param starts hs.styledtext|nil
---@param ends hs.styledtext|nil
---@return string
function styledtext:getString(starts, ends) end

--- Returns an iterator function which will return the captures (or the entire pattern) of the next match of the
--- specified pattern in the text of the
--- hs.styledtext
--- object each time it is called.  Mimics the Lua
--- string.gmatch
--- function.
---
--- Note: Any captures (or the entire pattern) returned by the iterator are returned as Lua Strings, not as
--- hs.styledtext objects.
---@param pattern string
---@return iterator-function
function styledtext:gmatch(pattern) end

--- Determine if the
--- styledText
--- object is identical to the one specified.
---
--- Note: comparing two hs.styledtext objects with the == operator only compares whether or not the string values are
--- identical.  This method also compares their attributes.
---@param styledText hs.styledtext
---@return boolean
function styledtext:isIdentical(styledText) end

--- Returns the length of the text of the
--- hs.styledtext
--- object.  Mimics the Lua
--- string.len
--- function.
---@return number
function styledtext:len() end

--- Returns a copy of the
--- hs.styledtext
--- object with all alpha characters converted to lower case.  Mimics the Lua
--- string.lower
--- function.
---@return styledText
function styledtext:lower() end

--- Returns the first occurrence of the captures in the specified pattern (or the complete pattern, if no captures are
--- specified) in the text of the
--- hs.styledtext
--- object.  Mimics the Lua
--- string.match
--- function.
---
--- Note: Any captures (or the entire pattern) returned are returned as Lua Strings, not as hs.styledtext objects.
---@param pattern string
---@param init number|nil
---@return match ...|nil
function styledtext:match(pattern, init) end

--- Return a copy of the
--- hs.styledtext
--- object containing the changes to its attributes specified in the
--- attributes
--- table.
---
--- Note: starts and ends follow the conventions of i and j for Lua's string.sub function.
--- See the module description documentation ( help.hs.styledtext ) for a list of officially recognized attribute label
--- names.
--- The officially recognized attribute labels were chosen for brevity or for consistency with conventions used in
--- Hammerspoon's other modules.  If you know the Objective-C name for an attribute, you can list it instead of an
--- officially recognized label, allowing the removal of attributes which this module cannot manipulate in other ways.
---@param attributes hs.styledtext
---@param starts hs.styledtext|nil
---@param ends hs.styledtext|nil
---@return styledText
function styledtext:removeStyle(attributes, starts, ends) end

--- Returns an
--- hs.styledtext
--- object which contains
--- n
--- repetitions of the
--- hs.styledtext
--- object, optionally with
--- separator
--- between each repetition.  Mimics the Lua
--- string.rep
--- function.
---@param n number
---@param separator hs.styledtext|nil
---@return styledText
function styledtext:rep(n, separator) end

--- Return a copy of the
--- hs.styledtext
--- object containing the changes to its attributes specified in the
--- attributes
--- table.
---
--- Note: starts and ends follow the conventions of i and j for Lua's string.sub function except that starts must refer
--- to an index preceding or equal to ends , even after negative and out-of-bounds indices are adjusted for.
--- See the module description documentation ( help.hs.styledtext ) for a description of the attributes table format
---@param string string
---@param starts hs.styledtext|nil
---@param ends hs.styledtext|nil
---@param clear any
---@return styledText
function styledtext:setString(string, starts, ends, clear) end

--- Return a copy of the
--- hs.styledtext
--- object containing the changes to its attributes specified in the
--- attributes
--- table.
---
--- Note: starts and ends follow the conventions of i and j for Lua's string.sub function.
--- See the module description documentation ( help.hs.styledtext ) for a description of the attributes table format
---@param attributes table
---@param starts hs.styledtext|nil
---@param ends hs.styledtext|nil
---@param clear any
---@return styledText
function styledtext:setStyle(attributes, starts, ends, clear) end

--- Returns a substring, including the style attributes, specified by the given indices from the
--- hs.styledtext
--- object.  Mimics the Lua
--- string.sub
--- function.
---
--- Note: starts and ends follow the conventions of i and j for Lua's string.sub function.
---@param starts hs.styledtext
---@param ends hs.styledtext|nil
---@return styledText
function styledtext:sub(starts, ends) end

--- Returns a copy of the
--- hs.styledtext
--- object with all alpha characters converted to upper case.  Mimics the Lua
--- string.upper
--- function.
---@return styledText
function styledtext:upper() end

-- ------------------------------------------------------------
-- hs.tabs
-- ------------------------------------------------------------

---@class hs.tabs
hs.tabs = {}

--- Places all the windows of an app into one place and tab them
---@param app hs.application
---@return any
function hs.tabs.enableForApp(app) end

--- Focuses a specific tab of an app
---
--- Note: If num is higher than the number of tabs, the last tab will be focussed
---@param app hs.application
---@param num number
---@return any
function hs.tabs.focusTab(app, num) end

--- Gets a list of the tabs of a window
---
--- Note: This function can be used when writing tab switchers
---@param app hs.application
---@return the[]
function hs.tabs.tabWindows(app) end

-- ------------------------------------------------------------
-- hs.tangent
-- ------------------------------------------------------------

---@class hs.tangent
hs.tangent = {}

---@class hs.tangent.tangent
---@field fromHub -> table any Definitions for IPC Commands from the HUB to Hammerspoon.
---@field panelType -> table any Tangent Panel Types.
---@field toHub -> table any Definitions for IPC Commands from Hammerspoon to the HUB.

--- Definitions for reserved action IDs.
---@type any
hs.tangent.reserved.action -> table = nil

--- Definitions for IPC Commands from the HUB to Hammerspoon.
---@type any
hs.tangent.fromHub -> table = nil

--- Tangent Panel Types.
---@type any
hs.tangent.panelType -> table = nil

--- A table of reserved parameter IDs.
---@type table
hs.tangent.reserved.parameter -> table = nil

--- Definitions for IPC Commands from Hammerspoon to the HUB.
---@type any
hs.tangent.toHub -> table = nil

--- Automatically send the "Application Definition" response. Defaults to
--- true
--- .
---@type any
hs.tangent.automaticallySendApplicationDefinition -> boolean = nil

--- IP Address that the Tangent Hub is located at. Defaults to 127.0.0.1.
---@type any
hs.tangent.ipAddress -> number = nil

--- The port that Tangent Hub monitors. Defaults to 64246.
---@type any
hs.tangent.port -> number = nil

--- Sets a callback when new messages are received.
---
--- Note: Full documentation for the Tangent API can be downloaded here .
--- The callback function should expect 1 argument and should not return anything.
--- id - the message ID of the incoming message
--- metadata - A table of data for the Tangent command (see below).
--- connected - Connection to Tangent Hub successfully established.
--- disconnected - The connection to Tangent Hub was dropped.
--- protocolRev - The revision number of the protocol.
--- numPanels - The number of panels connected.
--- panelID - The ID of the panel.
--- panelType - The type of panel connected.
--- data - The raw data from the Tangent Hub
--- paramID - The ID value of the parameter.
--- increment - The incremental value which should be applied to the parameter.
--- paramID - The ID value of the parameter.
--- paramID - The ID value of the parameter.
--- menuID - The ID value of the menu.
--- increment - The incremental amount by which the menu index should be changed which will always be an integer value
--- of +1 or -1.
--- menuID - The ID value of the menu.
--- menuID - The ID value of the menu.
--- actionID - The ID value of the action.
--- modeID - The ID value of the mode.
--- jogValue - The number of jog steps to move the transport.
--- shuttleValue - An incremental value to add to the shuttle speed.
--- actionID - The ID value of the action.
--- panelID - The ID of the panel as reported in the InitiateComms command.
--- numButtons - The number of buttons on the panel.
--- numEncoders - The number of encoders on the panel.
--- numDisplays - The number of displays on the panel.
--- numDisplayLines - The number of lines for each display on the panel.
--- numDisplayChars - The number of characters on each line of each display on the panel.
--- panelID - The ID of the panel as reported in the InitiateComms command.
--- buttonID - The hardware ID of the button
--- panelID - The ID of the panel as reported in the InitiateComms command.
--- buttonID - The hardware ID of the button.
--- panelID - The ID of the panel as reported in the InitiateComms command.
--- paramID - The hardware ID of the encoder.
--- increment - The incremental value.
--- panelID - The ID of the panel as reported in the InitiateComms command.
--- panelID - The ID of the panel as reported in the InitiateComms command.
--- state - The connected state of the panel, true if connected, false if disconnected.
---@return boolean
function hs.tangent.callback() end

--- Connects to the Tangent Hub.
---@param applicationName string
---@param systemPath string
---@param userPath? string
---@return boolean
---@return errorMessage
function hs.tangent.connect(applicationName, systemPath, userPath) end

--- Checks to see whether or not you're successfully connected to the Tangent Hub.
---@return boolean
function hs.tangent.connected() end

--- Disconnects from the Tangent Hub.
---@return none
function hs.tangent.disconnect() end

--- Checks to see whether or not the Tangent Hub software is installed.
---@return boolean
function hs.tangent.isTangentHubInstalled() end

--- Sends a "bytestring" message to the Tangent Hub.
---
--- Note: This should be a full encoded string for the command you want to send, withouth the leading 'size' section,
--- which the function will calculate automatically.
--- In general, you should use the more specific functions that package the command for you, such as
--- sendParameterValue(...) . This function can be used to send a message that this API doesn't yet support.
--- Full documentation for the Tangent API can be downloaded here .
---@param byteString string
---@return boolean
---@return string
function hs.tangent.send(byteString) end

--- Tells the Hub that a large number of software-controls have changed.
---
--- Note: The Hub responds by requesting all the current values of software-controls it is currently controlling.
---@return boolean
---@return string
function hs.tangent.sendAllChange() end

--- Sends the application details to the Tangent Hub.
---
--- Note: If no details are provided the ones stored in the module are used.
---@param appName string
---@param systemPath string
---@param userPath string
---@return boolean
---@return string
function hs.tangent.sendApplicationDefinition(appName, systemPath, userPath) end

--- Updates the Hub with a number of character strings that will be displayed on connected panels if there is space.
---
--- Note: Strings may either be 32 character, single height or 16 character double-height. They will be displayed in
--- the order received; the first string displayed at the top of the display.
--- If a string is not defined as double-height then it will occupy the next line.
--- If a string is defined as double-height then it will occupy the next 2 lines.
--- The maximum number of lines which will be used by the application must be indicated in the Controls XML file.
--- Text which exceeds 32 (single-height) or 16 (double-height) characters will be truncated.
--- If all text is single-height, the doubleHeight table can be omitted.
---@param messages messages[]
---@param doubleHeight? boolean[]|nil
---@return boolean
---@return string
function hs.tangent.sendDisplayText(messages, doubleHeight) end

--- Highlights the control on any panel where this feature is available.
---
--- Note: When applied to Modes, buttons which are mapped to the reserved "Go To Mode" action for this particular mode
--- will highlight.
---@param targetID string
---@param active any
---@return boolean
---@return string
function hs.tangent.sendHighlightControl(targetID, active) end

--- Sets the Indicator of the control on any panel where this feature is available.
---
--- Note: This indicator is driven by the atDefault argument for Parameters and Menus. This command therefore only
--- applies to controls mapped to Actions and Modes.
--- When applied to Modes, buttons which are mapped to the reserved "Go To Mode" action for this particular mode will
--- have their indicator set.
---@param targetID string
---@param indicated any
---@return boolean
---@return string
function hs.tangent.sendIndicateControl(targetID, indicated) end

--- Updates the Hub with a menu value.
---
--- Note: The Hub then updates the displays of any panels which are currently showing the menu.
--- If a value of nil is sent then the Hub will not attempt to display a value for the menu. However the atDefault flag
--- will still be recognised.
---@param menuID string
---@param value string
---@param atDefault? any
---@return boolean
---@return string
function hs.tangent.sendMenuString(menuID, value, atDefault) end

--- Updates the Hub with a mode value.
---
--- Note: The Hub then changes mode and requests all the current values of software-controls it is controlling.
---@param modeID string
---@return boolean
---@return string
function hs.tangent.sendModeValue(modeID) end

--- Requests the Hub to respond with a sequence of PanelConnectionState (0x35) commands to report the
--- connected/disconnected status of each configured panel
---
--- Note: A single request may result in multiple state responses.
---@return any
function hs.tangent.sendPanelConnectionStatesRequest() end

--- Updates the Hub with a parameter value.
---
--- Note: The Hub then updates the displays of any panels which are currently showing the parameter value.
---@param paramID string
---@param value any
---@param atDefault? any
---@return boolean
---@return string
function hs.tangent.sendParameterValue(paramID, value, atDefault) end

--- Renames a control dynamically.
---
--- Note: The string supplied will replace the normal text which has been derived from the Controls XML file.
--- To remove any existing replacement name set newName to "" , this will remove any renaming and return the system to
--- the normal display text
--- When applied to Modes, the string displayed on buttons which mapped to the reserved "Go To Mode" action for this
--- particular mode will also change.
---@param targetID string
---@param newName string
---@return boolean
---@return string
function hs.tangent.sendRenameControl(targetID, newName) end

--- Updates the Hub with text that will be displayed on a specific panel at the given line and starting position where
--- supported by the panel capabilities.
---
--- Note: Only used when working in Unmanaged panel mode.
--- If the most significant bit of any individual text character in message is set it will be displayed as inversed
--- with dark text on a light background.
---@param panelID string
---@param displayID string
---@param lineNum number
---@param pos any
---@param message string
---@return boolean
---@return string
function hs.tangent.sendUnmanagedDisplayWrite(panelID, displayID, lineNum, pos, message) end

--- Requests the Hub to respond with an UnmanagedPanelCapabilities (0x30) command.
---
--- Note: Only used when working in Unmanaged panel mode
---@param panelID string
---@return boolean
---@return string
function hs.tangent.sendUnmanagedPanelCapabilitiesRequest(panelID) end

--- Sets the Log Level.
---@param loglevel number
---@return none
function hs.tangent.setLogLevel(loglevel) end

-- ------------------------------------------------------------
-- hs.task
-- ------------------------------------------------------------

---@class hs.task
hs.task = {}

---@class task
local task = {}

--- Creates a new hs.task object
---
--- Note: The arguments are not processed via a shell, so you do not need to do any quoting or escaping. They are
--- passed to the executable exactly as provided.
--- When using a stream callback, the callback may be invoked one last time after the termination callback has already
--- been invoked. In this case, the task argument to the stream callback will be nil rather than the task userdata
--- object and the return value of the stream callback will be ignored.
---@param launchPath string
---@param callbackFn any
---@param streamCallbackFn? any
---@param arguments? table|nil
---@return hs.task
function hs.task.new(launchPath, callbackFn, streamCallbackFn, arguments) end

--- Closes the task's stdin
---
--- Note: This should only be called on tasks with a streaming callback - tasks without it will automatically close
--- stdin when any data supplied via hs.task:setInput() has been written
--- This is primarily useful for sending EOF to long-running tasks
---@return hs.task
function task:closeInput() end

--- Returns the environment variables as a table for the task.
---
--- Note: if you have not yet set an environment table with the hs.task:setEnvironment method, this method will return
--- a copy of the Hammerspoon environment table, as this is what the task will inherit by default.
---@return environment
function task:environment() end

--- Interrupts the task
---
--- Note: This will send SIGINT to the process
---@return hs.task
function task:interrupt() end

--- Test if a task is still running.
---
--- Note: A task which has not yet been started yet will also return false.
---@return boolean
function task:isRunning() end

--- Pauses the task
---
--- Note: If the task is not paused, the error message will be printed to the Hammerspoon Console
--- This method can be called multiple times, but a matching number of hs.task:resume() calls will be required to allow
--- the process to continue
---@return boolean
function task:pause() end

--- Gets the PID of a running/finished task
---
--- Note: The PID will still be returned if the task has already completed and the process terminated
---@return number
function task:pid() end

--- Resumes the task
---
--- Note: If the task is not resumed successfully, the error message will be printed to the Hammerspoon Console
---@return boolean
function task:resume() end

--- Set or remove a callback function for a task.
---@param fn function|nil
---@return hs.task
function task:setCallback(fn) end

--- Sets the environment variables for the task.
---
--- Note: If you do not set an environment table with this method, the task will inherit the environment variables of
--- the Hammerspoon application.  Set this to an empty table if you wish for no variables to be set for the task.
---@param environment table
---@return hs.task|boolean
function task:setEnvironment(environment) end

--- Sets the standard input data for a task
---
--- Note: This method can be called before the task has been started, to prepare some input for it (particularly if it
--- is not a streaming task)
--- If this method is called multiple times, any input that has not been passed to the task already, is discarded (for
--- streaming tasks, the data is generally consumed very quickly, but for now there is no way to synchronize this)
---@param inputData string
---@return hs.task
function task:setInput(inputData) end

--- Set a stream callback function for a task
---
--- Note: For information about the requirements of the callback function, see hs.task.new()
--- If a callback is removed without it previously having returned false, any further stdout/stderr output from the
--- task will be silently discarded
---@param fn function|nil
---@return hs.task
function task:setStreamingCallback(fn) end

--- Sets the working directory for the task.
---
--- Note: You can only set the working directory if the task has not already been started.
--- This will only set the directory that the task starts in.  The task itself can change the directory while it is
--- running.
---@param path string
---@return hs.task|boolean
function task:setWorkingDirectory(path) end

--- Starts the task
---
--- Note: If the task does not start successfully, the error message will be printed to the Hammerspoon Console
---@return hs.task|boolean
function task:start() end

--- Terminates the task
---
--- Note: This will send SIGTERM to the process
---@return hs.task
function task:terminate() end

--- Returns the termination reason for a task, or false if the task is still running.
---@return exitCode|boolean
function task:terminationReason() end

--- Returns the termination status of a task, or false if the task is still running.
---@return exitCode|boolean
function task:terminationStatus() end

--- Blocks Hammerspoon until the task exits
---
--- Note: All Lua and Hammerspoon activity will be blocked by this method. Its use is highly discouraged.
---@return hs.task
function task:waitUntilExit() end

--- Returns the working directory for the task.
---
--- Note: This only returns the directory that the task starts in.  If the task changes the directory itself, this
--- value will not reflect that change.
---@return path
function task:workingDirectory() end

-- ------------------------------------------------------------
-- hs.timer
-- ------------------------------------------------------------

---@class hs.timer
hs.timer = {}

---@class timer
local timer = {}

--- Returns the absolute time in nanoseconds since the last system boot.
---
--- Note: this value does not include time that the system has spent asleep
--- this value is used for the timestamps in system generated events.
---@return nanoseconds
function hs.timer.absoluteTime() end

--- Converts days to seconds
---@param n number
---@return sec
function hs.timer.days(n) end

--- Converts hours to seconds
---@param n number
---@return seconds
function hs.timer.hours(n) end

--- Returns the number of seconds since local time midnight
---@return number
function hs.timer.localTime() end

--- Converts minutes to seconds
---@param n number
---@return seconds
function hs.timer.minutes(n) end

--- Converts a string with a time of day or a duration into number of seconds
---@param timeOrDuration number
---@return seconds
function hs.timer.seconds(timeOrDuration) end

--- Gets the (fractional) number of seconds since the UNIX epoch (January 1, 1970)
---
--- Note: This has much better precision than os.time() , which is limited to whole seconds.
---@return sec
function hs.timer.secondsSinceEpoch() end

--- Blocks Lua execution for the specified time
---
--- Note: Use of this function is strongly discouraged, as it blocks all main-thread execution in Hammerspoon. This
--- means no hotkeys or events will be processed in that time, no GUI updates will happen, and no Lua will execute.
--- This is only provided as a last resort, or for extremely short sleeps. For all other purposes, you really should be
--- splitting up your code into multiple functions and calling hs.timer.doAfter()
---@param microsecs number
---@return any
function hs.timer.usleep(microsecs) end

--- Converts weeks to seconds
---@param n number
---@return sec
function hs.timer.weeks(n) end

--- Calls a function after a delay
---
--- Note: There is no need to call :start() on the returned object, the timer will be already running.
--- The callback can be cancelled by calling the :stop() method on the returned object before sec seconds have passed.
---@param sec number
---@param fn function
---@return timer
function hs.timer.doAfter(sec, fn) end

--- Creates and starts a timer which will perform
--- fn
--- at the given (local)
--- time
--- and then (optionally) repeat it every
--- interval
--- .
---
--- Note: The timer can trigger up to 1 second early or late
--- If it's 19:00, hs.timer.doAt("20:00",somefn) will set the timer 1 hour from now
--- If it's 21:00, hs.timer.doAt("20:00",somefn) will set the timer 23 hours from now
--- If it's 21:00, hs.timer.doAt("20:00","6h",somefn) will set the timer 5 hours from now (at 02:00)
--- To run a job every hour on the hour from 8:00 to 20:00: for h=8,20 do hs.timer.doAt(h..":00","1d",runJob) end
---@param time number
---@param repeatInterval? number
---@param fn? function
---@param continueOnError? function|nil
---@return timer
function hs.timer.doAt(time, repeatInterval, fn, continueOnError) end

--- Repeats fn every interval seconds.
---
--- Note: This function is a shorthand for hs.timer.new(interval, fn):start()
---@param interval number
---@param fn function
---@return timer
function hs.timer.doEvery(interval, fn) end

--- Creates and starts a timer which will perform
--- actionFn
--- every
--- checkinterval
--- seconds until
--- predicateFn
--- returns true.  The timer is automatically stopped when
--- predicateFn
--- returns true.
---
--- Note: The timer is passed as an argument to actionFn so that it may stop the timer prematurely (i.e. before
--- predicateFn returns true) if desired.
--- See also hs.timer.doWhile , which is essentially the opposite of this function
---@param predicateFn function
---@param actionFn function
---@param checkInterval? number
---@return timer
function hs.timer.doUntil(predicateFn, actionFn, checkInterval) end

--- Creates and starts a timer which will perform
--- actionFn
--- every
--- checkinterval
--- seconds while
--- predicateFn
--- returns true.  The timer is automatically stopped when
--- predicateFn
--- returns false.
---
--- Note: The timer is passed as an argument to actionFn so that it may stop the timer prematurely (i.e. before
--- predicateFn returns false) if desired.
--- See also hs.timer.doUntil , which is essentially the opposite of this function
---@param predicateFn function
---@param actionFn function
---@param checkInterval? number
---@return timer
function hs.timer.doWhile(predicateFn, actionFn, checkInterval) end

--- Creates a new
--- hs.timer
--- object for repeating interval callbacks
---
--- Note: The returned object does not start its timer until its :start() method is called
--- If interval is 0, the timer will not repeat (because if it did, it would be repeating as fast as your machine can
--- manage, which seems generally unwise)
--- For non-zero intervals, the lowest acceptable value for the interval is 0.00001s. Values >0 and <0.00001 will be
--- coerced to 0.00001
---@param interval number
---@param fn function
---@param continueOnError? function|nil
---@return timer
function hs.timer.new(interval, fn, continueOnError) end

--- Creates and starts a timer which will perform
--- actionFn
--- when
--- predicateFn
--- returns true.  The timer is automatically stopped when
--- actionFn
--- is called.
---
--- Note: The timer is stopped before actionFn is called, but the timer is passed as an argument to actionFn so that
--- the actionFn may restart the timer to be called again the next time predicateFn returns true.
--- See also hs.timer.waitWhile , which is essentially the opposite of this function
---@param predicateFn function
---@param actionFn function
---@param checkInterval? number
---@return timer
function hs.timer.waitUntil(predicateFn, actionFn, checkInterval) end

--- Creates and starts a timer which will perform
--- actionFn
--- when
--- predicateFn
--- returns false.  The timer is automatically stopped when
--- actionFn
--- is called.
---
--- Note: The timer is stopped before actionFn is called, but the timer is passed as an argument to actionFn so that
--- the actionFn may restart the timer to be called again the next time predicateFn returns false.
--- See also hs.timer.waitUntil , which is essentially the opposite of this function
---@param predicateFn function
---@param actionFn function
---@param checkInterval? number
---@return timer
function hs.timer.waitWhile(predicateFn, actionFn, checkInterval) end

--- Immediately fires a timer
---
--- Note: This cannot be used on a timer which has already stopped running
---@return timer
function timer:fire() end

--- Returns the number of seconds until the timer will next trigger
---
--- Note: The return value may be a negative integer in two circumstances:
--- Hammerspoon's runloop is backlogged and is catching up on missed timer triggers
--- The timer object is not currently running. In this case, the return value of this method is the number of seconds
--- since the last firing (you can check if the timer is running or not, with hs.timer:running()
---@return number
function timer:nextTrigger() end

--- Returns a boolean indicating whether or not the timer is currently running.
---@return boolean
function timer:running() end

--- Sets the next trigger time of a timer
---
--- Note: If the timer is not already running, this will start it
---@param seconds number
---@return timer
function timer:setNextTrigger(seconds) end

--- Starts an
--- hs.timer
--- object
---
--- Note: The timer will not call the callback immediately, the timer will wait until it fires
--- If the callback function results in an error, the timer will be stopped to prevent repeated error notifications
--- (see the continueOnError parameter to hs.timer.new() to override this)
---@return timer
function timer:start() end

--- Stops an
--- hs.timer
--- object
---@return timer
function timer:stop() end

-- ------------------------------------------------------------
-- hs.timer.delayed
-- ------------------------------------------------------------

---@class hs.timer.delayed
hs.timer.delayed = {}

---@class delayed
local delayed = {}

--- Creates a new delayed timer
---
--- Note: These timers are meant to be long-lived: once instantiated, there's no way to remove them from the run loop;
--- create them once at the module level.
--- Delayed timers have specialized methods that behave differently from regular timers. When the :start() method is
--- invoked, the timer will wait for delay seconds before calling fn() ; this is referred to as the callback countdown.
--- If :start() is invoked again before delay has elapsed, the countdown starts over again.
--- You can use a delayed timer to coalesce processing of unpredictable asynchronous events into a single callback; for
--- example, if you have an event stream that happens in "bursts" of dozens of events at once, set an appropriate delay
--- to wait for things to settle down, and then your callback will run just once.
---@param delay number
---@param fn function
---@return hs.timer.delayed
function hs.timer.delayed.new(delay, fn) end

--- Returns the time left in the callback countdown
---@return number|nil
function delayed:nextTrigger() end

--- Returns a boolean indicating whether the callback countdown is running
---@return boolean
function delayed:running() end

--- Changes the callback countdown duration
---
--- Note: if the callback countdown is running, calling this method will restart it
---@param delay number
---@return hs.timer.delayed
function delayed:setDelay(delay) end

--- Starts or restarts the callback countdown
---@param delay number|nil
---@return hs.timer.delayed
function delayed:start(delay) end

--- Cancels the callback countdown, if running; the callback will therefore not be triggered
---@return hs.timer.delayed
function delayed:stop() end

-- ------------------------------------------------------------
-- hs.uielement
-- ------------------------------------------------------------

---@class hs.uielement
hs.uielement = {}

---@class uielement
local uielement = {}

--- Gets the currently focused UI element
---@return element|nil
function hs.uielement.focusedElement() end

--- Returns whether the UI element represents an application.
---@return boolean
function uielement:isApplication() end

--- Returns whether the UI element represents a window.
---@return boolean
function uielement:isWindow() end

--- Creates a new watcher
---@param handler function
---@param userData? any
---@return hs.uielement.watcher|nil
function uielement:newWatcher(handler, userData) end

--- Returns the role of the element.
---@return string
function uielement:role() end

--- Returns the selected text in the element
---
--- Note: Many applications (e.g. Safari, Mail, Firefox) do not implement the necessary accessibility features for this
--- to work in their web views
---@return string|nil
function uielement:selectedText() end

-- ------------------------------------------------------------
-- hs.uielement.watcher
-- ------------------------------------------------------------

---@class hs.uielement.watcher
hs.uielement.watcher = {}

---@class watcher
local watcher = {}

--- Returns the element the watcher is watching.
---@return object
function watcher:element() end

--- Returns the PID of the element being watched
---@return number
function watcher:pid() end

--- Tells the watcher to start watching for the given list of events.
---
--- Note: See hs.uielement.watcher for a list of events. You may also specify arbitrary event names as strings.
--- Does nothing if the watcher has already been started. To start with different events, stop it first.
---@param events any
---@return hs.uielement.watcher
function watcher:start(events) end

--- Tells the watcher to stop listening for events.
---
--- Note: This is automatically called if the element is destroyed.
---@return hs.uielement.watcher
function watcher:stop() end

-- ------------------------------------------------------------
-- hs.urlevent
-- ------------------------------------------------------------

---@class hs.urlevent
hs.urlevent = {}

--- A function that should handle http:// and https:// URL events
---@type function
hs.urlevent.httpCallback = nil

--- A function that should handle mailto: URL events
---@type function
hs.urlevent.mailtoCallback = nil

--- Registers a callback for a hammerspoon:// URL event
---
--- Note: The callback function should accept two parameters:
--- eventName - A string containing the name of the event
--- params - A table containing key/value string pairs containing any URL parameters that were specified in the URL
--- senderPID - An integer containing the PID of the sending application, if available (otherwise -1)
--- fullURL - A string containing the full, original URL
--- Given the URL hammerspoon://doThingA?value=1 The event name is doThingA and the callback's params argument will be
--- a table containing {["value"] = "1"} and fullURL will be hammerspoon://doThingA?value=1
---@param eventName string
---@param callback function|nil
---@return any
function hs.urlevent.bind(eventName, callback) end

--- Gets all of the application bundle identifiers of applications able to handle a URL scheme
---@param scheme string
---@return table
function hs.urlevent.getAllHandlersForScheme(scheme) end

--- Gets the application bundle identifier of the application currently registered to handle a URL scheme
---@param scheme string
---@return string
function hs.urlevent.getDefaultHandler(scheme) end

--- Opens a URL with the default application
---@param url string
---@return boolean
function hs.urlevent.openURL(url) end

--- Opens a URL with a specified application
---@param url string
---@param bundleID string
---@return boolean
function hs.urlevent.openURLWithBundle(url, bundleID) end

--- Sets the default system handler for URLs of a given scheme
---
--- Note: Changing the default handler for http/https URLs will display a system prompt asking the user to confirm the
--- change
---@param scheme string
---@param bundleID? string|nil
---@return any
function hs.urlevent.setDefaultHandler(scheme, bundleID) end

--- Stores a URL handler that will be restored when Hammerspoon or reloads its config
---
--- Note: You don't have to call this function if you want Hammerspoon to permanently be your default handler. Only use
--- this if you want the handler to be automatically reverted to something else when Hammerspoon exits/reloads.
---@param scheme string
---@param bundleID string
---@return any
function hs.urlevent.setRestoreHandler(scheme, bundleID) end

-- ------------------------------------------------------------
-- hs.usb
-- ------------------------------------------------------------

---@class hs.usb
hs.usb = {}

--- Gets details about currently attached USB devices
---@return table|nil
function hs.usb.attachedDevices() end

-- ------------------------------------------------------------
-- hs.usb.watcher
-- ------------------------------------------------------------

---@class hs.usb.watcher
hs.usb.watcher = {}

---@class watcher
local watcher = {}

--- Creates a new watcher for USB device events
---@param fn function
---@return watcher
function hs.usb.watcher.new(fn) end

--- Starts the USB watcher
---@return watcher
function watcher:start() end

--- Stops the USB watcher
---@return watcher
function watcher:stop() end

-- ------------------------------------------------------------
-- hs.utf8
-- ------------------------------------------------------------

---@class hs.utf8
hs.utf8 = {}

--- A collection of UTF-8 characters already converted from codepoint and available as convenient key-value pairs.
--- UTF-8 printable versions of common Apple and OS X special keys are predefined and others can be added with
--- hs.utf8.registerCodepoint(label, codepoint)
--- for your own use.
---@type hs.utf8.registerCodepoint
hs.utf8.registeredKeys[] = nil

--- Returns the provided string with all non-printable ascii characters escaped, except Return, Linefeed, and Tab.
---
--- Note: Because Unicode characters outside of the basic ascii alphabet are multi-byte characters, any UTF8 or other
--- Unicode encoded character will be broken up into their individual bytes and likely escaped by this function.
--- utf8.charpattern , which contains the regular expression for matching valid UTF8 encoded sequences, results in
--- (null) in the Hammerspoon console, but hs.utf8.asciiOnly(utf8.charpattern) will display
--- [\x00-\x7F\xC2-\xF4][\x80-\xBF]* .
---@param string table
---@param all? any
---@return string
function hs.utf8.asciiOnly(string, all) end

--- Wrapper to
--- utf8.char(...)
--- which ensures that all codepoints return valid UTF8 characters.
---
--- Note: Valid codepoint values are from 0x0000 - 0x10FFFF (0 - 1114111)
--- If the codepoint provided is a string that starts with U+, then the 'U+' is converted to a '0x' so that lua can
--- properly treat the value as numeric.
--- This includes out of range codepoints as well as the Unicode Surrogate codepoints (U+D800 - U+DFFF)
---@param ... any
---@return string
function hs.utf8.codepointToUTF8(...) end

--- Replace invalid UTF8 character sequences in
--- inString
--- with
--- replacementChar
--- so it can be safely displayed in the console or other destination which requires valid UTF8 encoding.
---
--- Note: This function is a slight modification to code found at http://notebook.kulchenko.com/programming/fixing-malformed-utf8-in-lua.
--- If replacementChar is a multi-byte character (like U+FFFD) or multi character string, then the string length of
--- outString will be longer than the string length of inString .  The character positions in posTable will reflect
--- these new positions in outString .
--- To calculate the character position of the invalid characters in inString , use something like the following:
--- outString, outErrors = hs.utf8.fixUTF8(inString, replacement)
--- inErrors = {}
--- for i,p in ipairs(outErrors) do
--- table.insert(inErrors, p - ((i - 1) * string.length(replacement) - 1))
--- end Where replacement is utf8.char(0xFFFD) , if you leave it out of the hs.utf8.fixUTF8 function in the first line.
---@param inString string
---@param replacementChar? string|nil
---@return outString
---@return posTable
function hs.utf8.fixUTF8(inString, replacementChar) end

--- Returns a hex dump of the provided string.  This is primarily useful for examining the exact makeup of binary data
--- contained in a Lua String as individual bytes for debugging purposes.
---
--- Note: Like hs.utf8.asciiOnly, this function will break up Unicode characters into their individual bytes.
--- As an example: hs.utf8.hexDump(utf8.charpattern) will return 00 : 5B 00 2D 7F C2 2D F4 5D 5B 80 2D BF 5D 2A :
--- [.-..-.][.-.]*
---@param inputString string
---@param count? number|nil
---@return string
function hs.utf8.hexDump(inputString, count) end

--- Registers a Unicode codepoint under the given label as a UTF-8 string of bytes which can be referenced by the label
--- later in your code as
--- hs.utf8.registeredKeys[label]
--- for convenience and readability.
---
--- Note: If a codepoint label was previously registered, this will overwrite the previous value with a new one.
--- Because many of the special keys you may want to register have different variants, this allows you to easily modify
--- the existing predefined defaults to suite your preferences.
--- The return value is merely syntactic sugar and you do not need to save it locally; it can be safely ignored --
--- future access to the pre-converted codepoint should be retrieved as hs.utf8.registeredKeys[label] in your code.  It
--- looks good when invoked from the console, though ☺.
---@param label string
---@param codepoint any
---@return string
function hs.utf8.registerCodepoint(label, codepoint) end

--- Returns the label name for a UTF8 character, as it is registered in
--- hs.utf8.registeredKeys[]
--- .
---
--- Note: For parity with hs.utf8.registeredKeys , this can also be invoked as if it were an array: i.e.
--- hs.utf8.registeredLabels(char) is equivalent to hs.utf8.registeredLabels[char]
---@param utf8char hs.utf8.registeredKeys
---@return string
function hs.utf8.registeredLabels(utf8char) end

-- ------------------------------------------------------------
-- hs.vox
-- ------------------------------------------------------------

---@class hs.vox
hs.vox = {}

--- Add media URL to current list
---@param url string
---@return any
function hs.vox.addurl(url) end

--- Skips the playback position backwards by about 7 seconds
---@return any
function hs.vox.backward() end

--- Decreases the player volume
---@return any
function hs.vox.decreaseVolume() end

--- Skips the playback position backwards by about 14 seconds
---@return any
function hs.vox.fastBackward() end

--- Skips the playback position forwards by about 17 seconds
---@return any
function hs.vox.fastForward() end

--- Skips the playback position forwards by about 7 seconds
---@return any
function hs.vox.forward() end

--- Gets the artist of current Album
---@return string|nil
function hs.vox.getAlbumArtist() end

--- Gets the name of the album of the current track
---@return string|nil
function hs.vox.getCurrentAlbum() end

--- Gets the name of the artist of the current track
---@return string|nil
function hs.vox.getCurrentArtist() end

--- Gets the current playback state of vox
---@return any
function hs.vox.getPlayerState() end

--- Gets the uniqueID of the current track
---@return string|nil
function hs.vox.getUniqueID() end

--- Increases the player volume
---@return any
function hs.vox.increaseVolume() end

--- Returns whether VOX is currently open
---@return boolean
function hs.vox.isRunning() end

--- Skips to the next track
---@return any
function hs.vox.next() end

--- Pauses the current vox track
---@return any
function hs.vox.pause() end

--- Plays the current vox track
---@return any
function hs.vox.play() end

--- Toggles play/pause of current vox track
---@return any
function hs.vox.playpause() end

--- Play media from the given URL
---@param url string
---@return any
function hs.vox.playurl(url) end

--- Skips to previous track
---@return any
function hs.vox.previous() end

--- Toggle shuffle state of current list
---@return any
function hs.vox.shuffle() end

--- Toggle playlist
---@return any
function hs.vox.togglePlaylist() end

--- Displays information for current track on screen
---@return any
function hs.vox.trackInfo() end

-- ------------------------------------------------------------
-- hs.watchable
-- ------------------------------------------------------------

---@class hs.watchable
hs.watchable = {}

---@class watchable
local watchable = {}

--- Creates a table that can be watched by other modules for key changes
---
--- Note: This constructor is used by code which wishes to share state information which other code may register to
--- watch.
--- You may specify any string name as a path, but it must be unique -- an error will occur if the path name has
--- already been registered.
--- All key-value pairs stored within this table are potentially watchable by external code -- if you wish to keep some
--- data private, do not store it in this table.
--- externalChanges will apply to all keys within this table -- if you wish to only allow some keys to be externally
--- modifiable, you will need to register separate paths.
--- If external changes are enabled, you will need to register your own watcher with hs.watchable.watch if action is
--- required when external changes occur.
---@param path table
---@param externalChanges table|nil
---@return table
function hs.watchable.new(path, externalChanges) end

--- Creates a watcher that will be invoked when the specified key in the specified path is modified.
---
--- Note: This constructor is used by code which wishes to watch state information which is being shared by other code.
--- The callback function is invoked after the new value has already been set -- the callback is a "didChange"
--- notification, not a "willChange" notification.
--- If the key (specified as a separate argument or as the final component of path) is "*", then all key-value pair
--- changes that occur for the table specified by the path will invoke a callback.  This is a shortcut for watching an
--- entire table, rather than just a specific key-value pair of the table.
--- It is possible to register a watcher for a path that has not been registered with hs.watchable.new yet. Retrieving
--- the current value with hs.watchable:value in such a case will return nil.
---@param path string
---@param key function
---@param callback function
---@return hs.watchable
function hs.watchable.watch(path, key, callback) end

--- Get or set whether this watcher should be notified even when the new value is identical to the current value
---@param notify function|nil
---@return hs.watchable
function watchable:alwaysNotify(notify) end

--- Change or remove the callback function for the watchableObject.
---
--- Note: see hs.watchable.watch for a description of the arguments the callback function should expect.
---@param fn function|nil
---@return hs.watchable
function watchable:callback(fn) end

--- Externally change the value of the key-value pair being watched by the watchableObject
---
--- Note: if external changes are not allowed for the specified path, this method generates an error
---@param key table
---@param value any
---@return hs.watchable
function watchable:change(key, value) end

--- Temporarily stop notifications about the key-value pair(s) watched by this watchableObject.
---
--- Note: Only pauses notifications for this specific watchableObject -- if other watchers are set for the path watched
--- by this watcher, they will still receive notifications if enabled and not paused.
---@return hs.watchable
function watchable:pause() end

--- Removes the watchableObject so that key-value pairs watched by this object no longer generate notifications.
---
--- Note: Only releases this specific watchableObject -- if other watchers are set for the path watched by this object,
--- they remain bound.
---@return nil
function watchable:release() end

--- Resume notifications about the key-value pair(s) watched by this watchableObject which were previously paused.
---
--- Note: Only resumes notifications for this specific watchableObject -- if other watchers are set for the path
--- watched by this watcher are currently paused, they will remain paused.
---@return hs.watchable
function watchable:resume() end

--- Get the current value for the key-value pair being watched by the watchableObject
---@param key table
---@return any
function watchable:value(key) end

-- ------------------------------------------------------------
-- hs.websocket
-- ------------------------------------------------------------

---@class hs.websocket
hs.websocket = {}

---@class websocket
local websocket = {}

--- Creates a new websocket connection.
---
--- Note: The callback should accept two parameters.
--- open - The websocket connection has been opened
--- closed - The websocket connection has been closed
--- fail - The websocket connection has failed
--- received - The websocket has received a message
--- pong - A pong request has been received
--- The second parameter is a string with the received message or an error message.
--- ws://localhost:8000/mysock
--- wss://localhost:8000/mysock (if SSL enabled)
---@param url string
---@param callback function
---@return object
function hs.websocket.new(url, callback) end

--- Closes a websocket connection.
---@return object
function websocket:close() end

--- Sends a message to the websocket client.
---
--- Note: Forcing a text representation by setting isData to false may alter the data if it
--- contains invalid UTF8 character sequences (the default string behavior is to make
--- sure everything is "printable" by converting invalid sequences into the Unicode
--- Invalid Character sequence).
---@param message string
---@param isData? boolean|nil
---@return object
function websocket:send(message, isData) end

--- Gets the status of a websocket.
---@return string
function websocket:status() end

-- ------------------------------------------------------------
-- hs.webview
-- ------------------------------------------------------------

---@class hs.webview
hs.webview = {}

---@class webview
local webview = {}

--- Because use of this method can easily lead to a crash, useful methods from
--- hs.drawing
--- have been added to the
--- hs.webview
--- module itself.  If you believe that a useful method has been overlooked, please submit an issue.
---@return hs.drawing
function webview:asHSDrawing() end

--- Returns an hs.window object for the webview so that you can use hs.window methods on it.
---@return hs.window
function webview:asHSWindow() end

--- Deprecated; you should use
--- hs.webview:level
--- instead.
---
--- Note: see the notes for hs.drawing.windowLevels
---@deprecated
---@param theLevel any
---@return hs.drawing
function webview:setLevel(theLevel) end

--- A table of common OID values found in SSL certificates.  SSL certificates provided to the callback function for
--- hs.webview:sslCallback
--- or in the results of
--- hs.webview:certificateChain
--- use OID strings as the keys which describe the properties of the certificate and this table can be used to get a
--- more common name for the keys you are most likely to see.
---@type table
hs.webview.certificateOIDs[] = nil

--- A table containing valid masks for the webview window.
---@type table
hs.webview.windowMasks[] = nil

--- Get or set whether or not the title text appears in the webview window.
---
--- Note: See also hs.webview:windowStyle and hs.webview.windowMasks .
--- When a toolbar is attached to the webview, this function can be used to specify whether the Toolbar appears
--- underneath the webview window's title ("visible") or in the window's title bar itself, as seen in applications like
--- Safari ("hidden"). When the title is hidden, the toolbar will only display the toolbar items as icons without
--- labels, and ignores changes made with hs.webview.toolbar:displayMode .
--- If a toolbar is attached to the webview, you can achieve the same effect as this method with
--- hs.webview:attachedToolbar():inTitleBar(boolean)
---@param state boolean
---@return webviewObject|string
function webview:titleVisibility(state) end

--- Create a webviewObject and optionally modify its preferences.
---
--- Note: To set the initial URL, use the hs.webview:url method before showing the webview object.
--- Preferences can only be set when the webview object is created.  To change the preferences of an open webview, you
--- will need to close it and recreate it with this method.
--- developerExtrasEnabled is not listed in Apple's documentation, but is included in the WebKit2 documentation.
---@param rect any
---@param preferencesTable any
---@param userContentController hs.webview.usercontent|nil
---@return webviewObject
function hs.webview.new(rect, preferencesTable, userContentController) end

--- Create a webviewObject with some presets common to an interactive web browser.
---
--- Note: The parameters are the same as for hs.webview.new -- check there for more details
--- This constructor is just a short-hand for hs.webview.new(...):allowTextEntry(true):allowGestures(true):windowStyle(15) , which specifies a webview with a title bar, title bar buttons (zoom, close, minimize), and allows form entry and gesture support for previous and next pages.
--- hs.webview:allowGestures
--- hs.webview:allowTextEntry
--- hs.webview:windowStyle
--- hs.webview.windowMasks
---@param rect any
---@param preferencesTable table|nil
---@param userContentController hs.webview.usercontent|nil
---@return webviewObject
function hs.webview.newBrowser(rect, preferencesTable, userContentController) end

--- Get or set whether or not the webview will respond to gestures from a trackpad or magic mouse.  Default is false.
---
--- Note: This is a shorthand method for getting or setting both hs.webview:allowMagnificationGestures and
--- hs.webview:allowNavigationGestures .
--- This method will set both types of gestures to true or false, if given an argument, but will only return true if
--- both gesture types are currently true; if either or both gesture methods are false, then this method will return
--- false.
---@param value any
---@return webviewObject
function webview:allowGestures(value) end

--- Get or set whether or not the webview will respond to magnification gestures from a trackpad or magic mouse.
--- Default is false.
---@param value any
---@return webviewObject
function webview:allowMagnificationGestures(value) end

--- Get or set whether or not the webview will respond to the navigation gestures from a trackpad or magic mouse.
--- Default is false.
---@param value any
---@return webviewObject
function webview:allowNavigationGestures(value) end

--- Get or set whether or not the webview allows new windows to be opened from it by any method.  Defaults to true.
---
--- Note: This method allows you to prevent a webview from being able to open a new window by any method.   This
--- includes right-clicking on a link and selecting "Open in a New Window", JavaScript pop-ups, links with the target
--- of "__blank", etc.
--- If you just want to prevent automatic JavaScript windows, set the preference value
--- javaScriptCanOpenWindowsAutomatically to false when creating the web view - this method blocks all methods.
---@param value any
---@return webviewObject
function webview:allowNewWindows(value) end

--- Get or set whether or not the webview can accept keyboard for web form entry. Defaults to false.
---@param value any
---@return webviewObject
function webview:allowTextEntry(value) end

--- Get or set the alpha level of the window containing the hs.webview object.
---@param alpha number|nil
---@return webviewObject
function webview:alpha(alpha) end

--- Get or attach/detach a toolbar to/from the webview.
---
--- Note: this method is a convenience wrapper for the hs.webview.toolbar.attachToolbar function.
--- If the toolbarObject is currently attached to another window when this method is called, it will be detached from
--- the original window and attached to the webview.  If you wish to attach the same toolbar to multiple webviews, see
--- hs.webview.toolbar:copy .
---@param toolbar hs.webview.toolbar
---@return webviewObject
function webview:attachedToolbar(toolbar) end

--- Get or set the window behavior settings for the webview object.
---
--- Note: Window behaviors determine how the webview object is handled by Spaces and Exposé. See
--- hs.drawing.windowBehaviors for more information.
---@param behavior number|nil
---@return webviewObject
function webview:behavior(behavior) end

--- Get or set the window behavior settings for the webview object using labels defined in
--- hs.drawing.windowBehaviors
--- .
---
--- Note: Window behaviors determine how the webview object is handled by Spaces and Exposé. See
--- hs.drawing.windowBehaviors for more information.
---@param behaviorTable table|nil
---@return webviewObject
function webview:behaviorAsLabels(behaviorTable) end

--- Places the drawing object on top of normal windows
---@param aboveEverything boolean|nil
---@return webviewObject
function webview:bringToFront(aboveEverything) end

--- Returns the certificate chain for the most recently committed navigation of the webview.
---
--- Note: This method is only supported by OS X 10.11 and newer
--- A navigation which was performed via HTTP instead of HTTPS will return an empty array.
--- For OIDs which specify a type of "date" -- e.g. "2.5.29.24" (invalidityDate) -- the number provided represents the
--- number of seconds since 12:00:00 AM, January 1, 1970 and can be used directly with the Lua os.date command.
--- For OIDs which are known to represent a date, but specify its type as a "number" -- e.g.
--- "2.16.840.1.113741.2.1.1.1.7" (X509V1ValidityNotAfter) or "2.16.840.1.113741.2.1.1.1.6" (X509V1ValidityNotBefore)
--- -- the epoch is 12:00:00 AM, Jan 1, 2001.  To convert these dates into a format usable by Lua, you will need to do
--- something similar to the following: os.date("%c", value + os.time({year=2001,month=1,day=1,hour=0,min=0,sec=0})
---@return table|nil
function webview:certificateChain() end

--- Returns an array of webview objects which have been opened as children of this webview.
---@return array
function webview:children() end

--- If the webview is closable, this will get or set whether or not the Escape key is allowed to close the webview
--- window.
---
--- Note: If this is set to true, Escape will only close the window if no other element responds to the Escape key
--- first (e.g. if you are editing a text input field, the Escape will be captured by the text field, not by the
--- webview Window.)
---@param flag hs.webview|nil
---@return webviewObject
function webview:closeOnEscape(flag) end

--- Set or display whether or not the
--- hs.webview
--- window should display in dark mode.
---@param state hs.webview|nil
---@return boolean
function webview:darkMode(state) end

--- Destroys the webview object, optionally fading it out first (if currently visible).
---
--- Note: This method is automatically called during garbage collection, notably during a Hammerspoon termination or
--- reload, with a fade time of 0.
---@param propagate any
---@param fadeOutTime number|nil
---@return none
function webview:delete(propagate, fadeOutTime) end

--- Get or set whether or not the webview should delete itself when its window is closed.
---
--- Note: If set to true, a webview object will be deleted when the user clicks on the close button of a titled and
--- closable webview (see hs.webview.windowStyle ).
--- Children of an explicitly created webview automatically have this attribute set to true.  To cause closed children
--- to remain after the user closes the parent, you can set this to false with a policy callback function when it
--- receives the "newWindow" action.
---@param value hs.webview.new|nil
---@return webviewObject
function webview:deleteOnClose(value) end

--- Returns the estimated percentage of expected content that has been loaded.  Will equal 1.0 when all content has
--- been loaded.
---@return number
function webview:estimatedProgress() end

--- Execute JavaScript within the context of the current webview and optionally receive its result or error in a
--- callback function.
---@param script any
---@param callback function
---@return webviewObject
function webview:evaluateJavaScript(script, callback) end

--- Get or set whether or not invalid SSL server certificates that are approved by the ssl callback function are
--- accepted as valid for browsing with the webview.
---
--- Note: In order for this setting to have any effect, you must also register an ssl callback function with
--- hs.webview:sslCallback which should return true if the certificate should be granted an exception or false if it
--- should not.  For a certificate to be granted an exception, both this method and the result of the callback must be
--- true.
--- it is not signed by a recognized certificate authority - most commonly this means the certificate is self-signed.
--- the certificate has expired
--- the certificate has a common name (web site server name) other than the one requested (e.g. the certificate's
--- common name is www.site.com, but it is being used for something else, possibly just https://site.com, possibly
--- something else entirely
--- some corporate proxy servers don't handle SSL properly and can cause a certificate to appear invalid even when they
--- are valid (this is less common then it used to be, but does still occur occasionally)
--- potentially nefarious reasons including man-in-the-middle attacks or phishing scams.
--- The Hammerspoon server provided by hs.httpserver uses a self-signed certificate when set to use SSL, so it will be
--- considered invalid for reason 1 above.
--- If the certificate has been granted an exception in another application which registers the exception in the user's
--- keychain (e.g. Safari), then the certificate is no longer considered invalid and this setting has no effect for
--- that certificate.
---@param flag function|nil
---@return webviewObject
function webview:examineInvalidCertificates(flag) end

--- Get or set the frame of the webview window.
---
--- Note: a rect-table is a table with key-value pairs specifying the new top-left coordinate on the screen of the
--- webview window (keys x and y ) and the new size (keys h and w ).  The table may be crafted by any method which
--- includes these keys, including the use of an hs.geometry object.
---@param rect table|nil
---@return webviewObject
function webview:frame(rect) end

--- Move to the previous page in the webview's history, if possible.
---@return webviewObject
function webview:goBack() end

--- Move to the next page in the webview's history, if possible.
---@return webviewObject
function webview:goForward() end

--- Hides the webview object
---@param fadeOutTime number|nil
---@return webviewObject
function webview:hide(fadeOutTime) end

--- Returns the URL history for the current webview as an array.
---@return historyTable
function webview:historyList() end

--- Returns an hs.window object for the webview so that you can use hs.window methods on it.
---
--- Note: hs.window:minimize only works if the webview is minimizable (see hs.webview.windowStyle )
--- hs.window:setSize only works if the webview is resizable (see hs.webview.windowStyle )
--- hs.window:close only works if the webview is closable (see hs.webview.windowStyle )
--- hs.window:maximize will reposition the webview to the upper left corner of your screen, but will only resize the
--- webview if the webview is resizable (see hs.webview.windowStyle )
---@return hs.window
function webview:hswindow() end

--- Render the given HTML in the webview with an optional base URL for relative links.
---
--- Note: Web Pages generated in this manner are not added to the webview history list
---@param html any
---@param baseURL string
---@return webviewObject
---@return navigationIdentifier
function webview:html(html, baseURL) end

--- Returns a boolean value indicating if all content current displayed in the webview was loaded over securely
--- encrypted connections.
---@return boolean
function webview:isOnlySecureContent() end

--- Checks to see if a webview window is visible or not.
---@return boolean
function webview:isVisible() end

--- Get or set the window level
---
--- Note: see the notes for hs.drawing.windowLevels
---@param theLevel hs.drawing.windowLevels|nil
---@return hs.drawing
function webview:level(theLevel) end

--- Returns a boolean value indicating whether or not the webview is still loading content.
---@return boolean
function webview:loading() end

--- Get or set the webviews current magnification level. Default is 1.0.
---@param value number|nil
---@return webviewObject
function webview:magnification(value) end

--- Sets a callback for tracking a webview's navigation process.
---
--- Note: The return value of the callback function is ignored except when the action argument is equal to
--- didFailNavigation or didFailProvisionalNavigation .  If the return value when the action argument is one of these
--- values is a string, it will be treated as html and displayed in the webview as the error message.  If the return
--- value is the boolean value true, then no change will be made to the webview (it will continue to display the
--- previous web page).  All other return values or no return value at all, if these navigation actions occur, will
--- cause a default error page to be displayed in the webview.
---@param fn function
---@return webviewObject
function webview:navigationCallback(fn) end

--- Get the most recent navigation identifier for the specified webview.
---
--- Note: This navigation identifier can be used to track the progress of a webview with the navigation callback
--- function - see hs.webview.navigationCallback .
---@return navigationID
function webview:navigationID() end

--- Moves webview object above webview2, or all webview objects in the same presentation level, if webview2 is not
--- given.
---
--- Note: If the webview object and webview2 are not at the same presentation level, this method will move the webview
--- object as close to the desired relationship without changing the webview object's presentation level. See
--- hs.webview.level .
---@param webview2 any
---@return webviewObject
function webview:orderAbove(webview2) end

--- Moves webview object below webview2, or all webview objects in the same presentation level, if webview2 is not
--- given.
---
--- Note: If the webview object and webview2 are not at the same presentation level, this method will move the webview
--- object as close to the desired relationship without changing the webview object's presentation level. See
--- hs.webview.level .
---@param webview2 any
---@return webviewObject
function webview:orderBelow(webview2) end

--- Get the parent webview object for the calling webview object, or nil if the webview has no parent.
---@return webviewObject|nil
function webview:parent() end

--- Sets a callback to approve or deny web navigation activity.
---
--- Note: With the newWindow action, the navigationCallback and policyCallback are automatically replicated for the new
--- window from its parent.  If you wish to disable these for the new window or assign a different set of callback
--- functions, you can do so before returning true in the callback function with the webview argument provided.
---@param fn function
---@return webviewObject
function webview:policyCallback(fn) end

--- Returns whether or not the webview browser is set up for private browsing (i.e. uses a non-persistent datastore)
---
--- Note: This method is only supported by OS X 10.11 and newer
--- See hs.webview.datastore and hs.webview.new for more information.
---@return boolean
function webview:privateBrowsing() end

--- Reload the page in the webview, optionally performing end-to-end revalidation using cache-validating conditionals
--- if possible.
---@param validate any
---@return webviewObject
---@return navigationIdentifier
function webview:reload(validate) end

--- Places the webview object behind normal windows, between the desktop wallpaper and desktop icons
---@return webviewObject
function webview:sendToBack() end

--- Get or set whether or not the webview window has shadows. Default to false.
---@param value any
---@return webviewObject
function webview:shadow(value) end

--- Displays the webview object
---@param fadeInTime number|nil
---@return webviewObject
function webview:show(fadeInTime) end

--- Get or set the size of a webview window
---
--- Note: a size-table is a table with key-value pairs specifying the size (keys h and w ) the webview should be
--- resized to. The table may be crafted by any method which includes these keys, including the use of an hs.geometry
--- object.
---@param size table|nil
---@return webviewObject
function webview:size(size) end

--- Sets a callback to examine an invalid SSL certificate and determine if an exception should be granted.
---
--- Note: The callback function should return true if an exception should be granted for this certificate or false if
--- it should be rejected.
--- even if this callback returns true , the certificate will only be granted an exception if
--- hs.webview:examineInvalidCertificates has also been set to true .
--- once an invalid certificate has been granted an exception, the exception will remain in effect until the webview
--- object is deleted.
--- the callback is only invoked for invalid certificates -- if a certificate is valid, or once an exception has been
--- granted, the callback will not (no longer) be called for that certificate.
--- If the certificate has been granted an exception in another application which registers the exception in the user's
--- keychain (e.g. Safari), then the certificate is no longer considered invalid and this callback will not be invoked.
---@param fn function
---@return webviewObject
function webview:sslCallback(fn) end

--- Stop loading additional content for the webview.
---
--- Note: this method does not stop the loading of the primary content for the page at the specified URL
--- The documentation from Apple is unclear and experimentation has shown that if this method is applied before the
--- content of the specified URL has loaded, it can cause the webview to lock up; however it appears to stop the
--- loading of additional resources specified for the content (external script files, external style files, AJAX
--- queries, etc.) and should be used in this context.
---@return webviewObject
function webview:stopLoading() end

--- Get the title of the page displayed in the webview.
---@return title
function webview:title() end

--- Get or set the top-left coordinate of the webview window
---
--- Note: a point-table is a table with key-value pairs specifying the new top-left coordinate on the screen of the
--- webview (keys x and y ). The table may be crafted by any method which includes these keys, including the use of an
--- hs.geometry object.
---@param point table|nil
---@return webviewObject
function webview:topLeft(point) end

--- Get or set whether or not the webview background is transparent.  Default is false.
---
--- Note: When enabled, the webview's background color is equal to the body's background-color (transparent by default)
--- Setting background-color:rgba(0, 225, 0, 0.3) on <body> will give a translucent green webview background
---@param value any
---@return webviewObject
function webview:transparent(value) end

--- Get or set the URL to render for the webview.
---
--- Note: The networkServiceType field of the URL request table is a hint to the operating system about what the
--- underlying traffic is used for. This hint enhances the system's ability to prioritize traffic, determine how
--- quickly it needs to wake up the Wi-Fi radio, and so on. By providing accurate information, you improve the ability
--- of the system to optimally balance battery life, performance, and other considerations.  Likewise, inaccurate
--- information can have a deleterious effect on your system performance and battery life.
---@param URL string
---@return webviewObject
---@return navigationIdentifier|url
function webview:url(URL) end

--- Returns a table of keys containing the individual components of the URL for the webview.
---
--- Note: This method is a wrapper to the hs.http.urlParts function wich uses the OS X APIs, based on RFC 1808.
--- You may also want to consider the hs.httpserver.hsminweb.urlParts function for a version more consistent with RFC
--- 3986.
---@return table
function webview:urlParts() end

--- Get or set the webview's user agent string
---
--- Note: This method is only supported by OS X 10.11 and newer
--- The default user string used by webview objects will be something like this (the exact version numbers will differ,
--- depending upon your OS X version):
--- "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_11_5) AppleWebKit/601.6.17 (KHTML, like Gecko)"
--- By default, this method will return the empty string ("") when queried -- this indicates that the default, shown
--- above, is used.  You can also return to this default by setting the user agent to "" with this method (e.g.
--- hs.webview:userAgent("") ).
--- Some web sites tailor content based on the user string or use it for other internal purposes (tracking, statistics,
--- page availability, layout, etc.).  Common user-agent strings can be found at
--- http://www.useragentstring.com/pages/useragentstring.php.
--- If you have set the user agent application name with the applicationName parameter to the hs.webview.new
--- constructor, it will be ignored unless this value is "", i.e. the default user agent string.  If you wish to
--- specify an application name after the user agent string and use a custom string, include the application name in
--- your custom string.
---@param agent string
---@return webviewObject
function webview:userAgent(agent) end

--- Set or clear a callback for updates to the webview window
---@param fn function
---@return webviewObject
function webview:windowCallback(fn) end

--- Get or set the window display style
---@param mask any
---@return webviewObject|currentMask
function webview:windowStyle(mask) end

--- Sets the title for the webview window.
---
--- Note: The title will be hidden unless the window style includes the "titled" style (see hs.webview.windowStyle and
--- hs.webview.windowMasks )
---@param title string
---@return webviewObject
function webview:windowTitle(title) end

-- ------------------------------------------------------------
-- hs.webview.datastore
-- ------------------------------------------------------------

---@class hs.webview.datastore
hs.webview.datastore = {}

---@class datastore
local datastore = {}

--- Returns a list of the currently available data types within a datastore.
---
--- Note: WKWebsiteDataTypeDiskCache - On-disk caches.
--- WKWebsiteDataTypeOfflineWebApplicationCache - HTML offline web application caches.
--- WKWebsiteDataTypeMemoryCache - In-memory caches.
--- WKWebsiteDataTypeLocalStorage - HTML local storage.
--- WKWebsiteDataTypeCookies - Cookies.
--- WKWebsiteDataTypeSessionStorage - HTML session storage.
--- WKWebsiteDataTypeIndexedDBDatabases - WebSQL databases.
--- WKWebsiteDataTypeWebSQLDatabases - IndexedDB databases.
---@return table
function hs.webview.datastore.websiteDataTypes() end

--- Returns an object representing the default datastore for Hammerspoon
--- hs.webview
--- instances.
---
--- Note: this is the datastore used unless otherwise specified when creating an hs.webview instance.
---@return datastoreObject
function hs.webview.datastore.default() end

--- Returns an object representing the datastore for the specified
--- hs.webview
--- instance.
---
--- Note: When running on a system with OS X 10.11 or later, this method will also be added to the metatable for
--- hs.webview objects so that you can retrieve a webview's datastore with hs.webview:datastore() .
--- This method can be used to identify the datastore in use for a webview if you wish to create a new instance using
--- the same datastore.
---@param webview hs.webview
---@return datastoreObject
function hs.webview.datastore.fromWebview(webview) end

--- Returns an object representing a newly created non-persistent (private) datastore for use with a Hammerspoon
--- hs.webview
--- instance.
---
--- Note: The datastore represented by this object will be initially empty.  You can use this function to create a
--- non-persistent datastore that you wish to share among multiple hs.webview instances.  Once a datastore is created,
--- you assign it to a hs.webview instance by including the datastore key in the hs.webview.new constructor's
--- preferences table and setting it equal to this key.  All webview instances created with this datastore object will
--- share web caches, cookies, etc. but will still be isolated from the default datastore and it will be purged from
--- memory when the webviews are deleted, or Hammerspoon is restarted.
--- Using the datastore key in the webview's constructor differs from the private key -- use of the private key will
--- override the datastore key and will create a separate non-persistent datastore for the webview instance.  See
--- hs.webview.new for more information.
---@return datastoreObject
function hs.webview.datastore.newPrivate() end

--- Generates a list of the datastore records of the specified type, and invokes the callback function with the list.
---
--- Note: only those sites with one or more of the specified data types are returned
--- for the sites returned, only those data types that were present in the query will be included in the list, even if
--- the site has data of another type in the datastore.
---@param dataTypes table
---@param callback function
---@return datastoreObject
function datastore:fetchRecords(dataTypes, callback) end

--- Returns whether or not the datastore is persistent.
---
--- Note: Note that this value is the inverse of hs.webview:privateBrowsing() , since private browsing uses a
--- non-persistent datastore.
---@return boolean
function datastore:persistent() end

--- Removes the specified types of data from the datastore if the data was added or changed since the given date.
---
--- Note: Yes, you read the description correctly -- removes data newer then the date specified.  I've not yet found a
--- way to remove data older then the date specified (to expire old data, for example) but updates or suggestions are
--- welcome in the Hammerspoon Google group or GitHub web site.
--- to specify that all data types that qualify should be removed, specify the function
--- hs.webview.datastore.websiteDataTypes() . as the second argument.
--- For example, to purge the Hammerspoon default datastore of all data, you can do the following:
--- hs.webview.datastore.default():removeRecordsAfter(0, hs.webview.datastore.websiteDataTypes())
---@param date string
---@param dataTypes string
---@param callback function|nil
---@return datastoreObject
function datastore:removeRecordsAfter(date, dataTypes, callback) end

--- Remove data from the datastore of the specified type(s) for the specified site(s).
---
--- Note: to specify that all data types that qualify should be removed, specify the function
--- hs.webview.datastore.websiteDataTypes() . as the second argument.
---@param displayNames string
---@param dataTypes string
---@param callback function|nil
---@return datastoreObject
function datastore:removeRecordsFor(displayNames, dataTypes, callback) end

-- ------------------------------------------------------------
-- hs.webview.toolbar
-- ------------------------------------------------------------

---@class hs.webview.toolbar
hs.webview.toolbar = {}

---@class toolbar
local toolbar = {}

--- A table containing some pre-defined toolbar item priority values for use when determining item order in the toolbar.
---@type table
hs.webview.toolbar.itemPriorities = nil

--- An array containing string identifiers for supported system defined toolbar items.
---@type string
hs.webview.toolbar.systemToolbarItems = nil

--- Get or attach/detach a toolbar to the webview, chooser, or console.
---
--- Note: This function is not expected to be used directly (though it can be) -- it is added to the hs.webview and
--- hs.chooser object metatables so that it may be invoked as hs.webview:attachedToolbar([toolbarObject | nil]) /
--- hs.chooser:attachedToolbar([toolbarObject | nil]) and to the hs.console module so that it may be invoked as
--- hs.console.toolbar([toolbarObject | nil]) .
--- If the toolbar is currently attached to another window when this function is called, it will be detached from the
--- original window and attached to the new one specified by this function.
---@param obj1 any
---@param obj2 any
---@return obj1
function hs.webview.toolbar.attachToolbar(obj1, obj2) end

--- Get or set whether or not the toolbar appears in the containing window's titlebar, similar to Safari.
---
--- Note: When this value is true, the toolbar, when visible, will appear in the window's title bar similar to the
--- toolbar as seen in applications like Safari.  In this state, the toolbar will set the display of the toolbar items
--- to icons without labels, ignoring changes made with hs.webview.toolbar:displayMode .
--- This method is only valid when the toolbar is attached to a webview, chooser, or the console.
---@param state boolean
---@return toolbarObject|boolean
function toolbar:inTitleBar(state) end

--- Checks to see is a toolbar name is already in use
---@param toolbarName string
---@return boolean
function hs.webview.toolbar.uniqueName(toolbarName) end

--- Creates a new toolbar for a webview, chooser, or the console.
---
--- Note: Toolbar names must be unique, but a toolbar may be copied with hs.webview.toolbar:copy if you wish to attach
--- it to multiple windows (webview, chooser, or console).
--- See hs.webview.toolbar:addItems for a description of the format for toolbarTable
---@param toolbarName string
---@param toolbarTable table|nil
---@return toolbarObject
function hs.webview.toolbar.new(toolbarName, toolbarTable) end

--- Add one or more toolbar items to the toolbar
---
--- Note: id - A unique string identifier required for each toolbar item and group.  This key cannot be changed after
--- an item has been created.
--- allowedAlone - a boolean value, default true, specifying whether or not the toolbar item can be added to the
--- toolbar, programmatically or through the customization panel, (true) or whether it can only be added as a member of
--- a group (false).
--- default - a boolean value, default matching the value of allowedAlone for this item, indicating whether or not this
--- toolbar item or group should be displayed in the toolbar by default, unless overridden by user customization or a
--- saved configuration (when such options are enabled).
--- enable - a boolean value, default true, indicating whether or not the toolbar item is active (and can be clicked
--- on) or inactive and greyed out.  This field is ignored when applied to a toolbar group; apply it to the group
--- members instead.
--- fn - a callback function, or false to remove, specific to the toolbar item. This property is ignored if assigned to
--- the button group. This function will override the toolbar callback defined with hs.webview.toolbar:setCallback for
--- this specific item. The function should expect three (four, if the item is a searchfield ) arguments and return
--- none.  See hs.webview.toolbar:setCallback for information about the callback's arguments.
--- groupMembers - an array (table) of strings specifying the toolbar item ids that are members of this toolbar item
--- group.  If set to false, this field is removed and the item is reset back to being a regular toolbar item.  Note
--- that you cannot change a currently visible toolbar item to or from being a group; it must first be removed from
--- active toolbar with hs.webview.toolbar:removeItem .
--- image - an hs.image object, or false to remove, specifying the image to use as the toolbar item's icon when icon's
--- are displayed in the toolbar or customization panel. This key is ignored for a toolbar item group, but not for it's
--- individual members.
--- label - a string label, or false to remove, for the toolbar item or group when text is displayed in the toolbar or
--- in the customization panel. For a toolbar item, the default is the id string; for a group, the default is false .
--- If a group has a label assigned to it, the group label will be displayed for the group of items it contains. If a
--- group does not have a label, the individual items which make up the group will each display their individual labels.
--- priority - an integer value used to determine toolbar item order and which items are displayed or put into the
--- overflow menu when the number of items in the toolbar exceed the width of the window in which the toolbar is
--- attached. Some example values are provided in the hs.webview.toolbar.itemPriorities table. If a toolbar item is in
--- a group, it's priority is ignored and the item group is ordered by the item group's priority.
--- searchHistory - an array (table) of strings, specifying previous searches to automatically include in the search
--- field menu, if searchPredefinedMenuTitle is not false
--- searchHistoryAutosaveName - a string specifying the key name to save search history with in the application
--- defaults (accessible through hs.settings ). If this value is set, search history will be maintained through
--- restarts of Hammerspoon.
--- searchHistoryLimit - the maximum number of items to store in the search field history.
--- searchPredefinedMenuTitle - a string or boolean specifying how a predefined list of search field "response" should
--- be included in the search field menu. If this item is true , this list of items specified for
--- searchPredefinedSearches will be displayed in a submenu with the title "Predefined Searches". If this item is a
--- string, the list of items will be displayed in a submenu with the title specified by this string value. If this
--- item is false , then the search field menu will only contain the items specified in searchPredefinedSearches and no
--- search history will be included in the menu.
--- searchPredefinedSearches - an array (table) of strings specifying the items to be listed in the predefined search
--- submenu. If set to false, any existing menu will be removed and the search field menu will be reset to the default.
--- searchReleaseFocusOnCallback - a boolean, default false, specifying whether or not focus leaves the search field
--- text box when the callback is invoked. Setting this to true can be useful if you want subsequent keypresses to be
--- caught by the webview after reacting to the value entered into the search field by the user.
--- searchText - a string specifying the text to display in the search field.
--- searchWidth - the width of the search field text entry box.
--- selectable - a boolean value, default false, indicating whether or not this toolbar item is selectable (i.e.
--- highlights, like a selected tab) when clicked on. Only one selectable toolbar item can be highlighted at a time,
--- and you can get or set/reset the selected item with hs.webview.toolbar:selectedItem .
--- tag - an integer value which can be used for own purposes; has no affect on the visual aspect of the item or its
--- behavior.
--- tooltip - a string label, or false to remove, which is displayed as a tool tip when the user hovers the mouse over
--- the button or button group. If a button is in a group, it's tooltip is ignored in favor of the group tooltip.
---@param toolbarTable table
---@return toolbarObject
function toolbar:addItems(toolbarTable) end

--- Returns an array of all toolbar item identifiers defined for this toolbar.
---@return array
function toolbar:allowedItems() end

--- Get or set whether or not the toolbar autosaves changes made to the toolbar.
---
--- Note: If the toolbar is set to autosave, then a user-defaults entry is created in org.hammerspoon.Hammerspoon
--- domain with the key "NSToolbar Configuration XXX" where XXX is the toolbar identifier specified when the toolbar
--- was created.
--- the default item identifiers that are displayed when the toolbar is first created or when the user drags the
--- default set from the customization panel.
--- the current display mode (icon, text, both)
--- the current size mode (regular, small)
--- whether or not the toolbar is currently visible
--- the currently shown identifiers and their order
--- Note that the labels, icons, callback functions, etc. are not saved -- these are determined at toolbar creation
--- time, by the hs.webview.toolbar:addItems , or by the hs.webview.toolbar:modifyItem method and can differ between
--- invocations of toolbars with the same identifier and button identifiers.
---@param bool any
---@return toolbarObject|boolean
function toolbar:autosaves(bool) end

--- Get or set whether or not the user is allowed to customize the toolbar with the Customization Panel.
---
--- Note: the customization panel can be pulled up by right-clicking on the toolbar or by invoking
--- hs.webview.toolbar:customizePanel .
---@param bool any
---@return toolbarObject|boolean
function toolbar:canCustomize(bool) end

--- Returns a copy of the toolbar object.
---@return toolbarObject
function toolbar:copy() end

--- Opens the toolbar customization panel.
---@return toolbarObject
function toolbar:customizePanel() end

--- Deletes the toolbar, removing it from its window if it is currently attached.
---@return none
function toolbar:delete() end

--- Deletes the toolbar item specified completely from the toolbar, removing it first, if the toolbar item is currently
--- active.
---
--- Note: This method completely removes the toolbar item from the toolbar's definition dictionary, thus removing it
--- from active use in the toolbar as well as removing it from the customization panel, if supported.  If you only want
--- to remove a toolbar item from the active toolbar, consider hs.webview.toolbar:removeItem .
---@param identifier any
---@return toolbarObject
function toolbar:deleteItem(identifier) end

--- Get or set the toolbar's display mode.
---@param mode string|nil
---@return toolbarObject
function toolbar:displayMode(mode) end

--- The identifier for this toolbar.
---@return identifier
function toolbar:identifier() end

--- Insert or move the toolbar item to the index position specified
---
--- Note: the toolbar position must be between 1 and the number of currently active toolbar items.
---@param id string
---@param index number
---@return toolbarObject
function toolbar:insertItem(id, index) end

--- Returns a boolean indicating whether or not the toolbar is currently attached to a window.
---@return boolean
function toolbar:isAttached() end

--- Indicates whether or not the customization panel is currently open for the toolbar.
---@return boolean
function toolbar:isCustomizing() end

--- Returns a table containing details about the specified toolbar item
---
--- Note: For a list of the most of the possible toolbar item attribute keys, see hs.webview.toolbar:addItems .
--- The table will also include privateCallback which will be a boolean indicating whether or not this toolbar item has
--- a private callback function assigned (true) or uses the toolbar's general callback function (false).
--- toolbar - the toolbar object the item belongs to
--- subItems - if the toolbar item is actually a group, this will contain a table with basic information about the
--- members of the group.  If you wish to get the full details for each sub-member, you may iterate on the identifiers
--- provided in groupMembers .
---@param id string
---@return table
function toolbar:itemDetails(id) end

--- Returns an array of the toolbar item identifiers currently assigned to the toolbar.
---@return array
function toolbar:items() end

--- Modify the toolbar item specified by the "id" key in the table argument.
---
--- Note: You cannot change a toolbar item's id
--- For a list of the possible toolbar item attribute keys, see hs.webview.toolbar:addItems .
---@param table any
---@return toolbarObject
function toolbar:modifyItem(table) end

--- Get or set whether or not the global callback function is invoked when a toolbar item is added or removed from the
--- toolbar.
---@param bool any
---@return toolbarObject|boolean
function toolbar:notifyOnChange(bool) end

--- Remove the toolbar item at the index position specified, or with the specified identifier, if currently present in
--- the toolbar.
---
--- Note: the toolbar position must be between 1 and the number of currently active toolbar items.
---@param index | identifier any
---@return toolbarObject
function toolbar:removeItem(index | identifier) end

--- Returns a table containing the settings which will be saved for the toolbar if
--- hs.webview.toolbar:autosaves
--- is true.
---
--- Note: If the toolbar is set to autosave, then a user-defaults entry is created in org.hammerspoon.Hammerspoon
--- domain with the key "NSToolbar Configuration XXX" where XXX is the toolbar identifier specified when the toolbar
--- was created.
--- This method is provided if you do not wish for changes to the toolbar to be autosaved for every change, but may
--- wish to save it programmatically under specific conditions.
---@return table
function toolbar:savedSettings() end

--- Get or set the selected toolbar item
---
--- Note: Only toolbar items which were defined as selectable when created with hs.webview.toolbar.new can be selected
--- with this method.
---@param item any
---@return toolbarObject
function toolbar:selectedItem(item) end

--- Programmatically focus the search field for keyboard input.
---
--- Note: if there is current text in the searchfield, it will be selected so that any subsequent typing by the user
--- will replace the current value in the searchfield.
---@param identifier string|nil
---@return toolbarObject|boolean
function toolbar:selectSearchField(identifier) end

--- Get or set whether or not the toolbar shows a separator between the toolbar and the main window contents.
---@param bool any
---@return toolbarObject|boolean
function toolbar:separator(bool) end

--- Sets or removes the global callback function for the toolbar.
---
--- Note: the global callback function is invoked for a toolbar button item that does not have a specific function
--- assigned directly to it.
--- if hs.webview.toolbar:notifyOnChange is set to true, then this callback function will also be invoked when a
--- toolbar item is added or removed from the toolbar either programmatically with hs.webview.toolbar:insertItem and
--- hs.webview.toolbar:removeItem or under user control with hs.webview.toolbar:customizePanel and the callback
--- function will receive a string of "add" or "remove" as a fourth argument.
---@param fn function|nil
---@return toolbarObject
function toolbar:setCallback(fn) end

--- Get or set the toolbar's size.
---@param size string|nil
---@return toolbarObject
function toolbar:sizeMode(size) end

--- Get or set the toolbar's style.
---
--- Note: This is only available for macOS 11.0+. Will return nil if getting on an earlier version of macOS.
--- automatic - A style indicating that the system determines the toolbar’s appearance and location.
--- expanded - A style indicating that the toolbar appears below the window title.
--- preference - A style indicating that the toolbar appears below the window title with toolbar items centered in the
--- toolbar.
--- unified - A style indicating that the toolbar appears next to the window title.
--- unifiedCompact - A style indicating that the toolbar appears next to the window title and with reduced margins to
--- allow more focus on the window’s contents.
---@param style string|nil
---@return toolbarObject
function toolbar:toolbarStyle(style) end

--- Get or set whether or not the toolbar is currently visible in the window it is attached to.
---@param bool any
---@return toolbarObject|boolean
function toolbar:visible(bool) end

--- Returns an array of the currently visible toolbar item identifiers.
---@return array
function toolbar:visibleItems() end

-- ------------------------------------------------------------
-- hs.webview.usercontent
-- ------------------------------------------------------------

---@class hs.webview.usercontent
hs.webview.usercontent = {}

---@class usercontent
local usercontent = {}

--- Create a new user content controller for a webview and create the message port with the specified name for
--- JavaScript message support.
---
--- Note: This object should be provided as the final argument to the hs.webview.new constructor in order to tie the
--- webview to this content controller.  All new windows which are created from this parent webview will also use this
--- controller.
--- See hs.webview.usercontent:setCallback for more information about the message port.
---@param name string
---@return usercontentControllerObject
function hs.webview.usercontent.new(name) end

--- Add a script to be injected into webviews which use this user content controller.
---@param scriptTable any
---@return usercontentControllerObject
function usercontent:injectScript(scriptTable) end

--- Removes all user scripts currently defined for this user content controller.
---
--- Note: The WKUserContentController class only allows for removing all scripts.  If you need finer control, make a
--- copy of the current scripts with hs.webview.usercontent.userScripts() first so you can recreate the scripts you
--- want to keep.
---@return usercontentControllerObject
function usercontent:removeAllScripts() end

--- Set or remove the callback function to handle message posted to this user content's message port.
---
--- Note: Within your (injected or served) JavaScript, you can post messages via the message port created with the
--- constructor like this: try {
--- webkit.messageHandlers. name >.postMessage( message-object );
--- } catch(err) {
--- console.log('The controller does not exist yet');
--- }
--- Where name matches the name specified in the constructor and message-object is the object to post to the function.
--- This object can be a number, string, date, array, dictionary(table), or nil.
---@param fn function
---@return usercontentControllerObject
function usercontent:setCallback(fn) end

--- Get a table containing all of the currently defined injection scripts for this user content controller
---
--- Note: Because the WKUserContentController class only allows for removing all scripts, you can use this method to
--- generate a list of all scripts, modify it, and then use it in a loop to reapply the scripts if you need to remove
--- just a few scripts.
---@return array
function usercontent:userScripts() end

-- ------------------------------------------------------------
-- hs.wifi
-- ------------------------------------------------------------

---@class hs.wifi
hs.wifi = {}

---@class wifi
local wifi = {}

--- Connect the interface to a wireless network
---
--- Note: Enterprise WiFi networks are not currently supported. Please file an issue on GitHub if you need support for
--- enterprise networks
--- This function blocks Hammerspoon until the operation is completed
--- If multiple access points are available with the same SSID, one will be chosen at random to connect to
---@param network string
---@param passphrase string
---@param interface? hs.wifi.interfaces|nil
---@return boolean
function hs.wifi.associate(network, passphrase, interface) end

--- Gets a list of available WiFi networks
---
--- Note: WARNING: This function will block all Lua execution until the scan has completed. It's probably not very
--- sensible to use this function very much, if at all.
---@param interface hs.wifi.interfaces|nil
---@return table
function hs.wifi.availableNetworks(interface) end

--- Gets the name of the current WiFi network
---@param interface hs.wifi.interfaces|nil
---@return string|nil
function hs.wifi.currentNetwork(interface) end

--- Disconnect the interface from its current network.
---@param interface hs.wifi.interfaces|nil
---@return nil
function hs.wifi.disassociate(interface) end

--- Returns a table containing details about the wireless interface.
---@param interface hs.wifi.interfaces|nil
---@return table
function hs.wifi.interfaceDetails(interface) end

--- Returns a list of interface names for WLAN devices attached to the system
---
--- Note: For most systems, this will be one interface, but the result is still returned as an array.
---@return table
function hs.wifi.interfaces() end

--- Turns a wifi interface on or off
---@param state boolean
---@param interface hs.wifi.interfaces|nil
---@return boolean
function hs.wifi.setPower(state, interface) end

--- Perform a scan for available wifi networks in the background (non-blocking)
---
--- Note: If you pass in nil as the callback function, the scan occurs but no callback function is called.  This can be
--- useful to update the cachedScanResults entry returned by hs.wifi.interfaceDetails .
--- The callback function should expect one argument which will be a table if the scan was successful or a string
--- containing an error message if it was not.  The table will be an array of available networks.  Each entry in the
--- array will be a table containing the following keys:
--- beaconInterval         - The beacon interval (ms) for the network.
--- bssid                  - The basic service set identifier (BSSID) for the network.
--- countryCode            - The country code (ISO/IEC 3166-1:1997) for the network.
--- ibss                   - Whether or not the network is an IBSS (ad-hoc) network.
--- informationElementData - Information element data included in beacon or probe response frames as an array of
--- integers.
--- noise                  - The aggregate noise measurement (dBm) for the network.
--- PHYModes               - A table containing the PHY Modes supported by the network.
--- rssi                   - The aggregate received signal strength indication (RSSI) measurement (dBm) for the network.
--- security               - A table containing the security types supported by the network.
--- ssid                   - The service set identifier (SSID) for the network, encoded as a string.
--- ssidData               - The service set identifier (SSID) for the network, returned as data (1-32 octets).
--- wlanChannel            - A table containing details about the channel the network is on. The table will contain the
--- following keys:
--- band   - The channel band.
--- number - The channel number.
--- width  - The channel width.
--- You can convert this data into a Lua string by passing the array as an argument to
--- string.char(table.unpack(results.informationElementData)) , but note that this field contains arbitrary binary data
--- and should not be treated or considered as a displayable string. It requires additional parsing, depending upon the
--- specific information you need from the probe or beacon response.
--- For debugging purposes, if you wish to view the contents of this field as a string, make sure to wrap
--- string.char(table.unpack(results.informationElementData)) with hs.utf8.asciiOnly or hs.utf8.hexDump , rather than
--- just print the result directly.
--- As an example using hs.wifi.interfaceDetails whose cachedScanResults key is an array of entries identical to the
--- argument passed to this constructor's callback function:
--- function dumpIED(interface)
--- local interface = interface or "en0"
--- local cleanupFunction = hs.utf8.hexDump -- or hs.utf8.asciiOnly if you prefer
--- local cachedScanResults = hs.wifi.interfaceDetails(interface).cachedScanResults
--- if not cachedScanResults then
--- hs.wifi.availableNetworks() -- blocking, so only do if necessary
--- cachedScanResults = hs.wifi.interfaceDetails(interface).cachedScanResults
--- end
--- for i, v in ipairs(cachedScanResults) do
--- print(v.ssid .. " on channel " .. v.wlanChannel.number .. " beacon data:")
--- print(cleanupFunction(string.char(table.unpack(v.informationElementData))))
--- end
--- end
--- These precautions are in response to Hammerspoon GitHub Issue #859.  As binary data, even when cleaned up with the
--- Console's UTF8 wrapper code, some valid UTF8 sequences have been found to cause crashes in the OSX CoreText API
--- during rendering.  While some specific sequences have made the rounds on the Internet, the specific code analysis
--- at http://www.theregister.co.uk/2015/05/27/text_message_unicode_ios_osx_vulnerability/ suggests a possible cause of
--- the problem which may be triggered by other currently unknown sequences as well.  As the sequences aren't at
--- present predictable, we can't add to the UTF8 wrapper already in place for the Hammerspoon console.
---@param fn function
---@param interface hs.wifi.interfaces|nil
---@return scanObject
function hs.wifi.backgroundScan(fn, interface) end

--- Returns whether or not a scan object has completed its scan for wireless networks.
---
--- Note: This will be set whether or not an actual callback function was invoked.  This method can be checked to see
--- if the cached data for the cachedScanResults entry returned by hs.wifi.interfaceDetails has been updated.
---@return boolean
function wifi:isDone() end

-- ------------------------------------------------------------
-- hs.wifi.watcher
-- ------------------------------------------------------------

---@class hs.wifi.watcher
hs.wifi.watcher = {}

---@class watcher
local watcher = {}

--- A table containing the possible event types that this watcher can monitor for.
---@type table
hs.wifi.watcher.eventTypes[] = nil

--- Creates a new watcher for WiFi network events
---
--- Note: For backwards compatibility, only "SSIDChange" is watched for by default, so existing code can continue to
--- ignore the callback function arguments unless you add or change events with the hs.wifi.watcher:watchingFor .
--- watcher - the watcher object itself
--- message - the message specifying the event, in this case "SSIDChange"
--- interface - the name of the interface for which the event occurred
--- Use hs.wifi.currentNetwork([interface]) to identify the new network, which may be nil when you leave a network.
--- watcher - the watcher object itself
--- message - the message specifying the event, in this case "BSSIDChange"
--- interface - the name of the interface for which the event occurred
--- watcher - the watcher object itself
--- message - the message specifying the event, in this case "countryCodeChange"
--- interface - the name of the interface for which the event occurred
--- watcher - the watcher object itself
--- message - the message specifying the event, in this case "linkChange"
--- interface - the name of the interface for which the event occurred
--- watcher - the watcher object itself
--- message - the message specifying the event, in this case "linkQualityChange"
--- interface - the name of the interface for which the event occurred
--- rssi - the RSSI value for the currently associated network on the Wi-Fi interface
--- rate - the transmit rate for the currently associated network on the Wi-Fi interface
--- watcher - the watcher object itself
--- message - the message specifying the event, in this case "modeChange"
--- interface - the name of the interface for which the event occurred
--- watcher - the watcher object itself
--- message - the message specifying the event, in this case "powerChange"
--- interface - the name of the interface for which the event occurred
--- watcher - the watcher object itself
--- message - the message specifying the event, in this case "scanCacheUpdated"
--- interface - the name of the interface for which the event occurred
---@param fn function
---@return watcher
function hs.wifi.watcher.new(fn) end

--- Starts the SSID watcher
---@return watcher
function watcher:start() end

--- Stops the SSID watcher
---@return watcher
function watcher:stop() end

--- Get or set the specific types of wifi events to generate a callback for with this watcher.
---
--- Note: the possible values for this method are described in hs.wifi.watcher.eventTypes .
--- the special string "all" specifies that all event types should be watched for.
---@param messages function|nil
---@return watcher|current-
function watcher:watchingFor(messages) end

-- ------------------------------------------------------------
-- hs.window
-- ------------------------------------------------------------

---@class hs.window
hs.window = {}

---@class window
local window = {}

--- The default duration for animations, in seconds. Initial value is 0.2; set to 0 to disable animations.
---@type any
hs.window.animationDuration (number) = nil

--- Using
--- hs.window:setFrame()
--- in some cases does not work as expected: namely, the bottom (or Dock) edge, and edges between screens, might
---@type hs.window
hs.window.setFrameCorrectness = nil

--- Returns all windows
---
--- Note: visibleWindows() , orderedWindows() , get() , find() , and several more functions and methods in this and
--- other
--- modules make use of this function, so it is important to understand its limitations
--- This function queries all applications for their windows every time it is invoked; if you need to call it a lot and
--- performance is not acceptable consider using the hs.window.filter module
--- if Displays have separate Spaces is on (in System Preferences>Mission Control) the current Space is defined
--- as the union of all currently visible Spaces
--- minimized windows and hidden windows (i.e. belonging to hidden apps, e.g. via cmd-h) are always considered
--- to be in the current Space
--- This function filters out the desktop "window"; use hs.window.desktop() to address it. (Note however that
--- hs.application.get'Finder':allWindows() will include the desktop in the returned list)
--- Beside the limitations discussed above, this function will return all windows as reported by OSX, including some
--- "windows" that one wouldn't expect: for example, every Google Chrome (actual) window has a companion window for its
--- status bar; therefore you might get unexpected results  - in the Chrome example, calling
--- hs.window.focusWindowSouth() from a Chrome window would end up "focusing" its status bar, and therefore the proper
--- window itself, seemingly resulting
--- in a no-op. In order to avoid such surprises you can use the hs.window.filter module, and more specifically
--- the default windowfilter ( hs.window.filter.default ) which filters out known cases of not-actual-windows
--- Some windows will not be reported by OSX - e.g. things that are on different Spaces, or things that are Full Screen
---@return list of hs.window objects
function hs.window.allWindows() end

--- Returns the desktop "window"
---
--- Note: The desktop belongs to Finder.app: when Finder is the active application, you can focus the desktop by cycling
--- through windows via cmd-`
--- The desktop window has no id, a role of AXScrollArea and no subrole
--- The desktop is filtered out from hs.window.allWindows() (and downstream uses)
---@return hs.window
function hs.window.desktop() end

--- Gets all invisible windows
---@return list of hs.window objects
function hs.window.invisibleWindows() end

--- Gets a table containing all the window data retrieved from
--- CGWindowListCreate
--- .
---
--- Note: This allows you to get window information without Accessibility Permissions.
---@param allWindows any
---@return table
function hs.window.list(allWindows) end

--- Gets all minimized windows
---@return list of hs.window objects
function hs.window.minimizedWindows() end

--- Returns all visible windows, ordered from front to back
---@return list of hs.window objects
function hs.window.orderedWindows() end

--- Enables/Disables window shadows
---
--- Note: This function uses a private, undocumented OS X API call, so it is not guaranteed to work in any future OS X
--- release
---@param shadows boolean
---@return any
function hs.window.setShadows(shadows) end

--- Returns a snapshot of the window specified by the ID as an
--- hs.image
--- object
---
--- Note: See also method hs.window:snapshot()
--- Because the window ID cannot always be dynamically determined, this function will allow you to provide the ID of a
--- window that was cached earlier.
---@param ID string
---@param keepTransparency? number
---@return hs.image-object
function hs.window.snapshotForID(ID, keepTransparency) end

--- Sets the timeout value used in the accessibility API.
---@param value number
---@return boolean
function hs.window.timeout(value) end

--- Gets all visible windows
---@return list of hs.window objects
function hs.window.visibleWindows() end

--- Finds windows
---
--- Note: for convenience you can call this as hs.window(hint)
--- see also hs.window.get
--- for more sophisticated use cases and/or for better performance if you call this a lot, consider using
--- hs.window.filter
--- Usage:
--- -- by id
--- hs.window(8812):title() --> Hammerspoon Console
--- -- by title
--- hs.window'bash':application():name() --> Terminal
---@param hint hs.window
---@return hs.window
function hs.window.find(hint) end

--- Returns the window that has keyboard/mouse focus
---@return window
function hs.window.focusedWindow() end

--- Returns the focused window or, if no window has focus, the frontmost one
---@return hs.window
function hs.window.frontmostWindow() end

--- Gets a specific window
---
--- Note: see also hs.window.find and hs.application:getWindow()
---@param hint hs.window
---@return hs.window
function hs.window.get(hint) end

--- Gets the
--- hs.application
--- object the window belongs to
---@return app|nil
function window:application() end

--- Makes the window the main window of its application
---
--- Note: Make a window become the main window does not transfer focus to the application. See hs.window.focus()
---@return window
function window:becomeMain() end

--- Centers the window on a screen
---@param screen hs.screen|hs.screen.find|nil
---@param ensureInScreenBounds? any
---@param duration? hs.window.animationDuration|nil
---@return hs.window
function window:centerOnScreen(screen, ensureInScreenBounds, duration) end

--- Closes the window
---@return boolean
function window:close() end

--- Focuses the window
---@return hs.window
function window:focus() end

--- Focuses the tab in the window's tab group at index, or the last tab if index is out of bounds
---
--- Note: This method works with document tab groups and some app tabs, like Chrome and Safari.
---@param index number
---@return boolean
function window:focusTab(index) end

--- Focuses the nearest possible window to the east (i.e. right)
---
--- Note: If you don't pass candidateWindows , Hammerspoon will query for the list of all visible windows
--- every time this method is called; this can be slow, and some undesired "windows" could be included
--- (see the notes for hs.window.allWindows() ); consider using the equivalent methods in hs.window.filter instead
---@param candidateWindows candidate[]|nil
---@param frontmost? boolean|nil
---@param strict? boolean|nil
---@return boolean
function window:focusWindowEast(candidateWindows, frontmost, strict) end

--- Focuses the nearest possible window to the north (i.e. up)
---
--- Note: If you don't pass candidateWindows , Hammerspoon will query for the list of all visible windows
--- every time this method is called; this can be slow, and some undesired "windows" could be included
--- (see the notes for hs.window.allWindows() ); consider using the equivalent methods in hs.window.filter instead
---@param candidateWindows candidate[]|nil
---@param frontmost? boolean|nil
---@param strict? boolean|nil
---@return boolean
function window:focusWindowNorth(candidateWindows, frontmost, strict) end

--- Focuses the nearest possible window to the south (i.e. down)
---
--- Note: If you don't pass candidateWindows , Hammerspoon will query for the list of all visible windows
--- every time this method is called; this can be slow, and some undesired "windows" could be included
--- (see the notes for hs.window.allWindows() ); consider using the equivalent methods in hs.window.filter instead
---@param candidateWindows candidate[]|nil
---@param frontmost? boolean|nil
---@param strict? boolean|nil
---@return boolean
function window:focusWindowSouth(candidateWindows, frontmost, strict) end

--- Focuses the nearest possible window to the west (i.e. left)
---
--- Note: If you don't pass candidateWindows , Hammerspoon will query for the list of all visible windows
--- every time this method is called; this can be slow, and some undesired "windows" could be included
--- (see the notes for hs.window.allWindows() ); consider using the equivalent methods in hs.window.filter instead
---@param candidateWindows candidate[]|nil
---@param frontmost? boolean|nil
---@param strict? boolean|nil
---@return boolean
function window:focusWindowWest(candidateWindows, frontmost, strict) end

--- Gets the frame of the window in absolute coordinates
---@return hs.geometry rect
function window:frame() end

--- Gets the unique identifier of the window
---@return number|nil
function window:id() end

--- Gets the fullscreen state of the window
---@return boolean|nil
function window:isFullScreen() end

--- Determines if a window is maximizable
---@return boolean|nil
function window:isMaximizable() end

--- Gets the minimized state of the window
---@return boolean
function window:isMinimized() end

--- Determines if the window is a standard window
---
--- Note: "Standard window" means that this is not an unusual popup window, a modal dialog, a floating window, etc.
---@return boolean
function window:isStandard() end

--- Determines if a window is visible (i.e. not hidden and not minimized)
---
--- Note: This does not mean the user can see the window - it may be obscured by other windows, or it may be off the
--- edge of the screen
---@return boolean
function window:isVisible() end

--- Maximizes the window
---
--- Note: The window will be resized as large as possible, without obscuring the dock/menu
---@param duration hs.window.animationDuration|nil
---@return hs.window
function window:maximize(duration) end

--- Minimizes the window
---
--- Note: This method will always animate per your system settings and is not affected by hs.window.animationDuration
---@return window
function window:minimize() end

--- Moves the window
---@param rect hs.geometry
---@param screen? hs.screen|hs.screen.find|nil
---@param ensureInScreenBounds? any
---@param duration? hs.window.animationDuration|nil
---@return hs.window
function window:move(rect, screen, ensureInScreenBounds, duration) end

--- Moves the window one screen east (i.e. right)
---@param noResize number
---@param ensureInScreenBounds any
---@param duration? hs.window.animationDuration|nil
---@return hs.window
function window:moveOneScreenEast(noResize, ensureInScreenBounds, duration) end

--- Moves the window one screen north (i.e. up)
---@param noResize number
---@param ensureInScreenBounds any
---@param duration? hs.window.animationDuration|nil
---@return hs.window
function window:moveOneScreenNorth(noResize, ensureInScreenBounds, duration) end

--- Moves the window one screen south (i.e. down)
---@param noResize number
---@param ensureInScreenBounds any
---@param duration? hs.window.animationDuration|nil
---@return hs.window
function window:moveOneScreenSouth(noResize, ensureInScreenBounds, duration) end

--- Moves the window one screen west (i.e. left)
---@param noResize number
---@param ensureInScreenBounds any
---@param duration? hs.window.animationDuration|nil
---@return hs.window
function window:moveOneScreenWest(noResize, ensureInScreenBounds, duration) end

--- Moves the window to a given screen, retaining its relative position and size
---@param screen hs.screen|hs.screen.find
---@param noResize? number
---@param ensureInScreenBounds? any
---@param duration? hs.window.animationDuration|nil
---@return hs.window
function window:moveToScreen(screen, noResize, ensureInScreenBounds, duration) end

--- Moves and resizes the window to occupy a given fraction of the screen
---
--- Note: An example, which would make a window fill the top-left quarter of the screen:
--- win:moveToUnit'[0.0,0.0,0.5,0.5]'
---@param unitrect hs.geometry
---@param duration? hs.window.animationDuration|nil
---@return hs.window
function window:moveToUnit(unitrect, duration) end

--- Gets every window except this one
---@return list of hs.window objects
function window:otherWindowsAllScreens() end

--- Gets other windows on the same screen
---@return list of hs.window objects
function window:otherWindowsSameScreen() end

--- Brings a window to the front of the screen without focussing it
---@return window
function window:raise() end

--- Gets the role of the window
---@return string
function window:role() end

--- Gets the screen which the window is on
---
--- Note: While windows can be dragged to span multiple screens, part of the window will disappear when the mouse is
--- released. The screen returned by this method will be the part of the window that remains visible.
---@return hs.screen
function window:screen() end

--- Sends the window to the back
---
--- Note: Due to the way this method works and OSX limitations, calling this method when you have a lot of randomly
--- overlapping (as opposed to neatly tiled) windows might be visually jarring, and take a fair amount of time to
--- complete. So if you don't use orderly layouts, or if you have a lot of windows in general, you're probably better
--- off using hs.application:hide() (or simply cmd-h )
--- This method works by focusing all overlapping windows behind this one, front to back. If called on the focused
--- window, this method will switch focus to the topmost window under this one; otherwise, the currently focused window
--- will regain focus after this window has been sent to the back.
---@return hs.window
function window:sendToBack() end

--- Sets the frame of the window in absolute coordinates
---@param rect hs.geometry
---@param duration? hs.window.animationDuration|nil
---@return hs.window
function window:setFrame(rect, duration) end

--- Sets the frame of the window in absolute coordinates, possibly adjusted to ensure it is fully inside the screen
---@param rect hs.geometry
---@param duration? hs.window.animationDuration|nil
---@return hs.window
function window:setFrameInScreenBounds(rect, duration) end

--- Sets the frame of the window in absolute coordinates, using the additional workarounds described in
--- hs.window.setFrameCorrectness
---@param rect hs.geometry
---@param duration? hs.window.animationDuration|nil
---@return hs.window
function window:setFrameWithWorkarounds(rect, duration) end

--- Sets the fullscreen state of the window
---@param fullscreen boolean
---@return window
function window:setFullScreen(fullscreen) end

--- Resizes the window
---@param size table
---@return window
function window:setSize(size) end

--- Moves the window to a given point
---@param point table
---@return window
function window:setTopLeft(point) end

--- Gets the size of the window
---@return size
function window:size() end

--- Returns a snapshot of the window as an
--- hs.image
--- object
---
--- Note: See also function hs.window.snapshotForID()
---@param keepTransparency number
---@return hs.image-object
function window:snapshot(keepTransparency) end

--- Gets the subrole of the window
---
--- Note: This typically helps to determine if a window is a special kind of window - such as a modal window, or a
--- floating window
---@return string
function window:subrole() end

--- Gets the number of tabs in the window has
---
--- Note: Intended for use with the focusTab method, if this returns a number, then focusTab can switch between that
--- many tabs.
---@return number|nil
function window:tabCount() end

--- Gets the title of the window
---@return string
function window:title() end

--- Toggles the fullscreen state of the window
---
--- Note: Not all windows support being full-screened
---@return hs.window
function window:toggleFullScreen() end

--- Toggles the zoom state of the window (this is effectively equivalent to clicking the green maximize/fullscreen
--- button at the top left of a window)
---@return window
function window:toggleZoom() end

--- Gets the absolute co-ordinates of the top left of the window
---@return point
function window:topLeft() end

--- Un-minimizes the window
---@return window
function window:unminimize() end

--- Gets all windows to the east of this window
---
--- Note: If you don't pass candidateWindows , Hammerspoon will query for the list of all visible windows every time
--- this method is called; this can be slow, and some undesired "windows" could be included (see the notes for
--- hs.window.allWindows() ); consider using the equivalent methods in hs.window.filter instead
---@param candidateWindows candidate[]|nil
---@param frontmost? boolean|nil
---@param strict? boolean|nil
---@return list of hs.window objects
function window:windowsToEast(candidateWindows, frontmost, strict) end

--- Gets all windows to the north of this window
---
--- Note: If you don't pass candidateWindows , Hammerspoon will query for the list of all visible windows every time
--- this method is called; this can be slow, and some undesired "windows" could be included (see the notes for
--- hs.window.allWindows() ); consider using the equivalent methods in hs.window.filter instead
---@param candidateWindows candidate[]|nil
---@param frontmost? boolean|nil
---@param strict? boolean|nil
---@return list of hs.window objects
function window:windowsToNorth(candidateWindows, frontmost, strict) end

--- Gets all windows to the south of this window
---
--- Note: If you don't pass candidateWindows , Hammerspoon will query for the list of all visible windows every time
--- this method is called; this can be slow, and some undesired "windows" could be included (see the notes for
--- hs.window.allWindows() ); consider using the equivalent methods in hs.window.filter instead
---@param candidateWindows candidate[]|nil
---@param frontmost? boolean|nil
---@param strict? boolean|nil
---@return list of hs.window objects
function window:windowsToSouth(candidateWindows, frontmost, strict) end

--- Gets all windows to the west of this window
---
--- Note: If you don't pass candidateWindows , Hammerspoon will query for the list of all visible windows every time
--- this method is called; this can be slow, and some undesired "windows" could be included (see the notes for
--- hs.window.allWindows() ); consider using the equivalent methods in hs.window.filter instead
---@param candidateWindows candidate[]|nil
---@param frontmost? boolean|nil
---@param strict? boolean|nil
---@return list of hs.window objects
function window:windowsToWest(candidateWindows, frontmost, strict) end

--- Gets a rect-table for the location of the zoom button (the green button typically found at the top left of a window)
---
--- Note: The co-ordinates in the rect-table (i.e. the x and y values) are in absolute co-ordinates, not relative to
--- the window the button is part of, or the screen the window is on
--- Although not perfect as such, this method can provide a useful way to find a region of the titlebar suitable for
--- simulating mouse click events on, with hs.eventtap
---@return rect-table|nil
function window:zoomButtonRect() end

-- ------------------------------------------------------------
-- hs.window.filter
-- ------------------------------------------------------------

---@class hs.window.filter
hs.window.filter = {}

---@class filter
local filter = {}

---@class hs.window.filter.filter
---@field default any The default windowfilter; it filters apps whose windows are transient in nature so that you're unlikely (and often
---@field defaultCurrentSpace any A copy of the default windowfilter (see hs.window.filter.default ) that only allows windows in the current
---@field hasNoWindows any Pseudo-event for hs.window.filter:subscribe() : the windowfilter now rejects all windows
---@field hasWindow any Pseudo-event for hs.window.filter:subscribe() : the windowfilter now allows one window
---@field sortByCreated any Sort order for hs.window.filter:getWindows() : windows are sorted in order of creation, oldest...

--- The default windowfilter; it filters apps whose windows are transient in nature so that you're unlikely (and often
---@type any
hs.window.filter.default = nil

--- A copy of the default windowfilter (see
--- hs.window.filter.default
--- ) that only allows windows in the current
---@type hs.window.filter.default
hs.window.filter.defaultCurrentSpace = nil

--- Pseudo-event for
--- hs.window.filter:subscribe()
--- : the windowfilter now rejects all windows
---@type hs.window.filter
hs.window.filter.hasNoWindows = nil

--- Pseudo-event for
--- hs.window.filter:subscribe()
--- : the windowfilter now allows one window
---@type hs.window.filter
hs.window.filter.hasWindow = nil

--- Sort order for
--- hs.window.filter:getWindows()
--- : windows are sorted in order of creation, oldest first (see also
--- hs.window.filter:setSortOrder()
--- )
---@type hs.window.filter
hs.window.filter.sortByCreated = nil

--- Sort order for
--- hs.window.filter:getWindows()
--- : windows are sorted in order of creation, newest first (see also
--- hs.window.filter:setSortOrder()
--- )
---@type hs.window.filter
hs.window.filter.sortByCreatedLast = nil

--- Sort order for
--- hs.window.filter:getWindows()
--- : windows are sorted in order of focus received, least recently first (see also
--- hs.window.filter:setSortOrder()
--- )
---@type hs.window.filter
hs.window.filter.sortByFocused = nil

--- Sort order for
--- hs.window.filter:getWindows()
--- : windows are sorted in order of focus received, most recently first (see also
--- hs.window.filter:setSortOrder()
--- )
---@type hs.window.filter
hs.window.filter.sortByFocusedLast = nil

--- Pseudo-event for
--- hs.window.filter:subscribe()
--- : a previously rejected window (or a newly created one) is now allowed
---@type hs.window.filter
hs.window.filter.windowAllowed = nil

--- Event for
--- hs.window.filter:subscribe()
--- : a new window was created
---@type hs.window.filter
hs.window.filter.windowCreated = nil

--- Event for
--- hs.window.filter:subscribe()
--- : a window was destroyed
---@type hs.window.filter
hs.window.filter.windowDestroyed = nil

--- Event for
--- hs.window.filter:subscribe()
--- : a window received focus
---@type hs.window.filter
hs.window.filter.windowFocused = nil

--- Event for
--- hs.window.filter:subscribe()
--- : a window was expanded to fullscreen
---@type hs.window.filter
hs.window.filter.windowFullscreened = nil

--- Event for
--- hs.window.filter:subscribe()
--- : a window was hidden (its app was hidden, e.g. via
--- cmd-h
--- )
---@type hs.window.filter
hs.window.filter.windowHidden = nil

--- Event for
--- hs.window.filter:subscribe()
--- : a window is now in the current Mission Control Space, due to
---@type hs.window.filter
hs.window.filter.windowInCurrentSpace = nil

--- Event for
--- hs.window.filter:subscribe()
--- : a window was minimized
---@type hs.window.filter
hs.window.filter.windowMinimized = nil

--- Event for
--- hs.window.filter:subscribe()
--- : a window was moved or resized, including toggling fullscreen/maximize
---@type hs.window.filter
hs.window.filter.windowMoved = nil

--- Event for
--- hs.window.filter:subscribe()
--- : a window that used to be in the current Mission Control Space isn't anymore,
---@type hs.window.filter
hs.window.filter.windowNotInCurrentSpace = nil

--- Event for
--- hs.window.filter:subscribe()
--- : a window is no longer
--- actually
--- visible on any screen because it was minimized, closed,
---@type hs.window.filter
hs.window.filter.windowNotOnScreen = nil

--- Event for
--- hs.window.filter:subscribe()
--- : a window is no longer "visible" (in
--- any
--- Mission Control Space, as per
--- hs.window:isVisible()
--- )
---@type hs.window.filter|hs.window
hs.window.filter.windowNotVisible = nil

--- Event for
--- hs.window.filter:subscribe()
--- : a window became
--- actually
--- visible on screen (i.e. it's "visible" as per
--- hs.window:isVisible()
---@type hs.window.filter|hs.window
hs.window.filter.windowOnScreen = nil

--- Pseudo-event for
--- hs.window.filter:subscribe()
--- : a previously allowed window (or a window that's been destroyed) is now rejected
---@type hs.window.filter
hs.window.filter.windowRejected = nil

--- Pseudo-event for
--- hs.window.filter:subscribe()
--- : the list of allowed windows (as per
--- windowfilter:getWindows()
--- ) has changed
---@type hs.window.filter
hs.window.filter.windowsChanged = nil

--- Event for
--- hs.window.filter:subscribe()
--- : a window's title changed
---@type hs.window.filter
hs.window.filter.windowTitleChanged = nil

--- Event for
--- hs.window.filter:subscribe()
--- : a window lost focus
---@type hs.window.filter
hs.window.filter.windowUnfocused = nil

--- Event for
--- hs.window.filter:subscribe()
--- : a window was reverted back from fullscreen
---@type hs.window.filter
hs.window.filter.windowUnfullscreened = nil

--- Event for
--- hs.window.filter:subscribe()
--- : a window was unhidden (its app was unhidden, e.g. via
--- cmd-h
--- )
---@type hs.window.filter
hs.window.filter.windowUnhidden = nil

--- Event for
--- hs.window.filter:subscribe()
--- : a window was unminimized
---@type hs.window.filter
hs.window.filter.windowUnminimized = nil

--- Event for
--- hs.window.filter:subscribe()
--- : a window became "visible" (in
--- any
--- Mission Control Space, as per
--- hs.window:isVisible()
--- )
---@type hs.window.filter|hs.window
hs.window.filter.windowVisible = nil

--- A table for window roles (as per
--- hs.window:subrole()
--- ) that are allowed by default.
---@type table
hs.window.filter.allowedWindowRoles = nil

--- Tells all windowfilters whether to refresh all windows when the user switches to a different Mission Control Space.
---@type any
hs.window.filter.forceRefreshOnSpaceChange = nil

--- A table of application names (as per
--- hs.application:name()
--- ) that are always ignored by this module.
---@type table
hs.window.filter.ignoreAlways = nil

--- Convenience function to focus the nearest window to the east
---
--- Note: This is a convenience wrapper that performs hs.window.filter.defaultCurrentSpace:focusWindowEast(nil,nil,true)
---@return any
function hs.window.filter.focusEast() end

--- Convenience function to focus the nearest window to the north
---
--- Note: This is a convenience wrapper that performs hs.window.filter.defaultCurrentSpace:focusWindowNorth(nil,nil,true)
---@return any
function hs.window.filter.focusNorth() end

--- Convenience function to focus the nearest window to the south
---
--- Note: This is a convenience wrapper that performs hs.window.filter.defaultCurrentSpace:focusWindowSouth(nil,nil,true)
---@return any
function hs.window.filter.focusSouth() end

--- Convenience function to focus the nearest window to the west
---
--- Note: This is a convenience wrapper that performs hs.window.filter.defaultCurrentSpace:focusWindowWest(nil,nil,true)
---@return any
function hs.window.filter.focusWest() end

--- Checks whether an app is a known non-GUI app, as per
--- hs.window.filter.ignoreAlways
---@param appname hs.application
---@return boolean
function hs.window.filter.isGuiApp(appname) end

--- Callback to inform all windowfilters that the user initiated a switch to a (numbered) Mission Control Space.
---
--- Note: Only use this function if "Displays have separate Spaces" and "Automatically rearrange Spaces" are OFF in
--- System Preferences>Mission Control
--- Calling this function will set hs.window.filter.forceRefreshOnSpaceChange to false
--- If you defined one or more Spaces-aware windowfilters (i.e. when the currentSpace field of a filter is present),
--- windows need refreshing at every space change anyway, so using this callback will not result in improved performance
--- See hs.window.filter.forceRefreshOnSpaceChange for an overview of Spaces limitations in Hammerspoon. If you often
--- (or always) change Space via the "numbered" Mission Control keyboard shortcuts (by default, ctrl-1 etc.), you can
--- call this function from your init.lua when intercepting these shortcuts; for example:
--- hs.hotkey.bind('ctrl','1',nil,function()hs.window.filter.switchedToSpace(1)end)
--- hs.hotkey.bind('ctrl','2',nil,function()hs.window.filter.switchedToSpace(2)end)
--- -- etc.
--- Using this callback results in slightly better performance than setting forceRefreshOnSpaceChange to true , since
--- already visited Spaces are remembered and no refreshing is necessary when switching back to those.
---@param space number
---@return any
function hs.window.filter.switchedToSpace(space) end

--- Returns a copy of an hs.window.filter object that you can further restrict or expand
---@param windowfilter hs.window.filter
---@param logname? hs.logger|nil
---@param loglevel? hs.logger|nil
---@return hs.window.filter
function hs.window.filter.copy(windowfilter, logname, loglevel) end

--- Creates a new hs.window.filter instance
---@param fn function
---@param logname? hs.logger|nil
---@param loglevel? hs.logger|nil
---@return hs.window.filter
function hs.window.filter.new(fn, logname, loglevel) end

--- Sets the windowfilter to allow all visible windows belonging to a specific app
---
--- Note: this is just a convenience wrapper for windowfilter:setAppFilter(appname,{visible=true})
---@param appname hs.application
---@return hs.window.filter
function filter:allowApp(appname) end

--- Focuses the nearest window to the east of a given window
---
--- Note: This is a convenience wrapper that performs hs.window.focusWindowEast(window,self:getWindows(),...)
--- You'll likely want to add :setCurrentSpace(true) to the windowfilter used for this method call
---@param window hs.window|hs.window.frontmostWindow|nil
---@param frontmost boolean|nil
---@param strict boolean|nil
---@return any
function filter:focusWindowEast(window, frontmost, strict) end

--- Focuses the nearest window to the south of a given window
---
--- Note: This is a convenience wrapper that performs hs.window.focusWindowNorth(window,self:getWindows(),...)
--- You'll likely want to add :setCurrentSpace(true) to the windowfilter used for this method call
---@param window hs.window|hs.window.frontmostWindow|nil
---@param frontmost boolean|nil
---@param strict boolean|nil
---@return any
function filter:focusWindowNorth(window, frontmost, strict) end

--- Focuses the nearest window to the north of a given window
---
--- Note: This is a convenience wrapper that performs hs.window.focusWindowSouth(window,self:getWindows(),...)
--- You'll likely want to add :setCurrentSpace(true) to the windowfilter used for this method call
---@param window hs.window|hs.window.frontmostWindow|nil
---@param frontmost boolean|nil
---@param strict boolean|nil
---@return any
function filter:focusWindowSouth(window, frontmost, strict) end

--- Focuses the nearest window to the west of a given window
---
--- Note: This is a convenience wrapper that performs hs.window.focusWindowWest(window,self:getWindows(),...)
--- You'll likely want to add :setCurrentSpace(true) to the windowfilter used for this method call
---@param window hs.window|hs.window.frontmostWindow|nil
---@param frontmost boolean|nil
---@param strict boolean|nil
---@return any
function filter:focusWindowWest(window, frontmost, strict) end

--- Return a table with all the filtering rules defined for this windowfilter
---@return table
function filter:getFilters() end

--- Gets the current windows allowed by this windowfilter
---@param sortOrder hs.window.filter.sortBy|hs.window.filter|nil
---@return list of hs.window objects
function filter:getWindows(sortOrder) end

--- Checks if an app is allowed by the windowfilter
---@param appname hs.application
---@return boolean
function filter:isAppAllowed(appname) end

--- Checks if a window is allowed by the windowfilter
---@param window hs.window
---@return boolean
function filter:isWindowAllowed(window) end

--- Stops the windowfilter event subscriptions; no more event callbacks will be triggered, but the subscriptions remain
--- intact for a subsequent call to
--- hs.window.filter:resume()
---@return hs.window.filter
function filter:pause() end

--- Sets the windowfilter to outright reject any windows belonging to a specific app
---
--- Note: this is just a convenience wrapper for windowfilter:setAppFilter(appname,false)
---@param appname hs.application
---@return hs.window.filter
function filter:rejectApp(appname) end

--- Resumes the windowfilter event subscriptions
---@return hs.window.filter
function filter:resume() end

--- Sets the detailed filtering rules for the windows of a specific app
---
--- Note: Passing focused=true in filter will (naturally) result in the windowfilter ever allowing 1 window at most
--- If you want to allow all windows for an app, including invisible ones, pass an empty table for filter
--- Spaces-aware windowfilters might experience a (sometimes significant) delay after every Space switch, since (due to
--- OS X limitations) they must re-query for the list of all windows in the current Space every time.
--- If System Preferences>Mission Control>Displays have separate Spaces is on , the current Space is defined as the
--- union of all the Spaces that are currently visible
--- This table explains the effects of different combinations of visible and currentSpace , showing which windows will
--- be allowed:
--- |visible=         nil                      |             true             |     false    |
--- |currentSpace|------------------------------------------|------------------------------|--------------|
--- |     nil    |all                                       |visible in ANY space          |min and hidden|
--- |    true    |visible in CURRENT space+min and hidden   |visible in CURRENT space      |min and hidden|
--- |    false   |visible in OTHER space only+min and hidden|visible in OTHER space only   |none          |
---@param appname hs.application
---@param filter function
---@return hs.window.filter
function filter:setAppFilter(appname, filter) end

--- Sets whether the windowfilter should only allow (or reject) windows in the current Mission Control Space
---
--- Note: This is just a convenience wrapper for setting the currentSpace field in the override filter (other
--- fields will be left untouched); per-app filters will maintain their currentSpace field, if present, as is
--- Spaces-aware windowfilters might experience a (sometimes significant) delay after every Space switch, since
--- (due to OS X limitations) they must re-query for the list of all windows in the current Space every time.
---@param val boolean
---@return hs.window.filter
function filter:setCurrentSpace(val) end

--- Set the default filtering rules to be used for apps without app-specific rules
---@param filter hs.window.filter
---@return hs.window.filter
function filter:setDefaultFilter(filter) end

--- Sets multiple filtering rules
---
--- Note: every filter definition in filters will overwrite the preexisting one for the relevant application, if
--- present;
--- this also applies to the special default and override filters, if included
---@param filters table
---@return hs.window.filter
function filter:setFilters(filters) end

--- Set overriding filtering rules that will be applied for all apps before any app-specific rules
---@param filter hs.window.filter
---@return hs.window.filter
function filter:setOverrideFilter(filter) end

--- Sets the allowed screen regions for this windowfilter
---
--- Note: This is just a convenience wrapper for setting the allowRegions field in the override filter (other fields
--- will be left untouched); per-app filters will maintain their allowRegions and rejectRegions fields, if present
---@param regions hs.geometry
---@return hs.window.filter
function filter:setRegions(regions) end

--- Sets the allowed screens for this windowfilter
---
--- Note: This is just a convenience wrapper for setting the allowScreens field in the override filter (other
--- fields will be left untouched); per-app filters will maintain their allowScreens and rejectScreens fields, if
--- present
---@param screens any
---@return hs.window.filter
function filter:setScreens(screens) end

--- Sets the sort order for this windowfilter's
--- :getWindows()
--- method
---
--- Note: The default sort order for all windowfilters (that is, until changed by this method) is
--- hs.window.filter.sortByFocusedLast
---@param sortOrder hs.window.filter.sortBy
---@return hs.window.filter
function filter:setSortOrder(sortOrder) end

--- Subscribe to one or more events on the allowed windows
---
--- Note: Passing lists means that all the fn s will be called when any of the event s fires, so it's not a shortcut
--- for subscribing distinct callbacks to distinct events; use a map or chained :subscribe calls for that.
--- Use caution with immediate : if for example you're subscribing to hs.window.filter.windowUnfocused , fn (s) will be
--- called for all the windows except the currently focused one.
--- If the windowfilter was paused with hs.window.filter:pause() , calling this will resume it.
---@param event string
---@param fn function
---@param immediate? function|nil
---@return hs.window.filter
function filter:subscribe(event, fn, immediate) end

--- Removes one or more event subscriptions
---
--- Note: You must pass at least one of event or fn
--- If calling this on the default (or any other shared use) windowfilter, do not pass events, as that would remove all
--- the callbacks for the events including ones subscribed elsewhere that you might not be aware of. You should
--- instead keep references to your functions and pass in those.
---@param event string
---@param fn? function
---@return hs.window.filter
function filter:unsubscribe(event, fn) end

--- Removes all event subscriptions
---
--- Note: You should not use this on the default windowfilter or other shared-use windowfilters
---@return hs.window.filter
function filter:unsubscribeAll() end

--- Gets all visible windows allowed by this windowfilter that lie to the east a given window
---
--- Note: This is a convenience wrapper that returns hs.window.windowsToEast(window,self:getWindows(),...)
--- You'll likely want to add :setCurrentSpace(true) to the windowfilter used for this method call (or just use
--- hs.window.filter.defaultCurrentSpace )
---@param window hs.window|hs.window.frontmostWindow|nil
---@param frontmost boolean|nil
---@param strict boolean|nil
---@return hs.window
function filter:windowsToEast(window, frontmost, strict) end

--- Gets all visible windows allowed by this windowfilter that lie to the north a given window
---
--- Note: This is a convenience wrapper that returns hs.window.windowsToNorth(window,self:getWindows(),...)
--- You'll likely want to add :setCurrentSpace(true) to the windowfilter used for this method call (or just use
--- hs.window.filter.defaultCurrentSpace )
---@param window hs.window|hs.window.frontmostWindow|nil
---@param frontmost boolean|nil
---@param strict boolean|nil
---@return hs.window
function filter:windowsToNorth(window, frontmost, strict) end

--- Gets all visible windows allowed by this windowfilter that lie to the south a given window
---
--- Note: This is a convenience wrapper that returns hs.window.windowsToSouth(window,self:getWindows(),...)
--- You'll likely want to add :setCurrentSpace(true) to the windowfilter used for this method call (or just use
--- hs.window.filter.defaultCurrentSpace )
---@param window hs.window|hs.window.frontmostWindow|nil
---@param frontmost boolean|nil
---@param strict boolean|nil
---@return hs.window
function filter:windowsToSouth(window, frontmost, strict) end

--- Gets all visible windows allowed by this windowfilter that lie to the west a given window
---
--- Note: This is a convenience wrapper that returns hs.window.windowsToWest(window,self:getWindows(),...)
--- You'll likely want to add :setCurrentSpace(true) to the windowfilter used for this method call (or just use
--- hs.window.filter.defaultCurrentSpace )
---@param window hs.window|hs.window.frontmostWindow|nil
---@param frontmost boolean|nil
---@param strict boolean|nil
---@return hs.window
function filter:windowsToWest(window, frontmost, strict) end

-- ------------------------------------------------------------
-- hs.window.highlight
-- ------------------------------------------------------------

---@class hs.window.highlight
hs.window.highlight = {}

--- Allows customization of the highlight overlays and behaviour.
---@type any
hs.window.highlight.ui = nil

--- Starts the module
---
--- Note: overlay mode is disabled by default - see hs.window.highlight.ui.overlayColor
---@param windowfilterIsolate hs.window.filter|hs.window.highlight.toggleIsolate|nil
---@param windowfilterOverlay? hs.window.filter|nil
---@return any
function hs.window.highlight.start(windowfilterIsolate, windowfilterOverlay) end

--- Stops the module and disables focused window highlighting (both "overlay" and "isolate" mode)
---@return any
function hs.window.highlight.stop() end

--- Sets or clears the user override for "isolate" mode.
---
--- Note: This function should be bound to a hotkey, e.g.: hs.hotkey.bind('ctrl-cmd','\','Isolate',hs.window.highlight.toggleIsolate)
---@param v any
---@return any
function hs.window.highlight.toggleIsolate(v) end

-- ------------------------------------------------------------
-- hs.window.layout
-- ------------------------------------------------------------

---@class hs.window.layout
hs.window.layout = {}

---@class layout
local layout = {}

--- When "active mode" windowlayouts apply a rule, they will pause briefly for this amount of time in seconds, to allow
--- windows
---@type any
hs.window.layout.applyDelay = nil

--- The number of seconds to wait, after a screen configuration change has been detected, before
---@type number
hs.window.layout.screensChangedDelay = nil

--- Applies a layout
---
--- Note: this is a convenience wrapper for "passive mode" use that creates, applies, and deletes a windowlayout object;
--- do not use shared windowfilters in rules , as they'll be deleted; you can just use constructor argument maps instead
---@param rules hs.window.layout.new
---@return any
function hs.window.layout.applyLayout(rules) end

--- Pauses all active windowlayout instances
---@return any
function hs.window.layout.pauseAllInstances() end

--- Resumes all active windowlayout instances
---@return any
function hs.window.layout.resumeAllInstances() end

--- Creates a new hs.window.layout instance
---@param rules table
---@param logname? hs.logger|nil
---@param loglevel? hs.logger|nil
---@return hs.window.layout
function hs.window.layout.new(rules, logname, loglevel) end

--- Applies the layout
---
--- Note: if a screen configuration is defined for this windowfilter, and currently not satisfied, this method will do
--- nothing
---@return hs.window.layout
function layout:apply() end

--- Return a table with all the rules (and the screen configuration, if present) defined for this windowlayout
---@return table
function layout:getRules() end

--- Pauses an active windowlayout instance; while paused no automatic window management will occur
---@return hs.window.layout
function layout:pause() end

--- Resumes an active windowlayout instance after it was paused
---
--- Note: if a screen configuration is defined for this windowfilter, and currently not satisfied, this method will do
--- nothing
---@return hs.window.layout
function layout:resume() end

--- Determines the screen configuration that permits applying this windowlayout
---
--- Note: If screens is nil , any previous screen configuration is removed, and this windowlayout will be always allowed
--- For "active" windowlayouts, call this method before calling hs.window.layout:start()
--- By using hs.geometry size objects as hints you can define separate layouts for the same physical screen at
--- different resolutions
--- With this method you can define different windowlayouts for different screen configurations (as per System
--- Preferences->Displays->Arrangement).
--- "passive mode" use: you call :apply() on both on your chosen hotkey (via hs.hotkey:bind() ), but only the
--- appropriate layout for the current arrangement will be applied
--- "active mode" use: you just call :start() on both windowlayouts; as you switch between workplaces (by attaching or
--- detaching external screens) the correct layout "kicks in" automatically - this is in effect a convenience wrapper
--- that calls :pause() on the no longer relevant layout, and :resume() on the appropriate one, at every screen
--- configuration change
---@param screens any
---@return hs.window.layout
function layout:setScreenConfiguration(screens) end

--- Puts a windowlayout instance in "active mode"
---
--- Note: If a screen configuration is defined for this windowfilter, and currently not satisfied, this windowfilter
--- will be put in "active mode" but will remain paused until the screen configuration requirements are met
--- When in active mode, a windowlayout instance will constantly monitor the windowfilters for its rules, by
--- subscribing to all the relevant events. As soon as any change is detected (e.g. when you drag a window, switch
--- focus, open or close apps/windows, etc.) the relative rule will be automatically re-applied. In other words, the
--- rules you defined will remain enforced all the time, instead of waiting for manual intervention via
--- hs.window.layout:apply() .
---@return hs.window.layout
function layout:start() end

--- Stops a windowlayout instance (i.e. not in "active mode" anymore)
---@return hs.window.layout
function layout:stop() end

-- ------------------------------------------------------------
-- hs.window.switcher
-- ------------------------------------------------------------

---@class hs.window.switcher
hs.window.switcher = {}

---@class switcher
local switcher = {}

--- Allows customization of the switcher behaviour and user interface
---@type any
hs.window.switcher.ui = nil

--- Shows the switcher (if not yet visible) and selects the next window
---
--- Note: the switcher will be dismissed (and the selected window focused) when all modifier keys are released
---@return any
function hs.window.switcher.nextWindow() end

--- Shows the switcher (if not yet visible) and selects the previous window
---
--- Note: the switcher will be dismissed (and the selected window focused) when all modifier keys are released
---@return any
function hs.window.switcher.previousWindow() end

--- Creates a new switcher instance; it can use a windowfilter to determine which windows to show
---@param windowfilter any
---@param uiPrefs? hs.window.switcher.ui|nil
---@param logname? hs.logger|nil
---@param loglevel? hs.logger|nil
---@return hs.window.switcher
function hs.window.switcher.new(windowfilter, uiPrefs, logname, loglevel) end

--- Shows the switcher instance (if not yet visible) and selects the next window
---
--- Note: the switcher will be dismissed (and the selected window focused) when all modifier keys are released
---@return any
function switcher:next() end

--- Shows the switcher instance (if not yet visible) and selects the previous window
---
--- Note: the switcher will be dismissed (and the selected window focused) when all modifier keys are released
---@return any
function switcher:previous() end

-- ------------------------------------------------------------
-- hs.window.tiling
-- ------------------------------------------------------------

---@class hs.window.tiling
hs.window.tiling = {}

--- Tile (or fit) windows into a rect
---
--- Note: To ensure all windows are placed in a row (side by side), use a very small aspect ratio (for "tall and
--- narrow" windows) like 0.01;
--- similarly, to have all windows in a column, use a very large aspect ratio (for "short and wide") like 100
--- Hidden and minimized windows will be processed as well: the rect will have "gaps" where the invisible windows
--- would lie, that will get filled as the windows get unhidden/unminimized
---@param windows hs.window
---@param rect hs.geometry
---@param desiredAspect? hs.geometry|nil
---@param processInOrder? any
---@param preserveRelativeArea? any
---@param animationDuration? hs.window.animationDuration|nil
---@return any
function hs.window.tiling.tileWindows(windows, rect, desiredAspect, processInOrder, preserveRelativeArea, animationDuration) end
