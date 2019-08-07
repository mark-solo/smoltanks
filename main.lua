Object = require "lib.classic"
Input = require "lib.input"
wf = require "lib.windfield"

local fixedUpdateRate = 0.2
local fixedUpdateTimer = 0

function love.load()
	love.window.setMode(320, 240)

	local object_files = {}
  recursiveEnumerate('objects', object_files)
  requireFiles(object_files)

	input = Input()
	input:bind('w', 'forward')
	input:bind('s', 'back')
	input:bind('a', 'left')
	input:bind('d', 'right')

	world = wf.newWorld(0, 0, true)
	scene = GameScene()
end

function love.update(dt)
	scene:input()
	scene:update(dt)

	fixedUpdateTimer = fixedUpdateTimer + dt
	if fixedUpdateTimer > fixedUpdateRate then
		scene:fixedUpdate(fixedUpdateTimer)
		fixedUpdateTimer = 0
	end
end

function love.draw()
	scene:render()
end

---------

function recursiveEnumerate(folder, file_list)
    local items = love.filesystem.getDirectoryItems(folder)
    for _, item in ipairs(items) do
        local file = folder .. '/' .. item
        local type = love.filesystem.getInfo(file).type
        if type == "file" then
          table.insert(file_list, file)
        elseif type == "directory" then
          recursiveEnumerate(file, file_list)
        end
    end
end

function requireFiles(files)
    for _, file in ipairs(files) do
        local file = file:sub(1, -5)
        require(file)
    end
end
