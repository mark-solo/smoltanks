Level = Object:extend() -- store entities

function Level:new(map, sizeX, sizeY)
  self.world = wf.newWorld(0, 0, true)

  self.map = Map(self, map, sizeX, sizeY)

  self.bullet = Bullet(self, TILE_SIZE*2, TILE_SIZE, math.pi/4)
  self.player = Player(self, TILE_SIZE, TILE_SIZE)
end

function Level:update(dt)
  self.player:update(dt)
  self.world:update(dt)
end

function Level:draw()
  self.map:draw()
  self.player:draw()

  if (DEBUG) then
		self.world:draw(0.2)
		draw_log()
	end
end
