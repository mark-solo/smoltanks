MenuScene = Scene:extend()

function MenuScene:new()

end

function MenuScene:input()
  if input:pressed('space') then Scene.setScene(gameScene) end
end

function MenuScene:update(dt)

end

function MenuScene:render()

end
