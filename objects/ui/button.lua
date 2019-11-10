Button = Object:extend()

buttonState = {
  idle = {
    execute = function(button)
      if button:doesMouseHoverOverMe() then
        button.state = buttonState.hover
      end
    end,
    color = {0.5, 0.5, 0.5}
  },
  hover = {
    execute = function(button)
      if not button:doesMouseHoverOverMe() then
        button.state = buttonState.idle
      end

      if mousePressed and not wasPressed then
        button.state = buttonState.press
      end
    end,
    color = {0.7, 0.7, 0.7}
  },
  press = {
    execute = function(button)
      button.action()
      button.state = buttonState.hover
    end,
    color = {0.9, 0.9, 0.9}
  }
}

function Button:doesMouseHoverOverMe()
  local mouseX, mouseY = love.mouse.getPosition()

  return mouseX > self.x and mouseX < self.x+self.w and
         mouseY > self.y and mouseY < self.y+self.h
end

function Button:new(x, y, action, text, w, h)
  self.x = x or 100
  self.y = y or 100
  self.w = w or TILE_SIZE*2
  self.h = h or TILE_SIZE*0.35
  self.text = text or "meow"
  self.action = action
  self.state = buttonState.idle
end

function Button:update()
  self.state.execute(self)
end

function Button:draw()
  love.graphics.setColor(self.state.color)
  love.graphics.rectangle('fill', self.x, self.y, self.w, self.h)
  love.graphics.setColor(1, 1, 1)
  love.graphics.printf(self.text, self.x, self.y+(self.h-love.graphics.getFont():getHeight())/2, self.w, 'center')
end
