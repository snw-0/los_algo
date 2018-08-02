local mymath = {}

function mymath.averageAngles(...)
	local x,y = 0,0
	for i=1,select('#',...) do local a= select(i,...) x, y = x+math.cos(a), y+math.sin(a) end
	return math.atan2(y, x)
end

function mymath.clamp(low, n, high) return math.min(math.max(low, n), high) end

function mymath.dist(x1,y1, x2,y2) return math.max(math.abs(x1-x2), math.abs(y1-y2)) end

function mymath.collision(a, b)
    return a.x < b.x+b.w and
      	   b.x < a.x+a.w and
      	   a.y < b.y+b.h and
      	   b.y < a.y+a.h
end

local window_border = 32
function mymath.in_window(x, y)
	return (camera.x - window_border <= x and x < (camera.x + window.w + window_border)
			and camera.y - window_border <= y and y < (camera.y + window.h + window_border))
end

function mymath.abs_subtract(a, d)
	-- moves towards zero by d, d>=0
	if d >= math.abs(a) then return 0
	elseif a>0 then return a-d
	else return a+d
	end
end

function mymath.one_chance_in(n) return love.math.random(1,n) == 1 end

function mymath.coinflip() return love.math.random(1,2) == 1 end

function mymath.sign(n) return n>0 and 1 or n<0 and -1 or 0 end

function mymath.dir(a,b, x,y)
	-- find the direction from a,b to x,y, e.g. -1,-1 for nw
	return mymath.sign(x-a), mymath.sign(y-b)
end

return mymath
