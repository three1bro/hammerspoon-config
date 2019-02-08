-- Variable setting
hs.hotkey.alertDuration = 0
hs.hints.showTitleThresh = 0
hs.window.animationDuration = 0

-- load Spoons
hs.loadSpoon("ModalMgr")
hs.loadSpoon("CountDown")
hs.loadSpoon("SpeedMenu")
hs.loadSpoon("WinWin")
hs.loadSpoon("KSheet")

-- init speaker
speaker = hs.speech.new()

-- define hyper key as main key
local hyper = {"alt"}


-- Build better app switcher.
switcher = hs.window.switcher.new(
    hs.window.filter.new()
        :setAppFilter('Emacs', {allowRoles = '*', allowTitles = 1}), -- make emacs window show in switcher list
    {
        showTitles = false,               -- don't show window title
        thumbnailSize = 200,              -- window thumbnail size
        showSelectedThumbnail = false,    -- don't show bigger thumbnail
        backgroundColor = {0, 0, 0, 0.8}, -- background color
        highlightColor = {0.3, 0.3, 0.3, 0.8}, -- selected color
    }
)

spoon.ModalMgr.supervisor:bind(
   hyper, "]", 'next window', function()
      switcher:next()
end)
spoon.ModalMgr.supervisor:bind(
   hyper, "[", 'previous window', function()
      switcher:previous()
end)
spoon.ModalMgr.supervisor:bind(
   hyper, "/", 'Show Window Hints', function()
      spoon.ModalMgr:deactivateAll()
      hs.hints.windowHints()
end)
-- set imputmethod
local function Chinese()
  hs.keycodes.currentSourceID("com.sogou.inputmethod.sogou.pinyin")
end

local function English()
  hs.keycodes.currentSourceID("com.apple.keylayout.ABC")
end

local function set_app_input_method(app_name, set_input_method_function, event)
  event = event or hs.window.filter.windowFocused

  hs.window.filter.new(app_name)
    :subscribe(event, function()
                 set_input_method_function()
              end)
end

set_app_input_method('Hammerspoon', English, hs.window.filter.windowCreated)
set_app_input_method('LaunchBar', English, hs.window.filter.windowCreated)
set_app_input_method('Emacs', English)
set_app_input_method('iTerm2', English)
set_app_input_method('Google Chrome', English)
set_app_input_method('IntelliJ IDEA', English)

set_app_input_method('WeChat', Chinese)
set_app_input_method('QQ', Chinese)

-- Open Hammerspoon manual in default browser
spoon.ModalMgr.supervisor:bind(
   hyper, "H", "Read Hammerspoon Manual", function()
      hs.doc.hsdocs.forceExternalBrowser(true)
      hs.doc.hsdocs.moduleEntitiesInSidebar(true)
      hs.doc.hsdocs.help()
end)

-- Countdown tools
spoon.ModalMgr:new("countdownT")
local cmodal = spoon.ModalMgr.modal_list["countdownT"]
cmodal:bind('', 'escape', 'Deactivate countdownT', function() spoon.ModalMgr:deactivate({"countdownT"}) end)
cmodal:bind('', 'tab', 'Toggle Cheatsheet', function() spoon.ModalMgr:toggleCheatsheet() end)
cmodal:bind(
   '', '0', '5 Minutes Countdown', function()
      spoon.CountDown:startFor(5)
      spoon.ModalMgr:deactivate({"countdownT"})
end)
for i = 1, 9 do
   cmodal:bind(
      '', tostring(i), string.format("%s Minutes Countdown", 10 * i), function()
         spoon.CountDown:startFor(10 * i)
         spoon.ModalMgr:deactivate({"countdownT"})
   end)
end
cmodal:bind(
   '', 'return', '25 Minutes Countdown', function()
      spoon.CountDown:startFor(25)
      spoon.ModalMgr:deactivate({"countdownT"})
end)
cmodal:bind(
   '', 'space', 'Pause/Resume CountDown', function()
      spoon.CountDown:pauseOrResume()
      spoon.ModalMgr:deactivate({"countdownT"})
end)
spoon.ModalMgr.supervisor:bind(
   hyper, "C", "Enter countdownT Environment", function()
      spoon.ModalMgr:deactivateAll()
      spoon.ModalMgr:activate({"countdownT"}, "#FF6347", true)
end)

