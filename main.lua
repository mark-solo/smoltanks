Object = require "lib.classic"
Input = require "lib.input"
wf = require "lib.windfield"
inspect = require "lib.inspect"
json = require "lib.json"

DEBUG = true
TILE_SIZE = 64

function love.load()
	love.window.setMode(TILE_SIZE*8, TILE_SIZE*8)

	local object_files = {}
  recursiveEnumerate('objects', object_files)
  requireFiles(object_files)

	input = Input()
	input:bind(   'up',    'up')
	input:bind( 'left',  'left')
	input:bind('right', 'right')
	input:bind( 'down',  'down')

	menu = MenuScene()
		main = MainScene()
		mode = ModeScene()
		settings = SettingsScene()
		exit = ExitScene()
	game = GameScene()
		play = PlayScene()
		reset = ResetScene()
		pause = PauseScene()
		final = FinalScene()

	Scene.setScene(menu)
end

function love.update(dt)
	scene:input()
	scene:update(dt)
end

function love.draw()
	scene:draw()
end

----------

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
