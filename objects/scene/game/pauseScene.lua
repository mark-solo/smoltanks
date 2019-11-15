PauseScene = Scene:extend()

function PauseScene:input()
  if input:pressed('right') then Scene.setScene(play) end
end

function PauseScene:draw()
  love.graphics.setColor(1, 1, 1)
  love.graphics.print("pause", 0, 0)
end
