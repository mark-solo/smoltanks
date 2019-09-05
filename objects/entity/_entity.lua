Entity = Object:extend()

function Entity:new(level, x, y, angle, w, h)
  self.level = level
  self.x = x or 0
  self.y = y or 0
  self.angle = angle or 0
  self.w = w or TILE_SIZE*0.2
  self.h = h or TILE_SIZE*0.1
end

function Entity:reset()
  -- body...
end

function Entity:update()
  -- body...
end

function Entity:draw()
  -- body...
end
