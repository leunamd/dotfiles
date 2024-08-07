-- IMPORTS

import XMonad
import Data.Monoid
import System.Exit
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.SetWMName
import XMonad.Util.SpawnOnce
import XMonad.Util.Run
import XMonad.Hooks.DynamicLog
import qualified XMonad.StackSet as W
import qualified Data.Map        as M
import Data.Maybe (fromJust)
import XMonad.Actions.SpawnOn
import XMonad.Layout.PerWorkspace
import XMonad.Layout.NoBorders
import XMonad.Hooks.EwmhDesktops
import XMonad.Hooks.OnPropertyChange
import XMonad.Operations
import XMonad.Hooks.ManageHelpers





-- The preferred terminal program, which is used in a binding below and by
-- certain contrib modules.
--
myTerminal      = "alacritty"

-- Whether focus follows the mouse pointer.
myFocusFollowsMouse :: Bool
myFocusFollowsMouse = True

-- Whether clicking on a window to focus also passes the click to the window
myClickJustFocuses :: Bool
myClickJustFocuses = False

-- Width of the window border in pixels.
--
myBorderWidth   = 1

-- modMask lets you specify which modkey you want to use. The default
-- is mod1Mask ("left alt").  You may also consider using mod3Mask
-- ("right alt"), which does not conflict with emacs keybindings. The
-- "windows key" is usually mod4Mask.
--
myModMask       = mod4Mask

-- The default number of workspaces (virtual screens) and their names.
-- By default we use numeric strings, but any string may be used as a
-- workspace name. The number of workspaces is determined by the length
-- of this list.
--
-- A tagging example:
--
-- > workspaces = ["web", "irc", "code" ] ++ map show [4..9]
--
myWorkspaces    = ["1","2","3","4","5","6","7","8","9"]
myWorkspaceIndices = M.fromList $ zip myWorkspaces [1 ..]
clickable ws = "<action=xdotool key super+" ++ show i ++ ">" ++ ws ++ "</action>"
  where
    i = fromJust $ M.lookup ws myWorkspaceIndices

-- Border colors for unfocused and focused windows, respectively.
--
myNormalBorderColor  = "#dddddd"
myFocusedBorderColor = "#ff0000"

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--colors
data ColorSchemes = ColorSchemes{black ,white ,gray ,yellow ,orange ,red ,purple ,blue ,cyan ,green :: String}

myGruvbox :: ColorSchemes
myGruvbox = ColorSchemes {
                          black   = "#282828",
                          white   = "#ebdbb2",
                          gray    = "#928374",
                          yellow  = "#fabd2f",
                          orange  = "#fe8019",
                          red     = "#fb4934",
                          purple  = "#d3869b",
                          blue    = "#83a598",
                          cyan    = "#8ec07c",
                          green   = "#b8bb26"
                         }
-- custom user variables
myColor                = myGruvbox                                                                :: ColorSchemes

