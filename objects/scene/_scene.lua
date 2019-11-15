Scene = Object:extend()

function Scene:new()
end

function Scene:input() end
function Scene:update(dt) end
function Scene:draw() end

function Scene:onEnter() end
function Scene:onExit() end

function Scene.setScene(nextScene)
  if scene ~= nil then
    scene:onExit()
  end

  scene = nextScene
  scene:onEnter()
end
