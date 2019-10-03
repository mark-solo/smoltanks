-- lua doesn't have find function for table
function find(tab, val)
  for index, value in ipairs(tab) do
    if value == val then
      return index
    end
  end

  return nil
end

function min(tab)
  --if #tab == 0 then return nil, nil end

  local key = next(tab)
  local min = tab[key]

  for k, v in pairs(tab) do
      if tab[k] < min then
          key, min = k, v
      end
  end

  return key, min
end

-- posiotioning utils
function worldToCamera(wx, wy)
  return wx-camera.x+love.graphics.getWidth()/2, wy-camera.y+love.graphics.getHeight()/2
end

function cameraToWorld(cx, cy)
	return camera.x+cx-love.graphics.getWidth()/2, camera.y+cy-love.graphics.getHeight()/2
end

function dirToAngle(dx, dy)
	return math.atan2(dy, dx)
end

function angleToDir(angle)
	return math.cos(angle), math.sin(angle)
end

function worldToPoint(wx, wy)
  local x = wx/TILE_SIZE
  local y = wy/TILE_SIZE
  return math.floor(x), math.floor(y)
end
