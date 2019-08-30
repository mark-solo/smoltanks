GameScene = Scene:extend() -- controls game logic

function GameScene:new(levelName)
  level = levels[levelName]
end

function GameScene:input()
  local ds = 0
  local da = 0

  if input:down('forward') then ds = ds + 1 end
  if input:down('back') then ds = ds - 1 end
  if input:down('right') then da = da + 1 end
  if input:down('left') then da = da - 1 end

  level:getEntity('player'):move(ds)
  level:getEntity('player'):turn(da)

  if input:pressed('dup') then camera.scale = camera.scale*0.5 end
	if input:pressed('ddown') then camera.scale = camera.scale*2 end

  if input:pressed('space') then level:getEntity('bullet'):launch(10000) end

end

function GameScene:update(dt)
  level:update(dt)

  camera:setPos(level:getEntity('player').x, level:getEntity('player').y)
end

function GameScene:render()
  level:draw()
end
