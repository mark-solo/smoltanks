PlayerController = Object:extend()

function PlayerController:new()

end

function PlayerController:input(tank)
  local ds = 0
  local da = 0

  if input:down('forward') then ds = ds + 1 end
  if input:down('back') then ds = ds - 1 end
  if input:down('right') then da = da + 1 end
  if input:down('left') then da = da - 1 end

  tank:move(ds)
  tank:turn(da)

  if input:pressed('dup') then camera.scale = camera.scale*0.5 end
	if input:pressed('ddown') then camera.scale = camera.scale*2 end

  if love.mouse.isDown(1) then
    tank:shoot()
  end
end
