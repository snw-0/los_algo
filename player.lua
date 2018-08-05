local player = {id = 0, name = "player",
				x = 1, y = 1,
				face_x = 1, face_y = 0,
				flashlight_on = true}

local hash = mymath.hash

function player.set_location(x, y)
	if player.x then
		mainmap:set(player.x, player.y, "actor", nil)
	end
	if mainmap:get(x,y,"feat") == "doorc" then
		-- open the door
		mainmap:set(x,y,"feat","dooro")
		new_message("You open the door.", "green")
		light.needs_rebuild = true
	end
	player.x, player.y = x, y
	mainmap:set(player.x, player.y, "actor", player.id)
end

function player.try_step(dx, dy)
	if mainmap:can_walk(player.x + dx, player.y + dy) then
		player.set_location(player.x + dx, player.y + dy)
		player.face_x, player.face_y = dx, dy
		player.memorize_feat(player.x, player.y)
		new_turn(true)
		return true
	else
		new_message("Ouch! (" .. player.x + dx .. ", " .. player.y + dy .. ")", "grey")
		player.memorize_feat(player.x + dx, player.y + dy)
		player.face_x, player.face_y = dx, dy
		new_turn(true)
		return false
	end
end

function player.set_facing(dx, dy)
	player.face_x, player.face_y = dx, dy
	new_turn(true)
end

function player.interact(dx, dy)
	if mainmap:in_bounds(player.x + dx, player.y + dy) then
		local feat = mainmap:get(player.x + dx, player.y + dy, "feat")
		if feat == "dooro" then
			new_message("You close the door.", "green")
			player.face_x, player.face_y = dx, dy
			mainmap:set(player.x + dx, player.y + dy, "feat", "doorc")
			player.memorize_feat(player.x + dx, player.y + dy)
			new_turn(true)
		elseif feat == "doorc" then
			new_message("You open the door.", "green")
			player.face_x, player.face_y = dx, dy
			mainmap:set(player.x + dx, player.y + dy, "feat", "dooro")
			player.memorize_feat(player.x + dx, player.y + dy)
			new_turn(true)
		else
			new_message("That's a " .. feat ..", kid.", "grey")
			player.memorize_feat(player.x + dx, player.y + dy)
			new_turn(true)
		end
	else
		new_message("Nope.", "grey")
		new_turn(false)
	end
	player.control_state = nil
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

function player.reset_memory()
	player.memory_map = Map.new(mainmap.width, mainmap.height)
end

function player.switch_flashlight()
	player.flashlight_on = not player.flashlight_on
	new_message("You switch your flashlight " .. (player.flashlight_on and "on." or "off."), "green")
	new_turn(true)
end

return player
