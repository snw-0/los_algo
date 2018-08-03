local map = {}

function map:setup(w, h)
	self.width = w
	self.height = h

	for x=1, self.width do
		self[x] = {}
		for y=1, self.height do
			self[x][y] = {}
			if x==1 or x==self.width or y==1 or y==self.height or mymath.one_chance_in(8) then
				self[x][y].feat = "wall"
			else
				self[x][y].feat = "floor"
			end
		end
	end

	light.map = {}
end

function map:feat_at(x, y)
	if not self:in_bounds(x, y) then
		return "void" -- the void
	else
		return self[x][y].feat
	end
end

function map:tile_at(x, y)
	if not self:in_bounds(x, y) then
		-- shouldn't happen
		return "void", color.rgb("purple")
	end

	if x == player.x and y == player.y then
		return "player", color.rgb("green")
	else
		-- draw the feature
		local brightness = light.map[mymath.hash(x, y)] or 0
		local visible = los.visible(x, y)
		local r,g,b = 1, 0, 1

		if x == cursor_x and y == cursor_y then
			if los.visible(x, y) then
				r,g,b = color.rgb("orange")
			else
				r,g,b = color.rgb("red")
			end
		elseif los.visible(x,y) then
			r,g,b = 0.2 + 0.3 * brightness, 0.2 + 0.3 * brightness, 0.2 + 0.3 * brightness
		else
			return -- draw nothing
			-- r,g,b = color.rgb("dkred")
		end

		return self:feat_at(x, y) .. brightness, r, g, b
	end
end

function map:in_bounds(x, y)
	return x>=1 and x<=self.width and y>=1 and y<=self.height
end

function map:is_floor(x, y)
	return self:feat_at(x, y) == "floor"
end

function map:find_empty_floor()
	local x = love.math.random(2, self.width-1)
	local y = love.math.random(2, self.height-1)

	while self[x][y].feat ~= "floor" do
		x = love.math.random(2, self.width-1)
		y = love.math.random(2, self.height-1)
	end
	return x, y
end

return map