------------------------------------------------------------------------
-- Key bindings. Add, modify or remove key bindings here.
--
myKeys conf@(XConfig {XMonad.modMask = modm}) = M.fromList $

    -- launch a terminal
    [ ((modm .|. shiftMask, xK_Return), spawn $ XMonad.terminal conf)

    -- launch dmenu
    , ((modm,               xK_p     ), spawn "dmenu_run")
    
    -- disabled
    -- launch gmrun
    --, ((modm .|. shiftMask, xK_p     ), spawn "gmrun")

    -- close focused window
    , ((modm .|. shiftMask, xK_c     ), kill)

     -- Rotate through the available layout algorithms
    , ((modm,               xK_space ), sendMessage NextLayout)

    --  Reset the layouts on the current workspace to default
    , ((modm .|. shiftMask, xK_space ), setLayout $ XMonad.layoutHook conf)

    -- Resize viewed windows to the correct size
    , ((modm,               xK_n     ), refresh)

    -- Move focus to the next window
    , ((modm,               xK_Tab   ), windows W.focusDown)
    , ((mod1Mask,               xK_Tab   ), windows W.focusDown)

    -- Move focus to the next window
    , ((modm,               xK_j     ), windows W.focusDown)

    -- Move focus to the previous window
    , ((modm,               xK_k     ), windows W.focusUp  )

    -- Move focus to the master window
    , ((modm,               xK_m     ), windows W.focusMaster  )

    -- Swap the focused window and the master window
    , ((modm,               xK_Return), windows W.swapMaster)

    -- Swap the focused window with the next window
    , ((modm .|. shiftMask, xK_j     ), windows W.swapDown  )

    -- Swap the focused window with the previous window
    , ((modm .|. shiftMask, xK_k     ), windows W.swapUp    )

    -- Shrink the master area
    , ((modm,               xK_h     ), sendMessage Shrink)

    -- Expand the master area
    , ((modm,               xK_l     ), sendMessage Expand)

    -- Push window back into tiling
    , ((modm,               xK_t     ), withFocused $ windows . W.sink)

    -- Increment the number of windows in the master area
    , ((modm              , xK_comma ), sendMessage (IncMasterN 1))

    -- Deincrement the number of windows in the master area
    , ((modm              , xK_period), sendMessage (IncMasterN (-1)))

    -- Toggle the status bar gap
    -- Use this binding with avoidStruts from Hooks.ManageDocks.
    -- See also the statusBar function from Hooks.DynamicLog.
    --
    -- , ((modm              , xK_b     ), sendMessage ToggleStruts)

    -- Quit xmonad
    , ((modm .|. shiftMask, xK_q     ), io (exitWith ExitSuccess))

    -- Restart xmonad
    , ((modm              , xK_q     ), spawn "xmonad --recompile; xmonad --restart")

    -- Run xmessage with a summary of the default keybindings (useful for beginners)
    , ((modm .|. shiftMask, xK_slash ), spawn ("echo \"" ++ help ++ "\" | xmessage -file -"))
    -- 
    -- additionalKeys
    --
    --lock screen
    , ((modm .|. shiftMask, xK_l), spawn "loginctl lock-session")
    --start browser
    , ((modm            , xK_c), spawn "google-chrome-stable")
    --start file manager
    , ((modm            , xK_z), spawn "nautilus")
    --start calculator
    , ((modm            , xK_m), spawn "calc")
    --take a screenshot of selected region
    , ((modm , xK_Print ), unGrab *> spawn "scrot -a $(slop -f '%x,%y,%w,%h') ~/Pictures/Screenshots/%Y-%m-%d_%H-%M-%S.png -e 'xclip -selection clipboard -t image/png -i $f'")
    --take a screenshot of focused window
    , ((modm .|. shiftMask, xK_Print ), spawn "scrot ~/Pictures/Screenshots/window_%Y-%m-%d_%H-%M-%S.png -u -e 'xclip -selection clipboard -t image/png -i $f'")
     --take a screenshot of left monitor
    , ((modm .|. controlMask, xK_Print ), spawn "scrot ~/Pictures/Screenshots/monitor0_%Y-%m-%d_%H-%M-%S.png -a 0,0,1920,1080 -e 'xclip -selection clipboard -t image/png -i $f'")
    --take a screenshot of right monitor
    , ((modm .|. mod1Mask, xK_Print ), spawn "scrot ~/Pictures/Screenshots/monitor1_%Y-%m-%d_%H-%M-%S.png -a 1920,0,1920,1080 -e 'xclip -selection clipboard -t image/png -i $f'")
    ]
    ++
        -- mod-[1..9], Switch to workspace N
    -- mod-shift-[1..9], Move client to workspace N
    --
    [((m .|. modm, k), windows $ f i)
        | (i, k) <- zip (XMonad.workspaces conf) [xK_1 .. xK_9]
        , (f, m) <- [(W.greedyView, 0), (W.shift, shiftMask)]]
    ++

    --
    -- mod-{w,e,r}, Switch to physical/Xinerama screens 1, 2, or 3
    -- mod-shift-{w,e,r}, Move client to screen 1, 2, or 3
    --
    [((m .|. modm, key), screenWorkspace sc >>= flip whenJust (windows . f))
        | (key, sc) <- zip [xK_w, xK_e, xK_r] [0..]
        , (f, m) <- [(W.view, 0), (W.shift, shiftMask)]]


