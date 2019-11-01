Button = Object:extend()

buttonState = {
  idle = {
    execute = function(button)
      local mouseX, mouseY = love.mouse.getPosition()

      if mouseX > button.x and mouseX < button.x+button.w and
         mouseY > button.y and mouseY < button.y+button.h then
        button.state = buttonState.hover
      end
    end,
    color = {0.5, 0.5, 0.5}
  },
  hover = {
    execute = function(button)
      local mouseX, mouseY = love.mouse.getPosition()

      if mouseX < button.x or mouseX > button.x+button.w or
         mouseY < button.y or mouseY > button.y+button.h then
        button.state = buttonState.idle
      end

      if love.mouse.isDown(1) then
        button.state = buttonState.press
      end
    end,
    color = {0.7, 0.7, 0.7}
  },
  press = {
    execute = function(button)
      button.action()
    end,
    color = {0.9, 0.9, 0.9}
  }
}

function Button:new(x, y, action, text, w, h)
  self.x = x or 100
  self.y = y or 100
  self.w = w or 100
  self.h = h or 20
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
