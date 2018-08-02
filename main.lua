color = require "color"
img = require "img"
map = require "map"
los = require "los"
mymath = require "mymath"

function floor_setup()
	map:setup(48, 24)

	-- place the player, XXX find a cool place instead of just a random one
	player.x, player.y = map:find_empty_floor()
	new_turn(false)
end

function new_turn(time_passed)
	if time_passed then
		cturn = cturn + 1
	end
	los.compute(player.x, player.y)
	redraw = true
end

function draw_pause_menu()
	love.graphics.setColor(color.blue)
	love.graphics.circle("fill", window.w/2, window.h/2, 200)
	love.graphics.setColor(color.white)
	love.graphics.printf("Press Q to quit", math.floor(window.w/2 - 200), math.floor(window.h/2 - font:getHeight()/2), 400, "center")
	love.graphics.setColor(color.white)
end

function new_message(m)
	message = m
	redraw = true
end

function love.load()
	ctime = 0
	window = {}
	window.w, window.h = 1024, 640

	love.window.setMode(window.w, window.h)
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

	player = {id = player, x=1, y=1}

	cturn = 1
	floor_setup()

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
						   (window.w / 2) - (map.width * img.tile_size / 2),
						   (window.h / 2) - (map.height * img.tile_size / 2))

		-- gui stuff

		love.graphics.setColor(color.purple)
		love.graphics.print("Turn:  "..cturn, window.w - 320, 80)
		-- debug msg
	    -- love.graphics.print("FPS: "..love.timer.getFPS(), 20, window.h - 80)
	    -- message
	    if message then
	    	love.graphics.print(message, 20, window.h - 40)
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

	love.graphics.circle("line", mouse_x, mouse_y, 5)
end

function love.keypressed(key, unicode)
	if game_state == "pause" then
		if key == "escape" then
			unpause()
		end
		if key == "q" then love.event.push("quit") end
	elseif game_state == "play" then
		if key == "escape" then pause() end
		if key == "kp1" then try_player_step(-1,1) end
		if key == "kp2" or key == "s" then try_player_step(0,1) end
		if key == "kp3" then try_player_step(1,1) end
		if key == "kp4" or key == "a" then try_player_step(-1,0) end
		-- if key == "kp5" then player:key_skip_turn() end
		if key == "kp6" or key == "d" then try_player_step(1,0) end
		if key == "kp7" then try_player_step(-1,-1) end
		if key == "kp8" or key == "w" then try_player_step(0,-1) end
		if key == "kp9" then try_player_step(1,-1) end
		if key == "t" then
			local end_time = love.timer.getTime() + 1
			local n = 0
			while love.timer.getTime() < end_time do
				los.compute(player.x, player.y)
				n = n+1
			end
			new_message("Computed " .. n .. " cycles")
		end
		if key == "r" then
			floor_setup()
		end
	end
end

function love.mousepressed(x, y)
	update_cursor(x, y)
	if cursor_x ~= player.x or cursor_y ~= player.y then
		if map:feat_at(cursor_x, cursor_y) == "wall" then
			map[cursor_x][cursor_y].feat = "floor"
			los.compute(player.x, player.y)
			redraw = true
		elseif map:feat_at(cursor_x, cursor_y) == "floor" then
			map[cursor_x][cursor_y].feat = "wall"
			los.compute(player.x, player.y)
			redraw = true
		end
	end
end

function update_cursor(mouse_x, mouse_y)
	local new_cursor_x = 1 + math.floor((mouse_x - (window.w / 2) + (map.width * img.tile_size / 2)) / img.tile_size)
	local new_cursor_y = 1 + math.floor((mouse_y - (window.h / 2) + (map.height * img.tile_size / 2)) / img.tile_size)
	if map:in_bounds(new_cursor_x, new_cursor_y) then
		if new_cursor_x ~= cursor_x or new_cursor_y ~= cursor_y then
			-- set cursor
			cursor_x = new_cursor_x
			cursor_y = new_cursor_y
			redraw = true
		end
	elseif cursor_x ~= -99 or cursor_y ~= -99 then
		cursor_x = -99
		cursor_y = -99
		redraw = true
	end
end

function try_player_step(dx, dy)
	if map:is_floor(player.x + dx, player.y + dy) then
		player.x, player.y = player.x + dx, player.y + dy
		new_turn(true)
	else
		new_message("Ouch! (" .. player.x + dx .. ", " .. player.y + dy .. ")")
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
