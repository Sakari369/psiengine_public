psi.keyb = {}

local _speeds = { 0.0025, 0.005, 0.01, 0.02, 0.03, 0.05, 0.07, 0.10, 0.11, 0.12, 0.20, 0.30, 0.40, 0.50, 1.00, 2.00, 4.00, 8.00 }
local _active_speed = 1

local _speed = _speeds[_active_speed]

function psi.keyb.key_events()
	if (psi.input:key_pressed(psi.KEYS.KEY_ESCAPE) == 1) then
		psi.video:set_window_should_close(true)

	elseif (psi.input:key_pressed(psi.KEYS.KEY_TAB) == 1) then
		psi.renderer:cycle_draw_mode();

	elseif (psi.input:key_pressed(psi.KEYS.KEY_COMMA) == 1) then
		_active_speed = _active_speed - 1
		if _active_speed < 1 then
			_active_speed = 1
		end

		_speed = _speeds[_active_speed]
		psi.input:set_movement_speed(_speed)
	elseif (psi.input:key_pressed(psi.KEYS.KEY_PERIOD) == 1) then
		_active_speed = _active_speed + 1
		if _active_speed > #_speeds then
			_active_speed = #_speeds
		end

		_speed = _speeds[_active_speed]
		psi.input:set_movement_speed(_speed)
	end

end
