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
