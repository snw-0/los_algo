img = {tile = {}}

function img.setup()
	img.tile_size = 16

	img.tileset = love.graphics.newImage("tileset.png")
	img.tileset:setFilter("nearest", "linear")

	img.nq("player", 				0, 0)
	img.nq("void", 					3, 0)

	img.nq("floor3", 				0, 1)
	img.nq("floor2", 				1, 1)
	img.nq("floor1", 				2, 1)
	img.nq("floor0", 				3, 1)
	img.nq("wall3", 				0, 2)
	img.nq("wall2", 				1, 2)
	img.nq("wall1", 				2, 2)
	img.nq("wall0", 				3, 2)

	img.tileset_batch = love.graphics.newSpriteBatch(img.tileset, 2000)
end

function img.nq(id, x, y)
	img.tile[id] = love.graphics.newQuad(x * img.tile_size, y * img.tile_size, img.tile_size, img.tile_size,
										img.tileset:getWidth(), img.tileset:getHeight())
end

function img.update_tileset_batch()
	img.tileset_batch:clear()
	for x=1, map.width do
		for y=1, map.height do
			tile_name, r, g, b = map:tile_at(x, y)
			if tile_name then
				img.tileset_batch:setColor(r, g, b)
				img.tileset_batch:add(img.tile[tile_name], (x-1)*img.tile_size, (y-1)*img.tile_size)
			end
		end
	end

	img.tileset_batch:flush()
end

return img
