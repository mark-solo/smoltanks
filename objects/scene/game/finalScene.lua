FinalScene = Scene:extend()

function FinalScene:input()
  if input:pressed('up') then Scene.setScene(play) end
  if input:pressed('left') then Scene.setScene(menu) end
end

function FinalScene:draw()
  love.graphics.setColor(1, 1, 1)
  love.graphics.print("final", 0, 0)
end
