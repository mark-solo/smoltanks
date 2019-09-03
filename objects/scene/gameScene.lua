GameScene = Scene:extend() -- controls game logic

function GameScene:new(levelName)
  level = levels[levelName]
end

function GameScene:input()
  level:input()
end

function GameScene:update(dt)
  level:update(dt)

  camera:setPos(level:getEntity('player').x, level:getEntity('player').y)
end

function GameScene:render()
  level:draw()
end
