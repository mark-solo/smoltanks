Level = Object:extend() -- store and init entities

function Level:new(map, sizeX, sizeY)
  self.world = wf.newWorld(0, 0, true)
  self.world:addCollisionClass('Tank')
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

  local playerController = PlayerController()
  self.entities['player'] = Tank(self, TILE_SIZE, TILE_SIZE, playerController)
  local aiController = AIController()
  self.entities['aitank'] = Tank(self, 2*TILE_SIZE, TILE_SIZE, aiController)

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

  self.world:update(dt)
end

function Level:draw()
  self.map:draw()

  for _, entity in pairs(self.entities) do
    entity:draw()
  end

  if (DEBUG) then
    self.world:draw(0.2)
end

-- pool functions

function Level:getBullet()
  local bullet = table.remove(self.bullets, 1)
  table.insert(self.bullets, bullet)
  return bullet
end

-- pathfinding functions
