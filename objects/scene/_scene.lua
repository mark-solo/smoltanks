Scene = Object:extend()

function Scene:new() end

function Scene:input() end
function Scene:handleEvent(e) end -- TODO: prepare event class

function Scene:update(dt) end
function Scene:fixedUpdate(dt) end

function Scene:render()
  love.graphics.setColor(1, 1, 1)
  love.graphics.rectangle('fill', love.graphics.getWidth()/2-100, love.graphics.getHeight()/2-50, 200, 100)
end

function Scene:onEnter() end
function Scene:onExit() end

function Scene.setScene(newScene)
  if scene then scene:onExit() end
  scene = newScene
  scene:onEnter()
end
