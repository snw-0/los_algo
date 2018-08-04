mymath = require "mymath"

color = require "color"
img = require "img"
Map = require "Map"
light = require "light"
los = require "los"
player = require "player"

function floor_setup()
	local mainmap = Map.new(48,24)
	mainmap:setup_mainmap()
	return mainmap
end

function new_turn(time_passed)
	if time_passed then
		cturn = cturn + 1
	end
	light.update()
	player.compute_los()
	redraw = true
end

function draw_pause_menu()
	love.graphics.setColor(color.blue)
	love.graphics.circle("fill", window_w/2, window_h/2, 200)
	love.graphics.setColor(color.white)
	love.graphics.printf("Press Q to quit", math.floor(window_w/2 - 200), math.floor(window_h/2 - font:getHeight()/2), 400, "center")
	love.graphics.setColor(color.white)
end

function new_message(m)
	message = m
	redraw = true
end

function love.load()
	ctime = 0
	window_w, window_h = 1024, 640

	love.window.setMode(window_w, window_h)
	love.graphics.setBackgroundColor(0, 0, 0)
	canvas = love.graphics.newCanvas()
	shaderDesaturate = love.graphics.newShader("desaturate.lua")

	love.mouse.setVisible(false)
	love.mouse.setGrabbed(true)

	font = love.graphics.newImageFont("font2.png",
		" abcdefghijklmnopqrstuvwxyz" ..
		"ABCDEFGHIJKLMNOPQRSTUVWXYZ0" ..
		"123456789.,!?-+/():;%&`'*#=[]\"")
	love.graphics.setFont(font)

	img.setup()
	cursor_x = -99
	cursor_y = -99

	cturn = 1
	mainmap = floor_setup(48, 24)
	player.setup()
	new_turn(false)

	game_state = "play"
end

-- function love.update(dt)
	-- ctime = ctime + dt -- only for animations, if i do those
-- end

function love.draw()
	-- figure out mouse
	mouse_x, mouse_y = love.mouse.getPosition()
	-- convert to map grid
	update_cursor(mouse_x, mouse_y)

	if redraw then
		if game_state == "pause" then
			love.graphics.setShader(shaderDesaturate)
		end

		love.graphics.setCanvas(canvas)
		love.graphics.clear()

		-- update and draw the new view to canvas
		img.update_tileset_batch()
		love.graphics.draw(img.tileset_batch,
						   (window_w / 2) - (mainmap.width * img.tile_size / 2),
						   (window_h / 2) - (mainmap.height * img.tile_size / 2))

		-- gui stuff

		love.graphics.setColor(color.purple)

		love.graphics.print("Turn:  "..cturn, window_w - 320, 80)
		-- debug msg
	    -- love.graphics.print("FPS: "..love.timer.getFPS(), 20, window.h - 80)
	    -- message
	    if message then
	    	love.graphics.print(message, 20, window_h - 40)
	    end
	    love.graphics.setColor(color.white)

		if game_state == "pause" then
			love.graphics.setShader()
			draw_pause_menu()
		end

		love.graphics.setCanvas()
		redraw = false
	end

	-- copy canvas to screen
	love.graphics.draw(canvas, 0, 0)

	love.graphics.setColor(color.purple)
	love.graphics.draw(img.tileset, img.tile["cursor"],
						(cursor_x - 1) * img.tile_size + (window_w / 2) - (mainmap.width * img.tile_size / 2),
						(cursor_y - 1) * img.tile_size + (window_h / 2) - (mainmap.height * img.tile_size / 2))

	love.graphics.setColor(color.white)
	love.graphics.circle("fill", mouse_x, mouse_y, 2)
end

function love.keypressed(key, unicode)
	if game_state == "pause" then
		if key == "escape" then
			unpause()
		end
		if key == "q" then love.event.push("quit") end
	elseif game_state == "play" then
		if key == "escape" then pause() end
		if key == "kp1" or key == "z" then player.try_step(-1,1) end
		if key == "kp2" or key == "x" then player.try_step(0,1) end
		if key == "kp3" or key == "c" then player.try_step(1,1) end
		if key == "kp4" or key == "a" then player.try_step(-1,0) end
		-- if key == "kp5" then player:key_skip_turn() end
		if key == "kp6" or key == "d" then player.try_step(1,0) end
		if key == "kp7" or key == "q" then player.try_step(-1,-1) end
		if key == "kp8" or key == "w" then player.try_step(0,-1) end
		if key == "kp9" or key == "e" then player.try_step(1,-1) end
		if key == "t" then
			local end_time = love.timer.getTime() + 1
			local n = 0
			while love.timer.getTime() < end_time do
				player.compute_los()
				n = n+1
			end
			new_message("Computed " .. n .. " cycles")
		end
		if key == "r" then
			floor_setup()
		end
	end
end

function love.mousepressed(x, y, button)
	update_cursor(x, y)
	if button == 1 then
		if cursor_x ~= player.x or cursor_y ~= player.y then
			if mainmap:get(cursor_x, cursor_y, "feat") == "wall" then
				mainmap:set(cursor_x, cursor_y, "feat", "floor")
				new_turn(false)
			elseif mainmap:get(cursor_x, cursor_y, "feat") == "floor" then
				mainmap:set(cursor_x, cursor_y, "feat", "wall")
				new_turn(false)
			end
		end
	elseif mainmap:get(cursor_x, cursor_y, "feat") == "floor" then
		light.cast(cursor_x, cursor_y, 1, 3, 7, true)
		new_turn(false)
	end
end

function update_cursor(mouse_x, mouse_y)
	local new_cursor_x = 1 + math.floor((mouse_x - (window_w / 2) + (mainmap.width * img.tile_size / 2)) / img.tile_size)
	local new_cursor_y = 1 + math.floor((mouse_y - (window_h / 2) + (mainmap.height * img.tile_size / 2)) / img.tile_size)
	if mainmap:in_bounds(new_cursor_x, new_cursor_y) then
		if new_cursor_x ~= cursor_x or new_cursor_y ~= cursor_y then
			-- set cursor
			cursor_x = new_cursor_x
			cursor_y = new_cursor_y
		end
	elseif cursor_x ~= -99 or cursor_y ~= -99 then
		cursor_x = -99
		cursor_y = -99
	end
end

function love.focus(f)
	if f then
		love.mouse.setVisible(false)
		love.mouse.setGrabbed(true)
	else
		pause()
		love.mouse.setVisible(true)
		love.mouse.setGrabbed(false)
	end
end

function pause()
	game_state = "pause"
	redraw = true
end

function unpause()
	game_state = "play"
	redraw = true
end
