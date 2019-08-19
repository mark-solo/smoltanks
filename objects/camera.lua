Camera = Object:extend()

function Camera:new(x, y)
  self.x = x or 0
  self.y = y or 0
  self.angle = 0
  self.scale = 1
end

function Camera:setPos(x, y)
  self.x = x
  self.y = y
end

function Camera:apply()
  --love.graphics.translate(-self.x-love.graphics.getWidth()/2, -self.y-love.graphics.getHeight()/2)
  love.graphics.translate(love.graphics.getWidth()/2, love.graphics.getHeight()/2)
  love.graphics.scale(self.scale)
  --love.graphics.translate(-self.x+love.graphics.getWidth()/2, -self.y+love.graphics.getHeight()/2)
  love.graphics.translate(-self.x, -self.y)
  love.graphics.rotate(self.angle)

end