------------------------------------------------------------------------
-- Mouse bindings: default actions bound to mouse events
--
myMouseBindings (XConfig {XMonad.modMask = modm}) = M.fromList $

    -- mod-button1, Set the window to floating mode and move by dragging
    [ ((modm, button1), (\w -> focus w >> mouseMoveWindow w
                                       >> windows W.shiftMaster))

    -- mod-button2, Raise the window to the top of the stack
    , ((modm, button2), (\w -> focus w >> windows W.shiftMaster))

    -- mod-button3, Set the window to floating mode and resize by dragging
    , ((modm, button3), (\w -> focus w >> mouseResizeWindow w
                                       >> windows W.shiftMaster))

    -- you may also bind events to the mouse scroll wheel (button4 and button5)
    ]

------------------------------------------------------------------------
-- Layouts:

-- You can specify and transform your layouts by modifying these values.
-- If you change layout bindings be sure to use 'mod-shift-space' after
-- restarting (with 'mod-q') to reset your layout state to the new
-- defaults, as xmonad preserves your old layout settings by default.
--
-- The available layouts.  Note that each layout is separated by |||,
-- which denotes layout choice.
--
myLayout = lessBorders Screen $ onWorkspaces ["3","4","5","6","7"] fullLayout $ standardLayout
  where
     standardLayout = avoidStruts ( tiled |||
      --Mirror tiled |||
      noBorders Full)
       where
         -- default tiling algorithm partitions the screen into two panes
         tiled   = Tall nmaster delta ratio

         -- The default number of windows in the master pane
         nmaster = 1

         -- Default proportion of screen occupied by master pane
         ratio   = 1/2

         -- Percent of screen to increment by when resizing panes
         delta   = 3/100
      
     --
     --custom layouts
     fullLayout = avoidStruts $ noBorders Full
 
  
------------------------------------------------------------------------
-- Window rules:

-- Execute arbitrary actions and WindowSet manipulations when managing
-- a new window. You can use this to, for example, always float a
-- particular program, or have a client always appear on a particular
-- workspace.
--
-- To find the property name associated with a program, use
-- > xprop | grep WM_CLASS
-- and click on the client you're interested in.
--
-- To match on the WM_NAME, you can use 'title' in the same way that
-- 'className' and 'resource' are used below.
--
myManageHook = composeAll
    [ className =? "confirm"          --> doFloat
    , className =? "file_progress"    --> doFloat
    , className =? "dialog"           --> doFloat
    , className =? "download"         --> doFloat
    , className =? "error"            --> doFloat
    , className =? "notification"     --> doFloat
    , className =? "pinentry-gtk-2"   --> doFloat
    , className =? "splash"           --> doFloat
    , className =? "toolbar"          --> doFloat
    , className =? "Qalculate-gtk"    --> doFloat
    , className =? "mpv"              --> doShift (myWorkspaces !! 5)
    , className =? "Gimp"             --> doFloat
    , resource  =? "desktop_window"   --> doIgnore
    , resource  =? "kdesktop"         --> doIgnore
    , className =? "discord"          --> doShift (myWorkspaces !! 2)
    , className =? "WebCord"          --> doShift (myWorkspaces !! 2)
    , className =? "vesktop"          --> doShift (myWorkspaces !! 2)
    , className =? "TelegramDesktop"  --> doShift (myWorkspaces !! 2)
    , className =? "Virt-manager"     --> doShift (myWorkspaces !! 6)
    , className =? "looking-glass-client" --> doShift (myWorkspaces !! 6)
    , className =? "steam"            --> doShift (myWorkspaces !! 4)
    , className ^? "steam_app_"       --> doShift (myWorkspaces !! 4)
    , className =? "upc.exe"       --> doShift (myWorkspaces !! 4)
    , className ^? "xdefiant.exe"       --> doShift (myWorkspaces !! 4)
    , className =? "Spotify"          --> doShift (myWorkspaces !! 3)
    , className =? "obsidian"         --> doShift (myWorkspaces !! 7)
    , className ^? "league"           --> doShift (myWorkspaces !! 4)
    , className ^? "riot"             --> doShift (myWorkspaces !! 4)
    , className =? "Lutris"           --> doShift (myWorkspaces !! 4)
    , className =? "polaris-win64-shipping.exe" --> doShift (myWorkspaces !! 4)
    , className =? "code-oss"         --> doShift (myWorkspaces !! 6)
    , className =? "Code"             --> doShift (myWorkspaces !! 6)
    , className =? "leagueclientux.exe" --> doFloatAt 0 24
    , className =? "league of legends.exe" --> doShift (myWorkspaces !! 4)
    , (className =? "Google-chrome" <&&> resource =? "Dialog") --> doFloat
    , (stringProperty "WM_WINDOW_ROLE" =? "pop-up") --> doFloat
    , isFullscreen --> doFullFloat
    , isDialog --> doFloat
    ]

