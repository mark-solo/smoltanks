Label = Object:extend()

function Label:new(x, y, text, w, h)
  self.x = x or 100
  self.y = y or 100
  self.w = w or 100
  self.h = h or 20
  self.text = text or "meow"
end

function Label:draw()
  love.graphics.setColor(0.5, 0.5, 0.5)
  love.graphics.rectangle('fill', self.x, self.y, self.w, self.h)
  love.graphics.setColor(1, 1, 1)
  love.graphics.printf(self.text, self.x, self.y+(self.h-love.graphics.getFont():getHeight())/2, self.w, 'center')
end
