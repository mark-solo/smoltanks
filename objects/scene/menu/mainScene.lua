MainScene = Scene:extend()

function MainScene:input()
  if input:pressed('up') then Scene.setScene(mode) end
  if input:pressed('right') then Scene.setScene(settings) end
  if input:pressed('down') then Scene.setScene(exit) end
end

function MainScene:draw()
  love.graphics.setColor(1, 1, 1)
  love.graphics.print("main", 0, 0)
end
