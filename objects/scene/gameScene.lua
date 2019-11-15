GameScene = Scene:extend()

function GameScene:onEnter()
  Scene.setScene(reset)
end
