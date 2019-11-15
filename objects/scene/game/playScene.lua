PlayScene = Scene:extend()

function PlayScene:input()
  if input:pressed('up') then Scene.setScene(reset) end
  if input:pressed('left') then Scene.setScene(pause) end
  if input:pressed('down') then Scene.setScene(final) end
end

function PlayScene:draw()
  love.graphics.setColor(1, 1, 1)
  love.graphics.print("play", 0, 0)
end
