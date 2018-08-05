img = {tile = {}}

function img.setup()
	img.tile_size = 16

	img.tileset = love.graphics.newImage("tileset.png")
	img.tileset:setFilter("nearest", "linear")

	img.nq("player", 				 0,  0)
	img.nq("cursor",				 2,  0)
	img.nq("void", 					 3,  0)

	img.nq("floor3", 				 0,  1)
	img.nq("floor2", 				 1,  1)
	img.nq("floor1", 				 2,  1)
	img.nq("floor0", 				 3,  1)
	img.nq("wall3", 				 0,  2)
	img.nq("wall2", 				 1,  2)
	img.nq("wall1", 				 2,  2)
	img.nq("wall0", 				 3,  2)
	img.nq("doorc3", 				 0,  3)
	img.nq("doorc2", 				 1,  3)
	img.nq("doorc1", 				 2,  3)
	img.nq("doorc0", 				 3,  3)
	img.nq("dooro3", 				 0,  4)
	img.nq("dooro2", 				 1,  4)
	img.nq("dooro1", 				 2,  4)
	img.nq("dooro0", 				 3,  4)

	img.tileset_batch = love.graphics.newSpriteBatch(img.tileset, 2000)
end

function img.nq(id, x, y)
	img.tile[id] = love.graphics.newQuad(x * img.tile_size, y * img.tile_size, img.tile_size, img.tile_size,
										img.tileset:getWidth(), img.tileset:getHeight())
end

function img.update_tileset_batch()
	img.tileset_batch:clear()
	for x=1, mainmap.width do
		for y=1, mainmap.height do
			tile_name, r, g, b = mainmap:tile_at(x, y)
			if tile_name then
				img.tileset_batch:setColor(r, g, b)
				img.tileset_batch:add(img.tile[tile_name], (x-1)*img.tile_size, (y-1)*img.tile_size)
			end
		end
	end

	img.tileset_batch:flush()
end

return img
