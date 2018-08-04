local player = {}

local hash = mymath.hash

function player.setup()
	player.id = "player"

	-- place the player, XXX find a cool place instead of just a random one
	player.x, player.y = mainmap:find_empty_floor()
	player.face_x, player.face_y = 1, 0
	player.flashlight_on = true

	player.memory_map = Map.new(mainmap.width, mainmap.height)
end

function player.try_step(dx, dy)
	if mainmap:is_floor(player.x + dx, player.y + dy) then
		player.x, player.y = player.x + dx, player.y + dy
		player.face_x, player.face_y = dx, dy
		player.memorize_feat(player.x, player.y)
		new_turn(true)
		return true
	else
		new_message("Ouch! (" .. player.x + dx .. ", " .. player.y + dy .. ")")
		player.memorize_feat(player.x + dx, player.y + dy)
		player.face_x, player.face_y = dx, dy
		new_turn(true)
		return false
	end
end

function player.turn(dx, dy)
	player.face_x, player.face_y = dx, dy
	new_turn(true)
end

function player.compute_los()
	player.vis_grid = {}
	los.compute(player.x, player.y,
		function(x, y, distance)
			if mainmap:in_bounds(x, y) then
				player.vis_grid[hash(x,y)] = distance

				if light.get(x,y) > 0 then
					player.memorize_feat(x,y)
				end
			end
		end,
		nil,
		48)
end

function player.visible(x, y)
	return player.vis_grid[hash(x, y)]
end

function player.memorize_feat(x, y)
	-- copy whatever is at x,y into the player's memory
	player.memory_map:set(x, y, "feat", mainmap:get(x, y, "feat"))
	-- remember the brightness of "permanent" lights only
	-- we can figure this out because of ninja magic
	player.memory_map:set(x, y, "brightness", light.get_permanent(x,y))
end

function player.switch_flashlight()
	player.flashlight_on = not player.flashlight_on
	new_turn(true)
end

return player
