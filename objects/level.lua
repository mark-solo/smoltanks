Level = Object:extend() -- store entities

function Level:new(map, sizeX, sizeY)
  self.world = wf.newWorld(0, 0, true)

  self.map = Map(self, map, sizeX, sizeY)

  self.entities = {}
  self.entities['bullet'] = Bullet(self, TILE_SIZE*2, TILE_SIZE, 0)
  self.entities['player'] = Player(self, TILE_SIZE, TILE_SIZE)

  log('entities: '..inspect(self.entities, {depth=1}))
end

function Level:getEntity(entityName)
  return self.entities[entityName]
end

function Level:update(dt)
  for _, entity in pairs(self.entities) do
    entity:update(dt)
  end
  --self.bullet:update(dt)
  --self.player:update(dt)
  self.world:update(dt)
end

function Level:draw()
  self.map:draw()

  for _, entity in pairs(self.entities) do
    entity:draw()
  end
  --self.bullet:draw()
  --self.player:draw()

  if (DEBUG) then
		self.world:draw(0.2)
		draw_log()
	end
end
