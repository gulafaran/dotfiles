pcall(require, "luarocks.loader")
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
require("awful.hotkeys_popup.keys")
local vicious = require("vicious")

if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = tostring(err) })
        in_error = false
    end)
end

beautiful.init("/home/tom/.config/awesome/themes/default/theme.lua")

naughty.config.defaults['icon_size'] = 60
naughty.config.defaults['notification_max_height'] = 150
naughty.config.defaults['notification_max_width'] = 250

local opacity = 80

browser = "firefox"
terminal = "alacritty"
editor = os.getenv("EDITOR") or "vim"
editor_cmd = terminal .. " -e " .. editor
modkey = "Mod4"

awful.layout.layouts = {
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
}

iconspath = "/home/tom/icons/"

myawesomemenu = {
   { "hotkeys", function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", function() awesome.quit() end },
}


winemenu = {
  { "winecfg", "winecfg" , iconspath .. "winecfg.png" },
  { "winetricks", "winetricks" , iconspath .. "wine.png" },
}

steammenu = {
  { "steam-native", "steam-native", "/usr/share/icons/hicolor/256x256/apps/steam.png" },
  { "steam-runtime",  "steam-runtime", "/usr/share/icons/hicolor/256x256/apps/steam.png" },
}

sysmenu = {
  { "chromium", browser , "/usr/share/icons/hicolor/256x256/apps/chromium.png"},
  { "terminal", terminal, "/usr/share/icons/Adwaita/512x512/legacy/utilities-terminal.png" },
  { "sys monitor", "gnome-system-monitor", iconspath .. "utilities-system-monitor.png" },
}

menuitems = { { "awesomewm", myawesomemenu },
              { "steam", steammenu },
              { "wine", winemenu },
              { "sys tools", sysmenu },
}

mymainmenu = awful.menu({items = menuitems})

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

menubar.utils.terminal = terminal
mytextclock = wibox.widget.textclock()
mytextclock.opacity = 0.8

local tray_widget = wibox.widget {
  {
    {
      {
        widget = wibox.widget.systray,
        opacity = 0.8,
      },
      left = 6,
      top = 1,
      bottom = 1,
      right = 6,
      widget = wibox.container.margin,
      opacity = 0.8
    },
    widget = wibox.container.background,
    shape = gears.shape.rounded_bar,
    opacity = 0.8
  },
  top = 1,
  bottom = 1,
  widget = wibox.container.margin,
  opacity = 0.8
}

local taglist_buttons = gears.table.join(
                    awful.button({ }, 1, function(t) t:view_only() end),
                    awful.button({ modkey }, 1, function(t)
                                              if client.focus then
                                                  client.focus:move_to_tag(t)
                                              end
                                          end),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, function(t)
                                              if client.focus then
                                                  client.focus:toggle_tag(t)
                                              end
                                          end),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
                )

local tasklist_buttons = gears.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  c:emit_signal(
                                                      "request::activate",
                                                      "tasklist",
                                                      {raise = true}
                                                  )
                                              end
                                          end),
                     awful.button({ }, 3, function()
                                              awful.menu.client_list({ theme = { width = 250 } })
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                          end))

local function set_wallpaper(s)
    -- Wallpaper
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        -- If wallpaper is a function, call it with the screen
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s, true)
    end
end

screen.connect_signal("property::geometry", set_wallpaper)

cpuwidget = wibox.widget.textbox()
vicious.cache(vicious.widgets.cpu)
vicious.register(cpuwidget, vicious.widgets.cpu, '<span color="#1793D1">CPU</span>: $1% ', 3)

memwidget = wibox.widget.textbox()
vicious.cache(vicious.widgets.mem)
vicious.register(memwidget, vicious.widgets.mem, '<span color="#1793D1">RAM</span>: $2/$3 MiB ', 10)

swapwidget = wibox.widget.textbox()
vicious.register(swapwidget, vicious.widgets.mem, '<span color="#1793D1">SWAP</span>: $6/$7 MiB ', 30)

