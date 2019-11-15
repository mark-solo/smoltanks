ExitScene = Scene:extend()

function ExitScene:input()
  if input:pressed('up') then Scene.setScene(main) end
end

function ExitScene:draw()
  love.graphics.setColor(1, 1, 1)
  love.graphics.print("exit", 0, 0)
end
