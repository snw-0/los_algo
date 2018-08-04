local light = {permanent_grid = {}, temporary_grid = {}}

local hash = mymath.hash

function light.update()
	-- update the temp grid, but don't touch the permanent one
	light.temporary_grid = {}
	light.cast(player.x, player.y, 1, 3, 7, false,
		light.get_octants_from_dir(player.face_x, player.face_y))
end

function light.cast(x, y, r1, r2, r3, permanent, octants)
	los.compute(x, y,
		function(x, y, distance)
			if mainmap:in_bounds(x, y) then
				local brightness
				if distance <= r1 then
					brightness = 3
				elseif distance <= r2 then
					brightness = 2
				else -- we only calculate out to r3
					brightness = 1
				end
				if permanent then
					light.permanent_grid[hash(x,y)] = light.permanent_grid[hash(x,y)]
						and math.max(brightness, light.permanent_grid[hash(x,y)]) or brightness
				else
					light.temporary_grid[hash(x,y)] = light.temporary_grid[hash(x,y)]
						and math.max(brightness, light.temporary_grid[hash(x,y)]) or brightness
				end
			end
		end,
		nil, r3, octants)
end

function light.get(x, y)
	-- max of the two light grids
	return math.max(light.temporary_grid[hash(x,y)] or 0, light.permanent_grid[hash(x,y)] or 0)
end

function light.get_temporary(x, y)
	return light.temporary_grid[hash(x,y)] or 0
end

function light.get_permanent(x, y)
	return light.permanent_grid[hash(x,y)] or 0
end

function light.get_octants_from_dir(dx, dy)
	-- octants:
	--  32
	-- 4  1
	-- 5  8
	--  67

	if dy == 1 then
		if dx == 1 then
			return {7, 8}
		elseif dx == 0 then
			return {6, 7}
		elseif dx == -1 then
			return {5, 6}
		end
	elseif dy == 0 then
		if dx == 1 then
			return {1, 8}
		elseif dx == -1 then
			return {4, 5}
		end
	elseif dy == -1 then
		if dx == 1 then
			return {1, 2}
		elseif dx == 0 then
			return {2, 3}
		elseif dx == -1 then
			return {3, 4}
		end
	end
	error("bad coords ("..dx..","..dy..")")
end

return light
