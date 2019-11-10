SpawnPoint = Entity:extend()

function SpawnPoint:new(map, px, py, color)
  local x = px*TILE_SIZE
  local y = py*TILE_SIZE
  self.color = 'red' or color

  SpawnPoint.super.new(self, map.level, x, y, 0, TILE_SIZE, TILE_SIZE)

  self.entitiyCount = 0

  self.collider = world:newRectangleCollider(px*TILE_SIZE, py*TILE_SIZE, TILE_SIZE, TILE_SIZE)
  self.collider:setType('static')
  self.collider:setCollisionClass('Spawn')
  self.collider:setSensor(true)

  local sw, sh = sprites['tiles']:getDimensions()
  local offset = color == 'red' and 0 or 1
  local quad = love.graphics.newQuad((2+offset)*sh, 0, sh, sh, sw, sh)
  map.background:add(quad, x, y)

  self.tank = nil -- tank to spawn
end

function SpawnPoint:setActive(value)
  self.collider:setActive(value)
end

function SpawnPoint:update(dt)
  if self.tank~=nil then
    self.tank:spawn(self.x+TILE_SIZE/2, self.y+TILE_SIZE/2)
    self.tank = nil
  end
end

function SpawnPoint:isBusy()
  return #self.collider:getContacts()>0 or self.tank~=nil
end

function SpawnPoint:draw()
  if self:isBusy() then
    love.graphics.setColor(0.5, 0.5, 0.5)
    local d = 0.25*TILE_SIZE
    love.graphics.rectangle('fill', self.x+d, self.y+d, self.w-2*d, self.h-2*d)
  end

end
