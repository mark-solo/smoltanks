ModeScene = Scene:extend()

function ModeScene:input()
  if input:pressed('down') then Scene.setScene(main) end
  if input:pressed('right') then Scene.setScene(game) end
end

function ModeScene:draw()
  love.graphics.setColor(1, 1, 1)
  love.graphics.print("mode", 0, 0)
end
