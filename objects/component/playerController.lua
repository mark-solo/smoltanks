PlayerController = Object:extend()

function PlayerController:new()

end

function PlayerController:init(tank)

end

function PlayerController:input(tank)
  local ds = 0
  local da = 0

  if input.preset:down('forward') then ds = ds + 1 end
  if input.preset:down('back') then ds = ds - 1 end
  if input.preset:down('right') then da = da + 1 end
  if input.preset:down('left') then da = da - 1 end

  tank:move(ds)
  tank:turn(da)

  --if input:pressed('dup') then camera.scale = camera.scale*0.5 end
	--if input:pressed('ddown') then camera.scale = camera.scale*2 end

  local mouseX, mouseY = love.mouse.getPosition()
  local dirX = mouseX-tank.x
  local dirY = mouseY-tank.y
  tank:setTurretTo(dirToAngle(cameraToWorld(dirX, dirY)))

  if mousePressed then
    tank:shoot()
  end
end

function PlayerController:reset(tank)

end
