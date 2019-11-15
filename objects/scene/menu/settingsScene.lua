SettingsScene = Scene:extend()

function SettingsScene:input()
  if input:pressed('left') then Scene.setScene(main) end
end

function SettingsScene:draw()
  love.graphics.setColor(1, 1, 1)
  love.graphics.print("settings", 0, 0)
end