fswidget = wibox.widget.textbox()
vicious.cache(vicious.widgets.fs)
vicious.register(fswidget, vicious.widgets.fs, '<span color="#1793D1">ROOT</span>: ${/ used_gb}/${/ size_gb} GiB ' , 20)

fs2widget = wibox.widget.textbox()
vicious.register(fs2widget, vicious.widgets.fs, '<span color="#1793D1">AUR</span>: ${/home/tom/aur used_gb}/${/home/tom/aur size_gb} GiB ', 20)

fs3widget = wibox.widget.textbox()
vicious.register(fs3widget, vicious.widgets.fs, '<span color="#1793D1">DEV</span>: ${/home/tom/dev used_gb}/${/home/tom/dev size_gb} GiB ', 20)

netwidget = wibox.widget.textbox()
vicious.cache(vicious.widgets.net)
vicious.register(netwidget, vicious.widgets.net, '<span color="#1793D1">NET</span>: ${wireguard down_kb}↓/${wireguard up_kb}↑ KB/s ', 3)

oswidget = wibox.widget.textbox()
vicious.cache(vicious.widgets.os)
vicious.register(oswidget, vicious.widgets.os, '<span color="#1793D1"> OS</span>: $1 $2 ', 50)

batwidget = wibox.widget.textbox()
vicious.cache(vicious.widgets.bat)
vicious.register(batwidget, vicious.widgets.bat, '<span color="#1793D1"> BAT</span>: $2% $1 ', 15, "BAT1")

volwidget = wibox.widget.textbox()
vicious.cache(vicious.widgets.volume)
vicious.register(volwidget, vicious.widgets.volume, '<span color="#1793D1">VOL</span>: $1% ', 15, {"Master", "-D", "pulse"})

dgputext = wibox.widget.textbox()
dgputext.markup = '<span color="#1793D1">DGPU</span>: '

local open = io.open

local function update_cpu_widget(widget)
    local file = open("/sys/class/hwmon/hwmon5/temp1_input", "rb")
    local temp = "*"
    if file then
        local content = file:read "*line"
        file:close()
        temp = tonumber(content) / 1000
    end

    widget.markup = temp .. "C° "
end

local function register_cpu_widget(widget, seconds)
  local timer = gears.timer {
    timeout = seconds,
    autostart = true,
    call_now = false,
    callback = update_cpu_widget(widget),
    single_shot = false
  }

  timer:connect_signal("timeout",function() update_cpu_widget(widget) end)
end

cputempwidget = wibox.widget.textbox()
register_cpu_widget(cputempwidget, 5)

local function update_dgpu_widget(widget, widget2)
    local file = open("/proc/driver/nvidia/gpus/0000:01:00.0/power", "rb")
    local state = "Unknown"

    if file then
        file:read "*line"
        local content = file:read "*line"
        file:close()

        state = string.match(content, 'Off') or string.match(content, 'Active')

        if not state then
            state = "Unknown"
        end
    end

    widget.markup = state .. " "

    file = open("/sys/bus/pci/devices/0000:01:00.0/power/control", "rb")
    state = "Unknown"

    if file then
        state = file:read "*line"
        file:close()
        if not state then
            state = "Unknown"
        end
    end

    widget2.markup = state .. " "
end

local function register_dgpu_widget(widget, widget2, seconds)
  local timer = gears.timer {
    timeout = seconds,
    autostart = true,
    call_now = false,
    callback = update_dgpu_widget(widget, widget2),
    single_shot = false
  }

  timer:connect_signal("timeout", function() update_dgpu_widget(widget, widget2) end)
end

dgpuwidget = wibox.widget.textbox()
dgpuwidget2 = wibox.widget.textbox()
register_dgpu_widget(dgpuwidget, dgpuwidget2, 10)

tags = {
  names = {
    "sys",
    "irc",
    "web",
    "dev",
    "fps",
    "foo",
  },
  layouts = {
    awful.layout.layouts[2],
    awful.layout.layouts[2],
    awful.layout.layouts[2],
    awful.layout.layouts[2],
    awful.layout.layouts[1],
    awful.layout.layouts[1],
  }
}

