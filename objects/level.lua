Level = Object:extend() -- store entities

function Level:new(map, sizeX, sizeY)
  self.world = wf.newWorld(0, 0, true)

  self.map = Map(self, map, sizeX, sizeY)

  self.box = self.world:newRectangleCollider(love.graphics.getWidth()/2-50, love.graphics.getHeight()/2-30, 100, 60)
  self.box:applyAngularImpulse(5000)
  self.box:setMass(100)
  self.box:setLinearDamping(0.5)
  self.box:setAngularDamping(0.5)
  self.player = Player(self, 100, 100)
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
