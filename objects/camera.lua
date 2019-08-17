Camera = Object:extend()

function Camera:new(x, y)
  self.x = x or 0
  self.y = y or 0
  self.angle = 0
  self.scale = 1
end

function Camera:apply()
  love.graphics.translate(self.x, self.y)
  love.graphics.rotate(self.angle)
  love.graphics.scale(self.scale, self.scale)
end
