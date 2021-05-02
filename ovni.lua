-- ovni.
--
-- @eigen


local gamepad = include('lib/gamepad')

local Cirle = include('lib/3d/circle')
local draw_mode = include('lib/3d/enums/draw_mode')
local vertex_motion = include('lib/3d/utils/vertex_motion')

local inspect = include('lib/inspect')
include('lib/3d/utils/core')
include('lib/easing/easing')
include('lib/easing/interpolation')


-- ------------------------------------------------------------------------
-- CONF

local fps = 20
local selected_draw_mode = draw_mode.WIREFRAME


-- ------------------------------------------------------------------------
-- STATE

c_num = 4

max_r = 1
cs = {}
for i=1,c_num do
  local r = 1 / (i + 1)
  table.insert(cs, Cirle.new(r, {0,1/(c_num/i)/2,0}, {0.,1.,0.}))
  table.insert(cs, Cirle.new(r, {0,-1/(c_num/i)/2,0}, {0.,1.,0.}))
end
table.insert(cs, Cirle.new(r, {0,0,0}, {0.,1.,0.}))
cs_len = len(cs)


-- c = Cirle.new(1)
-- c_center = Point.new()
-- c_tilt = Segment.new(model.tilt)

-- print(inspect(model.faces))

-- init
cam = {0,0,-10} -- Initilise the camera position
mult = 128 -- View multiplier
a = flr(rnd(3))+1 -- Angle for random rotation
t = flr(rnd(50))+25 -- Time until next angle change
rot_speed = 0
rot_speed_a = {0,0,0} -- Independant angle rotation

max_rot_speed = 2

independant_rot_a = False
prev_a = nil

random_angle = false

is_shift = false


-- ------------------------------------------------------------------------
-- LIFECYCLE

local redraw_clock

function init()
  screen.aa(1)

  gamepad.init(gamepad_dpad_cb, gamepad_btn_cb)

  redraw_clock = clock.run(
    function()
      local step_s = 1 / fps
      while true do
        clock.sleep(step_s)
        redraw()
      end
  end)
end

function cleanup()
  gamepad.cleanup()

  clock.cancel(redraw_clock)
end


-- ------------------------------------------------------------------------
-- MAIN LOOP

function gamepad_dpad_cb(id, val)
  if id == "ABS_X" then
    a = 2
  elseif id == "ABS_Y" then
    a = 1
  end

  local sign = 1
  if val < 128 then
    sign = -1
  end

  if not independant_rot_a then
    if prev_a == a then
      rot_speed = util.clamp(rot_speed + 0.01 * sign, -max_rot_speed, max_rot_speed)
    else
      rot_speed = 0.01 * sign
    end
    prev_a = a
  else
    rot_speed_a[a] = util.clamp(rot_speed_a[a] + 0.005 * sign, -max_rot_speed/3, max_rot_speed/3)
  end
end

function gamepad_btn_cb(id, val)
  if id == "R" then
    if val == 1 then
      cam[3] = cam[3] + 0.5
    end
  elseif id == "L" then
    if val == 1 then
      cam[3] = cam[3] - 0.5
    end
  end
end


local rot_during_shift = false
local rot_shift_kept_held = false
local last_rot_time = nil


function key(id,state)
  if id == 1 then
    if state == 0 then
      if rot_during_shift then
        print("release!")
        last_rot_time = os.clock()
        rot_shift_kept_held = false
        rot_during_shift = false
      end
      is_shift = false
    else
      is_shift = true
    end
  elseif id == 2 then
    if state == 0 then
      if is_shift then
        independant_rot_a = not independant_rot_a
        if not independant_rot_a then
          print("independant angle rotation off")
          rot_speed = rot_speed_a[1] + rot_speed_a[2] + rot_speed_a[3]
        else
          print("independant angle rotation on")
          rot_speed_a = {0,0,0}
          rot_speed_a[a] = rot_speed
        end
      else
        random_angle = not random_angle
        if not random_angle then
          print("random rotation off")
          rot_speed = 0
        else
          print("random rotation on")
          independant_rot_a = false
          rot_speed = 0.01
        end
      end
    end
  elseif id == 3 then
    if state == 0 then
      print("emergency stop!")
      random_angle = False
      rot_speed = 0
      rot_speed_a = {0,0,0}
    end
  end
end


function enc(id,delta)
  if id == 1 then
    if is_shift then
      a = 3
    else
      cam[3] = cam[3] + delta / 5
    end
  elseif id == 2 then
    if is_shift then
      a = 2
    else
      cam[1] = cam[1] - delta / 10
    end
  elseif id == 3 then
    if is_shift then
      a = 1
    else
      cam[2] = cam[2] - delta / 10
    end
  end

  if is_shift then
    local sign = 1
    if delta < 0 then
      sign = -1
    end
    if id == 2 then
      sign = -sign
    end

    rot_during_shift = true
    rot_shift_kept_held = true
    -- last_rot_time = os.clock()

    print("hello")

    if not independant_rot_a then
      if prev_a == a then
        rot_speed = util.clamp(rot_speed + 0.01 * sign, -0.05, 0.05)
      else
        rot_speed = 0.01 * sign
      end
      prev_a = a
    else
      rot_speed_a[a] = util.clamp(rot_speed_a[a] + 0.005 * sign, -0.03, 0.03)
    end
  end
end

function fix_tilt ()
  for i=1, cs_len do
    -- print('-----------------')
    -- print(inspect(cs[i].rotation))
    local inv = vertex_motion.inverted(cs[i].rotation)
    local percent = 60 -- the higher, the quicklier it stabilizes
    local scaled = vertex_motion.interpolated(inv, cs[i].rotation, (100-percent)/2)
    -- print(inspect(scaled))
    cs[i]:rotate(scaled)
    cs[i]:rotate(inv)
  end
end

function move_shape()
  if random_angle then
    t = t - 1 -- Decrease time until next angle change
    if t <= 0 then -- If t is 0 then change the random angle and restart the timer
      t = flr(rnd(50))+25 -- Restart timer
      a = flr(rnd(3))+1 -- Update angle
    end
  end

  -- local nClock = os.clock()
  if not independant_rot_a then
    for i=1, cs_len do
      cs[i]:rotate(a, rot_speed)
    end
  else
    for i=1, cs_len do
      cs[i]:rotate(1, rot_speed_a[1])
      cs[i]:rotate(2, rot_speed_a[2])
      cs[i]:rotate(3, rot_speed_a[3])
    end
  end
  -- print("rotation took "..os.clock()-nClock)

end

function redraw()

  local t_since_last_rot = last_rot_time and os.clock() - last_rot_time or 9999

  if rot_shift_kept_held or t_since_last_rot < 0.2 then
      move_shape()
  else
    fix_tilt()
  end

  screen.clear()

  for i=1, cs_len do
    cs[i]:draw(15, selected_draw_mode, mult, cam)
  end

  screen.update()
end
