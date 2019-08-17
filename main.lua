-- libs
Object = require "lib.classic"
Input = require "lib.input"
wf = require "lib.windfield"

-- constants
DEBUG = true

-- core game local variable
local fixedUpdateRate = 0.02
local fixedUpdateTimer = 0

local log_text = 'init'

function love.load()
	love.window.setMode(640, 480)

	local object_files = {}
  recursiveEnumerate('objects', object_files)
  requireFiles(object_files)

	r = ResourceManager()

	input = Input()
	input:bind('w', 'forward')
	input:bind('s', 'back')
	input:bind('a', 'left')
	input:bind('d', 'right')
	input:bind('space', 'space')

	world = wf.newWorld(0, 0, true)
	scene = GameScene()
end

function love.update(dt)
	scene:input()
	scene:update(dt)
	world:update(dt)

	fixedUpdateTimer = fixedUpdateTimer + dt
	if fixedUpdateTimer > fixedUpdateRate then
		scene:fixedUpdate(fixedUpdateTimer)
		--world:update(fixedUpdateTimer)
		fixedUpdateTimer = 0
	end
end

function love.draw()
	scene:render()

	if (DEBUG) then
		draw_log()
	end
end

function love.event.quit()
	print("logging")
	world.destroy()
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

function log(text)
	log_text = text..'\n'..log_text
end

function draw_log()
	love.graphics.print(log_text, 0, 0)
end
