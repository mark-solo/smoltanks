Level = Object:extend() -- store entities

function Level:new(map, sizeX, sizeY)
  self.world = wf.newWorld(0, 0, true)
  self.world:addCollisionClass('Player')
  self.world:addCollisionClass('Bullet', {ignores = {'Bullet'}})
  self.world:addCollisionClass('Wall')

  self.map = Map(self, map, sizeX, sizeY)

  self.entities = {}

  self.bullets = {}
  for i=1,20 do
    local bullet = Bullet(self)
    table.insert(self.bullets, bullet)
    table.insert(self.entities, bullet)
  end
  --self.entities['bullet'] = Bullet(self, TILE_SIZE*2, TILE_SIZE, math.pi/2)

  self.entities['player'] = Player(self, TILE_SIZE, TILE_SIZE)

  log('entities: '..inspect(self.entities, {depth=1}))
end

function Level:getEntity(entityName)
  return self.entities[entityName]
end

function Level:input()
  for _, entity in pairs(self.entities) do
    if entity.input then
      entity:input()
    end
  end
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
  end
end

-- pool functions
function Level:initBullets(amount)
  --
end

function Level:getBullet()
  local bullet = table.remove(self.bullets, 1)
  table.insert(self.bullets, bullet)
  return bullet
end