-- caffeine

-- Power operation.
caffeinateOnIcon = [[ASCII:
.....1a..........AC..........E
..............................
......4.......................
1..........aA..........CE.....
e.2......4.3...........h......
..............................
..............................
.......................h......
e.2......6.3..........t..q....
5..........c..........s.......
......6..................q....
......................s..t....
.....5c.......................
]]

    caffeinateOffIcon = [[ASCII:
.....1a.....x....AC.y.......zE
..............................
......4.......................
1..........aA..........CE.....
e.2......4.3...........h......
..............................
..............................
.......................h......
e.2......6.3..........t..q....
5..........c..........s.......
......6..................q....
......................s..t....
...x.5c....y.......z..........
]]

local caffeinateTrayIcon = hs.menubar.new()

local function caffeinateSetIcon(state)
    caffeinateTrayIcon:setIcon(state and caffeinateOnIcon or caffeinateOffIcon)

    if state then
        caffeinateTrayIcon:setTooltip("Sleep never sleep")
    else
        caffeinateTrayIcon:setTooltip("System will sleep when idle")
    end
end

local function toggleCaffeinate()
    local sleepStatus = hs.caffeinate.toggle("displayIdle")
    if sleepStatus then
        hs.notify.new({title="HammerSpoon", informativeText="System never sleep"}):send()
    else
        hs.notify.new({title="HammerSpoon", informativeText="System will sleep when idle"}):send()
    end

    caffeinateSetIcon(sleepStatus)
end

spoon.ModalMgr.supervisor:bind(
   hyper, "P", 'Toogle caffeine', function()
      toggleCaffeinate()
end)

caffeinateTrayIcon:setClickCallback(toggleCaffeinate)
caffeinateSetIcon(sleepStatus)

-- Windows manager
spoon.ModalMgr:new("windowsM")
local cmodal = spoon.ModalMgr.modal_list["windowsM"]
cmodal:bind('', 'escape', 'Deactivate windowsM', function() spoon.ModalMgr:deactivate({"windowsM"}) end)
cmodal:bind('', 'tab', 'Toggle Cheatsheet', function() spoon.ModalMgr:toggleCheatsheet() end)
cmodal:bind('', 'H', 'Move Leftward', function() spoon.WinWin:stepMove("left") end, nil, function() spoon.WinWin:stepMove("left") end)
cmodal:bind('', 'L', 'Move Rightward', function() spoon.WinWin:stepMove("right") end, nil, function() spoon.WinWin:stepMove("right") end)
cmodal:bind('', 'K', 'Move Upward', function() spoon.WinWin:stepMove("up") end, nil, function() spoon.WinWin:stepMove("up") end)
cmodal:bind('', 'J', 'Move Downward', function() spoon.WinWin:stepMove("down") end, nil, function() spoon.WinWin:stepMove("down") end)

cmodal:bind('', 'A', 'Lefthalf of Screen', function() spoon.WinWin:stash() spoon.WinWin:moveAndResize("halfleft") end)
cmodal:bind('', 'D', 'Righthalf of Screen', function() spoon.WinWin:stash() spoon.WinWin:moveAndResize("halfright") end)
cmodal:bind('', 'W', 'Uphalf of Screen', function() spoon.WinWin:stash() spoon.WinWin:moveAndResize("halfup") end)
cmodal:bind('', 'S', 'Downhalf of Screen', function() spoon.WinWin:stash() spoon.WinWin:moveAndResize("halfdown") end)
cmodal:bind('', 'Q', 'NorthWest Corner', function() spoon.WinWin:stash() spoon.WinWin:moveAndResize("cornerNW") end)
cmodal:bind('', 'E', 'NorthEast Corner', function() spoon.WinWin:stash() spoon.WinWin:moveAndResize("cornerNE") end)
cmodal:bind('', 'Z', 'SouthWest Corner', function() spoon.WinWin:stash() spoon.WinWin:moveAndResize("cornerSW") end)
cmodal:bind('', 'X', 'SouthEast Corner', function() spoon.WinWin:stash() spoon.WinWin:moveAndResize("cornerSE") end)
cmodal:bind('', 'F', 'Fullscreen', function() spoon.WinWin:stash() spoon.WinWin:moveAndResize("fullscreen") end)
cmodal:bind('', 'C', 'Center Window', function() spoon.WinWin:stash() spoon.WinWin:moveAndResize("center") end)
cmodal:bind('', '=', 'Stretch Outward', function() spoon.WinWin:moveAndResize("expand") end, nil, function() spoon.WinWin:moveAndResize("expand") end)
cmodal:bind('', '-', 'Shrink Inward', function() spoon.WinWin:moveAndResize("shrink") end, nil, function() spoon.WinWin:moveAndResize("shrink") end)

