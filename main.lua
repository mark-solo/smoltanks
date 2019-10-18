-- libs
Object = require "lib.classic"
Input = require "lib.input"
wf = require "lib.windfield"
inspect = require "lib.inspect"

-- constants
DEBUG = true
TILE_SIZE = 64

-- core game local variable
local fixedUpdateRate = 0.02
local fixedUpdateTimer = 0

local log_text = {}
local last_logline_repeated = 0

timer = 0

function love.load()
	--love.window.setMode(640, 480)
	love.window.setMode(TILE_SIZE*8, TILE_SIZE*8)
	log('init')

	local object_files = {}
  recursiveEnumerate('objects', object_files)
  requireFiles(object_files)

	world = wf.newWorld(0, 0, true)
  world:addCollisionClass('Tank')
  world:addCollisionClass('Bullet', {ignores = {'Bullet'}})
  world:addCollisionClass('Wall')
  world:addCollisionClass('Spawn', {ignores = {'Spawn'}})

  --world = wf.newWorld(0, 0, true)
	r = ResourceManager()

	input = Input() -- TODO: move controls to options
	input:bind('w', 'forward')
	input:bind('s', 'back')
	input:bind('a', 'left')
	input:bind('d', 'right')
	input:bind('space', 'space')
	input:bind('mouse1', 'click')
	input:bind('up', 'dup')
	input:bind('down', 'ddown')
	input:bind('left', 'dleft')
	input:bind('right', 'dright')

	gameScene = GameScene('level01')
	Scene.setScene(gameScene)
	--scene = gameScene

	camera = Camera()
	--camera.scale = 0.25
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

	timer = timer + dt
end

function love.draw()
	scene:render()
	--love.graphics.draw(sprites['red'], TILE_SIZE*2, TILE_SIZE*2)

	if (DEBUG) then
		world:draw(0.2)

		draw_log(cameraToWorld(0, 0))
		love.graphics.print("FPS: "..tostring(love.timer.getFPS( )), cameraToWorld(love.graphics.getWidth()-50, 0))
	end
end

function love.event.quit()
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

--

function log(text, type)
	local type = type or 'info'

	local last_line = log_text[1]
	if last_line~=nil and last_line.text == text and last_line.type == type then
		last_logline_repeated = last_logline_repeated + 1
	else
		local message = {}

		if last_logline_repeated > 1 then
			message.text = 'last message was repeated '..last_logline_repeated..' times'
			message.type = 'warning'
		else
			message.text = text
			message.type = type
		end

		table.insert(log_text, 1, message)
		if #log_text > 50 then table.remove(log_text) end
		last_logline_repeated = 0
	end
end

function draw_log(x, y)
	local colors_for_types = {}
	colors_for_types['info'] = {1, 1, 1, 0.5}
	colors_for_types['warning'] = {1, 1, 0, 0.75}
	colors_for_types['error'] = {1, 0, 0, 1}

	for i, message in ipairs(log_text) do
		love.graphics.setColor(colors_for_types[message.type])
		love.graphics.print(message.text, x, y+(i-1)*12)
	end
end
