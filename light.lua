local light = {map = {}}

function light.cast(x, y, r1, r2, r3)
	los.compute(x, y,
		function(x, y, distance)
			if map:in_bounds(x, y) then
				local brightness
				if distance <= r1 then
					brightness = 3
				elseif distance <= r2 then
					brightness = 2
				else -- we only calculate out to r3
					brightness = 1
				end
				light.map[mymath.hash(x,y)] = light.map[mymath.hash(x,y)]
						and math.max(brightness, light.map[mymath.hash(x,y)]) or brightness
			end
		end,
		los.blocks_light_default, r3)
end

return light
