MenuScene = Scene:extend()

function MenuScene:new()
  self.buttons = {}
  table.insert(self.buttons, Button(100, 100, function() log("uh", "error") end, "bark"))
end

function MenuScene:input()
  if input:pressed('space') then Scene.setScene(gameScene) end
end

function MenuScene:update(dt)
  for _, button in pairs(self.buttons) do
    button:update()
  end
end

function MenuScene:render()
  if DEBUG then
    draw_log(0, 0)
  end

  for _, button in pairs(self.buttons) do
    button:draw()
  end
end