awful.screen.connect_for_each_screen(function(s)
    set_wallpaper(s)

    awful.tag(tags.names, s, tags.layouts)

    s.mypromptbox = awful.widget.prompt()
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(gears.table.join(
                           awful.button({ }, 1, function () awful.layout.inc( 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(-1) end),
                           awful.button({ }, 4, function () awful.layout.inc( 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(-1) end)))

    s.mytaglist = awful.widget.taglist {
        screen  = s,
        filter  = awful.widget.taglist.filter.all,
        buttons = taglist_buttons
    }

    s.mytasklist = awful.widget.tasklist ({
        screen  = s,
        filter  = awful.widget.tasklist.filter.currenttags,
        buttons = tasklist_buttons
    })

    s.mywibox = awful.wibar({ position = "top", screen = s})
    s.botbar = awful.wibar({ position = "bottom", screen = s})

    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            mylauncher,
            s.mytaglist,
            s.mypromptbox,
        },
        s.mytasklist, -- Middle widget
        { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            tray_widget,
            mytextclock,
        },
    }

  s.botbar:setup {
    layout = wibox.layout.align.horizontal,
    {
      layout = wibox.layout.fixed.horizontal,
      oswidget,
      cpuwidget,
      cputempwidget,
      dgputext,
      dgpuwidget2,
      dgpuwidget,
      memwidget,
      swapwidget,
      fswidget,
      fs2widget,
      fs3widget,
      netwidget,
    },
    nil,
    {
      layout = wibox.layout.fixed.horizontal,
      batwidget,
      volwidget,
      s.mylayoutbox,
    },
  }
end)

root.buttons(gears.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end)
))

globalkeys = gears.table.join(
    awful.key({ modkey,           }, "Return", function () awful.spawn(terminal) end,
              {description = "open a terminal", group = "launcher"}),
    awful.key({ modkey, "Control" }, "r", awesome.restart,
              {description = "reload awesome", group = "awesome"}),
    awful.key({ modkey, "Control"   }, "q", awesome.quit,
              {description = "quit awesome", group = "awesome"}),
    awful.key({ modkey,           }, "space", function () awful.layout.inc( 1)                end,
              {description = "select next", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(-1)                end,
              {description = "select previous", group = "layout"}),

    awful.key({ modkey, "Control" }, "n",
              function ()
                  local c = awful.client.restore()
                  -- Focus restored client
                  if c then
                    c:emit_signal(
                        "request::activate", "key.unminimize", {raise = true}
                    )
                  end
              end,
              {description = "restore minimized", group = "client"}),

    awful.key({ modkey },            "r",     function () awful.screen.focused().mypromptbox:run() end,
              {description = "run prompt", group = "launcher"}),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run {
                    prompt       = "Run Lua code: ",
                    textbox      = awful.screen.focused().mypromptbox.widget,
                    exe_callback = awful.util.eval,
                    history_path = awful.util.get_cache_dir() .. "/history_eval"
                  }
              end,
              {description = "lua execute prompt", group = "awesome"}),
    awful.key({ modkey }, "p", function() menubar.show() end,
              {description = "show the menubar", group = "launcher"}),

    awful.key({ }, "XF86AudioLowerVolume", function () awful.spawn("ponymix decrease 5%") end,
              { description = "decrease master volume 5%", group = "launcher" }),
    awful.key({ }, "XF86AudioRaiseVolume", function () awful.spawn("ponymix increase 5%") end,
              { description = "increase master volume 5%", group = "launcher" }),
    awful.key({ }, "XF86AudioMute", function () awful.spawn("ponymix toggle") end,
              { description = "toggle master volume mute", group = "launcher" }),
    awful.key({ }, "XF86AudioMicMute", function () awful.spawn("ponymix --input toggle") end,
              { description = "toggle mic volume mute", group = "launcher" }),
    awful.key({ }, "Print", function() awful.spawn.with_shell("sleep 0.4 && scrot -e 'mv $f ~/screenshots/'") end,
              { description = "scrot", group = "launcher" }),
    awful.key({ }, "XF86Launch1", awesome.restart,
              {description = "reload awesome", group = "awesome"}),
    awful.key({ }, "XF86AudioNext", function () awful.spawn("spotifycli --next") end,
              { description = "spotify next song", group = "launcher"}),
    awful.key({ }, "XF86AudioPrev", function () awful.spawn("spotifycli --previous") end,
              { description = "spotify previous song", group = "launcher"}),
    awful.key({ }, "XF86AudioPlay", function () awful.spawn("spotifycli --play") end,
              { description = "spotify play", group = "launcher"}),
    awful.key({ }, "XF86AudioStop", function () awful.spawn("spotifycli --stop") end,
              { description = "spotify stop song", group = "launcher"}),
    awful.key({ }, "XF86TouchpadToggle", function () awful.spawn("toggletouchpad") end,
              { description = "toggle touchpad", group = "launcher"}),
    awful.key({ }, "XF86MonBrightnessDown", function () awful.spawn("xbacklight -dec 3") end,
              { description = "lower brightness", group = "launcher"}),
    awful.key({ }, "XF86MonBrightnessUp", function () awful.spawn("xbacklight -inc 3") end,
              { description = "raisebrightness", group = "launcher"})
)

