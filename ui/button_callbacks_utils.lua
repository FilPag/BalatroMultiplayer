-- Utils-related button callbacks

function G.FUNCS.copy_to_clipboard(e)
  MP.UTILS.copy_to_clipboard(MP.LOBBY.code)
end

local exit_overlay_menu_ref = G.FUNCS.exit_overlay_menu
function G.FUNCS.exit_overlay_menu(self)
  -- Saves username if user presses ESC instead of Enter
  if G.OVERLAY_MENU and G.OVERLAY_MENU:get_UIE_by_ID("username_input_box") ~= nil then
    MP.UTILS.save_username(MP.LOBBY.username)
  end

  exit_overlay_menu_ref(self)
end

local mods_button_ref = G.FUNCS.mods_button
function G.FUNCS.mods_button(arg_736_0)
  if G.OVERLAY_MENU and G.OVERLAY_MENU:get_UIE_by_ID("username_input_box") ~= nil then
    MP.UTILS.save_username(MP.LOBBY.username)
  end

  mods_button_ref(arg_736_0)
end

function G.FUNCS.open_kofi(e)
  love.system.openURL("https://ko-fi.com/virtualized")
end

function G.FUNCS.reconnect(e)
  MP.ACTIONS.connect()
  G.FUNCS:exit_overlay_menu()
end

function G.FUNCS.skip_tutorial(e)
  G.SETTINGS.tutorial_complete = true
  G.SETTINGS.tutorial_progress = nil
  G.FUNCS.play_options(e)
end

G.FUNCS.wipe_off = function()
  G.E_MANAGER:add_event(Event({
    no_delete = true,
    func = function()
      delay(0.3)
      if not G.screenwipe then
        return true
      end
      G.screenwipe.children.particles.max = 0
      G.E_MANAGER:add_event(Event({
        trigger = "ease",
        no_delete = true,
        blockable = false,
        blocking = false,
        timer = "REAL",
        ref_table = G.screenwipe.colours.black,
        ref_value = 4,
        ease_to = 0,
        delay = 0.3,
        func = function(t)
          return t
        end,
      }))
      G.E_MANAGER:add_event(Event({
        trigger = "ease",
        no_delete = true,
        blockable = false,
        blocking = false,
        timer = "REAL",
        ref_table = G.screenwipe.colours.white,
        ref_value = 4,
        ease_to = 0,
        delay = 0.3,
        func = function(t)
          return t
        end,
      }))
      return true
    end,
  }))
  G.E_MANAGER:add_event(Event({
    trigger = "after",
    delay = 0.55,
    no_delete = true,
    blocking = false,
    timer = "REAL",
    func = function()
      if not G.screenwipe then
        return true
      end
      if G.screenwipecard then
        G.screenwipecard:start_dissolve({ G.C.BLACK, G.C.ORANGE, G.C.GOLD, G.C.RED })
      end
      if G.screenwipe:get_UIE_by_ID("text") then
        for k, v in ipairs(G.screenwipe:get_UIE_by_ID("text").children) do
          v.children[1].config.object:pop_out(4)
        end
      end
      return true
    end,
  }))
  G.E_MANAGER:add_event(Event({
    trigger = "after",
    delay = 1.1,
    no_delete = true,
    blocking = false,
    timer = "REAL",
    func = function()
      if not G.screenwipe then
        return true
      end
      G.screenwipe.children.particles:remove()
      G.screenwipe:remove()
      G.screenwipe.children.particles = nil
      G.screenwipe = nil
      G.screenwipecard = nil
      return true
    end,
  }))
  G.E_MANAGER:add_event(Event({
    trigger = "after",
    delay = 1.2,
    no_delete = true,
    blocking = true,
    timer = "REAL",
    func = function()
      return true
    end,
  }))
end
-- Utils-related button callbacks

-- Functions will be copied here in alphabetical order as per instructions.