------------------------------------------------------------------------
-- Event handling

-- * EwmhDesktops users should change this to ewmhDesktopsEventHook
--
-- Defines a custom handler function for X Events. The function should
-- return (All True) if the default handler is to be run afterwards. To
-- combine event hooks use mappend or mconcat from Data.Monoid.
--
myEventHook = mempty

windowCount :: X (Maybe String)
windowCount = gets $ Just . show . length . W.integrate' . W.stack . W.workspace . W.current . windowset 
------------------------------------------------------------------------
-- Status bars and logging

-- Perform an arbitrary action on each internal state change or X event.
-- See the 'XMonad.Hooks.DynamicLog' extension for examples.
--
--myLogHook = return ()
myXmobarPP h =
  xmobarPP
    { ppCurrent         = xmobarColor (green myColor) "" . wrap "[" "]",
      ppVisible         = xmobarColor (white myColor) "" . wrap "" "" . clickable,
      ppHidden          = xmobarColor (yellow myColor) "" . wrap "" "" . clickable,
      ppHiddenNoWindows = xmobarColor (white myColor) "" . clickable,
      ppSep             = " | ",
      ppTitle           = xmobarColor (white myColor) "" . shorten 100,
      ppLayout          = xmobarColor  (white myColor) "",
      ppOutput          = hPutStrLn h,
      ppExtras          = [windowCount],
      ppOrder           = \(ws : l : t : ex) -> [ws, l, t] ++ ex
    }
------------------------------------------------------------------------
-- Startup hook

-- Perform an arbitrary action each time xmonad starts or is restarted
-- with mod-q.  Used by, e.g., XMonad.Layout.PerWorkspace to initialize
-- per-workspace layout choices.
--
-- By default, do nothing.
myStartupHook = do
  spawnOnce "xrandr --output DP-0 --primary --mode 1920x1080 --rate 144 --right-of HDMI-0 --output HDMI-0 --mode 1920x1080 --rate 60 --output DVI-I-1-0 --off --output HDMI-A-1-0 --off"
  --background applications
  spawnOnce "/usr/lib/geoclue-2.0/demos/agent"
  spawnOnce "lxsession"
  spawnOnce "numlockx"
  spawnOnce "~/.config/xmonad/scripts/volumeicon.sh"
  spawnOnce "nm-applet"
  spawnOnce "dunst"
  spawnOnce "blueman-applet"
  spawnOnce "redshift-gtk"
  spawnOnce "nitrogen --restore"
  spawnOnce "picom --fade-in-step=1 --fade-out-step=1 --fade-delta=0 --unredir-if-possible"
  spawnOnce "xbindkeys"
  spawnOnce "sxhkd"
  spawnOnce "xset +dpms dpms 0 0 300"
  spawnOnce "xss-lock --transfer-sleep-lock -- lock"
  spawnOnce "solaar --window=hide"
  spawnOnce "joystickwake"
  spawnOnce "xmousepasteblock"
  spawnOnce "hp-systray"
  spawn "~/.config/xmonad/scripts/systray.sh"
  --foreground applications
  spawnOnce "discord"
  spawnOnce "telegram-desktop"
  spawnOnce "spotify"
  spawnOnce "obsidian"
  setWMName "LG3D"