clientkeys = gears.table.join(
    awful.key({ modkey,           }, "f",
        function (c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        {description = "toggle fullscreen", group = "client"}),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end,
              {description = "close", group = "client"}),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ,
              {description = "toggle floating", group = "client"}),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end,
              {description = "toggle keep on top", group = "client"}),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end ,
        {description = "minimize", group = "client"}),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized = not c.maximized
            c:raise()
        end ,
        {description = "(un)maximize", group = "client"}),
    awful.key({ modkey, "Control" }, "m",
        function (c)
            c.maximized_vertical = not c.maximized_vertical
            c:raise()
        end ,
        {description = "(un)maximize vertically", group = "client"}),
    awful.key({ modkey, "Shift"   }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c:raise()
        end ,
        {description = "(un)maximize horizontally", group = "client"})
)

for i = 1, 9 do
    globalkeys = gears.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = awful.screen.focused()
                        local tag = screen.tags[i]
                        if tag then
                           tag:view_only()
                        end
                  end,
                  {description = "view tag #"..i, group = "tag"}),
        -- Toggle tag display.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = awful.screen.focused()
                      local tag = screen.tags[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end,
                  {description = "toggle tag #" .. i, group = "tag"}),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:move_to_tag(tag)
                          end
                     end
                  end,
                  {description = "move focused client to tag #"..i, group = "tag"}),
        -- Toggle tag on focused client.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:toggle_tag(tag)
                          end
                      end
                  end,
                  {description = "toggle focused client on tag #" .. i, group = "tag"})
    )
end

clientbuttons = gears.table.join(
    awful.button({ }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
    end),
    awful.button({ modkey }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.move(c)
    end),
    awful.button({ modkey }, 3, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.resize(c)
    end)
)

root.keys(globalkeys)

awful.rules.rules = {
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     screen = awful.screen.preferred,
                     placement = awful.placement.no_overlap+awful.placement.no_offscreen
     }
    },

    { rule = { role = "_NET_WM_STATE_FULLSCREEN" },
      properties = { floating = true } },

    { rule_any = {
        instance = {
          "DTA",  -- Firefox addon DownThemAll.
          "copyq",  -- Includes session name in class.
          "pinentry",
        },
        class = {
          "Arandr",
          "Blueman-manager",
          "Gpick",
          "Kruler",
          "MessageWin",  -- kalarm.
          "Sxiv",
          "Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
          "Wpa_gui",
          "veromix",
          "xtightvncviewer"},

        name = {
          "Event Tester",  -- xev.
        },
        role = {
          "AlarmWindow",  -- Thunderbird's calendar.
          "ConfigManager",  -- Thunderbird's about:config.
          "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
        }
      }, properties = { floating = true }},
}

client.connect_signal("manage", function (c)
    if awesome.startup
      and not c.size_hints.user_position
      and not c.size_hints.program_position then
        awful.placement.no_offscreen(c)
    end
end)

client.connect_signal("mouse::enter", function(c)
    c:emit_signal("request::activate", "mouse_enter", {raise = false})
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
