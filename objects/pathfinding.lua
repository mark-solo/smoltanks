Pathfinding = Object:extend()

Pathfinding.queue = {}
Pathfinding.order = {}

function Pathfinding.update(dt)
  --log('queue '..inspect(Pathfinding.order, {depth=1}))
  local tank = table.remove(Pathfinding.order, 1)
  if tank~=nil then
    local r_params = Pathfinding.queue[tank]

    local path =  Pathfinding.aStar(r_params.map, r_params.start, r_params.goal)
    path = Pathfinding.optimizePath(r_params.map, path)
    tank.path = path

    if tank.path~=nil then
      --log('made a path '..tank.id..' '..r_params.start..':'..r_params.goal)
      log('made a path '..r_params.start..':'..r_params.goal)
    end
  end
end

function Pathfinding.getPath(requester, map, start, goal)
  --local start = Pathfinding.inspectAndFixPoint(map, start, goal)
  local index = find(Pathfinding.order, requester)
  if index ~= nil then return end

  local goal = Pathfinding.inspectAndFixPoint(map, goal, start)

  local request_params = {}
  request_params.map = map
  request_params.start = start
  request_params.goal = goal

  Pathfinding.queue[requester] = request_params

  if index~=nil then table.remove(Pathfinding.order, index) end
  table.insert(Pathfinding.order, requester)
end

--

-- check if point is unwalkable and moves it somewhere walkable,
-- closer to relativeTo
function Pathfinding.inspectAndFixPoint(map, point, relativeTo)
  if point == relativeTo then return point end

  local new_point = point
  local is_walkable = false

  while not is_walkable do
    local neighbours = Pathfinding.getNeighbours(map, new_point)
    if #neighbours==0 then return new_point end -- well, fuck

    local neighbours_with_distance = {}
    for _, neighbour in ipairs(neighbours) do
      neighbours_with_distance[neighbour] = Pathfinding.heuristic(map, new_point, relativeTo)
    end

    new_point = min(neighbours_with_distance)

    local x, y = map:indexToPoint(new_point)
    is_walkable = map:isWalkable(x, y)
  end

  return new_point
end

function Pathfinding.optimizePath(map, path)
  if path==nil or #path<=2 then return path end

  local new_path = {}
  table.insert(new_path, path[1])
  local last_point = path[1]

  for i=1,#path-1 do
    local current_point = path[i]
    local next_point = path[i+1]

    local x1, y1 = map:indexToPoint(last_point)
    local x2, y2 = map:indexToPoint(next_point)
    local cols = world:queryLine((x1+0.5)*TILE_SIZE, (y1+0.5)*TILE_SIZE,
                                 (x2+0.5)*TILE_SIZE, (y2+0.5)*TILE_SIZE,
                                 {'Wall'})

    if (#cols>0) then
      table.insert(new_path, current_point)
      last_point = current_point
    end
  end

  table.insert(new_path, path[#path])

  return new_path
end

--

function Pathfinding.recontructPath(came_from, current)
  local total_path = {}

  local c = current
  while c~=nil do
    table.insert(total_path, 1, c)
    c = came_from[c]
  end

  return total_path
end

function Pathfinding.heuristic(map, current, goal)
  local cx, cy = map:indexToPoint(current)
  local gx, gy = map:indexToPoint(goal)

  local dx = cx-gx
  local dy = cy-gy

  return math.sqrt(dx*dx+dy*dy)
end

function Pathfinding.getNodeWithLowestScore(open, fScore)
  local minIndex = -1
  local min = 99999

  for i=1,#open do
    if min >= (fScore[open[i]] or 9999) then
      minIndex = i
      min = fScore[open[i]]
    end
  end

  return open[minIndex]
end

function Pathfinding.getNeighbours(map, node)
  local neighbours = {}
  local x, y = map:indexToPoint(node)

  for i=-1,1,2 do
    --if map:pointToNum(x+i, y)==0 then
    if map:isWalkable(x+i, y) then
      table.insert(neighbours, map:pointToIndex(x+i, y))
    end
    if map:isWalkable(x, y+i) then
      table.insert(neighbours, map:pointToIndex(x, y+i))
    end
  end

  return neighbours
end

function Pathfinding.aStar(map, start, goal)
  -- TODO: check start and goal for walkability and move if needed

  local open = {}
  table.insert(open, start)
  local closed = {}

  local came_from = {}

  -- for node stores cost of shortest path to this node from start
  local gScore = {} -- default to infinity, please
  gScore[start] = 0

  -- f(n) = g(n) + h(n)
  local fScore = {} -- default to infinity, please
  fScore[start] = Pathfinding.heuristic(map, start, goal)

  while #open>0 do
    local current = Pathfinding.getNodeWithLowestScore(open, fScore)
    if current == goal then
      return Pathfinding.recontructPath(came_from, current)
    end

    table.remove(open, find(open, current))
    table.insert(closed, current)
    local neighbours = Pathfinding.getNeighbours(map, current)
    for _, neighbour in ipairs(neighbours) do
      if find(closed, neighbour)==nil then
        local t_gScore = (gScore[current] or 99998) + Pathfinding.heuristic(map, current, neighbour)

        if t_gScore < (gScore[neighbour] or 99999) then
          came_from[neighbour] = current
          gScore[neighbour] = t_gScore
          fScore[neighbour] = gScore[neighbour] + Pathfinding.heuristic(map, neighbour, goal)
          if find(open, neighbour)==nil then
            table.insert(open, neighbour)
          end
        end
      end
    end
  end

  return nil
end