------------------------------------------------------------------------
-- Now run xmonad with all the defaults we set up.

-- Run xmonad with the settings you specify. No need to modify this.
--
main = do 
  myXmobar <- spawnPipe "xmobar -x 0 ~/.config/xmonad/xmobarrc"
  xmonad $ docks $ ewmhFullscreen $ def
     {
        terminal           = myTerminal,
        focusFollowsMouse  = myFocusFollowsMouse,
        clickJustFocuses   = myClickJustFocuses,
        borderWidth        = myBorderWidth,
        modMask            = myModMask,
        workspaces         = myWorkspaces,
        normalBorderColor  = myNormalBorderColor,
        focusedBorderColor = myFocusedBorderColor,

      -- key bindings
        keys               = myKeys,
        mouseBindings      = myMouseBindings,

      -- hooks, layouts
        layoutHook         = myLayout,
        manageHook         = myManageHook,
        handleEventHook    = myEventHook <+> onXPropertyChange "WM_NAME" (title=? "Steam"   --> doShift (myWorkspaces !! 4)),--steam update popup gets launched with empty wm class
        startupHook        = myStartupHook,
        logHook            = dynamicLogWithPP $ myXmobarPP myXmobar
    }

-- | Finally, a copy of the default bindings in simple textual tabular format.
help :: String
help = unlines ["The default modifier key is 'alt'. Default keybindings:",
    "",
    "-- launching and killing programs",
    "mod-Shift-Enter  Launch xterminal",
    "mod-p            Launch dmenu",
    "mod-Shift-p      Launch gmrun",
    "mod-Shift-c      Close/kill the focused window",
    "mod-Space        Rotate through the available layout algorithms",
    "mod-Shift-Space  Reset the layouts on the current workSpace to default",
    "mod-n            Resize/refresh viewed windows to the correct size",
    "",
    "-- move focus up or down the window stack",
    "mod-Tab        Move focus to the next window",
    "mod-Shift-Tab  Move focus to the previous window",
    "mod-j          Move focus to the next window",
    "mod-k          Move focus to the previous window",
    "mod-m          Move focus to the master window",
    "",
    "-- modifying the window order",
    "mod-Return   Swap the focused window and the master window",
    "mod-Shift-j  Swap the focused window with the next window",
    "mod-Shift-k  Swap the focused window with the previous window",
    "",
    "-- resizing the master/slave ratio",
    "mod-h  Shrink the master area",
    "mod-l  Expand the master area",
    "",
    "-- floating layer support",
    "mod-t  Push window back into tiling; unfloat and re-tile it",
    "",
    "-- increase or decrease number of windows in the master area",
    "mod-comma  (mod-,)   Increment the number of windows in the master area",
    "mod-period (mod-.)   Deincrement the number of windows in the master area",
    "",
    "-- quit, or restart",
    "mod-Shift-q  Quit xmonad",
    "mod-q        Restart xmonad",
    "mod-[1..9]   Switch to workSpace N",
    "",
    "-- Workspaces & screens",
    "mod-Shift-[1..9]   Move client to workspace N",
    "mod-{w,e,r}        Switch to physical/Xinerama screens 1, 2, or 3",
    "mod-Shift-{w,e,r}  Move client to screen 1, 2, or 3",
    "",
    "-- Mouse bindings: default actions bound to mouse events",
    "mod-button1  Set the window to floating mode and move by dragging",
    "mod-button2  Raise the window to the top of the stack",
    "mod-button3  Set the window to floating mode and resize by dragging"]
