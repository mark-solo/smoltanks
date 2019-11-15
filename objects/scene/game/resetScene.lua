ResetScene = Scene:extend()

function ResetScene:input()
  if input:pressed('down') then Scene.setScene(play) end
end

function ResetScene:draw()
  love.graphics.setColor(1, 1, 1)
  love.graphics.print("reset", 0, 0)
end
