Panel = Object:extend()

function Panel:new(active)
  self.active = active or false
  self.buttons = buttons or {}
end

function Panel:addButton(button)
  table.insert(self.buttons, button)
end

function Panel:setActive(value)
  self.active = value
end

function Panel:update()
  if self.active then
    for _, button in pairs(self.buttons) do
      button:update()
    end
  end
end

function Panel:draw()
  if self.active then
    for _, button in pairs(self.buttons) do
      button:draw()
    end
  end
end
