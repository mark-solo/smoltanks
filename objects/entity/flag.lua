Flag = Entity:extend()

function Flag:new(map, px, py, color)
  local x = px * TILE_SIZE
  local y = py * TILE_SIZE
  self.map = map
  self.color = 'red' or color

  Flag.super.new(self, map.level, x, y, 0, TILE_SIZE, TILE_SIZE)

  self.collider = world:newRectangleCollider(px*TILE_SIZE, py*TILE_SIZE, TILE_SIZE, TILE_SIZE)
  self.collider:setType('static')
  self.collider:setCollisionClass('Flag')
  self.collider:setObject(self)

  local sw, sh = sprites['tiles']:getDimensions()
  local offset = color == 'red' and 0 or 1
  self.ok_quad = love.graphics.newQuad((4+offset)*sh, 0, sh, sh, sw, sh)
  self.broked_quad = love.graphics.newQuad((6+offset)*sh, 0, sh, sh, sw, sh)
  self.quad_id = self.map.background:add(self.ok_quad, x, y)

  self.destroyed = false
end

function Flag:setActive(value)
  self.collider:setActive(value)
end

function Flag:reset()
  self:setActive(true);
  self.destroyed = false;
  self.map.background:set(self.quad_id, self.ok_quad, self.x, self.y)
end

function Flag:destroy()
  self.destroyed = true;
  self.map.background:set(self.quad_id, self.broked_quad, self.x, self.y)
end
