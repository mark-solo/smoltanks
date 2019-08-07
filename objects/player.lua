Player = Object:extend()

function Player:new(x, y, w, h)
  self.x = x or 0
  self.y = y or 0
  self.w = w or 10
  self.h = h or 10
end

function Player:update(dt)

end

function Player:draw()
  love.graphics.setColor(1, 1, 1)
  love.graphics.rectangle('line', self.x, self.y, self.width, self.height)
end
