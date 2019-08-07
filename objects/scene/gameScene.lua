GameScene = Scene:extend()

local player

function GameScene:new()
  player = Player()
end

function GameScene:input()
  local ds = 0
  local da = 0

  if input:down('forward') then ds = ds + 1 end
  if input:down('back') then ds = ds - 1 end
  if input:down('right') then da = da + 1 end
  if input:down('left') then da = da - 1 end

  player:move(ds)
  player:turn(da)
end

function GameScene:update(dt)
  player:update(dt)
end

function GameScene:render()
  player:draw()
end
