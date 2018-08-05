local Map = {}
Map.__index = Map

local hash = mymath.hash
local unhash = mymath.hash

function Map.new(w, h)
	return setmetatable({ width = w or 0, height = h or 0 }, Map)
end

function Map:setup_mainmap()
	-- build mainmap and get things ready for the first player turn
	for x=1, self.width do
		for y=1, self.height do
			if x==1 or x==self.width or y==1 or y==self.height or mymath.one_chance_in(8) then
				self:set(x, y, "feat", "wall")
			elseif mymath.one_chance_in(32) then
				self:set(x, y, "feat", "doorc")
			elseif mymath.one_chance_in(32) then
				self:set(x, y, "feat", "dooro")
			else
				self:set(x, y, "feat", "floor")
			end
		end
	end
end

function Map:in_bounds(x, y)
	return x>=1 and x<=self.width and y>=1 and y<=self.height
end

local h
function Map:set(x, y, k, v)
	-- debug
	if not self:in_bounds(x, y) then
		error("bad coords ("..x..","..y..")")
	end
	h = hash(x, y)
	if not self[h] then
		self[h] = {}
	end
	self[h][k] = v
end

function Map:get(x, y, k)
	-- debug
	if not self:in_bounds(x, y) then
		error("bad coords ("..x..","..y..")")
	end
	h = hash(x, y)
	if not self[h] then
		return nil
	end
	return self[h][k]
end

function Map:tile_at(x, y)
	if not self:in_bounds(x, y) then
		-- shouldn't happen
		return "void", color.rgb("purple2")
	end

	if x == player.x and y == player.y then
		--obviously i can see MYSELF, mom, GAWD
		return "player", color.rgb("green" .. light.get(x,y))
	else
		local brightness = light.get(x,y)
		local visible = player.visible(x, y) and (brightness > 0)

		if visible then
			-- draw what we see
			return self:get(x, y, "feat") .. brightness, color.rgb("light" .. brightness)
		else
			-- draw whatever we remember being here before
			-- if the feat is nil we won't draw anything
			local feat = player.memory_map:get(x, y, "feat")
			if feat then
				brightness = player.memory_map:get(x, y, "brightness") or 0
				return feat .. brightness, color.rgb("grey0")
			end
		end
	end
end

function Map:can_walk(x, y)
	local feat = self:get(x, y, "feat")
	return feat == "floor" or feat == "dooro" or feat == "doorc"
end

function Map:find_empty_floor()
	local x = love.math.random(2, self.width-1)
	local y = love.math.random(2, self.height-1)

	while self:get(x, y, "feat") ~= "floor" do
		x = love.math.random(2, self.width-1)
		y = love.math.random(2, self.height-1)
	end
	return x, y
end

function Map:actor_at(x, y)
	-- return an actor id, or nil if empty
	return self:in_bounds(x,y) and self:get(x,y,"actor")
end

function Map:blocks_light(x, y)
	if self:in_bounds(x,y) then
		local feat = self:get(x, y, "feat")
		return feat == "wall" or feat == "doorc"
	end
	return true
end

return Map
