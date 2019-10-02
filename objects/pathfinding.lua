Pathfinding = Object:extend()

Pathfinding.queue = {}
Pathfinding.order = {}

function Pathfinding.update(dt)
  --log('queue '..inspect(Pathfinding.order, {depth=1}))
  local tank = table.remove(Pathfinding.order, 1)
  if tank~=nil then
    local r_params = Pathfinding.queue[tank]
    log('made a path '..tank.id..' '..r_params.start..':'..r_params.goal)
    tank.path = Pathfinding.aStar(r_params.map, r_params.start, r_params.goal)
  end
end

function Pathfinding.getPath(requester, map, start, goal)
  local request_params = {}
  request_params.map = map
  request_params.start = start
  request_params.goal = goal

  Pathfinding.queue[requester] = request_params
  local index = find(Pathfinding.order, requester)
  if index~=nil then table.remove(Pathfinding.order, index) end
  table.insert(Pathfinding.order, requester)
end

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
    if map:pointToNum(x+i, y)==0 then
      table.insert(neighbours, map:pointToIndex(x+i, y))
    end
    if map:pointToNum(x, y+i)==0 then
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
