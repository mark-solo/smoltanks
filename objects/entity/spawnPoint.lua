SpawnPoint = Entity:extend()

function SpawnPoint:new(level, px, py)
  local x = px*TILE_SIZE
  local y = py*TILE_SIZE

  SpawnPoint.super.new(self, level, x, y, 0, TILE_SIZE, TILE_SIZE)

  self.entitiyCount = 0

  self.collider = level.world:newRectangleCollider(px*TILE_SIZE, py*TILE_SIZE, TILE_SIZE, TILE_SIZE)
  self.collider:setType('static')
  self.collider:setCollisionClass('Spawn')
  self.collider:setSensor(true)

  self.tank = nil -- tank to spawn
end

function SpawnPoint:update(dt)
  if self.tank~=nil then
    self.tank:spawn(self.x+TILE_SIZE/2, self.y+TILE_SIZE/2)
    self.tank = nil
  end
end

function SpawnPoint:isBusy()
  return #self.collider:getContacts()>0 and self.tank==nil
end

function SpawnPoint:draw()
  if self:isBusy() then
    love.graphics.setColor(0.5, 0.5, 0.5)
  else
    love.graphics.setColor(1, 0, 1)
  end
  local d = 0.2*TILE_SIZE
  love.graphics.rectangle('fill', self.x+d, self.y+d, self.w-2*d, self.h-2*d)

  love.graphics.setColor(1, 1, 1)
  love.graphics.print(self.entitiyCount, self.x+self.w/2, self.y+self.h/2)
end
