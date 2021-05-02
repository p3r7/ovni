
include('lib/core')
local event_codes = require "hid_events"


-- ------------------------------------------------------------------------

local gamepad = {}


-- ------------------------------------------------------------------------
-- CONF

local gamepads_hid_names = {
  "USB,2-axis 8-button gamepad  "
}
local gamepad_aliases = {
  "iBUFFALO Classic USB Gamepad"
}
local gamepad_button_codes = {
  {
    A = 288,
    B = 289,
    X = 290,
    Y = 291,
    L = 292,
    R = 293,
    SELECT = 294,
    START = 295,
  }
}
-- Origin axis value is not necessarilly 128 and can oscillate due to analog sensors
-- We can precise a margin per model to handle this imprecision
local gamepad_abs_o_margin = {
  2
}


-- ------------------------------------------------------------------------
-- STATE

local current_hid

local hid_name = "USB,2-axis 8-button gamepad  " -- TODO: get programmatically
local gamepad_id

local dpad_cb
local btn_cb


-- ------------------------------------------------------------------------
-- LIFECYCLE

function gamepad.init(dpad_cb_fn, btn_cb_fn)

  if dpad_cb_fn then
    dpad_cb = dpad_cb_fn
  end
  if btn_cb_fn then
    btn_cb = btn_cb_fn
  end

  -- gamepad.print_known_event_codes
  -- gamepad.print_hid_info(hid)

  -- connect to default device
  current_hid = hid.connect()
  gamepad_id = find_in_table(current_hid.name, gamepads_hid_names)
  if gamepad_id then
    print("Current HID is a known gamepad: "..gamepad_aliases[gamepad_id])
    current_hid.event = gamepad.hid_cb
  end

  -- device select param
  local hids = {}
  for id,device in pairs(hid.vports) do
    hids[id] = string.sub(device.name, -24, string.len(device.name))
  end
  params:add{type = "option", id = "current_hid", name = "HID:", options = hids , default = 1,
             action = function(value)
               current_hid.event = nil
               current_hid = hid.connect(value)
               gamepad_id = find_in_table(current_hid.name, gamepads_hid_names)
               if gamepad_id then
                 print("Got: "..gamepad_aliases[gamepad_id])
                 current_hid.event = gamepad.hid_cb
               end
               devicepos = value
               print ("HID selected " .. hid.vports[devicepos].name)
  end}
end


function gamepad.cleanup()
  current_hid.event = nil
end

-- ------------------------------------------------------------------------
-- HID: GAMEPAD EVENT CALLBACK

function gamepad.hid_cb(typ, code, val)
  for key, value in pairs(event_codes.types) do
    if tonumber(value) == typ then
      event_code_t = key
    end
  end

  local do_log_event = gamepad.is_loggable_event(event_code_t, val)

  if do_log_event then
    print(" ")
    print("event_code_type: "..event_code_t)
    print("hid.event ", typ, code, val)
  end

  -- NB: gamepad EV_KEY events are not recognized in `event_codes.codes` but axis ones are
  local event_key
  if event_code_t == "EV_ABS" then
    event_key = gamepad.key_code_2_event_key(event_code_t, code)
    if event_key then
      if do_log_event then
        print("hid.event", "type: ".. typ, "code: " .. code, "value: "..val, "keycode: "..event_key)
      end
      if dpad_cb and not gamepad.is_abs_o_pos(val) then
        dpad_cb(event_key, val)
      end
    end
  end

  local button_name
  if event_code_t == "EV_KEY" then
    button_name = gamepad.key_code_2_button_name(code)
    if button_name then
      if do_log_event then
        print(button_name)
      end
      if btn_cb then
        btn_cb(button_name, val)
      end
    end

  end

  -- redraw()
end

-- Returns true if value for axis is around origin
-- i.e. when joystick / d-pad is not actioned
function gamepad.is_abs_o_pos(value)
  local margin = gamepad_abs_o_margin[gamepad_id]
  return ( value >= (128 - margin) and value <= (128 + margin) )
end

--- Predicate that returns true only on non-reset values (i.e. on key/joystick presses)
function gamepad.is_loggable_event(event_code_t, val)
  return (event_code_t == "EV_KEY" and val == 1)
    or (event_code_t == "EV_ABS" and not gamepad.is_abs_o_pos(val))
end

function gamepad.key_code_2_button_name(code)
  return find_in_table(code, gamepad_button_codes[gamepad_id])
end

function gamepad.key_code_2_button_name(code)
  return find_in_table(code, gamepad_button_codes[gamepad_id])
end

function gamepad.key_code_2_event_key(event_code_t, code)
  for key, value in pairs(event_codes.codes) do
    if tonumber(value) == code then
      if util.string_starts(key, gamepad.event_code_type_2_key_prfx(event_code_t)) then
        return key
      end
    end
  end
end


-- ------------------------------------------------------------------------
-- HID: UTILS

function gamepad.event_code_type_2_key_prfx(evt_code_t)
  return string.sub(evt_code_t, -3)
end


-- ------------------------------------------------------------------------
-- HID: DEBUG

function gamepad.print_hid_info(hid)
  print(" ")
  print("Devices:")
  --tab.print(hid.devices)
  for v in pairs(hid.devices) do
    print (v .. ": " .. hid.devices[v].name)
  end
  print(" ")

  print("vports:")
  --tab.print(hid.vports)
  for w in pairs(hid.vports) do
    print (w .. ": " .. hid.vports[w].name)
  end

  print(" ")
end

--- NB: gamepad button event codes are generally not recognized
--- that's why we have our local conf
function gamepad.print_known_event_codes()
  tab.print(event_codes.codes)
end


-- ------------------------------------------------------------------------

return gamepad