cmodal:bind('shift', 'H', 'Move Leftward', function() spoon.WinWin:stepResize("left") end, nil, function() spoon.WinWin:stepResize("left") end)
cmodal:bind('shift', 'L', 'Move Rightward', function() spoon.WinWin:stepResize("right") end, nil, function() spoon.WinWin:stepResize("right") end)
cmodal:bind('shift', 'K', 'Move Upward', function() spoon.WinWin:stepResize("up") end, nil, function() spoon.WinWin:stepResize("up") end)
cmodal:bind('shift', 'J', 'Move Downward', function() spoon.WinWin:stepResize("down") end, nil, function() spoon.WinWin:stepResize("down") end)
cmodal:bind('', 'left', 'Move to Left Monitor', function() spoon.WinWin:stash() spoon.WinWin:moveToScreen("left") end)
cmodal:bind('', 'right', 'Move to Right Monitor', function() spoon.WinWin:stash() spoon.WinWin:moveToScreen("right") end)
cmodal:bind('', 'up', 'Move to Above Monitor', function() spoon.WinWin:stash() spoon.WinWin:moveToScreen("up") end)
cmodal:bind('', 'down', 'Move to Below Monitor', function() spoon.WinWin:stash() spoon.WinWin:moveToScreen("down") end)
cmodal:bind('', 'space', 'Move to Next Monitor', function() spoon.WinWin:stash() spoon.WinWin:moveToScreen("next") end)
cmodal:bind('', '[', 'Undo Window Manipulation', function() spoon.WinWin:undo() end)
cmodal:bind('', ']', 'Redo Window Manipulation', function() spoon.WinWin:redo() end)
cmodal:bind('', '`', 'Center Cursor', function() spoon.WinWin:centerCursor() end)

spoon.ModalMgr.supervisor:bind(
   hyper, "W", "Enter windowsM Environment", function()
      spoon.ModalMgr:deactivateAll()
      spoon.ModalMgr:activate({"windowsM"}, "#B22222")
end)

-- Show cheetsheet from menu
spoon.ModalMgr:new("cheatsheetM")
local cmodal = spoon.ModalMgr.modal_list["cheatsheetM"]
cmodal:bind(
   '', 'escape', 'Deactivate cheatsheetM', function()
      spoon.KSheet:hide()
      spoon.ModalMgr:deactivate({"cheatsheetM"})
end)

spoon.ModalMgr.supervisor:bind(
   hyper, "K", "Show cheetsheet", function()
      spoon.KSheet:show()
      spoon.ModalMgr:deactivateAll()
      spoon.ModalMgr:activate({"cheatsheetM"})
end)

-- Show current time
spoon.ModalMgr.supervisor:bind(
   hyper, "T", "Show current time", function()
      local time = hs.timer.localTime()
      local x = math.floor(time/3600)
      local y = math.floor((time - x * 3600)/60)
      hs.notify.new({title="HManager", informativeText=tostring(x)..":"..tostring(y)}):send()
end)

-- Toogle Hammerspoon console
spoon.ModalMgr.supervisor:bind(
   hyper, ",", "Toogle Hammerspoon Console", function()
      hs.toggleConsole()
end)

-- Reload config
spoon.ModalMgr.supervisor:bind(
   hyper, "'", "Reload Configuration", function()
      --speaker:speak("try to reload configuration!") -- this will throw a crash
      hs.reload()
end)

-- Finally we initialize ModalMgr supervisor
spoon.ModalMgr.supervisor:enter()

-- We put reload notify at end of config, notify popup mean no error in config.
hs.notify.new({title="HManager", informativeText="Sean, I am here!"}):send()

-- Speak something after configuration success.
speaker:speak("Sean, I am here!")
