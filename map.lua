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
		return "void", color.rgb("purple")
	end

	if x == player.x and y == player.y then
		return "player", color.rgb("green")
	elseif x == cursor_x and y == cursor_y then
		if los.visible(x, y) then
			return self:feat_at(x, y), color.rgb("orange")
		else
			return self:feat_at(x, y), color.rgb("red")
		end
	else
		local distance = los.visible(x, y)
		if distance then
			distance = math.max(1, distance)
			return self:feat_at(x, y), 1 / distance, 1 / distance, 1 / distance
		else
			return self:feat_at(x, y), color.rgb("dkblue")
		end
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
