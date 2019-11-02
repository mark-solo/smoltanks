Flag = Entity:extend()

function Flag:new(level, px, py)
  local x = px * TILE_SIZE
  local y = py * TILE_SIZE

  Flag.super.new(self, level, x, y, 0, TILE_SIZE, TILE_SIZE)

  self.collider = world:newRectangleCollider(px*TILE_SIZE, py*TILE_SIZE, TILE_SIZE, TILE_SIZE)
  self.collider:setType('static')
  self.collider:setCollisionClass('Flag')
  self.collider:setObject(self)

  self.destroyed = false
end

function Flag:setActive(value)
  self.collider:setActive(value)
end

function Flag:draw(args)
  if self.destroyed then
    love.graphics.setColor(1, 0.2, 0.2)
  else
    love.graphics.setColor(0.5, 0.5, 0.5)
  end
  local d = 0.2*TILE_SIZE
  love.graphics.rectangle('fill', self.x+d, self.y+d, self.w-2*d, self.h-2*d)
end
